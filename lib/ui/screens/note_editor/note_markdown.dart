import 'package:super_editor/super_editor.dart';

/// Converts between the stored Markdown_Body of a Note and the editor document.
///
/// The editor package's own Markdown codec is lossy for text typed in a
/// WYSIWYG editor (`<fs_line>`, `* comment`, a literal fence and `[x](y)` all
/// come back changed, and code blocks gain whitespace on every pass), so this
/// adapter escapes plain text on the way out and keeps raw HTML as text on the
/// way in. The Supported_Formatting round-trips; other constructs the parser
/// understands (tables, images, rules, numbered lists) are written back by the
/// package.
const MarkdownSyntax _syntax = MarkdownSyntax.normal;

final RegExp _fenceLine = RegExp(r'^\s*(```|~~~)');
final RegExp _inlineCode = RegExp(r'`[^`]*`');
final RegExp _listItemLine = RegExp(r'^\s*([-*+]|\d+[.)])\s');
final RegExp _rawHtml = RegExp(r'(?<!\\)<(?=[A-Za-z/!?])');
final RegExp _orderedStart = RegExp(r'^\d+(?=[.)](\s|$))');
final RegExp _blockStart = RegExp(r'^(#{1,6}(\s|$)|>|[-+](\s|$)|(-{3,}|\*{3,}|_{3,}|={3,})\s*$)');
const String _specials = r'\`*_[]<~&';

/// Parses [markdown] into an editable document, never empty.
MutableDocument documentFromMarkdown(String markdown) {
  if (markdown.trim().isEmpty) {
    return MutableDocument(
      nodes: <DocumentNode>[ParagraphNode(id: Editor.createNodeId(), text: AttributedText())],
    );
  }
  final MutableDocument parsed = deserializeMarkdownToDocument(
    _keepRawHtmlAsText(markdown),
    syntax: _syntax,
  );
  final List<DocumentNode> nodes = <DocumentNode>[
    for (final DocumentNode node in parsed)
      if (node is ParagraphNode && node.getMetadataValue('blockType') == codeAttribution)
        _trimCodeBlock(node)
      else if (node is ListItemNode || node is TaskNode)
        _trimLineBreaks(node as TextNode)
      else
        node,
  ];
  if (nodes.isEmpty) {
    nodes.add(ParagraphNode(id: Editor.createNodeId(), text: AttributedText()));
  }
  return MutableDocument(nodes: nodes);
}

/// Serializes [document] to Markdown that [documentFromMarkdown] reads back as
/// the same text. A document with no text gives an empty string.
String markdownFromDocument(Document document) {
  final MutableDocument escaped = MutableDocument(
    nodes: <DocumentNode>[for (final DocumentNode node in document) _escapeNode(node)],
  );
  final String markdown = serializeDocumentToMarkdown(
    escaped,
    syntax: _syntax,
    customNodeSerializers: const <DocumentNodeMarkdownSerializer>[
      _CodeBlockSerializer(),
      _QuoteSerializer(),
      _ListSerializer(),
    ],
  );
  return markdown.trim().isEmpty ? '' : markdown.trimRight();
}

/// Raw HTML would be dropped by the parser, so a `<` that starts a tag is
/// escaped to stay visible as text; a list written with blank lines between its
/// items is made tight, because the parser loses a checked box in a loose list.
/// Fenced code is left alone.
String _keepRawHtmlAsText(String markdown) {
  bool inFence = false;
  final List<String> out = <String>[];
  final List<bool> code = <bool>[];
  for (final String line in markdown.split('\n')) {
    if (_fenceLine.hasMatch(line)) {
      inFence = !inFence;
      out.add(line);
      code.add(true);
      continue;
    }
    if (inFence) {
      out.add(line);
      code.add(true);
      continue;
    }
    code.add(false);
    // A `<` inside inline code is code, not a tag.
    out.add(line.splitMapJoin(
      _inlineCode,
      onMatch: (Match m) => m[0]!,
      onNonMatch: (String s) => s.replaceAll(_rawHtml, r'\<'),
    ));
  }
  // Drop a blank line that sits between two list items.
  final List<String> tight = <String>[];
  for (int i = 0; i < out.length; i++) {
    final bool blank = !code[i] && out[i].trim().isEmpty;
    if (blank && tight.isNotEmpty && _listItemLine.hasMatch(tight.last)) {
      int next = i + 1;
      while (next < out.length && !code[next] && out[next].trim().isEmpty) {
        next++;
      }
      if (next < out.length && !code[next] && _listItemLine.hasMatch(out[next])) {
        i = next - 1;
        continue;
      }
    }
    tight.add(out[i]);
  }
  return tight.join('\n');
}

/// A list written with blank lines between its items (a loose list) gives each
/// item a line break at its start or end; the editor shows items without it.
DocumentNode _trimLineBreaks(TextNode node) {
  final String text = node.text.toPlainText();
  int start = 0;
  int end = text.length;
  while (start < end && text[start] == '\n') {
    start++;
  }
  while (end > start && text[end - 1] == '\n') {
    end--;
  }
  if (start == 0 && end == text.length) return node;
  final AttributedText trimmed = node.text.copyText(start, end);
  if (node is TaskNode) {
    return TaskNode(id: node.id, text: trimmed, isComplete: node.isComplete, indent: node.indent, metadata: node.metadata);
  }
  final ListItemNode item = node as ListItemNode;
  return ListItemNode(id: item.id, itemType: item.type, text: trimmed, indent: item.indent, metadata: item.metadata);
}

