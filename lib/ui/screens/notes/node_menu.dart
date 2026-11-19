import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// What the "···" menu of a Folder or Note offers.
enum NodeMenuAction { rename, move, trash }

/// The "···" button with Přejmenovat, Přesunout and, last and in the
/// destructive colour, Přesunout do koše. While [enabled] is false the button
/// opens nothing.
class NodeMenuButton extends StatelessWidget {
  const NodeMenuButton({super.key, required this.enabled, required this.onSelected});

  final bool enabled;
  final ValueChanged<NodeMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);

    PopupMenuItem<NodeMenuAction> item(
      NodeMenuAction action,
      String label,
      String icon, {
      Color? color,
    }) {
      final Color tint = color ?? p.text;
      return PopupMenuItem<NodeMenuAction>(
        value: action,
        height: Metrics.menuItem,
        padding: const EdgeInsets.symmetric(horizontal: Space.s16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: context.bodyText.bodyLarge!.copyWith(color: tint, fontWeight: FontWeight.w500),
              ),
            ),
            AppIcon(icon, size: Metrics.iconSmall, color: tint),
          ],
        ),
      );
    }

    return PopupMenuButton<NodeMenuAction>(
      key: const ValueKey<String>('node-menu'),
      tooltip: l.a11y_nodeMenu,
      enabled: enabled,
      position: PopupMenuPosition.under,
      color: p.sheet,
      surfaceTintColor: p.sheet.withValues(alpha: 0),
      shadowColor: p.scrim,
      elevation: Space.s8,
      constraints: const BoxConstraints.tightFor(width: Metrics.menuWidth + Space.s32),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: p.boardLine, width: Metrics.hairline),
      ),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<NodeMenuAction>>[
        item(NodeMenuAction.rename, l.notes_actionRename, IconAsset.edit),
        item(NodeMenuAction.move, l.notes_actionMove, IconAsset.move),
        const PopupMenuDivider(height: Metrics.hairline),
        item(NodeMenuAction.trash, l.notes_actionTrash, IconAsset.trash, color: p.destructive),
      ],
      child: SizedBox(
        width: Metrics.touchTarget,
        height: Metrics.touchTarget,
        child: Center(
          child: Container(
            width: Metrics.iconButton,
            height: Metrics.iconButton,
            decoration: BoxDecoration(
              color: enabled ? p.brassSoft : p.field,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppIcon(
                IconAsset.more,
                size: Metrics.iconSmall,
                color: enabled ? p.brass : p.textFaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
