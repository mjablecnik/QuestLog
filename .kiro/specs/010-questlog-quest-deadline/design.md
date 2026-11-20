# Design Document: Quest Deadline

## Overview

A Quest does not store the date. `quests.event_id` references a row of `calendar_events` (`ON DELETE SET NULL`), and the Deadline is that Event's end date, so editing the Event in the Calendar moves the Deadline with no sync code. The Quest_Service creates, moves and deletes the Linked_Event; the Calendar_Service remembers the linked Quest in its deletion snapshot so an undo can link it again.

**Key design decisions:**

- **The Event is the source of the date.** One value, no copy to keep equal.
- **`ON DELETE SET NULL`.** Deleting the Event from the Calendar leaves the Quest without a Deadline and touches nothing else.
- **Deadlines come from one stream.** `questDeadlinesProvider` joins `quests` and `calendar_events` into a map of Quest id to date; cards read from it, so the `Quest` model and the existing queries do not change.
- **No new Event type.** The Linked_Event is of the existing type Date and the user may change the type.
- **Overdue is derived.** End date before the calendar day of the Clock and the Quest not done.

## Project Structure

```
lib/data/tables.dart                      quests.event_id
lib/data/database.dart                    schema 6 (adds the column when it is missing)
lib/data/models.dart, mappers.dart        Quest.eventId, QuestDraft.deadline
lib/services/quest_service.dart           deadline handling, watchDeadlines
lib/services/calendar/calendar_service.dart   snapshot keeps the Quest id
lib/services/providers.dart               questDeadlinesProvider
lib/ui/sheets/quest_sheet.dart            Deadline field
lib/ui/widgets/cards/quest_card.dart      Deadline and Overdue
```

## Components and Interfaces

```dart
class QuestDraft { final DateTime? deadline; /* ... */ }
Stream<Map<int, DateTime>> QuestService.watchDeadlines();
bool isOverdue(DateTime deadline, DateTime today); // pure
```

## Data Models

`quests.event_id` integer, nullable, references `calendar_events(id)` with `ON DELETE SET NULL`.

## Correctness Properties

- A Quest's Deadline always equals the end date of its Linked_Event.
- Deleting a Linked_Event never changes a Quest other than clearing its link, and never changes Total_XP.
- `isOverdue` holds exactly when the Deadline is before today.

## Error Handling

A failed write rolls back, so a Quest and its Event are created, moved and deleted together.

## Testing Strategy

Service tests (create, move, clear, rename, delete Quest, delete Event, undo), a migration test from schema 5, widget tests of the Quest_Sheet and the Quest_Card, and a test that the Calendar shows the Event.
