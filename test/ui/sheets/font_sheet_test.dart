import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/sheets/font_sheet.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/theme/typography.dart';
import 'package:questlog/ui/widgets/common/app_icon.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

/// Page title, as the real screens draw it: the display role of the theme.
class _Page extends StatelessWidget {
  const _Page();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text('Page title', style: context.displayText.headlineLarge),
          Text('Body text', style: context.bodyText.bodyLarge),
          TextButton(
            onPressed: () => showFontSheet(context),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _TestApp extends ConsumerWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final font = ref.watch(displayFontProvider);
    return MaterialApp(
      theme: buildTheme(palette: QuestlogPalette.guildBoard, font: font),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _Page(),
    );
  }
}

void main() {
  late QuestlogDatabase db;

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  Future<void> openSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    db = createTestDatabase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 16))),
          deviceLocaleProvider.overrideWithValue(const Locale('en')),
        ],
        child: const _TestApp(),
      ),
    );
    await settle(tester);
    await tester.tap(find.text('Open'));
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.runAsync(db.close);
  }

  void fontTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await finish(tester);
    });
  }

  Finder samples() => find.text('Board · +25', findRichText: true);

  /// Text.rich wraps the authored span in one carrying the ambient style.
  String? sampleFamily(WidgetTester tester, int index) {
    final rich = tester.widget<RichText>(samples().at(index));
    final authored = (rich.text as TextSpan).children!.first as TextSpan;
    return authored.style?.fontFamily;
  }

  String? titleFamily(WidgetTester tester) =>
      tester.widget<Text>(find.text('Page title')).style?.fontFamily;

  String? bodyFamily(WidgetTester tester) =>
      tester.widget<Text>(find.text('Body text')).style?.fontFamily;

  Future<DisplayFont> stored(WidgetTester tester) async {
    final row = await tester.runAsync(() => db.select(db.appState).getSingle());
    return row!.displayFont;
  }

  fontTest('lists the six fonts in order, each set in its own face', (
    tester,
  ) async {
    await openSheet(tester);

    expect(samples(), findsNWidgets(DisplayFont.values.length));
    final names = [
      'Figtree · Calm, universal',
      'Bricolage Grotesque · Quirky grotesque',
      'Sora · Geometric, technical',
      'Outfit · Soft geometric',
      'Unbounded · Wide, playful',
      'Cinzel · Carved capitals',
    ];
    final tops = [
      for (final name in names) tester.getTopLeft(find.text(name)).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
    expect(tops.toSet().length, names.length);

    for (var i = 0; i < DisplayFont.values.length; i++) {
      expect(sampleFamily(tester, i), displayFamilyName(DisplayFont.values[i]));
    }
    expect(find.text('Title font'), findsOneWidget);
    expect(find.textContaining('Changes only titles'), findsOneWidget);
  });

  fontTest('shows the brass tick on the current choice only', (tester) async {
    await openSheet(tester);

    expect(find.byType(AppIcon), findsOneWidget);
    final tick = tester.getCenter(find.byType(AppIcon)).dy;
    final first = tester.getCenter(samples().at(0)).dy;
    final second = tester.getCenter(samples().at(1)).dy;
    expect((tick - first).abs(), lessThan((tick - second).abs()));

    final selected = tester.getSemantics(
      find.text('Figtree · Calm, universal'),
    );
    expect(selected.label, contains('Figtree, selected'));
    final other = tester.getSemantics(find.text('Sora · Geometric, technical'));
    expect(other.label, isNot(contains('selected')));
  });

  fontTest('choosing a font stores it and restyles titles at once', (
    tester,
  ) async {
    await openSheet(tester);
    expect(titleFamily(tester), 'Figtree');

    await tester.tap(find.text('Sora · Geometric, technical'));
    await settle(tester);

    expect(await stored(tester), DisplayFont.sora);
    expect(titleFamily(tester), 'Sora');
    // The sheet title is a display-role text too and follows the choice.
    expect(
      tester.widget<Text>(find.text('Title font')).style?.fontFamily,
      'Sora',
    );
    // The tick moved to the new row and the sheet stayed open.
    final tick = tester.getCenter(find.byType(AppIcon)).dy;
    final sora = tester.getCenter(samples().at(2)).dy;
    expect((tick - sora).abs(), lessThan(Metrics.touchTarget));
  });

  fontTest('the body role stays Figtree for every font', (tester) async {
    await openSheet(tester);

    for (final font in DisplayFont.values) {
      final index = DisplayFont.values.indexOf(font);
      await tester.tap(samples().at(index));
      await settle(tester);
      expect(titleFamily(tester), displayFamilyName(font));
      expect(bodyFamily(tester), 'Figtree');
    }
    expect(await stored(tester), DisplayFont.cinzel);
  });

  fontTest('Close dismisses the sheet', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Close'));
    await settle(tester);

    expect(samples(), findsNothing);
  });

  fontTest('every row is at least 44 logical pixels tall', (tester) async {
    await openSheet(tester);

    for (var i = 0; i < DisplayFont.values.length; i++) {
      final row = find.ancestor(
        of: samples().at(i),
        matching: find.byType(InkWell),
      );
      expect(
        tester.getSize(row).height,
        greaterThanOrEqualTo(Metrics.touchTarget),
      );
    }
  });
}
