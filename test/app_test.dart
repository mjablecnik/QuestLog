import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/shell/app_shell.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import 'helpers/test_database.dart';

class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Text(AppLocalizations.of(context).app_tabQuests));
}

/// A pushed screen that remembers how often it was created and scrolled.
class _Pushed extends StatefulWidget {
  const _Pushed({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_Pushed> createState() => _PushedState();
}

class _PushedState extends State<_Pushed> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      controller: controller,
      children: <Widget>[
        for (int i = 0; i < 40; i++)
          SizedBox(
            height: 60,
            child: Text(AppLocalizations.of(context).app_tabQuests),
          ),
      ],
    ),
  );
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

    expect(context().displayText.headlineLarge!.fontFamily, 'Figtree');

    await settings.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Quests'), findsOneWidget);
  });

  testWidgets('a setting change restyles screens already pushed without '
      'rebuilding the stack', (tester) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        deviceLocaleProvider.overrideWithValue(const Locale('en')),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });
    final settings = container.read(settingsServiceProvider);
    int created = 0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const QuestlogApp(home: _Probe()),
      ),
    );
    await tester.pumpAndSettle();
    final NavigatorState navigator = Navigator.of(
      tester.element(find.byType(_Probe)),
    );
    // The detail, then Settings on top of it.
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => _Pushed(onInit: () => created++)),
    );
    await tester.pumpAndSettle();
    final ScrollController controller = tester
        .state<_PushedState>(find.byType(_Pushed))
        .controller;
    controller.jumpTo(300);
    navigator.push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
    await tester.pumpAndSettle();

    await settings.setLanguage(AppLanguage.cs);
    await settings.setTheme(AppTheme.dark);
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(_Pushed));
    expect(context.palette, QuestlogPalette.guildBoard);
    expect(find.text('Questy'), findsWidgets);
    expect(
      created,
      1,
      reason: 'the pushed screen was not rebuilt from scratch',
    );
    expect(controller.offset, 300, reason: 'the scroll position is kept');
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

  testWidgets('default home is the shell, localized by the device locale', (
    tester,
  ) async {
    final db = createTestDatabase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          deviceLocaleProvider.overrideWithValue(const Locale('cs')),
        ],
        child: const QuestlogApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsOneWidget);
    final BuildContext context = tester.element(find.byType(AppShell));
    expect(AppLocalizations.of(context).localeName, 'cs');

    // Disposed inside the body: the binding checks for pending timers
    // (Board_Day) before tear-downs run.
    // First let the real Reconciliation and the Drift streams finish.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  });
}
