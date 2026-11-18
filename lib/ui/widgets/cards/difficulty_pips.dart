import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/xp_rules.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Number of filled pips for [difficulty]: its effort step, one to four.
int pipCount(Difficulty difficulty) => switch (difficulty) {
  Difficulty.easy => 1,
  Difficulty.normal => 2,
  Difficulty.hard => 3,
  Difficulty.fullDay => 4,
};

/// Four diamonds, of which one to four are filled brass. Effort is never
/// colour coded and never named: the semantic label gives the step only.
class DifficultyPips extends StatelessWidget {
  const DifficultyPips(this.difficulty, {super.key, this.emptyColor});

  final Difficulty difficulty;

  /// Colour of the unfilled pips; defaults to the faint text of a Quest card.
  final Color? emptyColor;

  static const int total = 4;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final int filled = pipCount(difficulty);
    final Color empty = emptyColor ?? p.slipTextFaint;
    final AppLocalizations l = AppLocalizations.of(context);

    return Semantics(
      label: l.a11y_effort(filled, total),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < total; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: Space.s4),
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                key: ValueKey<String>(i < filled ? 'pip-on' : 'pip-off'),
                width: Metrics.pip,
                height: Metrics.pip,
                decoration: BoxDecoration(
                  color: i < filled ? p.brass : empty,
                  borderRadius: BorderRadius.circular(Metrics.hairline),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
