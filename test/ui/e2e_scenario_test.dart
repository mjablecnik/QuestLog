import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations_cs.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/xp_engine.dart';
import 'package:questlog/ui/screens/settings/settings_screen.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:questlog/ui/state/reward_queue.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/cards/check_circle.dart';
import 'package:questlog/ui/widgets/reward/reward_card.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/test_database.dart';

final AppLocalizationsEn en = AppLocalizationsEn();
final AppLocalizationsCs cs = AppLocalizationsCs();

const Key _questsTab = ValueKey<ShellTab>(ShellTab.quests);
const Key _missionsTab = ValueKey<ShellTab>(ShellTab.missions);
const Key _settingsTab = ValueKey<ShellTab>(ShellTab.settings);

/// Drift streams run on real async: give them time, then finish the frames.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await _settle(tester);
}

Finder _textField(String hint) => find.byWidgetPredicate(
  (Widget w) => w is TextField && w.decoration?.hintText == hint,
);

/// The check circle of an open Quest named [name] (Board or Mission detail).
Finder _completeCheck(String name) => find.byWidgetPredicate(
  (Widget w) =>
      w is CheckCircle && w.semanticLabel == en.a11y_completeQuest(name),
);

QuestlogPalette _palette(WidgetTester tester) =>
    tester.element(find.byType(SettingsScreen)).palette;

