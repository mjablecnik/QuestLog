import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/services/calendar/calendar_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

/// A calendar service over an in-memory database with the built-in events
/// removed, so a test sees only the events it creates (pass `keepSeed: true`
/// to keep them).
class CalendarHarness {
  CalendarHarness._(this.db, this.xp, this.clock, this.service);

  final QuestlogDatabase db;
  final XpEngine xp;
  final FixedClock clock;
  final CalendarService service;

  static Future<CalendarHarness> open({
    DateTime? now,
    bool keepSeed = false,
  }) async {
    final QuestlogDatabase db = createTestDatabase();
    if (!keepSeed) await db.delete(db.calendarEvents).go();
    final XpEngine xp = XpEngine(db);
    final FixedClock clock = FixedClock(now ?? DateTime(2026, 11, 19, 10));
    return CalendarHarness._(db, xp, clock, CalendarService(db, xp, clock));
  }

  Future<void> close() => db.close();

  /// A timed one-hour event on [date] at 18:00 unless told otherwise.
  EventDraft draft({
    String name = 'Event',
    EventType type = EventType.meeting,
    DateTime? date,
    DateTime? endDate,
    int? startMinute = 18 * 60,
    int? endMinute = 19 * 60,
    RepeatRule repeat = const NoRepeat(),
    bool onBoard = false,
    String? note,
    String? location,
  }) {
    final DateTime day = date ?? d(2026, 11, 19);
    return EventDraft(
      name: name,
      note: note,
      location: location,
      type: type,
      startDate: day,
      endDate: endDate ?? day,
      startMinute: startMinute,
      endMinute: startMinute == null ? null : endMinute,
      repeat: repeat,
      onBoard: onBoard,
    );
  }

  Future<List<EventOccurrence>> range(DateTime from, DateTime to) => service.occurrencesIn(from, to);
}
