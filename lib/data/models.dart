import '../core/cadence.dart';
import '../core/xp_rules.dart';
import 'preferences.dart';

/// Lifecycle state of a Mission.
enum MissionStatus { open, completed, closed }

/// The part of the Board a Quest is posted in. A Quest with no section is not
/// on the Board (only a Quest of a Mission can be like that).
enum BoardSection { todo, today }

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
  });

  /// The trimmed hero name; empty when no name is set.
  final String heroName;
  final AppLanguage language;
  final AppTheme theme;

  /// The hero name, or null when none is set (the UI then shows only the Level).
  String? get displayName => heroName.isEmpty ? null : heroName;

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.heroName == heroName &&
      other.language == language &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(heroName, language, theme);

  @override
  String toString() =>
      'AppSettings($heroName, $language, $theme)';
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
    this.board,
    this.eventId,
  });

  final int id;
  final String name;
  final String? note;
  final Difficulty difficulty;
  final int? missionId;

  /// Where on the Board the Quest is posted; null when it is not on the Board.
  final BoardSection? board;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// XP recorded at completion; null while the Quest is open.
  final int? awardedXp;

  /// The calendar event that carries the Quest's Deadline, if it has one.
  final int? eventId;

  bool get isDone => completedAt != null;
}

/// Input for creating or editing a Quest.
class QuestDraft {
  const QuestDraft({
    required this.name,
    required this.difficulty,
    this.note,
    this.missionId,
    this.board,
    this.deadline,
  });

  final String name;
  final String? note;
  final Difficulty difficulty;

  /// The date the Quest is meant to be done by; null for none.
  final DateTime? deadline;
  final int? missionId;

  /// The Board section. A Quest without a Mission is always on the Board, so
  /// null means Todo for it; for a Quest of a Mission null means off the Board.
  final BoardSection? board;
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
    this.revokedBonus = 0,
  });

  /// The XP recorded at completion that was taken back; 0 when the Quest was open.
  final int revokedXp;

  /// True when the parent Mission was `completed` and went back to `open`.
  final bool missionReopened;
  final int levelAfter;

  /// The Mission_Bonus taken back with the Mission; 0 when it stayed as it was.
  final int revokedBonus;
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

/// A quest template of a Recurring_Rule, as the user enters it.
class RuleQuestDraft {
  const RuleQuestDraft({required this.name, required this.difficulty});

  final String name;
  final Difficulty difficulty;
}

/// Input for creating or editing a Recurring_Rule.
class RuleDraft {
  const RuleDraft({
    required this.name,
    required this.cadence,
    required this.requestedAnchor,
    required this.bonus,
    required this.quests,
  });

  final String name;
  final Cadence cadence;

  /// A date in the series the user asked for; the service turns it into the real
  /// Anchor_Date (the first Occurrence on or after Today).
  final DateTime requestedAnchor;
  final MissionBonus bonus;
  final List<RuleQuestDraft> quests;
}

/// A stored quest template, in posting order.
class RuleQuest {
  const RuleQuest({
    required this.name,
    required this.difficulty,
    required this.sortOrder,
  });

  final String name;
  final Difficulty difficulty;
  final int sortOrder;
}

/// A stored Recurring_Rule with its quest templates.
class RecurringRule {
  const RecurringRule({
    required this.id,
    required this.name,
    required this.cadence,
    required this.anchorDate,
    required this.nextIndex,
    required this.bonus,
    required this.lastPostedOn,
    required this.createdAt,
    required this.quests,
  });

  final int id;
  final String name;
  final Cadence cadence;
  final DateTime anchorDate;

  /// Index of the Next_Occurrence in the series that starts at [anchorDate].
  final int nextIndex;
  final MissionBonus bonus;
  final DateTime? lastPostedOn;
  final DateTime createdAt;
  final List<RuleQuest> quests;
}

/// A Recurring_Rule as the Settings screen lists and edits it.
class RuleSummary {
  const RuleSummary({
    required this.id,
    required this.name,
    required this.cadence,
    required this.anchorDate,
    required this.bonus,
    required this.quests,
    required this.nextOccurrence,
    required this.hasOpenInstance,
  });

  final int id;
  final String name;
  final Cadence cadence;
  final DateTime anchorDate;
  final MissionBonus bonus;
  final List<RuleQuest> quests;

  /// The date of the Next_Occurrence.
  final DateTime nextOccurrence;

  /// True while an `open` Instance of the rule exists.
  final bool hasOpenInstance;
}

/// Outcome of posting a rule by hand.
class PostResult {
  const PostResult({
    required this.mission,
    required this.skippedNextPosting,
    required this.closedPreviousInstance,
  });

  final Mission mission;

  /// True when the nearest automatic Posting was skipped because it was still ahead.
  final bool skippedNextPosting;

  /// True when an earlier `open` Instance of the rule was closed.
  final bool closedPreviousInstance;
}
