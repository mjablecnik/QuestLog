import '../calendar/calendar_dates.dart' show searchKey;
import 'note_node.dart';
import 'trash_policy.dart';

/// Every rule about the notes tree, over the list of all stored nodes.
///
/// Pure Dart: it imports neither Flutter nor Drift. A node is visible when
/// neither it nor any ancestor is trashed; every listing, count and breadcrumb
/// only ever sees visible nodes.
final class NoteTree {
  NoteTree(Iterable<NoteNode> nodes)
      : _byId = <int, NoteNode>{for (final NoteNode n in nodes) n.id: n} {
    for (final NoteNode n in _byId.values) {
      (_childrenOf[n.parentId] ??= <NoteNode>[]).add(n);
    }
  }

  final Map<int, NoteNode> _byId;
  final Map<int?, List<NoteNode>> _childrenOf = <int?, List<NoteNode>>{};

  Iterable<NoteNode> get all => _byId.values;

  NoteNode? byId(int id) => _byId[id];

  /// True when neither [id] nor any of its ancestors has a deletion time.
  /// An unknown id, or one whose parent chain is broken, is not visible.
  bool isVisible(int id) {
    final Set<int> seen = <int>{};
    int? current = id;
    while (current != null) {
      if (!seen.add(current)) return false;
      final NoteNode? node = _byId[current];
      if (node == null || node.deletedAt != null) return false;
      current = node.parentId;
    }
    return true;
  }

  /// Visible children of [parentId] (null is the Root_Folder): Folders by
  /// `searchKey(name)`, then Notes by last edit, newest first; ties by id.
  List<NoteNode> children(int? parentId) {
    if (parentId != null && !isVisible(parentId)) return const <NoteNode>[];
    final List<NoteNode> direct = (_childrenOf[parentId] ?? const <NoteNode>[])
        .where((n) => n.deletedAt == null)
        .toList();
    final List<NoteNode> folders = direct.where((n) => n.isFolder).toList()
      ..sort((a, b) {
        final int byName = searchKey(a.name).compareTo(searchKey(b.name));
        return byName != 0 ? byName : a.id.compareTo(b.id);
      });
    final List<NoteNode> notes = direct.where((n) => !n.isFolder).toList()
      ..sort((a, b) {
        final int byDate = b.updatedAt.compareTo(a.updatedAt);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });
    return <NoteNode>[...folders, ...notes];
  }

  /// Folders from the first below the Root_Folder down to [folderId], inclusive.
  List<NoteNode> breadcrumb(int? folderId) {
    final List<NoteNode> path = <NoteNode>[];
    final Set<int> seen = <int>{};
    int? current = folderId;
    while (current != null && seen.add(current)) {
      final NoteNode? node = _byId[current];
      if (node == null) break;
      path.add(node);
      current = node.parentId;
    }
    return path.reversed.toList();
  }

  /// Visible Folders directly inside [folderId].
  int folderCount(int? folderId) => children(folderId).where((n) => n.isFolder).length;

  /// Visible Notes directly inside [folderId].
  int noteCount(int? folderId) => children(folderId).where((n) => !n.isFolder).length;

  /// Visible Notes at any depth inside [folderId].
  int noteCountDeep(int folderId) {
    int count = 0;
    for (final NoteNode child in children(folderId)) {
      count += child.isFolder ? noteCountDeep(child.id) : 1;
    }
    return count;
  }

  /// Visible Folders at any depth inside [folderId].
  int folderCountDeep(int folderId) {
    int count = 0;
    for (final NoteNode child in children(folderId)) {
      if (child.isFolder) count += 1 + folderCountDeep(child.id);
    }
    return count;
  }

  /// Notes inside the Folder at any depth, for a Folder that is in the Trash:
  /// everything that was trashed with it, not what was trashed on its own earlier.
  int containedNotesCount(int folderId) {
    int count = 0;
    for (final NoteNode child in _childrenOf[folderId] ?? const <NoteNode>[]) {
      if (child.deletedAt != null) continue;
      count += child.isFolder ? containedNotesCount(child.id) : 1;
    }
    return count;
  }

  /// True when anything visible lies inside the Folder.
  bool hasContent(int folderId) => children(folderId).isNotEmpty;

  /// [id] and everything inside it, whatever its visibility.
  Set<int> subtreeIds(int id) {
    final Set<int> result = <int>{};
    final List<int> queue = <int>[id];
    while (queue.isNotEmpty) {
      final int next = queue.removeLast();
      if (!result.add(next)) continue;
      for (final NoteNode child in _childrenOf[next] ?? const <NoteNode>[]) {
        queue.add(child.id);
      }
    }
    return result;
  }

  /// True when [id] may be placed under [targetParentId] (null is the
  /// Root_Folder): both exist and are visible, the target is a Folder that is
  /// neither the node itself nor inside it, and it is not already the parent.
  bool canMove(int id, int? targetParentId) {
    final NoteNode? node = _byId[id];
    if (node == null || !isVisible(id)) return false;
    if (targetParentId == node.parentId) return false;
    if (targetParentId == null) return true;
    final NoteNode? target = _byId[targetParentId];
    if (target == null || !target.isFolder || !isVisible(targetParentId)) return false;
    return !subtreeIds(id).contains(targetParentId);
  }

  /// Every node with a deletion time, the one nearest to its Purge first.
  List<NoteNode> trashEntries() {
    final List<NoteNode> entries = _byId.values.where((n) => n.deletedAt != null).toList()
      ..sort((a, b) {
        final int byDate = a.deletedAt!.compareTo(b.deletedAt!);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });
    return entries;
  }

  /// Where a restored node goes: its parent when that Folder exists and is
  /// visible, otherwise the Root_Folder (null).
  int? restoreTarget(int id) {
    final int? parentId = _byId[id]?.parentId;
    if (parentId == null) return null;
    final NoteNode? parent = _byId[parentId];
    return parent != null && parent.isFolder && isVisible(parentId) ? parentId : null;
  }

  /// Ids whose Trash_Retention has passed at [now], with everything inside them.
  Set<int> expiredIds(DateTime now) {
    final Set<int> result = <int>{};
    for (final NoteNode entry in trashEntries()) {
      if (isExpired(entry.deletedAt!, now)) result.addAll(subtreeIds(entry.id));
    }
    return result;
  }
}
