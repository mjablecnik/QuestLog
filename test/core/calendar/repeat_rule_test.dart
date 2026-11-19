import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/calendar/calendar_dates.dart';
import 'package:questlog/core/calendar/easter.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';

import '../../helpers/generators.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

List<DateTime> starts(
  DateTime first,
  RepeatRule rule,
  DateTime from,
  DateTime to, {
  int span = 0,
  Set<DateTime> skipped = const <DateTime>{},
}) => occurrenceStarts(
  firstStart: first,
  spanDays: span,
  rule: rule,
  skipped: skipped,
  from: from,
  to: to,
).toList();

void main() {
  test('EventType keys round trip and unknown keys read as meeting', () {
    for (final EventType type in EventType.values) {
      expect(EventType.fromKey(type.key), type);
    }
    expect(EventType.fromKey('party'), EventType.meeting);
    expect(EventType.publicHoliday.onBoardByDefault, isFalse);
    expect(EventType.notableDay.onBoardByDefault, isFalse);
    expect(EventType.nameDay.onBoardByDefault, isTrue);
    expect(EventType.notableDay.isSoft, isTrue);
    expect(EventType.publicHoliday.isSoft, isFalse);
  });

  group('no repeat', () {
    test('one occurrence, only when it touches the range', () {
      expect(starts(d(2026, 11, 18), const NoRepeat(), d(2026, 11, 1), d(2026, 11, 30)), <DateTime>[d(2026, 11, 18)]);
      expect(starts(d(2026, 11, 18), const NoRepeat(), d(2026, 11, 19), d(2026, 11, 30)), isEmpty);
    });
    test('a multi-day occurrence touches a range after its start', () {
      expect(starts(d(2026, 11, 18), const NoRepeat(), d(2026, 11, 20), d(2026, 11, 21), span: 2), <DateTime>[d(2026, 11, 18)]);
      expect(starts(d(2026, 11, 18), const NoRepeat(), d(2026, 11, 21), d(2026, 11, 21), span: 2), isEmpty);
    });
  });

  group('cadence', () {
    test('weekly on the weekday of the start', () {
      expect(
        starts(d(2026, 11, 4), const CadenceRepeat(Cadence.weekly), d(2026, 11, 1), d(2026, 11, 30)),
        <DateTime>[d(2026, 11, 4), d(2026, 11, 11), d(2026, 11, 18), d(2026, 11, 25)],
      );
    });
    test('a range long after the start only iterates over the range', () {
      expect(
        starts(d(2000, 1, 3), const CadenceRepeat(Cadence.weekly), d(2090, 1, 1), d(2090, 1, 31)).length,
        inInclusiveRange(4, 5),
      );
    });
    test('monthly clamps to the last day of a short month', () {
      expect(
        starts(d(2026, 1, 31), const CadenceRepeat(Cadence.monthly), d(2026, 2, 1), d(2026, 4, 30)),
        <DateTime>[d(2026, 2, 28), d(2026, 3, 31), d(2026, 4, 30)],
      );
    });
    test('yearly 29 February falls on 28 February in a common year', () {
      expect(
        starts(d(2028, 2, 29), const CadenceRepeat(Cadence.yearly), d(2028, 1, 1), d(2032, 12, 31)),
        <DateTime>[d(2028, 2, 29), d(2029, 2, 28), d(2030, 2, 28), d(2031, 2, 28), d(2032, 2, 29)],
      );
    });
    test('the repeat end is inclusive and skipped dates are left out', () {
      expect(
        starts(
          d(2026, 11, 4),
          CadenceRepeat(Cadence.weekly, end: d(2026, 11, 18)),
          d(2026, 11, 1),
          d(2026, 12, 31),
          skipped: <DateTime>{d(2026, 11, 11)},
        ),
        <DateTime>[d(2026, 11, 4), d(2026, 11, 18)],
      );
    });
    test('a series never starts before its first start', () {
      expect(starts(d(2026, 11, 4), const CadenceRepeat(Cadence.daily), d(2026, 10, 1), d(2026, 11, 5)),
          <DateTime>[d(2026, 11, 4), d(2026, 11, 5)]);
    });
  });

  group('built-in rules', () {
    test('Easter relative in 2026', () {
      final List<DateTime> friday = starts(d(2016, 1, 1), const EasterRelative(-2), d(2026, 1, 1), d(2026, 12, 31));
      final List<DateTime> monday = starts(d(2000, 1, 1), const EasterRelative(1), d(2026, 1, 1), d(2026, 12, 31));
      expect(friday, <DateTime>[d(2026, 4, 3)]);
      expect(monday, <DateTime>[d(2026, 4, 6)]);
    });
    test('Velký pátek is absent before its first year', () {
      expect(starts(d(2016, 1, 1), const EasterRelative(-2), d(2015, 1, 1), d(2015, 12, 31)), isEmpty);
    });
    test('n-th weekday in 2026', () {
      expect(starts(d(2000, 1, 1), const NthWeekday(month: 5, weekday: DateTime.sunday, ordinal: 2), d(2026, 1, 1), d(2026, 12, 31)),
          <DateTime>[d(2026, 5, 10)]);
      expect(starts(d(2000, 1, 1), const NthWeekday(month: 6, weekday: DateTime.sunday, ordinal: 3), d(2026, 1, 1), d(2026, 12, 31)),
          <DateTime>[d(2026, 6, 21)]);
    });
  });

  // Feature: questlog-calendar, Property 1: Occurrences stay inside their bounds
  Glados3(anyCalendarDate, any.intInRange(0, 4), any.intInRange(0, 4)).test(
    'Property 1: occurrences stay inside their bounds',
    (DateTime first, int cadenceIndex, int span) {
      final Cadence cadence = <Cadence>[Cadence.daily, Cadence.weekly, Cadence.monthly, Cadence.yearly][cadenceIndex];
      final DateTime end = DateTime(first.year, first.month, first.day + 400);
      final RepeatRule rule = CadenceRepeat(cadence, end: end);
      final DateTime from = DateTime(first.year, first.month, first.day + 30);
      final DateTime to = DateTime(first.year, first.month, first.day + 900);
      final DateTime skip = DateTime(first.year, first.month, first.day + 60);
      final List<DateTime> found = starts(first, rule, from, to, span: span, skipped: <DateTime>{skip});
      DateTime? previous;
      for (final DateTime s in found) {
        expect(s.isBefore(first), isFalse);
        expect(s.isAfter(end), isFalse);
        expect(s, isNot(skip));
        expect(s.isAfter(to), isFalse);
        expect(DateTime(s.year, s.month, s.day + span).isBefore(from), isFalse);
        if (previous != null) expect(s.isAfter(previous), isTrue);
        previous = s;
      }
    },
  );

  // Feature: questlog-calendar, Property 2: Monthly and yearly clamping never drifts
  Glados2(anyCalendarDate, any.intInRange(0, 60)).test(
    'Property 2: monthly keeps the day of month or the last day of a shorter month',
    (DateTime first, int k) {
      final DateTime day = occurrenceDate(first, Cadence.monthly, k);
      final int lastDay = DateTime(day.year, day.month + 1, 0).day;
      expect(day.day, first.day < lastDay ? first.day : lastDay);
    },
  );

  Glados(any.intInRange(2000, 2090)).test(
    'Property 2: yearly 29 February is 28 February in a common year and 29 in a leap year',
    (int year) {
      final DateTime anchor = d(2000, 2, 29);
      final DateTime day = occurrenceDate(anchor, Cadence.yearly, year - 2000);
      final bool leap = DateTime(year, 3, 0).day == 29;
      expect(day, d(year, 2, leap ? 29 : 28));
    },
  );

  // Feature: questlog-calendar, Property 3: Every occurrence keeps the first duration
  Glados2(anyCalendarDate, any.intInRange(0, 5)).test(
    'Property 3: every occurrence covers the same number of days',
    (DateTime first, int span) {
      final List<DateTime> found = starts(
        first,
        const CadenceRepeat(Cadence.weekly),
        first,
        DateTime(first.year, first.month, first.day + 200),
        span: span,
      );
      for (final DateTime s in found) {
        expect(coveredDates(s, span), hasLength(span + 1));
      }
      expect(found, isNotEmpty);
    },
  );

  test('Easter-relative dates agree with easterSunday', () {
    for (int year = 2000; year <= 2100; year++) {
      final DateTime easter = easterSunday(year);
      final List<DateTime> found = starts(d(2000, 1, 1), const EasterRelative(0), d(year, 1, 1), d(year, 12, 31));
      expect(found, <DateTime>[easter]);
    }
  });
}
