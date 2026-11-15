/// Source of the current local date and time.
///
/// All services read the time through this interface (never `DateTime.now()`),
/// so tests can control it.
abstract interface class Clock {
  /// Local wall-clock time.
  DateTime now();
}

/// [Clock] backed by the system clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
