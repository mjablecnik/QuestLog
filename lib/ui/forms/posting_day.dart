import '../../core/cadence.dart';

/// The part of a Recurring_Rule's schedule the user picks in the Rule_Sheet.
///
/// It mirrors what the domain treats as the rule's posting day (see
/// `RecurrenceService.update`): the weekday for Weekly and Biweekly, the day of
/// the month for Monthly, the day and month of the quarter for Quarterly, the
/// day and month for Yearly, and nothing for Daily.
sealed class PostingDay {
  const PostingDay();
}

/// Daily rules have no posting day.
final class NoPostingDay extends PostingDay {
  const NoPostingDay();

  @override
  bool operator ==(Object other) => other is NoPostingDay;

  @override
  int get hashCode => (NoPostingDay).hashCode;

  @override
  String toString() => 'NoPostingDay()';
}

/// A weekday, [DateTime.monday] (1) to [DateTime.sunday] (7), for Weekly and
/// Biweekly rules.
final class WeekdayPostingDay extends PostingDay {
  const WeekdayPostingDay(this.weekday)
    : assert(weekday >= DateTime.monday && weekday <= DateTime.sunday);

  final int weekday;

  @override
  bool operator ==(Object other) =>
      other is WeekdayPostingDay && other.weekday == weekday;

  @override
  int get hashCode => Object.hash(WeekdayPostingDay, weekday);

  @override
  String toString() => 'WeekdayPostingDay($weekday)';
}

/// A day of the month, 1 to 28, for Monthly rules.
final class MonthDayPostingDay extends PostingDay {
  const MonthDayPostingDay(this.day) : assert(day >= 1 && day <= maxDay);

  /// The last day of the month a Monthly rule may use, so every month has it.
  static const maxDay = 28;

  final int day;

  @override
  bool operator ==(Object other) =>
      other is MonthDayPostingDay && other.day == day;

  @override
  int get hashCode => Object.hash(MonthDayPostingDay, day);

  @override
  String toString() => 'MonthDayPostingDay($day)';
}

/// A full calendar date picked by the user, for Quarterly and Yearly rules.
///
/// Only its day of the month and its month matter (the month modulo 3 for
/// Quarterly), so the date may lie in the past or the future. [date] is kept
/// date-only; two values are equal when they hold the same calendar date.
final class DatePostingDay extends PostingDay {
  DatePostingDay(DateTime date)
    : date = DateTime(date.year, date.month, date.day);

  final DateTime date;

  @override
  bool operator ==(Object other) =>
      other is DatePostingDay && other.date == date;

  @override
  int get hashCode => Object.hash(DatePostingDay, date);

  @override
  String toString() =>
      'DatePostingDay(${date.year}-${_two(date.month)}-${_two(date.day)})';
}

/// The date to pass as `RuleDraft.requestedAnchor`: the nearest date on or after
/// [today] that matches [day] (the domain's `firstAnchor` then keeps it as is).
///
/// The result has no time part and lies less than one period of [cadence] after
/// [today] (Daily: it is [today]). A Weekly or Biweekly weekday that is today
/// gives today. For Quarterly and Yearly only the day of the month (and the month
/// modulo 3, or the month) of the picked date counts. Like the domain, a day
/// past the end of a month is clamped to its last day, so Yearly Feb 29 gives
/// Feb 28 in a non-leap year and Quarterly day 31 gives the 30th in April.
///
/// Throws [ArgumentError] when [day] is not the kind of posting day [cadence]
/// takes, or is out of range.
DateTime requestedAnchor(Cadence cadence, PostingDay day, DateTime today) {
  final base = _dateOnly(today);
  switch (cadence) {
    case Cadence.daily:
      if (day is! NoPostingDay) throw _mismatch(cadence, day);
      return base;
    case Cadence.weekly:
    case Cadence.biweekly:
      if (day is! WeekdayPostingDay) throw _mismatch(cadence, day);
      _checkRange(cadence, day.weekday, DateTime.monday, DateTime.sunday);
      final ahead = (day.weekday - base.weekday) % DateTime.daysPerWeek;
      return DateTime(base.year, base.month, base.day + ahead);
    case Cadence.monthly:
      if (day is! MonthDayPostingDay) throw _mismatch(cadence, day);
      _checkRange(cadence, day.day, 1, MonthDayPostingDay.maxDay);
      final thisMonth = DateTime(base.year, base.month, day.day);
      return thisMonth.isBefore(base)
          ? DateTime(base.year, base.month + 1, day.day)
          : thisMonth;
    case Cadence.quarterly:
      if (day is! DatePostingDay) throw _mismatch(cadence, day);
      // The same month class recurs every third month, so one of the current and
      // the next three months always qualifies.
      for (var ahead = 0; ahead <= 3; ahead++) {
        final month = base.month + ahead;
        if (month % 3 != day.date.month % 3) continue;
        final candidate = _clamped(base.year, month, day.date.day);
        if (!candidate.isBefore(base)) return candidate;
      }
      throw StateError(
        'unreachable: a month of every class lies within three months',
      );
    case Cadence.yearly:
      if (day is! DatePostingDay) throw _mismatch(cadence, day);
      final thisYear = _clamped(base.year, day.date.month, day.date.day);
      return thisYear.isBefore(base)
          ? _clamped(base.year + 1, day.date.month, day.date.day)
          : thisYear;
  }
}

/// Inverse of [requestedAnchor], for editing: the posting day of a stored
/// Anchor_Date.
///
/// Only the calendar date of [anchor] is used. A Monthly anchor is always on day
/// 1-28 in the domain; a later day is clamped to 28 so the result is valid.
PostingDay postingDayOf(Cadence cadence, DateTime anchor) {
  return switch (cadence) {
    Cadence.daily => const NoPostingDay(),
    Cadence.weekly || Cadence.biweekly => WeekdayPostingDay(anchor.weekday),
    Cadence.monthly => MonthDayPostingDay(
      anchor.day < MonthDayPostingDay.maxDay
          ? anchor.day
          : MonthDayPostingDay.maxDay,
    ),
    Cadence.quarterly || Cadence.yearly => DatePostingDay(anchor),
  };
}

/// The posting day a new rule starts with: today's weekday, today's day of the
/// month (at most 28), or today's date; none for Daily.
PostingDay defaultPostingDay(Cadence cadence, DateTime today) =>
    postingDayOf(cadence, today);

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Day [day] of [month] (which may be past 12), or the month's last day when it
/// is shorter.
DateTime _clamped(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, day < lastDay ? day : lastDay);
}

ArgumentError _mismatch(Cadence cadence, PostingDay day) =>
    ArgumentError.value(day, 'day', 'is not a posting day of a $cadence rule');

void _checkRange(Cadence cadence, int value, int min, int max) {
  if (value < min || value > max) {
    throw RangeError.range(
      value,
      min,
      max,
      'day',
      'out of range for a $cadence rule',
    );
  }
}

String _two(int value) => value.toString().padLeft(2, '0');
