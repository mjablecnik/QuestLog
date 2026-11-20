import 'package:drift/drift.dart';

import '../../core/clock.dart';
import '../../core/errors.dart';
import '../../core/notes/note_node.dart';
import '../../core/notes/note_title.dart';
import '../../core/notes/note_tree.dart';
import '../../core/validation.dart';
import '../../data/database.dart';
import '../../data/notes/notes_mappers.dart';

/// The longest Markdown_Body of a Note, in characters.
const int maxBodyLength = 100000;

/// Creates, edits, moves, trashes, restores and purges Folders and Notes and
/// streams the tree. It never touches XP, Quests, Missions or the Calendar.
class NotesService {
  NotesService(this._db, this._clock);

  final QuestlogDatabase _db;
  final Clock _clock;

  /// All stored nodes, Trashed_Nodes included, ordered by id; re-emits on every change.
  Stream<List<NoteNode>> watchAll() {
    final SimpleSelectStatement<$NoteNodesTable, NoteNodeRow> query = _db.select(_db.noteNodes)
      ..orderBy(<OrderingTerm Function($NoteNodesTable)>[(t) => OrderingTerm.asc(t.id)]);
    return query.watch().map((rows) => rows.map((r) => r.toNode()).toList());
  }

  // ---- writes ----

  Future<NoteNode> createFolder({int? parentId, required String name}) async {
    final String valid = validatedName(name, 'name');
    return _db.runTransaction(() async {
      await _requireFolderOrRoot(parentId);
      final DateTime now = _clock.now();
      final int id = await _db.into(_db.noteNodes).insert(
            NoteNodesCompanion.insert(
              parentId: Value<int?>(parentId),
              isFolder: true,
              name: valid,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return (await _load(id)).toNode();
    });
  }

  /// Creates the Note, or updates it when [id] is given.
  ///
  /// [title] is what the user typed in the title field: null leaves the naming
  /// as it is, a non-blank title (trimmed) becomes the name and ends the
  /// Automatic_Name, a blank one restores the Automatic_Name. While the Note has
  /// an Automatic_Name its name follows the first non-empty line of [body];
  /// [untitledName] is used when no line gives a name.
  ///
  /// A new Note is only created when [title] is non-blank or [body] is not
  /// blank; otherwise null is returned. Saving what is already stored writes
  /// nothing.
  Future<NoteNode?> saveBody({
    int? id,
    int? parentId,
    required String body,
    required String untitledName,
    String? title,
  }) async {
    if (body.runes.length > maxBodyLength) {
      throw const ValidationError('body', 'must be at most $maxBodyLength characters');
    }
    final bool hasTitle = title != null && title.trim().isNotEmpty;
    final String? chosenName = hasTitle ? validatedName(title, 'name') : null;
    return _db.runTransaction(() async {
      final DateTime now = _clock.now();
      if (id == null) {
        if (body.trim().isEmpty && !hasTitle) return null;
        await _requireFolderOrRoot(parentId);
        final int newId = await _db.into(_db.noteNodes).insert(
              NoteNodesCompanion.insert(
                parentId: Value<int?>(parentId),
                isFolder: false,
                name: chosenName ?? _autoName(body, untitledName),
                body: Value<String>(body),
                autoName: Value<bool>(!hasTitle),
                createdAt: now,
                updatedAt: now,
              ),
            );
        return (await _load(newId)).toNode();
      }
      final NoteNodeRow row = await _load(id);
      if (row.isFolder) throw const InvalidStateError('a Folder has no text');
      if (!(await _tree()).isVisible(id)) {
        throw const InvalidStateError('a Trashed_Node cannot be edited');
      }
      final bool autoName = title == null ? row.autoName : !hasTitle;
      final String name = chosenName ?? (autoName ? _autoName(body, untitledName) : row.name);
      if (row.body == body && row.name == name && row.autoName == autoName) return row.toNode();
      await (_db.update(_db.noteNodes)..where((t) => t.id.equals(id))).write(
        NoteNodesCompanion(
          body: Value<String>(body),
          updatedAt: Value<DateTime>(now),
          name: Value<String>(name),
          autoName: Value<bool>(autoName),
        ),
      );
      return (await _load(id)).toNode();
    });
  }

  /// Renames a Node. A Note keeps the chosen name from then on and its
  /// last-edited date does not change.
  Future<void> rename(int id, String name) async {
    final String valid = validatedName(name, 'name');
    await _db.runTransaction(() async {
      await _load(id);
      if (!(await _tree()).isVisible(id)) {
        throw const InvalidStateError('a Trashed_Node cannot be renamed');
      }
      await (_db.update(_db.noteNodes)..where((t) => t.id.equals(id))).write(
        NoteNodesCompanion(name: Value<String>(valid), autoName: const Value<bool>(false)),
      );
    });
  }

  /// Makes [targetParentId] (null is the Root_Folder) the parent of [id]. The
  /// last-edited date does not change.
  Future<void> move(int id, int? targetParentId) async {
    await _db.runTransaction(() async {
      await _load(id);
      if (!(await _tree()).canMove(id, targetParentId)) {
        throw InvalidStateError('node $id cannot be moved to $targetParentId');
      }
      await (_db.update(_db.noteNodes)..where((t) => t.id.equals(id))).write(
        NoteNodesCompanion(parentId: Value<int?>(targetParentId)),
      );
    });
  }

  /// Moves a Node, with everything inside it, to the Trash.
  Future<void> moveToTrash(int id) async {
    await _db.runTransaction(() async {
      final NoteNodeRow row = await _load(id);
      if (row.deletedAt != null || !(await _tree()).isVisible(id)) {
        throw NotFoundError('note node', id);
      }
      await (_db.update(_db.noteNodes)..where((t) => t.id.equals(id))).write(
        NoteNodesCompanion(deletedAt: Value<DateTime?>(_clock.now())),
      );
    });
  }

  /// Takes a Trashed_Node out of the Trash, back to the Folder it came from or,
  /// when that is gone or trashed, to the Root_Folder.
  Future<void> restore(int id) async {
    await _db.runTransaction(() async {
      final NoteNodeRow row = await _load(id);
      if (row.deletedAt == null) throw const InvalidStateError('the node is not in the Trash');
      final int? target = (await _tree()).restoreTarget(id);
      await (_db.update(_db.noteNodes)..where((t) => t.id.equals(id))).write(
        NoteNodesCompanion(parentId: Value<int?>(target), deletedAt: const Value<DateTime?>(null)),
      );
    });
  }

  /// Deletes a Trashed_Node and everything inside it permanently.
  Future<void> deleteForever(int id) async {
    await _db.runTransaction(() async {
      final NoteNodeRow row = await _load(id);
      if (row.deletedAt == null) throw const InvalidStateError('only a Trashed_Node can be deleted for good');
      await (_db.delete(_db.noteNodes)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Deletes every Trashed_Node permanently; returns how many there were.
  Future<int> emptyTrash() {
    return _db.runTransaction(() async {
      final List<NoteNode> entries = (await _tree()).trashEntries();
      await (_db.delete(_db.noteNodes)..where((t) => t.deletedAt.isNotNull())).go();
      return entries.length;
    });
  }

  /// Deletes the Trashed_Nodes whose Trash_Retention has passed, with what is
  /// inside them; returns how many Trashed_Nodes that were.
  Future<int> purgeExpired() {
    return _db.runTransaction(() async {
      final DateTime now = _clock.now();
      final NoteTree tree = await _tree();
      final List<int> expired = <int>[
        for (final NoteNode entry in tree.trashEntries())
          if (tree.expiredIds(now).contains(entry.id)) entry.id,
      ];
      if (expired.isEmpty) return 0;
      await (_db.delete(_db.noteNodes)..where((t) => t.id.isIn(expired))).go();
      return expired.length;
    });
  }

  // ---- helpers ----

  Future<NoteNodeRow> _load(int id) async {
    final NoteNodeRow? row =
        await (_db.select(_db.noteNodes)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw NotFoundError('note node', id);
    return row;
  }

  Future<NoteTree> _tree() async {
    final List<NoteNodeRow> rows = await _db.select(_db.noteNodes).get();
    return NoteTree(rows.map((r) => r.toNode()));
  }

  /// The parent of a new node must be the Root_Folder or a visible Folder.
  Future<void> _requireFolderOrRoot(int? parentId) async {
    if (parentId == null) return;
    final NoteNodeRow parent = await _load(parentId);
    if (!parent.isFolder) throw const InvalidStateError('a Note cannot contain other nodes');
    if (!(await _tree()).isVisible(parentId)) {
      throw const InvalidStateError('the Folder is in the Trash');
    }
  }

  String _autoName(String body, String untitledName) =>
      deriveNoteName(body) ?? validatedName(untitledName, 'name');
}
