import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/preferences.dart';
import 'tokens.dart';
import 'typography.dart';

/// Carries the palette and both text roles next to [ThemeData].
@immutable
class QuestlogStyle extends ThemeExtension<QuestlogStyle> {
  const QuestlogStyle({
    required this.palette,
    required this.display,
    required this.body,
  });

  final QuestlogPalette palette;

  /// Titles and XP figures (switchable face).
  final TextTheme display;

  /// Running text, always Figtree.
  final TextTheme body;

  @override
  QuestlogStyle copyWith({
    QuestlogPalette? palette,
    TextTheme? display,
    TextTheme? body,
  }) => QuestlogStyle(
    palette: palette ?? this.palette,
    display: display ?? this.display,
    body: body ?? this.body,
  );

  /// Palettes and text roles are discrete choices, so they switch at the end.
  @override
  QuestlogStyle lerp(ThemeExtension<QuestlogStyle>? other, double t) {
    if (other is! QuestlogStyle) return this;
    return t < 0.5 ? this : other;
  }
}

/// Shorthand for widgets; names are shared by the whole UI layer.
extension QuestlogContext on BuildContext {
  QuestlogStyle get _style => Theme.of(this).extension<QuestlogStyle>()!;

  QuestlogPalette get palette => _style.palette;

  TextTheme get displayText => _style.display;

  TextTheme get bodyText => _style.body;
}

/// Material 3 theme for one palette and display font.
ThemeData buildTheme({
  required QuestlogPalette palette,
  required DisplayFont font,
}) {
  final QuestlogPalette p = palette;
  final TextTheme display = buildDisplayTextTheme(font, p);
  final TextTheme body = buildBodyTextTheme(p);

  final ColorScheme scheme = ColorScheme(
    brightness: p.brightness,
    primary: p.brass,
    onPrimary: p.inkOnBrass,
    secondary: p.brass,
    onSecondary: p.inkOnBrass,
    error: p.destructive,
    onError: p.inkOnDestructive,
    surface: p.board,
    onSurface: p.text,
    surfaceContainerHighest: p.boardRaised,
    outline: p.boardLine,
    outlineVariant: p.boardLine,
    scrim: p.scrim,
  );

  final Color pressed = p.brassSoft;
  final WidgetStateProperty<Color?> overlay =
      WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) =>
            states.any(
              (WidgetState s) =>
                  s == WidgetState.pressed ||
                  s == WidgetState.hovered ||
                  s == WidgetState.focused,
            )
            ? pressed
            : null,
      );

  const PageTransitionsTheme transitions = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
    },
  );

  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.board,
    canvasColor: p.board,
    fontFamily: bodyFamilyName,
    textTheme: body,
    primaryTextTheme: body,
    splashFactory: InkRipple.splashFactory,
    splashColor: pressed,
    highlightColor: pressed,
    hoverColor: pressed,
    focusColor: pressed,
    dividerColor: p.boardLine,
    pageTransitionsTheme: transitions,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.brass,
      selectionColor: p.brass.withValues(alpha: 0.35),
      selectionHandleColor: p.brass,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.sheet,
      modalBackgroundColor: p.sheet,
      surfaceTintColor: Colors.transparent,
      showDragHandle: false,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.sheet,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: display.titleLarge,
      contentTextStyle: body.bodyLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.sheet),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.boardRaised,
      contentTextStyle: body.bodyMedium,
      actionTextColor: p.brass,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        side: BorderSide(color: p.boardLine, width: Metrics.hairline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(overlayColor: overlay),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(overlayColor: overlay),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        overlayColor: overlay,
        backgroundColor: WidgetStatePropertyAll<Color>(p.brass),
        foregroundColor: WidgetStatePropertyAll<Color>(p.inkOnBrass),
        textStyle: WidgetStatePropertyAll<TextStyle?>(body.labelLarge),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: p.boardLine,
      thickness: Metrics.hairline,
      space: Metrics.hairline,
    ),
    extensions: <ThemeExtension<dynamic>>[
      QuestlogStyle(palette: p, display: display, body: body),
    ],
  );
}
