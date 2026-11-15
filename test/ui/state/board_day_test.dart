import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, test, group, setUp, tearDown, setUpAll, tearDownAll;
import 'package:questlog/core/board_day.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/state/board_day.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/generators.dart';

void main() {
  group('untilNextBoardDay', () {
    // Property 5: Next Board_Day is always in the future and 04:00.
    Glados(anyLocalInstant).test('is positive and lands on the next local 04:00', (now) {
      final d = BoardDayNotifier.untilNextBoardDay(now);
      final next = now.add(d);
      expect(d, greaterThan(Duration.zero));
      expect(next.hour, 4);
      expect(next.minute, 0);
      expect(boardDayStart(next), next);
      final today = todayOf(now);
      expect(todayOf(next), DateTime(today.year, today.month, today.day + 1));
    });

    test('examples', () {
      expect(
        BoardDayNotifier.untilNextBoardDay(DateTime(2026, 11, 15, 3, 59)),
        const Duration(minutes: 1),
      );
      expect(
        BoardDayNotifier.untilNextBoardDay(DateTime(2026, 11, 15, 4)),
        const Duration(hours: 24),
      );
    });
  });

  group('BoardDayNotifier', () {
    late FixedClock clock;
    late ProviderContainer container;

    setUp(() {
      clock = FixedClock(DateTime(2026, 11, 15, 3, 0));
      container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(clock)],
      );
    });

    // The notifier's timer must be gone before the test body ends, so the
    // container is disposed here and not in a tearDown.
    void boardDayTest(
      String name,
      Future<void> Function(WidgetTester tester) body,
    ) {
      testWidgets(name, (tester) async {
        try {
          await body(tester);
        } finally {
          container.dispose();
        }
      });
    }

    void lifecycle(WidgetTester tester, AppLifecycleState s) =>
        tester.binding.handleAppLifecycleStateChanged(s);

    boardDayTest('changes state when the clock passes 04:00', (tester) async {
      final seen = <DateTime>[];
      container.listen(boardDayProvider, (_, next) => seen.add(next));
      expect(container.read(boardDayProvider), DateTime(2026, 11, 14));

      clock.set(DateTime(2026, 11, 15, 4, 0, 1));
      await tester.pump(const Duration(hours: 1));

      expect(container.read(boardDayProvider), DateTime(2026, 11, 15));
      expect(seen, [DateTime(2026, 11, 15)]);

      // Rescheduled for the following day.
      clock.set(DateTime(2026, 11, 16, 4));
      await tester.pump(const Duration(hours: 24));
      expect(container.read(boardDayProvider), DateTime(2026, 11, 16));
    });

    boardDayTest('cancels the timer while backgrounded', (tester) async {
      container.read(boardDayProvider);
      expect(tester.binding.hasScheduledFrame, isFalse);

      lifecycle(tester, AppLifecycleState.paused);
      clock.set(DateTime(2026, 11, 15, 5));
      await tester.pump(const Duration(hours: 3));

      expect(container.read(boardDayProvider), DateTime(2026, 11, 14));
      // A pending Timer would make the test binding fail on teardown.
    });

    boardDayTest('re-evaluates and reschedules on resume', (tester) async {
      container.read(boardDayProvider);
      lifecycle(tester, AppLifecycleState.paused);
      clock.set(DateTime(2026, 11, 16, 9));
      await tester.pump(const Duration(hours: 30));
      expect(container.read(boardDayProvider), DateTime(2026, 11, 14));

      lifecycle(tester, AppLifecycleState.resumed);
      expect(container.read(boardDayProvider), DateTime(2026, 11, 16));

      clock.set(DateTime(2026, 11, 17, 4));
      await tester.pump(const Duration(hours: 24));
      expect(container.read(boardDayProvider), DateTime(2026, 11, 17));
    });

    boardDayTest('resume on the same Board_Day keeps the state', (tester) async {
      final seen = <DateTime>[];
      container.listen(boardDayProvider, (_, next) => seen.add(next));
      container.read(boardDayProvider);
      lifecycle(tester, AppLifecycleState.paused);
      lifecycle(tester, AppLifecycleState.resumed);
      expect(seen, isEmpty);
    });

    boardDayTest('disposing the container cancels the timer', (tester) async {
      container.read(boardDayProvider);
      container.dispose();
    });
  });
}
