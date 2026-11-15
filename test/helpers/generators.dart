import 'package:glados/glados.dart';

/// Local wall-clock instants between 2000 and 2040, minute resolution, so that
/// property tests also cross daylight-saving changes when run in a zone that
/// has them (for example `TZ=Europe/Prague`).
Generator<DateTime> get anyLocalInstant =>
    any.intInRange(0, 60 * 24 * 365 * 40).map(
      (minutes) => DateTime(2000, 1, 1, 0, minutes),
    );

/// Calendar dates (time stripped) between 2000 and 2040.
Generator<DateTime> get anyCalendarDate =>
    any.intInRange(0, 365 * 40).map((days) => DateTime(2000, 1, 1 + days));
