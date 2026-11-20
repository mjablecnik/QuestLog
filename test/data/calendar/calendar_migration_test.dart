import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/calendar/calendar_mappers.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/data/database.dart';

import '../../helpers/generators.dart';
import '../../helpers/test_database.dart';

/// A schema 2 file is a schema 5 file without the calendar and notes tables, with
/// `user_version = 2`. The [NativeDatabase.setup] callback runs right before
/// Drift reads that version, so opening the file with it simulates an old install.
QuestlogDatabase openAsSchema2(File file) => QuestlogDatabase.forTesting(
  NativeDatabase(
    file,
    setup: (dynamic raw) {
      raw.execute('DROP TABLE calendar_addresses');
      raw.execute('DROP TABLE note_nodes');
      raw.execute('DROP TABLE calendar_completions');
      raw.execute('DROP TABLE calendar_skipped_dates');
      raw.execute('DROP TABLE calendar_events');
      raw.execute('PRAGMA user_version = 2');
    },
  ),
);

Future<void> main() async {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('calendar_migration_');
    file = File('${dir.path}/questlog.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<
    ({
      List<QuestRow> quests,
      List<MissionRow> missions,
      List<RecurringRuleRow> rules,
      AppStateRow state,
    })
  >
  prepare(int quests, int missions) async {
    final QuestlogDatabase db = QuestlogDatabase.forTesting(NativeDatabase(file));
    final DateTime now = DateTime(2026, 11, 15, 12);
    for (int i = 0; i < missions; i++) {
      await db.into(db.missions).insert(
        MissionsCompanion.insert(name: 'Mission $i', bonus: MissionBonus.small, createdAt: now),
      );
    }
    for (int i = 0; i < quests; i++) {
      await db.into(db.quests).insert(
        QuestsCompanion.insert(
          name: 'Quest $i',
          difficulty: Difficulty.easy,
          sortOrder: i + 1,
          createdAt: now,
          awardedXp: Value(i.isEven ? 10 : null),
        ),
      );
    }
    await db.update(db.appState).write(const AppStateCompanion(totalXp: Value(420), heroName: Value('Martin')));
    final result = (
      quests: await db.select(db.quests).get(),
      missions: await db.select(db.missions).get(),
      rules: await db.select(db.recurringRules).get(),
      state: await db.select(db.appState).getSingle(),
    );
    await db.close();
    return result;
  }

  Future<void> expectMigrated(
    ({List<QuestRow> quests, List<MissionRow> missions, List<RecurringRuleRow> rules, AppStateRow state}) before,
  ) async {
    final QuestlogDatabase db = openAsSchema2(file);
    expect(await db.select(db.calendarEvents).get(), hasLength(35));
    expect(await db.select(db.quests).get(), before.quests);
    expect(await db.select(db.missions).get(), before.missions);
    expect(await db.select(db.recurringRules).get(), before.rules);
    expect(await db.select(db.appState).getSingle(), before.state);
    await db.close();

    final QuestlogDatabase again = QuestlogDatabase.forTesting(NativeDatabase(file));
    expect(await again.select(again.calendarEvents).get(), hasLength(35));
    await again.close();
  }

  test('migrating schema 2 to 3 keeps every row and adds the 35 events once', () async {
    await expectMigrated(await prepare(4, 2));
  });

  test('migrating an empty schema 2 database works', () async {
    await expectMigrated(await prepare(0, 0));
  });

  test('a deleted holiday stays deleted on later starts', () async {
    await prepare(1, 0);
    QuestlogDatabase db = openAsSchema2(file);
    final CalendarEventRow row = (await db.select(db.calendarEvents).get()).first;
    await (db.delete(db.calendarEvents)..where((t) => t.id.equals(row.id))).go();
    await db.close();
    db = QuestlogDatabase.forTesting(NativeDatabase(file));
    expect(await db.select(db.calendarEvents).get(), hasLength(34));
    await db.close();
  });

  test('a fresh database and a migrated one hold the same events', () async {
    final QuestlogDatabase fresh = createTestDatabase();
    final List<String> freshNames = (await fresh.select(fresh.calendarEvents).get()).map((r) => r.name).toList()..sort();
    await fresh.close();
    await prepare(0, 0);
    final QuestlogDatabase migrated = openAsSchema2(file);
    final List<String> migratedNames = (await migrated.select(migrated.calendarEvents).get()).map((r) => r.name).toList()..sort();
    await migrated.close();
    expect(migratedNames, freshNames);
  });

  // Feature: questlog-calendar, Property 13: Migration keeps data and seeds once
  Glados2(any.intInRange(0, 6), any.intInRange(0, 4), ExploreConfig(numRuns: 8)).test(
    'Property 13: any schema 2 content survives the migration and gets 35 events once',
    (int quests, int missions) async {
      if (file.existsSync()) file.deleteSync();
      await expectMigrated(await prepare(quests, missions));
    },
  );

  group('wall-clock storage', () {
    late QuestlogDatabase db;
    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    Future<CalendarEventRow> insertEvent(DateTime date, int startMinute, int endMinute) async {
      final int id = await db.into(db.calendarEvents).insert(
        eventCompanion(
          EventDraft(
            name: 'Probe',
            type: EventType.meeting,
            startDate: date,
            endDate: date,
            startMinute: startMinute,
            endMinute: endMinute,
            onBoard: false,
          ),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      return (db.select(db.calendarEvents)..where((t) => t.id.equals(id))).getSingle();
    }

    test('a time inside a daylight-saving gap is stored and read back unchanged', () async {
      // 29 March 2026, 02:30: does not exist in Europe/Prague, still a valid wall-clock time here.
      final CalendarEventRow row = await insertEvent(DateTime(2026, 3, 29), 150, 210);
      final List<QueryRow> raw = await db
          .customSelect('SELECT start_date, end_date, start_minute, end_minute FROM calendar_events WHERE id = ?', variables: [Variable.withInt(row.id)])
          .get();
      expect(raw.single.read<String>('start_date'), '2026-03-29');
      expect(raw.single.read<int>('start_minute'), 150);
      expect(raw.single.read<int>('end_minute'), 210);
      final CalendarEvent event = row.toModel();
      expect((event.startDate.year, event.startDate.month, event.startDate.day), (2026, 3, 29));
      expect((event.startMinute, event.endMinute), (150, 210));
    });

    // Feature: questlog-calendar, Property 14: Wall-clock times are zone-independent
    Glados2(anyCalendarDate, any.intInRange(0, 1380), ExploreConfig(numRuns: 40)).test(
      'Property 14: the stored text and minutes read back as the same wall-clock time',
      (DateTime date, int minute) async {
        final CalendarEventRow row = await insertEvent(date, minute, minute + 30);
        final List<QueryRow> raw = await db
            .customSelect('SELECT start_date FROM calendar_events WHERE id = ?', variables: [Variable.withInt(row.id)])
            .get();
        String two(int n) => n.toString().padLeft(2, '0');
        expect(raw.single.read<String>('start_date'), '${date.year}-${two(date.month)}-${two(date.day)}');
        final CalendarEvent event = row.toModel();
        expect(event.startDate, DateTime(date.year, date.month, date.day));
        expect((event.startMinute, event.endMinute), (minute, minute + 30));
      },
    );
  });
}
