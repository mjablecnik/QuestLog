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
        ),
      );
}
