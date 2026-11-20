import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/notes/notes_mappers.dart';

import '../../helpers/test_database.dart';

/// A schema 3 file is a schema 5 file without `note_nodes` and `calendar_addresses`, with `user_version = 3`.
QuestlogDatabase openAsSchema3(File file) => QuestlogDatabase.forTesting(
  NativeDatabase(
    file,
    setup: (dynamic raw) {
      raw.execute('DROP TABLE calendar_addresses');
      raw.execute('DROP TABLE note_nodes');
      raw.execute('PRAGMA user_version = 3');
    },
  ),
);

final DateTime _now = DateTime(2026, 11, 19, 12);

Future<int> insertNode(
  QuestlogDatabase db, {
  int? parent,
  bool folder = false,
  String name = 'n',
  String body = '',
}) => db.into(db.noteNodes).insert(
  NoteNodesCompanion.insert(
    parentId: Value<int?>(parent),
    isFolder: folder,
    name: name,
    body: Value<String>(body),
    createdAt: _now,
    updatedAt: _now,
  ),
);

Future<void> main() async {
  group('schema 4', () {
    late QuestlogDatabase db;
    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    test('a fresh database is at version 6 with an empty notes table', () async {
      expect(db.schemaVersion, 6);
      expect(await db.select(db.noteNodes).get(), isEmpty);
    });

    test('a node round-trips through the mapper, a folder body is always empty', () async {
      final int folder = await insertNode(db, folder: true, name: 'ABAP', body: 'ignored');
      final int note = await insertNode(db, parent: folder, name: 'Syntaxe', body: '# Hello');
      final List<NoteNodeRow> rows = await db.select(db.noteNodes).get();
      final NoteNode f = rows.firstWhere((r) => r.id == folder).toNode();
      final NoteNode n = rows.firstWhere((r) => r.id == note).toNode();
      expect(f.isFolder, isTrue);
      expect(f.body, '');
      expect(n.parentId, folder);
      expect(n.body, '# Hello');
      expect(n.deletedAt, isNull);
      expect(n.autoName, isFalse);
      expect(noteNodeToInsert(n).name.value, 'Syntaxe');
    });

    test('deleting a folder row deletes everything inside it, several levels deep', () async {
      final int a = await insertNode(db, folder: true);
      final int b = await insertNode(db, parent: a, folder: true);
      final int c = await insertNode(db, parent: b);
      final int other = await insertNode(db);
      await (db.delete(db.noteNodes)..where((t) => t.id.equals(a))).go();
      final List<int> left = (await db.select(db.noteNodes).get()).map((r) => r.id).toList();
      expect(left, <int>[other]);
      expect(left, isNot(contains(c)));
    });

    test('a name of 0 or 81 characters and a body over 100 000 characters are rejected', () async {
      expect(insertNode(db, name: '   '), throwsA(anything));
      expect(insertNode(db, name: 'x' * 81), throwsA(anything));
      expect(insertNode(db, body: 'x' * 100001), throwsA(anything));
      expect(await insertNode(db, name: 'x' * 80, body: 'x' * 100000), isPositive);
    });

    test('a parent that does not exist is rejected', () async {
      expect(insertNode(db, parent: 999), throwsA(anything));
    });
  });

  group('migration 3 to 4', () {
    late Directory dir;
    late File file;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('notes_migration_');
      file = File('${dir.path}/questlog.sqlite');
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('adds the table and changes no existing data', () async {
      QuestlogDatabase db = QuestlogDatabase.forTesting(NativeDatabase(file));
      await db.into(db.missions).insert(
        MissionsCompanion.insert(name: 'M', bonus: MissionBonus.small, createdAt: _now),
      );
      await db.into(db.quests).insert(
        QuestsCompanion.insert(name: 'Q', difficulty: Difficulty.easy, sortOrder: 1, createdAt: _now),
      );
      await db.update(db.appState).write(const AppStateCompanion(totalXp: Value(420)));
      final List<QuestRow> quests = await db.select(db.quests).get();
      final List<MissionRow> missions = await db.select(db.missions).get();
      final List<CalendarEventRow> events = await db.select(db.calendarEvents).get();
      final AppStateRow state = await db.select(db.appState).getSingle();
      await db.close();

      db = openAsSchema3(file);
      expect(await db.select(db.noteNodes).get(), isEmpty);
      expect(await db.select(db.quests).get(), quests);
      expect(await db.select(db.missions).get(), missions);
      expect(await db.select(db.calendarEvents).get(), events);
      expect(await db.select(db.appState).getSingle(), state);
      await insertNode(db, name: 'after migration');
      await db.close();

      db = QuestlogDatabase.forTesting(NativeDatabase(file));
      expect(await db.select(db.noteNodes).get(), hasLength(1));
      expect(db.schemaVersion, 6);
      await db.close();
    });
  });

  test('the schema 4 dump contains the notes table', () {
    final String dump = File('drift_schemas/drift_schema_v4.json').readAsStringSync();
    expect(dump, contains('note_nodes'));
    expect(dump, contains('idx_note_nodes_parent'));
  });
}
