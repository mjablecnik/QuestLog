import 'package:flutter/material.dart';

import '../../data/preferences.dart';
import 'tokens.dart';

/// Family of the always-on body role.
const String bodyFamilyName = 'Figtree';

/// Used when a glyph or a whole family is missing; Figtree is always bundled.
const List<String> _fallbackFamilies = <String>[
  bodyFamilyName,
  'Roboto',
  'Helvetica',
  'Arial',
  'sans-serif',
];

/// Tabular figures keep XP numbers from jittering while they count up.
const List<FontFeature> _tabularFigures = <FontFeature>[
  FontFeature.tabularFigures(),
];

/// `family:` name of [font] as declared in `pubspec.yaml`.
String displayFamilyName(DisplayFont font) {
  switch (font) {
    case DisplayFont.figtree:
      return 'Figtree';
    case DisplayFont.bricolageGrotesque:
      return 'BricolageGrotesque';
    case DisplayFont.sora:
      return 'Sora';
    case DisplayFont.outfit:
      return 'Outfit';
    case DisplayFont.unbounded:
      return 'Unbounded';
    case DisplayFont.cinzel:
      return 'Cinzel';
  }
}

TextStyle _display(
  String family,
  Color color,
  double size,
  FontWeight weight,
) => TextStyle(
  fontFamily: family,
  fontFamilyFallback: _fallbackFamilies,
  color: color,
  fontSize: size,
  fontWeight: weight,
  letterSpacing: -0.02 * size,
  fontFeatures: _tabularFigures,
);

/// Titles and XP figures, set in the switchable display face.
TextTheme buildDisplayTextTheme(DisplayFont font, QuestlogPalette p) {
  final String family = displayFamilyName(font);
  return TextTheme(
    // Reward figure.
    displayLarge: _display(family, p.text, 48, FontWeight.w800),
    // Page title.
    headlineLarge: _display(family, p.text, 34, FontWeight.w700),
    // Sheet title.
    headlineMedium: _display(family, p.text, 24, FontWeight.w700),
    // Level text, Mission and hero names.
    titleLarge: _display(family, p.text, 20, FontWeight.w700),
    // XP figure on cards.
    titleMedium: _display(family, p.text, 17, FontWeight.w700),
  );
}

TextStyle _body(
  Color color,
  double size,
  FontWeight weight, {
  double letterSpacing = 0,
}) => TextStyle(
  fontFamily: bodyFamilyName,
  fontFamilyFallback: _fallbackFamilies,
  color: color,
  fontSize: size,
  fontWeight: weight,
  letterSpacing: letterSpacing,
);

/// Running text, card titles, buttons and caps labels; always Figtree.
TextTheme buildBodyTextTheme(QuestlogPalette p) {
  return TextTheme(
    bodyLarge: _body(p.text, 15, FontWeight.w400),
    bodyMedium: _body(p.text, 15, FontWeight.w500),
    // Meta line.
    bodySmall: _body(p.text, 12.5, FontWeight.w400),
    // Card title.
    titleMedium: _body(p.text, 16, FontWeight.w600),
    // Buttons.
    labelLarge: _body(p.text, 15, FontWeight.w600),
    // Caps labels (0.14em).
    labelSmall: _body(p.text, 11, FontWeight.w600, letterSpacing: 0.14 * 11),
  );
}
