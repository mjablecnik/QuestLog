import 'package:flutter/material.dart';

import '../settings/settings_screen.dart';

/// Pushes the Settings_Screen on the root navigator.
///
/// Every screen with a Hero_Bar gear calls this, so the route (and its iOS
/// edge-swipe back gesture, from the theme's page transitions) is the same
/// everywhere. The tab underneath stays mounted, so closing Settings returns to
/// it with its scroll position unchanged.
Future<void> openSettings(BuildContext context) {
  return Navigator.of(
    context,
  ).push<void>(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
}
