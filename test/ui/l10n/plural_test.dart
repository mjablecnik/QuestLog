import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, test, group, setUp, tearDown, setUpAll, tearDownAll;
import 'package:questlog/l10n/app_localizations.dart';

/// Property 6: Czech and English plural forms of the Quest count label.
///
/// Verified behaviour of `intl` (0.20) for integers: the Czech rules are
/// `one` for exactly 1, `few` for exactly 2, 3 and 4, and `other` for
/// everything else - including 0, 5-20, 21, 22 and 100+ (the Czech `many`
/// category is reserved for fractions, which a Quest count never is). So
/// "22 questů" and "21 questů" are what Czech grammar expects here.
final AppLocalizations cs = lookupAppLocalizations(const Locale('cs'));
final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

String czechForm(int count) {
  if (count == 1) return '$count quest';
  if (count >= 2 && count <= 4) return '$count questy';
  return '$count questů';
}

String englishForm(int count) => count == 1 ? '$count quest' : '$count quests';

void main() {
  Glados(any.intInRange(0, 1000000)).test(
    'Czech label uses one for 1, few for 2-4 and other otherwise',
    (count) {
      expect(cs.common_questCount(count), czechForm(count));
    },
  );

  Glados(any.intInRange(0, 1000000))
      .test('English label uses one for 1 and other otherwise', (count) {
        expect(en.common_questCount(count), englishForm(count));
      });

  test('Czech edge cases', () {
    const expected = {
      0: '0 questů',
      1: '1 quest',
      2: '2 questy',
      3: '3 questy',
      4: '4 questy',
      5: '5 questů',
      11: '11 questů',
      12: '12 questů',
      21: '21 questů',
      22: '22 questů',
      24: '24 questů',
      100: '100 questů',
      101: '101 questů',
      102: '102 questů',
    };
    expected.forEach((count, text) {
      expect(cs.common_questCount(count), text, reason: 'count $count');
    });
  });

  test('English edge cases', () {
    expect(en.common_questCount(0), '0 quests');
    expect(en.common_questCount(1), '1 quest');
    expect(en.common_questCount(2), '2 quests');
    expect(en.common_questCount(21), '21 quests');
  });

  test('other count-based messages follow the same Czech rule', () {
    expect(cs.board_subtitle(1, 'x'), startsWith('1 otevřený'));
    expect(cs.board_subtitle(3, 'x'), startsWith('3 otevřené'));
    expect(cs.board_subtitle(5, 'x'), startsWith('5 otevřených'));
    expect(cs.rule_line('Denně', 2, '1. 12.'), contains('2 questy'));
    expect(cs.rule_line('Denně', 5, '1. 12.'), contains('5 questů'));
    expect(cs.mission_deleteBody('Úklid', 1), contains('včetně 1 questu'));
    expect(cs.mission_deleteBody('Úklid', 3), contains('včetně 3 questů'));
    expect(en.mission_deleteBody('Úklid', 1), contains('its 1 quest.'));
  });
}
