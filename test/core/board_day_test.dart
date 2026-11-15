import 'package:glados/glados.dart';
import 'package:questlog/core/board_day.dart';

import '../helpers/generators.dart';

void main() {
  group('boardDayStart / todayOf unit cases', () {
    test('03:59 belongs to the previous day', () {
      final now = DateTime(2026, 3, 10, 3, 59);
      expect(boardDayStart(now), DateTime(2026, 3, 9, 4));
      expect(todayOf(now), DateTime(2026, 3, 9));
    });

    test('04:00 starts the new day', () {
      final now = DateTime(2026, 3, 10, 4);
      expect(boardDayStart(now), DateTime(2026, 3, 10, 4));
      expect(todayOf(now), DateTime(2026, 3, 10));
    });

    test('00:30 belongs to the previous day', () {
      final now = DateTime(2026, 3, 10, 0, 30);
      expect(todayOf(now), DateTime(2026, 3, 9));
    });

    test('crosses month and year boundaries', () {
      expect(todayOf(DateTime(2026, 1, 1, 2)), DateTime(2025, 12, 31));
      expect(todayOf(DateTime(2026, 3, 1, 3)), DateTime(2026, 2, 28));
      expect(todayOf(DateTime(2028, 3, 1, 3)), DateTime(2028, 2, 29));
    });

    test('boardDayStartOf is 04:00 on the given date', () {
      expect(boardDayStartOf(DateTime(2026, 3, 29)), DateTime(2026, 3, 29, 4));
    });

    test('boardDayStartOf spans a DST change in wall-clock terms', () {
      // Europe/Prague changes clocks on 2026-03-29 and 2026-10-25; the window
      // is still 04:00 to the next 04:00 local, whatever its length in hours.
      for (final date in [DateTime(2026, 3, 29), DateTime(2026, 10, 25)]) {
        final start = boardDayStartOf(date);
        final next = boardDayStartOf(DateTime(date.year, date.month, date.day + 1));
        expect(start.hour, 4);
        expect(next.hour, 4);
        expect(next.isAfter(start), isTrue);
        expect(boardDayStart(next.subtract(const Duration(minutes: 1))), start);
        expect(boardDayStart(next), next);
      }
    });
  });

  // Feature: questlog-domain, Property 11: Board_Day boundary is the most recent 04:00
  group('Property 11: Board_Day boundary is the most recent 04:00', () {
    Glados(anyLocalInstant).test('boardDayStart is the latest 04:00 at or before now', (now) {
      final start = boardDayStart(now);
      expect(start.hour, 4);
      expect(start.minute, 0);
      expect(start.isAfter(now), isFalse);
      final next = DateTime(start.year, start.month, start.day + 1, 4);
      expect(next.isAfter(now), isTrue);
    });

    Glados(anyLocalInstant).test('todayOf is the calendar date of the boundary', (now) {
      final start = boardDayStart(now);
      expect(todayOf(now), DateTime(start.year, start.month, start.day));
    });

    Glados(anyLocalInstant).test('boardDayStartOf(todayOf(now)) is boardDayStart(now)', (now) {
      expect(boardDayStartOf(todayOf(now)), boardDayStart(now));
    });
  });
}
