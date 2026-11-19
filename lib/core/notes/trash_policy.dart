/// How long a Trashed_Node stays in the Trash before it is purged.
const Duration trashRetention = Duration(days: 30);

/// True from exactly `deletedAt + trashRetention` on.
bool isExpired(DateTime deletedAt, DateTime now) =>
    !now.isBefore(deletedAt.add(trashRetention));

/// Whole days left until the Purge, rounded up: 30 on the day of deletion and
/// never below 1 while the node is not expired. 0 once it is expired.
int daysUntilPurge(DateTime deletedAt, DateTime now) {
  if (isExpired(deletedAt, now)) return 0;
  final Duration left = deletedAt.add(trashRetention).difference(now);
  final int days = (left.inMicroseconds / Duration.microsecondsPerDay).ceil();
  return days.clamp(1, trashRetention.inDays);
}
