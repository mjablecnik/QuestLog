import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/services/calendar/calendar_service.dart' show DeleteScope;
import 'package:questlog/ui/screens/calendar/calendar_screen.dart';
import 'package:questlog/ui/screens/calendar/event_detail_screen.dart';

import '_calendar_harness.dart';

void main() {
  final CalendarUiHarness h = CalendarUiHarness();

  Future<void> openMonth(WidgetTester tester) => h.pump(tester, home: const CalendarScreen());

  Future<void> openDetail(WidgetTester tester, CalendarEvent e, DateTime date) async {
    final BuildContext context = tester.element(find.byType(CalendarScreen));
    showEventDetail(context, e.id, date);
    await h.settle(tester);
  }

  Finder menu() => find.byKey(const ValueKey<String>('detail-menu'));

  calendarTest(h, 'shows name, type badge, start and end, and "Not set" for an empty note and location', (tester) async {
    await openMonth(tester);
    final CalendarEvent e = await h.add(tester, name: 'Leandro Salsa', type: EventType.lesson, date: d(2026, 11, 18));
    await openDetail(tester, e, d(2026, 11, 18));
    expect(find.text('Leandro Salsa'), findsWidgets);
    expect(find.text(en.calendar_typeLesson), findsOneWidget);
    expect(find.text(en.calendar_start), findsOneWidget);
    expect(find.text(en.calendar_end), findsOneWidget);
    expect(find.text('Wed, Nov 18, 2026'), findsNWidgets(2));
    expect(find.text('18:00'), findsOneWidget);
    expect(find.text('19:00'), findsOneWidget);
    expect(find.text(en.calendar_notSet), findsNWidgets(2));
    expect(find.text(en.calendar_repeatNever), findsOneWidget);
  });

  calendarTest(h, 'an all-day event shows dates without times and "All day"', (tester) async {
    await openMonth(tester);
    final CalendarEvent e = await h.add(tester, name: 'Narozeniny', type: EventType.birthday, date: d(2026, 11, 18), startMinute: null);
    await openDetail(tester, e, d(2026, 11, 18));
    expect(find.text(en.calendar_allDay), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d\d:\d\d$')), findsNothing);
  });

  calendarTest(h, 'a repeat is described in words for the occurrence that is open', (tester) async {
    await openMonth(tester);
    final CalendarEvent e = await h.add(tester, name: 'Salsa', type: EventType.lesson, date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly));
    await openDetail(tester, e, d(2026, 11, 18));
    expect(find.text('every week on Wednesday'), findsOneWidget);
    expect(find.text('Wed, Nov 18, 2026'), findsNWidgets(2));
  });

  calendarTest(h, 'the built-in rules are described: Easter and the n-th weekday', (tester) async {
    await openMonth(tester);
    final CalendarEvent easter = await h.add(tester, name: 'Velikonoční neděle', type: EventType.notableDay, date: d(2000, 1, 1), startMinute: null, repeat: const EasterRelative(0));
    await openDetail(tester, easter, d(2026, 4, 5));
    expect(find.text(en.calendar_repeatDescEaster), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('detail-close')));
    await h.settle(tester);
    final CalendarEvent mothers = await h.add(
      tester,
      name: 'Den matek',
      type: EventType.notableDay,
      date: d(2000, 1, 1),
      startMinute: null,
      repeat: const NthWeekday(month: 5, weekday: DateTime.sunday, ordinal: 2),
    );
    await openDetail(tester, mothers, d(2026, 5, 10));
    expect(find.text('every year, 2nd Sunday of May'), findsOneWidget);
  });

  calendarTest(h, 'a repeat end is shown', (tester) async {
    await openMonth(tester);
    final CalendarEvent e = await h.add(tester, name: 'Kurz', date: d(2026, 11, 4), repeat: CadenceRepeat(Cadence.weekly, end: d(2026, 12, 30)));
    await openDetail(tester, e, d(2026, 11, 4));
    expect(find.textContaining('until'), findsOneWidget);
  });

  calendarTest(h, 'tapping the location copies it and shows a snackbar', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await openMonth(tester);
    final CalendarEvent e = await h.add(tester, name: 'Oběd', location: 'Černá růže, Brno');
    await openDetail(tester, e, d(2026, 11, 19));
    await tester.tap(find.text('Černá růže, Brno'));
    await h.settle(tester);
    expect(copied, 'Černá růže, Brno');
    expect(find.text(en.calendar_locationCopied), findsOneWidget);
  });

  calendarTest(h, 'a completed occurrence shows when it was done and the XP', (tester) async {
    await openMonth(tester);
    final CalendarEvent e = await h.add(tester, name: 'Hotovo', onBoard: true);
    await tester.runAsync(() => h.service.completeOccurrence(e.id, d(2026, 11, 19)));
    await openDetail(tester, e, d(2026, 11, 19));
    expect(find.text(en.calendar_completedAt('10:00', 25)), findsOneWidget);
  });

  calendarTest(h, 'the Edit button and the menu entry open the form, close returns', (tester) async {
    await openMonth(tester);
    final CalendarEvent e = await h.add(tester, name: 'Upravit mě');
    await openDetail(tester, e, d(2026, 11, 19));
    await tester.tap(find.byKey(const ValueKey<String>('detail-edit')));
    await h.settle(tester);
    expect(find.text(en.calendar_formEditTitle), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('form-back')));
    await h.settle(tester);
    expect(find.text(en.calendar_formEditTitle), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('detail-close')));
    await h.settle(tester);
    expect(find.byKey(const ValueKey<String>('detail-edit')), findsNothing);
  });

  calendarTest(h, 'Duplicate opens a new-event form with every value except the repeat', (tester) async {
    await openMonth(tester);
    final CalendarEvent e = await h.add(
      tester,
      name: 'Salsa',
      type: EventType.lesson,
      date: d(2026, 11, 4),
      location: 'Studio',
      onBoard: true,
      repeat: const CadenceRepeat(Cadence.weekly),
    );
    await openDetail(tester, e, d(2026, 11, 18));
    await tester.tap(menu());
    await h.settle(tester);
    await tester.tap(find.text(en.calendar_duplicate));
    await h.settle(tester);
    expect(find.text(en.calendar_formCreateTitle), findsOneWidget);
    expect(find.text('Salsa'), findsWidgets);
    expect(find.text('Studio', skipOffstage: false), findsWidgets);
    expect(find.text('Wed, Nov 18, 2026'), findsWidgets);
    expect(find.byKey(const ValueKey<String>('form-repeat-end')), findsNothing);
    expect(find.byKey(const ValueKey<String>('form-xp'), skipOffstage: false), findsOneWidget);
  });

  group('delete', () {
    calendarTest(h, 'DeleteEventSheet: one confirmation for an event without a repeat; undo brings it back', (tester) async {
      await openMonth(tester);
      final CalendarEvent e = await h.add(tester, name: 'Jednou');
      await openDetail(tester, e, d(2026, 11, 19));
      await tester.tap(menu());
      await h.settle(tester);
      await tester.tap(find.text(en.common_delete));
      await h.settle(tester);
      expect(find.text(en.calendar_deleteTitle), findsOneWidget);
      expect(find.text(en.calendar_deleteBody('Jednou')), findsOneWidget);
      await tester.tap(find.text(en.common_cancel));
      await h.settle(tester);
      expect(await tester.runAsync(() => h.service.getEvent(e.id)), isNotNull);

      await tester.tap(menu());
      await h.settle(tester);
      await tester.tap(find.text(en.common_delete));
      await h.settle(tester);
      await tester.tap(find.text(en.common_delete).last);
      await h.settle(tester);
      expect(await tester.runAsync(() => h.service.getEvent(e.id)), isNull);
      expect(find.byKey(const ValueKey<String>('detail-edit')), findsNothing);
      expect(find.text(en.calendar_deleted('Jednou')), findsOneWidget);
      await tester.tap(find.text(en.calendar_undo));
      await h.settle(tester);
      expect(await tester.runAsync(() => h.service.getEvent(e.id)), isNotNull);
    });

    calendarTest(h, 'DeleteEventSheet: a repeating event offers three scopes; "only this" skips one date and undo restores it', (tester) async {
      await openMonth(tester);
      final CalendarEvent e = await h.add(tester, name: 'Salsa', type: EventType.lesson, date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly));
      await openDetail(tester, e, d(2026, 11, 18));
      await tester.tap(menu());
      await h.settle(tester);
      await tester.tap(find.text(en.common_delete));
      await h.settle(tester);
      expect(find.text(en.calendar_deleteOnlyThis), findsOneWidget);
      expect(find.text(en.calendar_deleteThisAndFollowing), findsOneWidget);
      expect(find.text(en.calendar_deleteAll), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('delete-onlyThis')));
      await h.settle(tester);
      final List<EventOccurrence> after = (await tester.runAsync(() => h.service.occurrencesIn(d(2026, 11, 1), d(2026, 11, 30))))!;
      expect(after.map((EventOccurrence o) => o.start.day).toList(), <int>[4, 11, 25]);
      await tester.tap(find.text(en.calendar_undo));
      await h.settle(tester);
      final List<EventOccurrence> restored = (await tester.runAsync(() => h.service.occurrencesIn(d(2026, 11, 1), d(2026, 11, 30))))!;
      expect(restored.map((EventOccurrence o) => o.start.day).toList(), <int>[4, 11, 18, 25]);
    });

    calendarTest(h, '"this and following" and "all" end the series', (tester) async {
      await openMonth(tester);
      final CalendarEvent e = await h.add(tester, name: 'Salsa', date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly));
      await openDetail(tester, e, d(2026, 11, 18));
      await tester.tap(menu());
      await h.settle(tester);
      await tester.tap(find.text(en.common_delete));
      await h.settle(tester);
      await tester.tap(find.byKey(const ValueKey<String>('delete-thisAndFollowing')));
      await h.settle(tester);
      final List<EventOccurrence> after = (await tester.runAsync(() => h.service.occurrencesIn(d(2026, 11, 1), d(2026, 12, 31))))!;
      expect(after.map((EventOccurrence o) => o.start.day).toList(), <int>[4, 11]);
    });

    calendarTest(h, 'cancelling the scope sheet deletes nothing', (tester) async {
      await openMonth(tester);
      final CalendarEvent e = await h.add(tester, name: 'Salsa', date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly));
      await openDetail(tester, e, d(2026, 11, 18));
      await tester.tap(menu());
      await h.settle(tester);
      await tester.tap(find.text(en.common_delete));
      await h.settle(tester);
      await tester.tap(find.text(en.common_cancel));
      await h.settle(tester);
      expect(await tester.runAsync(() => h.service.getEvent(e.id)), isNotNull);
    });
  });

  calendarTest(h, 'a detail whose event is deleted elsewhere closes itself', (tester) async {
    await openMonth(tester);
    final CalendarEvent e = await h.add(tester, name: 'Zmizí');
    await openDetail(tester, e, d(2026, 11, 19));
    expect(find.byKey(const ValueKey<String>('detail-edit')), findsOneWidget);
    await tester.runAsync(() => h.service.deleteOccurrence(e.id, d(2026, 11, 19), DeleteScope.all));
    await h.settle(tester);
    expect(find.byKey(const ValueKey<String>('detail-edit')), findsNothing);
  });
}
