import 'errors.dart';

const int maxNameLength = 80;
const int maxNoteLength = 500;
const int maxHeroNameLength = 40;

/// Trims [raw] and returns it, or throws a [ValidationError] for [field] when it
/// is empty or longer than [maxLength] characters.
String validatedName(String raw, String field, {int maxLength = maxNameLength}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    throw ValidationError(field, 'must not be empty');
  }
  if (_length(trimmed) > maxLength) {
    throw ValidationError(field, 'must be at most $maxLength characters');
  }
  return trimmed;
}

/// Returns [raw] unchanged, or throws a [ValidationError] when it is longer than
/// [maxNoteLength] characters. A null note stays null.
String? validatedNote(String? raw, {String field = 'note'}) {
  if (raw != null && _length(raw) > maxNoteLength) {
    throw ValidationError(field, 'must be at most $maxNoteLength characters');
  }
  return raw;
}

/// Characters, not UTF-16 code units, so that it agrees with SQLite's `length()`.
int _length(String value) => value.runes.length;

/// Whether a Quest with [deadline] that is still open is Overdue on [today]
/// (both calendar dates).
bool isOverdue(DateTime deadline, DateTime today) =>
    DateTime(deadline.year, deadline.month, deadline.day).isBefore(DateTime(today.year, today.month, today.day));
