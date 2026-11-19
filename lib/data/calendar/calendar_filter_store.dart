import 'dart:io';

import '../../core/calendar/event_type.dart';

/// Keeps the Type_Filter between launches. Outside the database on purpose, so
/// that a view preference needs no schema migration.
abstract interface class CalendarFilterStore {
  /// The shown types; all ten when nothing is stored or it cannot be read.
  Future<Set<EventType>> load();

  Future<void> save(Set<EventType> shown);
}

/// Stores the shown [EventType.key] values, comma separated, in a small file.
class FileCalendarFilterStore implements CalendarFilterStore {
  const FileCalendarFilterStore(this._file);

  final File _file;

  @override
  Future<Set<EventType>> load() async {
    final Set<EventType> all = EventType.values.toSet();
    try {
      final String raw = (await _file.readAsString()).trim();
      if (raw == '-') return <EventType>{};
      if (raw.isEmpty) return all;
      final Set<EventType> shown = <EventType>{};
      for (final String key in raw.split(',')) {
        for (final EventType type in EventType.values) {
          if (type.key == key.trim()) shown.add(type);
        }
      }
      return shown.isEmpty ? all : shown;
    } on FileSystemException {
      return all;
    } on FormatException {
      return all;
    }
  }

  @override
  Future<void> save(Set<EventType> shown) async {
    try {
      // "-" marks "no type shown", so an empty file still means "all".
      await _file.writeAsString(
        shown.isEmpty ? '-' : shown.map((EventType t) => t.key).join(','),
        flush: true,
      );
    } on FileSystemException {
      // A view preference: failing to remember it is not worth a dialog.
    }
  }
}

/// Keeps the filter in memory only; the default in tests.
class MemoryCalendarFilterStore implements CalendarFilterStore {
  MemoryCalendarFilterStore([Set<EventType>? value]) : value = value ?? EventType.values.toSet();

  Set<EventType> value;

  @override
  Future<Set<EventType>> load() async => Set<EventType>.of(value);

  @override
  Future<void> save(Set<EventType> shown) async => value = Set<EventType>.of(shown);
}
