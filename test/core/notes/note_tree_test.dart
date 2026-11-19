import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/calendar/calendar_dates.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/notes/note_tree.dart';
import 'package:questlog/core/notes/trash_policy.dart';

import '_tree_gen.dart';

NoteNode node(
  int id, {
  int? parent,
  bool folder = false,
  String name = 'n',
  DateTime? updated,
  DateTime? deleted,
}) => NoteNode(
  id: id,
  parentId: parent,
  isFolder: folder,
  name: name,
  body: '',
  autoName: false,
  createdAt: treeEpoch,
  updatedAt: updated ?? treeEpoch,
  deletedAt: deleted,
);

void main() {
  final Glados<int> anySeed = Glados(any.intInRange(0, 1 << 20));

  group('visibility (Property 2)', () {
    anySeed.test('a node is visible iff no node on its path has deletedAt', (seed) {
      final List<NoteNode> nodes = randomTree(seed);
      final NoteTree tree = NoteTree(nodes);
      for (final NoteNode n in nodes) {
        bool expected = true;
        int? cur = n.id;
        while (cur != null) {
          final NoteNode c = tree.byId(cur)!;
          if (c.deletedAt != null) expected = false;
          cur = c.parentId;
        }
        expect(tree.isVisible(n.id), expected, reason: '$n');
      }
    });

    anySeed.test('listings, counts and breadcrumbs never contain an invisible node', (seed) {
      final List<NoteNode> nodes = randomTree(seed);
      final NoteTree tree = NoteTree(nodes);
      for (final int? parent in <int?>[null, ...nodes.where((n) => n.isFolder).map((n) => n.id)]) {
        for (final NoteNode c in tree.children(parent)) {
          expect(tree.isVisible(c.id), isTrue);
        }
      }
      for (final NoteNode n in nodes.where((n) => n.isFolder && tree.isVisible(n.id))) {
        for (final NoteNode b in tree.breadcrumb(n.id)) {
          expect(tree.isVisible(b.id), isTrue);
        }
      }
    });

    test('an orphan and an unknown id are not visible', () {
      final NoteTree tree = NoteTree(<NoteNode>[node(2, parent: 99)]);
      expect(tree.isVisible(2), isFalse);
      expect(tree.isVisible(7), isFalse);
    });
  });

  group('listing (Property 3)', () {
    anySeed.test('folders first by searchKey, notes newest first, stable', (seed) {
      final List<NoteNode> nodes = randomTree(seed, trashed: 0);
      final NoteTree tree = NoteTree(nodes);
      for (final int? parent in <int?>[null, ...nodes.where((n) => n.isFolder).map((n) => n.id)]) {
        final List<NoteNode> list = tree.children(parent);
        final int firstNote = list.indexWhere((n) => !n.isFolder);
        if (firstNote >= 0) {
          expect(list.skip(firstNote).every((n) => !n.isFolder), isTrue);
        }
        final List<NoteNode> folders = list.where((n) => n.isFolder).toList();
        for (int i = 1; i < folders.length; i++) {
          expect(searchKey(folders[i - 1].name).compareTo(searchKey(folders[i].name)) <= 0, isTrue);
        }
        final List<NoteNode> notes = list.where((n) => !n.isFolder).toList();
        for (int i = 1; i < notes.length; i++) {
          expect(!notes[i - 1].updatedAt.isBefore(notes[i].updatedAt), isTrue);
        }
        expect(tree.children(parent).map((n) => n.id), list.map((n) => n.id));
      }
    });

    test('folders ignore case and diacritics, ties go by id', () {
      final NoteTree tree = NoteTree(<NoteNode>[
        node(1, folder: true, name: 'Zebra'),
        node(2, folder: true, name: 'čaj'),
        node(3, folder: true, name: 'Abap'),
        node(4, folder: true, name: 'abap'),
      ]);
      expect(tree.children(null).map((n) => n.id), <int>[3, 4, 2, 1]);
    });

    test('children of a note, an unknown id and a trashed folder are empty', () {
      final NoteTree tree = NoteTree(<NoteNode>[
        node(1),
        node(2, folder: true, deleted: treeEpoch),
        node(3, parent: 2),
      ]);
      expect(tree.children(1), isEmpty);
      expect(tree.children(42), isEmpty);
      expect(tree.children(2), isEmpty);
    });
  });

  group('counts (Property 4)', () {
    anySeed.test('deep note count equals the visible notes in the subtree', (seed) {
      final List<NoteNode> nodes = randomTree(seed);
      final NoteTree tree = NoteTree(nodes);
      for (final NoteNode f in nodes.where((n) => n.isFolder)) {
        if (!tree.isVisible(f.id)) continue;
        final int expected = tree
            .subtreeIds(f.id)
            .where((id) => id != f.id)
            .map((id) => tree.byId(id)!)
            .where((n) => !n.isFolder && tree.isVisible(n.id))
            .length;
        expect(tree.noteCountDeep(f.id), expected);
        final int folders = tree
            .subtreeIds(f.id)
            .where((id) => id != f.id)
            .map((id) => tree.byId(id)!)
            .where((n) => n.isFolder && tree.isVisible(n.id))
            .length;
        expect(tree.folderCountDeep(f.id), folders);
        expect(tree.folderCount(f.id) + tree.noteCount(f.id), tree.children(f.id).length);
        expect(tree.hasContent(f.id), tree.children(f.id).isNotEmpty);
      }
    });
  });

  group('moving (Property 1)', () {
    anySeed.test('canMove is false into itself and into its subtree', (seed) {
      final List<NoteNode> nodes = randomTree(seed, trashed: 0);
      final NoteTree tree = NoteTree(nodes);
      for (final NoteNode n in nodes) {
        for (final int id in tree.subtreeIds(n.id)) {
          expect(tree.canMove(n.id, id), isFalse, reason: '${n.id} into $id');
        }
      }
    });

    anySeed.test('after any accepted move every node still reaches the root', (seed) {
      final List<NoteNode> nodes = randomTree(seed, trashed: 0);
      List<NoteNode> current = nodes;
      for (final NoteNode n in nodes) {
        for (final int? target in <int?>[null, ...nodes.where((f) => f.isFolder).map((f) => f.id)]) {
          final NoteTree tree = NoteTree(current);
          if (!tree.canMove(n.id, target)) continue;
          current = <NoteNode>[
            for (final NoteNode c in current) c.id == n.id ? c.copyWith(parentId: () => target) : c,
          ];
          final NoteTree after = NoteTree(current);
          for (final NoteNode c in current) {
            expect(after.isVisible(c.id), isTrue, reason: 'move ${n.id} -> $target broke ${c.id}');
          }
          break;
        }
      }
    });

    test('rejects the current parent, notes, trashed and unknown targets', () {
      final NoteTree tree = NoteTree(<NoteNode>[
        node(1, folder: true),
        node(2, parent: 1),
        node(3, folder: true, deleted: treeEpoch),
        node(4),
      ]);
      expect(tree.canMove(2, 1), isFalse);
      expect(tree.canMove(2, null), isTrue);
      expect(tree.canMove(2, 3), isFalse);
      expect(tree.canMove(2, 4), isFalse);
      expect(tree.canMove(2, 99), isFalse);
      expect(tree.canMove(99, null), isFalse);
      expect(tree.canMove(3, null), isFalse, reason: 'a trashed node cannot be moved');
      expect(tree.canMove(4, 1), isTrue);
    });
  });

  group('trash', () {
    anySeed.test('restoreTarget is the parent when visible, else the root (Property 5)', (seed) {
      final List<NoteNode> nodes = randomTree(seed);
      final NoteTree tree = NoteTree(nodes);
      for (final NoteNode e in tree.trashEntries()) {
        final int? p = e.parentId;
        final bool parentOk = p != null && tree.byId(p) != null && tree.isVisible(p);
        expect(tree.restoreTarget(e.id), parentOk ? p : null);
      }
    });

    anySeed.test('expiredIds holds exactly expired entries and their subtrees (Property 8)', (seed) {
      final List<NoteNode> nodes = randomTree(seed);
      final NoteTree tree = NoteTree(nodes);
      final DateTime now = treeEpoch.add(Duration(days: 30 + seed % 40));
      final Set<int> expected = <int>{};
      for (final NoteNode n in nodes) {
        if (n.deletedAt != null && !now.isBefore(n.deletedAt!.add(trashRetention))) {
          expected.addAll(tree.subtreeIds(n.id));
        }
      }
      expect(tree.expiredIds(now), expected);
      for (final int id in tree.expiredIds(now)) {
        int? cur = id;
        bool underExpired = false;
        while (cur != null) {
          final NoteNode c = tree.byId(cur)!;
          if (c.deletedAt != null && isExpired(c.deletedAt!, now)) underExpired = true;
          cur = c.parentId;
        }
        expect(underExpired, isTrue);
      }
    });

    test('entries are ordered by deletion time and a restored folder becomes visible', () {
      final DateTime a = treeEpoch;
      final NoteTree tree = NoteTree(<NoteNode>[
        node(1, folder: true, deleted: a.add(const Duration(days: 2))),
        node(2, parent: 1),
        node(3, deleted: a),
      ]);
      expect(tree.trashEntries().map((n) => n.id), <int>[3, 1]);
      expect(tree.isVisible(2), isFalse);
      expect(tree.restoreTarget(3), isNull);
    });

    test('a node trashed before its folder is purged on its own, the rest later', () {
      final NoteTree tree = NoteTree(<NoteNode>[
        node(1, folder: true, deleted: treeEpoch.add(const Duration(days: 10))),
        node(2, parent: 1, deleted: treeEpoch),
        node(3, parent: 1),
      ]);
      expect(tree.expiredIds(treeEpoch.add(const Duration(days: 31))), <int>{2});
      expect(tree.expiredIds(treeEpoch.add(const Duration(days: 41))), <int>{1, 2, 3});
    });
  });

  test('containedNotesCount counts what was trashed with the folder, not earlier trashed nodes', () {
    final NoteTree tree = NoteTree(<NoteNode>[
      node(1, folder: true, deleted: treeEpoch),
      node(2, parent: 1),
      node(3, parent: 1, folder: true),
      node(4, parent: 3),
      node(5, parent: 3, deleted: treeEpoch.subtract(const Duration(days: 1))),
      node(6, parent: 1, folder: true, deleted: treeEpoch.subtract(const Duration(days: 2))),
      node(7, parent: 6),
    ]);
    expect(tree.containedNotesCount(1), 2);
    expect(tree.containedNotesCount(3), 1);
  });

  test('breadcrumb lists the folders from the top, subtree includes the node itself', () {
    final NoteTree tree = NoteTree(<NoteNode>[
      node(1, folder: true),
      node(2, parent: 1, folder: true),
      node(3, parent: 2),
    ]);
    expect(tree.breadcrumb(2).map((n) => n.id), <int>[1, 2]);
    expect(tree.breadcrumb(null), isEmpty);
    expect(tree.subtreeIds(1), <int>{1, 2, 3});
  });
}
