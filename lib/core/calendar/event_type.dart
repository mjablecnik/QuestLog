/// The kind of a Calendar_Event. Each type has one fixed colour in the Design_Tokens.
enum EventType {
  dance('dance'),
  work('work'),
  birthday('birthday'),
  nameDay('nameDay'),
  publicHoliday('publicHoliday'),
  notableDay('notableDay'),
  date('date'),
  meeting('meeting'),
  seminar('seminar'),
  lesson('lesson');

  const EventType(this.key);

  /// The stored value.
  final String key;

  /// The type for a stored [key]; an unknown key reads as [meeting] so that a
  /// row from newer or damaged data is shown, not lost.
  static EventType fromKey(String key) {
    for (final EventType type in values) {
      if (type.key == key) return type;
    }
    return EventType.meeting;
  }

  /// Whether a new event of this type is put on the Board by default.
  bool get onBoardByDefault =>
      this != EventType.publicHoliday && this != EventType.notableDay;

  /// Whether the type is drawn as a Soft_Chip instead of a solid chip.
  bool get isSoft => this == EventType.notableDay;
}
