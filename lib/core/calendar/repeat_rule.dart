import '../cadence.dart';
import 'easter.dart';

/// How a Calendar_Event repeats, with an optional inclusive end date.
sealed class RepeatRule {
  const RepeatRule({this.end});

  /// The last date on which an occurrence may start (date only), or null.
  final DateTime? end;

  /// The same rule with another [end].
  RepeatRule withEnd(DateTime? end);
}

/// A single occurrence.
final class NoRepeat extends RepeatRule {
  const NoRepeat({super.end});

  @override
  RepeatRule withEnd(DateTime? end) => NoRepeat(end: end);
}

/// Daily, weekly, monthly or yearly from the start date.
final class CadenceRepeat extends RepeatRule {
  const CadenceRepeat(this.cadence, {super.end})
    : assert(
        cadence == Cadence.daily ||
            cadence == Cadence.weekly ||
            cadence == Cadence.monthly ||
            cadence == Cadence.yearly,
      );

  final Cadence cadence;

  @override
  RepeatRule withEnd(DateTime? end) => CadenceRepeat(cadence, end: end);
}

/// Every year, [offsetDays] after Easter Sunday of that year. Built-in days only.
final class EasterRelative extends RepeatRule {
  const EasterRelative(this.offsetDays, {super.end});

  final int offsetDays;

  @override
  RepeatRule withEnd(DateTime? end) => EasterRelative(offsetDays, end: end);
}

/// Every year, on the [ordinal]-th [weekday] of [month]. Built-in days only.
final class NthWeekday extends RepeatRule {
  const NthWeekday({
    required this.month,
    required this.weekday,
    required this.ordinal,
    super.end,
  });

  final int month;
  final int weekday;
  final int ordinal;

  @override
  RepeatRule withEnd(DateTime? end) =>
      NthWeekday(month: month, weekday: weekday, ordinal: ordinal, end: end);
}

DateTime _dateOnly(DateTime v) => DateTime(v.year, v.month, v.day);

DateTime _plusDays(DateTime v, int days) => DateTime(v.year, v.month, v.day + days);

/// The start dates of the occurrences that touch [from]..[to] (inclusive), in
/// order.
///
/// An occurrence touches the range when it starts on or before [to] and its
/// last day (start plus [spanDays]) is on or after [from]. Nothing starts
/// before [firstStart], after the rule's end, or on a date in [skipped]. All
/// dates are calendar dates; time parts are ignored. A series with no end only
/// iterates over the requested range.
Iterable<DateTime> occurrenceStarts({
  required DateTime firstStart,
  required int spanDays,
  required RepeatRule rule,
  Set<DateTime> skipped = const <DateTime>{},
  required DateTime from,
  required DateTime to,
}) sync* {
  final DateTime first = _dateOnly(firstStart);
  final DateTime lo = _plusDays(_dateOnly(from), -spanDays);
  DateTime hi = _dateOnly(to);
  final DateTime? end = rule.end == null ? null : _dateOnly(rule.end!);
  if (end != null && end.isBefore(hi)) hi = end;
  if (hi.isBefore(lo)) return;

  bool wanted(DateTime d) =>
      !d.isBefore(first) && !d.isBefore(lo) && !d.isAfter(hi) && !skipped.contains(d);

  switch (rule) {
    case NoRepeat():
      if (wanted(first)) yield first;
    case CadenceRepeat(:final Cadence cadence):
      int k = firstIndexAfter(first, cadence, _plusDays(lo, -1));
      while (true) {
        final DateTime d = occurrenceDate(first, cadence, k);
        if (d.isAfter(hi)) break;
        if (wanted(d)) yield d;
        k++;
      }
    case EasterRelative(:final int offsetDays):
      for (int year = lo.year; year <= hi.year; year++) {
        final DateTime d = _plusDays(easterSunday(year), offsetDays);
        if (wanted(d)) yield d;
      }
    case NthWeekday(:final int month, :final int weekday, :final int ordinal):
      for (int year = lo.year; year <= hi.year; year++) {
        final DateTime d = nthWeekdayOfMonth(year, month, weekday, ordinal);
        if (wanted(d)) yield d;
      }
  }
}
