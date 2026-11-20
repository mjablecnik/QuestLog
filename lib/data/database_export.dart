import 'dart:convert';

import 'package:drift/drift.dart';

/// Identifies the file as a Questlog export, so an importer can refuse anything else.
const exportFormat = 'questlog-export';

/// Version of the JSON layout below. Raise it when the layout changes.
const exportFormatVersion = 1;

/// Reads every table of [db] into a JSON-encodable map.
///
/// The export is deliberately independent of the schema: it walks
/// `db.allTables` and copies each row as stored, so a table or column added by a
/// later migration is exported without touching this file. Values keep their
/// SQLite types (integers stay integers, so dates and booleans are stored
/// exactly as they are in the database); a BLOB is written as
/// `{"$blob": "<base64>"}`.
Future<Map<String, Object?>> exportDatabase(
  GeneratedDatabase db, {
  required String appName,
  required String appVersion,
  required DateTime exportedAt,
}) async {
  final tables = <String, Object?>{};
  final rowCounts = <String, int>{};
  for (final table in db.allTables) {
    final name = table.actualTableName;
    final rows = await db.customSelect('SELECT * FROM "$name"').get();
    tables[name] = <Map<String, Object?>>[
      for (final row in rows)
        <String, Object?>{
          for (final entry in row.data.entries)
            entry.key: _encodeValue(entry.value),
        },
    ];
    rowCounts[name] = rows.length;
  }
  return <String, Object?>{
    'format': exportFormat,
    'formatVersion': exportFormatVersion,
    'app': appName,
    'appVersion': appVersion,
    'schemaVersion': db.schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'rowCounts': rowCounts,
    'tables': tables,
  };
}

/// [exportDatabase] as pretty-printed JSON text.
Future<String> exportDatabaseAsJson(
  GeneratedDatabase db, {
  required String appName,
  required String appVersion,
  required DateTime exportedAt,
}) async {
  final data = await exportDatabase(
    db,
    appName: appName,
    appVersion: appVersion,
    exportedAt: exportedAt,
  );
  return const JsonEncoder.withIndent('  ').convert(data);
}

Object? _encodeValue(Object? value) {
  if (value is Uint8List) return <String, Object?>{r'$blob': base64Encode(value)};
  return value;
}
