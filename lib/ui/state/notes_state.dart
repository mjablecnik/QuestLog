import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/notes/note_node.dart';
import '../../core/notes/note_tree.dart';
import '../../services/notes/notes_providers.dart';
import '../../services/notes/notes_service.dart';
import '../theme/tokens.dart';

/// The Folder the Notes_Screen last showed; null is the Root_Folder. It is
/// kept while the user visits other tabs.
final currentFolderProvider = NotifierProvider<CurrentFolderNotifier, int?>(
  CurrentFolderNotifier.new,
);

class CurrentFolderNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void open(int? folderId) => state = folderId;
}

/// The Current_Folder, or the Root_Folder when that Folder is gone or trashed.
final visibleFolderProvider = Provider<int?>((ref) {
  final int? id = ref.watch(currentFolderProvider);
  final NoteTree? tree = ref.watch(noteTreeProvider).value;
  if (id == null || tree == null) return id;
  final NoteNode? node = tree.byId(id);
  return node != null && node.isFolder && tree.isVisible(id) ? id : null;
});

/// Where a save of the Note_Editor stands.
enum SaveStatus { idle, saving, failed, tooLong }

/// Saves the name and the text of one Note: after [Motion.autosave] without a change, and at
/// once on [flush]. Saves never overlap. A failed save keeps the text dirty so
/// that [flush] (the retry) writes it again; a too long text waits for the next edit.
class NoteSaveController {
  NoteSaveController(
    this._service, {
    required this._noteId,
    required this.parentId,
    required this.untitledName,
    this._delay = Motion.autosave,
  });

  final NotesService _service;
  final int? parentId;
  final String untitledName;
  final Duration _delay;

  int? _noteId;
  NoteNode? _saved;
  Timer? _timer;
  String Function()? _read;
  String Function()? _readTitle;
  bool _dirty = false;
  bool _disposed = false;
  Future<void> _chain = Future<void>.value();

  /// Where the save stands, for the banner of the editor.
  final ValueNotifier<SaveStatus> status = ValueNotifier<SaveStatus>(SaveStatus.idle);

  /// The id of the Note once it was saved for the first time; null before.
  int? get noteId => _noteId;

  /// The last saved node; null until a non-empty text was saved.
  NoteNode? get saved => _saved;

  /// True while a change is waiting to be written.
  bool get hasUnsavedChanges => _dirty;

  /// The text or the title changed: restart the pause before the save.
  /// [readTitle] reads the title field; without it the naming is left as it is.
  void markChanged(String Function() readMarkdown, {String Function()? readTitle}) {
    _read = readMarkdown;
    _readTitle = readTitle ?? _readTitle;
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(_delay, () => unawaited(flush()));
  }

  /// Writes a pending change now; completes when the write has finished.
  Future<void> flush() {
    _timer?.cancel();
    _chain = _chain.then((_) => _flushOnce());
    return _chain;
  }

  Future<void> _flushOnce() async {
    final String Function()? read = _read;
    if (!_dirty || read == null || _disposed) return;
    _dirty = false;
    final String body = read();
    final String? title = _readTitle?.call();
    _setStatus(SaveStatus.saving);
    try {
      final NoteNode? node = await _service.saveBody(
        id: _noteId,
        parentId: parentId,
        body: body,
        untitledName: untitledName,
        title: title,
      );
      if (node != null) {
        _noteId = node.id;
        _saved = node;
      }
      _setStatus(SaveStatus.idle);
    } on ValidationError {
      _setStatus(SaveStatus.tooLong);
    } catch (_) {
      _dirty = true;
      _setStatus(SaveStatus.failed);
    }
  }

  void _setStatus(SaveStatus value) {
    if (!_disposed) status.value = value;
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    status.dispose();
  }
}
