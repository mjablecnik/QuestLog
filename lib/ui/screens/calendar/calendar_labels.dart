import 'package:intl/intl.dart';

import '../../../core/cadence.dart';
import '../../../core/calendar/event_type.dart';
import '../../../core/calendar/repeat_rule.dart';
import '../../../data/calendar/calendar_models.dart';
import '../../../l10n/app_localizations.dart';

/// Localized name of an [EventType].
String eventTypeName(AppLocalizations l, EventType type) => switch (type) {
  EventType.dance => l.calendar_typeDance,
  EventType.work => l.calendar_typeWork,
  EventType.birthday => l.calendar_typeBirthday,
  EventType.nameDay => l.calendar_typeNameDay,
  EventType.publicHoliday => l.calendar_typePublicHoliday,
  EventType.notableDay => l.calendar_typeNotableDay,
  EventType.date => l.calendar_typeDate,
  EventType.meeting => l.calendar_typeMeeting,
  EventType.seminar => l.calendar_typeSeminar,
  EventType.lesson => l.calendar_typeLesson,
  EventType.quest => l.calendar_typeQuest,
};

String _capitalized(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// "Listopad 2026": the month title in the header of the Month_View.
String monthTitle(DateTime month, String locale) =>
    _capitalized(DateFormat('LLLL y', locale).format(month));

/// "Středa 18. listopadu" (Czech) or "Wednesday, November 18": the heading of the Day_Sheet.
String dayHeading(DateTime date, String locale) => _capitalized(
  locale == 'cs'
      ? DateFormat('EEEE d. MMMM', locale).format(date)
      : DateFormat.MMMMEEEEd(locale).format(date),
);

/// "st 18. 11. 2026": a date with its weekday, as in the detail screen.
String shortDateLabel(DateTime date, String locale) =>
    DateFormat.yMMMEd(locale).format(date);

/// "18. listopadu 2026".
String longDateLabel(DateTime date, String locale) =>
    DateFormat.yMMMMd(locale).format(date);

/// "08:15" from minutes since midnight.
String minuteLabel(int minute) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(minute ~/ 60)}:${two(minute % 60)}';
}

/// "2." in Czech, "2nd" in English.
String ordinalLabel(int n, String locale) {
  if (locale == 'cs') return '$n.';
  final int tens = n % 100;
  if (tens >= 11 && tens <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

/// The repeat of an event in words, for the occurrence that starts on [start]:
/// "středa každý týden", "každý rok, 2. neděle (květen)", with its end if any.
String repeatDescription(AppLocalizations l, RepeatRule rule, DateTime start) {
  final String locale = l.localeName;
  final String text = switch (rule) {
    NoRepeat() => l.calendar_repeatNever,
    CadenceRepeat(:final Cadence cadence) => switch (cadence) {
      Cadence.weekly => l.calendar_repeatDescWeekly(DateFormat.EEEE(locale).format(start)),
      Cadence.monthly => l.calendar_repeatDescMonthly(start.day),
      Cadence.yearly => l.calendar_repeatDescYearly(
        locale == 'cs' ? DateFormat('d. MMMM', locale).format(start) : DateFormat.MMMMd(locale).format(start),
      ),
      _ => l.calendar_repeatDescDaily,
    },
    EasterRelative() => l.calendar_repeatDescEaster,
    NthWeekday(:final int month, :final int weekday, :final int ordinal) => l.calendar_repeatDescNth(
      ordinalLabel(ordinal, locale),
      DateFormat.EEEE(locale).format(DateTime(2026, 11, 2 + weekday - 1)),
      DateFormat('LLLL', locale).format(DateTime(2026, month)),
    ),
  };
  final DateTime? end = rule.end;
  if (rule is NoRepeat || end == null) return text;
  return l.calendar_repeatUntil(text, shortDateLabel(end, locale));
}

/// The time line of an occurrence on [date]: "08:15 – 10:00", or "Celý den".
///
/// A multi-day timed occurrence shows only the part that falls on [date].
({String start, String end})? timesOn(CalendarEvent event, DateTime occurrenceStart, DateTime date) {
  if (event.allDay) return null;
  final bool first = date == occurrenceStart;
  final DateTime last = DateTime(
    occurrenceStart.year,
    occurrenceStart.month,
    occurrenceStart.day + event.spanDays,
  );
  final bool final_ = date == last;
  if (!first && !final_) return null;
  return (
    start: first ? minuteLabel(event.startMinute!) : minuteLabel(0),
    end: final_ ? minuteLabel(event.endMinute!) : minuteLabel(24 * 60 - 1),
  );
}
