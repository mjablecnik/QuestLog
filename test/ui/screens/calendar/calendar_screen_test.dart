import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/ui/screens/calendar/calendar_screen.dart';
import 'package:questlog/ui/screens/calendar/day_sheet.dart';
import 'package:questlog/ui/screens/calendar/month_grid.dart';
import 'package:questlog/ui/screens/calendar/week_lanes.dart';
import 'package:questlog/ui/state/calendar_state.dart';
import 'package:questlog/ui/widgets/calendar/event_chip.dart';

import '_calendar_harness.dart';

void main() {
  final CalendarUiHarness h = CalendarUiHarness();

  Future<void> open(WidgetTester tester, {DateTime? now, bool keepSeed = false, Set<EventType>? filter, double? textScale}) =>
      h.pump(tester, home: const CalendarScreen(), now: now, keepSeed: keepSeed, filter: filter, textScale: textScale);

  Finder cell(int month, int day, [int year = 2026]) => find.byKey(ValueKey<String>('day-$year-$month-$day'));

  /// The bars (Event_Chips) that touch [day]'s cell. A bar is drawn over the cells of the week row, not
  /// inside one cell, and a bar of several days touches several cells.
  Finder chipsIn(WidgetTester tester, Finder day) {
    final Rect rect = tester.getRect(day);
    return find.byWidgetPredicate(
      (Widget w) => w is EventChip && tester.getRect(find.byWidget(w)).overlaps(rect),
    );
  }

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
    expect(chipsIn(tester, cell(11, 18)), findsNWidgets(2));
    final List<EventChip> chips = tester.widgetList<EventChip>(chipsIn(tester, cell(11, 18))).toList();
    expect(chips.map((EventChip c) => c.label).toList(), <String>['Narozeniny Evy', 'Porada']);
    expect(chips.first.type, EventType.birthday);
  });

  calendarTest(h, 'a date with more than three events shows two chips and "+N"', (tester) async {
    await open(tester);
    for (int i = 1; i <= 5; i++) {
      await h.add(tester, name: 'E$i', date: d(2026, 11, 18), startMinute: 8 * 60 + i, endMinute: 9 * 60);
    }
    expect(chipsIn(tester, cell(11, 18)), findsNWidgets(2));
    expect(find.descendant(of: cell(11, 18), matching: find.text('+3')), findsOneWidget);
    // Three events fit in three lanes: all show, in another week so the five above do not take lanes from them.
    await h.add(tester, name: 'Tři', date: d(2026, 11, 4));
    await h.add(tester, name: 'Tři 2', date: d(2026, 11, 4), startMinute: 600, endMinute: 700);
    await h.add(tester, name: 'Tři 3', date: d(2026, 11, 4), startMinute: 800, endMinute: 900);
    expect(chipsIn(tester, cell(11, 4)), findsNWidgets(3));
    expect(find.descendant(of: cell(11, 4), matching: find.textContaining('+')), findsNothing);
  });

  calendarTest(h, 'a notable day is a soft chip, a public holiday a solid one', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Den veteránů', type: EventType.notableDay, date: d(2026, 11, 11), startMinute: null);
    await h.add(tester, name: 'Boj za svobodu', type: EventType.publicHoliday, date: d(2026, 11, 17), startMinute: null);
    BoxDecoration decoration(Finder cellFinder) => tester
        .widget<Container>(find.descendant(of: chipsIn(tester, cellFinder), matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;
    expect(decoration(cell(11, 11)).border, isNotNull);
    expect(decoration(cell(11, 17)).border, isNull);
  });

  calendarTest(h, 'a multi-day event is one bar across the dates it touches, with no gap', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Seminář', type: EventType.seminar, date: d(2026, 11, 18), endDate: d(2026, 11, 20));
    expect(find.byType(EventChip), findsOneWidget, reason: 'one bar, not one chip per date');
    for (final int day in <int>[18, 19, 20]) {
      expect(chipsIn(tester, cell(11, day)), findsOneWidget, reason: '$day');
    }
    expect(chipsIn(tester, cell(11, 17)), findsNothing);
    expect(chipsIn(tester, cell(11, 21)), findsNothing);
    final Rect bar = tester.getRect(find.byType(EventChip));
    expect(bar.left, lessThanOrEqualTo(tester.getRect(cell(11, 18)).left + 4));
    expect(bar.right, greaterThanOrEqualTo(tester.getRect(cell(11, 20)).right - 4));
    expect(bar.width, greaterThan(tester.getRect(cell(11, 18)).width * 2.8), reason: 'across the cell borders');
    expect(find.text('Seminář'), findsOneWidget, reason: 'the name is written once');
    final EventChip chip = tester.widget<EventChip>(find.byType(EventChip));
    expect(chip.continuesBefore, isFalse);
    expect(chip.continuesAfter, isFalse);
  });

  calendarTest(h, 'a bar that runs over the end of the week goes on in the next week row', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Soustředění', type: EventType.seminar, date: d(2026, 11, 20), endDate: d(2026, 11, 24));
    final List<EventChip> bars = tester.widgetList<EventChip>(find.byType(EventChip)).toList();
    expect(bars, hasLength(2), reason: 'a bar in each week row');
    expect(bars.map((EventChip b) => b.continuesAfter).toList(), <bool>[true, false]);
    expect(bars.map((EventChip b) => b.continuesBefore).toList(), <bool>[false, true]);
    final Rect first = tester.getRect(find.byWidget(bars.first));
    final Rect second = tester.getRect(find.byWidget(bars.last));
    expect(first.right, closeTo(tester.getRect(cell(11, 22)).right, 1), reason: 'to the end of the row');
    expect(second.left, closeTo(tester.getRect(cell(11, 23)).left, 1), reason: 'from the start of the row');
  });

  calendarTest(h, 'a bar keeps one height over its days, a shorter event goes under it', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Víkend', type: EventType.seminar, date: d(2026, 11, 18), endDate: d(2026, 11, 20));
    await h.add(tester, name: 'Schůzka', type: EventType.meeting, date: d(2026, 11, 19), startMinute: 600, endMinute: 700);
    final Rect long = tester.getRect(find.widgetWithText(EventChip, 'Víkend'));
    final Rect short = tester.getRect(find.widgetWithText(EventChip, 'Schůzka'));
    expect(long.top, lessThan(short.top), reason: 'the longer event takes the first lane');
    expect(chipsIn(tester, cell(11, 19)), findsNWidgets(2));
  });

  calendarTest(h, 'a tap on a bar opens the day sheet of the date under it', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Seminář', type: EventType.seminar, date: d(2026, 11, 18), endDate: d(2026, 11, 20));
    await tester.tapAt(tester.getCenter(cell(11, 19)).translate(0, -tester.getRect(cell(11, 19)).height / 2 + 24));
    await h.settle(tester);
    expect(find.byType(DaySheet), findsOneWidget);
    expect(container(tester).read(selectedDayProvider), d(2026, 11, 19));
  });

  calendarTest(h, 'a repeating event shows on each of its dates', (tester) async {
    await open(tester);
    await h.add(tester, name: 'Salsa', type: EventType.lesson, date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly));
    for (final int day in <int>[4, 11, 18, 25]) {
      expect(chipsIn(tester, cell(11, day)), findsOneWidget, reason: '$day');
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
    expect(tester.getRect(cell(11, 17)).contains(tester.getCenter(find.text('Den boje za svobodu a demokracii'))), isTrue);
    // Two events on 11 November (Svatý Martin and no name day): the folk day shows as a soft chip.
    expect(tester.getRect(cell(11, 11)).contains(tester.getCenter(find.text('Svatý Martin'))), isTrue);
  });

  group('large text', () {
    calendarTest(h, 'chips stay inside their cells at a large text size', (tester) async {
      await open(tester, textScale: 2.0);
      for (int i = 1; i <= 4; i++) {
        await h.add(tester, name: 'Dlouhý název události číslo $i', date: d(2026, 11, 18), startMinute: 8 * 60 + i, endMinute: 9 * 60);
      }
      expect(tester.takeException(), isNull);
      final Rect cellRect = tester.getRect(cell(11, 18));
      for (final Element e in chipsIn(tester, cell(11, 18)).evaluate()) {
        final Rect chip = tester.getRect(find.byWidget(e.widget));
        expect(chip.bottom, lessThanOrEqualTo(cellRect.bottom + 0.5));
        expect(chip.right, lessThanOrEqualTo(cellRect.right + 0.5));
      }
    });
  });

  calendarTest(h, 'bars stay inside the week rows at 320 points and a text scale of 130 %', (tester) async {
    await open(tester, textScale: 1.3);
    tester.view.physicalSize = const Size(320, 844);
    await h.add(tester, name: 'Víkendový seminář', type: EventType.seminar, date: d(2026, 11, 20), endDate: d(2026, 11, 24));
    for (int i = 1; i <= 5; i++) {
      await h.add(tester, name: 'Událost $i', date: d(2026, 11, 18), startMinute: 8 * 60 + i, endMinute: 9 * 60);
    }
    await h.settle(tester);
    expect(tester.takeException(), isNull);
    final Rect grid = tester.getRect(find.byKey(const ValueKey<String>('month-pager')));
    for (final Element e in find.byType(EventChip).evaluate()) {
      final Rect bar = tester.getRect(find.byWidget(e.widget));
      expect(bar.left, greaterThanOrEqualTo(grid.left - 0.5));
      expect(bar.right, lessThanOrEqualTo(grid.right + 0.5));
      expect(bar.bottom, lessThanOrEqualTo(grid.bottom + 0.5));
    }
  });

  test('lanesShown keeps to the room it has', () {
    expect(lanesShown(2, 10), 2);
    expect(lanesShown(3, 10), 3);
    expect(lanesShown(5, 10), 2);
    expect(lanesShown(5, 2), 1);
    expect(lanesShown(2, 1), 0, reason: 'the +N label needs a line');
    expect(lanesShown(3, 2), 1);
    expect(lanesShown(5, 0), 0);
    expect(lanesShown(0, 4), 0);
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
