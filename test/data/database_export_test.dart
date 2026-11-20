import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/database_export.dart';

import '../helpers/test_database.dart';

void main() {
  late QuestlogDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  final exportedAt = DateTime(2026, 11, 20, 9, 30);

  Future<Map<String, Object?>> export() => exportDatabase(
        db,
        appName: 'questlog',
        appVersion: '1.4.0',
        exportedAt: exportedAt,
      );

  test('writes the header and one entry per table', () async {
    final data = await export();

    expect(data['format'], exportFormat);
    expect(data['formatVersion'], exportFormatVersion);
    expect(data['app'], 'questlog');
    expect(data['appVersion'], '1.4.0');
    expect(data['schemaVersion'], db.schemaVersion);
    expect(data['exportedAt'], exportedAt.toIso8601String());
    final tables = data['tables']! as Map<String, Object?>;
    expect(
      tables.keys.toSet(),
      db.allTables.map((t) => t.actualTableName).toSet(),
    );
  });

  test('copies rows as stored and counts them', () async {
    final createdAt = DateTime(2026, 11, 15, 12);
    final missionId = await db.into(db.missions).insert(
          MissionsCompanion.insert(
            name: 'Learn ABAP',
            bonus: MissionBonus.small,
            createdAt: createdAt,
          ),
        );
    await db.into(db.quests).insert(
          QuestsCompanion.insert(
            name: 'Read chapter 1',
            difficulty: Difficulty.easy,
            sortOrder: 1,
            createdAt: createdAt,
            missionId: Value(missionId),
          ),
        );

    final data = await export();
    final tables = data['tables']! as Map<String, Object?>;
    final quests = (tables['quests']! as List).cast<Map<String, Object?>>();

    expect(quests, hasLength(1));
    expect(quests.single['name'], 'Read chapter 1');
    expect(quests.single['mission_id'], missionId);
    expect((data['rowCounts']! as Map)['quests'], 1);
    expect((data['rowCounts']! as Map)['missions'], 1);
    // The singleton settings row is created with the database.
    expect((data['rowCounts']! as Map)['app_state'], 1);
  });

  test('the JSON text decodes back to the same data', () async {
    final text = await exportDatabaseAsJson(
      db,
      appName: 'questlog',
      appVersion: '1.4.0',
      exportedAt: exportedAt,
    );

    expect(jsonDecode(text), jsonDecode(jsonEncode(await export())));
  });
}
