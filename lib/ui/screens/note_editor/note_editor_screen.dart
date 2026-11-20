import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_editor/super_editor.dart';

import '../../../core/notes/note_node.dart';
import '../../../core/notes/note_tree.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/notes/notes_providers.dart';
import '../../state/notes_state.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../notes/node_menu.dart';
import '../notes/notes_actions.dart';
import 'editor_style.dart';
import 'format_toolbar.dart';
import 'note_markdown.dart';
import 'note_task_component.dart';
import 'note_title_field.dart';

/// Opens the Note_Editor on the Note [noteId], or on a new Note in [parentId]
/// (null is the Root_Folder) when [noteId] is null.
void openNoteEditor(BuildContext context, {int? noteId, int? parentId}) {
  Navigator.of(context).push(
    CupertinoPageRoute<void>(
      builder: (_) => NoteEditorScreen(noteId: noteId, parentId: parentId),
    ),
  );
}

/// Full-screen WYSIWYG editor of one Note's text. The text is saved by itself
/// shortly after the last change, and at once when the editor is left or the
/// app goes to the background. A new Note is only created by its first
/// non-empty save.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.noteId, this.parentId});

  final int? noteId;
  final int? parentId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen>
    with WidgetsBindingObserver {
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;
  late final Editor _editor;
  late final TextEditingController _title;
  final FocusNode _focus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  NoteSaveController? _save;

  /// False until the stored text is known and the editor is built.
  bool _ready = false;
  ProviderSubscription<AsyncValue<List<NoteNode>>>? _firstRead;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final int? id = widget.noteId;
    if (id == null) {
      _initEditor('', '');
    } else {
      final NoteTree? tree = ref.read(noteTreeProvider).value;
      if (tree != null) {
        final NoteNode? node = tree.byId(id);
        _initEditor(node?.body ?? '', _titleOf(node));
      } else {
        // The notes were not read yet (this screen was opened before the list);
        // wait for the first read so that no stored text is replaced by an empty one.
        _firstRead = ref.listenManual<AsyncValue<List<NoteNode>>>(noteNodesProvider, (_, next) {
          final List<NoteNode>? nodes = next.value;
          if (nodes == null || _ready || !mounted) return;
          _firstRead?.close();
          final Iterable<NoteNode> found = nodes.where((NoteNode n) => n.id == id);
          final NoteNode? node = found.isEmpty ? null : found.first;
          setState(() => _initEditor(node?.body ?? '', _titleOf(node)));
        });
      }
    }
  }

  /// What the title field shows: the name the user chose; empty while the name
  /// follows the first line of the text.
  static String _titleOf(NoteNode? node) => node == null || node.autoName ? '' : node.name;

  void _initEditor(String body, String title) {
    _title = TextEditingController(text: title);
    _document = documentFromMarkdown(body);
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(document: _document, composer: _composer);
    _document.addListener(_onDocumentChanged);
    _ready = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _save ??= NoteSaveController(
      ref.read(notesServiceProvider),
      noteId: widget.noteId,
      parentId: widget.parentId,
      untitledName: AppLocalizations.of(context).notes_untitled,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _firstRead?.close();
    final NoteSaveController? save = _save;
    if (save != null) unawaited(save.flush().whenComplete(save.dispose));
    _focus.dispose();
    _titleFocus.dispose();
    if (_ready) {
      _title.dispose();
      _document.removeListener(_onDocumentChanged);
      _composer.dispose();
      _editor.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_save?.flush());
  }

  void _markChanged() {
    _save?.markChanged(() => markdownFromDocument(_document), readTitle: () => _title.text);
  }

  void _onDocumentChanged(DocumentChangeLog _) {
    _markChanged();
    if (mounted) setState(() {});
  }

  /// A rename from the menu changes the name behind the field's back: show it.
  /// A name that only echoes a save of what is typed (or a save still waiting)
  /// is left alone, so typing is never overwritten.
  void _followRename(NoteTree? tree) {
    final int? id = _save?.noteId;
    final NoteNode? node = id == null ? null : tree?.byId(id);
    if (!_ready || node == null || node.autoName) return;
    if (_save!.hasUnsavedChanges || _save!.status.value != SaveStatus.idle) return;
    if (node.name == _title.text.trim()) return;
    _title.value = TextEditingValue(
      text: node.name,
      selection: TextSelection.collapsed(offset: node.name.length),
    );
  }

  /// Saves, and closes only when nothing is left unsaved.
  Future<void> _close() async {
    final NoteSaveController? save = _save;
    if (save == null) return;
    await save.flush();
    if (!mounted) return;
    if (save.status.value == SaveStatus.idle) Navigator.of(context).pop();
  }

  NoteNode? get _node {
    final int? id = _save?.noteId;
    return id == null ? null : ref.read(noteTreeProvider).value?.byId(id);
  }

  Future<void> _onMenu(NodeMenuAction action) async {
    await _save?.flush();
    final NoteNode? node = _node;
    if (node == null || !mounted) return;
    switch (action) {
      case NodeMenuAction.rename:
        await renameNode(context, ref, node);
      case NodeMenuAction.move:
        await moveNode(context, ref, node);
      case NodeMenuAction.trash:
        if (await trashNode(context, ref, node) && mounted) Navigator.of(context).pop();
    }
  }

  /// Return in the title field: the text takes over, with the caret at its start.
  void _focusBody() {
    final DocumentNode first = _document.first;
    if (first is TextNode) {
      _editor.execute(<EditRequest>[
        ChangeSelectionRequest(
          DocumentSelection.collapsed(
            position: DocumentPosition(nodeId: first.id, nodePosition: const TextNodePosition(offset: 0)),
          ),
          SelectionChangeType.placeCaret,
          SelectionReason.userInteraction,
        ),
      ]);
    }
    _focus.requestFocus();
  }

  bool get _isEmpty =>
      _ready &&
      _document.nodeCount == 1 &&
      (_document.first is TextNode) &&
      (_document.first as TextNode).text.toPlainText().isEmpty;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    if (!_ready) return const Scaffold(body: SizedBox.shrink());
    final NoteSaveController save = _save!;
    ref.listen<AsyncValue<NoteTree>>(noteTreeProvider, (_, AsyncValue<NoteTree> next) => _followRename(next.value));
    final NoteTree? tree = ref.watch(noteTreeProvider).value;
    final NoteNode? node = save.noteId == null ? null : tree?.byId(save.noteId!);
    final int? parentId = node?.parentId ?? widget.parentId;
    final String parentName =
        (parentId == null ? null : tree?.byId(parentId)?.name) ?? l.notes_title;

    return ValueListenableBuilder<SaveStatus>(
      valueListenable: save.status,
      builder: (BuildContext context, SaveStatus status, Widget? _) {
        return PopScope(
          canPop: !save.hasUnsavedChanges && status == SaveStatus.idle,
          onPopInvokedWithResult: (bool didPop, Object? _) {
            if (!didPop) unawaited(_close());
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _TopBar(
                    parentName: parentName,
                    menuEnabled: node != null,
                    onBack: _close,
                    onDone: _close,
                    onMenu: _onMenu,
                  ),
                  if (status == SaveStatus.failed || status == SaveStatus.tooLong)
                    _Banner(
                      message: status == SaveStatus.failed ? l.editor_saveFailed : l.editor_tooLong,
                      onRetry: status == SaveStatus.failed ? () => unawaited(save.flush()) : null,
                    ),
                  NoteTitleField(
                    controller: _title,
                    focusNode: _titleFocus,
                    autofocus: widget.noteId == null,
                    onChanged: (_) => _markChanged(),
                    onSubmitted: _focusBody,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s20),
                      child: Stack(
                        children: <Widget>[
                          SuperEditor(
                            editor: _editor,
                            focusNode: _focus,
                            stylesheet: buildEditorStylesheet(context),
                            selectionStyle: buildSelectionStyles(p),
                            documentOverlayBuilders: buildEditorOverlays(p),
                            contentTapDelegateFactories: const [],
                            componentBuilders: <ComponentBuilder>[
                              ...defaultComponentBuilders,
                              NoteTaskComponentBuilder(_editor, toggleLabel: l.a11y_taskToggle),
                            ],
                          ),
                          if (_isEmpty)
                            Positioned(
                              left: 0,
                              top: Space.s12,
                              child: IgnorePointer(
                                child: Text(
                                  l.editor_hint,
                                  style: context.bodyText.bodyLarge!.copyWith(color: p.textFaint),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  FormatToolbar(editor: _editor, document: _document, composer: _composer),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.parentName,
    required this.menuEnabled,
    required this.onBack,
    required this.onDone,
    required this.onMenu,
  });

  final String parentName;
  final bool menuEnabled;
  final VoidCallback onBack;
  final VoidCallback onDone;
  final ValueChanged<NodeMenuAction> onMenu;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
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
                onTap: onBack,
                child: InkWell(
                  key: const ValueKey<String>('editor-back'),
                  onTap: onBack,
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
          NodeMenuButton(enabled: menuEnabled, onSelected: onMenu),
          Semantics(
            button: true,
            label: l.editor_done,
            excludeSemantics: true,
            onTap: onDone,
            child: InkWell(
              key: const ValueKey<String>('editor-done'),
              onTap: onDone,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Metrics.touchTarget,
                  minWidth: Metrics.touchTarget,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s8),
                    child: Text(
                      l.editor_done,
                      style: context.bodyText.bodyLarge!.copyWith(
                        color: p.brassText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.s20, Space.s4, Space.s20, Space.s4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: p.field,
            borderRadius: BorderRadius.circular(Radii.control),
            border: Border.all(color: p.destructive, width: Metrics.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.s12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.s8),
                    child: Text(message, style: context.bodyText.bodyMedium),
                  ),
                ),
                if (onRetry != null)
                  TextButton(
                    key: const ValueKey<String>('editor-retry'),
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(Metrics.touchTarget, Metrics.touchTarget),
                      foregroundColor: p.brassText,
                    ),
                    child: Text(l.common_retry),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
