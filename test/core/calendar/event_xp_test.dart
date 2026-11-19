import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/event_xp.dart';

int timed(int minutes, [EventType type = EventType.meeting]) =>
    eventXp(type: type, allDay: false, duration: Duration(minutes: minutes));

void main() {
  test('timed events by duration, at the boundaries', () {
    expect(timed(0), 10);
    expect(timed(30), 10);
    expect(timed(31), 25);
    expect(timed(120), 25);
    expect(timed(121), 50);
    expect(timed(300), 50);
    expect(timed(301), 100);
    expect(timed(60 * 24 + 5), 100);
  });

  test('the type does not matter for a timed event', () {
    for (final EventType type in EventType.values) {
      expect(timed(90, type), 25);
    }
  });

  test('all-day events by type', () {
    for (final EventType type in <EventType>[
      EventType.birthday,
      EventType.nameDay,
      EventType.publicHoliday,
      EventType.notableDay,
      EventType.date,
    ]) {
      expect(eventXp(type: type, allDay: true, duration: Duration.zero), 10, reason: type.key);
    }
    for (final EventType type in <EventType>[
      EventType.dance,
      EventType.work,
      EventType.meeting,
      EventType.seminar,
      EventType.lesson,
    ]) {
      expect(eventXp(type: type, allDay: true, duration: Duration.zero), 25, reason: type.key);
    }
  });

  test('an all-day event ignores its duration', () {
    expect(
      eventXp(type: EventType.birthday, allDay: true, duration: const Duration(days: 3)),
      10,
    );
  });

  // Feature: questlog-calendar, Property 6: Event_XP is always a Difficulty value
  Glados3(any.intInRange(0, EventType.values.length), any.bool, any.intInRange(0, 3000)).test(
    'Property 6: result is 10, 25, 50 or 100',
    (int typeIndex, bool allDay, int minutes) {
      final int xp = eventXp(
        type: EventType.values[typeIndex],
        allDay: allDay,
        duration: Duration(minutes: minutes),
      );
      expect(<int>[10, 25, 50, 100], contains(xp));
    },
  );

  Glados2(any.intInRange(0, 3000), any.intInRange(0, 3000)).test(
    'Property 6: a timed event is never worth less when it is longer',
    (int a, int b) {
      final int shorter = a < b ? a : b;
      final int longer = a < b ? b : a;
      expect(timed(longer), greaterThanOrEqualTo(timed(shorter)));
    },
  );
}
