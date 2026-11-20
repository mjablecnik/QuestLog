# Design Document: Address History

## Overview

A table `calendar_addresses` (address, last_used_at) holds the Address_History. `CalendarService` writes it inside the transaction of `create` and `update`, and reads it for the form. Nothing is looked up on a network. The form shows the matches in a column under the Address field.

**Key design decisions:**

- **A table, not a file.** The history is user data, so it lives in the database; the schema goes to version 5 with `createTable` only, no existing table changes.
- **Case-insensitive key.** The primary key is the lower-cased address (`key`), the spelling saved last is kept in `address`.
- **Expiry on read and at start.** Suggestions filter by the cutoff, so a stale entry never shows; the purge at start only keeps the table small.
- **Events are independent.** Deleting an Event does not touch the history and forgetting an address does not touch an Event.

## Project Structure

```
lib/data/calendar/calendar_tables.dart            CalendarAddresses table
lib/core/calendar/address_history.dart            NEW: addressRetention, matchesAddress (pure)
lib/services/calendar/calendar_service.dart       remember in create/update, suggestAddresses, purgeExpiredAddresses
lib/ui/widgets/calendar/calendar_fields.dart      CalendarTextField.onFocusChange
lib/ui/widgets/calendar/address_suggestions.dart  NEW: the suggestion rows
lib/ui/screens/calendar/event_form_screen.dart    shows them under the Address field
lib/ui/screens/shell/app_shell.dart               purge at start
drift_schemas/drift_schema_v5.json
```

## Components and Interfaces

```dart
const Duration addressRetention = Duration(days: 30);

/// Calls on the Calendar_Service
Future<List<String>> suggestAddresses(String typed, {int limit = 5});
Future<void> purgeExpiredAddresses();
```

## Data Models

`calendar_addresses`: `key` text primary key (`searchKey` of the address is not used, plain lower case), `address` text (1 to 120 characters), `last_used_at` datetime.

## Correctness Properties

- A saved address is returned by `suggestAddresses('')` until `addressRetention` after its last use, and not after.
- Saving the same address in any letter case leaves one entry.
- `suggestAddresses` never returns more than `limit` entries, never an entry equal to the typed text, and returns them newest first.

## Error Handling

A failure of the purge at start is ignored; the next start tries again. A failure while reading suggestions shows no suggestions.

## Testing Strategy

Service tests with a fake clock for the 30-day edge, the migration from schema 4, widget tests of the form (focus, typing, tap, empty), and a property test of the three properties above.
