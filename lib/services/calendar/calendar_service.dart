import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/calendar/address_history.dart';
import '../../core/calendar/calendar_dates.dart';
import '../../core/calendar/event_type.dart';
import '../../core/calendar/event_xp.dart';
import '../../core/calendar/repeat_rule.dart';
import '../../core/clock.dart';
import '../../core/errors.dart';
import '../../core/validation.dart';
import '../../data/calendar/calendar_mappers.dart';
import '../../data/calendar/calendar_models.dart';
import '../../data/database.dart';
import '../../data/tables.dart';
import '../xp_engine.dart';

/// Which occurrences of a repeating event a deletion removes.
enum DeleteScope { onlyThis, thisAndFollowing, all }

/// What completing an Event_Task did: the stored completion and the Level change.
class CompleteEventResult {
  const CompleteEventResult({
    required this.completion,
    required this.awardedXp,
    required this.levelBefore,
    required this.levelAfter,
  });

  final EventCompletion completion;

  /// 0 when the occurrence was already completed.
  final int awardedXp;
  final int levelBefore;
  final int levelAfter;
}

const int maxLocationLength = 120;

DateTime _dateOnly(DateTime v) => DateTime(v.year, v.month, v.day);

String _key(DateTime d) => const DateOnlyConverter().toSql(d);

/// Creates, edits, deletes and queries Calendar_Events, expands their repeats
/// into occurrences at read time, and completes Event_Tasks for XP.
class CalendarService {
  CalendarService(this._db, this._xp, this._clock);

  final QuestlogDatabase _db;
  final XpEngine _xp;
  final Clock _clock;

  /// The calendar date of the [Clock] (Calendar_Today).
  DateTime get calendarToday => _dateOnly(_clock.now());

  // ---- writes ----

  Future<CalendarEvent> create(EventDraft draft) async {
    final EventDraft valid = _validated(draft);
    return _db.runTransaction(() async {
      final DateTime now = _clock.now();
      final int id = await _db
          .into(_db.calendarEvents)
          .insert(eventCompanion(valid, createdAt: now, updatedAt: now));
      await _rememberAddress(valid.location, now);
      return (await _load(id)).toModel();
    });
  }

  /// Edits the whole series (Requirement 9.9).
  Future<CalendarEvent> update(int id, EventDraft draft) async {
    final EventDraft valid = _validated(draft);
    return _db.runTransaction(() async {
      final CalendarEventRow row = await _load(id);
      await (_db.update(_db.calendarEvents)..where((t) => t.id.equals(id))).write(
        eventCompanion(valid, createdAt: row.createdAt, updatedAt: _clock.now()),
      );
      await _rememberAddress(valid.location, _clock.now());
      return (await _load(id)).toModel();
    });
  }

  Future<void> _rememberAddress(String? location, DateTime now) async {
    if (location == null) return;
    final String address = location.trim();
    await _db.into(_db.calendarAddresses).insertOnConflictUpdate(
      CalendarAddressesCompanion.insert(
        key: addressKey(address),
        address: address,
        lastUsedAt: now,
      ),
    );
  }

