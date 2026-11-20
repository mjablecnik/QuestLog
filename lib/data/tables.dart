// The CHECK constraints reference their own column getter, which is the
// documented Drift pattern, so the recursive_getters lint does not apply here.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../core/cadence.dart';
import '../core/xp_rules.dart';
import 'calendar/calendar_tables.dart';
import 'models.dart';
import 'preferences.dart';

/// Stores a calendar date as `YYYY-MM-DD` text so it never shifts with the
/// time zone.
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) {
    final parts = fromDb.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  @override
  String toSql(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}';
  }
}

@DataClassName('MissionRow')
class Missions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().check(name.trim().length.isBetweenValues(1, 80))();
  TextColumn get bonus => textEnum<MissionBonus>()();
  TextColumn get status => textEnum<MissionStatus>().withDefault(const Constant('open'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get awardedBonus => integer().nullable()();
  IntColumn get ruleId =>
      integer().nullable().references(RecurringRules, #id, onDelete: KeyAction.setNull)();
}

@DataClassName('QuestRow')
@TableIndex(name: 'idx_quests_mission', columns: {#missionId})
@TableIndex(name: 'idx_quests_completed', columns: {#completedAt})
class Quests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().check(name.trim().length.isBetweenValues(1, 80))();
  TextColumn get note => text().nullable().check(note.length.isSmallerOrEqualValue(500))();
  TextColumn get difficulty => textEnum<Difficulty>()();
  IntColumn get missionId =>
      integer().nullable().references(Missions, #id, onDelete: KeyAction.cascade)();
  /// Null: not on the Board. Quests without a Mission are always on it.
  TextColumn get board => textEnum<BoardSection>().nullable()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get awardedXp => integer().nullable()();

  /// The calendar event of the Quest's Deadline. Deleting the event only clears
  /// this link; the Quest stays.
  IntColumn get eventId =>
      integer().nullable().references(CalendarEvents, #id, onDelete: KeyAction.setNull)();
}

@DataClassName('RecurringRuleRow')
class RecurringRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().check(name.trim().length.isBetweenValues(1, 80))();
  TextColumn get cadence => textEnum<Cadence>()();
  TextColumn get anchorDate => text().map(const DateOnlyConverter())();
  IntColumn get nextIndex => integer().withDefault(const Constant(0))();
  TextColumn get bonus => textEnum<MissionBonus>()();
  TextColumn get lastPostedOn => text().map(const DateOnlyConverter()).nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('RuleQuestRow')
class RuleQuests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get ruleId =>
      integer().references(RecurringRules, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get difficulty => textEnum<Difficulty>()();
  IntColumn get sortOrder => integer()();
}

/// Singleton row (id = 1): Total_XP and the settings.
@DataClassName('AppStateRow')
class AppState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1)).check(id.equals(1))();
  IntColumn get totalXp =>
      integer().withDefault(const Constant(0)).check(totalXp.isBiggerOrEqualValue(0))();
  TextColumn get heroName => text().withDefault(const Constant(''))();
  TextColumn get language => textEnum<AppLanguage>().withDefault(const Constant('system'))();
  TextColumn get theme => textEnum<AppTheme>().withDefault(const Constant('system'))();
  // Unused since the title font was fixed to Figtree; the column stays so that no migration is needed.
  TextColumn get displayFont => text().withDefault(const Constant('figtree'))();

  @override
  Set<Column> get primaryKey => {id};
}
