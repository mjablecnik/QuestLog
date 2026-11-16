import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// What the "···" menu offers.
enum MissionMenuAction { edit, addQuest, delete }

/// The "···" button with its menu: edit, add quest (only while the Mission is
/// open) and, last and in the destructive colour, delete.
class MissionMenuButton extends StatelessWidget {
  const MissionMenuButton({
    super.key,
    required this.canAddQuest,
    required this.onSelected,
  });

  final bool canAddQuest;
  final ValueChanged<MissionMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);

    PopupMenuItem<MissionMenuAction> item(
      MissionMenuAction action,
      String label,
      String icon, {
      Color? color,
    }) {
      final Color tint = color ?? p.text;
      return PopupMenuItem<MissionMenuAction>(
        value: action,
        height: Metrics.menuItem,
        padding: const EdgeInsets.symmetric(horizontal: Space.s16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: context.bodyText.bodyLarge!.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AppIcon(icon, size: Metrics.iconSmall, color: tint),
          ],
        ),
      );
    }

    return PopupMenuButton<MissionMenuAction>(
      tooltip: l.a11y_missionMenu,
      position: PopupMenuPosition.under,
      color: p.sheet,
      surfaceTintColor: p.sheet.withValues(alpha: 0),
      shadowColor: p.scrim,
      elevation: Space.s8,
      constraints: const BoxConstraints.tightFor(width: Metrics.menuWidth),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: p.boardLine, width: Metrics.hairline),
      ),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<MissionMenuAction>>[
            item(MissionMenuAction.edit, l.mission_menuEdit, IconAsset.edit),
            if (canAddQuest) ...<PopupMenuEntry<MissionMenuAction>>[
              const PopupMenuDivider(height: Metrics.hairline),
              item(
                MissionMenuAction.addQuest,
                l.mission_menuAddQuest,
                IconAsset.plus,
              ),
            ],
            const PopupMenuDivider(height: Metrics.hairline),
            item(
              MissionMenuAction.delete,
              l.mission_menuDelete,
              IconAsset.trash,
              color: p.destructive,
            ),
          ],
      child: SizedBox(
        width: Metrics.touchTarget,
        height: Metrics.touchTarget,
        child: Center(
          child: Container(
            width: Metrics.iconButton,
            height: Metrics.iconButton,
            decoration: BoxDecoration(
              color: p.brassSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                IconAsset.more,
                size: Metrics.iconSmall,
                color: p.brass,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
