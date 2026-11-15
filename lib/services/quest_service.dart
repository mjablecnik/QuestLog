import 'package:drift/drift.dart';

import '../core/clock.dart';
import '../core/errors.dart';
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
  // ignore: unused_field
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
