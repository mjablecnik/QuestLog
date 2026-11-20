import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../core/xp_rules.dart';
import '../data/database.dart';
import '../data/models.dart';
import 'mission_service.dart';
import 'quest_service.dart';
import 'recurrence_service.dart';
import 'settings_service.dart';
import 'xp_engine.dart';

/// The app database. Tests override it with an in-memory database.
final databaseProvider = Provider<QuestlogDatabase>((ref) {
  final db = QuestlogDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The source of the current time. Tests override it with a fixed clock.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

final xpEngineProvider = Provider<XpEngine>(
  (ref) => XpEngine(ref.watch(databaseProvider)),
);

final questServiceProvider = Provider<QuestService>(
  (ref) => QuestService(
    ref.watch(databaseProvider),
    ref.watch(xpEngineProvider),
    ref.watch(clockProvider),
  ),
);

final missionServiceProvider = Provider<MissionService>(
  (ref) => MissionService(
    ref.watch(databaseProvider),
    ref.watch(xpEngineProvider),
    ref.watch(clockProvider),
  ),
);

final recurrenceServiceProvider = Provider<RecurrenceService>(
  (ref) =>
      RecurrenceService(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(ref.watch(databaseProvider)),
);

// Streams. Each one re-emits whenever the data behind it changes.

final totalXpProvider = StreamProvider<int>(
  (ref) => ref.watch(xpEngineProvider).watchTotal(),
);

final levelProgressProvider = StreamProvider<LevelProgress>(
  (ref) => ref.watch(xpEngineProvider).watchProgress(),
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsServiceProvider).watch(),
);

/// The Deadline of each Quest that has one, by Quest id.
final questDeadlinesProvider = StreamProvider<Map<int, DateTime>>(
  (ref) => ref.watch(questServiceProvider).watchDeadlines(),
);

final openBoardProvider = StreamProvider<List<Quest>>(
  (ref) => ref.watch(questServiceProvider).watchOpenBoard(),
);

/// Quests completed on the Board_Day of the given date.
final doneTodayProvider = StreamProvider.family<List<Quest>, DateTime>(
  (ref, today) => ref.watch(questServiceProvider).watchDoneToday(today),
);

final openMissionsProvider = StreamProvider<List<MissionSummary>>(
  (ref) => ref.watch(missionServiceProvider).watchOpen(),
);

/// Missions completed on the Board_Day of the given date.
final completedMissionsTodayProvider =
    StreamProvider.family<List<MissionSummary>, DateTime>(
      (ref, today) =>
          ref.watch(missionServiceProvider).watchCompletedToday(today),
    );

final missionDetailProvider = StreamProvider.family<MissionDetail?, int>(
  (ref, id) => ref.watch(missionServiceProvider).watchDetail(id),
);

final rulesProvider = StreamProvider<List<RuleSummary>>(
  (ref) => ref.watch(recurrenceServiceProvider).watchRules(),
);
