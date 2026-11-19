import 'package:drift/drift.dart';

import '../../core/notes/note_node.dart';
import '../database.dart';

extension NoteNodeRowMapper on NoteNodeRow {
  NoteNode toNode() => NoteNode(
        id: id,
        parentId: parentId,
        isFolder: isFolder,
        name: name,
        body: isFolder ? '' : body,
        autoName: autoName,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}

/// A companion for inserting [node] without its id (the database assigns it).
NoteNodesCompanion noteNodeToInsert(NoteNode node) => NoteNodesCompanion.insert(
      parentId: Value<int?>(node.parentId),
      isFolder: node.isFolder,
      name: node.name,
      body: Value<String>(node.isFolder ? '' : node.body),
      autoName: Value<bool>(node.autoName),
      createdAt: node.createdAt,
      updatedAt: node.updatedAt,
      deletedAt: Value<DateTime?>(node.deletedAt),
    );
