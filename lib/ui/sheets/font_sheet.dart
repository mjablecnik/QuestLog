import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../data/preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../services/providers.dart';
import '../forms/error_text.dart';
import '../state/ui_providers.dart';
import '../theme/questlog_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/common/haptics.dart';
import '../widgets/common/snackbar_host.dart';
import '../widgets/sheet/questlog_sheet.dart';

/// Localized name of [font].
String displayFontName(AppLocalizations l, DisplayFont font) {
  switch (font) {
    case DisplayFont.figtree:
      return l.font_nameFigtree;
    case DisplayFont.bricolageGrotesque:
      return l.font_nameBricolage;
    case DisplayFont.sora:
      return l.font_nameSora;
    case DisplayFont.outfit:
      return l.font_nameOutfit;
    case DisplayFont.unbounded:
      return l.font_nameUnbounded;
    case DisplayFont.cinzel:
      return l.font_nameCinzel;
  }
}

String _displayFontNote(AppLocalizations l, DisplayFont font) {
  switch (font) {
    case DisplayFont.figtree:
      return l.font_noteFigtree;
    case DisplayFont.bricolageGrotesque:
      return l.font_noteBricolage;
    case DisplayFont.sora:
      return l.font_noteSora;
    case DisplayFont.outfit:
      return l.font_noteOutfit;
    case DisplayFont.unbounded:
      return l.font_noteUnbounded;
    case DisplayFont.cinzel:
      return l.font_noteCinzel;
  }
}

/// Opens the temporary display-font picker.
///
/// A choice is stored and applied at once; the sheet stays open so the fonts
/// can be compared on the live page behind it.
Future<void> showFontSheet(BuildContext context) {
  return showQuestlogSheet<void>(
    context,
    builder: (BuildContext context) => const FontSheet(),
  );
}

/// Six rows, each set in its own face, with a brass tick on the current one.
class FontSheet extends ConsumerWidget {
  const FontSheet({super.key});

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    DisplayFont font,
  ) async {
    if (ref.read(displayFontProvider) == font) return;
    Haptics.light();
    try {
      await ref.read(settingsServiceProvider).setDisplayFont(font);
    } catch (e) {
      if (!context.mounted || e is! DomainError) return;
      showQuestlogSnack(
        context,
        domainErrorText(AppLocalizations.of(context), e),
        bottomClearance: Space.s16,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final current = ref.watch(displayFontProvider);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Material(
        color: p.sheet,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.sheet),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _Grabber(),
            _Header(title: l.font_rowLabel, closeLabel: l.common_close),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Space.s20,
                  Space.s8,
                  Space.s20,
                  Space.s16 + media.padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final DisplayFont font
                        in DisplayFont.values) ...<Widget>[
                      _FontRow(
                        font: font,
                        selected: font == current,
                        onTap: () => _choose(context, ref, font),
                      ),
                      const SizedBox(height: Space.s8),
                    ],
                    const SizedBox(height: Space.s4),
                    Text(
                      l.font_help,
                      style: context.bodyText.bodySmall!.copyWith(
                        color: p.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s12),
        child: Center(
          child: Container(
            width: Metrics.grabberWidth,
            height: Metrics.grabberHeight,
            decoration: BoxDecoration(
              color: context.palette.textFaint,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Zavřít" on the left, the title centred on the sheet.
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.closeLabel});

  final String title;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Metrics.touchTarget + Space.s32,
              ),
              child: Semantics(
                header: true,
                namesRoute: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.displayText.headlineMedium,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    Metrics.touchTarget,
                    Metrics.touchTarget,
                  ),
                  foregroundColor: context.palette.text,
                  padding: const EdgeInsets.symmetric(horizontal: Space.s8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.control),
                  ),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(closeLabel, style: context.bodyText.titleMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontRow extends StatelessWidget {
  const _FontRow({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  final DisplayFont font;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final name = displayFontName(l, font);
    final note = _displayFontNote(l, font);

    // The sample's last word ("+25") is the XP figure and takes the brass.
    final sample = l.font_sample;
    final split = sample.lastIndexOf(' ') + 1;

    // Unbounded is very wide; the artboard sets it a little smaller.
    final double size = font == DisplayFont.unbounded ? 20 : 22;
    final TextStyle sampleStyle = context.displayText.titleLarge!.copyWith(
      fontFamily: displayFamilyName(font),
      fontSize: size,
      fontWeight: font == DisplayFont.bricolageGrotesque
          ? FontWeight.w800
          : FontWeight.w700,
      letterSpacing: -0.01 * size,
      height: 1.15,
    );
    final String semanticName = selected ? l.a11y_selectedOption(name) : name;

    return Semantics(
      button: true,
      selected: selected,
      label: '$semanticName, $note',
      excludeSemantics: true,
      child: Material(
        color: selected ? p.fieldActive : p.field,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.control),
          side: selected
              ? BorderSide(color: p.brass)
              : BorderSide(color: p.sheet.withValues(alpha: 0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.s16,
                vertical: Space.s12,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text.rich(
                          TextSpan(
                            style: sampleStyle,
                            children: <InlineSpan>[
                              TextSpan(text: sample.substring(0, split)),
                              TextSpan(
                                text: sample.substring(split),
                                style: TextStyle(color: p.brass),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Space.s4),
                        Text(
                          '$name · $note',
                          style: context.bodyText.bodySmall!.copyWith(
                            color: p.textFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: Metrics.iconSize,
                    child: selected
                        ? AppIcon(
                            IconAsset.tick,
                            size: Metrics.iconSmall,
                            color: p.brass,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
