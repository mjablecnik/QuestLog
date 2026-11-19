import 'package:intl/intl.dart';

import '../../../core/notes/note_dates.dart';
import '../../../core/notes/note_tree.dart';
import '../../../l10n/app_localizations.dart';

/// "2 složky · 9 poznámek": the non-zero counts joined by a dot; [empty] when both are zero.
String countsLabel(AppLocalizations l, int folders, int notes, {String empty = ''}) {
  final List<String> parts = <String>[
    if (folders > 0) l.notes_folderCount(folders),
    if (notes > 0) l.notes_noteCount(notes),
  ];
  return parts.isEmpty ? empty : parts.join(' · ');
}

/// What a Folder_Row shows: its direct Folders and all Notes inside it.
String folderSummary(AppLocalizations l, NoteTree tree, int folderId) => countsLabel(
  l,
  tree.folderCount(folderId),
  tree.noteCountDeep(folderId),
  empty: l.notes_folderEmpty,
);

/// "dnes", "včera", day and month, or day, month and year.
String noteDateLabel(AppLocalizations l, DateTime edited, DateTime now) {
  switch (noteDateKind(edited, now)) {
    case NoteDateKind.today:
      return l.common_today;
    case NoteDateKind.yesterday:
      return l.common_yesterday;
    case NoteDateKind.thisYear:
      return (l.localeName == 'cs' ? DateFormat.Md(l.localeName) : DateFormat.MMMd(l.localeName))
          .format(edited);
    case NoteDateKind.earlier:
      return DateFormat.yMMMd(l.localeName).format(edited);
  }
}

/// The counts of a Folder that is about to be trashed, as one phrase
/// ("2 složky a 9 poznámek"), for the warning dialog.
String trashContentsLabel(AppLocalizations l, NoteTree tree, int folderId) {
  final int folders = tree.folderCountDeep(folderId);
  final int notes = tree.noteCountDeep(folderId);
  if (folders > 0 && notes > 0) {
    return l.notes_joinAnd(l.notes_folderCount(folders), l.notes_noteCount(notes));
  }
  return folders > 0 ? l.notes_folderCount(folders) : l.notes_noteCount(notes);
}
