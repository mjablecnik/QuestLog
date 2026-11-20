import 'package:drift/drift.dart';

import '../core/board_day.dart';
import '../core/clock.dart';
import '../core/errors.dart';
import '../core/xp_rules.dart';
import '../core/validation.dart';
import '../core/calendar/event_type.dart';
import '../data/calendar/calendar_mappers.dart';
import '../data/calendar/calendar_models.dart';
import '../data/database.dart';
import '../data/mappers.dart';
import '../data/quest_writes.dart';
import '../data/models.dart';
import 'xp_engine.dart';

/// Creates, edits, deletes, completes, reopens and reorders Quests, and
/// provides the board streams and the Quest history.
class QuestService {
  QuestService(this._db, this._xp, this._clock);

  final QuestlogDatabase _db;
  final XpEngine _xp;
  final Clock _clock;

  /// Stores a new open Quest after all existing Quests in the manual order.
  Future<Quest> create(QuestDraft draft) async {
    final name = validatedName(draft.name, 'name');
    final note = validatedNote(draft.note);
    return _db.runTransaction(() async {
      final missionId = draft.missionId;
      if (missionId != null) {
        await _requireOpenMission(missionId);
      }
      final id = await insertQuestLast(
        _db,
        name: name,
        note: note,
        difficulty: draft.difficulty,
        missionId: missionId,
        createdAt: _clock.now(),
        board: draft.board,
      );
      await _applyDeadline(id, null, name, draft.deadline);
      return (await _load(id)).toModel();
    });
  }

  /// Edits a Quest. An open Quest takes the whole [draft]; a done Quest changes
  /// only its name and note, keeping its Difficulty and Mission.
  Future<Quest> update(int id, QuestDraft draft) async {
    final name = validatedName(draft.name, 'name');
    final note = validatedNote(draft.note);
    return _db.runTransaction(() async {
      final quest = await _load(id);
      final change = QuestsCompanion(name: Value(name), note: Value(note));
      if (quest.completedAt != null) {
        await (_db.update(_db.quests)..where((q) => q.id.equals(id))).write(change);
        await _applyDeadline(id, quest.eventId, name, null, keepDate: true);
      } else {
        final missionId = draft.missionId;
        if (missionId != null) {
          await _requireOpenMission(missionId);
        }
        await (_db.update(_db.quests)..where((q) => q.id.equals(id))).write(
          change.copyWith(
            difficulty: Value(draft.difficulty),
            missionId: Value(missionId),
            board: Value(missionId == null ? (draft.board ?? BoardSection.todo) : draft.board),
          ),
        );
        await _applyDeadline(id, quest.eventId, name, draft.deadline);
      }
      return (await _load(id)).toModel();
    });
  }

  /// Removes a Quest permanently; Total_XP is left unchanged.
  Future<void> delete(int id) {
    return _db.runTransaction(() async {
      final quest = await _load(id);
      await (_db.delete(_db.quests)..where((q) => q.id.equals(id))).go();
      final eventId = quest.eventId;
      if (eventId != null) {
        await (_db.delete(_db.calendarEvents)..where((e) => e.id.equals(eventId))).go();
      }
    });
  }

  /// The Deadline of every Quest that has one, by Quest id: the end date of its
  /// linked calendar event, so a change made to the event in the Calendar shows.
  Stream<Map<int, DateTime>> watchDeadlines() {
    final query = _db.select(_db.quests).join([
      innerJoin(_db.calendarEvents, _db.calendarEvents.id.equalsExp(_db.quests.eventId)),
    ]);
    return query.watch().map(
      (rows) => <int, DateTime>{
        for (final row in rows) row.readTable(_db.quests).id: row.readTable(_db.calendarEvents).endDate,
      },
    );
  }

