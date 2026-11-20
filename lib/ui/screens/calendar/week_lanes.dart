import '../../../data/calendar/calendar_models.dart';

/// The part of one Event_Occurrence that lies in one week row of the Month_View.
class WeekSegment {
  const WeekSegment({
    required this.occurrence,
    required this.startColumn,
    required this.endColumn,
    required this.continuesBefore,
    required this.continuesAfter,
    required this.lane,
  });

  final EventOccurrence occurrence;

  /// 0 (Monday) to 6 (Sunday), startColumn <= endColumn.
  final int startColumn;
  final int endColumn;

  /// The occurrence also touches a date before this week / after this week.
  final bool continuesBefore;
  final bool continuesAfter;

  /// The row of bars, from 0 at the top, the segment is drawn in.
  final int lane;

  bool covers(int column) => column >= startColumn && column <= endColumn;
}

/// Days from [from] to [to] by calendar date, not by 24 hour spans (a daylight
/// saving change inside the week must not shift a column).
int _daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// The segments of [occurrences] in the week that starts on [weekStart] (a
/// Monday), each in the lowest lane that is free in all its columns.
///
/// Lanes go first to the occurrences that touch more dates, then to all-day
/// ones before timed ones, then to timed ones by start time, then by name.
List<WeekSegment> layoutWeek(List<EventOccurrence> occurrences, DateTime weekStart) {
  final List<EventOccurrence> inWeek = <EventOccurrence>[
    for (final EventOccurrence o in occurrences)
      if (_daysBetween(weekStart, o.end) >= 0 && _daysBetween(weekStart, o.start) <= 6) o,
  ];
  inWeek.sort((EventOccurrence a, EventOccurrence b) {
    final int byLength = b.event.spanDays.compareTo(a.event.spanDays);
    if (byLength != 0) return byLength;
    final int byAllDay = (a.event.allDay ? 0 : 1).compareTo(b.event.allDay ? 0 : 1);
    if (byAllDay != 0) return byAllDay;
    final int byMinute = (a.event.startMinute ?? 0).compareTo(b.event.startMinute ?? 0);
    if (byMinute != 0) return byMinute;
    final int byName = a.event.name.compareTo(b.event.name);
    if (byName != 0) return byName;
    return a.event.id.compareTo(b.event.id);
  });

  final List<Set<int>> taken = <Set<int>>[];
  final List<WeekSegment> segments = <WeekSegment>[];
  for (final EventOccurrence o in inWeek) {
    final int first = _daysBetween(weekStart, o.start);
    final int last = _daysBetween(weekStart, o.end);
    final int start = first < 0 ? 0 : first;
    final int end = last > 6 ? 6 : last;
    int lane = 0;
    while (lane < taken.length && taken[lane].any((int c) => c >= start && c <= end)) {
      lane++;
    }
    if (lane == taken.length) taken.add(<int>{});
    taken[lane].addAll(<int>[for (int c = start; c <= end; c++) c]);
    segments.add(
      WeekSegment(
        occurrence: o,
        startColumn: start,
        endColumn: end,
        continuesBefore: first < 0,
        continuesAfter: last > 6,
        lane: lane,
      ),
    );
  }
  return segments;
}

/// How many lanes are drawn when [needed] lanes are wanted and [capacity] fit
/// in the cell: all of up to three, otherwise two; one lane less when there are
/// hidden occurrences, whose "+N" label needs a line of its own.
int lanesShown(int needed, int capacity) {
  if (capacity <= 0) return 0;
  if (needed <= 3) return needed <= capacity ? needed : capacity - 1;
  return capacity - 1 < 2 ? capacity - 1 : 2;
}
