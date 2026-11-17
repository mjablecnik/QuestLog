import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// The round badge with the current Level: brass ring, soft brass fill and the
/// number in the display face.
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});

  /// The Level to show; the badge is blank while it is null (data loading).
  final int? level;

  /// Painted size of the number.
  static const double _fontSize = 22;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final int? value = level;
    final Widget badge = Container(
      width: Metrics.levelBadge,
      height: Metrics.levelBadge,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: p.brassSoft,
        border: Border.all(color: p.brass, width: Metrics.badgeBorder),
      ),
      child: value == null
          ? null
          : Text(
              '$value',
              maxLines: 1,
              style: context.displayText.titleLarge!.copyWith(
                color: p.brassText,
                fontSize: _fontSize,
              ),
            ),
    );
    if (value == null) return badge;
    return Semantics(
      container: true,
      label: AppLocalizations.of(context).hero_levelBadgeLabel(value),
      child: ExcludeSemantics(child: badge),
    );
  }
}
