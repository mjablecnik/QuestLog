import 'package:drift/drift.dart';

import '../core/validation.dart';
import '../core/xp_rules.dart';
import 'database.dart';
import 'models.dart';

/// The `sort_order` that places a new Quest after every existing Quest.
Future<int> nextQuestSortOrder(QuestlogDatabase db) async {
  final maxOrder = db.quests.sortOrder.max();
  final row = await (db.selectOnly(db.quests)..addColumns([maxOrder])).getSingle();
  return (row.read(maxOrder) ?? 0) + 1;
}

/// The `sort_order` that places a new Mission after every existing Mission.
Future<int> nextMissionSortOrder(QuestlogDatabase db) async {
  final maxOrder = db.missions.sortOrder.max();
  final row = await (db.selectOnly(db.missions)..addColumns([maxOrder])).getSingle();
  return (row.read(maxOrder) ?? 0) + 1;
}

/// Inserts an open Quest after all existing Quests and returns its id.
///
/// Call it inside a transaction. [name] and [note] are validated here, so a
/// caller that builds several Quests can rely on the whole batch failing.
Future<int> insertQuestLast(
  QuestlogDatabase db, {
  required String name,
  required String? note,
  required Difficulty difficulty,
  required int? missionId,
  required DateTime createdAt,
  BoardSection? board,
}) async {
  return db.into(db.quests).insert(
        QuestsCompanion.insert(
          name: validatedName(name, 'name'),
          note: Value(validatedNote(note)),
          difficulty: difficulty,
          missionId: Value(missionId),
          board: Value(missionId == null ? (board ?? BoardSection.todo) : board),
          sortOrder: await nextQuestSortOrder(db),
          createdAt: createdAt,
        ),
      );
}
