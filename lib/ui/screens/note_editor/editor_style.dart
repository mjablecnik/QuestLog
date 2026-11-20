import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Families tried, in order, for code; the first one the device has is used.
const List<String> _monospaceFamilies = <String>['Menlo', 'Roboto Mono', 'Courier', 'monospace'];

/// Line height of running text in the editor.
const double _lineHeight = 1.55;

/// Smaller than body text, so code reads as code next to it.
const double _codeScale = 0.9;

/// The look of the Note_Editor, built from the Design_Tokens: body text in the
/// body face, headings in the display face, links in the accent colour and
/// code in a monospace face on a tinted ground.
Stylesheet buildEditorStylesheet(BuildContext context) {
  final QuestlogPalette p = context.palette;
  final TextStyle body = context.bodyText.bodyLarge!.copyWith(color: p.text, height: _lineHeight);
  final TextTheme display = context.displayText;

  TextStyle heading(TextStyle style) => style.copyWith(color: p.text);

  return Stylesheet(
    documentPadding: EdgeInsets.zero,
    inlineTextStyler: (Set<Attribution> attributions, TextStyle existing) {
      TextStyle style = defaultInlineTextStyler(attributions, existing);
      for (final Attribution attribution in attributions) {
        if (attribution == codeAttribution) {
          style = style.copyWith(
            fontFamily: _monospaceFamilies.first,
            fontFamilyFallback: _monospaceFamilies,
            fontSize: (existing.fontSize ?? body.fontSize!) * _codeScale,
            backgroundColor: p.field,
          );
        } else if (attribution is LinkAttribution) {
          style = style.copyWith(
            color: p.brassText,
            decoration: TextDecoration.underline,
            decorationColor: p.brassText,
          );
        }
      }
      return style;
    },
    rules: <StyleRule>[
      StyleRule(BlockSelector.all, (Document doc, DocumentNode node) {
        return <String, dynamic>{
          Styles.maxWidth: double.infinity,
          Styles.padding: const CascadingPadding.only(top: Space.s12),
          Styles.textStyle: body,
        };
      }),
      StyleRule(const BlockSelector('header1'), (Document doc, DocumentNode node) {
        return <String, dynamic>{
          Styles.padding: const CascadingPadding.only(top: Space.s16),
          Styles.textStyle: heading(display.headlineMedium!),
        };
      }),
      StyleRule(const BlockSelector('header2'), (Document doc, DocumentNode node) {
        return <String, dynamic>{
          Styles.padding: const CascadingPadding.only(top: Space.s16),
          Styles.textStyle: heading(display.titleLarge!),
        };
      }),
      StyleRule(const BlockSelector('header3'), (Document doc, DocumentNode node) {
        return <String, dynamic>{
          Styles.padding: const CascadingPadding.only(top: Space.s12),
          Styles.textStyle: heading(display.titleMedium!),
        };
      }),
      StyleRule(const BlockSelector('listItem'), (Document doc, DocumentNode node) {
        return <String, dynamic>{Styles.padding: const CascadingPadding.only(top: Space.s4)};
      }),
      StyleRule(const BlockSelector('task'), (Document doc, DocumentNode node) {
        // The 44 point row of a task already gives it air; only a hairline of extra space.
        return <String, dynamic>{Styles.padding: const CascadingPadding.only(top: Space.s2)};
      }),
      StyleRule(const BlockSelector('blockquote'), (Document doc, DocumentNode node) {
        return <String, dynamic>{
          Styles.textStyle: body.copyWith(color: p.textDim),
          Styles.backgroundColor: p.field,
          Styles.borderRadius: BorderRadius.circular(Radii.control),
        };
      }),
      StyleRule(const BlockSelector('code'), (Document doc, DocumentNode node) {
        return <String, dynamic>{
          Styles.textStyle: body.copyWith(
            fontFamily: _monospaceFamilies.first,
            fontFamilyFallback: _monospaceFamilies,
            fontSize: body.fontSize! * _codeScale,
            height: _lineHeight,
          ),
        };
      }),
      StyleRule(BlockSelector.all.last(), (Document doc, DocumentNode node) {
        return <String, dynamic>{Styles.padding: const CascadingPadding.only(bottom: Space.s64)};
      }),
    ],
  );
}

SelectionStyles buildSelectionStyles(QuestlogPalette p) =>
    SelectionStyles(selectionColor: p.brassSoft);

/// The overlays of the editor: the package's own list with the accent colour
/// set. On iOS they draw the caret, the selection handles and the anchor of the
/// Cut, Copy and Paste toolbar; on Android the same; on desktop the caret. A
/// list with the desktop caret alone leaves iOS with no caret and no handles.
List<SuperEditorLayerBuilder> buildEditorOverlays(QuestlogPalette p) => <SuperEditorLayerBuilder>[
  const SuperEditorIosToolbarFocalPointDocumentLayerBuilder(),
  SuperEditorIosHandlesDocumentLayerBuilder(handleColor: p.brass, caretWidth: Space.s2),
  const SuperEditorAndroidToolbarFocalPointDocumentLayerBuilder(),
  SuperEditorAndroidHandlesDocumentLayerBuilder(caretColor: p.brass, caretWidth: Space.s2),
  DefaultCaretOverlayBuilder(caretStyle: CaretStyle(width: Space.s2, color: p.brass)),
];
