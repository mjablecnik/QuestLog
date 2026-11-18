import 'package:flutter/material.dart';

import '../../../core/xp_rules.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../cards/difficulty_pips.dart';

/// Localized name of [difficulty]; shown only while a Quest is created or
/// edited, never in a list.
String effortName(AppLocalizations l, Difficulty difficulty) =>
    switch (difficulty) {
      Difficulty.easy => l.quest_effortMoment,
      Difficulty.normal => l.quest_effortHour,
      Difficulty.hard => l.quest_effortPart,
      Difficulty.fullDay => l.quest_effortDay,
    };

/// Localized time description of [difficulty], for example "up to ~2 h".
String effortTime(AppLocalizations l, Difficulty difficulty) =>
    switch (difficulty) {
      Difficulty.easy => l.quest_effortMomentTime,
      Difficulty.normal => l.quest_effortHourTime,
      Difficulty.hard => l.quest_effortPartTime,
      Difficulty.fullDay => l.quest_effortDayTime,
    };

/// One option per effort step, each with its name, time description, XP and
/// four pips. A stacked list rather than a row of segments so every
/// description stays readable at large text sizes.
class EffortPicker extends StatelessWidget {
  const EffortPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final Difficulty selected;
  final ValueChanged<Difficulty> onChanged;

  /// A disabled picker keeps its selection visible but ignores taps.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < Difficulty.values.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: Space.s4),
            _EffortOption(
              difficulty: Difficulty.values[i],
              selected: Difficulty.values[i] == selected,
              enabled: enabled,
              onTap: () => onChanged(Difficulty.values[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _EffortOption extends StatefulWidget {
  const _EffortOption({
    required this.difficulty,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final Difficulty difficulty;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_EffortOption> createState() => _EffortOptionState();
}

class _EffortOptionState extends State<_EffortOption> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final bool on = widget.selected;
    final Duration fade = MediaQuery.disableAnimationsOf(context)
        ? Motion.none
        : Motion.hover;
    final String name = effortName(l, widget.difficulty);
    final String time = effortTime(l, widget.difficulty);
    final String xp = l.common_plusXp(widget.difficulty.xp);

    return Semantics(
      button: true,
      selected: on,
      inMutuallyExclusiveGroup: true,
      enabled: widget.enabled,
      label: '$name, $time, $xp',
      excludeSemantics: true,
      onTap: widget.enabled ? widget.onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
        onTapUp: widget.enabled ? (_) => _setPressed(false) : null,
        onTapCancel: () => _setPressed(false),
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: fade,
          curve: Motion.curve,
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: Space.s12,
            vertical: Space.s8,
          ),
          decoration: BoxDecoration(
            color: (on || _pressed) ? p.brassSoft : p.field,
            borderRadius: BorderRadius.circular(Radii.control),
            border: Border.all(
              color: on ? p.brass : Colors.transparent,
              width: on && _pressed ? Metrics.hairline * 2 : Metrics.hairline,
            ),
          ),
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.5,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        name,
                        style: context.bodyText.labelLarge!.copyWith(
                          color: on ? p.brassText : p.text,
                        ),
                      ),
                      Text(
                        time,
                        style: context.bodyText.bodySmall!.copyWith(
                          color: p.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      xp,
                      style: context.bodyText.labelLarge!.copyWith(
                        color: on ? p.brass : p.textDim,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const SizedBox(height: Space.s4),
                    DifficultyPips(widget.difficulty, emptyColor: p.textFaint),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
