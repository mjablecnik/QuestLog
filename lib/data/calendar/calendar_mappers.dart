import 'package:drift/drift.dart';

import '../../core/cadence.dart' show Cadence;
import '../../core/calendar/event_type.dart';
import '../../core/calendar/repeat_rule.dart';
import '../database.dart';
import 'calendar_models.dart';

/// The columns that store a [RepeatRule].
typedef RepeatColumns = ({
  String kind,
  int? easterOffset,
  int? nthMonth,
  int? nthWeekday,
  int? nthOrdinal,
  DateTime? end,
});

RepeatColumns repeatToColumns(RepeatRule rule) => switch (rule) {
  NoRepeat() => (kind: 'none', easterOffset: null, nthMonth: null, nthWeekday: null, nthOrdinal: null, end: rule.end),
  CadenceRepeat(:final Cadence cadence) => (
    kind: cadence.name,
    easterOffset: null,
    nthMonth: null,
    nthWeekday: null,
    nthOrdinal: null,
    end: rule.end,
  ),
  EasterRelative(:final int offsetDays) => (
    kind: 'easter',
    easterOffset: offsetDays,
    nthMonth: null,
    nthWeekday: null,
    nthOrdinal: null,
    end: rule.end,
  ),
  NthWeekday(:final int month, :final int weekday, :final int ordinal) => (
    kind: 'nthWeekday',
    easterOffset: null,
    nthMonth: month,
    nthWeekday: weekday,
    nthOrdinal: ordinal,
    end: rule.end,
  ),
};

/// Reads a rule back; an unknown or incomplete rule reads as no repeat.
RepeatRule repeatFromColumns(RepeatColumns c) => switch (c.kind) {
  'daily' => CadenceRepeat(Cadence.daily, end: c.end),
  'weekly' => CadenceRepeat(Cadence.weekly, end: c.end),
  'monthly' => CadenceRepeat(Cadence.monthly, end: c.end),
  'yearly' => CadenceRepeat(Cadence.yearly, end: c.end),
  'easter' when c.easterOffset != null => EasterRelative(c.easterOffset!, end: c.end),
  'nthWeekday' when c.nthMonth != null && c.nthWeekday != null && c.nthOrdinal != null =>
    NthWeekday(month: c.nthMonth!, weekday: c.nthWeekday!, ordinal: c.nthOrdinal!, end: c.end),
  _ => NoRepeat(end: c.end),
};

extension CalendarEventRowMapping on CalendarEventRow {
  CalendarEvent toModel() => CalendarEvent(
    id: id,
    name: name,
    note: note,
    location: location,
    type: EventType.fromKey(eventType),
    startDate: startDate,
    endDate: endDate,
    startMinute: startMinute,
    endMinute: endMinute,
    repeat: repeatFromColumns((
      kind: repeatKind,
      easterOffset: easterOffset,
      nthMonth: nthMonth,
      nthWeekday: nthWeekday,
      nthOrdinal: nthOrdinal,
      end: repeatEnd,
    )),
    onBoard: onBoard,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension CalendarCompletionRowMapping on CalendarCompletionRow {
  EventCompletion toModel() => EventCompletion(
    eventId: eventId,
    occurrenceDate: occurrenceDate,
    completedAt: completedAt,
    awardedXp: awardedXp,
  );
}

/// An insert for [draft]; [createdAt] and [updatedAt] come from the caller's Clock.
CalendarEventsCompanion eventCompanion(
  EventDraft draft, {
  int? id,
  required DateTime createdAt,
  required DateTime updatedAt,
}) {
  final RepeatColumns r = repeatToColumns(draft.repeat);
  return CalendarEventsCompanion(
    id: id == null ? const Value.absent() : Value(id),
    name: Value(draft.name),
    note: Value(draft.note),
    location: Value(draft.location),
    eventType: Value(draft.type.key),
    startDate: Value(draft.startDate),
    endDate: Value(draft.endDate),
    startMinute: Value(draft.startMinute),
    endMinute: Value(draft.endMinute),
    repeatKind: Value(r.kind),
    easterOffset: Value(r.easterOffset),
    nthMonth: Value(r.nthMonth),
    nthWeekday: Value(r.nthWeekday),
    nthOrdinal: Value(r.nthOrdinal),
    repeatEnd: Value(r.end),
    onBoard: Value(draft.onBoard),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
