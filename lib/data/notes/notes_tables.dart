// The CHECK constraints reference their own column getter, which is the
// documented Drift pattern, so the recursive_getters lint does not apply here.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

/// One Folder or Note of the notes tree. A null `parent_id` lies in the
/// Root_Folder; deleting a Folder row deletes everything inside it. A node
/// moved to the Trash keeps its parent and gets a `deleted_at`.
@DataClassName('NoteNodeRow')
@TableIndex(name: 'idx_note_nodes_parent', columns: {#parentId})
@TableIndex(name: 'idx_note_nodes_deleted', columns: {#deletedAt})
class NoteNodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get parentId =>
      integer().nullable().references(NoteNodes, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isFolder => boolean()();
  TextColumn get name => text().check(name.trim().length.isBetweenValues(1, 80))();

  /// The Markdown_Body; always empty for a Folder.
  TextColumn get body =>
      text().withDefault(const Constant('')).check(body.length.isSmallerOrEqualValue(100000))();
  BoolColumn get autoName => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
