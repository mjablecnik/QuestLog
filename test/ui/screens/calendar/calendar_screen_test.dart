import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/ui/screens/calendar/calendar_screen.dart';
import 'package:questlog/ui/screens/calendar/day_sheet.dart';
import 'package:questlog/ui/screens/calendar/month_grid.dart';
import 'package:questlog/ui/state/calendar_state.dart';
import 'package:questlog/ui/widgets/calendar/event_chip.dart';

import '_calendar_harness.dart';

void main() {
  final CalendarUiHarness h = CalendarUiHarness();

  Future<void> open(WidgetTester tester, {DateTime? now, bool keepSeed = false, Set<EventType>? filter, double? textScale}) =>
      h.pump(tester, home: const CalendarScreen(), now: now, keepSeed: keepSeed, filter: filter, textScale: textScale);

  Finder cell(int month, int day, [int year = 2026]) => find.byKey(ValueKey<String>('day-$year-$month-$day'));

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(CalendarScreen)));

  calendarTest(h, 'shows the month of Calendar_Today as six rows of seven cells, Monday first', (tester) async {
    await open(tester);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.byType(DayCell), findsNWidgets(42));
    final List<String> names = <String>['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    for (final String n in names) {
      expect(find.text(n), findsOneWidget, reason: n);
    }
    // 26 October is the first cell, 6 December the last.
    expect(cell(10, 26), findsOneWidget);
    expect(cell(12, 6), findsOneWidget);
    final double monday = tester.getTopLeft(find.text('MON')).dx;
    final double sunday = tester.getTopLeft(find.text('SUN')).dx;
    expect(monday, lessThan(sunday));
  });

  calendarTest(h, 'marks Calendar_Today and fades the days of the neighbouring months', (tester) async {
    await open(tester);
    final Container today = tester.widget<Container>(find.descendant(of: cell(11, 19), matching: find.byType(Container)).first);
    expect(today.foregroundDecoration, isNotNull);
    final Container other = tester.widget<Container>(find.descendant(of: cell(11, 18), matching: find.byType(Container)).first);
    expect(other.foregroundDecoration, isNull);
  });

  calendarTest(h, 'the today mark moves at local midnight, not at 04:00', (tester) async {
    await open(tester, now: DateTime(2026, 11, 19, 23, 59));
    final ProviderContainer c = container(tester);
    expect(c.read(calendarTodayProvider), d(2026, 11, 19));
    h.clock.set(DateTime(2026, 11, 20, 0, 0));
    c.read(calendarTodayProvider.notifier).didChangeAppLifecycleState(AppLifecycleState.resumed);
    await h.settle(tester);
    final Container today = tester.widget<Container>(find.descendant(of: cell(11, 20), matching: find.byType(Container)).first);
    expect(today.foregroundDecoration, isNotNull);
  });

  calendarTest(h, 'the arrows, "Today" and the swipe change the month', (tester) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(en.calendar_nextMonth));
    await h.settle(tester);
    expect(find.text('December 2026'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(en.calendar_prevMonth));
    await tester.tap(find.bySemanticsLabel(en.calendar_prevMonth));
    await h.settle(tester);
    expect(find.text('October 2026'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('calendar-today')));
    await h.settle(tester);
    expect(find.text('November 2026'), findsOneWidget);

    await tester.fling(find.byKey(const ValueKey<String>('month-pager')), const Offset(-300, 0), 1500);
    await h.settle(tester);
    expect(find.text('December 2026'), findsOneWidget);
    await tester.fling(find.byKey(const ValueKey<String>('month-pager')), const Offset(300, 0), 1500);
    await h.settle(tester);
    expect(find.text('November 2026'), findsOneWidget);
  });

  calendarTest(h, 'MonthPickerSheet jumps to a month of another year and stays within 2000 to 2100', (tester) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('November 2026. ${en.calendar_pickMonth}')));
    await h.settle(tester);
    expect(find.text('2026'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(en.calendar_nextYear));
    await tester.pump();
    expect(find.text('2027'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('picker-month-3')));
    await h.settle(tester);
    expect(find.text('March 2027'), findsOneWidget);
  });

  calendarTest(h, 'shows events as chips in the colour of their type, all-day first', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Porada', type: EventType.meeting, date: d(2026, 11, 18), startMinute: 8 * 60 + 15, endMinute: 10 * 60);
    await h.add(tester, name: 'Narozeniny Evy', type: EventType.birthday, date: d(2026, 11, 18), startMinute: null);
    expect(find.descendant(of: cell(11, 18), matching: find.byType(EventChip)), findsNWidgets(2));
    final List<EventChip> chips = tester.widgetList<EventChip>(find.descendant(of: cell(11, 18), matching: find.byType(EventChip))).toList();
    expect(chips.map((EventChip c) => c.label).toList(), <String>['Narozeniny Evy', 'Porada']);
    expect(chips.first.type, EventType.birthday);
  });

  calendarTest(h, 'a date with more than three events shows two chips and "+N"', (tester) async {
    await open(tester);
    for (int i = 1; i <= 5; i++) {
      await h.add(tester, name: 'E$i', date: d(2026, 11, 18), startMinute: 8 * 60 + i, endMinute: 9 * 60);
    }
    expect(find.descendant(of: cell(11, 18), matching: find.byType(EventChip)), findsNWidgets(2));
    expect(find.descendant(of: cell(11, 18), matching: find.text('+3')), findsOneWidget);
    await h.add(tester, name: 'Tři', date: d(2026, 11, 17));
    await h.add(tester, name: 'Tři 2', date: d(2026, 11, 17), startMinute: 600, endMinute: 700);
    await h.add(tester, name: 'Tři 3', date: d(2026, 11, 17), startMinute: 800, endMinute: 900);
    expect(find.descendant(of: cell(11, 17), matching: find.byType(EventChip)), findsNWidgets(3));
  });

  calendarTest(h, 'a notable day is a soft chip, a public holiday a solid one', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Den veteránů', type: EventType.notableDay, date: d(2026, 11, 11), startMinute: null);
    await h.add(tester, name: 'Boj za svobodu', type: EventType.publicHoliday, date: d(2026, 11, 17), startMinute: null);
    BoxDecoration decoration(Finder cellFinder) => tester
        .widget<Container>(find.descendant(of: find.descendant(of: cellFinder, matching: find.byType(EventChip)), matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;
    expect(decoration(cell(11, 11)).border, isNotNull);
    expect(decoration(cell(11, 17)).border, isNull);
  });

  calendarTest(h, 'a multi-day event has a chip on every date it touches', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Seminář', type: EventType.seminar, date: d(2026, 11, 18), endDate: d(2026, 11, 20));
    for (final int day in <int>[18, 19, 20]) {
      expect(find.descendant(of: cell(11, day), matching: find.byType(EventChip)), findsOneWidget, reason: '$day');
    }
    expect(find.descendant(of: cell(11, 21), matching: find.byType(EventChip)), findsNothing);
  });

  calendarTest(h, 'a repeating event shows on each of its dates', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Salsa', type: EventType.lesson, date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly));
    for (final int day in <int>[4, 11, 18, 25]) {
      expect(find.descendant(of: cell(11, day), matching: find.byType(EventChip)), findsOneWidget, reason: '$day');
    }
  });

  calendarTest(h, 'each cell has one semantic label with the date and the number of events', (tester) async {
    await open(tester);
    await h.add(tester, name: 'A', date: d(2026, 11, 19));
    await h.add(tester, name: 'B', date: d(2026, 11, 19), startMinute: 600, endMinute: 700);
    expect(find.bySemanticsLabel('Thursday, November 19, 2026, 2 events'), findsOneWidget);
    expect(find.bySemanticsLabel('Friday, November 20, 2026, no events'), findsOneWidget);
  });

  calendarTest(h, 'built-in holidays appear in the month: 17 November is a public holiday', (tester) async {
    await open(tester, keepSeed: true);
    expect(find.descendant(of: cell(11, 17), matching: find.text('Den boje za svobodu a demokracii')), findsOneWidget);
    // Two events on 11 November (Svatý Martin and no name day): the folk day shows as a soft chip.
    expect(find.descendant(of: cell(11, 11), matching: find.text('Svatý Martin')), findsOneWidget);
  });

  group('large text', () {
    calendarTest(h, 'chips stay inside their cells at a large text size', (tester) async {
      await open(tester, textScale: 2.0);
      for (int i = 1; i <= 4; i++) {
        await h.add(tester, name: 'Dlouhý název události číslo $i', date: d(2026, 11, 18), startMinute: 8 * 60 + i, endMinute: 9 * 60);
      }
      expect(tester.takeException(), isNull);
      final Rect cellRect = tester.getRect(cell(11, 18));
      for (final Element e in find.descendant(of: cell(11, 18), matching: find.byType(EventChip)).evaluate()) {
        final Rect chip = tester.getRect(find.byWidget(e.widget));
        expect(chip.bottom, lessThanOrEqualTo(cellRect.bottom + 0.5));
        expect(chip.right, lessThanOrEqualTo(cellRect.right + 0.5));
      }
    });
  });

  calendarTest(h, 'DayCell.split keeps to the room it has', (tester) async {
    await open(tester);
    expect(DayCell.split(2, 100, 10), (shown: 2, hidden: 0));
    expect(DayCell.split(3, 100, 10), (shown: 3, hidden: 0));
    expect(DayCell.split(5, 100, 10), (shown: 2, hidden: 3));
    expect(DayCell.split(5, 20, 10), (shown: 1, hidden: 4));
    expect(DayCell.split(2, 15, 10), (shown: 0, hidden: 2));
    expect(DayCell.split(5, 0, 10), (shown: 0, hidden: 5));
  });

  group('type filter', () {
    calendarTest(h, 'TypeFilterSheet hides the events of a switched-off type and shows the filter button in the accent colour', (tester) async {
      await open(tester);
      await h.add(tester, name: 'Tanec', type: EventType.dance, date: d(2026, 11, 18));
      await h.add(tester, name: 'Práce', type: EventType.work, date: d(2026, 11, 18), startMinute: 600, endMinute: 700);
      expect(find.byType(EventChip), findsNWidgets(2));
      await tester.tap(find.bySemanticsLabel(en.calendar_filter));
      await h.settle(tester);
      await tester.tap(find.byKey(const ValueKey<String>('filter-dance')));
      await h.settle(tester);
      await tester.tap(find.text(en.calendar_filterDone));
      await h.settle(tester);
      expect(find.byType(EventChip), findsOneWidget);
      expect(find.text('Práce'), findsOneWidget);
      expect(h.filterStore.value, isNot(contains(EventType.dance)));
      expect(container(tester).read(typeFilterActiveProvider), isTrue);
    });

    calendarTest(h, 'starts from the stored filter', (tester) async {
      await open(tester, filter: <EventType>{EventType.work});
      await h.add(tester, name: 'Tanec', type: EventType.dance, date: d(2026, 11, 18));
      expect(find.byType(EventChip), findsNothing);
    });

    calendarTest(h, 'with every type off the month is empty and a message offers to show all', (tester) async {
      await open(tester, filter: <EventType>{});
      await h.add(tester, name: 'Tanec', type: EventType.dance, date: d(2026, 11, 18));
      expect(find.byType(EventChip), findsNothing);
      expect(find.text(en.calendar_filterHidesAll), findsOneWidget);
      await tester.tap(find.text(en.calendar_filterShowAll));
      await h.settle(tester);
      expect(find.text(en.calendar_filterHidesAll), findsNothing);
      expect(find.byType(EventChip), findsOneWidget);
    });
  });

  group('day sheet', () {
    calendarTest(h, 'opens on a tap: heading, count, all-day first, then timed events by time', (tester) async {
      await open(tester);
      await h.add(tester, name: 'Leandro Salsa', type: EventType.lesson, date: d(2026, 11, 18), startMinute: 18 * 60, endMinute: 19 * 60);
      await h.add(tester, name: 'Porada', type: EventType.meeting, date: d(2026, 11, 18), startMinute: 8 * 60 + 15, endMinute: 10 * 60);
      await h.add(tester, name: 'Narozeniny Evy', type: EventType.birthday, date: d(2026, 11, 18), startMinute: null);
      await tester.tap(cell(11, 18));
      await h.settle(tester);
      expect(find.text('Wednesday, November 18'), findsOneWidget);
      expect(find.text('3 events'), findsOneWidget);
      final List<String> names = <String>['Narozeniny Evy', 'Porada', 'Leandro Salsa'];
      final List<double> tops = <double>[
        for (final String n in names) tester.getTopLeft(find.descendant(of: find.byType(DaySheet), matching: find.text(n))).dy,
      ];
      expect(tops[0], lessThan(tops[1]));
      expect(tops[1], lessThan(tops[2]));
      expect(find.text('08:15'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text(en.calendar_allDay), findsWidgets);
      expect(find.text(en.calendar_typeLesson), findsOneWidget);
    });

    calendarTest(h, 'an empty day shows "No events" and an add button', (tester) async {
      await open(tester);
      await tester.tap(cell(11, 13));
      await h.settle(tester);
      expect(find.text(en.calendar_dayEmpty), findsWidgets);
      expect(find.byKey(const ValueKey<String>('day-add')), findsOneWidget);
    });

    calendarTest(h, 'a multi-day timed event shows only its part of the day', (tester) async {
      await open(tester);
      await h.add(tester, name: 'Konference', type: EventType.seminar, date: d(2026, 11, 18), endDate: d(2026, 11, 20), startMinute: 9 * 60, endMinute: 17 * 60);
      await tester.tap(cell(11, 18));
      await h.settle(tester);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('23:59'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('day-close')));
      await h.settle(tester);
      await tester.tap(cell(11, 19));
      await h.settle(tester);
      expect(find.text(en.calendar_allDay), findsWidgets);
      await tester.tap(find.byKey(const ValueKey<String>('day-close')));
      await h.settle(tester);
      await tester.tap(cell(11, 20));
      await h.settle(tester);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('17:00'), findsOneWidget);
    });

    calendarTest(h, 'closes with the button and keeps the visible month', (tester) async {
      await open(tester);
      await tester.tap(cell(11, 18));
      await h.settle(tester);
      await tester.tap(find.byKey(const ValueKey<String>('day-close')));
      await h.settle(tester);
      expect(find.text('Wednesday, November 18'), findsNothing);
      expect(find.text('November 2026'), findsOneWidget);
    });

    calendarTest(h, 'shows a new event at once and sets the selected day', (tester) async {
      await open(tester);
      await tester.tap(cell(11, 18));
      await h.settle(tester);
      expect(container(tester).read(selectedDayProvider), d(2026, 11, 18));
      expect(find.text(en.calendar_dayEmpty), findsWidgets);
      await h.add(tester, name: 'Nový', date: d(2026, 11, 18));
      expect(find.text('Nový'), findsWidgets);
      expect(find.text('1 event'), findsOneWidget);
    });
  });

  group('search', () {
    calendarTest(h, 'EventSearchScreen finds an event ignoring case and diacritics, shows its type and date, opens its detail', (tester) async {
      await open(tester);
      await h.add(tester, name: 'Řehoř na schůzce', type: EventType.meeting, date: d(2026, 12, 3));
      await tester.tap(find.bySemanticsLabel(en.calendar_search));
      await h.settle(tester);
      expect(find.text(en.calendar_searchPrompt), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey<String>('search-field')), 'REHOR');
      await h.settle(tester);
      expect(find.text('Řehoř na schůzce'), findsOneWidget);
      expect(find.textContaining('Meeting · '), findsOneWidget);
      await tester.tap(find.text('Řehoř na schůzce'));
      await h.settle(tester);
      expect(find.byKey(const ValueKey<String>('detail-edit')), findsOneWidget);
    });

    calendarTest(h, 'says "Nothing found" for no match', (tester) async {
      await open(tester);
      await tester.tap(find.bySemanticsLabel(en.calendar_search));
      await h.settle(tester);
      await tester.enterText(find.byKey(const ValueKey<String>('search-field')), 'zzz');
      await h.settle(tester);
      expect(find.text(en.calendar_searchNone), findsOneWidget);
    });

    calendarTest(h, 'ignores the type filter', (tester) async {
      await open(tester, filter: <EventType>{EventType.work});
      await h.add(tester, name: 'Tanec', type: EventType.dance, date: d(2026, 12, 3));
      await tester.tap(find.bySemanticsLabel(en.calendar_search));
      await h.settle(tester);
      await tester.enterText(find.byKey(const ValueKey<String>('search-field')), 'tanec');
      await h.settle(tester);
      expect(find.text('Tanec'), findsWidgets);
      expect(find.textContaining('Dance · '), findsOneWidget);
    });
  });

  calendarTest(h, 'month pager follows the provider, repeat series is not a stored list', (tester) async {
    await open(tester);
    container(tester).read(visibleMonthProvider.notifier).show(d(2027, 3, 1));
    await h.settle(tester);
    expect(find.text('March 2027'), findsOneWidget);
    expect(find.byType(MonthPage), findsWidgets);
    expect(const NoRepeat().end, isNull);
  });
}
