import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart'
    show VoidCallback, WidgetsBinding, WidgetsBindingObserver;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/models.dart';
import '../../data/preferences.dart';
import '../../services/export_service.dart';
import '../../services/providers.dart';

// The stream providers of every `watch*` query (settings, XP, board, missions,
// rules) live in `services/providers.dart`; `settingsProvider` is the settings
// stream used below.

/// The device locale. Re-evaluated when the system language changes; tests
/// override it with `deviceLocaleProvider.overrideWithValue(...)`.
final deviceLocaleProvider = Provider<Locale>((ref) {
  final observer = _LocaleObserver(ref.invalidateSelf);
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
  return PlatformDispatcher.instance.locale;
});

class _LocaleObserver with WidgetsBindingObserver {
  _LocaleObserver(this._onChanged);

  final VoidCallback _onChanged;

  @override
  void didChangeLocales(List<Locale>? locales) => _onChanged();
}

/// The latest stored settings, or the defaults until the first emission.
final _currentSettingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(settingsProvider).value ??
      const AppSettings(
        heroName: '',
        language: AppLanguage.system,
        theme: AppTheme.system,
      );
});

/// The Effective_Language as a [Locale]: Czech or English, English for any
/// other device language.
final effectiveLocaleProvider = Provider<Locale>((ref) {
  final language = ref.watch(
    _currentSettingsProvider.select((s) => s.language),
  );
  final device = ref.watch(deviceLocaleProvider);
  final code = ref
      .watch(settingsServiceProvider)
      .resolveLanguage(language, device.languageCode);
  return Locale(code.name);
});

/// The stored theme setting as a [ThemeMode]; `system` follows the device live.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final theme = ref.watch(_currentSettingsProvider.select((s) => s.theme));
  switch (theme) {
    case AppTheme.light:
      return ThemeMode.light;
    case AppTheme.dark:
      return ThemeMode.dark;
    case AppTheme.system:
      return ThemeMode.system;
  }
});

/// The version from the platform build information (`pubspec.yaml` is the only
/// copy). Tests override it.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// Optional action of a [SnackMessage], for example "Undo".
class SnackAction {
  const SnackAction({required this.label, required this.onPressed});

  /// Already localized label.
  final String label;
  final VoidCallback onPressed;
}

/// A transient bottom message. Each instance is distinct, so showing the same
/// text twice still counts as a new message.
class SnackMessage {
  const SnackMessage(this.text, {this.action});

  /// Already localized text; never exception text.
  final String text;
  final SnackAction? action;
}

/// Holds the next message the shell has to show.
class SnackbarNotifier extends Notifier<SnackMessage?> {
  @override
  SnackMessage? build() => null;

  /// Replaces any message that has not been shown yet.
  void show(SnackMessage message) => state = message;

  /// Called by the shell once it has taken the message.
  void clear() => state = null;
}

final snackbarProvider = NotifierProvider<SnackbarNotifier, SnackMessage?>(
  SnackbarNotifier.new,
);

/// Exports all app data to a file and shares it.
final exportServiceProvider = Provider<ExportService>(
  (ref) => ExportService(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
    () => ref.read(appVersionProvider.future),
  ),
);
