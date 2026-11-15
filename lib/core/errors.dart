/// Base type of every error the domain layer throws on purpose.
///
/// Messages are for logs only; user-facing text is localized in the UI layer.
sealed class DomainError implements Exception {
  const DomainError();

  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Input rejected before any write (empty or over-long name, bad reorder list...).
final class ValidationError extends DomainError {
  const ValidationError(this.field, this.detail);

  /// The offending field, so the UI can show an inline message.
  final String field;
  final String detail;

  @override
  String get message => 'invalid $field: $detail';
}

/// The referenced Quest, Mission or rule does not exist (any more).
final class NotFoundError extends DomainError {
  const NotFoundError(this.entity, this.id);

  final String entity;
  final int id;

  @override
  String get message => '$entity $id not found';
}

/// The operation is not allowed in the current state of the data.
final class InvalidStateError extends DomainError {
  const InvalidStateError(this.reason);

  final String reason;

  @override
  String get message => reason;
}

/// A database error; the transaction was rolled back and all data is unchanged.
final class StorageError extends DomainError {
  const StorageError(this.cause);

  final Object cause;

  @override
  String get message => 'storage failure: $cause';
}
