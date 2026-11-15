import 'package:questlog/core/clock.dart';

/// A [Clock] whose time is set explicitly by the test.
class FixedClock implements Clock {
  FixedClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  /// Sets the current time.
  void set(DateTime value) => _now = value;

  /// Moves the current time forward (or backward with a negative duration).
  void advance(Duration by) => _now = _now.add(by);
}
