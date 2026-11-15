import '../../core/validation.dart';

/// Why a form field was rejected; `error_text.dart` turns it into localized text.
enum FieldError {
  required,
  tooLong,
  noteTooLong,
  heroNameTooLong,
  noQuestTemplate,
  missionNotOpen,
}

/// A name must have 1–[maxNameLength] characters after trimming.
FieldError? validateName(String raw) {
  final length = _trimmedLength(raw);
  if (length == 0) return FieldError.required;
  if (length > maxNameLength) return FieldError.tooLong;
  return null;
}

/// A note may be empty and has at most [maxNoteLength] characters (not trimmed).
FieldError? validateNote(String raw) {
  return _length(raw) > maxNoteLength ? FieldError.noteTooLong : null;
}

/// The hero name may be empty and has at most [maxHeroNameLength] characters
/// after trimming.
FieldError? validateHeroName(String raw) {
  return _trimmedLength(raw) > maxHeroNameLength
      ? FieldError.heroNameTooLong
      : null;
}

/// A quest row in the Mission or Rule sheet: an empty row is ignored on submit,
/// so only an over-long name is an error.
FieldError? validateQuestRowName(String raw) {
  return _trimmedLength(raw) > maxNameLength ? FieldError.tooLong : null;
}

/// Quest template names of a rule. Empty rows are ignored; the first error found
/// wins: an over-long name (in list order), otherwise no non-empty name at all.
FieldError? validateRuleQuests(List<String> names) {
  var anyNamed = false;
  for (final name in names) {
    final length = _trimmedLength(name);
    if (length > maxNameLength) return FieldError.tooLong;
    if (length > 0) anyNamed = true;
  }
  return anyNamed ? null : FieldError.noQuestTemplate;
}

int _length(String value) => value.runes.length;

int _trimmedLength(String value) => _length(value.trim());
