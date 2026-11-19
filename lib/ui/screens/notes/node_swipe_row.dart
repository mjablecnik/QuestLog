import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/notes/swipe_row.dart';

/// Wraps a Folder_Row or Note_Row with the Swipe_Actions Přejmenovat,
/// Přesunout and Smazat.
class NodeSwipeRow extends StatelessWidget {
  const NodeSwipeRow({
    super.key,
    required this.name,
    required this.onRename,
    required this.onMove,
    required this.onDelete,
    required this.child,
  });

  final String name;
  final VoidCallback onRename;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return SwipeRow(
      groupTag: 'notes',
      actions: <SwipeActionSpec>[
        SwipeActionSpec(
          label: l.notes_actionRename,
          semanticLabel: l.a11y_renameNode(name),
          icon: IconAsset.edit,
          background: p.boardRaised,
          foreground: p.text,
          onPressed: onRename,
          actionKey: const ValueKey<String>('node-swipe-rename'),
        ),
        SwipeActionSpec(
          label: l.notes_actionMove,
          semanticLabel: l.a11y_moveNode(name),
          icon: IconAsset.move,
          background: p.brassSoft,
          foreground: p.brassText,
          onPressed: onMove,
          actionKey: const ValueKey<String>('node-swipe-move'),
        ),
        SwipeActionSpec(
          label: l.notes_actionDelete,
          semanticLabel: l.a11y_trashNode(name),
          icon: IconAsset.trash,
          background: p.destructive,
          foreground: p.inkOnDestructive,
          onPressed: onDelete,
          actionKey: const ValueKey<String>('node-swipe-delete'),
        ),
      ],
      child: child,
    );
  }
}
