import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/clock.dart';
import 'package:questlog/core/font_licenses.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/export_service.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/settings/settings_screen.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';

/// A stand-in for the app root: the same providers drive locale and theme.
class _TestApp extends ConsumerWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: buildTheme(palette: QuestlogPalette.daylight),
      darkTheme: buildTheme(palette: QuestlogPalette.guildBoard),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(effectiveLocaleProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SettingsScreen(),
    );
  }
}

/// Counts share requests instead of opening the system share sheet.
class _FakeExportService extends ExportService {
  _FakeExportService(QuestlogDatabase db, Clock clock)
      : super(db, clock, _noVersion);

  static Future<String> _noVersion() async => '1.2.3';

  int shared = 0;
  bool fail = false;

  @override
  Future<void> shareExport({Rect? origin}) async {
    if (fail) throw StateError('share failed');
    shared++;
  }
}

void main() {
  late QuestlogDatabase db;

  Future<void> settle(WidgetTester tester) async {
    // Drift streams run on real async; give them time, then rebuild.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    String version = '1.2.3',
    ExportService Function(QuestlogDatabase)? export,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    db = createTestDatabase();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 16))),
          deviceLocaleProvider.overrideWithValue(const Locale('en')),
          appVersionProvider.overrideWith((ref) async => version),
          if (export != null)
            exportServiceProvider.overrideWith((ref) => export(db)),
        ],
        child: const _TestApp(),
      ),
    );
    await settle(tester);
  }

  /// Disposes the tree first so drift's stream timers run out, then the database.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.runAsync(db.close);
  }

  /// A widget test that always ends with [finish].
  void settingsTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await finish(tester);
    });
  }

  Future<AppStateRow> stored(WidgetTester tester) async {
    final row = await tester.runAsync(() => db.select(db.appState).getSingle());
    return row!;
  }

  Finder heroField() => find.byType(TextField);

  Future<void> blur(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
  }

  settingsTest('shows the groups in the required order', (tester) async {
    await open(tester, size: const Size(390, 1200));
    final labels = ['PROFILE', 'LANGUAGE', 'APPEARANCE', 'DATA', 'ABOUT'];
    final tops = [
      for (final label in labels) tester.getTopLeft(find.text(label)).dy,
    ];
    expect(tops, orderedEquals([...tops]..sort()));
    expect(tops.toSet().length, labels.length);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('0 / 40'), findsOneWidget);
  });

  settingsTest('the export row shares the data and reports a failure', (
    tester,
  ) async {
    late _FakeExportService service;
    await open(
      tester,
      size: const Size(390, 1200),
      export: (db) => service = _FakeExportService(
        db,
        FixedClock(DateTime(2026, 11, 20)),
      ),
    );

    await tester.tap(find.text('Export data'));
    await settle(tester);
    expect(service.shared, 1);
    expect(find.text('The export failed. Please try again.'), findsNothing);

    service.fail = true;
    await tester.tap(find.text('Export data'));
    await settle(tester);
    expect(service.shared, 1);
    expect(find.text('The export failed. Please try again.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
  });

  settingsTest('saves the trimmed hero name on blur and shows it', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(heroField());
    await tester.enterText(heroField(), '  Aria  ');
    await tester.pump();
    expect((await stored(tester)).heroName, '');

    await blur(tester);

    expect((await stored(tester)).heroName, 'Aria');
    expect(find.widgetWithText(TextField, 'Aria'), findsOneWidget);
  });

  settingsTest('saves the hero name on submit', (tester) async {
    await open(tester);
    await tester.tap(heroField());
    await tester.enterText(heroField(), 'Brom');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect((await stored(tester)).heroName, 'Brom');
  });

  settingsTest('41 characters show an error and are not saved', (tester) async {
    await open(tester);
    await tester.tap(heroField());
    await tester.enterText(heroField(), 'a' * 40);
    await blur(tester);
    expect((await stored(tester)).heroName, 'a' * 40);
    expect(find.text('The name can be at most 40 characters.'), findsNothing);

    await tester.tap(heroField());
    await tester.enterText(heroField(), 'b' * 41);
    await tester.pump();
    expect(find.text('The name can be at most 40 characters.'), findsOneWidget);
    expect(find.text('41 / 40'), findsOneWidget);

    await blur(tester);

    expect((await stored(tester)).heroName, 'a' * 40);
    // The input is kept so the user can fix it.
    expect(find.widgetWithText(TextField, 'b' * 41), findsOneWidget);
    expect(find.text('The name can be at most 40 characters.'), findsOneWidget);
  });

  settingsTest('language switch changes strings at once and keeps scroll', (
    tester,
  ) async {
    await open(tester, size: const Size(390, 420));
    final listScrollable = find
        .descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        )
        .first;
    ScrollableState scrollable() =>
        tester.state<ScrollableState>(listScrollable);

    await tester.drag(find.byType(ListView), const Offset(0, -80));
    await tester.pump();
    final offset = scrollable().position.pixels;
    expect(offset, greaterThan(0));
    expect(find.text('LANGUAGE'), findsOneWidget);

    await tester.tap(find.text('Čeština'));
    // Never an empty or loading frame while the change travels through.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
    }
    await settle(tester);

    expect((await stored(tester)).language, AppLanguage.cs);
    expect(find.text('JAZYK'), findsOneWidget);
    expect(find.text('LANGUAGE'), findsNothing);
    expect(scrollable().position.pixels, offset);
    final cs = find.bySemanticsLabel('Čeština');
    expect(cs, findsWidgets);
  });

  settingsTest('theme switch applies at once', (tester) async {
    await open(tester);
    Brightness brightness() =>
        Theme.of(tester.element(find.byType(SettingsScreen))).brightness;
    expect(brightness(), Brightness.light);

    await tester.tap(find.text('Dark'));
    await settle(tester);
    // MaterialApp animates the theme change.
    await tester.pump(const Duration(milliseconds: 400));

    expect((await stored(tester)).theme, AppTheme.dark);
    expect(brightness(), Brightness.dark);

    await tester.tap(find.text('Light'));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect((await stored(tester)).theme, AppTheme.light);
    expect(brightness(), Brightness.light);
  });

  settingsTest('shows the version from the platform info provider', (
    tester,
  ) async {
    await open(tester, size: const Size(390, 1200), version: '4.5.6');
    expect(find.text('version 4.5.6'), findsOneWidget);
    expect(find.text('Questlog'), findsOneWidget);
  });
  settingsTest('the Licenses row opens the licence page with the fonts', (
    tester,
  ) async {
    await open(tester, version: '4.5.6');
    registerFontLicenses();
    final row = find.text('Licenses');
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(row, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    final target = find.ancestor(of: row, matching: find.byType(InkWell));
    expect(tester.getSize(target).height, greaterThanOrEqualTo(44));

    await tester.tap(row);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(LicensePage), findsOneWidget);
    expect(find.text('4.5.6'), findsOneWidget);

    // The registry streams in on real async.
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    expect(find.text('Figtree (font)'), findsOneWidget);

    await tester.tap(find.text('Figtree (font)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    expect(find.textContaining('SIL Open Font License'), findsWidgets);
    expect(find.textContaining('The Figtree Project Authors'), findsWidgets);
  });

  settingsTest('the shortcut guide copies the link of the chosen tab', (
    tester,
  ) async {
    await open(tester, size: const Size(390, 1600));
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    // Collapsed: the steps are hidden until the row is opened.
    expect(find.text('Copy the link above.'), findsNothing);
    await tester.tap(find.text('Home Screen shortcut').last);
    await tester.pump();
    expect(find.text('Copy the link above.'), findsOneWidget);
    expect(find.text('questlog://calendar'), findsOneWidget);

    await tester.tap(find.text('Notes'));
    await tester.pump();
    expect(find.text('questlog://notes'), findsOneWidget);

    await tester.tap(find.text('Copy link'));
    await tester.pump();
    expect(copied, 'questlog://notes');
    expect(find.text('Link copied'), findsOneWidget);
  });
}
