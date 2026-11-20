// The CHECK constraints reference their own column getter, which is the
// documented Drift pattern, so the recursive_getters lint does not apply here.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../tables.dart';

/// A calendar event, or the first of a series. A start and an end are a
/// calendar date plus minutes since midnight with no time zone; an all-day
/// event has no minutes. Seeded built-in events have `created_at = 0`.
@DataClassName('CalendarEventRow')
@TableIndex(name: 'idx_calendar_events_start', columns: {#startDate})
class CalendarEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().check(name.trim().length.isBetweenValues(1, 80))();
  TextColumn get note => text().nullable().check(note.length.isSmallerOrEqualValue(500))();
  TextColumn get location =>
      text().nullable().check(location.length.isSmallerOrEqualValue(120))();

  /// An `EventType.key`; no CHECK, so an unknown value from newer data is kept.
  TextColumn get eventType => text()();
  TextColumn get startDate => text().map(const DateOnlyConverter())();
  TextColumn get endDate => text().map(const DateOnlyConverter())();
  IntColumn get startMinute =>
      integer().nullable().check(startMinute.isBetweenValues(0, 1439))();
  IntColumn get endMinute => integer().nullable().check(endMinute.isBetweenValues(0, 1439))();

  /// none | daily | weekly | monthly | yearly | easter | nthWeekday
  TextColumn get repeatKind => text().withDefault(const Constant('none'))();
  IntColumn get easterOffset => integer().nullable()();
  IntColumn get nthMonth => integer().nullable()();
  IntColumn get nthWeekday => integer().nullable()();
  IntColumn get nthOrdinal => integer().nullable()();
  TextColumn get repeatEnd => text().map(const DateOnlyConverter()).nullable()();
  BoolColumn get onBoard => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// A start date on which a repeating event is deliberately not shown.
@DataClassName('CalendarSkippedDateRow')
class CalendarSkippedDates extends Table {
  IntColumn get eventId =>
      integer().references(CalendarEvents, #id, onDelete: KeyAction.cascade)();
  TextColumn get skippedOn => text().map(const DateOnlyConverter())();

  @override
  Set<Column> get primaryKey => {eventId, skippedOn};
}

/// The record that one occurrence was completed, with the XP it awarded.
@DataClassName('CalendarCompletionRow')
class CalendarCompletions extends Table {
  IntColumn get eventId =>
      integer().references(CalendarEvents, #id, onDelete: KeyAction.cascade)();
  TextColumn get occurrenceDate => text().map(const DateOnlyConverter())();
  DateTimeColumn get completedAt => dateTime()();
  IntColumn get awardedXp => integer()();

  @override
  Set<Column> get primaryKey => {eventId, occurrenceDate};
}

/// An address the user saved on an event, kept for suggestions until it has not
/// been used for 30 days. The key is the lower-cased address, so spellings that
/// differ only in letter case are one entry; [address] keeps the last spelling.
@DataClassName('CalendarAddressRow')
class CalendarAddresses extends Table {
  TextColumn get key => text()();
  TextColumn get address => text().check(address.length.isBetweenValues(1, 120))();
  DateTimeColumn get lastUsedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
