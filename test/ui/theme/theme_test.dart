import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/theme/typography.dart';

void main() {
  final List<QuestlogPalette> palettes = <QuestlogPalette>[
    QuestlogPalette.guildBoard,
    QuestlogPalette.daylight,
  ];

  test('buildTheme succeeds for every palette', () {
    for (final QuestlogPalette p in palettes) {
      final ThemeData t = buildTheme(palette: p);
      expect(t.useMaterial3, isTrue);
      expect(t.brightness, p.brightness);
      expect(t.scaffoldBackgroundColor, p.board);
      expect(t.colorScheme.primary, p.brass);
      expect(t.extension<QuestlogStyle>(), isNotNull);
    }
  });

  test('every text, titles included, is Figtree', () {
    final ThemeData t = buildTheme(palette: palettes.first);
    final QuestlogStyle s = t.extension<QuestlogStyle>()!;
    expect(t.textTheme.bodyLarge!.fontFamily, 'Figtree');
    for (final TextStyle? style in <TextStyle?>[
      s.body.bodyLarge,
      s.body.bodyMedium,
      s.body.bodySmall,
      s.body.titleMedium,
      s.body.labelLarge,
      s.body.labelSmall,
    ]) {
      expect(style!.fontFamily, 'Figtree');
    }
    for (final TextStyle? style in <TextStyle?>[
      s.display.displayLarge,
      s.display.headlineLarge,
      s.display.headlineMedium,
      s.display.titleLarge,
      s.display.titleMedium,
    ]) {
      expect(style!.fontFamily, 'Figtree');
      expect(style.fontFamilyFallback, isNotEmpty);
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    }
  });

  test('display and body sizes follow the design', () {
    final QuestlogPalette p = palettes.first;
    final TextTheme d = buildDisplayTextTheme(p);
    final TextTheme b = buildBodyTextTheme(p);
    expect(d.displayLarge!.fontSize, 48);
    expect(d.displayLarge!.fontWeight, FontWeight.w800);
    expect(d.headlineLarge!.fontSize, 34);
    expect(d.headlineMedium!.fontSize, 24);
    expect(d.titleLarge!.fontSize, 20);
    expect(d.titleMedium!.fontSize, 17);
    expect(d.titleMedium!.letterSpacing, closeTo(-0.34, 1e-9));
    expect(b.bodyLarge!.fontSize, 15);
    expect(b.titleMedium!.fontSize, 16);
    expect(b.bodySmall!.fontSize, 12.5);
    expect(b.labelSmall!.letterSpacing, closeTo(11 * 0.14, 1e-9));
    expect(b.bodyLarge!.color, p.text);
  });

  test('line heights follow the artboards: 1.35 body, 1.1 display', () {
    final QuestlogPalette p = palettes.first;
    final TextTheme d = buildDisplayTextTheme(p);
    final TextTheme b = buildBodyTextTheme(p);
    for (final TextStyle? style in <TextStyle?>[
      d.displayLarge,
      d.headlineLarge,
      d.headlineMedium,
      d.titleLarge,
      d.titleMedium,
    ]) {
      expect(style!.height, 1.1);
    }
    for (final TextStyle? style in <TextStyle?>[
      b.bodyLarge,
      b.bodyMedium,
      b.bodySmall,
      b.titleMedium,
      b.labelLarge,
      b.labelSmall,
    ]) {
      expect(style!.height, 1.35);
    }
  });

  test('selection, cursor and handles are brass; sheets have no handle', () {
    for (final QuestlogPalette p in palettes) {
      final ThemeData t = buildTheme(palette: p);
      final TextSelectionThemeData sel = t.textSelectionTheme;
      expect(sel.cursorColor, p.brass);
      expect(sel.selectionHandleColor, p.brass);
      expect(sel.selectionColor!.withValues(alpha: 1), p.brass);
      expect(t.bottomSheetTheme.showDragHandle, isFalse);
      expect(t.bottomSheetTheme.backgroundColor, p.sheet);
      expect(t.snackBarTheme.behavior, SnackBarBehavior.floating);
    }
  });

  test('every platform uses the Cupertino page transition', () {
    final ThemeData t = buildTheme(palette: palettes.first);
    for (final TargetPlatform platform in TargetPlatform.values) {
      expect(
        t.pageTransitionsTheme.builders[platform],
        isA<CupertinoPageTransitionsBuilder>(),
        reason: '$platform',
      );
    }
  });

  testWidgets('QuestlogStyle is reachable through the context getters', (
    WidgetTester tester,
  ) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(palette: QuestlogPalette.daylight),
        home: Builder(
          builder: (BuildContext context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(captured.palette, same(QuestlogPalette.daylight));
    expect(captured.displayText.headlineLarge!.fontFamily, 'Figtree');
    expect(captured.bodyText.bodyLarge!.fontFamily, 'Figtree');
  });
}
