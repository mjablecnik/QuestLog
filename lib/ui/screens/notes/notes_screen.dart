import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/notes/note_node.dart';
import '../../../core/notes/note_title.dart';
import '../../../core/notes/note_tree.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/notes/notes_providers.dart';
import '../../../services/providers.dart';
import '../../sheets/notes/add_sheet.dart';
import '../../sheets/notes/name_sheet.dart';
import '../../state/notes_state.dart';
import '../../state/quest_actions.dart' show showDomainError;
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/add_fab.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton_list.dart';
import '../../widgets/notes/trash_button.dart';
import '../note_editor/note_editor_screen.dart';
import '../board/section_header.dart';
import 'breadcrumb.dart';
import 'folder_row.dart';
import 'node_menu.dart';
import 'node_swipe_row.dart';
import 'note_row.dart';
import 'notes_actions.dart';
import 'notes_labels.dart';
import 'trash_screen.dart';

/// The Poznámky tab: the Folders and Notes of the Current_Folder, with the add
/// button, the Breadcrumb inside a Folder and the Trash button at the top level.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<NoteTree> treeAsync = ref.watch(noteTreeProvider);
    final NoteTree? tree = treeAsync.value;
    final int? folderId = ref.watch(visibleFolderProvider);
    final NoteNode? folder = folderId == null ? null : tree?.byId(folderId);
    final void Function(int?) open = ref.read(currentFolderProvider.notifier).open;

    final Widget body;
    if (treeAsync.hasError) {
      body = _LoadError(onRetry: () => ref.invalidate(noteNodesProvider));
    } else if (tree == null) {
      body = const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SkeletonList(count: 4, padding: EdgeInsets.symmetric(horizontal: Space.s20)),
      );
    } else if (tree.children(folderId).isEmpty) {
      body = EmptyState(title: l.notes_emptyTitle, body: l.notes_emptyBody);
    } else {
      body = _NodeList(tree: tree, folderId: folderId);
    }

    // All tabs stay mounted: only the visible one (tickers on) takes the back action.
    return PopScope(
      canPop: folderId == null || !TickerMode.valuesOf(context).enabled,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) open(folder?.parentId);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (folder != null && tree != null) ...<Widget>[
                    _FolderBar(tree: tree, folder: folder),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s20),
                      child: Breadcrumb(path: tree.breadcrumb(folder.id), onOpen: open),
                    ),
                  ],
                  _TitleRow(tree: tree, folder: folder),
                  const SizedBox(height: Space.s10),
                  Expanded(child: body),
                ],
              ),
              Positioned(
                right: Space.s20,
                bottom: Space.s20,
                child: AddFab(
                  label: l.notes_addTitle,
                  onPressed: () => _add(context, ref, tree, folderId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, NoteTree? tree, int? folderId) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final String place = folderId == null
        ? l.notes_title
        : tree?.byId(folderId)?.name ?? l.notes_title;
    final NewNodeKind? kind = await showAddSheet(context, placeName: place);
    if (kind == null || !context.mounted) return;
    switch (kind) {
      case NewNodeKind.note:
        openNoteEditor(context, parentId: folderId);
      case NewNodeKind.folder:
        final String? name = await showNameSheet(
          context,
          title: l.notes_addFolder,
          primaryLabel: l.notes_createFolder,
        );
        if (name == null || !context.mounted) return;
        try {
          await ref.read(notesServiceProvider).createFolder(parentId: folderId, name: name);
        } catch (error) {
          if (context.mounted) showDomainError(context, error);
        }
    }
  }
}

/// Back button (labelled with the parent) and the Node_Menu of the Current_Folder.
class _FolderBar extends ConsumerWidget {
  const _FolderBar({required this.tree, required this.folder});

