import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_editor/super_editor.dart';

import '../../../core/notes/note_node.dart';
import '../../../core/notes/note_tree.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/notes/notes_providers.dart';
import '../../state/quest_actions.dart' show showDomainError;
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../note_editor/editor_style.dart';
import '../note_editor/note_markdown.dart';
import '../note_editor/note_task_component.dart';
import 'trash_row.dart';

/// Opens the read-only preview of the trashed Note [noteId]. Completes with
/// true when the Note was restored from the preview.
Future<bool?> openTrashPreview(BuildContext context, int noteId) {
  return Navigator.of(context).push<bool>(
    CupertinoPageRoute<bool>(builder: (_) => TrashPreviewScreen(noteId: noteId)),
  );
}

/// A trashed Note to read before it is restored or lost: its name, its text
/// formatted as in the Note_Editor but not editable (no caret, no keyboard, no
/// toolbar, a check cannot be toggled) and the Obnovit pill. Opening it changes
/// nothing about the Note. The preview closes when the Note stops being a
/// Trashed_Node, for example because it was purged.
class TrashPreviewScreen extends ConsumerStatefulWidget {
  const TrashPreviewScreen({super.key, required this.noteId});

  final int noteId;

  @override
  ConsumerState<TrashPreviewScreen> createState() => _TrashPreviewScreenState();
}

class _TrashPreviewScreenState extends ConsumerState<TrashPreviewScreen> {
  MutableDocumentComposer? _composer;
  Editor? _editor;
  bool _empty = true;
  bool _closing = false;

  /// Builds the document from the stored text once; the preview never edits it.
  void _ensureDocument(String body) {
    if (_editor != null) return;
    final MutableDocument document = documentFromMarkdown(body);
    _empty = body.trim().isEmpty;
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(document: document, composer: _composer!);
  }

  @override
  void dispose() {
    _composer?.dispose();
    _editor?.dispose();
    super.dispose();
  }

  Future<void> _restore(NoteNode node) async {
    _closing = true;
    try {
      await ref.read(notesServiceProvider).restore(node.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      _closing = false;
      if (mounted) showDomainError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final NoteTree? tree = ref.watch(noteTreeProvider).value;
    final NoteNode? node = tree?.byId(widget.noteId);
    if (tree != null && (node == null || node.deletedAt == null) && !_closing) {
      // Purged, or restored elsewhere: nothing is left to preview.
      _closing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
    if (node != null) _ensureDocument(node.body);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s8, Space.s4, Space.s16, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        button: true,
                        label: l.common_back,
                        excludeSemantics: true,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: InkWell(
                          key: const ValueKey<String>('preview-back'),
                          onTap: () => Navigator.of(context).maybePop(),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                AppIcon(IconAsset.chevronLeft, size: Metrics.iconSmall, color: p.brassText),
                                const SizedBox(width: Space.s4),
                                Text(
                                  l.trash_title,
                                  style: context.bodyText.bodyLarge!.copyWith(
                                    color: p.brassText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (node != null)
                    RestorePill(
                      name: node.name,
                      onPressed: () => _restore(node),
                      buttonKey: const ValueKey<String>('preview-restore'),
                    ),
                ],
              ),
            ),
            if (node != null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.s20, Space.s8, Space.s20, Space.s4),
                child: Semantics(
                  header: true,
                  child: Text(
                    node.name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.displayText.headlineMedium,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s20),
                  child: _empty
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: Space.s12),
                            child: Text(
                              l.trash_previewEmpty,
                              style: context.bodyText.bodyLarge!.copyWith(color: p.textFaint),
                            ),
                          ),
                        )
                      : SuperReader(
                          key: const ValueKey<String>('trash-preview-text'),
                          editor: _editor!,
                          stylesheet: buildEditorStylesheet(context),
                          selectionStyle: buildSelectionStyles(p),
                          componentBuilders: <ComponentBuilder>[
                            NoteTaskComponentBuilder.readOnly(toggleLabel: l.a11y_taskToggle),
                            ...readOnlyDefaultComponentBuilders,
                          ],
                        ),
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}
