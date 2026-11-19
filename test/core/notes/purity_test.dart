import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `lib/core/notes/` is pure Dart: it may import only `dart:` libraries and the
/// project's own `core` files, never Flutter, Drift or the data and UI layers.
void main() {
  final List<File> sources = Directory('lib/core/notes')
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart'))
      .toList();

  test('the scan sees the notes core', () {
    expect(sources.length, greaterThanOrEqualTo(5));
  });

  for (final File file in sources) {
    test('${file.uri.pathSegments.last} imports no Flutter, Drift, data, service or UI code', () {
      final List<String> imports = file
          .readAsLinesSync()
          .where((String l) => l.trimLeft().startsWith('import ') || l.trimLeft().startsWith('export '))
          .toList();
      for (final String line in imports) {
        expect(line, isNot(contains('package:flutter')), reason: line);
        expect(line, isNot(contains('package:drift')), reason: line);
        expect(line, isNot(contains('package:flutter_riverpod')), reason: line);
        expect(line, isNot(contains('/data/')), reason: line);
        expect(line, isNot(contains('/services/')), reason: line);
        expect(line, isNot(contains('/ui/')), reason: line);
        expect(line, isNot(contains('dart:ui')), reason: line);
      }
    });
  }
}
