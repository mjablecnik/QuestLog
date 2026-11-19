import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, test, group, setUp, tearDown, setUpAll, tearDownAll;
import 'package:questlog/ui/widgets/cards/progress_ring.dart';

import '_cards_harness.dart';

/// Counts the arcs and circles a painter draws, ignoring everything else.
class _CountingCanvas implements Canvas {
  int arcs = 0;
  int circles = 0;
  double? lastSweep;

  @override
  void drawArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    Paint paint,
  ) {
    arcs++;
    lastSweep = sweepAngle;
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) => circles++;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

ProgressRingPainter _painter(int done, int total) => ProgressRingPainter(
  done: done,
  total: total,
  trackColor: const Color(0xFF000000),
  progressColor: const Color(0xFFFFFFFF),
);

void main() {
  // Feature: questlog-ui, Property 8: Progress ring geometry
  Glados2<int, int>(any.intInRange(1, 500), any.intInRange(0, 100000)).test(
    'sweep equals done/total of a full circle and nothing is drawn at 0',
    (int total, int raw) {
      final int done = raw % (total + 1);
      final ProgressRingPainter painter = _painter(done, total);

      expect(painter.sweep, closeTo(done / total * 2 * math.pi, 1e-9));
      expect(ringFraction(done, total), closeTo(done / total, 1e-12));
      expect(painter.shouldDrawArc, done > 0);

      final _CountingCanvas canvas = _CountingCanvas();
      painter.paint(canvas, const Size(56, 56));
      expect(canvas.circles, 1, reason: 'the track is always drawn');
      expect(canvas.arcs, done == 0 ? 0 : 1);
      if (done > 0) expect(canvas.lastSweep, closeTo(painter.sweep, 1e-12));
    },
  );

  test('edge cases: empty mission and full ring', () {
    expect(ringFraction(0, 0), 0);
    expect(_painter(0, 0).shouldDrawArc, isFalse);
    expect(ringFraction(5, 5), 1);
    expect(_painter(5, 5).sweep, closeTo(2 * math.pi, 1e-12));
    // Never beyond a full circle, never negative.
    expect(ringFraction(9, 5), 1);
    expect(ringFraction(-1, 5), 0);
  });

  testWidgets('ring uses the design geometry and shows the quests still open', (
    WidgetTester tester,
  ) async {
    await pumpCards(tester, const ProgressRing(done: 2, total: 5));

    expect(tester.getSize(find.byType(ProgressRing)), const Size(56, 56));
    expect(find.text('3'), findsOneWidget, reason: '2 of 5 done leaves 3 open');
    expect(find.textContaining('/'), findsNothing);

    final RenderBox paint = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey<String>('progress-ring-paint')),
    );
    expect(paint, paintsExactlyCountTimes(#drawArc, 1));
  });

  testWidgets('ring at 0 draws only the track', (WidgetTester tester) async {
    await pumpCards(tester, const ProgressRing(done: 0, total: 4));

    final RenderBox paint = tester.renderObject<RenderBox>(
      find.byKey(const ValueKey<String>('progress-ring-paint')),
    );
    expect(paint, paintsExactlyCountTimes(#drawArc, 0));
    expect(paint, paintsExactlyCountTimes(#drawCircle, 1));
  });
}
