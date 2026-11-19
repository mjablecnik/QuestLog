import 'package:drift/drift.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';

/// Inserts a Mission row directly, bypassing the services, for tests that need a
/// Mission in a particular state.
Future<int> seedMission(
  QuestlogDatabase db, {
  String name = 'Mission',
  MissionBonus bonus = MissionBonus.small,
  MissionStatus status = MissionStatus.open,
  DateTime? createdAt,
  DateTime? completedAt,
  int? awardedBonus,
  int? ruleId,
  int sortOrder = 0,
}) {
  return db.into(db.missions).insert(
        MissionsCompanion.insert(
          name: name,
          bonus: bonus,
          status: Value(status),
          createdAt: createdAt ?? DateTime(2026, 11, 1, 12),
          completedAt: Value(completedAt),
          awardedBonus: Value(awardedBonus),
          ruleId: Value(ruleId),
          sortOrder: Value(sortOrder),
        ),
      );
}

/// Inserts a Quest row directly, optionally already done.
Future<int> seedQuest(
  QuestlogDatabase db, {
  String name = 'Quest',
  Difficulty difficulty = Difficulty.normal,
  int? missionId,
  int sortOrder = 1,
  DateTime? completedAt,
  int? awardedXp,
  BoardSection? board,
}) {
  return db.into(db.quests).insert(
        QuestsCompanion.insert(
          name: name,
          difficulty: difficulty,
          missionId: Value(missionId),
          // A Quest without a Mission is always on the Board, in Todo by default.
          board: Value(missionId == null ? (board ?? BoardSection.todo) : board),
          sortOrder: sortOrder,
          createdAt: DateTime(2026, 11, 1, 12),
          completedAt: Value(completedAt),
          awardedXp: Value(awardedXp ?? (completedAt == null ? null : difficulty.xp)),
        ),
      );
}
