import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

/// The Trash button of the Notes_Screen: a round icon button with the number of
/// Trashed_Nodes as a badge, and no badge when there are none.
class TrashButton extends StatelessWidget {
  const TrashButton({super.key, required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.notes_trashButton,
      value: l.trash_count(count),
      excludeSemantics: true,
      onTap: onPressed,
      child: InkWell(
        key: const ValueKey<String>('notes-trash'),
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: Metrics.touchTarget,
          height: Metrics.touchTarget,
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(color: p.field, shape: BoxShape.circle),
                  child: SizedBox(
                    width: Metrics.iconButton,
                    height: Metrics.iconButton,
                    child: Center(
                      child: AppIcon(IconAsset.trash, size: Metrics.iconSmall, color: p.textDim),
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -Space.s4,
                    right: -Space.s4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.brass,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: Metrics.trashBadge,
                          minHeight: Metrics.trashBadge,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Space.s4),
                            child: Text(
                              '$count',
                              style: context.bodyText.labelSmall!.copyWith(
                                color: p.inkOnBrass,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
