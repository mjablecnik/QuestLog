import '../core/xp_rules.dart';
import 'preferences.dart';

/// Lifecycle state of a Mission.
enum MissionStatus { open, completed, closed }

/// Result of applying an XP delta to Total_XP.
class XpChange {
  const XpChange({
    required this.totalBefore,
    required this.totalAfter,
    required this.levelBefore,
    required this.levelAfter,
  });

  final int totalBefore;
  final int totalAfter;
  final int levelBefore;
  final int levelAfter;

  /// The XP actually applied after clamping at zero (negative when XP was removed).
  int get appliedDelta => totalAfter - totalBefore;

  @override
  bool operator ==(Object other) =>
      other is XpChange &&
      other.totalBefore == totalBefore &&
      other.totalAfter == totalAfter &&
      other.levelBefore == levelBefore &&
      other.levelAfter == levelAfter;

  @override
  int get hashCode => Object.hash(totalBefore, totalAfter, levelBefore, levelAfter);

  @override
  String toString() =>
      'XpChange($totalBefore -> $totalAfter, level $levelBefore -> $levelAfter)';
}

/// The hero name and appearance preferences.
class AppSettings {
  const AppSettings({
    required this.heroName,
    required this.language,
    required this.theme,
    required this.displayFont,
  });

  /// The trimmed hero name; empty when no name is set.
  final String heroName;
  final AppLanguage language;
  final AppTheme theme;
  final DisplayFont displayFont;

  /// The hero name, or null when none is set (the UI then shows only the Level).
  String? get displayName => heroName.isEmpty ? null : heroName;

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.heroName == heroName &&
      other.language == language &&
      other.theme == theme &&
      other.displayFont == displayFont;

  @override
  int get hashCode => Object.hash(heroName, language, theme, displayFont);

  @override
  String toString() =>
      'AppSettings($heroName, $language, $theme, $displayFont)';
}

/// A one-off task, standalone or part of a Mission.
class Quest {
  const Quest({
    required this.id,
    required this.name,
    required this.note,
    required this.difficulty,
    required this.missionId,
    required this.sortOrder,
    required this.createdAt,
    required this.completedAt,
    required this.awardedXp,
  });

  final int id;
  final String name;
  final String? note;
  final Difficulty difficulty;
  final int? missionId;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// XP recorded at completion; null while the Quest is open.
  final int? awardedXp;

  bool get isDone => completedAt != null;
}

/// Input for creating or editing a Quest.
class QuestDraft {
  const QuestDraft({
    required this.name,
    required this.difficulty,
    this.note,
    this.missionId,
  });

  final String name;
  final String? note;
  final Difficulty difficulty;
  final int? missionId;
}

/// Done and total Quest counts of a Mission and the XP its open Quests still award.
class MissionProgress {
  const MissionProgress({
    required this.done,
    required this.total,
    required this.remainingXp,
  });

  final int done;
  final int total;
  final int remainingXp;

  @override
  bool operator ==(Object other) =>
      other is MissionProgress &&
      other.done == done &&
      other.total == total &&
      other.remainingXp == remainingXp;

  @override
  int get hashCode => Object.hash(done, total, remainingXp);

  @override
  String toString() => 'MissionProgress($done/$total, $remainingXp XP left)';
}

/// Outcome of completing a Quest.
class CompleteQuestResult {
  const CompleteQuestResult({
    required this.awardedXp,
    required this.levelBefore,
    required this.levelAfter,
    required this.mission,
    required this.missionReadyToComplete,
  });

  /// XP awarded by this call; 0 when the Quest was already done.
  final int awardedXp;
  final int levelBefore;
  final int levelAfter;

  /// Progress of the parent Mission, or null for a standalone Quest.
  final MissionProgress? mission;

  /// True when the Mission is open, has Quests and all of them are now done.
  final bool missionReadyToComplete;
}

/// Outcome of reopening a Quest.
class ReopenQuestResult {
  const ReopenQuestResult({
    required this.revokedXp,
    required this.missionReopened,
    required this.levelAfter,
  });

  /// The XP recorded at completion that was taken back; 0 when the Quest was open.
  final int revokedXp;

  /// True when the parent Mission was `completed` and went back to `open`.
  final bool missionReopened;
  final int levelAfter;
}

/// A Quest as the board shows it: the Quest plus the name of its Mission.
class BoardQuest {
  const BoardQuest({required this.quest, required this.missionName});

  final Quest quest;

  /// The name of the Quest's Mission, or null for a standalone Quest.
  final String? missionName;
}

/// A done Quest as the history query returns it.
class HistoryQuest {
  const HistoryQuest({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.awardedXp,
    required this.completedAt,
    required this.missionName,
  });

  final int id;
  final String name;
  final Difficulty difficulty;
  final int awardedXp;
  final DateTime completedAt;
  final String? missionName;
}

/// A group of Quests with a bonus for completing all of them.
class Mission {
  const Mission({
    required this.id,
    required this.name,
    required this.bonus,
    required this.status,
    required this.ruleId,
    required this.createdAt,
    required this.completedAt,
    required this.awardedBonus,
  });

  final int id;
  final String name;
  final MissionBonus bonus;
  final MissionStatus status;

  /// The Recurring_Rule this Mission is an Instance of, or null for a one-off Mission.
  final int? ruleId;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// The bonus recorded at completion; null unless the Mission is `completed`.
  final int? awardedBonus;
}

/// Input for creating a Mission together with its first Quests.
class MissionDraft {
  const MissionDraft({
    required this.name,
    required this.bonus,
    this.quests = const [],
  });

  final String name;
  final MissionBonus bonus;
  final List<QuestDraft> quests;
}

/// One row of the Missions screen, also used for the "completed today" section
/// and the Mission picker.
class MissionSummary {
  const MissionSummary({
    required this.id,
    required this.name,
    required this.bonus,
    required this.status,
    required this.done,
    required this.total,
    required this.remainingXp,
    required this.ruleId,
    required this.completedAt,
    required this.awardedBonus,
  });

  final int id;
  final String name;
  final MissionBonus bonus;
  final MissionStatus status;
  final int done;
  final int total;

  /// The sum of the XP of the Mission's open Quests.
  final int remainingXp;
  final int? ruleId;
  final DateTime? completedAt;
  final int? awardedBonus;
}

/// A Mission with all of its Quests, including those completed on earlier days.
class MissionDetail {
  const MissionDetail({required this.mission, required this.quests});

  final Mission mission;
  final List<Quest> quests;
}

/// Outcome of completing a Mission.
class CompleteMissionResult {
  const CompleteMissionResult({
    required this.awardedBonus,
    required this.levelBefore,
    required this.levelAfter,
  });

  final int awardedBonus;
  final int levelBefore;
  final int levelAfter;
}

/// A `completed` Mission as the history query returns it.
class HistoryMission {
  const HistoryMission({
    required this.id,
    required this.name,
    required this.awardedBonus,
    required this.completedAt,
  });

  final int id;
  final String name;
  final int awardedBonus;
  final DateTime completedAt;
}
