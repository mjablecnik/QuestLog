/// One Folder or Note of the notes tree, independent of the database.
///
/// A Folder always has an empty [body]. A node whose [parentId] is null lies in
/// the Root_Folder. [deletedAt] is set only on the node that was moved to the
/// Trash; everything inside a trashed Folder keeps a null [deletedAt] and is
/// hidden because an ancestor is trashed.
final class NoteNode {
  const NoteNode({
    required this.id,
    required this.parentId,
    required this.isFolder,
    required this.name,
    required this.body,
    required this.autoName,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final int id;
  final int? parentId;
  final bool isFolder;

  /// 1 to 80 characters, trimmed.
  final String name;

  /// The Markdown_Body of a Note; always empty for a Folder.
  final String body;

  /// True while the name follows the first non-empty line of the text.
  final bool autoName;
  final DateTime createdAt;

  /// Last edit of a Note's text; for a Folder its creation time.
  final DateTime updatedAt;
  final DateTime? deletedAt;

  NoteNode copyWith({
    int? Function()? parentId,
    String? name,
    String? body,
    bool? autoName,
    DateTime? updatedAt,
    DateTime? Function()? deletedAt,
  }) {
    return NoteNode(
      id: id,
      parentId: parentId != null ? parentId() : this.parentId,
      isFolder: isFolder,
      name: name ?? this.name,
      body: body ?? this.body,
      autoName: autoName ?? this.autoName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NoteNode &&
      other.id == id &&
      other.parentId == parentId &&
      other.isFolder == isFolder &&
      other.name == name &&
      other.body == body &&
      other.autoName == autoName &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt;

  @override
  int get hashCode => Object.hash(
        id,
        parentId,
        isFolder,
        name,
        body,
        autoName,
        createdAt,
        updatedAt,
        deletedAt,
      );

  @override
  String toString() => 'NoteNode($id, ${isFolder ? 'folder' : 'note'}, "$name", parent $parentId)';
}
