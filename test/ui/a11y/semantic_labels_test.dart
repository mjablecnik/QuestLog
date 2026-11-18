import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/l10n/app_localizations.dart';

import '_a11y_harness.dart';

/// Requirement 16.3: check circles, the add buttons, swipe actions,
/// the drag handle and the "..." menu all have a spoken label in the
/// Effective_Language.
void main() {
  const Map<String, Locale> locales = <String, Locale>{
    'cs': Locale('cs'),
    'en': Locale('en'),
  };

  for (final MapEntry<String, Locale> language in locales.entries) {
    final AppLocalizations l = lookupAppLocalizations(language.value);

    Future<A11yEnv> open(
      WidgetTester tester,
      Subject subject,
      void Function(A11yEnv) track,
    ) async {
      final A11yEnv env = await A11yEnv.pump(
        tester,
        subject,
        height: 2400,
        locale: language.value,
      );
      track(env);
      return env;
    }

    /// Swipes the card showing [text] to the left so its actions show.
    Future<void> swipeOpen(WidgetTester tester, String text) async {
      await tester.drag(find.text(text).first, const Offset(-300, 0));
      await tester.pumpAndSettle();
    }

    a11yTest('board (${language.key}): labels of add, checks, drag and '
        'swipe actions', (
      WidgetTester tester,
      void Function(A11yEnv) track,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await open(tester, Subject.board, track);
      List<String> spoken = spokenTexts(tester);
      expect(spoken, contains(l.a11y_addQuest));
      expect(spoken, contains(l.a11y_completeQuest('Koupit mléko')));
      expect(spoken, contains(l.a11y_reopenQuest('Odeslat daňové přiznání')));
      expect(spoken, contains(l.a11y_dragHint));
      await swipeOpen(tester, 'Koupit mléko');
      spoken = spokenTexts(tester);
      expect(spoken, contains(l.a11y_editQuest('Koupit mléko')));
      expect(spoken, contains(l.a11y_deleteQuest('Koupit mléko')));
      handle.dispose();
    });

    a11yTest('missions (${language.key}): labels of add, cards and swipe '
        'actions', (WidgetTester tester, void Function(A11yEnv) track) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await open(tester, Subject.missions, track);
      const String name =
          'Kompletní rekonstrukce koupelny včetně obkladů a podlahy';
      List<String> spoken = spokenTexts(tester);
      expect(spoken, contains(l.a11y_addMission));
      expect(
        spoken.where((String s) => s.contains(l.a11y_openMission(name))),
        isNotEmpty,
      );
      await swipeOpen(tester, name);
      spoken = spokenTexts(tester);
      expect(spoken, contains(l.a11y_editMission(name)));
      expect(spoken, contains(l.a11y_deleteMission(name)));
      handle.dispose();
    });

    a11yTest('detail (${language.key}): labels of the menu, add and checks', (
      WidgetTester tester,
      void Function(A11yEnv) track,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await open(tester, Subject.detail, track);
      final List<String> spoken = spokenTexts(tester);
      expect(spoken, contains(l.a11y_missionMenu));
      expect(spoken, contains(l.a11y_completeQuest('Vynést suť')));
      handle.dispose();
    });
  }
}
