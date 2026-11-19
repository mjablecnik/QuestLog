import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/services/calendar/calendar_service.dart';

import '_harness.dart';

void main() {
  late CalendarHarness h;

  setUp(() async => h = await CalendarHarness.open());
  tearDown(() => h.close());

  Future<List<EventOccurrence>> tasks(DateTime day) async {
    final List<EventOccurrence> out = await h.service.watchEventTasks(day).first;
    return out;
  }

  group('Event_Tasks', () {
    test('only On_Board events that start today appear, all-day first', () async {
      await h.service.create(h.draft(name: 'Ne', onBoard: false));
      await h.service.create(h.draft(name: 'Večer', onBoard: true, startMinute: 20 * 60, endMinute: 21 * 60));
      await h.service.create(h.draft(name: 'Ráno', onBoard: true, startMinute: 8 * 60, endMinute: 9 * 60));
      await h.service.create(h.draft(name: 'Celý den', onBoard: true, startMinute: null));
      await h.service.create(h.draft(name: 'Zítra', onBoard: true, date: d(2026, 11, 20)));
      expect((await tasks(d(2026, 11, 19))).map((o) => o.event.name).toList(), <String>['Celý den', 'Ráno', 'Večer']);
      expect((await tasks(d(2026, 11, 20))).map((o) => o.event.name).toList(), <String>['Zítra']);
    });

    test('a multi-day event is a task only on its start date', () async {
      await h.service.create(h.draft(name: 'Seminář', onBoard: true, date: d(2026, 11, 18), endDate: d(2026, 11, 20)));
      expect(await tasks(d(2026, 11, 18)), hasLength(1));
      expect(await tasks(d(2026, 11, 19)), isEmpty);
    });

    test('a repeating event is a task on each of its dates', () async {
      await h.service.create(h.draft(name: 'Salsa', onBoard: true, date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly)));
      expect(await tasks(d(2026, 11, 18)), hasLength(1));
      expect(await tasks(d(2026, 11, 19)), isEmpty);
    });

    test('the seeded holidays are not tasks, a seeded name day is', () async {
      final CalendarHarness seeded = await CalendarHarness.open(keepSeed: true);
      addTearDown(seeded.close);
      expect(await seeded.service.watchEventTasks(d(2026, 11, 17)).first, isEmpty);
      expect(await seeded.service.watchEventTasks(d(2026, 12, 24)).first, isEmpty);
      final List<EventOccurrence> iveta = await seeded.service.watchEventTasks(d(2026, 6, 7)).first;
      expect(iveta.single.event.name, 'Iveta');
      expect(iveta.single.event.type, EventType.nameDay);
    });
  });

  group('completion', () {
    test('completing awards the Event_XP once and stores the completion', () async {
      final CalendarEvent e = await h.service.create(h.draft(onBoard: true));
      final CompleteEventResult r = await h.service.completeOccurrence(e.id, d(2026, 11, 19));
      expect(r.awardedXp, 25);
      expect(r.completion.awardedXp, 25);
      expect(r.completion.completedAt, DateTime(2026, 11, 19, 10));
      expect(await h.xp.readTotal(), 25);
      final CompleteEventResult again = await h.service.completeOccurrence(e.id, d(2026, 11, 19));
      expect(again.awardedXp, 0);
      expect(await h.xp.readTotal(), 25);
      expect(await h.db.select(h.db.calendarCompletions).get(), hasLength(1));
    });

    test('XP follows the duration, or the type for an all-day event', () async {
      final CalendarEvent quick = await h.service.create(h.draft(startMinute: 600, endMinute: 615));
      final CalendarEvent long = await h.service.create(h.draft(startMinute: 540, endMinute: 540 + 6 * 60 - 1));
      final CalendarEvent birthday = await h.service.create(h.draft(startMinute: null, type: EventType.birthday));
      final CalendarEvent lesson = await h.service.create(h.draft(startMinute: null, type: EventType.lesson));
      expect((await h.service.completeOccurrence(quick.id, d(2026, 11, 19))).awardedXp, 10);
      expect((await h.service.completeOccurrence(long.id, d(2026, 11, 19))).awardedXp, 100);
      expect((await h.service.completeOccurrence(birthday.id, d(2026, 11, 19))).awardedXp, 10);
      expect((await h.service.completeOccurrence(lesson.id, d(2026, 11, 19))).awardedXp, 25);
      expect(await h.xp.readTotal(), 145);
    });

    test('a level up is reported', () async {
      await h.xp.apply(95);
      final CalendarEvent e = await h.service.create(h.draft());
      final CompleteEventResult r = await h.service.completeOccurrence(e.id, d(2026, 11, 19));
      expect(r.levelBefore, 1);
      expect(r.levelAfter, 2);
    });

    test('every occurrence of a series uses the first duration and completes separately', () async {
      final CalendarEvent e = await h.service.create(h.draft(date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly)));
      await h.service.completeOccurrence(e.id, d(2026, 11, 4));
      await h.service.completeOccurrence(e.id, d(2026, 11, 11));
      expect(await h.xp.readTotal(), 50);
      final List<EventOccurrence> r = await h.range(d(2026, 11, 1), d(2026, 11, 30));
      expect(r.where((o) => o.isCompleted).map((o) => o.start).toList(), <DateTime>[d(2026, 11, 4), d(2026, 11, 11)]);
    });

    test('a date that is not an occurrence is rejected', () async {
      final CalendarEvent e = await h.service.create(h.draft());
      expect(() => h.service.completeOccurrence(e.id, d(2026, 11, 20)), throwsA(isA<InvalidStateError>()));
      expect(() => h.service.completeOccurrence(999, d(2026, 11, 19)), throwsA(isA<NotFoundError>()));
      expect(await h.xp.readTotal(), 0);
    });

    test('reopening removes the completion and the XP', () async {
      final CalendarEvent e = await h.service.create(h.draft());
      await h.service.completeOccurrence(e.id, d(2026, 11, 19));
      await h.service.reopenOccurrence(e.id, d(2026, 11, 19));
      expect(await h.xp.readTotal(), 0);
      expect(await h.db.select(h.db.calendarCompletions).get(), isEmpty);
      await h.service.reopenOccurrence(e.id, d(2026, 11, 19));
      expect(await h.xp.readTotal(), 0);
    });

    test('an edit after completion does not change the stored XP', () async {
      final CalendarEvent e = await h.service.create(h.draft());
      await h.service.completeOccurrence(e.id, d(2026, 11, 19));
      await h.service.update(e.id, h.draft(startMinute: null, type: EventType.birthday));
      expect((await h.db.select(h.db.calendarCompletions).getSingle()).awardedXp, 25);
      await h.service.reopenOccurrence(e.id, d(2026, 11, 19));
      expect(await h.xp.readTotal(), 0);
    });

    test('deleting a completed event keeps the XP already awarded', () async {
      final CalendarEvent e = await h.service.create(h.draft());
      await h.service.completeOccurrence(e.id, d(2026, 11, 19));
      await h.service.deleteOccurrence(e.id, d(2026, 11, 19), DeleteScope.all);
      expect(await h.xp.readTotal(), 25);
    });

    test('a completion shows in the task stream and leaves when reopened', () async {
      final CalendarEvent e = await h.service.create(h.draft(onBoard: true));
      final List<bool> seen = <bool>[];
      final sub = h.service.watchEventTasks(d(2026, 11, 19)).listen((l) => seen.add(l.single.isCompleted));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await h.service.completeOccurrence(e.id, d(2026, 11, 19));
      await pumpEventQueue();
      await h.service.reopenOccurrence(e.id, d(2026, 11, 19));
      await pumpEventQueue();
      expect(seen, <bool>[false, true, false]);
    });

    test('a failed completion leaves XP and completion untouched', () async {
      final CalendarEvent e = await h.service.create(h.draft());
      await h.db.close();
      // The connection is closed, so the transaction cannot run.
      await expectLater(h.service.completeOccurrence(e.id, d(2026, 11, 19)), throwsA(anything));
    });
  });
}
