import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/notes/node_tiles.dart';

/// One Trashed_Node: its kind icon, name, where it came from and when it is
/// purged, and the Obnovit pill. The second line is destructive-coloured when
/// the Purge is one day away or less.
class TrashRow extends StatelessWidget {
  const TrashRow({
    super.key,
    required this.name,
    required this.isFolder,
    required this.detail,
    required this.urgent,
    required this.onRestore,
  });

  final String name;
  final bool isFolder;

  /// Already localized, for example "z Poznámky · smaže se za 9 dní".
  final String detail;
  final bool urgent;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return NodeCard(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.s12, Space.s10, Space.s12, Space.s10),
        child: Row(
          children: <Widget>[
            NodeIconTile(icon: isFolder ? IconAsset.folder : IconAsset.note, tinted: false),
            const SizedBox(width: Space.s12),
            Expanded(
              child: Semantics(
                label: '$name. $detail',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyText.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyText.bodySmall!.copyWith(
                        color: urgent ? p.destructive : p.textFaint,
                        fontWeight: urgent ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Space.s8),
            Semantics(
              button: true,
              label: l.a11y_restoreNode(name),
              excludeSemantics: true,
              onTap: onRestore,
              child: InkWell(
                key: const ValueKey<String>('trash-restore'),
                onTap: onRestore,
                borderRadius: BorderRadius.circular(Radii.pill),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
                  child: Center(
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.brassSoft,
                        borderRadius: BorderRadius.circular(Radii.pill),
                        border: Border.all(color: p.brass, width: Metrics.hairline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s6),
                        child: Text(
                          l.trash_restore,
                          style: context.bodyText.bodySmall!.copyWith(
                            color: p.brassText,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
