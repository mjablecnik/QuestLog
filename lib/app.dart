import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/preferences.dart';
import 'l10n/app_localizations.dart';
import 'ui/screens/shell/app_shell.dart';
import 'ui/state/ui_providers.dart';
import 'ui/theme/questlog_theme.dart';
import 'ui/theme/tokens.dart';

/// The application root: theme, locale and localization follow the settings
/// live, so a change applies to every screen without rebuilding navigation.
class QuestlogApp extends ConsumerWidget {
  const QuestlogApp({super.key, this.home = const AppShell()});

  /// The root screen; tests swap in a probe.
  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(effectiveLocaleProvider);
    final DisplayFont font = ref.watch(displayFontProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).app_name,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: buildTheme(palette: QuestlogPalette.daylight, font: font),
      darkTheme: buildTheme(palette: QuestlogPalette.guildBoard, font: font),
      themeMode: ref.watch(themeModeProvider),
      // The application-level Localizations does not tag its subtree, so screen
      // readers would keep the device voice without this.
      builder: (context, child) =>
          Semantics(localeForSubtree: locale, child: child),
      home: home,
    );
  }
}