  /// Keeps the linked calendar event of Quest [questId] in line with [deadline]:
  /// creates it, moves it (keeping its length and times), renames it, or deletes
  /// it when [deadline] is null. With [keepDate] only the name is brought along.
  Future<void> _applyDeadline(
    int questId,
    int? eventId,
    String name,
    DateTime? deadline, {
    bool keepDate = false,
  }) async {
    final CalendarEventRow? event = eventId == null
        ? null
        : await (_db.select(_db.calendarEvents)..where((e) => e.id.equals(eventId))).getSingleOrNull();
    final DateTime now = _clock.now();
    if (event != null) {
      if (!keepDate && deadline == null) {
        await (_db.delete(_db.calendarEvents)..where((e) => e.id.equals(event.id))).go();
        return;
      }
      final DateTime end = keepDate ? event.endDate : DateTime(deadline!.year, deadline.month, deadline.day);
      final int span = event.endDate.difference(event.startDate).inDays;
      await (_db.update(_db.calendarEvents)..where((e) => e.id.equals(event.id))).write(
        CalendarEventsCompanion(
          name: Value(name),
          startDate: Value(DateTime(end.year, end.month, end.day - span)),
          endDate: Value(end),
          updatedAt: Value(now),
        ),
      );
      return;
    }
    if (deadline == null || keepDate) return;
    final DateTime day = DateTime(deadline.year, deadline.month, deadline.day);
    final int newEventId = await _db.into(_db.calendarEvents).insert(
      eventCompanion(
        EventDraft(
          name: name,
          type: EventType.quest,
          startDate: day,
          endDate: day,
          onBoard: false,
        ),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await (_db.update(_db.quests)..where((q) => q.id.equals(questId))).write(
      QuestsCompanion(eventId: Value(newEventId)),
    );
  }

  /// Marks the Quest done, records its XP and adds it to Total_XP.
  ///
  /// Completing a Quest that is already done changes nothing and awards 0 XP.
  Future<CompleteQuestResult> complete(int id) {
    return _db.runTransaction(() async {
      final quest = await _load(id);
      final missionId = quest.missionId;
      if (quest.completedAt != null) {
        final level = levelFor(await _xp.readTotal());
        return CompleteQuestResult(
          awardedXp: 0,
          levelBefore: level,
          levelAfter: level,
          mission: missionId == null ? null : await _progress(missionId),
          missionReadyToComplete: await _readyToComplete(missionId),
        );
      }
      final xp = quest.difficulty.xp;
      await (_db.update(_db.quests)..where((q) => q.id.equals(id))).write(
        QuestsCompanion(completedAt: Value(_clock.now()), awardedXp: Value(xp)),
      );
      final change = await _xp.apply(xp);
      return CompleteQuestResult(
        awardedXp: xp,
        levelBefore: change.levelBefore,
        levelAfter: change.levelAfter,
        mission: missionId == null ? null : await _progress(missionId),
        missionReadyToComplete: await _readyToComplete(missionId),
      );
    });
  }

  /// Marks the Quest open again and takes back the XP recorded at completion.
  /// When its Mission was `completed`, the Mission reopens and its recorded
  /// bonus is taken back in the same transaction.
  Future<ReopenQuestResult> reopen(int id) {
    return _db.runTransaction(() async {
      final quest = await _load(id);
      if (quest.completedAt == null) {
        return ReopenQuestResult(
          revokedXp: 0,
          missionReopened: false,
          levelAfter: levelFor(await _xp.readTotal()),
        );
      }
      final revoked = quest.awardedXp ?? 0;
      await (_db.update(_db.quests)..where((q) => q.id.equals(id))).write(
        const QuestsCompanion(completedAt: Value(null), awardedXp: Value(null)),
      );
      var change = await _xp.apply(-revoked);

      var missionReopened = false;
      var revokedBonus = 0;
      final missionId = quest.missionId;
      if (missionId != null) {
        final mission = await (_db.select(_db.missions)..where((m) => m.id.equals(missionId)))
            .getSingle();
        if (mission.status == MissionStatus.completed) {
          await (_db.update(_db.missions)..where((m) => m.id.equals(missionId))).write(
            const MissionsCompanion(
              status: Value(MissionStatus.open),
              completedAt: Value(null),
              awardedBonus: Value(null),
            ),
          );
          revokedBonus = mission.awardedBonus ?? 0;
          change = await _xp.apply(-revokedBonus);
          missionReopened = true;
        }
      }
      return ReopenQuestResult(
        revokedXp: revoked,
        missionReopened: missionReopened,
        levelAfter: change.levelAfter,
        revokedBonus: revokedBonus,
      );
    });
  }

  /// Puts exactly the Quests in [orderedIds] into that relative order.
  ///
  /// The positions the subset occupies are reused, so every other Quest keeps
  /// its place. An unknown or duplicate id is rejected before anything is written.
  Future<void> reorder(List<int> orderedIds) async {
    if (orderedIds.toSet().length != orderedIds.length) {
      throw const ValidationError('orderedIds', 'contains a duplicate id');
    }
    if (orderedIds.isEmpty) return;
    await _db.runTransaction(() async {
      final rows =
          await (_db.select(_db.quests)..where((q) => q.id.isIn(orderedIds))).get();
      if (rows.length != orderedIds.length) {
        throw const ValidationError('orderedIds', 'contains an unknown id');
      }
      final positions = rows.map((row) => row.sortOrder).toList()..sort();
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.quests)..where((q) => q.id.equals(orderedIds[i])))
            .write(QuestsCompanion(sortOrder: Value(positions[i])));
      }
    });
  }

  /// Moves an open Quest to [section] of the Board and puts the Quests of that
  /// section into [orderedIds] (which includes [id]), in one transaction.
  Future<void> moveOnBoard(int id, BoardSection section, List<int> orderedIds) {
    return _db.runTransaction(() async {
      final quest = await _load(id);
      if (quest.completedAt != null) {
        throw InvalidStateError('quest $id is done and cannot be moved on the board');
      }
      if (!orderedIds.contains(id)) {
        throw const ValidationError('orderedIds', 'does not contain the moved quest');
      }
      await (_db.update(_db.quests)..where((q) => q.id.equals(id)))
          .write(QuestsCompanion(board: Value(section)));
      await reorder(orderedIds);
    });
  }

  /// Open Quests that are on the Board (both sections), in the manual order.
  /// Quests of a Mission are on the Board only when they were put there.
  Stream<List<Quest>> watchOpenBoard() {
    final query = _db.select(_db.quests)
      ..where((q) => q.completedAt.isNull() & q.board.isNotNull())
      ..orderBy([(q) => OrderingTerm.asc(q.sortOrder)]);
    return query.watch().map(_toModels);
  }

  /// Quests on the Board completed within the Board_Day of [today], newest first.
  ///
  /// [today] comes from the caller, so a consumer can refresh the window when the
  /// Board_Day changes.
  Stream<List<Quest>> watchDoneToday(DateTime today) {
    final window = boardDayRange(today, today);
    final query = _db.select(_db.quests)
      ..where(
        (q) =>
            q.board.isNotNull() &
            q.completedAt.isBiggerOrEqualValue(window.start) &
            q.completedAt.isSmallerThanValue(window.end),
      )
      ..orderBy([
        (q) => OrderingTerm.desc(q.completedAt),
        (q) => OrderingTerm.desc(q.id),
      ]);
    return query.watch().map(_toModels);
  }

  /// Done Quests completed from the Board_Day [fromDay] up to and including the
  /// Board_Day [toDay], newest first. Reads only.
  Future<List<HistoryQuest>> history(DateTime fromDay, DateTime toDay) async {
    final window = boardDayRange(fromDay, toDay);
    final query = _historyQuery()
      ..where(
        _db.quests.completedAt.isBiggerOrEqualValue(window.start) &
            _db.quests.completedAt.isSmallerThanValue(window.end),
      )
      ..orderBy([OrderingTerm.desc(_db.quests.completedAt), OrderingTerm.desc(_db.quests.id)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        HistoryQuest(
          id: row.readTable(_db.quests).id,
          name: row.readTable(_db.quests).name,
          difficulty: row.readTable(_db.quests).difficulty,
          awardedXp: row.readTable(_db.quests).awardedXp ?? 0,
          completedAt: row.readTable(_db.quests).completedAt!,
          missionName: row.readTableOrNull(_db.missions)?.name,
        ),
    ];
  }

  JoinedSelectStatement<HasResultSet, dynamic> _historyQuery() {
    return _db.select(_db.quests).join([
      leftOuterJoin(_db.missions, _db.missions.id.equalsExp(_db.quests.missionId)),
    ]);
  }

  List<Quest> _toModels(List<QuestRow> rows) => [for (final row in rows) row.toModel()];

  Future<MissionProgress> _progress(int missionId) async {
    final rows =
        await (_db.select(_db.quests)..where((q) => q.missionId.equals(missionId))).get();
    var done = 0;
    var remaining = 0;
    for (final row in rows) {
      if (row.completedAt != null) {
        done++;
      } else {
        remaining += row.difficulty.xp;
      }
    }
    return MissionProgress(done: done, total: rows.length, remainingXp: remaining);
  }

  Future<bool> _readyToComplete(int? missionId) async {
    if (missionId == null) return false;
    final mission = await (_db.select(_db.missions)..where((m) => m.id.equals(missionId)))
        .getSingleOrNull();
    if (mission == null || mission.status != MissionStatus.open) return false;
    final progress = await _progress(missionId);
    return progress.total > 0 && progress.done == progress.total;
  }

  Future<QuestRow> _load(int id) async {
    final row = await (_db.select(_db.quests)..where((q) => q.id.equals(id))).getSingleOrNull();
    if (row == null) throw NotFoundError('quest', id);
    return row;
  }

  Future<void> _requireOpenMission(int missionId) async {
    final mission = await (_db.select(_db.missions)..where((m) => m.id.equals(missionId)))
        .getSingleOrNull();
    if (mission == null) {
      throw InvalidStateError('mission $missionId does not exist');
    }
    if (mission.status != MissionStatus.open) {
      throw InvalidStateError('mission $missionId is ${mission.status.name}, not open');
    }
  }
}
