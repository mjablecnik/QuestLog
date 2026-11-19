import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/notes/note_dates.dart';
import 'package:questlog/core/notes/trash_policy.dart';

void main() {
  final DateTime t = DateTime(2026, 11, 1, 10, 30);

  test('retention is 30 days and expiry is exact', () {
    expect(trashRetention, const Duration(days: 30));
    expect(isExpired(t, t.add(const Duration(days: 30)).subtract(const Duration(minutes: 1))), isFalse);
    expect(isExpired(t, t.add(const Duration(days: 30))), isTrue);
    expect(isExpired(t, t.add(const Duration(days: 31))), isTrue);
  });

  test('days left at the boundaries', () {
    expect(daysUntilPurge(t, t), 30);
    expect(daysUntilPurge(t, t.add(const Duration(minutes: 1))), 30);
    expect(daysUntilPurge(t, t.add(const Duration(days: 1))), 29);
    expect(daysUntilPurge(t, t.add(const Duration(days: 29, hours: 23))), 1);
    expect(daysUntilPurge(t, t.add(const Duration(days: 30))), 0);
    expect(daysUntilPurge(t, t.add(const Duration(days: 31))), 0);
    expect(daysUntilPurge(t, t.subtract(const Duration(days: 2))), 30, reason: 'clock skew stays at 30');
  });

  // Property 7: days until Purge.
  Glados2(any.intInRange(0, 30 * 24 * 60 - 1), any.intInRange(0, 600)).test(
    'between 1 and 30, 30 at deletion, never increasing as time passes',
    (minutes, extra) {
      final DateTime now = t.add(Duration(minutes: minutes));
      final DateTime later = now.add(Duration(minutes: extra));
      final int days = daysUntilPurge(t, now);
      expect(days, inInclusiveRange(1, 30));
      if (!isExpired(t, later)) expect(daysUntilPurge(t, later), lessThanOrEqualTo(days));
    },
  );

  group('noteDateKind', () {
    final DateTime now = DateTime(2026, 11, 19, 0, 5);
    test('today, yesterday, this year, earlier', () {
      expect(noteDateKind(DateTime(2026, 11, 19, 0, 0), now), NoteDateKind.today);
      expect(noteDateKind(DateTime(2026, 11, 19, 23, 59), now), NoteDateKind.today);
      expect(noteDateKind(DateTime(2026, 11, 18, 23, 59), now), NoteDateKind.yesterday);
      expect(noteDateKind(DateTime(2026, 11, 17, 23, 59), now), NoteDateKind.thisYear);
      expect(noteDateKind(DateTime(2026, 1, 1), now), NoteDateKind.thisYear);
      expect(noteDateKind(DateTime(2025, 12, 31, 23, 59), now), NoteDateKind.earlier);
    });
    test('year and month boundaries and a leap day', () {
      expect(noteDateKind(DateTime(2026, 12, 31, 22), DateTime(2027, 1, 1, 1)), NoteDateKind.yesterday);
      expect(noteDateKind(DateTime(2026, 2, 28), DateTime(2026, 3, 1)), NoteDateKind.yesterday);
      expect(noteDateKind(DateTime(2028, 2, 29), DateTime(2028, 3, 1)), NoteDateKind.yesterday);
      expect(noteDateKind(DateTime(2027, 12, 31), DateTime(2027, 12, 31, 23)), NoteDateKind.today);
    });
    test('a future date counts as today', () {
      expect(noteDateKind(DateTime(2026, 11, 20), now), NoteDateKind.today);
    });
  });
}
