import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart'
    hide expect, test, group, setUp, tearDown, setUpAll, tearDownAll;
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/ui/state/reward_queue.dart';

Quest _quest({int? missionId}) => Quest(
  id: 1,
  name: 'Quest',
  note: null,
  difficulty: Difficulty.normal,
  missionId: missionId,
  sortOrder: 1,
  createdAt: DateTime(2026, 11, 1),
  completedAt: null,
  awardedXp: null,
);

Mission _mission() => Mission(
  id: 2,
  name: 'Mission',
  bonus: MissionBonus.medium,
  status: MissionStatus.open,
  ruleId: null,
  createdAt: DateTime(2026, 11, 1),
  completedAt: null,
  awardedBonus: null,
);

void main() {
  group('Property 4: reward events reflect the service result', () {
    Glados3(any.intInRange(1, 50), any.intInRange(0, 3), any.intInRange(0, 200))
        .test('rewardForQuest', (levelBefore, rise, xp) {
      final ready = xp.isEven;
      final progressKind = xp % 4;
      final progress = progressKind == 0
          ? null
          : MissionProgress(
              done: progressKind,
              total: progressKind + 1,
              remainingXp: xp,
            );
      final result = CompleteQuestResult(
        awardedXp: xp,
        levelBefore: levelBefore,
        levelAfter: levelBefore + rise,
        mission: progress,
        missionReadyToComplete: ready,
      );
      final event = rewardForQuest(
        _quest(missionId: progress == null ? null : 2),
        result,
      );
      expect(event.levelUp, rise > 0);
      expect(event.xp, xp);
      expect(event.level, levelBefore + rise);
      expect(event.offerMissionComplete, ready);
      expect(event.mission, progress);
      expect(event.missionId, progress == null ? null : 2);
    });

    Glados3(any.intInRange(1, 50), any.intInRange(0, 3), any.intInRange(0, 300))
        .test('rewardForMission', (levelBefore, rise, bonus) {
          final event = rewardForMission(
            _mission(),
            CompleteMissionResult(
              awardedBonus: bonus,
              levelBefore: levelBefore,
              levelAfter: levelBefore + rise,
            ),
          );
          expect(event.levelUp, rise > 0);
          expect(event.bonus, bonus);
          expect(event.level, levelBefore + rise);
          expect(event.missionName, 'Mission');
        });
  });

  group('RewardQueue', () {
    late ProviderContainer container;
    setUp(() {
      container = ProviderContainer();
      container.listen(rewardQueueProvider, (_, _) {});
    });
    tearDown(() => container.dispose());

    RewardEvent? current() => container.read(currentRewardProvider);

    test('is empty at start and dismissing an empty queue is a no-op', () {
      expect(current(), isNull);
      container.read(rewardQueueProvider.notifier).dismissCurrent();
      expect(container.read(rewardQueueProvider), isEmpty);
    });

    test('events pushed in quick succession show one at a time, in order', () {
      final queue = container.read(rewardQueueProvider.notifier);
      final a = rewardForMission(
        _mission(),
        const CompleteMissionResult(
          awardedBonus: 100,
          levelBefore: 1,
          levelAfter: 1,
        ),
      );
      final b = rewardForQuest(
        _quest(),
        const CompleteQuestResult(
          awardedXp: 25,
          levelBefore: 1,
          levelAfter: 2,
          mission: null,
          missionReadyToComplete: false,
        ),
      );
      final c = rewardForQuest(
        _quest(),
        const CompleteQuestResult(
          awardedXp: 10,
          levelBefore: 2,
          levelAfter: 2,
          mission: null,
          missionReadyToComplete: false,
        ),
      );
      queue
        ..push(a)
        ..push(b)
        ..push(c);

      expect(current(), same(a));
      queue.dismissCurrent();
      expect(current(), same(b));
      queue.dismissCurrent();
      expect(current(), same(c));
      queue.dismissCurrent();
      expect(current(), isNull);
    });
  });
}
