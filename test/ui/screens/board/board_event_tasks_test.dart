import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/calendar/calendar_providers.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/board/board_screen.dart';
import 'package:questlog/ui/screens/calendar/event_detail_screen.dart';
import 'package:questlog/ui/state/board_day.dart';
import 'package:questlog/ui/widgets/calendar/event_task_card.dart';

import '../../../helpers/seed.dart';
import '_board_harness.dart';

void main() {
  final BoardHarness h = BoardHarness();
  final AppLocalizationsEn en = AppLocalizationsEn();

  Future<CalendarEvent> addEvent(
    WidgetTester tester, {
    String name = 'Event',
    EventType type = EventType.meeting,
    DateTime? date,
    int? startMinute = 18 * 60,
    int? endMinute = 19 * 60,
    bool onBoard = true,
  }) async {
    final DateTime day = date ?? DateTime(2026, 11, 15);
    final CalendarEvent? e = await tester.runAsync(
      () => ProviderScope.containerOf(tester.element(find.byType(BoardScreen))).read(calendarServiceProvider).create(
        EventDraft(
          name: name,
          type: type,
          startDate: day,
          endDate: day,
          startMinute: startMinute,
          endMinute: startMinute == null ? null : endMinute,
          onBoard: onBoard,
        ),
      ),
    );
    await h.settle(tester);
    return e!;
  }

  Finder task(String name) => find.ancestor(of: find.text(name), matching: find.byType(EventTaskCard));

  boardTest(h, 'an On_Board event of the Board_Day shows in Today above the Quests, all-day first', (tester) async {
    await h.pump(tester);
    await tester.runAsync(() => h.db.delete(h.db.calendarEvents).go());
    await h.seed(tester, () async {
      await seedQuest(h.db, name: 'Quest A', difficulty: Difficulty.normal, sortOrder: 1);
    });
    await h.settle(tester);
    await addEvent(tester, name: 'Večerní lekce', startMinute: 20 * 60, endMinute: 21 * 60);
    await addEvent(tester, name: 'Popřát Evě', type: EventType.birthday, startMinute: null);
    await addEvent(tester, name: 'Ranní porada', startMinute: 8 * 60, endMinute: 9 * 60);
    await addEvent(tester, name: 'Nezapnuto', onBoard: false);
    await addEvent(tester, name: 'Zítra', date: DateTime(2026, 11, 16));
    expect(find.byType(EventTaskCard), findsNWidgets(3));
    expect(find.text('Nezapnuto'), findsNothing);
    expect(find.text('Zítra'), findsNothing);
    final List<String> top = h.order(tester, <String>['Popřát Evě', 'Ranní porada', 'Večerní lekce', 'Quest A']);
    expect(top, <String>['Popřát Evě', 'Ranní porada', 'Večerní lekce', 'Quest A']);
  });

  boardTest(h, 'a card shows its type, the time or "All day", the XP and a calendar mark', (tester) async {
    await h.pump(tester);
    await tester.runAsync(() => h.db.delete(h.db.calendarEvents).go());
    await addEvent(tester, name: 'Lekce', type: EventType.lesson, startMinute: 18 * 60, endMinute: 19 * 60);
    await addEvent(tester, name: 'Narozeniny', type: EventType.birthday, startMinute: null);
    expect(find.descendant(of: task('Lekce'), matching: find.text('Lesson')), findsOneWidget);
    expect(find.descendant(of: task('Lekce'), matching: find.text('18:00–19:00')), findsOneWidget);
    expect(find.descendant(of: task('Lekce'), matching: find.text('+25')), findsOneWidget);
    expect(find.descendant(of: task('Narozeniny'), matching: find.text(en.calendar_taskAllDay)), findsOneWidget);
    expect(find.descendant(of: task('Narozeniny'), matching: find.text('+10')), findsOneWidget);
  });

  boardTest(h, 'a board with only an Event_Task is not empty', (tester) async {
    await h.pump(tester);
    await tester.runAsync(() => h.db.delete(h.db.calendarEvents).go());
    expect(find.text('The board is empty'), findsOneWidget);
    await addEvent(tester, name: 'Jediný');
    expect(find.text('The board is empty'), findsNothing);
    expect(find.byType(EventTaskCard), findsOneWidget);
  });

  boardTest(h, 'completing awards the XP, shows the done style and keeps the card; tapping again takes it back', (tester) async {
    await h.pump(tester);
    await tester.runAsync(() => h.db.delete(h.db.calendarEvents).go());
    await addEvent(tester, name: 'Splnit mě');
    final ProviderContainer c = ProviderScope.containerOf(tester.element(find.byType(BoardScreen)));
    c.listen(totalXpProvider, (_, _) {});

    await tester.tap(find.bySemanticsLabel(en.a11y_completeEvent('Splnit mě')));
    await h.settle(tester);
    expect(await tester.runAsync(() => c.read(xpEngineProvider).readTotal()), 25);
    expect(find.bySemanticsLabel(en.a11y_reopenEvent('Splnit mě')), findsOneWidget);
    expect(find.byType(EventTaskCard), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(en.a11y_reopenEvent('Splnit mě')));
    await h.settle(tester);
    expect(await tester.runAsync(() => c.read(xpEngineProvider).readTotal()), 0);
    expect(find.bySemanticsLabel(en.a11y_completeEvent('Splnit mě')), findsOneWidget);
    expect(find.text(en.board_rewardWithdrawn(25)), findsOneWidget);
  });

  boardTest(h, 'a task has no drag handle and no swipe actions', (tester) async {
    await h.pump(tester);
    await tester.runAsync(() => h.db.delete(h.db.calendarEvents).go());
    await addEvent(tester, name: 'Pevná');
    expect(find.descendant(of: task('Pevná'), matching: find.byType(ReorderableDragStartListener)), findsNothing);
    expect(find.ancestor(of: task('Pevná'), matching: find.byType(ReorderableDelayedDragStartListener)), findsNothing);
    await tester.drag(task('Pevná'), const Offset(-300, 0));
    await h.settle(tester);
    expect(find.text(en.common_delete), findsNothing);
  });

  boardTest(h, 'tapping the card outside the check circle opens the event detail', (tester) async {
    await h.pump(tester);
    await tester.runAsync(() => h.db.delete(h.db.calendarEvents).go());
    await addEvent(tester, name: 'Otevři mě');
    await tester.tap(find.text('Otevři mě'));
    await h.settle(tester);
    expect(find.byType(EventDetailScreen), findsOneWidget);
  });

  boardTest(h, 'yesterday\'s task is gone and a seeded name day is a task on its day', (tester) async {
    await h.pump(tester, now: DateTime(2026, 6, 7, 10));
    expect(find.text('Iveta'), findsOneWidget);
    expect(find.byType(EventTaskCard), findsOneWidget);
    final ProviderContainer c = ProviderScope.containerOf(tester.element(find.byType(BoardScreen)));
    h.clock.set(DateTime(2026, 6, 8, 4, 0));
    c.read(boardDayProvider.notifier).didChangeAppLifecycleState(AppLifecycleState.resumed);
    await h.settle(tester);
    expect(find.text('Iveta'), findsNothing);
  });

  boardTest(h, 'public holidays seeded in the database are not tasks', (tester) async {
    await h.pump(tester, now: DateTime(2026, 11, 17, 10));
    expect(find.byType(EventTaskCard), findsNothing);
    expect(find.text('The board is empty'), findsOneWidget);
  });
}
