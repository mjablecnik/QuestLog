import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';

sealed class RewardEvent {
  const RewardEvent();
}

/// Reward for completing a Quest.
final class QuestReward extends RewardEvent {
  const QuestReward({
    required this.questName,
    required this.xp,
    required this.levelUp,
    required this.level,
    required this.mission,
    required this.missionId,
    required this.offerMissionComplete,
  });

  final String questName;
  final int xp;
  final bool levelUp;

  /// The Level after the completion.
  final int level;
  final MissionProgress? mission;
  final int? missionId;
  final bool offerMissionComplete;
}

/// Reward for completing a Mission.
final class MissionReward extends RewardEvent {
  const MissionReward({
    required this.missionName,
    required this.bonus,
    required this.levelUp,
    required this.level,
  });

  final String missionName;
  final int bonus;
  final bool levelUp;
  final int level;
}

QuestReward rewardForQuest(Quest quest, CompleteQuestResult r) {
  return QuestReward(
    questName: quest.name,
    xp: r.awardedXp,
    levelUp: r.levelAfter > r.levelBefore,
    level: r.levelAfter,
    mission: r.mission,
    missionId: quest.missionId,
    offerMissionComplete: r.missionReadyToComplete,
  );
}

MissionReward rewardForMission(Mission mission, CompleteMissionResult r) {
  return MissionReward(
    missionName: mission.name,
    bonus: r.awardedBonus,
    levelUp: r.levelAfter > r.levelBefore,
    level: r.levelAfter,
  );
}

/// Pending rewards in the order they were earned; the first one is shown.
class RewardQueue extends Notifier<List<RewardEvent>> {
  @override
  List<RewardEvent> build() => const [];

  void push(RewardEvent event) => state = [...state, event];

  void dismissCurrent() {
    if (state.isEmpty) return;
    state = state.sublist(1);
  }
}

final rewardQueueProvider = NotifierProvider<RewardQueue, List<RewardEvent>>(
  RewardQueue.new,
);

/// The reward being shown, or null when the queue is empty.
final currentRewardProvider = Provider<RewardEvent?>((ref) {
  final queue = ref.watch(rewardQueueProvider);
  return queue.isEmpty ? null : queue.first;
});
