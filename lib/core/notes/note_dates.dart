/// How the last-edited date of a Note is written.
enum NoteDateKind { today, yesterday, thisYear, earlier }

/// Classifies [edited] against [now] by calendar date in local time.
NoteDateKind noteDateKind(DateTime edited, DateTime now) {
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime day = DateTime(edited.year, edited.month, edited.day);
  if (!day.isBefore(today)) return NoteDateKind.today;
  if (day == DateTime(today.year, today.month, today.day - 1)) {
    return NoteDateKind.yesterday;
  }
  return day.year == today.year ? NoteDateKind.thisYear : NoteDateKind.earlier;
}
