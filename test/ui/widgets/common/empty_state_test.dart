import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/common/empty_state.dart';

import '_harness.dart';

void main() {
  testWidgets('shows title and body, no button without an action', (
    tester,
  ) async {
    await pumpCommon(
      tester,
      const EmptyState(title: 'The board is empty', body: 'Post a quest.'),
    );
    expect(find.text('The board is empty'), findsOneWidget);
    expect(find.text('Post a quest.'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(BlankSlip), findsOneWidget);
  });

  testWidgets('body is optional', (tester) async {
    await pumpCommon(tester, const EmptyState(title: 'Nothing here'));
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('action button fires and is at least 44px', (tester) async {
    int taps = 0;
    await pumpCommon(
      tester,
      EmptyState(
        title: 'No missions',
        actionLabel: 'Start a mission',
        onAction: () => taps++,
      ),
    );
    final Size size = tester.getSize(find.byType(FilledButton));
    expect(size.height, greaterThanOrEqualTo(Metrics.touchTarget));
    expect(size.width, greaterThanOrEqualTo(Metrics.touchTarget));
    await tester.tap(find.text('Start a mission'));
    expect(taps, 1);
  });

  testWidgets('title is a semantic header and the slip is decorative', (
    tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpCommon(tester, const EmptyState(title: 'Empty', body: 'Body'));
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Empty'))
          .flagsCollection
          .isHeader,
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('fits a small screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpCommon(
      tester,
      const EmptyState(
        title: 'The board is empty',
        body:
            'Tap the + button to post your first quest — maybe something you '
            'meant to do today anyway.',
        actionLabel: 'Post a quest',
        onAction: _noop,
      ),
    );
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
