import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/state/reward_queue.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/reward/reward_card.dart';
import 'package:questlog/ui/widgets/reward/reward_overlay.dart';

const int _missionId = 7;

final Mission _mission = Mission(
  id: _missionId,
  name: 'Cleaning',
  bonus: MissionBonus.medium,
  status: MissionStatus.open,
  ruleId: null,
  createdAt: DateTime(2026, 11, 15),
  completedAt: null,
  awardedBonus: null,
);

QuestReward _quest({
  String name = 'Sweep the floor',
  int xp = 25,
  bool levelUp = false,
  int level = 4,
  MissionProgress? mission,
  bool offer = false,
}) => QuestReward(
  questName: name,
  xp: xp,
  levelUp: levelUp,
  level: level,
  mission: mission,
  missionId: mission == null ? null : _missionId,
  offerMissionComplete: offer,
);

const MissionProgress _progress = MissionProgress(
  done: 3,
  total: 5,
  remainingXp: 60,
);

/// Pumps a shell-like Stack with the overlay on top and returns the container.
Future<ProviderContainer> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  bool disableAnimations = false,
  ValueChanged<int>? onCompleteMission,
}) async {
  // An iPhone-sized screen: the card with the mission offer must fit.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        missionDetailProvider.overrideWith(
          (ref, id) =>
              Stream.value(MissionDetail(mission: _mission, quests: const [])),
        ),
      ],
      child: MaterialApp(
        theme: buildTheme(
          palette: QuestlogPalette.guildBoard,
        ),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (BuildContext context, Widget? app) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: app!,
        ),
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              const Center(child: Text('tabs')),
              RewardOverlay(onCompleteMission: onCompleteMission ?? (_) {}),
            ],
          ),
        ),
      ),
    ),
  );
  return ProviderScope.containerOf(tester.element(find.byType(Scaffold)));
}

Future<void> _show(
  WidgetTester tester,
  ProviderContainer container,
  RewardEvent event,
) async {
  container.read(rewardQueueProvider.notifier).push(event);
  await tester.pump();
  await tester.pump(Motion.panel);
}

// A controller finishes only once its time is strictly past the duration.
const Duration _exitDone = Duration(milliseconds: 301);
const Duration _reducedExitDone = Duration(milliseconds: 151);

Future<void> _end(WidgetTester tester) => tester.pumpWidget(const SizedBox());

