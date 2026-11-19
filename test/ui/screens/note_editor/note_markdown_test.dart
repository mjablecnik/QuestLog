import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/ui/screens/note_editor/note_markdown.dart';
import 'package:super_editor/super_editor.dart';

/// What the editor shows: the kind of every block and its text.
List<String> shape(Document doc) => <String>[
  for (final DocumentNode n in doc)
    if (n is TaskNode)
      'task${n.isComplete ? 'x' : ''}:${n.indent}:${n.text.toPlainText()}'
    else if (n is ListItemNode)
      '${n.type.name}:${n.indent}:${n.text.toPlainText()}'
    else if (n is ParagraphNode)
      '${_kind(n)}:${n.text.toPlainText()}'
    else
      n.runtimeType.toString(),
];

String _kind(ParagraphNode n) {
  final Object? type = n.getMetadataValue('blockType');
  if (type is! NamedAttribution || type.id == 'paragraph') return 'p';
  return type.id;
}

String roundTrip(String md) => markdownFromDocument(documentFromMarkdown(md));

Document docOf(List<DocumentNode> nodes) => MutableDocument(nodes: nodes);
int _id = 0;
String nid() => 'n${_id++}';

ParagraphNode para(String s, {NamedAttribution? type}) => ParagraphNode(
  id: nid(),
  text: AttributedText(s),
  metadata: type == null ? const <String, dynamic>{} : <String, dynamic>{'blockType': type},
);

