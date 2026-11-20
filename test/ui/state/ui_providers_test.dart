import 'dart:ui';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/state/ui_providers.dart';

import '../../helpers/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> open(Locale device) async {
    final db = createTestDatabase();
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        deviceLocaleProvider.overrideWithValue(device),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    container.listen(settingsProvider, (_, _) {});
    await container.read(settingsProvider.future);
    return container;
  }

  Future<void> settle(ProviderContainer container) async {
    // One more emission of the settings stream after a write.
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  group('effectiveLocaleProvider', () {
    const devices = {
      'cs': Locale('cs', 'CZ'),
      'en': Locale('en', 'US'),
      'de': Locale('de', 'DE'),
    };
    // Expected language for each (setting, device) pair.
    const expected = {
      AppLanguage.system: {'cs': 'cs', 'en': 'en', 'de': 'en'},
      AppLanguage.cs: {'cs': 'cs', 'en': 'cs', 'de': 'cs'},
      AppLanguage.en: {'cs': 'en', 'en': 'en', 'de': 'en'},
    };

    for (final language in AppLanguage.values) {
      for (final entry in devices.entries) {
        test('${language.name} on a ${entry.key} device', () async {
          final container = await open(entry.value);
          await container.read(settingsServiceProvider).setLanguage(language);
          await settle(container);
          expect(
            container.read(effectiveLocaleProvider),
            Locale(expected[language]![entry.key]!),
          );
        });
      }
    }

    test('defaults to the device language before settings arrive', () {
      final db = createTestDatabase();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          deviceLocaleProvider.overrideWithValue(const Locale('cs')),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      expect(container.read(effectiveLocaleProvider), const Locale('cs'));
    });
  });

  group('themeModeProvider', () {
    const mapping = {
      AppTheme.system: ThemeMode.system,
      AppTheme.dark: ThemeMode.dark,
      AppTheme.light: ThemeMode.light,
    };
    for (final entry in mapping.entries) {
      test('${entry.key.name} maps to ${entry.value.name}', () async {
        final container = await open(const Locale('en'));
        container.listen(themeModeProvider, (_, _) {});
        await container.read(settingsServiceProvider).setTheme(entry.key);
        await settle(container);
        expect(container.read(themeModeProvider), entry.value);
      });
    }
  });

  test('appVersionProvider can be overridden', () async {
    final container = ProviderContainer(
      overrides: [appVersionProvider.overrideWith((ref) async => '9.8.7')],
    );
    addTearDown(container.dispose);
    expect(await container.read(appVersionProvider.future), '9.8.7');
  });

  group('snackbarProvider', () {
    test('holds the pending message until it is cleared', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(snackbarProvider), isNull);

      const first = SnackMessage('first');
      var undone = false;
      final second = SnackMessage(
        'second',
        action: SnackAction(label: 'Undo', onPressed: () => undone = true),
      );
      container.read(snackbarProvider.notifier).show(first);
      container.read(snackbarProvider.notifier).show(second);
      expect(container.read(snackbarProvider), same(second));
      container.read(snackbarProvider)!.action!.onPressed();
      expect(undone, isTrue);

      container.read(snackbarProvider.notifier).clear();
      expect(container.read(snackbarProvider), isNull);
    });

    test('showing an equal message again notifies listeners', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var notifications = 0;
      container.listen(snackbarProvider, (_, _) => notifications++);
      container.read(snackbarProvider.notifier).show(const SnackMessage('x'));
      container.read(snackbarProvider.notifier).clear();
      container.read(snackbarProvider.notifier).show(const SnackMessage('x'));
      expect(notifications, 3);
    });
  });
}
