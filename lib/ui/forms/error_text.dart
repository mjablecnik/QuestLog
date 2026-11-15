import '../../core/errors.dart';
import '../../l10n/app_localizations.dart';
import 'validators.dart';

/// Localized message for a client-side form error, shown beside the field.
String fieldErrorText(AppLocalizations l, FieldError e) {
  return switch (e) {
    FieldError.required => l.error_nameRequired,
    FieldError.tooLong => l.error_nameTooLong,
    FieldError.noteTooLong => l.error_noteTooLong,
    FieldError.heroNameTooLong => l.error_heroNameTooLong,
    FieldError.noQuestTemplate => l.error_noQuestTemplate,
    FieldError.missionNotOpen => l.error_missionNotOpen,
  };
}

/// Localized message for an error thrown by a service.
///
/// Never exposes exception text, entity names, ids or causes: those are for
/// logs only.
String domainErrorText(AppLocalizations l, DomainError e) {
  return switch (e) {
    ValidationError() => l.error_validation,
    NotFoundError() || InvalidStateError() => l.error_itemChanged,
    StorageError() => l.error_storage,
  };
}
