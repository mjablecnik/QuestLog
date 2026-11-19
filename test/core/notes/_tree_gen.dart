import 'dart:math';

import 'package:questlog/core/notes/note_node.dart';

final DateTime treeEpoch = DateTime(2026, 11, 1, 12);

/// A random but valid tree: parents are always earlier Folders (or none).
List<NoteNode> randomTree(int seed, {double trashed = 0.2, int maxNodes = 26}) {
  final Random random = Random(seed);
  final int count = 1 + random.nextInt(maxNodes);
  final List<NoteNode> nodes = <NoteNode>[];
  final List<int> folderIds = <int>[];
  for (int id = 1; id <= count; id++) {
    final bool isFolder = random.nextInt(3) == 0;
    final int? parent = folderIds.isEmpty || random.nextInt(4) == 0
        ? null
        : folderIds[random.nextInt(folderIds.length)];
    nodes.add(
      NoteNode(
        id: id,
        parentId: parent,
        isFolder: isFolder,
        name: _names[random.nextInt(_names.length)],
        body: '',
        autoName: false,
        createdAt: treeEpoch,
        updatedAt: treeEpoch.add(Duration(hours: random.nextInt(500))),
        deletedAt: random.nextDouble() < trashed
            ? treeEpoch.add(Duration(days: random.nextInt(60), hours: random.nextInt(24)))
            : null,
      ),
    );
    if (isFolder) folderIds.add(id);
  }
  return nodes;
}

const List<String> _names = <String>[
  'Abap', 'ábel', 'Zebra', 'čaj', 'Cestování', 'domov', 'Domov', 'Nápady', 'řeka', 'Šum', 'a', 'B',
];
