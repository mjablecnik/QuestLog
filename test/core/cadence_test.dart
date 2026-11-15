import 'package:glados/glados.dart';
import 'package:questlog/core/cadence.dart';

import '../helpers/generators.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

void main() {
  group('occurrenceDate unit cases', () {
    test('Monthly anchor Jan 31 yields Feb 28/29, Mar 31', () {
      expect(occurrenceDate(d(2026, 1, 31), Cadence.monthly, 1), d(2026, 2, 28));
      expect(occurrenceDate(d(2028, 1, 31), Cadence.monthly, 1), d(2028, 2, 29));
      expect(occurrenceDate(d(2026, 1, 31), Cadence.monthly, 2), d(2026, 3, 31));
      expect(occurrenceDate(d(2026, 1, 31), Cadence.monthly, 3), d(2026, 4, 30));
    });

    test('Yearly anchor Feb 29 yields Feb 28 in non-leap years', () {
      expect(occurrenceDate(d(2028, 2, 29), Cadence.yearly, 1), d(2029, 2, 28));
      expect(occurrenceDate(d(2028, 2, 29), Cadence.yearly, 4), d(2032, 2, 29));
    });

    test('Biweekly steps 14 days, Weekly 7, Daily 1', () {
      expect(occurrenceDate(d(2026, 2, 20), Cadence.biweekly, 1), d(2026, 3, 6));
      expect(occurrenceDate(d(2026, 2, 20), Cadence.weekly, 2), d(2026, 3, 6));
      expect(occurrenceDate(d(2026, 2, 27), Cadence.daily, 3), d(2026, 3, 2));
    });

    test('Quarterly steps three months, index 0 is the anchor', () {
      expect(occurrenceDate(d(2026, 11, 30), Cadence.quarterly, 1), d(2027, 2, 28));
      expect(occurrenceDate(d(2026, 5, 17), Cadence.monthly, 0), d(2026, 5, 17));
    });

    test('ignores the time part of the anchor', () {
      expect(
        occurrenceDate(DateTime(2026, 1, 1, 17, 30), Cadence.daily, 1),
        d(2026, 1, 2),
      );
    });

    test('negative index is rejected', () {
      expect(() => occurrenceDate(d(2026, 1, 1), Cadence.daily, -1), throwsArgumentError);
    });
  });

  group('firstIndexAfter', () {
    test('returns 0 when the anchor is already after the date', () {
      expect(firstIndexAfter(d(2026, 3, 1), Cadence.monthly, d(2026, 2, 28)), 0);
    });

    test('is strict: an Occurrence on the date itself does not count', () {
      expect(firstIndexAfter(d(2026, 3, 1), Cadence.monthly, d(2026, 3, 1)), 1);
      expect(firstIndexAfter(d(2026, 3, 1), Cadence.monthly, d(2026, 3, 31)), 1);
      expect(firstIndexAfter(d(2026, 3, 1), Cadence.monthly, d(2026, 4, 1)), 2);
    });

    test('works over long gaps', () {
      expect(firstIndexAfter(d(2020, 1, 1), Cadence.daily, d(2026, 1, 1)), 2193);
    });
  });

  group('firstAnchor', () {
    test('keeps a requested anchor that is today or later', () {
      expect(
        firstAnchor(Cadence.monthly, d(2026, 12, 1), today: d(2026, 11, 15)),
        d(2026, 12, 1),
      );
      expect(
        firstAnchor(Cadence.monthly, d(2026, 11, 15), today: d(2026, 11, 15)),
        d(2026, 11, 15),
      );
    });

    test('moves a past anchor to the next Occurrence on or after today', () {
      expect(
        firstAnchor(Cadence.monthly, d(2026, 11, 1), today: d(2026, 11, 15)),
        d(2026, 12, 1),
      );
      expect(
        firstAnchor(Cadence.weekly, d(2026, 11, 2), today: d(2026, 11, 15)),
        d(2026, 11, 16),
      );
    });

    test('is strictly after the last posting', () {
      expect(
        firstAnchor(
          Cadence.daily,
          d(2026, 11, 1),
          today: d(2026, 11, 15),
          lastPosted: d(2026, 11, 15),
        ),
        d(2026, 11, 16),
      );
      expect(
        firstAnchor(
          Cadence.monthly,
          d(2026, 11, 1),
          today: d(2026, 11, 15),
          lastPosted: d(2026, 12, 1),
        ),
        d(2027, 1, 1),
      );
    });
  });

  final anyCadence = any.choose(Cadence.values);

  // Feature: questlog-domain, Property 7: Occurrences are strictly increasing and computed from the anchor
  group('Property 7: Occurrences are strictly increasing and computed from the anchor', () {
    Glados3(anyCalendarDate, anyCadence, any.intInRange(0, 200)).test('occurrence j is before occurrence k for j < k', (
      anchor,
      cadence,
      j,
    ) {
      for (final step in [1, 2, 7, 53]) {
        expect(
          occurrenceDate(anchor, cadence, j).isBefore(occurrenceDate(anchor, cadence, j + step)),
          isTrue,
        );
      }
    });

    Glados2(anyCalendarDate, any.intInRange(0, 600)).test('month-based results are the anchor day clamped to the month length', (
      anchor,
      k,
    ) {
      for (final (cadence, months) in [
        (Cadence.monthly, k),
        (Cadence.quarterly, 3 * k),
        (Cadence.yearly, 12 * k),
      ]) {
        final result = occurrenceDate(anchor, cadence, k);
        final total = anchor.year * 12 + (anchor.month - 1) + months;
        final year = total ~/ 12;
        final month = total % 12 + 1;
        expect(result.year, year);
        expect(result.month, month);
        final length = daysInMonth(year, month);
        expect(result.day, anchor.day < length ? anchor.day : length);
      }
    });

    Glados2(anyCalendarDate, any.intInRange(0, 500)).test('day-based results are exact multiples of the period', (anchor, k) {
      for (final (cadence, days) in [
        (Cadence.daily, 1),
        (Cadence.weekly, 7),
        (Cadence.biweekly, 14),
      ]) {
        expect(occurrenceDate(anchor, cadence, k), DateTime(anchor.year, anchor.month, anchor.day + days * k));
      }
    });

    Glados3(anyCalendarDate, anyCadence, any.intInRange(0, 3000)).test('firstIndexAfter is the smallest index strictly after the date', (
      anchor,
      cadence,
      offset,
    ) {
      final date = DateTime(anchor.year, anchor.month, anchor.day + offset - 100);
      final k = firstIndexAfter(anchor, cadence, date);
      expect(occurrenceDate(anchor, cadence, k).isAfter(date), isTrue);
      if (k > 0) {
        expect(occurrenceDate(anchor, cadence, k - 1).isAfter(date), isFalse);
      }
    });

    Glados3(anyCalendarDate, anyCadence, any.intInRange(0, 800)).test('firstAnchor is on or after today and after the last posting', (
      requested,
      cadence,
      offset,
    ) {
      final today = DateTime(requested.year, requested.month, requested.day + offset - 200);
      final lastPosted = DateTime(today.year, today.month, today.day - 3 + offset % 7);
      final anchor = firstAnchor(cadence, requested, today: today, lastPosted: lastPosted);
      expect(anchor.isBefore(today), isFalse);
      expect(anchor.isAfter(lastPosted), isTrue);
    });
  });
}