  /// The remembered addresses that match [typed], most recently used first, at
  /// most [limit]. An address not used for [addressRetention] is never returned.
  Future<List<String>> suggestAddresses(String typed, {int limit = maxAddressSuggestions}) async {
    final DateTime cutoff = _clock.now().subtract(addressRetention);
    final List<CalendarAddressRow> rows = await (_db.select(_db.calendarAddresses)
          ..where((t) => t.lastUsedAt.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.lastUsedAt), (t) => OrderingTerm.asc(t.key)]))
        .get();
    return <String>[
      for (final CalendarAddressRow row in rows)
        if (matchesAddress(row.address, typed)) row.address,
    ].take(limit).toList();
  }

  /// Forgets the addresses not used for [addressRetention]. Events keep theirs.
  Future<void> purgeExpiredAddresses() async {
    final DateTime cutoff = _clock.now().subtract(addressRetention);
    await (_db.delete(_db.calendarAddresses)..where((t) => t.lastUsedAt.isSmallerThanValue(cutoff))).go();
  }

  /// Deletes the occurrence that starts on [occurrenceDate] according to [scope].
  ///
  /// An event without a repeat is deleted whatever the scope. Total_XP is never
  /// changed. The returned snapshot undoes the deletion through [restore].
  Future<DeletedEventSnapshot> deleteOccurrence(
    int id,
    DateTime occurrenceDate,
    DeleteScope scope,
  ) {
    final DateTime date = _dateOnly(occurrenceDate);
    return _db.runTransaction(() async {
      final CalendarEventRow row = await _load(id);
      final CalendarEvent event = row.toModel();
      final DeletedEventSnapshot snapshot = DeletedEventSnapshot(
        event: event,
        skippedDates: await _skipped(id),
        questId: (await (_db.select(_db.quests)..where((q) => q.eventId.equals(id))).getSingleOrNull())?.id,
        completions: (await (_db.select(_db.calendarCompletions)..where((t) => t.eventId.equals(id))).get())
            .map((CalendarCompletionRow r) => r.toModel())
            .toList(),
      );

      Future<void> deleteEvent() =>
          (_db.delete(_db.calendarEvents)..where((t) => t.id.equals(id))).go();

      if (event.repeat is NoRepeat || scope == DeleteScope.all) {
        await deleteEvent();
      } else if (scope == DeleteScope.onlyThis) {
        await _db
            .into(_db.calendarSkippedDates)
            .insert(
              CalendarSkippedDatesCompanion.insert(eventId: id, skippedOn: date),
              mode: InsertMode.insertOrIgnore,
            );
      } else {
        final DateTime? firstOccurrence = occurrenceStarts(
          firstStart: event.startDate,
          spanDays: event.spanDays,
          rule: event.repeat,
          skipped: snapshot.skippedDates.toSet(),
          from: event.startDate,
          to: date,
        ).firstOrNull;
        if (firstOccurrence == null || !date.isAfter(firstOccurrence)) {
          await deleteEvent();
        } else {
          final DateTime dayBefore = DateTime(date.year, date.month, date.day - 1);
          final DateTime? current = event.repeat.end;
          final DateTime newEnd = current != null && current.isBefore(dayBefore) ? current : dayBefore;
          final RepeatColumns columns = repeatToColumns(event.repeat.withEnd(newEnd));
          await (_db.update(_db.calendarEvents)..where((t) => t.id.equals(id))).write(
            CalendarEventsCompanion(repeatEnd: Value(columns.end)),
          );
        }
      }
      return snapshot;
    });
  }

  /// Puts back what [deleteOccurrence] removed, exactly as it was.
  Future<void> restore(DeletedEventSnapshot snapshot) {
    return _db.runTransaction(() async {
      final CalendarEvent e = snapshot.event;
      await _db.into(_db.calendarEvents).insertOnConflictUpdate(
        eventCompanion(
          EventDraft.fromEvent(e),
          id: e.id,
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
        ),
      );
      await (_db.delete(_db.calendarSkippedDates)..where((t) => t.eventId.equals(e.id))).go();
      for (final DateTime d in snapshot.skippedDates) {
        await _db.into(_db.calendarSkippedDates).insert(
          CalendarSkippedDatesCompanion.insert(eventId: e.id, skippedOn: d),
        );
      }
      final int? questId = snapshot.questId;
      if (questId != null) {
        await (_db.update(_db.quests)..where((q) => q.id.equals(questId))).write(
          QuestsCompanion(eventId: Value(e.id)),
        );
      }
      for (final EventCompletion c in snapshot.completions) {
        await _db.into(_db.calendarCompletions).insertOnConflictUpdate(
          CalendarCompletionsCompanion.insert(
            eventId: c.eventId,
            occurrenceDate: c.occurrenceDate,
            completedAt: c.completedAt,
            awardedXp: c.awardedXp,
          ),
        );
      }
    });
  }

  // ---- reads ----

  Future<CalendarEvent?> getEvent(int id) async {
    final CalendarEventRow? row =
        await (_db.select(_db.calendarEvents)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toModel();
  }

  Stream<CalendarEvent?> watchEvent(int id) {
    return (_db.select(_db.calendarEvents)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((CalendarEventRow? r) => r?.toModel());
  }

  /// The occurrences that touch [from]..[to] (dates), sorted by start date,
  /// all-day first, then by start minute. Re-emits when any calendar table changes.
  Stream<List<EventOccurrence>> watchRange(DateTime from, DateTime to) =>
      _watchAll(() => occurrencesIn(from, to));

  /// The occurrences of On_Board events that start on [today].
  Stream<List<EventOccurrence>> watchEventTasks(DateTime today) {
    final DateTime day = _dateOnly(today);
    return _watchAll(() async {
      final List<EventOccurrence> all = await occurrencesIn(day, day);
      return all.where((EventOccurrence o) => o.event.onBoard && o.start == day).toList();
    });
  }

  /// The occurrences that touch [from]..[to], without watching.
  Future<List<EventOccurrence>> occurrencesIn(DateTime from, DateTime to) async {
    final DateTime lo = _dateOnly(from);
    final DateTime hi = _dateOnly(to);
    final List<CalendarEventRow> rows = await (_db.select(_db.calendarEvents)
          ..where((t) => t.startDate.isSmallerOrEqual(Variable<String>(_key(hi)))))
        .get();
    if (rows.isEmpty) return <EventOccurrence>[];
    final Map<int, Set<DateTime>> skipped = <int, Set<DateTime>>{};
    for (final CalendarSkippedDateRow s in await _db.select(_db.calendarSkippedDates).get()) {
      skipped.putIfAbsent(s.eventId, () => <DateTime>{}).add(s.skippedOn);
    }
    final List<CalendarEvent> events = rows.map((CalendarEventRow r) => r.toModel()).toList();
    final int widest = events.fold<int>(0, (int m, CalendarEvent e) => e.spanDays > m ? e.spanDays : m);
    final DateTime completionsFrom = DateTime(lo.year, lo.month, lo.day - widest);
    final Map<(int, DateTime), EventCompletion> completions = <(int, DateTime), EventCompletion>{
      for (final CalendarCompletionRow c in await (_db.select(_db.calendarCompletions)
            ..where((t) => t.occurrenceDate.isBiggerOrEqual(Variable<String>(_key(completionsFrom))) &
                t.occurrenceDate.isSmallerOrEqual(Variable<String>(_key(hi)))))
          .get())
        (c.eventId, c.occurrenceDate): c.toModel(),
    };
    final List<EventOccurrence> out = <EventOccurrence>[];
    for (final CalendarEvent e in events) {
      for (final DateTime start in occurrenceStarts(
        firstStart: e.startDate,
        spanDays: e.spanDays,
        rule: e.repeat,
        skipped: skipped[e.id] ?? const <DateTime>{},
        from: lo,
        to: hi,
      )) {
        out.add(EventOccurrence(event: e, start: start, completion: completions[(e.id, start)]));
      }
    }
    out.sort(compareOccurrences);
    return out;
  }

  /// Events whose name, note or location contains [text], ignoring case and
  /// diacritics, one result per event.
  ///
  /// Each result carries the nearest occurrence on or after Calendar_Today, or
  /// the latest one when none is upcoming. Upcoming first, then past ones, the
  /// latest first.
  Future<List<SearchResult>> search(String text) async {
    final String needle = searchKey(text.trim());
    if (needle.isEmpty) return <SearchResult>[];
    final DateTime today = calendarToday;
    final List<CalendarEvent> events =
        (await _db.select(_db.calendarEvents).get()).map((CalendarEventRow r) => r.toModel()).toList();
    final Map<int, Set<DateTime>> skipped = <int, Set<DateTime>>{};
    for (final CalendarSkippedDateRow s in await _db.select(_db.calendarSkippedDates).get()) {
      skipped.putIfAbsent(s.eventId, () => <DateTime>{}).add(s.skippedOn);
    }
    final List<SearchResult> upcoming = <SearchResult>[];
    final List<SearchResult> past = <SearchResult>[];
    for (final CalendarEvent e in events) {
      final String haystack = searchKey('${e.name}\n${e.note ?? ''}\n${e.location ?? ''}');
      if (!haystack.contains(needle)) continue;
      final Set<DateTime> skip = skipped[e.id] ?? const <DateTime>{};
      final DateTime? next = occurrenceStarts(
        firstStart: e.startDate,
        spanDays: 0,
        rule: e.repeat,
        skipped: skip,
        from: today,
        to: DateTime(today.year + 3, today.month, today.day),
      ).firstOrNull;
      if (next != null) {
        upcoming.add(SearchResult(event: e, occurrenceDate: next));
        continue;
      }
      final DateTime lastDay = DateTime(today.year, today.month, today.day - 1);
      if (lastDay.isBefore(e.startDate)) continue;
      final DateTime? last = occurrenceStarts(
        firstStart: e.startDate,
        spanDays: 0,
        rule: e.repeat,
        skipped: skip,
        from: e.startDate,
        to: lastDay,
      ).lastOrNull;
      if (last != null) past.add(SearchResult(event: e, occurrenceDate: last));
    }
    int byDate(SearchResult a, SearchResult b) => a.occurrenceDate.compareTo(b.occurrenceDate);
    upcoming.sort(byDate);
    past.sort((SearchResult a, SearchResult b) => byDate(b, a));
    return <SearchResult>[...upcoming, ...past];
  }

  /// The type of the most recently saved event, or Meeting when none was saved
  /// yet. Built-in events (saved at the epoch) do not count.
  Future<EventType> lastUsedType() async {
    final CalendarEventRow? row = await (_db.select(_db.calendarEvents)
          ..where((t) =>
              t.updatedAt.isBiggerThanValue(DateTime.fromMillisecondsSinceEpoch(0)) &
              t.eventType.equals(EventType.quest.key).not())
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? EventType.meeting : EventType.fromKey(row.eventType);
  }

  // ---- Event_Tasks ----

  /// Completes the occurrence that starts on [occurrenceDate] and awards its
  /// Event_XP, in one transaction. An occurrence that is already completed is
  /// returned unchanged and awards nothing.
  Future<CompleteEventResult> completeOccurrence(int id, DateTime occurrenceDate) {
    final DateTime date = _dateOnly(occurrenceDate);
    return _db.runTransaction(() async {
      final CalendarEvent event = (await _load(id)).toModel();
      final CalendarCompletionRow? existing = await _completion(id, date);
      if (existing != null) {
        final int level = (await _xp.apply(0)).levelAfter;
        return CompleteEventResult(
          completion: existing.toModel(),
          awardedXp: 0,
          levelBefore: level,
          levelAfter: level,
        );
      }
      final bool isOccurrence = occurrenceStarts(
        firstStart: event.startDate,
        spanDays: event.spanDays,
        rule: event.repeat,
        skipped: (await _skipped(id)).toSet(),
        from: date,
        to: date,
      ).contains(date);
      if (!isOccurrence) {
        throw const InvalidStateError('the date is not an occurrence of the event');
      }
      final int xp = eventXp(type: event.type, allDay: event.allDay, duration: event.duration);
      final DateTime now = _clock.now();
      await _db.into(_db.calendarCompletions).insert(
        CalendarCompletionsCompanion.insert(
          eventId: id,
          occurrenceDate: date,
          completedAt: now,
          awardedXp: xp,
        ),
      );
      final change = await _xp.apply(xp);
      return CompleteEventResult(
        completion: EventCompletion(eventId: id, occurrenceDate: date, completedAt: now, awardedXp: xp),
        awardedXp: xp,
        levelBefore: change.levelBefore,
        levelAfter: change.levelAfter,
      );
    });
  }

  /// Takes the completion back and removes the XP it awarded.
  Future<void> reopenOccurrence(int id, DateTime occurrenceDate) {
    final DateTime date = _dateOnly(occurrenceDate);
    return _db.runTransaction(() async {
      final CalendarCompletionRow? existing = await _completion(id, date);
      if (existing == null) return;
      await (_db.delete(_db.calendarCompletions)
            ..where((t) => t.eventId.equals(id) & t.occurrenceDate.equals(_key(date))))
          .go();
      await _xp.apply(-existing.awardedXp);
    });
  }

  // ---- helpers ----

  Future<CalendarEventRow> _load(int id) async {
    final CalendarEventRow? row =
        await (_db.select(_db.calendarEvents)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw NotFoundError('calendar event', id);
    return row;
  }

  Future<List<DateTime>> _skipped(int id) async => (await (_db.select(_db.calendarSkippedDates)
            ..where((t) => t.eventId.equals(id)))
          .get())
      .map((CalendarSkippedDateRow r) => r.skippedOn)
      .toList();

  Future<CalendarCompletionRow?> _completion(int id, DateTime date) {
    return (_db.select(_db.calendarCompletions)
          ..where((t) => t.eventId.equals(id) & t.occurrenceDate.equals(_key(date))))
        .getSingleOrNull();
  }

  /// Emits [read] once and again after every change of a calendar table.
  ///
  /// Listens to the table updates themselves instead of to a query, so an idle
  /// calendar holds no query of its own and never delays the other streams.
  Stream<T> _watchAll<T>(Future<T> Function() read) {
    late final StreamController<T> controller;
    StreamSubscription<Set<TableUpdate>>? subscription;
    bool busy = false;
    bool again = false;

    // Reads once at a time; a change that arrives during a read schedules one more.
    Future<void> emit() async {
      if (busy) {
        again = true;
        return;
      }
      busy = true;
      try {
        do {
          again = false;
          final T value = await read();
          if (!controller.isClosed) controller.add(value);
        } while (again && !controller.isClosed);
      } catch (error, stack) {
        if (!controller.isClosed) controller.addError(error, stack);
      } finally {
        busy = false;
      }
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = _db
            .tableUpdates(
              TableUpdateQuery.onAllTables(<TableInfo>[
                _db.calendarEvents,
                _db.calendarSkippedDates,
                _db.calendarCompletions,
              ]),
            )
            .listen((_) => emit());
        emit();
      },
      onCancel: () async => subscription?.cancel(),
    );
    return controller.stream;
  }

  EventDraft _validated(EventDraft draft) {
    final String name = validatedName(draft.name, 'name');
    final String? note = _blankToNull(validatedNote(draft.note));
    final String? location = _blankToNull(draft.location == null
        ? null
        : (draft.location!.trim().isEmpty
              ? null
              : validatedName(draft.location!, 'location', maxLength: maxLocationLength)));
    final DateTime start = _dateOnly(draft.startDate);
    final DateTime end = _dateOnly(draft.endDate);
    if (end.isBefore(start)) throw const ValidationError('end', 'must not be before the start');
    int? startMinute = draft.startMinute;
    int? endMinute = draft.endMinute;
    if ((startMinute == null) != (endMinute == null)) {
      throw const ValidationError('time', 'start and end minutes go together');
    }
    if (startMinute != null && endMinute != null) {
      if (startMinute < 0 || startMinute > 1439 || endMinute < 0 || endMinute > 1439) {
        throw const ValidationError('time', 'minutes must be 0..1439');
      }
      if (start == end && endMinute < startMinute) {
        throw const ValidationError('end', 'must not be before the start');
      }
    } else {
      startMinute = null;
      endMinute = null;
    }
    final DateTime? repeatEnd = draft.repeat.end == null ? null : _dateOnly(draft.repeat.end!);
    if (repeatEnd != null && repeatEnd.isBefore(start)) {
      throw const ValidationError('repeatEnd', 'must not be before the start date');
    }
    return EventDraft(
      name: name,
      note: note,
      location: location,
      type: draft.type,
      startDate: start,
      endDate: end,
      startMinute: startMinute,
      endMinute: endMinute,
      repeat: draft.repeat.withEnd(repeatEnd),
      onBoard: draft.onBoard,
    );
  }

  String? _blankToNull(String? v) => v == null || v.trim().isEmpty ? null : v;
}

/// Orders occurrences by start date, then all-day first, then start minute,
/// then name, then id.
int compareOccurrences(EventOccurrence a, EventOccurrence b) {
  final int byDate = a.start.compareTo(b.start);
  if (byDate != 0) return byDate;
  if (a.event.allDay != b.event.allDay) return a.event.allDay ? -1 : 1;
  final int byMinute = (a.event.startMinute ?? 0).compareTo(b.event.startMinute ?? 0);
  if (byMinute != 0) return byMinute;
  final int byName = a.event.name.compareTo(b.event.name);
  return byName != 0 ? byName : a.event.id.compareTo(b.event.id);
}
