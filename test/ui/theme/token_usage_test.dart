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
  });
}
