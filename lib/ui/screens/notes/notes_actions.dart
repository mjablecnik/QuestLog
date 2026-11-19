import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notes/note_node.dart';
import '../../../core/notes/note_tree.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/notes/notes_providers.dart';
import '../../sheets/notes/move_sheet.dart';
import '../../sheets/notes/name_sheet.dart';
import '../../state/quest_actions.dart' show showDomainError;
import '../../widgets/common/snackbar_host.dart';
import '../../widgets/sheet/confirm_destructive.dart';
import 'notes_labels.dart';

/// Rename, move and trash flows shared by the swipe actions, the Node_Menu of a
/// Folder and the Node_Menu of the Note_Editor, so they all behave the same.

Future<void> renameNode(BuildContext context, WidgetRef ref, NoteNode node) async {
  final AppLocalizations l = AppLocalizations.of(context);
  final String? name = await showNameSheet(
    context,
    title: l.notes_renameTitle,
    primaryLabel: l.common_save,
    initial: node.name,
  );
  if (name == null || !context.mounted) return;
  try {
    await ref.read(notesServiceProvider).rename(node.id, name);
  } catch (error) {
    if (context.mounted) showDomainError(context, error);
  }
}

/// Returns true when the node was moved.
Future<bool> moveNode(BuildContext context, WidgetRef ref, NoteNode node) async {
  final NoteTree? tree = ref.read(noteTreeProvider).value;
  if (tree == null) return false;
  final ({int? target})? choice = await showMoveSheet(context, tree: tree, node: node);
  if (choice == null || !context.mounted) return false;
  try {
    await ref.read(notesServiceProvider).move(node.id, choice.target);
    return true;
  } catch (error) {
    if (context.mounted) showDomainError(context, error);
    return false;
  }
}

/// Moves [node] to the Trash. A Folder with content asks first, with the
/// number of Folders and Notes inside it; a Note and an empty Folder do not.
/// Returns true when the node was moved to the Trash.
Future<bool> trashNode(BuildContext context, WidgetRef ref, NoteNode node) async {
  final AppLocalizations l = AppLocalizations.of(context);
  final NoteTree? tree = ref.read(noteTreeProvider).value;
  if (node.isFolder && tree != null && tree.hasContent(node.id)) {
    final bool confirmed = await confirmDestructive(
      context,
      title: l.notes_deleteFolderTitle(node.name),
      body: l.notes_deleteFolderBody(trashContentsLabel(l, tree, node.id)),
      confirmLabel: l.notes_deleteConfirm,
    );
    if (!confirmed || !context.mounted) return false;
  }
  try {
    await ref.read(notesServiceProvider).moveToTrash(node.id);
  } catch (error) {
    if (context.mounted) showDomainError(context, error);
    return false;
  }
  if (context.mounted) showQuestlogSnack(context, l.notes_movedToTrash);
  return true;
}
