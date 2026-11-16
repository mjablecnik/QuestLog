import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DateTime.now appears nowhere in lib/ outside lib/core/clock.dart', () {
    final List<String> offences = <String>[];
    for (final File file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || file.path == 'lib/core/clock.dart') continue;
      final List<String> lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final String code = lines[i].replaceFirst(RegExp(r'//.*$'), '');
        if (code.contains('DateTime.now') || code.contains('DateTime.timestamp')) {
          offences.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(offences, isEmpty);
  });
}
