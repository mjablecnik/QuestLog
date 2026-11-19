import 'package:drift/drift.dart';

import '../core/board_day.dart';
import '../core/clock.dart';
import '../core/errors.dart';
import '../core/validation.dart';
import '../core/xp_rules.dart';
import '../data/database.dart';
import '../data/mappers.dart';
import '../data/models.dart';
import '../data/quest_writes.dart';
import 'xp_engine.dart';

/// Creates, edits, deletes and completes Missions, adds Quests to them, and
/// provides the Mission streams and Mission history.
class MissionService {
  MissionService(this._db, this._xp, this._clock);

  final QuestlogDatabase _db;
  final XpEngine _xp;
  final Clock _clock;

  /// Stores an `open` Mission and its initial Quests, in the given order after
  /// all existing Quests, in one transaction.
  Future<Mission> create(MissionDraft draft) async {
    final name = validatedName(draft.name, 'name');
    for (final quest in draft.quests) {
      validatedName(quest.name, 'quests.name');
      validatedNote(quest.note, field: 'quests.note');
    }
    return _db.runTransaction(() async {
      final now = _clock.now();
      final id = await _db.into(_db.missions).insert(
            MissionsCompanion.insert(
              name: name,
              bonus: draft.bonus,
              createdAt: now,
              sortOrder: Value(await nextMissionSortOrder(_db)),
            ),
          );
      for (final quest in draft.quests) {
        await insertQuestLast(
          _db,
          name: quest.name,
          note: quest.note,
          difficulty: quest.difficulty,
          missionId: id,
          createdAt: now,
        );
      }
      return (await _load(id)).toModel();
    });
  }

  /// Changes the name and bonus. The bonus recorded for a `completed` Mission
  /// stays as it was.
  Future<Mission> update(int id, String name, MissionBonus bonus) async {
    final validName = validatedName(name, 'name');
    return _db.runTransaction(() async {
      await _load(id);
      await (_db.update(_db.missions)..where((m) => m.id.equals(id))).write(
        MissionsCompanion(name: Value(validName), bonus: Value(bonus)),
      );
      return (await _load(id)).toModel();
    });
  }

  /// Removes the Mission and all its Quests; Total_XP is left unchanged.
  Future<void> delete(int id) {
    return _db.runTransaction(() async {
      await _load(id);
      await (_db.delete(_db.quests)..where((q) => q.missionId.equals(id))).go();
      await (_db.delete(_db.missions)..where((m) => m.id.equals(id))).go();
    });
  }

  /// Adds an open Quest after the existing Quests of an `open` Mission.
  Future<Quest> addQuest(int missionId, QuestDraft draft) async {
    final name = validatedName(draft.name, 'name');
    final note = validatedNote(draft.note);
    return _db.runTransaction(() async {
      final mission = await _load(missionId);
      if (mission.status != MissionStatus.open) {
        throw InvalidStateError('mission $missionId is ${mission.status.name}, not open');
      }
      final id = await insertQuestLast(
        _db,
        name: name,
        note: note,
        difficulty: draft.difficulty,
        missionId: missionId,
        createdAt: _clock.now(),
      );
      final row = await (_db.select(_db.quests)..where((q) => q.id.equals(id))).getSingle();
      return row.toModel();
    });
  }

  /// Completes an `open` Mission whose Quests are all done and awards its bonus.
  ///
  /// Never called automatically: the UI offers it once the last Quest is done.
  Future<CompleteMissionResult> complete(int id) {
    return _db.runTransaction(() async {
      final mission = await _load(id);
      if (mission.status != MissionStatus.open) {
        throw InvalidStateError('mission $id is ${mission.status.name}, not open');
      }
      final quests =
          await (_db.select(_db.quests)..where((q) => q.missionId.equals(id))).get();
      if (quests.isEmpty) {
        throw InvalidStateError('mission $id has no quests');
      }
      if (quests.any((q) => q.completedAt == null)) {
        throw InvalidStateError('mission $id still has open quests');
      }
      final bonus = mission.bonus.xp;
      await (_db.update(_db.missions)..where((m) => m.id.equals(id))).write(
        MissionsCompanion(
          status: const Value(MissionStatus.completed),
          completedAt: Value(_clock.now()),
          awardedBonus: Value(bonus),
        ),
      );
      final change = await _xp.apply(bonus);
      return CompleteMissionResult(
        awardedBonus: bonus,
        levelBefore: change.levelBefore,
        levelAfter: change.levelAfter,
      );
    });
  }

