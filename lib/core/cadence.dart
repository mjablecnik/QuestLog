/// How often a Recurring_Rule repeats.
enum Cadence { daily, weekly, biweekly, monthly, quarterly, yearly }

/// Occurrence number [k] of a rule: [anchor] advanced by [k] periods of
/// [cadence].
///
/// Month-based Cadences keep the anchor's day of month, clamped to the last day
/// of the target month. The result is always computed from [anchor] and [k],
/// never from a previous Occurrence, so clamping (31st, Feb 29) never drifts.
/// Only the calendar date of [anchor] is used; the result has no time part.
DateTime occurrenceDate(DateTime anchor, Cadence cadence, int k) {
  if (k < 0) {
    throw ArgumentError.value(k, 'k', 'must not be negative');
  }
  return switch (cadence) {
    Cadence.daily => DateTime(anchor.year, anchor.month, anchor.day + k),
    Cadence.weekly => DateTime(anchor.year, anchor.month, anchor.day + 7 * k),
    Cadence.biweekly => DateTime(anchor.year, anchor.month, anchor.day + 14 * k),
    Cadence.monthly => _addMonths(anchor, k),
    Cadence.quarterly => _addMonths(anchor, 3 * k),
    Cadence.yearly => _addMonths(anchor, 12 * k),
  };
}

/// Smallest index `k >= 0` whose Occurrence is strictly after [date]
/// (compared by calendar date).
int firstIndexAfter(DateTime anchor, Cadence cadence, DateTime date) {
  final day = _dateOnly(date);
  bool isAfter(int k) => occurrenceDate(anchor, cadence, k).isAfter(day);

  if (isAfter(0)) return 0;
  // Occurrences are strictly increasing in k: grow an upper bound, then bisect.
  var low = 0; // known not after [day]
  var high = 1;
  while (!isAfter(high)) {
    low = high;
    high *= 2;
  }
  while (high - low > 1) {
    final mid = low + (high - low) ~/ 2;
    if (isAfter(mid)) {
      high = mid;
    } else {
      low = mid;
    }
  }
  return high;
}

/// The Anchor_Date for a new or changed rule: the first Occurrence of the
/// series defined by [requested] that is on or after [today] and strictly
/// after [lastPosted].
///
/// A Yearly rule requested on Feb 29 lands on Feb 28 in a non-leap year and
/// keeps that date as its anchor from then on.
DateTime firstAnchor(
  Cadence cadence,
  DateTime requested, {
  required DateTime today,
  DateTime? lastPosted,
}) {
  var earliest = _dateOnly(today);
  if (lastPosted != null) {
    final afterLast = _dateOnly(lastPosted);
    final dayAfterLast = DateTime(afterLast.year, afterLast.month, afterLast.day + 1);
    if (dayAfterLast.isAfter(earliest)) earliest = dayAfterLast;
  }
  final series = _dateOnly(requested);
  // First index whose Occurrence is on or after [earliest], i.e. strictly after
  // the day before it.
  final k = firstIndexAfter(
    series,
    cadence,
    DateTime(earliest.year, earliest.month, earliest.day - 1),
  );
  return occurrenceDate(series, cadence, k);
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

DateTime _addMonths(DateTime anchor, int months) {
  final total = anchor.year * 12 + (anchor.month - 1) + months;
  final year = total ~/ 12;
  final month = total % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, anchor.day < lastDay ? anchor.day : lastDay);
}
