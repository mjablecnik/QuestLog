import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/common/snackbar_host.dart';

import '_harness.dart';

Future<void> _pumpButton(
  WidgetTester tester,
  void Function(BuildContext) onTap,
) {
  return pumpCommon(
    tester,
    Builder(
      builder: (BuildContext context) => Center(
        child: TextButton(
          onPressed: () => onTap(context),
          child: const Text('go'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the message, styled from the palette', (tester) async {
    await _pumpButton(tester, (c) => showQuestlogSnack(c, '25 XP withdrawn'));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(Motion.panel);
    expect(find.text('25 XP withdrawn'), findsOneWidget);
    final SnackBar bar = tester.widget(find.byType(SnackBar));
    expect(bar.behavior, SnackBarBehavior.floating);
    expect(bar.backgroundColor, QuestlogPalette.guildBoard.boardRaised);
    expect(
      bar.margin!.resolve(TextDirection.ltr).bottom,
      Metrics.snackClearance,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dismisses itself after the snack duration', (tester) async {
    await _pumpButton(tester, (c) => showQuestlogSnack(c, 'Saved'));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(Motion.panel);
    expect(find.text('Saved'), findsOneWidget);
    await tester.pump(Motion.snack);
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('action runs its callback and dismisses', (tester) async {
    int retries = 0;
    await _pumpButton(
      tester,
      (c) => showQuestlogSnack(
        c,
        'Could not save',
        actionLabel: 'Try again',
        onAction: () => retries++,
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(Motion.panel);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(retries, 1);
    expect(find.text('Could not save'), findsNothing);
  });

  testWidgets('a new message replaces the one on screen', (tester) async {
    await _pumpButton(tester, (c) {
      showQuestlogSnack(c, 'first');
      showQuestlogSnack(c, 'second');
    });
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(Motion.panel);
    await tester.pumpAndSettle(Motion.panel);
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
