import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// DriftRemoteException is the only way the background isolate reports a failure.
// ignore: experimental_member_use
import 'package:drift/remote.dart' show DriftRemoteException;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/cadence.dart';
import '../core/errors.dart';
import '../core/xp_rules.dart';
import 'calendar/calendar_seed.dart';
import 'calendar/calendar_tables.dart';
import 'models.dart';
import 'notes/notes_tables.dart';
import 'preferences.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Missions,
    Quests,
    RecurringRules,
    RuleQuests,
    AppState,
    CalendarEvents,
    CalendarSkippedDates,
    CalendarCompletions,
    CalendarAddresses,
    NoteNodes,
  ],
)
class QuestlogDatabase extends _$QuestlogDatabase {
  /// Opens the on-device database file, lazily on first use.
  QuestlogDatabase() : super(_openFileDatabase());

  /// Uses the given [executor], for example `NativeDatabase.memory()` in tests.
  QuestlogDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  /// Runs [action] in a transaction (joining the active one, if any).
  ///
  /// A [DomainError] thrown by [action] rolls the transaction back and is
  /// rethrown as is; a SQLite failure is rolled back and rethrown as a
  /// [StorageError] (also when it comes back from the database isolate), so
  /// callers only ever see domain errors.
  Future<T> runTransaction<T>(Future<T> Function() action) async {
    try {
      return await transaction(action);
    } on DomainError {
      rethrow;
    } on SqliteException catch (error) {
      throw StorageError(error);
    } on DriftWrappedException catch (error) {
      throw StorageError(error);
    } on DriftRemoteException catch (error) {
      // The file database runs in a background isolate, which reports every
      // SQLite failure this way instead of as the SqliteException itself.
      throw StorageError(error.remoteCause);
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // The singleton row: Total_XP 0 and the default settings.
          await into(appState).insert(AppStateCompanion.insert());
          await seedCalendarDefaults(this);
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Board sections and a manual Mission order. Every Quest without a
            // Mission was on the Board, so it goes to Todo; Missions keep their
            // old oldest-first order.
            await m.addColumn(quests, quests.board);
            await m.addColumn(missions, missions.sortOrder);
            await customStatement("UPDATE quests SET board = 'todo' WHERE mission_id IS NULL");
            await customStatement('UPDATE missions SET sort_order = id');
          }
          if (from < 3) {
            // The calendar: events, skipped dates and completions, filled once with
            // the Czech holidays, notable days and name days. No existing table changes.
            await m.createTable(calendarEvents);
            await m.createTable(calendarSkippedDates);
            await m.createTable(calendarCompletions);
            await seedCalendarDefaults(this);
          }
          if (from < 4) {
            // Notes: one table for Folders and Notes. No existing table changes.
            await m.createTable(noteNodes);
          }
          if (from < 5) {
            // Address suggestions for the event form. No existing table changes.
            await m.createTable(calendarAddresses);
          }
          if (from < 6) {
            // A Quest's Deadline is a calendar event it points to. Added only when
            // missing, so a file that already has the column is left alone.
            final columns = await customSelect('PRAGMA table_info(quests)').get();
            if (!columns.any((row) => row.read<String>('name') == 'event_id')) {
              await m.addColumn(quests, quests.eventId);
            }
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

QueryExecutor _openFileDatabase() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'questlog.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
