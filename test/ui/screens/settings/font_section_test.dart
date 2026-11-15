import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/settings/font_section.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';

class _TestApp extends ConsumerWidget {
  const _TestApp({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final font = ref.watch(displayFontProvider);
    return MaterialApp(
      theme: buildTheme(palette: QuestlogPalette.guildBoard, font: font),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SingleChildScrollView(child: FontSection())),
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

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    db = createTestDatabase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 16))),
          deviceLocaleProvider.overrideWithValue(locale),
        ],
        child: _TestApp(locale: locale),
      ),
    );
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.runAsync(db.close);
  }

  void sectionTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await finish(tester);
    });
  }

  sectionTest('shows the group header and the row with the current font', (
    tester,
  ) async {
    await open(tester);

    expect(find.text('TEMPORARY · REMOVED ONCE YOU CHOOSE'), findsOneWidget);
    expect(find.text('Title font'), findsOneWidget);
    expect(find.text('Figtree'), findsOneWidget);
  });

  sectionTest('is localized in Czech', (tester) async {
    await open(tester, locale: const Locale('cs'));

    expect(find.text('DOČASNÉ · ZMIZÍ PO VÝBĚRU'), findsOneWidget);
    expect(find.text('Písmo titulků'), findsOneWidget);
  });

  sectionTest('the row is a labelled button of at least 44 pixels', (
    tester,
  ) async {
    await open(tester);

    final row = find.ancestor(
      of: find.text('Title font'),
      matching: find.byType(InkWell),
    );
    expect(
      tester.getSize(row).height,
      greaterThanOrEqualTo(Metrics.touchTarget),
    );
    final semantics = tester.getSemantics(find.text('Title font'));
    expect(semantics.label, 'Title font, Figtree');
  });

  sectionTest('opens the sheet; a choice updates the row at once', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Title font'));
    await settle(tester);
    expect(find.text('Cinzel · Carved capitals'), findsOneWidget);

    await tester.tap(find.text('Cinzel · Carved capitals'));
    await settle(tester);
    final row = await tester.runAsync(() => db.select(db.appState).getSingle());
    expect(row!.displayFont, DisplayFont.cinzel);

    await tester.tap(find.text('Close'));
    await settle(tester);
    expect(find.text('Cinzel'), findsOneWidget);
    expect(find.text('Figtree'), findsNothing);
  });
}