void main() {
  testWidgets('a whole day with Questlog: mission, level-up, new day, '
      'language, theme and a hand-posted rule', (tester) async {
    tester.view.physicalSize = const Size(430, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The device is dark, so the "system" theme starts as the Guild Board.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    final QuestlogDatabase db = createTestDatabase();
    // Monday 16 Nov 2026, 12:00 (Board_Day of 16 Nov).
    final FixedClock clock = FixedClock(DateTime(2026, 11, 16, 12));
    final SemanticsHandle semantics = tester.ensureSemantics();

    try {
      // Seed 10 XP through the real service, yesterday, before the first pump
      // (no streams are active yet, so no Drift deadlock). The Mission below
      // is worth 25 + 50 + 100 bonus XP: 10 + 75 = 85 stays on Level 1 and the
      // bonus is what crosses the Level 2 boundary at 100 XP.
      await tester.runAsync(() async {
        final QuestService seeding = QuestService(
          db,
          XpEngine(db),
          FixedClock(DateTime(2026, 11, 15, 12)),
        );
        final Quest quest = await seeding.create(
          const QuestDraft(name: 'Old chore', difficulty: Difficulty.easy),
        );
        await seeding.complete(quest.id);
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(clock),
            deviceLocaleProvider.overrideWithValue(const Locale('en')),
            appVersionProvider.overrideWith((ref) async => '1.0.0'),
          ],
          child: const QuestlogApp(),
        ),
      );
      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(QuestlogApp)),
      );
      await _settle(tester);
      await _settle(tester);

      // Starting point: Level 1, 10 XP, an empty board, no missions.
      expect(find.text(en.hero_level(1)), findsOneWidget);
      expect(find.text(en.hero_xpProgress(10, 100)), findsOneWidget);
      expect(find.text(en.board_emptyTitle), findsOneWidget);

      // ---- 1. Create a Mission with two Quests (requirements 3.6, 9) -------
      await _tap(tester, find.byKey(_missionsTab));
      expect(find.text(en.missions_emptyTitle), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey<String>('add-fab')));
      expect(find.text(en.mission_sheetCreateTitle), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey<String>('mission-name-field')),
        'Autumn clean-up',
      );
      await tester.enterText(
        _textField(en.mission_questNamePlaceholder),
        'Rake the leaves',
      );
      await _tap(tester, find.text(en.mission_addQuest));
      expect(_textField(en.mission_questNamePlaceholder), findsNWidgets(2));
      await tester.enterText(
        _textField(en.mission_questNamePlaceholder).last,
        'Clean the gutters',
      );
      // The second Quest is Hard: one tap on its Difficulty chip (Normal -> Hard).
      await _tap(tester, find.text('+25').last);
      expect(find.text('+50'), findsOneWidget);
      expect(find.text(en.mission_questsLabel(2).toUpperCase()), findsOne);
      // Default Mission bonus is Medium (+100 XP).
      await _tap(tester, find.text(en.mission_createAction));

      expect(find.text(en.mission_sheetCreateTitle), findsNothing);
      expect(find.text('Autumn clean-up'), findsOneWidget);
      expect(find.text(en.missions_remaining(75)), findsOneWidget);
      expect(find.text('+100'), findsOneWidget);
      expect(find.text(en.missions_openCount(1)), findsOneWidget);

      // Both Quests belong to the Mission, so the Board does not list them.
      await _tap(tester, find.byKey(_questsTab));
      expect(find.text('Rake the leaves'), findsNothing);
      expect(find.text('Clean the gutters'), findsNothing);
      expect(find.text(en.board_emptyTitle), findsOneWidget);
      expect(find.text(en.board_subtitle(0, 'Monday, November 16')), findsOne);

      // ---- 2. Complete both Quests in the Mission, then the Mission -------
      await _tap(tester, find.byKey(_missionsTab));
      await _tap(tester, find.text('Autumn clean-up'));
      expect(find.text('Rake the leaves'), findsOneWidget);
      expect(find.text('Clean the gutters'), findsOneWidget);
      // A completed Quest shows no reward card: it moves to the done list.
      await _tap(tester, _completeCheck('Rake the leaves'));
      expect(find.text(en.reward_questComplete), findsNothing);
      expect(find.text(en.mission_completeAction), findsNothing);

      await _tap(tester, _completeCheck('Clean the gutters'));
      expect(find.text(en.reward_questComplete), findsNothing);
      // Every Quest is done: the detail screen offers to complete the Mission.
      expect(find.text(en.mission_completeAction), findsOneWidget);

      await _tap(tester, find.text(en.mission_completeAction));
      // The Mission bonus crosses the Level boundary: Level-up variant.
      expect(find.text(en.reward_levelUp), findsOneWidget);
      expect(find.text(en.reward_levelUpBody(2)), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RewardCard),
          matching: find.text('Autumn clean-up'),
        ),
        findsOneWidget,
      );
      expect(container.read(rewardQueueProvider), hasLength(1));
      await _tap(tester, find.text(en.common_continue));
      expect(container.read(rewardQueueProvider), isEmpty);
      expect(find.text(en.reward_levelUp), findsNothing);

      // Back on the Board: the Mission's done Quests are not listed there.
      await _tap(tester, find.bySemanticsLabel(en.common_back));
      await _tap(tester, find.byKey(_questsTab));
      expect(find.text(en.board_doneSection.toUpperCase()), findsNothing);
      expect(find.text('Rake the leaves'), findsNothing);
      expect(find.text(en.board_emptyTitle), findsOneWidget);

      // The Hero_Bar shows the new Level: 185 XP = Level 2, 85 / 150.
      expect(find.text(en.hero_level(2)), findsOneWidget);
      expect(find.text(en.hero_xpProgress(85, 150)), findsOneWidget);
      expect(find.text(en.hero_xpRemaining(65, 3)), findsOneWidget);

      // ---- 3. Missions tab: "Completed today" with the earned bonus -------
      await _tap(tester, find.byKey(_missionsTab));
      expect(
        find.text(en.missions_sectionDoneToday.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(en.missions_sectionOpen.toUpperCase()), findsNothing);
      expect(find.text('Autumn clean-up'), findsOneWidget);
      expect(find.text(en.missions_completedLine(2, '12:00')), findsOneWidget);
      expect(find.text('+100'), findsOneWidget);
      expect(find.text(en.missions_earnedCaption.toUpperCase()), findsOne);
      expect(find.text(en.missions_doneCount(1)), findsOneWidget);

      // ---- 4. Day_Start passes: both done lists empty (3.6, 17.3) ---------
      clock.set(DateTime(2026, 11, 17, 4, 0, 1));
      await tester.pump(const Duration(hours: 17));
      await _settle(tester);
      expect(
        find.text(en.missions_sectionDoneToday.toUpperCase()),
        findsNothing,
      );
      expect(find.text('Autumn clean-up'), findsNothing);
      expect(find.text(en.missions_emptyTitle), findsOneWidget);
      await _tap(tester, find.byKey(_questsTab));
      expect(find.text(en.board_doneSection.toUpperCase()), findsNothing);
      expect(find.text(en.board_emptyTitle), findsOneWidget);
      expect(find.text(en.board_subtitle(0, 'Tuesday, November 17')), findsOne);
      // The earned XP stays: history is not on the board, the level is.
      expect(find.text(en.hero_level(2)), findsOneWidget);

      // ---- 5. Settings: language to Czech, theme to Light (11.x, 14.3) ----
      await _tap(tester, find.byKey(_settingsTab));
      expect(find.byType(SettingsScreen), findsOneWidget);
      // Screen title plus the tab label.
      expect(find.text(en.settings_title), findsNWidgets(2));
      expect(_palette(tester).isLight, isFalse);

      await _tap(tester, find.text(en.settings_languageCs));
      expect(find.text(cs.settings_title), findsNWidgets(2));
      expect(find.text(cs.settings_groupLanguage.toUpperCase()), findsOne);
      expect(find.text(en.settings_title), findsNothing);
      expect(container.read(effectiveLocaleProvider).languageCode, 'cs');

      await _tap(tester, find.text(cs.settings_themeLight));
      expect(_palette(tester).isLight, isTrue);
      expect(_palette(tester).board, QuestlogPalette.daylight.board);
      expect(find.text(cs.settings_version('1.0.0')), findsOneWidget);

      // ---- 6. Post a rule by hand (12.3) ------------------------------------
      await _tap(tester, find.text(cs.rule_addRow));
      expect(find.text(cs.rule_sheetTitle), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey<String>('rule-name-field')),
        'Water plants',
      );
      await tester.enterText(
        _textField(cs.mission_questNamePlaceholder),
        'Fill the can',
      );
      await tester.pump();
      await _tap(tester, find.text(cs.rule_saveAction));
      expect(find.text(cs.rule_sheetTitle), findsNothing);
      // The rules sit below the language, theme, font and palette groups.
      await tester.dragUntilVisible(
        find.text('Water plants'),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      await tester.pump();
      expect(find.text('Water plants'), findsOneWidget);
      expect(find.text(cs.settings_rulesActive(1).toUpperCase()), findsOneWidget);
      expect(find.text(cs.rule_postNow), findsOneWidget);

      await _tap(tester, find.text(cs.rule_postNow));
      expect(
        find.textContaining(cs.rule_postedMessage('Water plants')),
        findsOneWidget,
      );
      expect(find.text(cs.rule_posted), findsOneWidget);
      expect(find.text(cs.rule_postNow), findsNothing);

      // Leaving the Settings tab takes its message with it, then Missions.
      await _tap(tester, find.byKey(_missionsTab));
      expect(find.byType(SettingsScreen), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      // Screen title plus the tab label.
      expect(find.text(cs.missions_title), findsNWidgets(2));
      expect(find.text(cs.missions_sectionOpen.toUpperCase()), findsOneWidget);
      expect(find.text('Water plants'), findsOneWidget);
      expect(find.text(cs.missions_remaining(25)), findsOneWidget);
      expect(find.text(cs.missions_openCount(1)), findsOneWidget);
      // The posted Quest belongs to the new Mission: Missions shows it, the
      // Board does not.
      await _tap(tester, find.byKey(_questsTab));
      expect(find.text('Fill the can'), findsNothing);
      await _tap(tester, find.byKey(_missionsTab));
      await _tap(tester, find.text('Water plants'));
      expect(find.text('Fill the can'), findsOneWidget);
    } finally {
      semantics.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
      await tester.runAsync(db.close);
    }
  });
}
