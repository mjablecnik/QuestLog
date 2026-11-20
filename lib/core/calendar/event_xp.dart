import 'event_type.dart';

/// The XP an Event_Task awards: 10, 25, 50 or 100.
///
/// A timed event is worth what its [duration] says (an event that spans
/// midnight is long). An all-day event has no length, so its XP comes from its
/// [type]. The duration is an argument; this function never reads the Clock.
int eventXp({
  required EventType type,
  required bool allDay,
  required Duration duration,
}) {
  if (allDay) {
    return switch (type) {
      EventType.birthday ||
      EventType.nameDay ||
      EventType.publicHoliday ||
      EventType.notableDay ||
      EventType.date ||
      EventType.quest => 10,
      EventType.dance ||
      EventType.work ||
      EventType.meeting ||
      EventType.seminar ||
      EventType.lesson => 25,
    };
  }
  final int minutes = duration.inMinutes;
  if (minutes <= 30) return 10;
  if (minutes <= 120) return 25;
  if (minutes <= 300) return 50;
  return 100;
}
