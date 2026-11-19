import 'package:flutter/material.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

/// The tinted square holding the icon of a Folder or a trashed Node.
class NodeIconTile extends StatelessWidget {
  const NodeIconTile({super.key, required this.icon, this.tinted = true});

  final String icon;

  /// Accent tint for Folders; a neutral tile for Notes in the Trash.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tinted ? p.brassSoft : p.field,
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      child: SizedBox(
        width: Metrics.nodeIcon,
        height: Metrics.nodeIcon,
        child: Center(
          child: AppIcon(
            icon,
            size: Metrics.iconSmall + Space.s4,
            color: tinted ? p.brassText : p.textDim,
          ),
        ),
      ),
    );
  }
}

/// The raised, outlined card every row of the notes screens sits on.
class NodeCard extends StatelessWidget {
  const NodeCard({super.key, required this.onTap, required this.child, this.cardKey});

  final VoidCallback? onTap;
  final Widget child;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final BorderRadius radius = BorderRadius.circular(Radii.card);
    return Material(
      color: p.boardRaised,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: p.boardLine, width: Metrics.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: cardKey,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: child,
        ),
      ),
    );
  }
}
