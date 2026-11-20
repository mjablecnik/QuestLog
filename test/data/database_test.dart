import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:glados/glados.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/data/preferences.dart';

import '../helpers/test_database.dart';

void main() {
  late QuestlogDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  final now = DateTime(2026, 11, 15, 12);

  Future<int> insertMission({int? ruleId}) => db.into(db.missions).insert(
        MissionsCompanion.insert(
          name: 'Mission',
          bonus: MissionBonus.small,
          createdAt: now,
          ruleId: Value(ruleId),
        ),
      );

  Future<int> insertQuest({int? missionId, String name = 'Quest', int sortOrder = 1}) =>
      db.into(db.quests).insert(
            QuestsCompanion.insert(
              name: name,
              difficulty: Difficulty.easy,
              sortOrder: sortOrder,
              createdAt: now,
              missionId: Value(missionId),
            ),
          );

  Future<int> insertRule() => db.into(db.recurringRules).insert(
        RecurringRulesCompanion.insert(
          name: 'Cleaning',
          cadence: Cadence.monthly,
          anchorDate: DateTime(2026, 12, 1),
          bonus: MissionBonus.medium,
          createdAt: now,
        ),
      );

  Future<int> count(TableInfo table) async =>
      (await db.select(table).get()).length;

  group('creation', () {
    test('a fresh database has Total_XP 0 and the default settings', () async {
      final rows = await db.select(db.appState).get();
      expect(rows, hasLength(1));
      final state = rows.single;
      expect(state.id, 1);
      expect(state.totalXp, 0);
      expect(state.heroName, '');
      expect(state.language, AppLanguage.system);
      expect(state.theme, AppTheme.system);
      expect(state.displayFont, 'figtree', reason: 'the column is unused but keeps its default');
    });

    test('foreign keys are enabled', () async {
      final result = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(result.data.values.single, 1);
    });

    test('a new Mission is open by default', () async {
      final id = await insertMission();
      final row = await (db.select(db.missions)..where((m) => m.id.equals(id))).getSingle();
      expect(row.status, MissionStatus.open);
    });
  });

  group('constraints', () {
    test('blank and over-long names are rejected by CHECK constraints', () async {
      await expectLater(insertQuest(name: '   '), throwsA(anything));
      await expectLater(insertQuest(name: 'x' * 81), throwsA(anything));
      await insertQuest(name: 'x' * 80);
    });

    test('a note over 500 characters is rejected', () async {
      await expectLater(
        db.into(db.quests).insert(
              QuestsCompanion.insert(
                name: 'Quest',
                note: Value('n' * 501),
                difficulty: Difficulty.easy,
                sortOrder: 1,
                createdAt: now,
              ),
            ),
        throwsA(anything),
      );
    });

    test('Total_XP cannot go below zero and the state row is a singleton', () async {
      await expectLater(
        db.customStatement('UPDATE app_state SET total_xp = -1'),
        throwsA(anything),
      );
      await expectLater(
        db.customStatement('INSERT INTO app_state (id) VALUES (2)'),
        throwsA(anything),
      );
    });

    test('calendar dates round-trip without a time zone shift', () async {
      final id = await insertRule();
      final row = await (db.select(db.recurringRules)..where((r) => r.id.equals(id))).getSingle();
      expect(row.anchorDate, DateTime(2026, 12, 1));
      expect(row.lastPostedOn, isNull);
      final raw = await db.customSelect('SELECT anchor_date FROM recurring_rules').getSingle();
      expect(raw.data['anchor_date'], '2026-12-01');
    });
  });

  group('transactions', () {
    test('a transaction that throws leaves all tables unchanged', () async {
      final missionId = await insertMission();
      await insertQuest(missionId: missionId);

      await expectLater(
        db.transaction(() async {
          await insertMission();
          await insertQuest();
          await insertRule();
          await db.customStatement('UPDATE app_state SET total_xp = 500');
          throw StateError('boom');
        }),
        throwsStateError,
      );

      expect(await count(db.missions), 1);
      expect(await count(db.quests), 1);
      expect(await count(db.recurringRules), 0);
      expect(await count(db.ruleQuests), 0);
      final state = await db.select(db.appState).getSingle();
      expect(state.totalXp, 0);
    });
  });

  group('foreign keys', () {
    test('deleting a Mission cascades to its Quests', () async {
      final missionId = await insertMission();
      final otherMissionId = await insertMission();
      await insertQuest(missionId: missionId);
      await insertQuest(missionId: missionId, sortOrder: 2);
      await insertQuest(missionId: otherMissionId, sortOrder: 3);
      await insertQuest(sortOrder: 4);

      await (db.delete(db.missions)..where((m) => m.id.equals(missionId))).go();

      final remaining = await db.select(db.quests).get();
      expect(remaining.map((q) => q.missionId), [otherMissionId, null]);
    });

    test('deleting a rule nulls missions.rule_id and cascades to rule_quests', () async {
      final ruleId = await insertRule();
      await db.into(db.ruleQuests).insert(
            RuleQuestsCompanion.insert(
              ruleId: ruleId,
              name: 'Vacuum',
              difficulty: Difficulty.normal,
              sortOrder: 0,
            ),
          );
      final missionId = await insertMission(ruleId: ruleId);

      await (db.delete(db.recurringRules)..where((r) => r.id.equals(ruleId))).go();

      expect(await count(db.ruleQuests), 0);
      final mission = await (db.select(db.missions)..where((m) => m.id.equals(missionId))).getSingle();
      expect(mission.ruleId, isNull);
    });

    test('a Quest cannot reference a missing Mission', () async {
      await expectLater(insertQuest(missionId: 999), throwsA(anything));
    });
  });

  group('runTransaction', () {
    test('maps a SQLite constraint failure to StorageError', () async {
      await expectLater(
        db.runTransaction(() => db.into(db.quests).insert(
              QuestsCompanion.insert(
                name: 'Orphan',
                difficulty: Difficulty.easy,
                missionId: const Value(999),
                sortOrder: 0,
                createdAt: now,
              ),
            )),
        throwsA(isA<StorageError>()),
      );
    });

    test('rethrows a DomainError unchanged and rolls the transaction back', () async {
      await expectLater(
        db.runTransaction(() async {
          await insertMission();
          throw const InvalidStateError('boom');
        }),
        throwsA(isA<InvalidStateError>()),
      );
      expect(await count(db.missions), 0);
    });

    test('maps a failure reported by the database isolate to StorageError', () async {
      final Directory dir = await Directory.systemTemp.createTemp('questlog_ro');
      final File file = File('${dir.path}/questlog.sqlite');
      final QuestlogDatabase seeded = QuestlogDatabase.forTesting(NativeDatabase(file));
      await seeded.customSelect('SELECT 1').get();
      await seeded.close();
      await Process.run('chmod', <String>['444', file.path]);
      final QuestlogDatabase readOnly = QuestlogDatabase.forTesting(
        NativeDatabase.createInBackground(file),
      );
      try {
        await expectLater(
          readOnly.runTransaction(() => readOnly.into(readOnly.quests).insert(
                QuestsCompanion.insert(
                  name: 'Nope',
                  difficulty: Difficulty.easy,
                  sortOrder: 0,
                  createdAt: now,
                ),
              )),
          throwsA(isA<StorageError>()),
        );
      } finally {
        await readOnly.close();
        await dir.delete(recursive: true);
      }
    });
  });
}
