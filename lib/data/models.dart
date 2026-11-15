import 'preferences.dart';

/// Lifecycle state of a Mission.
enum MissionStatus { open, completed, closed }

/// Result of applying an XP delta to Total_XP.
class XpChange {
  const XpChange({
    required this.totalBefore,
    required this.totalAfter,
    required this.levelBefore,
    required this.levelAfter,
  });

  final int totalBefore;
  final int totalAfter;
  final int levelBefore;
  final int levelAfter;

  /// The XP actually applied after clamping at zero (negative when XP was removed).
  int get appliedDelta => totalAfter - totalBefore;

  @override
  bool operator ==(Object other) =>
      other is XpChange &&
      other.totalBefore == totalBefore &&
      other.totalAfter == totalAfter &&
      other.levelBefore == levelBefore &&
      other.levelAfter == levelAfter;

  @override
  int get hashCode => Object.hash(totalBefore, totalAfter, levelBefore, levelAfter);

  @override
  String toString() =>
      'XpChange($totalBefore -> $totalAfter, level $levelBefore -> $levelAfter)';
}

/// The hero name and appearance preferences.
class AppSettings {
  const AppSettings({
    required this.heroName,
    required this.language,
    required this.theme,
    required this.displayFont,
  });

  /// The trimmed hero name; empty when no name is set.
  final String heroName;
  final AppLanguage language;
  final AppTheme theme;
  final DisplayFont displayFont;

  /// The hero name, or null when none is set (the UI then shows only the Level).
  String? get displayName => heroName.isEmpty ? null : heroName;

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.heroName == heroName &&
      other.language == language &&
      other.theme == theme &&
      other.displayFont == displayFont;

  @override
  int get hashCode => Object.hash(heroName, language, theme, displayFont);

  @override
  String toString() =>
      'AppSettings($heroName, $language, $theme, $displayFont)';
}
