import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/data/calendar/calendar_mappers.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/data/database.dart';

import '../../helpers/test_database.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

void main() {
  late QuestlogDatabase db;
  late List<CalendarEvent> events;

  setUp(() async {
    db = createTestDatabase();
    events = (await db.select(db.calendarEvents).get()).map((r) => r.toModel()).toList();
  });
  tearDown(() => db.close());

  CalendarEvent named(String name) => events.singleWhere((CalendarEvent e) => e.name == name);

  List<DateTime> in2026(CalendarEvent e) => occurrenceStarts(
    firstStart: e.startDate,
    spanDays: e.spanDays,
    rule: e.repeat,
    from: d(2026, 1, 1),
    to: d(2026, 12, 31),
  ).toList();

  test('a fresh database holds 13 + 16 + 6 = 35 built-in events', () {
    expect(events, hasLength(35));
    expect(events.where((e) => e.type == EventType.publicHoliday), hasLength(13));
    expect(events.where((e) => e.type == EventType.notableDay), hasLength(16));
    expect(events.where((e) => e.type == EventType.nameDay), hasLength(6));
  });

  test('every built-in event is all-day, single-day, built-in and has no repeat end', () {
    for (final CalendarEvent e in events) {
      expect(e.allDay, isTrue, reason: e.name);
      expect(e.spanDays, 0, reason: e.name);
      expect(e.isBuiltIn, isTrue, reason: e.name);
      expect(e.repeat.end, isNull, reason: e.name);
      expect(e.repeat is NoRepeat, isFalse, reason: e.name);
    }
  });

  test('On_Board is off for holidays and notable days and on for name days', () {
    for (final CalendarEvent e in events) {
      expect(e.onBoard, e.type == EventType.nameDay, reason: e.name);
    }
  });

  test('the thirteen public holidays have the right names and dates in 2026', () {
    final Map<String, DateTime> expected = <String, DateTime>{
      'Nový rok': d(2026, 1, 1),
      'Velký pátek': d(2026, 4, 3),
      'Velikonoční pondělí': d(2026, 4, 6),
      'Svátek práce': d(2026, 5, 1),
      'Den vítězství': d(2026, 5, 8),
      'Den slovanských věrozvěstů Cyrila a Metoděje': d(2026, 7, 5),
      'Den upálení mistra Jana Husa': d(2026, 7, 6),
      'Den české státnosti': d(2026, 9, 28),
      'Den vzniku samostatného československého státu': d(2026, 10, 28),
      'Den boje za svobodu a demokracii': d(2026, 11, 17),
      'Štědrý den': d(2026, 12, 24),
      '1. svátek vánoční': d(2026, 12, 25),
      '2. svátek vánoční': d(2026, 12, 26),
    };
    expected.forEach((String name, DateTime date) {
      expect(in2026(named(name)), <DateTime>[date], reason: name);
    });
  });

  test('the notable and folk days have the right dates in 2026', () {
    final Map<String, DateTime> expected = <String, DateTime>{
      'Valentýn': d(2026, 2, 14),
      'Mezinárodní den žen': d(2026, 3, 8),
      'Apríl': d(2026, 4, 1),
      'Den Země': d(2026, 4, 22),
      'Pálení čarodějnic': d(2026, 4, 30),
      'Den dětí': d(2026, 6, 1),
      'Halloween': d(2026, 10, 31),
      'Dušičky': d(2026, 11, 2),
      'Svatý Martin': d(2026, 11, 11),
      'Mikuláš': d(2026, 12, 5),
      'Silvestr': d(2026, 12, 31),
      'Zelený čtvrtek': d(2026, 4, 2),
      'Bílá sobota': d(2026, 4, 4),
      'Velikonoční neděle': d(2026, 4, 5),
      'Den matek': d(2026, 5, 10),
      'Den otců': d(2026, 6, 21),
    };
    expected.forEach((String name, DateTime date) {
      expect(in2026(named(name)), <DateTime>[date], reason: name);
      expect(named(name).type, EventType.notableDay);
    });
  });

  test('the six name days', () {
    final Map<String, DateTime> expected = <String, DateTime>{
      'Veronika': d(2026, 2, 7),
      'Iveta': d(2026, 6, 7),
      'Jindřich': d(2026, 7, 15),
      'Luboš': d(2026, 7, 16),
      'Michala': d(2026, 10, 19),
      'Jitka': d(2026, 12, 5),
    };
    expected.forEach((String name, DateTime date) {
      expect(in2026(named(name)), <DateTime>[date], reason: name);
    });
  });

  test('series start on 1 January 2000, Velký pátek on 1 January 2016', () {
    for (final CalendarEvent e in events) {
      if (e.name == 'Velký pátek') continue;
      expect(e.startDate.year, 2000, reason: e.name);
    }
    expect(named('Velký pátek').startDate, d(2016, 1, 1));
    expect(
      occurrenceStarts(
        firstStart: named('Velký pátek').startDate,
        spanDays: 0,
        rule: named('Velký pátek').repeat,
        from: d(2015, 1, 1),
        to: d(2015, 12, 31),
      ),
      isEmpty,
    );
  });

  test('the series carry on every year', () {
    final CalendarEvent christmas = named('Štědrý den');
    for (final int year in <int>[2000, 2031, 2100]) {
      expect(
        occurrenceStarts(
          firstStart: christmas.startDate,
          spanDays: 0,
          rule: christmas.repeat,
          from: d(year, 1, 1),
          to: d(year, 12, 31),
        ),
        <DateTime>[d(year, 12, 24)],
      );
    }
  });

  test('a seeded event can be edited and deleted like any other', () async {
    final CalendarEvent halloween = named('Halloween');
    await (db.update(db.calendarEvents)..where((t) => t.id.equals(halloween.id)))
        .write(const CalendarEventsCompanion(name: Value('Dýně')));
    expect((await db.select(db.calendarEvents).get()).any((r) => r.name == 'Dýně'), isTrue);
    await (db.delete(db.calendarEvents)..where((t) => t.id.equals(halloween.id))).go();
    expect(await db.select(db.calendarEvents).get(), hasLength(34));
  });
}
