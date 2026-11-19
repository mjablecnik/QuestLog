import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/easter.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

void main() {
  group('easterSunday known dates', () {
    const Map<int, List<int>> known = <int, List<int>>{
      2000: <int>[4, 23],
      2008: <int>[3, 23],
      2019: <int>[4, 21],
      2024: <int>[3, 31],
      2025: <int>[4, 20],
      2026: <int>[4, 5],
      2027: <int>[3, 28],
      2038: <int>[4, 25],
      2100: <int>[3, 28],
    };
    known.forEach((int year, List<int> md) {
      test('$year', () => expect(easterSunday(year), d(year, md[0], md[1])));
    });
  });

  test('Velký pátek and Velikonoční pondělí fall on 3 and 6 April 2026', () {
    final DateTime easter = easterSunday(2026);
    expect(d(easter.year, easter.month, easter.day - 2), d(2026, 4, 3));
    expect(d(easter.year, easter.month, easter.day + 1), d(2026, 4, 6));
  });

  test('nth weekday known dates 2026', () {
    expect(nthWeekdayOfMonth(2026, 5, DateTime.sunday, 2), d(2026, 5, 10));
    expect(nthWeekdayOfMonth(2026, 6, DateTime.sunday, 3), d(2026, 6, 21));
    expect(nthWeekdayOfMonth(2026, 11, DateTime.monday, 1), d(2026, 11, 2));
  });

  test('a missing fifth weekday and bad arguments are rejected', () {
    expect(() => nthWeekdayOfMonth(2026, 2, DateTime.monday, 5), throwsArgumentError);
    expect(() => nthWeekdayOfMonth(2026, 13, DateTime.monday, 1), throwsArgumentError);
    expect(() => nthWeekdayOfMonth(2026, 2, 8, 1), throwsArgumentError);
    expect(() => nthWeekdayOfMonth(2026, 2, 1, 0), throwsArgumentError);
  });

  // Feature: questlog-calendar, Property 4: Easter-relative days are consistent with Easter Sunday
  Glados(any.intInRange(2000, 2101)).test('Property 4: Easter is a Sunday between 22 March and 25 April', (int year) {
    final DateTime easter = easterSunday(year);
    expect(easter.weekday, DateTime.sunday);
    expect(!easter.isBefore(d(year, 3, 22)) && !easter.isAfter(d(year, 4, 25)), isTrue);
    final DateTime friday = d(year, easter.month, easter.day - 2);
    final DateTime monday = d(year, easter.month, easter.day + 1);
    expect(friday.weekday, DateTime.friday);
    expect(monday.weekday, DateTime.monday);
  });

  // Feature: questlog-calendar, Property 5: The n-th weekday is the right weekday of the right month
  Glados3(any.intInRange(2000, 2101), any.intInRange(1, 13), any.intInRange(1, 8)).test(
    'Property 5: n-th weekday is in the month, on the weekday, in the ordinal range',
    (int year, int month, int weekday) {
      for (int ordinal = 1; ordinal <= 4; ordinal++) {
        final DateTime day = nthWeekdayOfMonth(year, month, weekday, ordinal);
        expect(day.month, month);
        expect(day.weekday, weekday);
        expect(day.day, inInclusiveRange((ordinal - 1) * 7 + 1, ordinal * 7));
      }
    },
  );
}
