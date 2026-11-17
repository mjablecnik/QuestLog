import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/font_licenses.dart';

class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fontFiles = Directory('assets/fonts')
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last)
      .where((name) => name.endsWith('.ttf'))
      .toList();

  test('every bundled font file has a licence file', () {
    expect(fontFiles, isNotEmpty);
    for (final name in fontFiles) {
      final family = name.split('-').first;
      expect(
        File('assets/fonts/licenses/$family-OFL.txt').existsSync(),
        isTrue,
        reason: '$name has no licence in assets/fonts/licenses/',
      );
    }
  });

  test('every licence file belongs to a bundled family and is listed', () {
    final families = fontFiles.map((n) => n.split('-').first).toSet();
    final files = Directory('assets/fonts/licenses')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    expect(files, families.map((f) => '$f-OFL.txt').toSet());
    expect(bundledFontLicenses.map((e) => e.file).toSet(), families);
  });

  test('each licence is the SIL OFL and names its family', () {
    for (final font in bundledFontLicenses) {
      final text = File(fontLicenseAsset(font.file)).readAsStringSync();
      expect(
        text.toUpperCase(),
        contains('SIL OPEN FONT LICENSE'),
        reason: font.name,
      );
      expect(text, contains('Copyright'), reason: font.name);
      expect(
        text.replaceAll(' ', '').toLowerCase(),
        contains(font.name.replaceAll(' ', '').toLowerCase()),
        reason: font.name,
      );
    }
  });

  test('registers one licence entry per font family', () async {
    registerFontLicenses(bundle: _DiskBundle());
    final entries = <LicenseEntry>[];
    await for (final entry in LicenseRegistry.licenses) {
      if (entry.packages.any((p) => p.endsWith('(font)'))) entries.add(entry);
    }
    final packages = entries.expand((e) => e.packages).toSet();
    expect(packages, <String>{
      for (final font in bundledFontLicenses) '${font.name} (font)',
    });
    for (final entry in entries) {
      final text = entry.paragraphs.map((p) => p.text).join('\n');
      expect(text.toUpperCase(), contains('SIL OPEN FONT LICENSE'));
    }
  });
}
