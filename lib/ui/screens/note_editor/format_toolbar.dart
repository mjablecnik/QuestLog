import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

import '../../../l10n/app_localizations.dart';
import '../../sheets/notes/link_sheet.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// The bar of formatting buttons above the keyboard: bold, italic, heading,
/// bulleted list, checklist, quote, code and link. It scrolls sideways when it
/// does not fit, and shows the button of every format at the caret as selected.
class FormatToolbar extends StatelessWidget {
  const FormatToolbar({
    super.key,
    required this.editor,
    required this.document,
    required this.composer,
  });

  final Editor editor;
  final MutableDocument document;
  final MutableDocumentComposer composer;

  // ---- reading the state at the caret ----

  DocumentSelection? get _selection => composer.selection;

  TextNode? get _node {
    final DocumentSelection? selection = _selection;
    if (selection == null) return null;
    final DocumentNode? node = document.getNodeById(selection.extent.nodeId);
    return node is TextNode ? node : null;
  }

  /// The selected character range inside one node, or null for a selection
  /// across several nodes, no selection, or a node that is not text.
  SpanRange? get _range {
    final DocumentSelection? selection = _selection;
    final TextNode? node = _node;
    if (selection == null || node == null || selection.base.nodeId != selection.extent.nodeId) {
      return null;
    }
    final int a = (selection.base.nodePosition as TextNodePosition).offset;
    final int b = (selection.extent.nodePosition as TextNodePosition).offset;
    return SpanRange(a < b ? a : b, (a < b ? b : a) - 1);
  }

  bool get _expanded {
    final SpanRange? range = _range;
    return range != null && range.end >= range.start;
  }

  bool _inlineActive(Attribution attribution) {
    final TextNode? node = _node;
    final SpanRange? range = _range;
    if (node == null || range == null) return false;
    if (_expanded) {
      return node.text.hasAttributionsThroughout(
        attributions: <Attribution>{attribution},
        range: range,
      );
    }
    return composer.preferences.currentAttributions.contains(attribution);
  }

  Object? _blockType(TextNode node) => node is ParagraphNode ? node.getMetadataValue('blockType') : null;

  bool _blockActive(NamedAttribution type) {
    final TextNode? node = _node;
    return node is ParagraphNode && _blockType(node) == type;
  }

  bool get _headingActive {
    final TextNode? node = _node;
    if (node is! ParagraphNode) return false;
    final Object? type = _blockType(node);
    return type == header1Attribution || type == header2Attribution || type == header3Attribution;
  }

  bool get _listActive {
    final TextNode? node = _node;
    return node is ListItemNode && node.type == ListItemType.unordered;
  }

  bool get _checklistActive => _node is TaskNode;

  // ---- changing the document ----

  void _toggleInline(Attribution attribution) {
    final SpanRange? range = _range;
    final DocumentSelection? selection = _selection;
    if (range == null || selection == null) return;
    if (_expanded) {
      editor.execute(<EditRequest>[
        ToggleTextAttributionsRequest(
          documentRange: selection.normalize(document),
          attributions: <Attribution>{attribution},
        ),
      ]);
    } else {
      composer.preferences.toggleStyle(attribution);
    }
  }

  /// Turns the current list or task item into a paragraph so that a block
  /// command can change it, and returns the node's id.
  String _asParagraph(TextNode node) {
    if (node is ListItemNode) {
      editor.execute(<EditRequest>[ConvertListItemToParagraphRequest(nodeId: node.id)]);
    } else if (node is TaskNode) {
      editor.execute(<EditRequest>[ConvertTaskToParagraphRequest(nodeId: node.id)]);
    }
    return node.id;
  }

  void _setBlockType(TextNode node, Attribution? type) {
    final String id = _asParagraph(node);
    editor.execute(<EditRequest>[ChangeParagraphBlockTypeRequest(nodeId: id, blockType: type)]);
  }

  void _cycleHeading() {
    final TextNode? node = _node;
    if (node == null) return;
    final Object? type = _blockType(node);
    final Attribution? next = type == header1Attribution
        ? header2Attribution
        : type == header2Attribution
        ? header3Attribution
        : type == header3Attribution
        ? null
        : header1Attribution;
    _setBlockType(node, next);
  }

  void _toggleBlock(NamedAttribution type) {
    final TextNode? node = _node;
    if (node == null) return;
    _setBlockType(node, _blockActive(type) ? null : type);
  }

  void _toggleList() {
    final TextNode? node = _node;
    if (node == null) return;
    if (node is ListItemNode) {
      if (node.type == ListItemType.unordered) {
        editor.execute(<EditRequest>[ConvertListItemToParagraphRequest(nodeId: node.id)]);
      } else {
        editor.execute(<EditRequest>[
          ChangeListItemTypeRequest(nodeId: node.id, newType: ListItemType.unordered),
        ]);
      }
      return;
    }
    final String id = _asParagraph(node);
    if (_blockType(document.getNodeById(id)! as TextNode) != null) {
      editor.execute(<EditRequest>[ChangeParagraphBlockTypeRequest(nodeId: id, blockType: null)]);
    }
    editor.execute(<EditRequest>[
      ConvertParagraphToListItemRequest(nodeId: id, type: ListItemType.unordered),
    ]);
  }

