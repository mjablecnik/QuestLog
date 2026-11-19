import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/services/calendar/calendar_service.dart';

import '_harness.dart';

Future<void> withCalendar(Future<void> Function(CalendarHarness h) body) async {
  final CalendarHarness h = await CalendarHarness.open();
  try {
    await body(h);
  } finally {
    await h.close();
  }
}

/// Everything a deletion can touch, as comparable values.
Future<List<String>> snapshotOf(QuestlogDatabase db) async {
  final List<String> out = <String>[];
  for (final CalendarEventRow r in await (db.select(db.calendarEvents)..orderBy([(t) => OrderingTerm.asc(t.id)])).get()) {
    out.add('event $r');
  }
  for (final CalendarSkippedDateRow r in await db.select(db.calendarSkippedDates).get()) {
    out.add('skip $r');
  }
  for (final CalendarCompletionRow r in await db.select(db.calendarCompletions).get()) {
    out.add('done $r');
  }
  out.sort();
  return out;
}

void main() {
  // Feature: questlog-calendar, Property 7: Completing twice awards once, reopening restores Total_XP
  Glados3(any.intInRange(0, 3000), any.intInRange(0, EventType.values.length), any.intInRange(1, 600)).test(
    'Property 7: complete twice awards once and reopen restores Total_XP',
    (int startXp, int typeIndex, int minutes) async {
      await withCalendar((CalendarHarness h) async {
        await h.xp.apply(startXp);
        final CalendarEvent e = await h.service.create(
          h.draft(type: EventType.values[typeIndex], startMinute: 0, endMinute: minutes.clamp(0, 1439)),
        );
        final CompleteEventResult first = await h.service.completeOccurrence(e.id, d(2026, 11, 19));
        await h.service.completeOccurrence(e.id, d(2026, 11, 19));
        expect(await h.xp.readTotal(), startXp + first.awardedXp);
        expect(await h.db.select(h.db.calendarCompletions).get(), hasLength(1));
        await h.service.reopenOccurrence(e.id, d(2026, 11, 19));
        expect(await h.xp.readTotal(), startXp);
      });
    },
  );

  // Feature: questlog-calendar, Property 8: A later edit does not change awarded XP
  Glados2(any.intInRange(0, EventType.values.length), any.intInRange(0, 2)).test(
    'Property 8: an edit after completion keeps the stored XP and Total_XP',
    (int newTypeIndex, int allDayFlag) async {
      await withCalendar((CalendarHarness h) async {
        final CalendarEvent e = await h.service.create(h.draft());
        await h.service.completeOccurrence(e.id, d(2026, 11, 19));
        await h.service.update(
          e.id,
          h.draft(type: EventType.values[newTypeIndex], startMinute: allDayFlag == 1 ? null : 0, endMinute: 600),
        );
        expect((await h.db.select(h.db.calendarCompletions).getSingle()).awardedXp, 25);
        expect(await h.xp.readTotal(), 25);
      });
    },
  );

  // Feature: questlog-calendar, Property 9: Delete then undo restores the calendar
  Glados3(any.intInRange(0, 3), any.intInRange(0, 8), any.intInRange(0, 2), ExploreConfig(numRuns: 60)).test(
    'Property 9: restore of the snapshot leaves the calendar as it was',
    (int scopeIndex, int occurrenceIndex, int withEnd) async {
      await withCalendar((CalendarHarness h) async {
        final CalendarEvent e = await h.service.create(
          h.draft(
            date: d(2026, 11, 4),
            repeat: CadenceRepeat(Cadence.weekly, end: withEnd == 1 ? d(2027, 3, 1) : null),
          ),
        );
        await h.service.deleteOccurrence(e.id, d(2026, 11, 11), DeleteScope.onlyThis);
        await h.service.completeOccurrence(e.id, d(2026, 11, 18));
        final List<String> before = await snapshotOf(h.db);
        final int xpBefore = await h.xp.readTotal();
        final DateTime target = DateTime(2026, 11, 4 + 7 * occurrenceIndex);
        final DeletedEventSnapshot snapshot =
            await h.service.deleteOccurrence(e.id, target, DeleteScope.values[scopeIndex]);
        expect(await h.xp.readTotal(), xpBefore);
        await h.service.restore(snapshot);
        expect(await snapshotOf(h.db), before);
        expect(await h.xp.readTotal(), xpBefore);
      });
    },
  );

  // Feature: questlog-calendar, Property 10: "This and following" keeps the past
  Glados(any.intInRange(1, 20), ExploreConfig(numRuns: 40)).test(
    'Property 10: occurrences before the chosen one stay, none on or after remain',
    (int index) async {
      await withCalendar((CalendarHarness h) async {
        final CalendarEvent e = await h.service.create(
          h.draft(date: d(2026, 1, 7), repeat: const CadenceRepeat(Cadence.weekly)),
        );
        final DateTime chosen = DateTime(2026, 1, 7 + 7 * index);
        final List<DateTime> before = (await h.range(d(2026, 1, 1), d(2026, 12, 31))).map((o) => o.start).toList();
        await h.service.deleteOccurrence(e.id, chosen, DeleteScope.thisAndFollowing);
        final List<DateTime> after = (await h.range(d(2026, 1, 1), d(2026, 12, 31))).map((o) => o.start).toList();
        expect(after, before.where((DateTime s) => s.isBefore(chosen)).toList());
        expect(after.any((DateTime s) => !s.isBefore(chosen)), isFalse);
      });
    },
  );

  test('an Easter-relative event can be deleted for one year and restored', () async {
    await withCalendar((CalendarHarness h) async {
      final CalendarEvent e = await h.service.create(
        h.draft(name: 'Velký pátek', date: d(2016, 1, 1), startMinute: null, repeat: const EasterRelative(-2)),
      );
      await h.service.deleteOccurrence(e.id, d(2026, 4, 3), DeleteScope.onlyThis);
      expect(await h.range(d(2026, 1, 1), d(2026, 12, 31)), isEmpty);
      expect((await h.range(d(2027, 1, 1), d(2027, 12, 31))).single.start, d(2027, 3, 26));
    });
  });
}
