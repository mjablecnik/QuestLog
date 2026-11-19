import 'package:flutter/material.dart';

import '../../../core/notes/note_node.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// The path from Poznámky to the Current_Folder. Every segment but the last is
/// tappable. When the path is longer than three Folders the middle segments
/// are replaced by an ellipsis, keeping the first and the last two.
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.path, required this.onOpen});

  /// Folders from the first below the Root_Folder to the Current_Folder.
  final List<NoteNode> path;

  /// Opens a Folder, or the Root_Folder for null.
  final ValueChanged<int?> onOpen;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final QuestlogPalette p = context.palette;
    // Poznámky, then the Folders; a long path keeps only the last two of them.
    final bool shorten = path.length > 3;
    final List<NoteNode> shown = shorten ? path.sublist(path.length - 2) : path;
    final List<Widget> parts = <Widget>[
      _segment(context, l.notes_title, () => onOpen(null), current: false),
      if (shorten) ...<Widget>[
        _chevron(p),
        Text('…', style: context.bodyText.bodySmall!.copyWith(color: p.textDim)),
      ],
      for (final NoteNode n in shown) ...<Widget>[
        _chevron(p),
        _segment(
          context,
          n.name,
          identical(n, path.last) ? null : () => onOpen(n.id),
          current: identical(n, path.last),
        ),
      ],
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: parts),
    );
  }

  Widget _chevron(QuestlogPalette p) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Space.s4),
    child: AppIcon(IconAsset.chevronRight, size: Metrics.iconSmall - Space.s6, color: p.textFaint),
  );

  Widget _segment(BuildContext context, String text, VoidCallback? onTap, {required bool current}) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final TextStyle style = context.bodyText.bodySmall!.copyWith(
      color: current ? p.text : p.textDim,
      fontWeight: current ? FontWeight.w600 : FontWeight.w500,
    );
    final Widget label = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
      child: Center(child: Text(text, maxLines: 1, style: style)),
    );
    if (onTap == null) {
      return Semantics(label: text, excludeSemantics: true, child: label);
    }
    return Semantics(
      button: true,
      label: l.a11y_breadcrumbTo(text),
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(onTap: onTap, child: label),
    );
  }
}
