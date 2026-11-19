/// Easter Sunday of [year] by the Gregorian computus (Meeus/Jones/Butcher), as
/// a date without a time part.
DateTime easterSunday(int year) {
  final int a = year % 19;
  final int b = year ~/ 100;
  final int c = year % 100;
  final int d = b ~/ 4;
  final int e = b % 4;
  final int f = (b + 8) ~/ 25;
  final int g = (b - f + 1) ~/ 3;
  final int h = (19 * a + b - d - g + 15) % 30;
  final int i = c ~/ 4;
  final int k = c % 4;
  final int l = (32 + 2 * e + 2 * i - h - k) % 7;
  final int m = (a + 11 * h + 22 * l) ~/ 451;
  final int month = (h + l - 7 * m + 114) ~/ 31;
  final int day = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime(year, month, day);
}

/// The [ordinal]-th [weekday] (`DateTime.monday` .. `DateTime.sunday`) of
/// [month] in [year], counted from the first day of the month.
///
/// Throws an [ArgumentError] when the month has no such day (a fifth weekday
/// that does not exist) or the arguments are out of range.
DateTime nthWeekdayOfMonth(int year, int month, int weekday, int ordinal) {
  if (month < 1 || month > 12) throw ArgumentError.value(month, 'month');
  if (weekday < DateTime.monday || weekday > DateTime.sunday) {
    throw ArgumentError.value(weekday, 'weekday');
  }
  if (ordinal < 1 || ordinal > 5) throw ArgumentError.value(ordinal, 'ordinal');
  final int first = DateTime(year, month, 1).weekday;
  final int day = 1 + (weekday - first) % 7 + (ordinal - 1) * 7;
  if (day > DateTime(year, month + 1, 0).day) {
    throw ArgumentError.value(ordinal, 'ordinal', 'no such day in the month');
  }
  return DateTime(year, month, day);
}
