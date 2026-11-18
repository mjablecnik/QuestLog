import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/widgets/cards/difficulty_pips.dart';
import 'package:intl/intl.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations_cs.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/sheets/quest_sheet.dart';
import 'package:questlog/ui/state/reward_queue.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '_harness.dart';

final AppLocalizationsEn en = AppLocalizationsEn();
final AppLocalizationsCs cs = AppLocalizationsCs();

const List<(String, Difficulty)> _threeQuests = <(String, Difficulty)>[
  ('Take out the trash', Difficulty.easy),
  ('Sweep the floor', Difficulty.normal),
  ('Wash the windows', Difficulty.hard),
];

Future<int> _seedThree(DetailFixture f) =>
    f.missions.create('Cleaning', quests: _threeQuests);

void main() {
  group('content', () {
    detailTest('lists every Quest, including older done ones', (tester) async {
      final (DetailFixture f, int id) = await pumpDetail(
        tester,
        seed: (DetailFixture f) => f.missions.create(
          'Cleaning',
          quests: <(String, Difficulty)>[
            ..._threeQuests,
            ('Wash the dishes', Difficulty.normal),
            ('Vacuum the bedroom', Difficulty.easy),
          ],
        ),
      );
      await completeQuests(tester, f, id, <String>[
        'Vacuum the bedroom',
      ], at: DateTime(2026, 11, 10, 18));
      await completeQuests(tester, f, id, <String>[
        'Wash the dishes',
      ], at: DateTime(2026, 11, 15, 8, 52));

      expect(find.text('Cleaning'), findsOneWidget);
      expect(find.text(en.mission_progressText(2, 5)), findsOneWidget);
      expect(find.text(en.mission_bonusOnCompletion(100)), findsOneWidget);
      expect(find.text(en.mission_sectionRemaining.toUpperCase()), findsOne);
      expect(find.text(en.mission_sectionDone.toUpperCase()), findsOne);
      for (final String name in <String>[
        'Take out the trash',
        'Sweep the floor',
        'Wash the windows',
        'Wash the dishes',
        'Vacuum the bedroom',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      // Open Quests show effort pips but never a tier name; done ones show when
      // they were completed.
      for (final String name in <String>[
        en.quest_effortMoment,
        en.quest_effortHour,
        en.quest_effortPart,
        en.quest_effortDay,
      ]) {
        expect(find.text(name), findsNothing, reason: name);
      }
      expect(find.byType(DifficultyPips), findsWidgets);
      expect(find.text(en.quest_completedTodayAt('08:52')), findsOneWidget);
      expect(
        find.text(
          en.quest_completedOn(
            DateFormat.yMd('en').format(DateTime(2026, 11, 10)),
          ),
        ),
        findsOneWidget,
      );
      // The newest done Quest comes first.
      expect(
        tester.getTopLeft(find.text('Wash the dishes')).dy,
        lessThan(tester.getTopLeft(find.text('Vacuum the bedroom')).dy),
      );
      expect(find.text(en.mission_menuAddQuest), findsNothing);
      expect(find.text(en.mission_completeAction), findsNothing);
    });

    detailTest('shows the recurring caption for an Instance only', (
      tester,
    ) async {
      final (DetailFixture f, int id) = await pumpDetail(
        tester,
        seed: (DetailFixture f) async {
          final rule = await f.container
              .read(recurrenceServiceProvider)
              .create(
                RuleDraft(
                  name: 'Monthly clean',
                  cadence: Cadence.monthly,
                  requestedAnchor: DateTime(2026, 11, 1),
                  bonus: MissionBonus.small,
                  quests: const <RuleQuestDraft>[
                    RuleQuestDraft(name: 'Mop', difficulty: Difficulty.normal),
                  ],
                ),
              );
          final PostResult posted = await f.container
              .read(recurrenceServiceProvider)
              .postNow(rule.id);
          return posted.mission.id;
        },
      );

      expect(find.text('Monthly clean'), findsOneWidget);
      expect(find.text(en.missions_recurringCaption), findsOneWidget);
      expect(f.db, isNotNull);
      expect(id, greaterThan(0));
    });

    detailTest('the progress bar fill is visible and proportional', (
      tester,
    ) async {
      final (DetailFixture f, int id) = await pumpDetail(
        tester,
        seed: _seedThree,
      );
      await completeQuests(tester, f, id, <String>['Sweep the floor']);

      final Finder fill = find.descendant(
        of: find.byType(FractionallySizedBox),
        matching: find.byType(ColoredBox),
      );
      expect(fill, findsOneWidget);
      final Finder track = find.byWidgetPredicate(
        (Widget w) => w is SizedBox && w.height == Metrics.detailBar,
      );
      expect(track, findsOneWidget);
      // A fill with zero height is invisible although the text says 1 of 3.
      expect(tester.getSize(fill).height, Metrics.detailBar);
      expect(
        tester.getSize(fill).width / tester.getSize(track).width,
        closeTo(1 / 3, 0.01),
      );
    });

    detailTest('a one-off Mission has no recurring caption', (tester) async {
      await pumpDetail(tester, seed: _seedThree);

      expect(find.text(en.missions_recurringCaption), findsNothing);
    });

    detailTest('a Mission without Quests shows the empty state', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        seed: (DetailFixture f) => f.missions.create('Empty goal'),
      );

      expect(find.text(en.mission_emptyTitle), findsOneWidget);
      expect(find.text(en.mission_emptyBody), findsOneWidget);
      expect(find.text(en.mission_completeAction), findsNothing);
      expect(find.text(en.mission_progressText(0, 0)), findsOneWidget);

      await tester.tap(find.text(en.mission_menuAddQuest));
      await settle(tester);
      expect(find.byType(QuestSheet), findsOneWidget);
    });

    detailTest('texts and menu follow the Czech locale', (tester) async {
      await pumpDetail(tester, seed: _seedThree, locale: const Locale('cs'));

      expect(find.text(cs.mission_sectionRemaining.toUpperCase()), findsOne);
      expect(find.text(cs.mission_bonusOnCompletion(100)), findsOneWidget);
      await tester.tap(find.byTooltip(cs.a11y_missionMenu));
      await settle(tester);
      expect(find.text('Upravit misi'), findsOneWidget);
      expect(find.text('Přidat quest'), findsOneWidget);
      expect(find.text('Smazat misi'), findsOneWidget);
    });
  });

  group('completing the Mission', () {
    detailTest('the button appears only when every Quest is done', (
      tester,
    ) async {
      await pumpDetail(tester, seed: _seedThree);
      expect(find.text(en.mission_completeAction), findsNothing);

      await toggle(tester, 'Take out the trash');
      await toggle(tester, 'Sweep the floor');
      expect(find.text(en.mission_progressText(2, 3)), findsOneWidget);
      expect(find.text(en.mission_completeAction), findsNothing);

      await toggle(tester, 'Wash the windows');
      expect(find.text(en.mission_progressText(3, 3)), findsOneWidget);
      expect(find.text(en.mission_completeAction), findsOneWidget);

      // Reopening one Quest takes the button away again.
      await toggle(tester, 'Sweep the floor');
      expect(find.text(en.mission_completeAction), findsNothing);
    });

    detailTest('completing pushes the Mission reward and shows the seal', (
      tester,
    ) async {
      final (DetailFixture f, int id) = await pumpDetail(
        tester,
        seed: _seedThree,
      );
      await completeQuests(tester, f, id, <String>[
        'Take out the trash',
        'Sweep the floor',
        'Wash the windows',
      ]);
      final int before = f.container.read(rewardQueueProvider).length;

      await tester.tap(find.text(en.mission_completeAction));
      await settle(tester);

      final List<RewardEvent> queue = f.container.read(rewardQueueProvider);
      expect(queue.length, before + 1);
      final MissionReward reward = queue.last as MissionReward;
      expect(reward.missionName, 'Cleaning');
      expect(reward.bonus, 100);
      expect(find.text(en.mission_completedTitle), findsOneWidget);
      expect(find.text(en.mission_completedBonus(100)), findsOneWidget);
      expect(
        find.text(
          en.mission_completedOn(DateFormat.yMMMd('en').format(testNow)),
        ),
        findsOneWidget,
      );
      expect(find.text(en.mission_completeAction), findsNothing);
      expect(find.text(en.mission_bonusOnCompletion(100)), findsNothing);
      // A completed Mission offers no "add quest" anywhere.
      expect(find.text(en.mission_addQuestToMission), findsNothing);
      await tester.tap(find.byTooltip(en.a11y_missionMenu));
      await settle(tester);
      expect(find.text(en.mission_menuEdit), findsOneWidget);
      expect(find.text(en.mission_menuAddQuest), findsNothing);
      expect(find.text(en.mission_menuDelete), findsOneWidget);
    });

    detailTest('reopening a Quest reopens the Mission and says so', (
      tester,
    ) async {
      final (DetailFixture f, int id) = await pumpDetail(
        tester,
        seed: _seedThree,
      );
      await completeQuests(tester, f, id, <String>[
        'Take out the trash',
        'Sweep the floor',
        'Wash the windows',
      ]);
      await tester.tap(find.text(en.mission_completeAction));
      await settle(tester);
      expect(find.text(en.mission_completedTitle), findsOneWidget);
      expect(find.text(en.mission_bonusWithdrawn), findsNothing);

      await toggle(tester, 'Sweep the floor');

      expect(find.text(en.mission_completedTitle), findsNothing);
      expect(find.text(en.mission_bonusWithdrawn), findsOneWidget);
      // The message counts everything taken back: the Quest and the bonus.
      expect(
        find.text(en.board_rewardWithdrawnMissionReopened(25 + 100)),
        findsOneWidget,
      );
      expect(find.text(en.mission_bonusOnCompletion(100)), findsOneWidget);
      expect(find.text(en.mission_progressText(2, 3)), findsOneWidget);
      expect(find.text(en.mission_addQuestToMission), findsOneWidget);
      // The Mission really is open again and the bonus was taken back.
      final Mission mission = (await realAsync(
        tester,
        () => f.container.read(missionServiceProvider).watchDetail(id).first,
      ))!.mission;
      expect(mission.status, MissionStatus.open);
      expect(mission.awardedBonus, isNull);
    });
  });

  group('menu and deletion', () {
    detailTest('the menu lists Edit, Add quest and Delete, Delete last', (
      tester,
    ) async {
      await pumpDetail(tester, seed: _seedThree);
      await tester.tap(find.byTooltip(en.a11y_missionMenu));
      await settle(tester);

      final double edit = tester.getTopLeft(find.text(en.mission_menuEdit)).dy;
      final double add = tester
          .getTopLeft(find.text(en.mission_menuAddQuest))
          .dy;
      final double delete = tester
          .getTopLeft(find.text(en.mission_menuDelete))
          .dy;
      expect(edit, lessThan(add));
      expect(add, lessThan(delete));
    });

    detailTest('Add quest presets the Mission of the new Quest', (
      tester,
    ) async {
      final (DetailFixture f, int id) = await pumpDetail(
        tester,
        seed: _seedThree,
      );
      await tester.tap(find.byTooltip(en.a11y_missionMenu));
      await settle(tester);
      await tester.tap(find.text(en.mission_menuAddQuest));
      await settle(tester);

      expect(find.byType(QuestSheet), findsOneWidget);
      expect(find.text(en.quest_sheetCreateTitle), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Polish the sink');
      await tester.pump();
      await tester.tap(find.byType(FilledButton));
      await settle(tester);

      expect(find.byType(QuestSheet), findsNothing);
      expect(find.text('Polish the sink'), findsOneWidget);
      final List<Quest> quests = await realAsync(tester, () => f.quests(id));
      expect(quests.map((Quest q) => q.name), contains('Polish the sink'));
      expect(quests, hasLength(4));
    });

    detailTest('deleting the Mission asks first, then returns to Missions', (
      tester,
    ) async {
      final (DetailFixture f, int id) = await pumpDetail(
        tester,
        seed: _seedThree,
      );
      await tester.tap(find.byTooltip(en.a11y_missionMenu));
      await settle(tester);
      await tester.tap(find.text(en.mission_menuDelete));
      await settle(tester);

      expect(find.text(en.mission_deleteTitle), findsOneWidget);
      expect(find.text(en.mission_deleteBody('Cleaning', 3)), findsOneWidget);

      await tester.tap(find.text(en.common_delete));
      await settle(tester);

      expect(find.text(homeLabel), findsOneWidget);
      expect(find.text('Cleaning'), findsNothing);
      final detail = await realAsync(
        tester,
        () => f.container.read(missionServiceProvider).watchDetail(id).first,
      );
      expect(detail, isNull);
    });

    detailTest('cancelling the deletion keeps the Mission', (tester) async {
      await pumpDetail(tester, seed: _seedThree);
      await tester.tap(find.byTooltip(en.a11y_missionMenu));
      await settle(tester);
      await tester.tap(find.text(en.mission_menuDelete));
      await settle(tester);
      await tester.tap(find.text(en.common_cancel));
      await settle(tester);

      expect(find.text('Cleaning'), findsOneWidget);
      expect(find.text(homeLabel), findsNothing);
    });

    detailTest('the screen pops when the Mission disappears', (tester) async {
      final (DetailFixture f, int id) = await pumpDetail(
        tester,
        seed: _seedThree,
      );
      expect(find.text('Cleaning'), findsOneWidget);

      await realAsync(
        tester,
        () => f.container.read(missionServiceProvider).delete(id),
      );
      await settle(tester);

      expect(find.text(homeLabel), findsOneWidget);
      expect(find.text('Cleaning'), findsNothing);
      // A deletion made on screen is not a stale row: no message.
      expect(f.container.read(snackbarProvider), isNull);
    });

    detailTest('a Mission that is already gone closes with the message', (
      tester,
    ) async {
      final (DetailFixture f, int _) = await pumpDetail(
        tester,
        seed: (DetailFixture f) async {
          final int id = await _seedThree(f);
          await f.container.read(missionServiceProvider).delete(id);
          return id;
        },
      );

      expect(find.text(homeLabel), findsOneWidget);
      expect(f.container.read(snackbarProvider)?.text, en.error_itemChanged);
    });
  });
}
