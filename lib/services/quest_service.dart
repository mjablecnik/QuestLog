import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/errors.dart';
import '../core/xp_rules.dart';
import '../core/validation.dart';
import '../data/database.dart';
import '../data/mappers.dart';
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
      final id = await _db.into(_db.quests).insert(
            QuestsCompanion.insert(
              name: name,
              note: Value(note),
              difficulty: draft.difficulty,
              missionId: Value(missionId),
              sortOrder: await _nextSortOrder(),
              createdAt: _clock.now(),
            ),
          );
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
      } else {
        final missionId = draft.missionId;
        if (missionId != null) {
          await _requireOpenMission(missionId);
        }
        await (_db.update(_db.quests)..where((q) => q.id.equals(id))).write(
          change.copyWith(
            difficulty: Value(draft.difficulty),
            missionId: Value(missionId),
          ),
        );
      }
      return (await _load(id)).toModel();
    });
  }

  /// Removes a Quest permanently; Total_XP is left unchanged.
  Future<void> delete(int id) {
    return _db.runTransaction(() async {
      await _load(id);
      await (_db.delete(_db.quests)..where((q) => q.id.equals(id))).go();
    });
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
          change = await _xp.apply(-(mission.awardedBonus ?? 0));
          missionReopened = true;
        }
      }
      return ReopenQuestResult(
        revokedXp: revoked,
        missionReopened: missionReopened,
        levelAfter: change.levelAfter,
      );
    });
  }

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

  Future<int> _nextSortOrder() async {
    final maxOrder = _db.quests.sortOrder.max();
    final row = await (_db.selectOnly(_db.quests)..addColumns([maxOrder])).getSingle();
    return (row.read(maxOrder) ?? 0) + 1;
  }
}