void main() {
  group('variants', () {
    testWidgets('quest with a mission renders the English texts', (
      tester,
    ) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest(mission: _progress));
      expect(find.text('+25 XP'), findsOneWidget);
      expect(find.text('QUEST COMPLETE'), findsOneWidget);
      expect(find.text('Sweep the floor'), findsOneWidget);
      expect(find.text('Mission · Cleaning'), findsOneWidget);
      expect(find.text('3 of 5 quests'), findsOneWidget);
      expect(find.text('60 XP remaining'), findsOneWidget);
      expect(
        find.text('Completing the mission brings another +100 XP'),
        findsOneWidget,
      );
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Complete mission'), findsNothing);
      await _end(tester);
    });

    testWidgets('quest with a mission renders the Czech texts', (tester) async {
      final c = await _pump(tester, locale: const Locale('cs'));
      await _show(tester, c, _quest(mission: _progress));
      expect(find.text('+25 XP'), findsOneWidget);
      expect(find.text('QUEST SPLNĚNO'), findsOneWidget);
      expect(find.text('Mise · Cleaning'), findsOneWidget);
      expect(find.text('3 z 5 questů'), findsOneWidget);
      expect(
        find.text('Dokončení mise přinese dalších +100 XP'),
        findsOneWidget,
      );
      expect(find.text('Pokračovat'), findsOneWidget);
      await _end(tester);
    });

    testWidgets('the XP unit is set smaller than the figure', (tester) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest(xp: 1250));
      final Text figure = tester.widget<Text>(
        find.descendant(
          of: find.byType(RewardCard),
          matching: find.byWidgetPredicate(
            (Widget w) => w is Text && w.textSpan?.toPlainText() == '+1,250 XP',
          ),
        ),
      );
      final TextSpan root = figure.textSpan! as TextSpan;
      expect(root.text, '+1,250');
      final TextSpan unit = root.children!.single as TextSpan;
      expect(unit.text, ' XP');
      expect(unit.style!.fontSize, lessThan(root.style!.fontSize!));
      await _end(tester);
    });

    testWidgets('quest without a mission has no progress block', (
      tester,
    ) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest());
      expect(find.text('QUEST COMPLETE'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await _end(tester);
    });

    testWidgets('mission variant shows the bonus and caption', (tester) async {
      final c = await _pump(tester);
      await _show(
        tester,
        c,
        const MissionReward(
          missionName: 'Cleaning',
          bonus: 100,
          levelUp: false,
          level: 4,
        ),
      );
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('MISSION COMPLETE'), findsOneWidget);
      expect(find.text('Cleaning'), findsOneWidget);
      expect(find.text('LEVEL UP'), findsNothing);
      await _end(tester);

      final cs = await _pump(tester, locale: const Locale('cs'));
      await _show(
        tester,
        cs,
        const MissionReward(
          missionName: 'Úklid',
          bonus: 50,
          levelUp: false,
          level: 4,
        ),
      );
      expect(find.text('MISE SPLNĚNA'), findsOneWidget);
      expect(find.text('+50 XP'), findsOneWidget);
      await _end(tester);
    });

    testWidgets('level-up variant shows the new level in both languages', (
      tester,
    ) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest(levelUp: true, level: 5));
      expect(find.text('LEVEL UP'), findsOneWidget);
      expect(find.text('QUEST COMPLETE'), findsNothing);
      expect(find.text('You reached level 5'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Sweep the floor'), findsOneWidget);
      await _end(tester);

      final cs = await _pump(tester, locale: const Locale('cs'));
      await _show(
        tester,
        cs,
        const MissionReward(
          missionName: 'Úklid',
          bonus: 100,
          levelUp: true,
          level: 6,
        ),
      );
      expect(find.text('NOVÁ ÚROVEŇ'), findsOneWidget);
      expect(find.text('Dosáhl jsi úrovně 6'), findsOneWidget);
      await _end(tester);
    });
  });

  group('dismissal', () {
    testWidgets('auto-dismisses after 2.5 seconds', (tester) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest());
      expect(find.byType(RewardCard), findsOneWidget);

      await tester.pump(Motion.rewardDismiss - Motion.panel - Motion.hover);
      expect(find.byType(RewardCard), findsOneWidget);
      expect(c.read(rewardQueueProvider), hasLength(1));

      await tester.pump(Motion.hover * 2);
      await tester.pump(_exitDone);
      await tester.pump();
      expect(find.byType(RewardCard), findsNothing);
      expect(c.read(rewardQueueProvider), isEmpty);
      await _end(tester);
    });

    testWidgets('does not auto-dismiss while the mission offer is shown', (
      tester,
    ) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest(mission: _progress, offer: true));
      expect(find.text('Complete mission'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(
        find.text(
          'All quests are done — complete the mission to claim the bonus.',
        ),
        findsOneWidget,
      );

      await tester.pump(Motion.rewardDismiss * 4);
      expect(find.byType(RewardCard), findsOneWidget);
      expect(c.read(rewardQueueProvider), hasLength(1));
      await _end(tester);
    });

    testWidgets('"Complete mission" reports the mission id and dismisses', (
      tester,
    ) async {
      final calls = <int>[];
      final c = await _pump(tester, onCompleteMission: calls.add);
      await _show(tester, c, _quest(mission: _progress, offer: true));

      await tester.tap(find.text('Complete mission'));
      await tester.pump();
      await tester.pump(_exitDone);
      await tester.pump();
      expect(calls, <int>[_missionId]);
      expect(find.byType(RewardCard), findsNothing);
      expect(c.read(rewardQueueProvider), isEmpty);
      await _end(tester);
    });

    testWidgets('"Continue" dismisses at once, even with the offer', (
      tester,
    ) async {
      final calls = <int>[];
      final c = await _pump(tester, onCompleteMission: calls.add);
      await _show(tester, c, _quest(mission: _progress, offer: true));

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(_exitDone);
      await tester.pump();
      expect(calls, isEmpty);
      expect(find.byType(RewardCard), findsNothing);
      await _end(tester);
    });

    testWidgets('tapping the scrim dismisses, tapping the card does not', (
      tester,
    ) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest(mission: _progress, offer: true));

      await tester.tap(find.text('Sweep the floor'));
      await tester.pump(Motion.panel);
      expect(find.byType(RewardCard), findsOneWidget);

      await tester.tapAt(const Offset(4, 4));
      await tester.pump();
      await tester.pump(_exitDone);
      await tester.pump();
      expect(find.byType(RewardCard), findsNothing);
      expect(c.read(rewardQueueProvider), isEmpty);
      await _end(tester);
    });

    testWidgets('draws nothing while the queue is empty', (tester) async {
      await _pump(tester);
      expect(find.byType(RewardCard), findsNothing);
      await _end(tester);
    });
  });

  group('queue', () {
    testWidgets('shows queued rewards one after another', (tester) async {
      final c = await _pump(tester);
      c.read(rewardQueueProvider.notifier)
        ..push(_quest(name: 'First quest'))
        ..push(_quest(name: 'Second quest', xp: 50));
      await tester.pump();
      await tester.pump(Motion.panel);

      expect(find.text('First quest'), findsOneWidget);
      expect(find.text('Second quest'), findsNothing);
      expect(find.byType(RewardCard), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(Motion.panel);
      await tester.pump(Motion.panel);
      expect(find.text('First quest'), findsNothing);
      expect(find.text('Second quest'), findsOneWidget);
      expect(find.text('+50 XP'), findsOneWidget);
      expect(find.byType(RewardCard), findsOneWidget);

      // The second one gets its own full 2.5 s.
      await tester.pump(Motion.rewardDismiss);
      await tester.pump(_exitDone);
      await tester.pump();
      expect(find.byType(RewardCard), findsNothing);
      expect(c.read(rewardQueueProvider), isEmpty);
      await _end(tester);
    });

    testWidgets('a reward pushed while one is shown waits', (tester) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest(name: 'First quest'));
      c.read(rewardQueueProvider.notifier).push(_quest(name: 'Late quest'));
      await tester.pump();
      expect(find.text('Late quest'), findsNothing);
      expect(find.text('First quest'), findsOneWidget);
      await tester.pump(Motion.rewardDismiss);
      await tester.pump(Motion.panel);
      await tester.pump(Motion.panel);
      expect(find.text('Late quest'), findsOneWidget);
      await _end(tester);
    });
  });

  group('motion', () {
    testWidgets('normal motion scales the card in', (tester) async {
      final c = await _pump(tester);
      await _show(tester, c, _quest());
      expect(
        find.descendant(
          of: find.byType(RewardOverlay),
          matching: find.byType(ScaleTransition),
        ),
        findsWidgets,
      );
      await _end(tester);
    });

    testWidgets('reduced motion uses a fade of at most 150 ms only', (
      tester,
    ) async {
      final c = await _pump(tester, disableAnimations: true);
      c.read(rewardQueueProvider.notifier).push(_quest());
      await tester.pump();
      await tester.pump(Motion.reducedFade ~/ 2);

      expect(
        find.descendant(
          of: find.byType(RewardOverlay),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );
      final FadeTransition mid = tester.widget(
        find
            .descendant(
              of: find.byType(RewardOverlay),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(mid.opacity.value, inExclusiveRange(0, 1));

      await tester.pump(Motion.reducedFade);
      final FadeTransition done = tester.widget(
        find
            .descendant(
              of: find.byType(RewardOverlay),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(done.opacity.value, 1);

      // Disappears with the same short fade.
      await tester.pump(Motion.rewardDismiss);
      await tester.pump(_reducedExitDone);
      await tester.pump();
      expect(find.byType(RewardCard), findsNothing);
      await _end(tester);
    });
  });
}
