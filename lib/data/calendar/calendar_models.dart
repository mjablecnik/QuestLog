import '../../core/calendar/event_type.dart';
import '../../core/calendar/repeat_rule.dart';

DateTime _dateOnly(DateTime v) => DateTime(v.year, v.month, v.day);

/// Whole days from [a] to [b], both calendar dates (DST-safe).
int daysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

/// A stored calendar event, or the first occurrence of a series.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.name,
    this.note,
    this.location,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.startMinute,
    this.endMinute,
    this.repeat = const NoRepeat(),
    required this.onBoard,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String? note;
  final String? location;
  final EventType type;

  /// First start date (date only). For a built-in Easter or n-th weekday rule it
  /// is the date the series begins, not an occurrence.
  final DateTime startDate;
  final DateTime endDate;

  /// Minutes since midnight; both null for an all-day event.
  final int? startMinute;
  final int? endMinute;
  final RepeatRule repeat;
  final bool onBoard;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get allDay => startMinute == null;

  /// Days an occurrence extends beyond its start date.
  int get spanDays => daysBetween(startDate, endDate);

  /// The length of one occurrence; whole days for an all-day event.
  Duration get duration {
    if (allDay) return Duration(days: spanDays + 1);
    return Duration(minutes: spanDays * 1440 + (endMinute! - startMinute!));
  }

  /// A seeded built-in event (they are stored with `created_at` at the epoch).
  bool get isBuiltIn => createdAt.millisecondsSinceEpoch == 0;
}

/// One appearance of a [CalendarEvent] on the calendar.
class EventOccurrence {
  const EventOccurrence({required this.event, required this.start, this.completion});

  final CalendarEvent event;

  /// The date this occurrence starts (date only).
  final DateTime start;
  final EventCompletion? completion;

  /// The last date this occurrence touches.
  DateTime get end => DateTime(start.year, start.month, start.day + event.spanDays);

  bool get isCompleted => completion != null;

  @override
  bool operator ==(Object other) =>
      other is EventOccurrence &&
      other.event.id == event.id &&
      other.start == start &&
      other.completion?.completedAt == completion?.completedAt;

  @override
  int get hashCode => Object.hash(event.id, start, completion?.completedAt);
}

/// The record that one occurrence was completed.
class EventCompletion {
  const EventCompletion({
    required this.eventId,
    required this.occurrenceDate,
    required this.completedAt,
    required this.awardedXp,
  });

  final int eventId;
  final DateTime occurrenceDate;
  final DateTime completedAt;
  final int awardedXp;
}

/// The editable fields of a [CalendarEvent].
class EventDraft {
  const EventDraft({
    required this.name,
    this.note,
    this.location,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.startMinute,
    this.endMinute,
    this.repeat = const NoRepeat(),
    required this.onBoard,
  });

  factory EventDraft.fromEvent(CalendarEvent e) => EventDraft(
    name: e.name,
    note: e.note,
    location: e.location,
    type: e.type,
    startDate: e.startDate,
    endDate: e.endDate,
    startMinute: e.startMinute,
    endMinute: e.endMinute,
    repeat: e.repeat,
    onBoard: e.onBoard,
  );

  final String name;
  final String? note;
  final String? location;
  final EventType type;
  final DateTime startDate;
  final DateTime endDate;
  final int? startMinute;
  final int? endMinute;
  final RepeatRule repeat;
  final bool onBoard;

  bool get allDay => startMinute == null;

  EventDraft copyWith({
    String? name,
    String? note,
    bool clearNote = false,
    String? location,
    bool clearLocation = false,
    EventType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? startMinute,
    int? endMinute,
    bool allDay = false,
    bool timed = false,
    RepeatRule? repeat,
    bool? onBoard,
  }) => EventDraft(
    name: name ?? this.name,
    note: clearNote ? null : (note ?? this.note),
    location: clearLocation ? null : (location ?? this.location),
    type: type ?? this.type,
    startDate: startDate == null ? this.startDate : _dateOnly(startDate),
    endDate: endDate == null ? this.endDate : _dateOnly(endDate),
    startMinute: allDay ? null : (startMinute ?? this.startMinute),
    endMinute: allDay ? null : (endMinute ?? this.endMinute),
    repeat: repeat ?? this.repeat,
    onBoard: onBoard ?? this.onBoard,
  );
}

/// What a deletion removed, enough to put it back exactly.
class DeletedEventSnapshot {
  const DeletedEventSnapshot({
    required this.event,
    required this.skippedDates,
    required this.completions,
    this.questId,
  });

  /// The Quest whose Deadline this event was, so that an undo can link it again.
  final int? questId;
  final CalendarEvent event;
  final List<DateTime> skippedDates;
  final List<EventCompletion> completions;
}

/// One event found by the search, with the occurrence to open.
class SearchResult {
  const SearchResult({required this.event, required this.occurrenceDate});

  final CalendarEvent event;
  final DateTime occurrenceDate;
}
