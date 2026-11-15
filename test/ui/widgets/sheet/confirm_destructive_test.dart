import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/sheet/confirm_destructive.dart';

import '../common/_harness.dart';

final AppLocalizationsEn l10n = AppLocalizationsEn();

class _Answer {
  bool? value;
}

Future<_Answer> _pumpAsk(
  WidgetTester tester, {
  String? cancelLabel,
  QuestlogPalette palette = QuestlogPalette.guildBoard,
}) async {
  final _Answer answer = _Answer();
  await pumpCommon(
    tester,
    Builder(
      builder: (BuildContext context) => Center(
        child: TextButton(
          onPressed: () async {
            answer.value = await confirmDestructive(
              context,
              title: 'Delete quest?',
              body: 'Quest “Hang laundry” will be deleted.',
              confirmLabel: 'Delete',
              cancelLabel: cancelLabel,
            );
          },
          child: const Text('ask'),
        ),
      ),
    ),
    palette: palette,
  );
  await tester.tap(find.text('ask'));
  await tester.pumpAndSettle();
  return answer;
}

void main() {
  testWidgets('shows title, body and both actions', (
    WidgetTester tester,
  ) async {
    await _pumpAsk(tester);

    expect(find.text('Delete quest?'), findsOneWidget);
    expect(find.text('Quest “Hang laundry” will be deleted.'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text(l10n.common_cancel), findsOneWidget);
  });

  testWidgets('the destructive button resolves true', (
    WidgetTester tester,
  ) async {
    final _Answer answer = await _pumpAsk(tester);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(answer.value, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('the cancel button resolves false', (WidgetTester tester) async {
    final _Answer answer = await _pumpAsk(tester);

    await tester.tap(find.text(l10n.common_cancel));
    await tester.pumpAndSettle();

    expect(answer.value, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('a custom cancel label replaces the default', (
    WidgetTester tester,
  ) async {
    await _pumpAsk(tester, cancelLabel: 'Keep it');

    expect(find.text('Keep it'), findsOneWidget);
    expect(find.text(l10n.common_cancel), findsNothing);
  });

  testWidgets('tapping the scrim resolves false', (WidgetTester tester) async {
    final _Answer answer = await _pumpAsk(tester);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(answer.value, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('the system back gesture resolves false', (
    WidgetTester tester,
  ) async {
    final _Answer answer = await _pumpAsk(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(answer.value, isFalse);
  });

  for (final QuestlogPalette palette in <QuestlogPalette>[
    QuestlogPalette.guildBoard,
    QuestlogPalette.daylight,
  ]) {
    testWidgets('the confirm button is destructive-coloured '
        '(${palette.brightness.name})', (WidgetTester tester) async {
      await _pumpAsk(tester, palette: palette);

      final Material material = tester.widget<Material>(
        find.descendant(
          of: find.widgetWithText(FilledButton, 'Delete'),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, palette.destructive);
    });
  }

  testWidgets('both actions have 44x44 hit areas', (WidgetTester tester) async {
    await _pumpAsk(tester);

    for (final Finder finder in <Finder>[
      find.widgetWithText(TextButton, l10n.common_cancel),
      find.widgetWithText(FilledButton, 'Delete'),
    ]) {
      final Size size = tester.getSize(finder);
      expect(size.width, greaterThanOrEqualTo(Metrics.touchTarget));
      expect(size.height, greaterThanOrEqualTo(Metrics.touchTarget));
    }
  });

  testWidgets('exposes the actions as labelled buttons', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await _pumpAsk(tester);

    expect(
      tester.getSemantics(find.widgetWithText(FilledButton, 'Delete')),
      matchesSemantics(
        label: 'Delete',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(find.bySemanticsLabel(l10n.common_cancel), findsOneWidget);
    handle.dispose();
  });

  testWidgets('stacks the buttons when the labels do not fit', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpAsk(tester, cancelLabel: 'Continue editing what I typed');

    expect(tester.takeException(), isNull);
    final Offset cancel = tester.getTopLeft(
      find.widgetWithText(TextButton, 'Continue editing what I typed'),
    );
    final Offset confirm = tester.getTopLeft(
      find.widgetWithText(FilledButton, 'Delete'),
    );
    expect(cancel.dy != confirm.dy, isTrue);
  });
}
