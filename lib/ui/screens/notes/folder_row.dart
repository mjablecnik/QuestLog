import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/notes/node_tiles.dart';

/// One Folder in the list: icon, name, what is inside, and a chevron.
class FolderRow extends StatelessWidget {
  const FolderRow({
    super.key,
    required this.name,
    required this.summary,
    required this.onTap,
  });

  final String name;

  /// Already localized, for example "2 složky · 9 poznámek".
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: '${l.a11y_openFolder(name)}. $summary',
      excludeSemantics: true,
      onTap: onTap,
      child: NodeCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.s12,
            vertical: Space.s10,
          ),
          child: Row(
            children: <Widget>[
              const NodeIconTile(icon: IconAsset.folder),
              const SizedBox(width: Space.s12),
              Expanded(
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
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyText.bodySmall!.copyWith(color: p.textDim),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.s8),
              AppIcon(IconAsset.chevronRight, size: Metrics.iconSmall, color: p.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}
