import 'package:drift/drift.dart';

import '../database.dart';
import 'calendar_mappers.dart';
import 'calendar_models.dart';
import 'calendar_seed_data.dart';

/// The `created_at` and `updated_at` of a seeded event: the epoch, so that a
/// built-in event is told apart from one the user saved and never counts as the
/// "last used type".
final DateTime seedTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

/// Inserts the 13 public holidays, 16 notable and folk days and 6 name days.
///
/// Called by `onCreate` and by the schema 2 to 3 step and nowhere else, so
/// every holiday is inserted once and a deleted one stays deleted.
Future<void> seedCalendarDefaults(QuestlogDatabase db) async {
  await db.batch((Batch batch) {
    batch.insertAll(db.calendarEvents, <CalendarEventsCompanion>[
      for (final SeedEvent e in calendarSeedEvents)
        eventCompanion(
          EventDraft(
            name: e.name,
            type: e.type,
            startDate: e.start,
            endDate: e.start,
            repeat: e.repeat,
            onBoard: e.onBoard,
          ),
          createdAt: seedTimestamp,
          updatedAt: seedTimestamp,
        ),
    ]);
  });
}
