import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/validation.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/calendar/calendar_service.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/test_database.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

void main() {
  late QuestlogDatabase db;
  late FixedClock clock;
  late QuestService quests;
  late CalendarService calendar;

  setUp(() async {
    db = createTestDatabase();
    await db.delete(db.calendarEvents).go();
    final XpEngine xp = XpEngine(db);
    clock = FixedClock(DateTime(2026, 11, 20, 10));
    quests = QuestService(db, xp, clock);
    calendar = CalendarService(db, xp, clock);
  });
  tearDown(() => db.close());

  QuestDraft draft({String name = 'Pay rent', DateTime? deadline}) =>
      QuestDraft(name: name, difficulty: Difficulty.normal, deadline: deadline);

  Future<List<CalendarEventRow>> events() => db.select(db.calendarEvents).get();
  Future<Map<int, DateTime>> deadlines() => quests.watchDeadlines().first;

  test('a Quest with a Deadline gets an all-day Date event, not on the Board', () async {
    final Quest q = await quests.create(draft(deadline: d(2026, 11, 25)));
    final List<CalendarEventRow> all = await events();
    expect(all, hasLength(1));
    expect(all.single.name, 'Pay rent');
    expect(all.single.eventType, EventType.quest.key);
    expect(all.single.startMinute, isNull);
    expect(all.single.startDate, d(2026, 11, 25));
    expect(all.single.endDate, d(2026, 11, 25));
    expect(all.single.onBoard, isFalse);
    expect(q.eventId, all.single.id);
    expect(await deadlines(), <int, DateTime>{q.id: d(2026, 11, 25)});
  });

  test('the Quest event does not become the last used type of the event form', () async {
    await calendar.create(
      EventDraft(name: 'Dance', type: EventType.dance, startDate: d(2026, 11, 21), endDate: d(2026, 11, 21), onBoard: false),
    );
    clock.advance(const Duration(hours: 1));
    await quests.create(draft(deadline: d(2026, 11, 25)));
    expect(await calendar.lastUsedType(), EventType.dance);
  });

  test('a Quest without a Deadline has no event', () async {
    final Quest q = await quests.create(draft());
    expect(await events(), isEmpty);
    expect(q.eventId, isNull);
    expect(await deadlines(), isEmpty);
  });

  test('the Calendar shows the event on the Deadline day', () async {
    await quests.create(draft(deadline: d(2026, 11, 25)));
    final occurrences = await calendar.occurrencesIn(d(2026, 11, 25), d(2026, 11, 25));
    expect(occurrences.map((o) => o.event.name), <String>['Pay rent']);
    expect(occurrences.single.event.allDay, isTrue);
  });

  test('a new Deadline moves the event, keeping its length and times', () async {
    final Quest q = await quests.create(draft(deadline: d(2026, 11, 25)));
    final int id = q.eventId!;
    await (db.update(db.calendarEvents)..where((e) => e.id.equals(id))).write(
      CalendarEventsCompanion(
        startDate: Value(d(2026, 11, 24)),
        startMinute: const Value(9 * 60),
        endMinute: const Value(10 * 60),
      ),
    );
    await quests.update(q.id, draft(deadline: d(2026, 12, 3)));
    final CalendarEventRow e = (await events()).single;
    expect(e.startDate, d(2026, 12, 2));
    expect(e.endDate, d(2026, 12, 3));
    expect(e.startMinute, 9 * 60);
    expect(e.endMinute, 10 * 60);
    expect((await deadlines())[q.id], d(2026, 12, 3));
  });

  test('adding a Deadline to an existing Quest creates the event; clearing it deletes the event', () async {
    final Quest q = await quests.create(draft());
    final Quest dated = await quests.update(q.id, draft(deadline: d(2026, 11, 22)));
    expect(dated.eventId, isNotNull);
    expect(await events(), hasLength(1));
    final Quest cleared = await quests.update(q.id, draft());
    expect(cleared.eventId, isNull);
    expect(await events(), isEmpty);
  });

  test('renaming the Quest renames its event', () async {
    final Quest q = await quests.create(draft(deadline: d(2026, 11, 25)));
    await quests.update(q.id, draft(name: 'Pay the rent', deadline: d(2026, 11, 25)));
    expect((await events()).single.name, 'Pay the rent');
  });

  test('a Deadline edited in the Calendar is the Quest Deadline', () async {
    final Quest q = await quests.create(draft(deadline: d(2026, 11, 25)));
    final CalendarEvent e = (await calendar.getEvent(q.eventId!))!;
    await calendar.update(e.id, EventDraft.fromEvent(e).copyWith(startDate: d(2026, 11, 28), endDate: d(2026, 11, 28)));
    expect((await deadlines())[q.id], d(2026, 11, 28));
  });

  test('deleting the event keeps the Quest, loses the Deadline and changes no XP', () async {
    final Quest q = await quests.create(draft(deadline: d(2026, 11, 25)));
    await quests.complete(q.id);
    final int xpBefore = (await (db.select(db.appState)).getSingle()).totalXp;
    final CalendarEvent e = (await calendar.getEvent(q.eventId!))!;
    await calendar.deleteOccurrence(e.id, e.startDate, DeleteScope.all);
    expect(await events(), isEmpty);
    final QuestRow row = await (db.select(db.quests)..where((t) => t.id.equals(q.id))).getSingle();
    expect(row.eventId, isNull);
    expect(row.completedAt, isNotNull);
    expect((await (db.select(db.appState)).getSingle()).totalXp, xpBefore);
    expect(await deadlines(), isEmpty);
  });

  test('undoing the deletion of the event gives the Quest its Deadline back', () async {
    final Quest q = await quests.create(draft(deadline: d(2026, 11, 25)));
    final CalendarEvent e = (await calendar.getEvent(q.eventId!))!;
    final DeletedEventSnapshot snapshot = await calendar.deleteOccurrence(e.id, e.startDate, DeleteScope.all);
    expect(await deadlines(), isEmpty);
    await calendar.restore(snapshot);
    expect((await deadlines())[q.id], d(2026, 11, 25));
  });

  test('deleting the Quest deletes its event', () async {
    final Quest q = await quests.create(draft(deadline: d(2026, 11, 25)));
    await quests.delete(q.id);
    expect(await events(), isEmpty);
  });

  test('a done Quest keeps its Deadline and its event is only renamed', () async {
    final Quest q = await quests.create(draft(deadline: d(2026, 11, 25)));
    await quests.complete(q.id);
    await quests.update(q.id, draft(name: 'Paid', deadline: d(2027, 1, 1)));
    expect((await deadlines())[q.id], d(2026, 11, 25));
    expect((await events()).single.name, 'Paid');
  });

  test('a Quest in a Mission can have a Deadline', () async {
    final int missionId = await db.into(db.missions).insert(
      MissionsCompanion.insert(name: 'M', bonus: MissionBonus.small, createdAt: clock.now()),
    );
    final Quest q = await quests.create(
      QuestDraft(name: 'In mission', difficulty: Difficulty.easy, missionId: missionId, deadline: d(2026, 12, 1)),
    );
    expect((await deadlines())[q.id], d(2026, 12, 1));
  });

  test('isOverdue is true only for a date before today', () {
    expect(isOverdue(d(2026, 11, 19), d(2026, 11, 20)), isTrue);
    expect(isOverdue(d(2026, 11, 20), d(2026, 11, 20)), isFalse);
    expect(isOverdue(d(2026, 11, 21), d(2026, 11, 20)), isFalse);
  });
}