ParagraphNode _trimCodeBlock(ParagraphNode node) {
  final String text = node.text.toPlainText();
  if (!text.endsWith('\n')) return node;
  return ParagraphNode(
    id: node.id,
    text: node.text.copyText(0, text.length - 1),
    metadata: node.metadata,
  );
}

DocumentNode _escapeNode(DocumentNode node) {
  if (node is ParagraphNode) {
    final Object? type = node.getMetadataValue('blockType');
    if (type == codeAttribution) return node;
    // A heading's text cannot start a new block; every other block's text can.
    final bool heading = type == header1Attribution ||
        type == header2Attribution ||
        type == header3Attribution ||
        type == header4Attribution ||
        type == header5Attribution ||
        type == header6Attribution;
    return ParagraphNode(
      id: node.id,
      text: _escapeText(node.text, blockStart: !heading, heading: heading),
      metadata: node.metadata,
    );
  }
  if (node is ListItemNode) {
    return ListItemNode(
      id: node.id,
      itemType: node.type,
      indent: node.indent,
      text: _escapeText(node.text, blockStart: true),
      metadata: node.metadata,
    );
  }
  if (node is TaskNode) {
    return TaskNode(
      id: node.id,
      isComplete: node.isComplete,
      indent: node.indent,
      text: _escapeText(node.text, blockStart: true),
      metadata: node.metadata,
    );
  }
  return node;
}

/// Puts a backslash before every character that Markdown would read as markup,
/// except inside inline code, and before a block marker at the start of any
/// block that is not a heading.
AttributedText _escapeText(AttributedText text, {required bool blockStart, bool heading = false}) {
  final String plain = text.toPlainText();
  // A trailing run of `#` would be read as the closing sequence of a heading.
  final String specials = heading ? '$_specials#' : _specials;
  AttributedText result = text;
  for (int i = plain.length - 1; i >= 0; i--) {
    if (!specials.contains(plain[i])) continue;
    if (text.getAllAttributionsAt(i).contains(codeAttribution)) continue;
    result = result.insertString(textToInsert: r'\', startOffset: i);
  }
  if (blockStart) {
    final int? at = _orderedStart.firstMatch(plain)?.end ?? (_blockStart.hasMatch(plain) ? 0 : null);
    if (at != null) {
      // The digits of "1. x" are not escaped characters, so `at` needs no shift;
      // a marker character at offset 0 is not in [_specials] except `*` and `_`,
      // which were escaped above, so only skip it then.
      final bool alreadyEscaped = at == 0 && specials.contains(plain[0]);
      if (!alreadyEscaped) result = result.insertString(textToInsert: r'\', startOffset: at);
    }
  }
  return result;
}

class _CodeBlockSerializer implements DocumentNodeMarkdownSerializer {
  const _CodeBlockSerializer();

  @override
  String? serialize(Document document, DocumentNode node, {NodeSelection? selection}) {
    if (node is! ParagraphNode || node.getMetadataValue('blockType') != codeAttribution) return null;
    final StringBuffer out = StringBuffer('```\n${node.text.toPlainText()}\n```');
    if (document.getNodeIndexById(node.id) != document.nodeCount - 1) out.writeln();
    return out.toString();
  }
}

class _QuoteSerializer implements DocumentNodeMarkdownSerializer {
  const _QuoteSerializer();

  @override
  String? serialize(Document document, DocumentNode node, {NodeSelection? selection}) {
    if (node is! ParagraphNode || node.getMetadataValue('blockType') != blockquoteAttribution) return null;
    final String inline = node.text.toMarkdown();
    final StringBuffer out = StringBuffer(inline.split('\n').map((String l) => '> $l').join('\n'));
    if (document.getNodeIndexById(node.id) != document.nodeCount - 1) out.writeln();
    return out.toString();
  }
}

/// List items and checklist items on consecutive lines, four spaces per level,
/// and a blank line after the last one so that a following paragraph is not
/// read as a continuation of the item.
class _ListSerializer implements DocumentNodeMarkdownSerializer {
  const _ListSerializer();

  @override
  String? serialize(Document document, DocumentNode node, {NodeSelection? selection}) {
    final String marker;
    final int indent;
    if (node is TaskNode) {
      marker = node.isComplete ? '- [x] ' : '- [ ] ';
      indent = node.indent;
    } else if (node is ListItemNode) {
      marker = node.type == ListItemType.unordered ? '- ' : '1. ';
      indent = node.indent;
    } else {
      return null;
    }
    final StringBuffer out = StringBuffer('${'    ' * indent}$marker${(node as TextNode).text.toMarkdown()}');
    final int index = document.getNodeIndexById(node.id);
    final DocumentNode? below = index < document.nodeCount - 1 ? document.getNodeAt(index + 1) : null;
    if (below != null && below is! ListItemNode && below is! TaskNode) out.writeln();
    return out.toString();
  }
}
