import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calendar/calendar_dates.dart';
import '../../core/calendar/event_type.dart';
import '../../data/calendar/calendar_models.dart';
import '../../services/calendar/calendar_providers.dart';
import '../../services/providers.dart';
import 'board_day.dart';

DateTime _dateOnly(DateTime v) => DateTime(v.year, v.month, v.day);

/// Calendar_Today: the calendar date of the Clock. Unlike the Board_Day it
/// changes at local midnight, not at Day_Start.
final calendarTodayProvider = NotifierProvider<CalendarTodayNotifier, DateTime>(
  CalendarTodayNotifier.new,
);

class CalendarTodayNotifier extends Notifier<DateTime> with WidgetsBindingObserver {
  Timer? _timer;

  /// Duration from [now] to the next local midnight (always positive, DST-safe).
  static Duration untilMidnight(DateTime now) =>
      DateTime(now.year, now.month, now.day + 1).difference(now);

  @override
  DateTime build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _cancel();
    });
    _schedule();
    return _dateOnly(ref.read(clockProvider).now());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _refresh();
      case AppLifecycleState.inactive ||
            AppLifecycleState.hidden ||
            AppLifecycleState.paused ||
            AppLifecycleState.detached:
        _cancel();
    }
  }

  void _refresh() {
    final DateTime today = _dateOnly(ref.read(clockProvider).now());
    if (today != state) state = today;
    _schedule();
  }

  void _schedule() {
    _cancel();
    _timer = Timer(untilMidnight(ref.read(clockProvider).now()), _refresh);
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

/// The month the Month_View shows (first day of the month).
final visibleMonthProvider = NotifierProvider<VisibleMonthNotifier, DateTime>(
  VisibleMonthNotifier.new,
);

class VisibleMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final DateTime today = ref.read(calendarTodayProvider);
    return DateTime(today.year, today.month);
  }

  /// Shows [month] when the calendar can show it, and ignores it otherwise.
  void show(DateTime month) {
    final DateTime first = DateTime(month.year, month.month);
    if (isNavigableMonth(first)) state = first;
  }

  void next() => show(DateTime(state.year, state.month + 1));

  void previous() => show(DateTime(state.year, state.month - 1));

  void goToToday() => show(ref.read(calendarTodayProvider));
}

/// The date last tapped in the Month_View, or Calendar_Today before any tap.
final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime>(
  SelectedDayNotifier.new,
);

class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => ref.read(calendarTodayProvider);

  void select(DateTime day) => state = _dateOnly(day);
}

/// The Event_Types shown in the Month_View and the Day_Sheet (Type_Filter).
final typeFilterProvider = NotifierProvider<TypeFilterNotifier, Set<EventType>>(
  TypeFilterNotifier.new,
);

class TypeFilterNotifier extends Notifier<Set<EventType>> {
  @override
  Set<EventType> build() => ref.read(initialCalendarFilterProvider);

  Future<void> toggle(EventType type) {
    final Set<EventType> next = Set<EventType>.of(state);
    if (!next.remove(type)) next.add(type);
    return _set(next);
  }

  Future<void> showAll() => _set(EventType.values.toSet());

  Future<void> _set(Set<EventType> next) async {
    state = next;
    await ref.read(calendarFilterStoreProvider).save(next);
  }
}

/// Whether the filter hides at least one type.
final typeFilterActiveProvider = Provider<bool>(
  (ref) => ref.watch(typeFilterProvider).length < EventType.values.length,
);

List<EventOccurrence> _filtered(List<EventOccurrence> all, Set<EventType> shown) =>
    all.where((EventOccurrence o) => shown.contains(o.event.type)).toList();

/// The occurrences of the six-week grid of a month, with the Type_Filter applied.
final monthOccurrencesProvider = StreamProvider.family<List<EventOccurrence>, DateTime>((
  ref,
  DateTime month,
) {
  final Set<EventType> shown = ref.watch(typeFilterProvider);
  final List<DateTime> grid = monthGridDates(month);
  return ref
      .watch(calendarServiceProvider)
      .watchRange(grid.first, grid.last)
      .map((List<EventOccurrence> all) => _filtered(all, shown));
});

/// The occurrences that touch a date, with the Type_Filter applied.
final dayOccurrencesProvider = StreamProvider.family<List<EventOccurrence>, DateTime>((
  ref,
  DateTime day,
) {
  final Set<EventType> shown = ref.watch(typeFilterProvider);
  return ref
      .watch(calendarServiceProvider)
      .watchRange(day, day)
      .map((List<EventOccurrence> all) => _filtered(all, shown));
});

/// The Event_Tasks of the current Board_Day. The Type_Filter does not apply.
final eventTasksProvider = StreamProvider<List<EventOccurrence>>((ref) {
  final DateTime today = ref.watch(boardDayProvider);
  return ref.watch(calendarServiceProvider).watchEventTasks(today);
});

/// One stored event, to follow it on its detail screen and in its form.
final eventProvider = StreamProvider.family<CalendarEvent?, int>(
  (ref, int id) => ref.watch(calendarServiceProvider).watchEvent(id),
);

/// One occurrence (an event and the date it starts on) with its completion;
/// null once the event or that occurrence is gone. The Type_Filter does not apply.
final occurrenceProvider = StreamProvider.family<EventOccurrence?, (int, DateTime)>((
  ref,
  (int, DateTime) key,
) {
  final (int id, DateTime date) = key;
  return ref.watch(calendarServiceProvider).watchRange(date, date).map(
    (List<EventOccurrence> all) {
      for (final EventOccurrence o in all) {
        if (o.event.id == id && o.start == date) return o;
      }
      return null;
    },
  );
});
