import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Requirement 19.3: every screen and sheet has a widget test on the in-memory
/// database. The catalogue is the set of `*_screen.dart` files under
/// `lib/ui/screens` and `*_sheet.dart` files under `lib/ui/sheets`; each needs
/// a test under `test/ui` that names it and runs on `createTestDatabase()`
/// (directly or through a harness that does).
void main() {
  String pascal(String snake) => snake
      .split('_')
      .map((String w) => w[0].toUpperCase() + w.substring(1))
      .join();

  List<File> dartFiles(String dir) =>
      Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart'))
          .toList();

  final List<File> tests = dartFiles('test/ui')
      .where((File f) => !f.path.contains('/a11y/'))
      .where((File f) => f.path.endsWith('_test.dart'))
      .toList();
  final Map<String, String> sources = <String, String>{
    for (final File f in tests) f.path: f.readAsStringSync(),
  };
  final Map<String, String> harnesses = <String, String>{
    for (final File f in dartFiles('test/ui'))
      if (f.uri.pathSegments.last.startsWith('_')) f.path: f.readAsStringSync(),
  };

  bool runsOnInMemoryDatabase(String source, String testPath) {
    if (source.contains('createTestDatabase')) return true;
    // Through a harness imported from the test's own directory tree.
    return harnesses.entries.any(
      (MapEntry<String, String> h) =>
          source.contains(h.key.split('/').last) &&
          h.value.contains('createTestDatabase'),
    );
  }

  final List<String> catalogue = <String>[
    ...dartFiles('lib/ui/screens')
        .map((File f) => f.uri.pathSegments.last)
        .where((String n) => n.endsWith('_screen.dart')),
    ...dartFiles('lib/ui/sheets')
        .map((File f) => f.uri.pathSegments.last)
        .where((String n) => n.endsWith('_sheet.dart')),
  ];

  test('the catalogue is not empty', () {
    expect(catalogue.length, greaterThanOrEqualTo(9));
  });

  for (final String file in catalogue) {
    final String base = file.substring(0, file.length - '.dart'.length);
    final String widget = pascal(base);
    test('$file has a widget test on the in-memory database', () {
      final Iterable<MapEntry<String, String>> naming = sources.entries.where(
        (MapEntry<String, String> e) =>
            e.value.contains(widget) || e.value.contains('show$widget'),
      );
      expect(naming, isNotEmpty, reason: 'no test under test/ui names $widget');
      expect(
        naming.any(
          (MapEntry<String, String> e) =>
              runsOnInMemoryDatabase(e.value, e.key),
        ),
        isTrue,
        reason: 'no test of $widget uses createTestDatabase()',
      );
    });
  }
}
