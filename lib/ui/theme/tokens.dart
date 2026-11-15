import 'package:flutter/material.dart';

/// Palette roles from `.design/DESIGN.md`; one instance per theme.
///
/// These are the only colour literals in the app. Widgets read them through
/// `QuestlogTokens.of(context)` (see `questlog_theme.dart`).
class QuestlogPalette {
  const QuestlogPalette({
    required this.brightness,
    required this.board,
    required this.boardRaised,
    required this.boardLine,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.parchment,
    required this.parchmentEdge,
    required this.ink,
    required this.inkDim,
    required this.inkFaint,
    required this.brass,
    required this.brassSoft,
    required this.inkOnBrass,
    required this.destructive,
    required this.inkOnDestructive,
    required this.scrim,
    required this.sheet,
    required this.field,
    required this.fieldActive,
  });

  final Brightness brightness;
  final Color board, boardRaised, boardLine, text, textDim, textFaint;
  final Color parchment, parchmentEdge, ink, inkDim, inkFaint;
  final Color brass, brassSoft, inkOnBrass, destructive, inkOnDestructive;
  final Color scrim, sheet, field, fieldActive;

  bool get isLight => brightness == Brightness.light;

  /// Dark default theme.
  static const QuestlogPalette guildBoard = QuestlogPalette(
    brightness: Brightness.dark,
    board: Color(0xFF121A17),
    boardRaised: Color(0xFF1A2522),
    boardLine: Color(0x14ECE6D8),
    text: Color(0xFFECE6D8),
    textDim: Color(0x9EECE6D8),
    textFaint: Color(0x6BECE6D8),
    parchment: Color(0xFFF1E7D3),
    parchmentEdge: Color(0xFFE3D6BB),
    ink: Color(0xFF1F2A26),
    inkDim: Color(0x991F2A26),
    inkFaint: Color(0x611F2A26),
    brass: Color(0xFFD8AE5A),
    brassSoft: Color(0x2ED8AE5A),
    inkOnBrass: Color(0xFF2A1F0A),
    destructive: Color(0xFFD96B5A),
    inkOnDestructive: Color(0xFFFFF4F1),
    scrim: Color(0xB8080C0A),
    sheet: Color(0xFF1A2522),
    field: Color(0x0FECE6D8),
    fieldActive: Color(0x1AD8AE5A),
  );

  /// Light variant.
  static const QuestlogPalette daylight = QuestlogPalette(
    brightness: Brightness.light,
    board: Color(0xFFF4EEE1),
    boardRaised: Color(0xFFFBF7EE),
    boardLine: Color(0x141F2A26),
    text: Color(0xFF1F2A26),
    textDim: Color(0x9E1F2A26),
    textFaint: Color(0x6B1F2A26),
    parchment: Color(0xFFFFFDF7),
    parchmentEdge: Color(0xFFE9DFC9),
    ink: Color(0xFF1F2A26),
    inkDim: Color(0x991F2A26),
    inkFaint: Color(0x611F2A26),
    brass: Color(0xFFB4832A),
    brassSoft: Color(0x24B4832A),
    inkOnBrass: Color(0xFFFFF8E8),
    destructive: Color(0xFFD96B5A),
    inkOnDestructive: Color(0xFFFFF4F1),
    scrim: Color(0x801F2A26),
    sheet: Color(0xFFFBF7EE),
    field: Color(0x0D1F2A26),
    fieldActive: Color(0x1AB4832A),
  );
}

/// Spacing scale in logical pixels.
abstract final class Space {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s48 = 48;
  static const double s64 = 64;
}

/// Corner radii.
abstract final class Radii {
  static const double card = 14;
  static const double control = 12;
  static const double sheet = 24;
  static const double reward = 22;
  static const double pill = 999;
}

/// Sizes that are not spacing.
abstract final class Metrics {
  static const double touchTarget = 44;
  static const double checkPainted = 28;
  static const double heroBar = 6;
  static const double ring = 56;
  static const double ringRadius = 24;
  static const double ringStroke = 5;
  static const double swipeAction = 84;
  static const double levelBadge = 52;
  static const double fab = 56;
  static const double pip = 7;
  static const double hairline = 1;
  static const double grabberWidth = 36;
  static const double grabberHeight = 5;
  static const double menuWidth = 196;
  static const double iconSize = 24;
  static const double iconSmall = 18;

  /// Pinned blank slip of the empty state.
  static const double slipWidth = 170;
  static const double slipHeight = 110;
  static const double slipPin = 14;

  /// Bottom space a snackbar leaves for the tab bar and the add button.
  static const double snackClearance = 96;

  /// Height of one skeleton placeholder row.
  static const double skeletonRow = 72;
}

/// Transition durations and the shared curve.
abstract final class Motion {
  /// Hover and press states.
  static const Duration hover = Duration(milliseconds: 200);

  /// Sheets and menus.
  static const Duration panel = Duration(milliseconds: 300);

  /// Screen transitions.
  static const Duration screen = Duration(milliseconds: 350);

  /// Level progress bar fill.
  static const Duration progress = Duration(milliseconds: 600);

  /// How long a Reward_Card without a Mission offer stays on screen.
  static const Duration rewardDismiss = Duration(milliseconds: 2500);

  /// Replacement for every slide, scale and ray animation under reduced motion.
  static const Duration reducedFade = Duration(milliseconds: 150);

  /// One breath of the skeleton pulse.
  static const Duration pulse = Duration(milliseconds: 1100);

  /// How long a snackbar stays before it dismisses itself.
  static const Duration snack = Duration(milliseconds: 4000);

  static const Duration none = Duration.zero;

  static const Curve curve = Curves.easeInOut;
}