  /// Puts exactly the Missions in [orderedIds] into that relative order; every
  /// other Mission keeps its place. Same contract as `QuestService.reorder`.
  Future<void> reorder(List<int> orderedIds) async {
    if (orderedIds.toSet().length != orderedIds.length) {
      throw const ValidationError('orderedIds', 'contains a duplicate id');
    }
    if (orderedIds.isEmpty) return;
    await _db.runTransaction(() async {
      final rows =
          await (_db.select(_db.missions)..where((m) => m.id.isIn(orderedIds))).get();
      if (rows.length != orderedIds.length) {
        throw const ValidationError('orderedIds', 'contains an unknown id');
      }
      final positions = rows.map((row) => row.sortOrder).toList()..sort();
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.missions)..where((m) => m.id.equals(orderedIds[i])))
            .write(MissionsCompanion(sortOrder: Value(positions[i])));
      }
    });
  }

  /// `open` Missions with their progress in the manual order.
  Stream<List<MissionSummary>> watchOpen() {
    return _watchSummaries(
      _db.missions.status.equalsValue(MissionStatus.open),
      [
        OrderingTerm.asc(_db.missions.sortOrder),
        OrderingTerm.asc(_db.missions.createdAt),
        OrderingTerm.asc(_db.missions.id),
      ],
    );
  }

  /// `completed` Missions finished within the Board_Day of [today], newest first.
  ///
  /// [today] comes from the caller, so a consumer can refresh the window when the
  /// Board_Day changes.
  Stream<List<MissionSummary>> watchCompletedToday(DateTime today) {
    final window = boardDayRange(today, today);
    return _watchSummaries(
      _db.missions.status.equalsValue(MissionStatus.completed) &
          _db.missions.completedAt.isBiggerOrEqualValue(window.start) &
          _db.missions.completedAt.isSmallerThanValue(window.end),
      [OrderingTerm.desc(_db.missions.completedAt), OrderingTerm.desc(_db.missions.id)],
    );
  }

  /// One Mission with all of its Quests, or null when it does not exist or is
  /// `closed`.
  Stream<MissionDetail?> watchDetail(int id) {
    final query = _db.select(_db.missions).join([
      leftOuterJoin(_db.quests, _db.quests.missionId.equalsExp(_db.missions.id)),
    ])
      ..where(_db.missions.id.equals(id) & _db.missions.status.equalsValue(MissionStatus.closed).not())
      ..orderBy([OrderingTerm.asc(_db.quests.sortOrder)]);
    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      return MissionDetail(
        mission: rows.first.readTable(_db.missions).toModel(),
        quests: [
          for (final row in rows)
            if (row.readTableOrNull(_db.quests) case final quest?) quest.toModel(),
        ],
      );
    });
  }

  /// `completed` Missions finished from the Board_Day [fromDay] up to and
  /// including [toDay], newest first. Reads only.
  Future<List<HistoryMission>> history(DateTime fromDay, DateTime toDay) async {
    final window = boardDayRange(fromDay, toDay);
    final rows = await (_db.select(_db.missions)
          ..where(
            (m) =>
                m.status.equalsValue(MissionStatus.completed) &
                m.completedAt.isBiggerOrEqualValue(window.start) &
                m.completedAt.isSmallerThanValue(window.end),
          )
          ..orderBy([
            (m) => OrderingTerm.desc(m.completedAt),
            (m) => OrderingTerm.desc(m.id),
          ]))
        .get();
    return [
      for (final row in rows)
        HistoryMission(
          id: row.id,
          name: row.name,
          awardedBonus: row.awardedBonus ?? 0,
          completedAt: row.completedAt!,
        ),
    ];
  }

  Stream<List<MissionSummary>> _watchSummaries(
    Expression<bool> where,
    List<OrderingTerm> order,
  ) {
    final query = _db.select(_db.missions).join([
      leftOuterJoin(_db.quests, _db.quests.missionId.equalsExp(_db.missions.id)),
    ])
      ..where(where)
      ..orderBy(order);
    return query.watch().map((rows) {
      // The join yields one row per Quest; fold them back into one summary per
      // Mission, keeping the order of first appearance.
      final summaries = <int, MissionSummary>{};
      for (final row in rows) {
        final mission = row.readTable(_db.missions);
        final quest = row.readTableOrNull(_db.quests);
        final previous = summaries[mission.id];
        final done = (previous?.done ?? 0) + (quest?.completedAt != null ? 1 : 0);
        final total = (previous?.total ?? 0) + (quest == null ? 0 : 1);
        final remaining = (previous?.remainingXp ?? 0) +
            (quest != null && quest.completedAt == null ? quest.difficulty.xp : 0);
        summaries[mission.id] = MissionSummary(
          id: mission.id,
          name: mission.name,
          bonus: mission.bonus,
          status: mission.status,
          done: done,
          total: total,
          remainingXp: remaining,
          ruleId: mission.ruleId,
          completedAt: mission.completedAt,
          awardedBonus: mission.awardedBonus,
        );
      }
      return summaries.values.toList();
    });
  }

  Future<MissionRow> _load(int id) async {
    final row = await (_db.select(_db.missions)..where((m) => m.id.equals(id))).getSingleOrNull();
    if (row == null) throw NotFoundError('mission', id);
    return row;
  }
}
