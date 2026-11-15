import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/cadence.dart';
import '../core/xp_rules.dart';
import 'models.dart';
import 'preferences.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Missions, Quests, RecurringRules, RuleQuests, AppState])
class QuestlogDatabase extends _$QuestlogDatabase {
  /// Opens the on-device database file, lazily on first use.
  QuestlogDatabase() : super(_openFileDatabase());

  /// Uses the given [executor], for example `NativeDatabase.memory()` in tests.
  QuestlogDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // The singleton row: Total_XP 0 and the default settings.
          await into(appState).insert(AppStateCompanion.insert());
        },
        // Upgrades from version 1 are added here with stepByStep(...) together
        // with a new dump in drift_schemas/ whenever the schema changes.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

QueryExecutor _openFileDatabase() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'questlog.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
