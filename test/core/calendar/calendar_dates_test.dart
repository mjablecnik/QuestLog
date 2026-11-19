import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/calendar/calendar_dates.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';

import '../../helpers/generators.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

void main() {
  group('monthGridDates', () {
    test('November 2026 starts on Monday 26 October and ends on Sunday 6 December', () {
      final List<DateTime> grid = monthGridDates(d(2026, 11, 1));
      expect(grid, hasLength(42));
      expect(grid.first, d(2026, 10, 26));
      expect(grid.last, d(2026, 12, 6));
    });

    test('a month that starts on Monday has no leading days', () {
      expect(monthGridDates(d(2026, 6, 1)).first, d(2026, 6, 1));
    });

    test('a month that starts on Sunday has six leading days', () {
      expect(monthGridDates(d(2026, 2, 1)).first, d(2026, 1, 26));
    });

    test('every month from 2000 to 2100 gives 42 consecutive days starting on Monday', () {
      for (int y = 2000; y <= 2100; y++) {
        for (int m = 1; m <= 12; m++) {
          final List<DateTime> grid = monthGridDates(d(y, m, 1));
          expect(grid.first.weekday, DateTime.monday);
          expect(grid.where((DateTime x) => x.month == m && x.year == y), hasLength(DateTime(y, m + 1, 0).day));
          for (int i = 1; i < 42; i++) {
            expect(grid[i], DateTime(grid[i - 1].year, grid[i - 1].month, grid[i - 1].day + 1));
          }
        }
      }
    });
  });

  test('navigation limits', () {
    expect(isNavigableMonth(d(2000, 1, 1)), isTrue);
    expect(isNavigableMonth(d(2100, 12, 1)), isTrue);
    expect(isNavigableMonth(d(1999, 12, 1)), isFalse);
    expect(isNavigableMonth(d(2101, 1, 1)), isFalse);
  });

  test('coveredDates', () {
    expect(coveredDates(d(2026, 12, 30), 0), <DateTime>[d(2026, 12, 30)]);
    expect(coveredDates(d(2026, 12, 30), 2), <DateTime>[d(2026, 12, 30), d(2026, 12, 31), d(2027, 1, 1)]);
  });

  group('searchKey', () {
    test('removes Czech diacritics and lower-cases', () {
      expect(searchKey('Řehoř Žlutý ŠČĎŤŇ Úterý Ůžasný'), 'rehor zluty scdtn utery uzasny');
    });
    test('keeps other characters', () {
      expect(searchKey('Café 1:1 – Tomáš'), 'cafe 1:1 – tomas');
    });
  });

  // Feature: questlog-calendar, Property 11: A multi-day occurrence touches exactly its dates
  Glados2(anyCalendarDate, any.intInRange(0, 6)).test(
    'Property 11: an occurrence is returned for exactly the dates it covers',
    (DateTime start, int span) {
      final Set<DateTime> covered = coveredDates(start, span).toSet();
      for (int offset = -10; offset <= span + 10; offset++) {
        final DateTime day = DateTime(start.year, start.month, start.day + offset);
        final List<DateTime> found = occurrenceStarts(
          firstStart: start,
          spanDays: span,
          rule: const NoRepeat(),
          from: day,
          to: day,
        ).toList();
        expect(found.isNotEmpty, covered.contains(day), reason: 'offset $offset span $span');
      }
    },
  );

  // Feature: questlog-calendar, Property 12: Search ignores case and diacritics
  Glados(any.intInRange(0, 5)).test(
    'Property 12: a lower-cased, diacritics-free substring of a name is found',
    (int shift) {
      const List<String> names = <String>[
        'Řehoř na schůzce', 'Jmeniny Žofie', 'Úklid bytu', 'Ředitelská porada', 'Čtvrtek večer',
      ];
      final String name = names[shift];
      final String key = searchKey(name);
      final String sub = key.substring(1, key.length - 1);
      expect(searchKey(name).contains(searchKey(sub)), isTrue);
      expect(searchKey(name.toUpperCase()).contains(sub), isTrue);
    },
  );
}