  void _toggleChecklist() {
    final TextNode? node = _node;
    if (node == null) return;
    if (node is TaskNode) {
      editor.execute(<EditRequest>[ConvertTaskToParagraphRequest(nodeId: node.id)]);
      return;
    }
    final String id = _asParagraph(node);
    if (_blockType(document.getNodeById(id)! as TextNode) != null) {
      editor.execute(<EditRequest>[ChangeParagraphBlockTypeRequest(nodeId: id, blockType: null)]);
    }
    editor.execute(<EditRequest>[ConvertParagraphToTaskRequest(nodeId: id)]);
  }

  /// Code is inline for a selection and a whole block when nothing is selected.
  void _toggleCode() {
    if (_expanded) {
      _toggleInline(codeAttribution);
    } else {
      _toggleBlock(codeAttribution);
    }
  }

  Future<void> _link(BuildContext context) async {
    final DocumentSelection? selection = _selection;
    final TextNode? node = _node;
    final SpanRange? range = _range;
    if (selection == null || node == null || range == null) return;
    // The sheet takes the focus and may change the selection, so read it first.
    final DocumentRange documentRange = selection.normalize(document);
    final bool expanded = _expanded;
    String existing = '';
    if (expanded) {
      for (final Attribution a in node.text.getAllAttributionsAt(range.start)) {
        if (a is LinkAttribution) existing = a.plainTextUri;
      }
    }
    final String? address = await showLinkSheet(context, initial: existing);
    if (address == null) return;
    final LinkAttribution link = LinkAttribution.fromUri(Uri.parse(address));
    if (expanded) {
      editor.execute(<EditRequest>[
        AddTextAttributionsRequest(documentRange: documentRange, attributions: <Attribution>{link}),
      ]);
    } else {
      // Nothing selected: the address itself becomes the linked text.
      final AttributedText text = AttributedText(address)
        ..addAttribution(link, SpanRange(0, address.length - 1));
      editor.execute(<EditRequest>[InsertAttributedTextRequest(selection.extent, text)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[composer.selectionNotifier, composer.preferences]),
      builder: (BuildContext context, Widget? _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: p.boardRaised,
            border: Border(top: BorderSide(color: p.boardLine, width: Metrics.hairline)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s4),
              child: Row(
                children: <Widget>[
                  _Button(
                    buttonKey: 'bold',
                    icon: IconAsset.bold,
                    label: l.editor_fmtBold,
                    active: _inlineActive(boldAttribution),
                    onTap: () => _toggleInline(boldAttribution),
                  ),
                  _Button(
                    buttonKey: 'italic',
                    icon: IconAsset.italic,
                    label: l.editor_fmtItalic,
                    active: _inlineActive(italicsAttribution),
                    onTap: () => _toggleInline(italicsAttribution),
                  ),
                  _Button(
                    buttonKey: 'heading',
                    icon: IconAsset.heading,
                    label: l.editor_fmtHeading,
                    active: _headingActive,
                    onTap: _cycleHeading,
                  ),
                  _Button(
                    buttonKey: 'list',
                    icon: IconAsset.list,
                    label: l.editor_fmtList,
                    active: _listActive,
                    onTap: _toggleList,
                  ),
                  _Button(
                    buttonKey: 'checklist',
                    icon: IconAsset.checklist,
                    label: l.editor_fmtChecklist,
                    active: _checklistActive,
                    onTap: _toggleChecklist,
                  ),
                  _Button(
                    buttonKey: 'quote',
                    icon: IconAsset.quote,
                    label: l.editor_fmtQuote,
                    active: _blockActive(blockquoteAttribution),
                    onTap: () => _toggleBlock(blockquoteAttribution),
                  ),
                  _Button(
                    buttonKey: 'code',
                    icon: IconAsset.code,
                    label: l.editor_fmtCode,
                    active: _inlineActive(codeAttribution) || _blockActive(codeAttribution),
                    onTap: _toggleCode,
                  ),
                  _Button(
                    buttonKey: 'link',
                    icon: IconAsset.link,
                    label: l.editor_fmtLink,
                    active: _hasLink,
                    onTap: () => _link(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool get _hasLink {
    final TextNode? node = _node;
    final SpanRange? range = _range;
    if (node == null || range == null) return false;
    final int offset = _expanded ? range.start : (range.start > 0 ? range.start - 1 : 0);
    return node.text.getAllAttributionsAt(offset).any((Attribution a) => a is LinkAttribution);
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String buttonKey;
  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s2),
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: Material(
          color: active ? p.brassSoft : p.field.withValues(alpha: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.control),
            side: active ? BorderSide(color: p.brass, width: Metrics.hairline) : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey<String>('fmt-$buttonKey'),
            onTap: onTap,
            canRequestFocus: false,
            child: SizedBox(
              width: Metrics.touchTarget,
              height: Metrics.touchTarget,
              child: Center(
                child: AppIcon(icon, size: Metrics.iconSmall + Space.s2, color: active ? p.brassText : p.textDim),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
