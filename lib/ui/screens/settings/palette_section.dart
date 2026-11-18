import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/palette_choice_store.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/palette_choice.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Temporary palette group of the Settings_Screen: switches the whole app
/// between the original colours and the proposals (higher contrast, blue,
/// green). Draws its own group header and the gap above it.
class PaletteSection extends ConsumerWidget {
  const PaletteSection({super.key});

  static String _name(AppLocalizations l, PaletteChoice choice) =>
      switch (choice) {
        PaletteChoice.original => l.settings_paletteOriginal,
        PaletteChoice.highContrast => l.settings_paletteHighContrast,
        PaletteChoice.blue => l.settings_paletteBlue,
        PaletteChoice.green => l.settings_paletteGreen,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final PaletteChoice choice = ref.watch(paletteChoiceProvider);
    void select(PaletteChoice next) =>
        ref.read(paletteChoiceProvider.notifier).select(next);

    Widget cell(PaletteChoice option) => Expanded(
      child: _PaletteChip(
        choice: option,
        label: _name(l, option),
        selected: option == choice,
        onTap: () => select(option),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: Space.s24),
        Semantics(
          header: true,
          child: Text(
            '${l.settings_paletteLabel} · ${l.settings_groupTemporary}'
                .toUpperCase(),
            style: context.bodyText.labelSmall!.copyWith(
              color: context.palette.textFaint,
            ),
          ),
        ),
        const SizedBox(height: Space.s8),
        Semantics(
          container: true,
          explicitChildNodes: true,
          child: Column(
            children: <Widget>[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    cell(PaletteChoice.original),
                    const SizedBox(width: Space.s8),
                    cell(PaletteChoice.highContrast),
                  ],
                ),
              ),
              const SizedBox(height: Space.s8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    cell(PaletteChoice.blue),
                    const SizedBox(width: Space.s8),
                    cell(PaletteChoice.green),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaletteChip extends StatefulWidget {
  const _PaletteChip({
    required this.choice,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final PaletteChoice choice;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_PaletteChip> createState() => _PaletteChipState();
}

class _PaletteChipState extends State<_PaletteChip> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bool on = widget.selected;
    final QuestlogPalette preview = p.isLight
        ? widget.choice.light
        : widget.choice.dark;
    final Duration fade = MediaQuery.disableAnimationsOf(context)
        ? Motion.none
        : Motion.hover;

    return Semantics(
      button: true,
      selected: on,
      inMutuallyExclusiveGroup: true,
      label: widget.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: fade,
          curve: Motion.curve,
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          padding: const EdgeInsets.all(Space.s6),
          decoration: BoxDecoration(
            color: (on || _pressed) ? p.brassSoft : p.field,
            borderRadius: BorderRadius.circular(Radii.control),
            border: Border.all(
              color: on ? p.brass : Colors.transparent,
              width: _pressed && on ? Metrics.hairline * 2 : Metrics.hairline,
            ),
          ),
          child: Row(
            children: <Widget>[
              _Swatch(palette: preview),
              const SizedBox(width: Space.s10),
              Expanded(
                child: Text(
                  widget.label,
                  style: context.bodyText.labelLarge!.copyWith(
                    color: on ? p.brassText : p.text,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tiny board in the colours of [palette]: ground, one parchment slip with
/// an ink line, and the accent as a dot.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.palette});

  final QuestlogPalette palette;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = palette;
    return Container(
      width: Metrics.touchTarget,
      height: Metrics.touchTarget,
      decoration: BoxDecoration(
        color: p.board,
        borderRadius: BorderRadius.circular(Space.s10),
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: Space.s6,
            top: Space.s8,
            child: Container(
              width: Space.s26,
              height: Space.s18,
              padding: const EdgeInsets.all(Space.s4),
              decoration: BoxDecoration(
                color: p.parchment,
                borderRadius: BorderRadius.circular(Space.s4),
                border: Border.all(
                  color: p.parchmentEdge,
                  width: Metrics.hairline,
                ),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: Space.s12,
                  height: Space.s4,
                  decoration: BoxDecoration(
                    color: p.ink,
                    borderRadius: BorderRadius.circular(Space.s2),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: Space.s6,
            bottom: Space.s6,
            child: Container(
              width: Space.s12,
              height: Space.s12,
              decoration: BoxDecoration(
                color: p.brass,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
