import 'package:flutter/material.dart';

import '../../../core/notes/note_node.dart';
import '../../../core/notes/note_tree.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/sheet/questlog_sheet.dart';

/// Opens the Move_Sheet for [node] and resolves to the chosen destination
/// (a record, so that the Root_Folder, `target: null`, is told apart from a
/// dismissed sheet), or null when dismissed.
Future<({int? target})?> showMoveSheet(
  BuildContext context, {
  required NoteTree tree,
  required NoteNode node,
}) {
  return showQuestlogSheet<({int? target})>(
    context,
    builder: (BuildContext context) => _MoveSheet(tree: tree, node: node),
  );
}

class _MoveSheet extends StatefulWidget {
  const _MoveSheet({required this.tree, required this.node});

  final NoteTree tree;
  final NoteNode node;

  @override
  State<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends State<_MoveSheet> {
  late int? _selected = widget.node.parentId;

  /// The Folder being moved and everything inside it cannot be a destination.
  late final Set<int> _blocked = widget.node.isFolder
      ? widget.tree.subtreeIds(widget.node.id)
      : const <int>{};

  List<({NoteNode? folder, int depth})> _rows() {
    final List<({NoteNode? folder, int depth})> rows = <({NoteNode? folder, int depth})>[
      (folder: null, depth: 0),
    ];
    void walk(int? parent, int depth) {
      for (final NoteNode child in widget.tree.children(parent)) {
        if (!child.isFolder) continue;
        rows.add((folder: child, depth: depth));
        walk(child.id, depth + 1);
      }
    }

    walk(null, 1);
    return rows;
  }

  String _targetName(AppLocalizations l) =>
      _selected == null ? l.notes_title : widget.tree.byId(_selected!)?.name ?? l.notes_title;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final QuestlogPalette p = context.palette;
    final NoteNode node = widget.node;
    return QuestlogSheet(
      title: l.notes_moveTitle,
      primaryLabel: l.notes_moveConfirm(_targetName(l)),
      primaryEnabled: _selected != node.parentId,
      onPrimary: () async => QuestlogSheet.close<({int? target})>(context, (target: _selected)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            node.isFolder ? l.notes_moveFolder(node.name) : l.notes_moveNote(node.name),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.bodyText.bodyMedium!.copyWith(color: p.textDim),
          ),
          const SizedBox(height: Space.s12),
          for (final ({NoteNode? folder, int depth}) row in _rows())
            _TreeRow(
              rowKey: ValueKey<String>('move-${row.folder?.id ?? 'root'}'),
              name: row.folder?.name ?? l.notes_title,
              depth: row.depth,
              tag: row.folder == null
                  ? (node.parentId == null ? l.notes_moveCurrentTag : l.notes_moveRootTag)
                  : (row.folder!.id == node.parentId ? l.notes_moveCurrentTag : null),
              selected: _selected == row.folder?.id,
              enabled: row.folder == null || !_blocked.contains(row.folder!.id),
              onTap: () => setState(() => _selected = row.folder?.id),
            ),
        ],
      ),
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.rowKey,
    required this.name,
    required this.depth,
    required this.tag,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final Key rowKey;
  final String name;
  final int depth;
  final String? tag;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final Color tint = selected ? p.brassText : p.text;
    return Padding(
      padding: EdgeInsets.only(left: depth * Metrics.treeIndent, bottom: Space.s4),
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: tag == null ? name : '$name, $tag',
        excludeSemantics: true,
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : Space.s4 / Space.s10,
          child: Material(
            color: selected ? p.brassSoft : p.field.withValues(alpha: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.control),
              side: selected
                  ? BorderSide(color: p.brass, width: Metrics.hairline)
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: rowKey,
              onTap: enabled ? onTap : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s12),
                  child: Row(
                    children: <Widget>[
                      AppIcon(IconAsset.folder, size: Metrics.iconSmall, color: selected ? p.brassText : p.textDim),
                      const SizedBox(width: Space.s12),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.bodyText.bodyLarge!.copyWith(
                            color: tint,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (tag != null) ...<Widget>[
                        const SizedBox(width: Space.s8),
                        Text(tag!, style: context.bodyText.bodySmall!.copyWith(color: p.textFaint)),
                      ],
                      if (selected) ...<Widget>[
                        const SizedBox(width: Space.s8),
                        AppIcon(IconAsset.tick, size: Metrics.iconSmall, color: p.brassText),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
