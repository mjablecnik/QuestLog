import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/palette_choice_store.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/settings/settings_screen.dart';
import 'package:questlog/ui/state/palette_choice.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';

/// Root screen that pushes the Settings screen, so a palette change can be
/// observed on a route that is already underneath.
class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
      child: const Text('open settings'),
    ),
  );
}

void main() {
  late QuestlogDatabase db;
  late MemoryPaletteChoiceStore store;

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
  }

  Future<void> launch(
    WidgetTester tester, {
    PaletteChoice initial = PaletteChoice.original,
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
          paletteChoiceStoreProvider.overrideWithValue(store),
          initialPaletteChoiceProvider.overrideWithValue(initial),
        ],
        child: const QuestlogApp(home: _Probe()),
      ),
    );
    await settle(tester);
    await tester.tap(find.text('open settings'));
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.runAsync(db.close);
  }

  QuestlogPalette paletteOf(WidgetTester tester, Finder finder) =>
      tester.element(finder).palette;

  void paletteTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      store = MemoryPaletteChoiceStore();
      await body(tester);
      await finish(tester);
    });
  }

  paletteTest('shows a temporary group with both options, original selected', (
    tester,
  ) async {
    await launch(tester);

    expect(find.text('PALETTE · TEMPORARY'), findsOneWidget);
    expect(find.text('Original'), findsOneWidget);
    expect(find.text('Higher contrast'), findsOneWidget);
    expect(
      paletteOf(tester, find.byType(SettingsScreen)),
      QuestlogPalette.daylight,
    );
  });

  paletteTest('is localized in Czech', (tester) async {
    await launch(tester, locale: const Locale('cs'));

    expect(find.text('PALETA · DOČASNÉ'), findsOneWidget);
    expect(find.text('Původní'), findsOneWidget);
    expect(find.text('Vyšší kontrast'), findsOneWidget);
  });

  paletteTest('switching restyles the screen and the route underneath live', (
    tester,
  ) async {
    await launch(tester);
    final Finder probe = find.byType(_Probe, skipOffstage: false);

    await tester.tap(find.text('Higher contrast'));
    await settle(tester);

    expect(
      paletteOf(tester, find.byType(SettingsScreen)),
      QuestlogPalette.daylightHighContrast,
    );
    expect(paletteOf(tester, probe), QuestlogPalette.daylightHighContrast);
    expect(store.value, PaletteChoice.highContrast);

    await tester.tap(find.text('Original'));
    await settle(tester);

    expect(paletteOf(tester, probe), QuestlogPalette.daylight);
    expect(store.value, PaletteChoice.original);
  });

  paletteTest('applies to the dark theme as well', (tester) async {
    await launch(tester);
    await ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)))
        .read(settingsServiceProvider)
        .setTheme(AppTheme.dark);
    await settle(tester);
    expect(
      paletteOf(tester, find.byType(SettingsScreen)),
      QuestlogPalette.guildBoard,
    );

    await tester.tap(find.text('Higher contrast'));
    await settle(tester);

    expect(
      paletteOf(tester, find.byType(SettingsScreen)),
      QuestlogPalette.guildBoardHighContrast,
    );
  });

  paletteTest('a stored choice is applied on the next launch', (tester) async {
    await launch(tester);
    await tester.tap(find.text('Higher contrast'));
    await settle(tester);
    await finish(tester);

    final PaletteChoice restored = await store.load();
    await launch(tester, initial: restored);

    expect(
      paletteOf(tester, find.byType(SettingsScreen)),
      QuestlogPalette.daylightHighContrast,
    );
  });
}
