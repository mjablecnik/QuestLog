import 'package:flutter/material.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Small upper-case label row above a list section, with a figure on the
/// right ("+110 XP", "2 quests · 35 XP").
class BoardSectionHeader extends StatelessWidget {
  const BoardSectionHeader({
    super.key,
    required this.label,
    required this.figure,
    this.figureColor,
  });

  /// Already localized section name.
  final String label;

  /// Already localized summary shown at the right.
  final String figure;

  /// Defaults to the faint text colour; the open section uses brass.
  final Color? figureColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final TextStyle base = context.bodyText.labelSmall!.copyWith(
      color: p.textFaint,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.s20,
        Space.s8,
        Space.s20,
        Space.s10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Text(label.toUpperCase(), style: base),
            ),
          ),
          const SizedBox(width: Space.s12),
          Text(
            figure.toUpperCase(),
            style: base.copyWith(color: figureColor ?? p.textFaint),
          ),
        ],
      ),
    );
  }
}
