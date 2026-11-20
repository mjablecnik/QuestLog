import 'package:flutter/material.dart';
import '../../core/calendar/event_type.dart';

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
    Color? brassText,
    Color? brassOnParchment,
    Color? slip,
    Color? slipEdge,
    Color? slipText,
    Color? slipTextDim,
    Color? slipTextFaint,
    Color? slipDone,
    Color? destructiveText,
    required this.inkOnBrass,
    required this.destructive,
    required this.inkOnDestructive,
    required this.scrim,
    required this.sheet,
    required this.field,
    required this.fieldActive,
  }) : brassText = brassText ?? brass,
       destructiveText = destructiveText ?? destructive,
       brassOnParchment = brassOnParchment ?? brass,
       slip = slip ?? (brightness == Brightness.dark ? boardRaised : parchment),
       slipEdge =
           slipEdge ??
           (brightness == Brightness.dark ? boardLine : parchmentEdge),
       slipText = slipText ?? (brightness == Brightness.dark ? text : ink),
       slipTextDim =
           slipTextDim ?? (brightness == Brightness.dark ? textDim : inkDim),
       slipTextFaint =
           slipTextFaint ??
           (brightness == Brightness.dark ? textFaint : inkFaint),
       slipDone =
           slipDone ??
           (brightness == Brightness.dark
               ? const Color(0x00000000)
               : boardRaised);

  final Brightness brightness;
  final Color board, boardRaised, boardLine, text, textDim, textFaint;
  final Color parchment, parchmentEdge, ink, inkDim, inkFaint;
  final Color brass, brassSoft, inkOnBrass, destructive, inkOnDestructive;
  final Color scrim, sheet, field, fieldActive;

  /// The destructive colour as text on a Quest card (the overdue Deadline); darker
  /// than the fill in the light theme so that it reaches 4.5:1 on parchment.
  final Color destructiveText;

  /// Brass as text or an icon stroke on the ground.
  final Color brassText;

  /// Brass as text or an icon stroke on parchment.
  final Color brassOnParchment;

  /// Quest card roles. Light palettes keep the parchment slip (the defaults
  /// are its values); dark palettes draw a dark raised card instead, so no
  /// bright plane glares on the dark board. Widgets read these roles, never
  /// [parchment] or [ink], for a Quest card.
  ///
  /// [slip] fills an open card, [slipDone] a done one (transparent on a dark
  /// board, so an open card reads as the raised one), [slipEdge] is the
  /// hairline outline; [slipText], [slipTextDim] and [slipTextFaint] are the
  /// name, the meta line and the check ring plus empty pips.
  final Color slip, slipEdge, slipText, slipTextDim, slipTextFaint, slipDone;

  bool get isLight => brightness == Brightness.light;

  /// Dark theme: the blue palette after TimeLog's "Midnight" theme (board, text
  /// and accent are its `background`, `text` and `accent`), with cool paper slips.
  /// Chosen by Martin on 2026-11-19; the other temporary palettes were removed.
  static const QuestlogPalette guildBoard = QuestlogPalette(
    brightness: Brightness.dark,
    board: Color(0xFF0F1319),
    boardRaised: Color(0xFF18202B),
    boardLine: Color(0x1AE6EAF2),
    text: Color(0xFFE6EAF2),
    textDim: Color(0xA6E6EAF2),
    textFaint: Color(0x66E6EAF2),
    parchment: Color(0xFFEEF2F7),
    parchmentEdge: Color(0xFFDAE2EC),
    ink: Color(0xFF131B26),
    inkDim: Color(0xB2131B26),
    inkFaint: Color(0x61131B26),
    brass: Color(0xFF78B4C4),
    brassSoft: Color(0x2E78B4C4),
    brassText: Color(0xFF78B4C4),
    brassOnParchment: Color(0xFF2D6E80),
    inkOnBrass: Color(0xFF08131A),
    destructive: Color(0xFFD96B5A),
    inkOnDestructive: Color(0xFF2B0F0A),
    scrim: Color(0xB8070A10),
    sheet: Color(0xFF18202B),
    field: Color(0x0FE6EAF2),
    fieldActive: Color(0x1A78B4C4),
  );

  /// Light theme: cool off-white ground, darkened teal accent.
  static const QuestlogPalette daylight = QuestlogPalette(
    brightness: Brightness.light,
    board: Color(0xFFEDF1F6),
    boardRaised: Color(0xFFF8FAFD),
    boardLine: Color(0x1415202B),
    text: Color(0xFF15202B),
    textDim: Color(0xB315202B),
    textFaint: Color(0x6B15202B),
    parchment: Color(0xFFFFFFFF),
    parchmentEdge: Color(0xFFDCE4EE),
    ink: Color(0xFF15202B),
    inkDim: Color(0xB215202B),
    inkFaint: Color(0x6115202B),
    brass: Color(0xFF2B7287),
    brassSoft: Color(0x242B7287),
    brassText: Color(0xFF2B7287),
    brassOnParchment: Color(0xFF2B7287),
    inkOnBrass: Color(0xFFF4FAFC),
    destructive: Color(0xFFD96B5A),
    destructiveText: Color(0xFFB03A2A),
    inkOnDestructive: Color(0xFF2B0F0A),
    scrim: Color(0x8015202B),
    sheet: Color(0xFFF8FAFD),
    field: Color(0x0D15202B),
    fieldActive: Color(0x1A2B7287),
  );
}