void main() {
  group('Supported_Formatting round-trips', () {
    const Map<String, String> cases = <String, String>{
      'headings': '# Titulek\n\n## Druhý\n\n### Třetí',
      'inline': 'Text **tučně** a *kurzíva* a `kód` a [odkaz](https://example.com).',
      'bullets': '- jedna\n- dva\n  - vnořená',
      'checklist': '- [ ] otevřený\n- [x] hotový',
      'quote': '> Čti zleva doprava',
      'czech': 'Příliš žluťoučký kůň úpěl ďábelské ódy',
      'mixed': '# Plán\n\nOdstavec s **tučným**.\n\n- [ ] úkol\n- [x] hotovo\n\n> citát\n\nKonec',
    };
    cases.forEach((String name, String md) {
      test(name, () {
        final String once = roundTrip(md);
        expect(roundTrip(once), once, reason: 'stable');
        expect(shape(documentFromMarkdown(once)), shape(documentFromMarkdown(md)));
      });
    });

    test('formatting survives: bold, italic, code and a link', () {
      final MutableDocument doc = documentFromMarkdown('A **b** *i* `c` [l](https://example.com)');
      final TextNode node = doc.first as TextNode;
      expect(node.text.toPlainText(), 'A b i c l');
      expect(node.text.hasAttributionsThroughout(attributions: <Attribution>{boldAttribution}, range: const SpanRange(2, 2)), isTrue);
      expect(node.text.hasAttributionsThroughout(attributions: <Attribution>{italicsAttribution}, range: const SpanRange(4, 4)), isTrue);
      expect(node.text.hasAttributionsThroughout(attributions: <Attribution>{codeAttribution}, range: const SpanRange(6, 6)), isTrue);
      final Set<Attribution> atLink = node.text.getAllAttributionsAt(8);
      expect(atLink.whereType<LinkAttribution>().single.plainTextUri, 'https://example.com');
    });

    test('a fenced code block keeps its text and does not grow on repeated passes', () {
      String md = '```abap\nSELECT * FROM spfli.\n  WRITE x.\n\n* comment\n```';
      final String first = roundTrip(md);
      expect(first, '```\nSELECT * FROM spfli.\n  WRITE x.\n\n* comment\n```');
      for (int i = 0; i < 4; i++) {
        md = roundTrip(first);
        expect(md, first);
      }
      final Document doc = documentFromMarkdown(first);
      expect(shape(doc), <String>['code:SELECT * FROM spfli.\n  WRITE x.\n\n* comment']);
    });

    test('a multi-line quote keeps every line in the quote', () {
      final String md = markdownFromDocument(docOf(<DocumentNode>[
        para('one\ntwo', type: blockquoteAttribution),
        para('after'),
      ]));
      expect(md, contains('> one'));
      expect(md, contains('\n> two'));
      expect(md, endsWith('after'));
    });
  });

  group('text typed in the editor survives', () {
    const List<String> typed = <String>[
      '2 * 3 * 4', 'snake_case_name', '# not a heading', '1. not a list', '- not a bullet', '<div>raw</div>',
      r'back\slash', '[x](y)', 'a | b', '> not a quote', '```', '*star*', 'tilde ~~x~~', '&amp; &lt;',
      'IF a < b AND c > d.', 'ASSIGN <fs_line> TO <fs>.', '* comment line', '---', '+ plus', '1) paren', '  leading spaces',
      '_under_', '**bold** typed literally', '![img](http://x/y.png)', '10. ten', '#hashtag',
    ];
    for (final String s in typed) {
      test(s, () {
        final Document doc = docOf(<DocumentNode>[para(s)]);
        final String md = markdownFromDocument(doc);
        final Document back = documentFromMarkdown(md);
        expect(shape(back), <String>['p:$s'], reason: 'markdown was "$md"');
        expect(markdownFromDocument(back), md, reason: 'stable');
      });
    }

    test('the same characters inside a list item, a task, a heading and a quote', () {
      const String s = 'a <fs> * b _c_ [d](e) `f` ~g~ &h';
      final Document doc = docOf(<DocumentNode>[
        ListItemNode.unordered(id: nid(), text: AttributedText(s)),
        TaskNode(id: nid(), text: AttributedText(s), isComplete: false),
        para(s, type: header2Attribution),
        para(s, type: blockquoteAttribution),
      ]);
      final Document back = documentFromMarkdown(markdownFromDocument(doc));
      expect(shape(back), shape(doc));
    });

    test('inline code keeps its characters', () {
      final AttributedText text = AttributedText('x <fs> y')
        ..addAttribution(codeAttribution, const SpanRange(2, 5));
      final Document back = documentFromMarkdown(markdownFromDocument(docOf(<DocumentNode>[
        ParagraphNode(id: nid(), text: text),
      ])));
      expect((back.first as TextNode).text.toPlainText(), 'x <fs> y');
    });
  });

  group('loose lists', () {
    test('items separated by blank lines show no line break at their start', () {
      final Document doc = documentFromMarkdown('- one\n\n- two\n\n- [ ] task\n\n- [x] done');
      expect(shape(doc), <String>['unordered:0:one', 'unordered:0:two', 'task:0:task', 'taskx:0:done']);
    });
  });

  test('blank lines inside a code fence are kept even between list-looking lines', () {
    const String md = '```\n- a\n\n- b\n```';
    expect(roundTrip(md), md);
  });

  group('unsupported constructs stay as text', () {
    test('raw HTML in stored Markdown is shown as text and kept', () {
      final Document doc = documentFromMarkdown('<div>raw</div>\n\n<b>x</b> and more');
      expect(shape(doc), <String>['p:<div>raw</div>', 'p:<b>x</b> and more']);
      expect(roundTrip('<div>raw</div>'), r'\<div>raw\</div>'.replaceAll(r'\<', r'\<'));
      expect(shape(documentFromMarkdown(roundTrip('<div>raw</div>'))), <String>['p:<div>raw</div>']);
    });

    test('a table and a rule are kept', () {
      final String out = roundTrip('| a | b |\n|---|---|\n| 1 | 2 |\n\nbefore\n\n---\n\nafter');
      expect(out, contains('| a | b |'));
      expect(out, contains('---'));
      expect(out, contains('after'));
    });
  });

  group('edge cases', () {
    test('empty and blank bodies give one empty paragraph and an empty string back', () {
      for (final String md in <String>['', '\n', '   \n\n  ']) {
        final Document doc = documentFromMarkdown(md);
        expect(doc.nodeCount, 1);
        expect((doc.first as TextNode).text.toPlainText(), '');
        expect(markdownFromDocument(doc), '');
      }
    });

    test('a 100 000-character body converts', () {
      final String md = List<String>.filled(1000, 'x' * 99).join('\n\n');
      expect(md.length, greaterThan(99999));
      expect(shape(documentFromMarkdown(md)), hasLength(1000));
      expect(roundTrip(md), md);
    });
  });

  // Property 9: Markdown round trip is stable.
  const List<String> words = <String>[
    'abc', 'Žluťoučký', 'kůň', '*', '_', '#', '-', '+', '1.', '>', '`', '[a]', '(b)', '<c>', '~', '&', r'\', '|', '!', 'x_y_z', '2*3',
  ];
  Glados(any.intInRange(0, 1 << 20)).test(
    'for any document of supported blocks the text and kinds survive and a second pass changes nothing',
    (int seed) {
      final Random random = Random(seed);
      final List<DocumentNode> nodes = <DocumentNode>[];
      for (int i = 0, n = 1 + random.nextInt(6); i < n; i++) {
        final String text = List<String>.generate(1 + random.nextInt(5), (_) => words[random.nextInt(words.length)]).join(' ');
        switch (random.nextInt(8)) {
          case 0:
            nodes.add(para(text, type: header1Attribution));
          case 1:
            nodes.add(para(text, type: header3Attribution));
          case 2:
            nodes.add(para(text, type: blockquoteAttribution));
          case 3:
            nodes.add(para(text, type: codeAttribution));
          case 4:
            // An item can only be indented below another list item.
            final bool afterItem = nodes.isNotEmpty && nodes.last is ListItemNode;
            nodes.add(ListItemNode.unordered(id: nid(), text: AttributedText(text), indent: afterItem ? random.nextInt(2) : 0));
          case 5:
            nodes.add(TaskNode(id: nid(), text: AttributedText(text), isComplete: random.nextBool()));
          default:
            nodes.add(para(text));
        }
      }
      final Document doc = docOf(nodes);
      final String md1 = markdownFromDocument(doc);
      final Document back = documentFromMarkdown(md1);
      expect(shape(back), shape(doc), reason: 'markdown was:\n$md1');
      expect(markdownFromDocument(back), md1);
    },
  );
}
