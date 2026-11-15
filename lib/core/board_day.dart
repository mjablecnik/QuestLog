/// Local time at which a new Board_Day begins (Day_Start).
const Duration dayStart = Duration(hours: 4);

/// Start of the Board_Day containing [now]: the most recent local 04:00 at or
/// before [now].
///
/// Built with the `DateTime` constructor rather than by subtracting a fixed
/// 24 hours, so it stays correct across daylight-saving changes.
DateTime boardDayStart(DateTime now) {
  final sameDay = boardDayStartOf(DateTime(now.year, now.month, now.day));
  if (!now.isBefore(sameDay)) {
    return sameDay;
  }
  return boardDayStartOf(DateTime(now.year, now.month, now.day - 1));
}

/// Calendar date (time stripped) of the Board_Day containing [now].
DateTime todayOf(DateTime now) {
  final start = boardDayStart(now);
  return DateTime(start.year, start.month, start.day);
}

/// 04:00 local on the calendar date [today]: the start of that Board_Day.
///
/// Used by services that receive Today from the caller instead of the Clock.
DateTime boardDayStartOf(DateTime today) {
  return DateTime(
    today.year,
    today.month,
    today.day,
    dayStart.inHours,
    dayStart.inMinutes % 60,
  );
}

/// The half-open time range `[start, end)` covering the Board_Days from [first]
/// to [last] inclusive, both given as calendar dates.
({DateTime start, DateTime end}) boardDayRange(DateTime first, DateTime last) {
  return (
    start: boardDayStartOf(first),
    end: boardDayStartOf(DateTime(last.year, last.month, last.day + 1)),
  );
}
