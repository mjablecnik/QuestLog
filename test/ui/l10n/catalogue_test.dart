import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Structural checks of the string catalogue: both languages carry exactly the
/// same keys with the same placeholders, and nothing is empty.
Map<String, dynamic> loadArb(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

Map<String, String> messages(Map<String, dynamic> arb) => {
  for (final e in arb.entries)
    if (!e.key.startsWith('@')) e.key: e.value as String,
};

/// Placeholder names used in an ICU message: `{name}` and `{name, plural, ...}`.
Set<String> usedPlaceholders(String message) => {
  for (final m in RegExp(r'\{(\w+)\s*[,}]').allMatches(message)) m.group(1)!,
};

const allowedPrefixes = {
  'app', 'hero', 'board', 'quest', 'missions', 'mission', 'settings', 'rule',
  'font', 'reward', 'sheet', 'a11y', 'error', 'common', 'calendar', 'notes', 'trash', 'editor', //
};

void main() {
  final csArb = loadArb('app_cs.arb');
  final enArb = loadArb('app_en.arb');
  final cs = messages(csArb);
  final en = messages(enArb);

  test('every key of app_cs.arb exists in app_en.arb and the reverse', () {
    expect(
      cs.keys.toSet().difference(en.keys.toSet()),
      isEmpty,
      reason: 'keys missing in app_en.arb',
    );
    expect(
      en.keys.toSet().difference(cs.keys.toSet()),
      isEmpty,
      reason: 'keys missing in app_cs.arb',
    );
  });

  test('no value is empty', () {
    for (final entry in cs.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: 'cs ${entry.key}');
    }
    for (final entry in en.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: 'en ${entry.key}');
    }
  });

  test('placeholders of both languages agree with the template metadata', () {
    for (final key in cs.keys) {
      final declared =
          ((csArb['@$key'] as Map?)?['placeholders'] as Map?)?.keys.toSet() ??
          <String>{};
      expect(
        usedPlaceholders(cs[key]!),
        declared,
        reason: 'cs placeholders of $key differ from @$key',
      );
      expect(
        usedPlaceholders(en[key]!),
        declared,
        reason: 'en placeholders of $key differ from @$key',
      );
    }
  });

  test('every key has a description in the template', () {
    for (final key in cs.keys) {
      final meta = csArb['@$key'] as Map?;
      expect(meta?['description'], isA<String>(), reason: key);
      expect((meta!['description'] as String).trim(), isNotEmpty, reason: key);
    }
  });

  test('keys use a known prefix and camelCase after it', () {
    for (final key in cs.keys) {
      final parts = key.split('_');
      expect(parts.length, 2, reason: key);
      expect(allowedPrefixes, contains(parts.first), reason: key);
      expect(parts.last, matches(RegExp(r'^[a-z][A-Za-z0-9]*$')), reason: key);
    }
  });

  test('the app_en.arb file carries only messages, no stray metadata keys', () {
    for (final key in enArb.keys) {
      if (key.startsWith('@')) {
        expect(key, '@@locale');
      }
    }
  });
}