/// Spacing scale in logical pixels.
abstract final class Space {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s24 = 24;
  static const double s26 = 26;
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
  static const double fab = 58;
  static const double pip = 7;
  static const double hairline = 1;
  static const double grabberWidth = 36;
  static const double grabberHeight = 5;
  static const double menuWidth = 196;
  static const double iconSize = 24;
  static const double iconSmall = 18;

  /// Ring around the level badge.
  static const double badgeBorder = 2;

  /// Painted size of a round icon button inside its 44px hit area.
  static const double iconButton = 32;

  /// Pinned blank slip of the empty state.
  static const double slipWidth = 170;
  static const double slipHeight = 110;
  static const double slipPin = 14;

  /// Bottom space a snackbar leaves for the tab bar and the add button.
  static const double snackClearance = 96;

  /// Height of one skeleton placeholder row.
  static const double skeletonRow = 72;

  /// Height of one row of the Mission menu.
  static const double menuItem = 46;

  /// Height of the progress bar on the Mission detail header.
  static const double detailBar = 10;

  /// Diameter of the seal on a completed Mission.
  static const double detailSeal = 48;

  /// Stroke and dash lengths of the dashed "add quest" outline.
  static const double dashStroke = 1.5;
  static const double dashLength = 6;
  static const double dashGap = 4;

  /// Notes: tinted icon tile of a row, width of one of three swipe actions,
  /// the count badge on the Trash button, indent of one level in the Move_Sheet.
  static const double nodeIcon = 40;
  static const double swipeActionNarrow = 76;
  static const double trashBadge = 16;
  static const double treeIndent = 22;

  /// Rule row in Settings: tinted icon tile, "Post now" pill, add-row plus.
  static const double ruleIcon = 40;
  static const double postPill = 30;
  static const double addPlus = 26;
}

/// Transition durations and the shared curve.
abstract final class Motion {
  /// Hover and press states.
  static const Duration hover = Duration(milliseconds: 200);

  /// Sheets and menus.
  static const Duration panel = Duration(milliseconds: 300);

  /// Pause after the last keystroke before a Note is saved.
  static const Duration autosave = Duration(milliseconds: 500);

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

/// The fixed colour of each calendar Event_Type, the same in every palette and
/// both themes. Solid chips carry [eventChipInk]; the Soft_Chip of a notable
/// day tints the colour over the ground and keeps the body text colour.
extension EventTypeColors on QuestlogPalette {
  Color eventColor(EventType type) => switch (type) {
    EventType.publicHoliday => const Color(0xFFE5594F),
    EventType.notableDay => const Color(0xFFC98A7D),
    EventType.birthday => const Color(0xFFF2A05E),
    EventType.nameDay => const Color(0xFFE8D36A),
    EventType.dance => const Color(0xFFEE7AA8),
    EventType.date => const Color(0xFFB983E0),
    EventType.meeting => const Color(0xFF6FA3E6),
    EventType.seminar => const Color(0xFF6FD0D8),
    EventType.lesson => const Color(0xFF62CF9F),
    EventType.work => const Color(0xFF8CA0B3),
    EventType.quest => const Color(0xFFA6D44E),
  };

  /// Text and marks on a solid event colour.
  Color get eventChipInk => const Color(0xFF14110A);

  /// The fill of a Soft_Chip: the type colour tinted over the ground.
  Color eventSoftFill(EventType type) => eventColor(type).withValues(alpha: 0.24);
}
