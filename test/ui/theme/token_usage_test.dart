import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every `.dart` file under `lib/ui/` outside `lib/ui/theme/`.
List<File> _screenAndWidgetSources() {
  final Directory root = Directory('lib/ui');
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .where((File f) => !f.path.startsWith('lib/ui/theme/'))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));
}

/// Source lines with `//` comments removed, so documentation may mention the
/// forbidden forms.
List<(int, String)> _codeLines(File file) {
  final List<String> lines = file.readAsLinesSync();
  return <(int, String)>[
    for (int i = 0; i < lines.length; i++)
      (i + 1, lines[i].replaceFirst(RegExp(r'//.*$'), '')),
  ];
}

List<String> _offences(RegExp pattern) {
  final List<String> found = <String>[];
  for (final File file in _screenAndWidgetSources()) {
    for (final (int number, String line) in _codeLines(file)) {
      if (pattern.hasMatch(line)) {
        found.add('${file.path}:$number: ${line.trim()}');
      }
    }
  }
  return found;
}

void main() {
  test('the scan sees the UI sources', () {
    expect(_screenAndWidgetSources().length, greaterThan(40));
  });

  test('no literal Color(0x...) outside lib/ui/theme', () {
    expect(_offences(RegExp(r'Color\(\s*0x', caseSensitive: false)), isEmpty);
  });

  test('no named Colors.* other than transparent outside lib/ui/theme', () {
    expect(_offences(RegExp(r'\bColors\.(?!transparent\b)[a-zA-Z]')), isEmpty);
  });

  test('no literal Duration(milliseconds: ...) outside lib/ui/theme', () {
    expect(_offences(RegExp(r'Duration\(\s*milliseconds\s*:')), isEmpty);
  });

  // A non-zero number written directly in a padding, margin, gap or radius.
  final RegExp literalSpacing = RegExp(
    r'(EdgeInsets\.[a-zA-Z]+|BorderRadius\.(circular|all)|Radius\.circular)\([^)]*?(?<![A-Za-z_.0-9])[1-9][0-9]*(\.[0-9]+)?\s*[,)]'
    r'|SizedBox\((width|height):\s*[1-9]',
  );

  test('no literal spacing or radius outside lib/ui/theme', () {
    expect(_offences(literalSpacing), isEmpty);
  });

  test('no Material Icons.* outside lib/ui/theme', () {
    expect(_offences(RegExp(r'\bIcons\.[a-zA-Z]')), isEmpty);
  });

  test('the scan would catch an offence', () {
    final RegExp color = RegExp(r'Color\(\s*0x', caseSensitive: false);
    expect(color.hasMatch('const c = Color(0xFF112233);'), isTrue);
    expect(
      RegExp(r'Duration\(\s*milliseconds\s*:')
          .hasMatch('Duration(milliseconds: 200)'),
      isTrue,
    );
    expect(RegExp(r'\bIcons\.[a-zA-Z]').hasMatch('Icon(Icons.add)'), isTrue);
    expect(literalSpacing.hasMatch('padding: EdgeInsets.all(16),'), isTrue);
    expect(literalSpacing.hasMatch('padding: EdgeInsets.only(top: 8),'), isTrue);
    expect(literalSpacing.hasMatch('const SizedBox(height: 18),'), isTrue);
    expect(literalSpacing.hasMatch('BorderRadius.circular(1)'), isTrue);
    expect(literalSpacing.hasMatch('EdgeInsets.all(Space.s16)'), isFalse);
  });
}
