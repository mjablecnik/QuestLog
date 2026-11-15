import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import 'helpers/test_database.dart';

class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Text(AppLocalizations.of(context)!.app_tabQuests));
}

void main() {
  testWidgets('settings change locale, theme and font at once', (tester) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        deviceLocaleProvider.overrideWithValue(const Locale('de')),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });
    final settings = container.read(settingsServiceProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const QuestlogApp(home: _Probe()),
      ),
    );
    await tester.pumpAndSettle();

    BuildContext context() => tester.element(find.byType(_Probe));

    // German device, no choice yet: English, device brightness (light in tests).
    expect(find.text('Quests'), findsOneWidget);
    expect(context().palette, QuestlogPalette.daylight);
    expect(Localizations.localeOf(context()), const Locale('en'));

    await settings.setLanguage(AppLanguage.cs);
    await tester.pumpAndSettle();
    expect(find.text('Questy'), findsOneWidget);
    expect(find.text('Quests'), findsNothing);
    expect(Localizations.localeOf(context()), const Locale('cs'));
    // Screen readers get the language of the app, not of the device.
    final semantics = tester.widget<Semantics>(
      find
          .ancestor(
            of: find.byType(_Probe),
            matching: find.byWidgetPredicate(
              (w) => w is Semantics && w.localeForSubtree != null,
            ),
          )
          .first,
    );
    expect(semantics.localeForSubtree, const Locale('cs'));

    await settings.setTheme(AppTheme.dark);
    await tester.pumpAndSettle();
    expect(context().palette, QuestlogPalette.guildBoard);
    expect(Theme.of(context()).brightness, Brightness.dark);

    await settings.setTheme(AppTheme.light);
    await tester.pumpAndSettle();
    expect(context().palette, QuestlogPalette.daylight);

    await settings.setDisplayFont(DisplayFont.cinzel);
    await tester.pumpAndSettle();
    expect(context().displayText.headlineLarge!.fontFamily, 'Cinzel');

    await settings.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Quests'), findsOneWidget);
  });

  testWidgets('system theme follows the device brightness live', (
    tester,
  ) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      tester.platformDispatcher.clearPlatformBrightnessTestValue();
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const QuestlogApp(home: _Probe()),
      ),
    );
    await tester.pumpAndSettle();
    BuildContext context() => tester.element(find.byType(_Probe));

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(context().palette, QuestlogPalette.guildBoard);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(context().palette, QuestlogPalette.daylight);
  });

  testWidgets('default home is the placeholder with the localized title', (
    tester,
  ) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        deviceLocaleProvider.overrideWithValue(const Locale('cs')),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const QuestlogApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppShellPlaceholder), findsOneWidget);
    expect(find.text('Questlog'), findsOneWidget);
  });
}
