import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/notes/note_title.dart';

void main() {
  group('deriveNoteName', () {
    test('strips heading, quote, bullet, checklist, emphasis, code and links', () {
      expect(deriveNoteName('# Inline deklarace'), 'Inline deklarace');
      expect(deriveNoteName('> Čti zleva doprava'), 'Čti zleva doprava');
      expect(deriveNoteName('- [ ] Koupit mléko'), 'Koupit mléko');
      expect(deriveNoteName('- [x] Hotovo'), 'Hotovo');
      expect(deriveNoteName('1. První krok'), 'První krok');
      expect(deriveNoteName('**Tučné** a *kurzíva*'), 'Tučné a kurzíva');
      expect(deriveNoteName('Použij `DATA(x)` všude'), 'Použij DATA(x) všude');
      expect(deriveNoteName('Viz [dokumentace](https://example.com/a)'), 'Viz dokumentace');
      expect(deriveNoteName('snake_case_name zůstane'), 'snake_case_name zůstane');
    });

    test('backslash escapes written by the editor are plain text', () {
      expect(deriveNoteName(r'snake\_case \* \<fs_line\> \[x\]'), 'snake_case * <fs_line> [x]');
      expect(deriveNoteName(r'\# not a heading'), '# not a heading');
      expect(deriveNoteName(r'\- not a bullet'), '- not a bullet');
      expect(notePreview('1\\. one\n\\> two'), '1. one > two');
    });

    test('skips blank lines, fences and thematic breaks; handles CRLF', () {
      expect(deriveNoteName('\n\r\n   \r\nPrvní\r\nDruhý'), 'První');
      expect(deriveNoteName('---\n***\nTeprve tohle'), 'Teprve tohle');
      expect(deriveNoteName('```abap\nSELECT * FROM spfli.\n```'), 'SELECT * FROM spfli.');
    });

    test('is null when no line holds text', () {
      expect(deriveNoteName(''), isNull);
      expect(deriveNoteName('   \n\n \t'), isNull);
      expect(deriveNoteName('---\n***'), isNull);
      expect(deriveNoteName('# \n> \n- '), isNull);
    });

    test('is cut to 80 characters and keeps Czech letters', () {
      final String name = deriveNoteName('ž' * 200)!;
      expect(name.runes.length, 80);
      expect(deriveNoteName('${'a' * 79}ěščř'), '${'a' * 79}ě');
    });
  });

  group('notePreview', () {
    test('joins the first two lines with markers removed', () {
      expect(notePreview('# Titulek\n\nPrvní **řádek**\nTřetí'), 'Titulek První řádek');
      expect(notePreview('Jen jeden'), 'Jen jeden');
      expect(notePreview(' \n '), '');
      expect(notePreview('# Titulek\n\nPrvní\nDruhý\nTřetí', skipFirstLine: true), 'První Druhý');
      expect(notePreview('Jen název', skipFirstLine: true), '');
    });
  });

  // Property 6: names derived from text.
  final Glados<List<int>> anyLines = Glados(any.list(any.intInRange(0, 14)));
  const List<String> pieces = <String>[
    '# ', '> ', '- ', '- [ ] ', '1. ', '**', '`', 'text', 'Žluťoučký', '  ', '-', '#tag', '---', '',
  ];
  anyLines.test('null iff no line has text, otherwise 1 to 80 characters without a leading marker', (picks) {
    final List<String> lines = <String>[];
    for (int i = 0; i + 1 < picks.length; i += 2) {
      lines.add('${pieces[picks[i]]}${pieces[picks[i + 1]]}');
    }
    final String body = lines.join('\n');
    final String? name = deriveNoteName(body);
    if (name == null) {
      expect(notePreview(body), '');
      return;
    }
    expect(name.runes.length, inInclusiveRange(1, 80));
    expect(name, equals(name.trim()));
    expect(RegExp(r'^(#{1,6}\s|>|[-+*]\s|\d+[.)]\s|`|\*)').hasMatch(name), isFalse, reason: '"$name" from "$body"');
  });
}
