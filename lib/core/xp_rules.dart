import 'dart:math' as math;

/// Effort tier of a Quest, chosen mostly by the time it takes.
///
/// The enum names are the values stored in the database, so the first three
/// keep their original names. Shown to the user as effort steps 1 to 4:
/// [easy] a moment, [normal] an hour, [hard] part of a day, [fullDay] a whole
/// day.
enum Difficulty { easy, normal, hard, fullDay }

/// Extra XP granted when a Mission is completed.
enum MissionBonus { small, medium, large }

extension DifficultyXp on Difficulty {
  /// XP awarded for completing a Quest of this Difficulty.
  int get xp => switch (this) {
        Difficulty.easy => 10,
        Difficulty.normal => 25,
        Difficulty.hard => 50,
        Difficulty.fullDay => 100,
      };
}

extension MissionBonusXp on MissionBonus {
  /// XP granted for completing a Mission with this bonus.
  int get xp => switch (this) {
        MissionBonus.small => 50,
        MissionBonus.medium => 100,
        MissionBonus.large => 200,
      };
}

/// The Level_Progress of a hero: the Level plus the XP earned inside it.
class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.xpIntoLevel,
    required this.threshold,
  });

  final int level;

  /// XP earned inside the current Level, in `[0, threshold)`.
  final int xpIntoLevel;

  /// XP needed to advance from [level] to the next Level.
  final int threshold;

  @override
  bool operator ==(Object other) =>
      other is LevelProgress &&
      other.level == level &&
      other.xpIntoLevel == xpIntoLevel &&
      other.threshold == threshold;

  @override
  int get hashCode => Object.hash(level, xpIntoLevel, threshold);

  @override
  String toString() => 'LevelProgress(level: $level, $xpIntoLevel/$threshold)';
}

/// XP needed to advance from [level] to [level] + 1: `100 + 50 × (L − 1)`.
int levelThreshold(int level) {
  _checkLevel(level);
  return 100 + 50 * (level - 1);
}

/// Cumulative XP needed to reach [level]; Level 1 needs 0.
int xpToReachLevel(int level) {
  _checkLevel(level);
  final n = level - 1;
  return 100 * n + 25 * n * (n - 1);
}

/// The Level for [totalXp]; there is no upper limit.
int levelFor(int totalXp) {
  if (totalXp < 0) {
    throw ArgumentError.value(totalXp, 'totalXp', 'must not be negative');
  }
  // Solve 25n² + 75n <= totalXp for n = level - 1, then correct rounding.
  var n = ((-75 + math.sqrt(5625 + 100 * totalXp)) / 50).floor();
  if (n < 0) n = 0;
  while (xpToReachLevel(n + 2) <= totalXp) {
    n++;
  }
  while (n > 0 && xpToReachLevel(n + 1) > totalXp) {
    n--;
  }
  return n + 1;
}

/// Level, XP earned inside it and its threshold for [totalXp].
LevelProgress progressFor(int totalXp) {
  final level = levelFor(totalXp);
  return LevelProgress(
    level: level,
    xpIntoLevel: totalXp - xpToReachLevel(level),
    threshold: levelThreshold(level),
  );
}

void _checkLevel(int level) {
  if (level < 1) {
    throw ArgumentError.value(level, 'level', 'must be at least 1');
  }
}
