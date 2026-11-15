import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/xp_rules.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Number of filled pips for [difficulty]: one, two or three.
int pipCount(Difficulty difficulty) => switch (difficulty) {
  Difficulty.easy => 1,
  Difficulty.normal => 2,
  Difficulty.hard => 3,
};

/// Localized name of [difficulty].
String difficultyName(AppLocalizations l, Difficulty difficulty) =>
    switch (difficulty) {
      Difficulty.easy => l.quest_difficultyEasy,
      Difficulty.normal => l.quest_difficultyNormal,
      Difficulty.hard => l.quest_difficultyHard,
    };

/// Three diamonds, of which one to three are filled brass. Difficulty is never
/// colour coded.
class DifficultyPips extends StatelessWidget {
  const DifficultyPips(this.difficulty, {super.key, this.emptyColor});

  final Difficulty difficulty;

  /// Colour of the unfilled pips; defaults to the faint ink of a parchment slip.
  final Color? emptyColor;

  static const int total = 3;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final int filled = pipCount(difficulty);
    final Color empty = emptyColor ?? p.inkFaint;
    final AppLocalizations l = AppLocalizations.of(context);

    return Semantics(
      label: l.a11y_difficulty(difficultyName(l, difficulty)),
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