  final NoteTree tree;
  final NoteNode folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final NoteNode? parent = folder.parentId == null ? null : tree.byId(folder.parentId!);
    final String parentName = parent?.name ?? l.notes_title;
    final void Function(int?) open = ref.read(currentFolderProvider.notifier).open;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s8, Space.s4, Space.s8, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                label: l.a11y_breadcrumbTo(parentName),
                excludeSemantics: true,
                onTap: () => open(parent?.id),
                child: InkWell(
                  key: const ValueKey<String>('notes-back'),
                  onTap: () => open(parent?.id),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppIcon(IconAsset.chevronLeft, size: Metrics.iconSmall, color: p.brassText),
                        const SizedBox(width: Space.s4),
                        Flexible(
                          child: Text(
                            parentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodyText.bodyLarge!.copyWith(
                              color: p.brassText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          NodeMenuButton(
            enabled: true,
            onSelected: (NodeMenuAction action) async {
              switch (action) {
                case NodeMenuAction.rename:
                  await renameNode(context, ref, folder);
                case NodeMenuAction.move:
                  await moveNode(context, ref, folder);
                case NodeMenuAction.trash:
                  if (await trashNode(context, ref, folder)) open(folder.parentId);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends ConsumerWidget {
  const _TitleRow({required this.tree, required this.folder});

  final NoteTree? tree;
  final NoteNode? folder;

  /// Width of [text] on one line at the current text scale.
  static double _width(BuildContext context, String text, TextStyle style) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final double width = painter.width;
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final QuestlogPalette p = context.palette;
    final String title = folder?.name ?? l.notes_title;
    final String counts = tree == null
        ? ''
        : countsLabel(l, tree!.folderCount(folder?.id), tree!.noteCount(folder?.id));
    final TextStyle titleStyle = context.displayText.headlineLarge!;
    final TextStyle countsStyle = context.bodyText.bodySmall!.copyWith(color: p.textDim);
    final bool hasTrash = folder == null;
    final double trashWidth = hasTrash ? Space.s4 + Metrics.touchTarget : 0;

    /// A single word is shrunk to fit rather than broken in the middle (down to
    /// half its size); several words wrap and a huge one is cut with an ellipsis.
    Widget heading(double available) {
      final bool oneWord = !title.trim().contains(' ');
      final double natural = _width(context, title, titleStyle);
      final Widget text = oneWord && natural > available && natural <= available * 2
          ? FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(title, maxLines: 1, style: titleStyle),
            )
          : Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: titleStyle);
      return Semantics(header: true, child: text);
    }

    final Widget countsText = Text(
      counts,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: countsStyle,
    );
    final Widget? trash = hasTrash
        ? Padding(
            padding: const EdgeInsets.only(left: Space.s4),
            child: TrashButton(
              count: ref.watch(trashCountProvider),
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute<void>(builder: (_) => const TrashScreen()),
              ),
            ),
          )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          // The title is never squeezed to half a row: when it and the counts do
          // not fit side by side, the counts go under it.
          final bool sideBySide =
              _width(context, title, titleStyle) + Space.s12 + _width(context, counts, countsStyle) + trashWidth <=
              box.maxWidth;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (sideBySide) ...<Widget>[
                // Not Flexible: it would split the row evenly with the counts, and the
                // title would get half of it. It has its natural width; the counts take the rest.
                heading(box.maxWidth - trashWidth),
                const SizedBox(width: Space.s12),
                Expanded(
                  child: Align(alignment: AlignmentDirectional.centerEnd, child: countsText),
                ),
              ] else
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      heading(box.maxWidth - trashWidth),
                      const SizedBox(height: Space.s4),
                      countsText,
                    ],
                  ),
                ),
              ?trash,
            ],
          );
        },
      ),
    );
  }
}

class _NodeList extends ConsumerWidget {
  const _NodeList({required this.tree, required this.folderId});

  final NoteTree tree;
  final int? folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final DateTime now = ref.watch(clockProvider).now();
    final List<NoteNode> children = tree.children(folderId);
    final List<NoteNode> folders = children.where((n) => n.isFolder).toList();
    final List<NoteNode> notes = children.where((n) => !n.isFolder).toList();
    final void Function(int?) open = ref.read(currentFolderProvider.notifier).open;

    Widget swipe(NoteNode node, Widget child) => NodeSwipeRow(
      name: node.name,
      onRename: () => renameNode(context, ref, node),
      onMove: () => moveNode(context, ref, node),
      onDelete: () => trashNode(context, ref, node),
      child: child,
    );

    final List<Widget> items = <Widget>[
      if (folders.isNotEmpty) BoardSectionHeader(label: l.notes_sectionFolders, figure: ''),
      for (final NoteNode f in folders)
        _Item(
          key: ValueKey<int>(f.id),
          child: swipe(
            f,
            FolderRow(
              name: f.name,
              summary: folderSummary(l, tree, f.id),
              onTap: () => open(f.id),
            ),
          ),
        ),
      if (notes.isNotEmpty) BoardSectionHeader(label: l.notes_sectionNotes, figure: ''),
      for (final NoteNode n in notes)
        _Item(
          key: ValueKey<int>(n.id),
          child: swipe(
            n,
            NoteRow(
              name: n.name,
              date: noteDateLabel(l, n.updatedAt, now),
              preview: notePreview(n.body, skipFirstLine: n.autoName),
              onTap: () => openNoteEditor(context, noteId: n.id, parentId: n.parentId),
            ),
          ),
        ),
    ];
    return SlidableAutoCloseBehavior(
      child: ListView(
        padding: const EdgeInsets.only(bottom: Metrics.fab + Space.s48),
        children: items,
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(Space.s20, 0, Space.s20, Space.s10),
    child: child,
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l.notes_errorGeneric, style: context.bodyText.bodyLarge),
          const SizedBox(height: Space.s12),
          TextButton(onPressed: onRetry, child: Text(l.common_retry)),
        ],
      ),
    );
  }
}
