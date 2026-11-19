import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/data/calendar/calendar_filter_store.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/services/calendar/calendar_providers.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/state/board_day.dart';
import 'package:questlog/ui/state/calendar_state.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 80));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late QuestlogDatabase db;
  late FixedClock clock;
  late MemoryCalendarFilterStore store;

  ProviderContainer container({Set<EventType>? filter}) {
    final ProviderContainer c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
        calendarFilterStoreProvider.overrideWithValue(store),
        initialCalendarFilterProvider.overrideWithValue(filter ?? EventType.values.toSet()),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<CalendarEvent> create(ProviderContainer c, DateTime date, EventType type, {bool onBoard = false, String name = 'E'}) {
    return c.read(calendarServiceProvider).create(
      EventDraft(
        name: name,
        type: type,
        startDate: date,
        endDate: date,
        startMinute: 600,
        endMinute: 660,
        onBoard: onBoard,
      ),
    );
  }

  setUp(() async {
    db = createTestDatabase();
    await db.delete(db.calendarEvents).go();
    clock = FixedClock(d(2026, 11, 19).add(const Duration(hours: 10)));
    store = MemoryCalendarFilterStore();
  });
  tearDown(() => db.close());

  test('the visible month starts on the month of Calendar_Today and refuses months out of range', () {
    final ProviderContainer c = container();
    expect(c.read(visibleMonthProvider), d(2026, 11, 1));
    final VisibleMonthNotifier n = c.read(visibleMonthProvider.notifier);
    n.next();
    expect(c.read(visibleMonthProvider), d(2026, 12, 1));
    n.previous();
    n.previous();
    expect(c.read(visibleMonthProvider), d(2026, 10, 1));
    n.show(d(2000, 1, 15));
    expect(c.read(visibleMonthProvider), d(2000, 1, 1));
    n.previous();
    expect(c.read(visibleMonthProvider), d(2000, 1, 1));
    n.show(d(2100, 12, 1));
    n.next();
    expect(c.read(visibleMonthProvider), d(2100, 12, 1));
    n.goToToday();
    expect(c.read(visibleMonthProvider), d(2026, 11, 1));
  });

  test('the selected day starts on Calendar_Today', () {
    final ProviderContainer c = container();
    expect(c.read(selectedDayProvider), d(2026, 11, 19));
    c.read(selectedDayProvider.notifier).select(DateTime(2026, 12, 3, 14, 30));
    expect(c.read(selectedDayProvider), d(2026, 12, 3));
  });

  test('Calendar_Today changes at local midnight, the Board_Day at 04:00', () {
    clock.set(DateTime(2026, 11, 19, 23, 59));
    final ProviderContainer c = container();
    expect(c.read(calendarTodayProvider), d(2026, 11, 19));
    expect(c.read(boardDayProvider), d(2026, 11, 19));
    expect(CalendarTodayNotifier.untilMidnight(DateTime(2026, 11, 19, 23, 59)), const Duration(minutes: 1));

    clock.set(DateTime(2026, 11, 20, 0, 0));
    c.read(calendarTodayProvider.notifier).didChangeAppLifecycleState(AppLifecycleState.resumed);
    c.read(boardDayProvider.notifier).didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(c.read(calendarTodayProvider), d(2026, 11, 20));
    expect(c.read(boardDayProvider), d(2026, 11, 19));

    clock.set(DateTime(2026, 11, 20, 3, 59));
    c.read(boardDayProvider.notifier).didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(c.read(boardDayProvider), d(2026, 11, 19));

    clock.set(DateTime(2026, 11, 20, 4, 0));
    c.read(boardDayProvider.notifier).didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(c.read(boardDayProvider), d(2026, 11, 20));
  });

  test('an event of a date becomes an Event_Task only from 04:00 of that date', () async {
    clock.set(DateTime(2026, 11, 20, 3, 30));
    final ProviderContainer c = container();
    c.listen(eventTasksProvider, (_, _) {});
    await create(c, d(2026, 11, 20), EventType.birthday, onBoard: true);
    await settle();
    expect(c.read(eventTasksProvider).value, isEmpty);

    clock.set(DateTime(2026, 11, 20, 4, 0));
    c.read(boardDayProvider.notifier).didChangeAppLifecycleState(AppLifecycleState.resumed);
    await settle();
    expect(c.read(eventTasksProvider).value, hasLength(1));
  });

  test('the Type_Filter is restored from the store and filters month and day, not tasks or search', () async {
    store.value = <EventType>{EventType.dance};
    final ProviderContainer c = container(filter: await store.load());
    expect(c.read(typeFilterProvider), <EventType>{EventType.dance});
    expect(c.read(typeFilterActiveProvider), isTrue);

    final DateTime month = d(2026, 11, 1);
    c.listen(monthOccurrencesProvider(month), (_, _) {});
    c.listen(dayOccurrencesProvider(d(2026, 11, 19)), (_, _) {});
    c.listen(eventTasksProvider, (_, _) {});
    await create(c, d(2026, 11, 19), EventType.dance, name: 'Tanec');
    await create(c, d(2026, 11, 19), EventType.work, name: 'Práce', onBoard: true);
    await settle();

    expect(c.read(monthOccurrencesProvider(month)).value!.map((o) => o.event.name), <String>['Tanec']);
    expect(c.read(dayOccurrencesProvider(d(2026, 11, 19))).value!.map((o) => o.event.name), <String>['Tanec']);
    expect(c.read(eventTasksProvider).value!.map((o) => o.event.name), <String>['Práce']);
    expect((await c.read(calendarServiceProvider).search('prace')).single.event.name, 'Práce');

    await c.read(typeFilterProvider.notifier).showAll();
    await settle();
    expect(c.read(typeFilterActiveProvider), isFalse);
    expect(c.read(monthOccurrencesProvider(month)).value, hasLength(2));
    expect(store.value, EventType.values.toSet());
  });

  test('toggling a type saves the filter', () async {
    final ProviderContainer c = container();
    await c.read(typeFilterProvider.notifier).toggle(EventType.work);
    expect(c.read(typeFilterProvider), isNot(contains(EventType.work)));
    expect(store.value, isNot(contains(EventType.work)));
    await c.read(typeFilterProvider.notifier).toggle(EventType.work);
    expect(c.read(typeFilterProvider), contains(EventType.work));
  });

  test('the month provider covers the six-week grid', () async {
    final ProviderContainer c = container();
    c.listen(monthOccurrencesProvider(d(2026, 11, 1)), (_, _) {});
    await create(c, d(2026, 10, 27), EventType.dance, name: 'Zouk');
    await create(c, d(2026, 12, 6), EventType.dance, name: 'Konec');
    await create(c, d(2026, 12, 7), EventType.dance, name: 'Mimo');
    await settle();
    expect(c.read(monthOccurrencesProvider(d(2026, 11, 1))).value!.map((o) => o.event.name), <String>['Zouk', 'Konec']);
  });
}
