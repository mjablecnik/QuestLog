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
