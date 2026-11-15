import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/common/skeleton_list.dart';

import '_harness.dart';

Finder get _rows => find.byType(SkeletonRow);

double _opacity(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find.descendant(
        of: find.byType(SkeletonList),
        matching: find.byType(FadeTransition),
      ),
    )
    .opacity
    .value;

void main() {
  testWidgets('renders the requested number of placeholder rows', (
    tester,
  ) async {
    await pumpCommon(tester, const SkeletonList(count: 3));
    expect(_rows, findsNWidgets(3));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('pulses when animations are allowed', (tester) async {
    await pumpCommon(tester, const SkeletonList());
    await tester.pump();
    final double start = _opacity(tester);
    await tester.pump(Motion.pulse ~/ 2);
    expect(_opacity(tester), lessThan(start));
    // Unmount to stop the repeating controller.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('is static under reduced motion', (tester) async {
    await pumpCommon(tester, const SkeletonList(), disableAnimations: true);
    expect(tester.hasRunningAnimations, isFalse);
    final double before = _opacity(tester);
    await tester.pump(Motion.pulse);
    expect(_opacity(tester), before);
    expect(before, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('is hidden from the semantics tree', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpCommon(tester, const SkeletonList(), disableAnimations: true);
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });
}
