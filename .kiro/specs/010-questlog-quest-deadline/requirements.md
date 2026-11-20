# Requirements Document

## Introduction

This spec gives a Quest of Questlog (Flutter, iOS primary, `/workspace/QuestLog/`) an optional date, a Deadline. A Quest with a Deadline also shows in the Calendar as an ordinary Event that the user can open, edit and delete like any other. A Quest that is still open after its Deadline is highlighted. Completing a Quest happens only on the Quest, never from its Event. The schema goes from version 5 to 6.

This replaces the earlier rule of the project that Quests have no due dates; the user asked for it.

## Glossary

Terms defined in `001-questlog-domain`, `002-questlog-ui` and `003-questlog-calendar` (Questlog_App, Quest, Quest_Card, Quest_Sheet, Board, Mission, Calendar_Service, Event, Event_Form, Calendar_Day) keep their meaning here. Additional terms:

- **Deadline**: The date a Quest is meant to be done by; the end date of its Linked_Event. A Quest without a Linked_Event has no Deadline.
- **Linked_Event**: The Event the Questlog_App creates for a Quest that has a Deadline. It is an all-day Event of type Quest, not on the Board, and the Quest keeps a reference to it.
- **Overdue**: An open Quest whose Deadline is before the current calendar day.

## Requirements

### Requirement 1: Setting a Deadline

**User Story:** As a user, I want to give a quest a date, so that I see when it has to be done.

#### Acceptance Criteria

1. THE Quest_Sheet SHALL offer an optional Deadline field that opens a date picker and can be cleared
2. WHEN a Quest is saved with a Deadline and has no Linked_Event, THE Questlog_App SHALL create a Linked_Event named like the Quest, all-day, of type Quest, starting and ending on the Deadline, not on the Board
3. WHEN a Quest with a Linked_Event is saved with another Deadline, THE Questlog_App SHALL move the Linked_Event to that date, keeping its length in days and its times
4. WHEN a Quest with a Linked_Event is saved without a Deadline, THE Questlog_App SHALL delete the Linked_Event
5. WHEN the name of a Quest with a Linked_Event is changed, THE Questlog_App SHALL give the Linked_Event the new name
6. WHILE a Quest is done, THE Quest_Sheet SHALL show its Deadline and SHALL NOT change it
7. THE Questlog_App SHALL allow a Deadline for a Quest in a Mission

### Requirement 4: The Quest Event Type

**User Story:** As a user, I want quest deadlines to look different in the calendar, so that I tell them from ordinary events.

#### Acceptance Criteria

1. THE Questlog_App SHALL have an Event type Quest with its own colour, different from the colour of every other Event type, named Quest in Czech and English
2. THE Calendar SHALL draw a Linked_Event in the colour of the type Quest, and THE type filter and the Event_Form SHALL list the type Quest
3. THE Event_Form SHALL NOT take the type Quest as the default type of a new Event because a Linked_Event was the last one saved
4. WHEN a Linked_Event is on the Board by the user's choice and completed there, THE Calendar_Service SHALL award 10 XP for the all-day type Quest

### Requirement 2: The Quest in the Calendar

**User Story:** As a user, I want the quest to show in the calendar, so that I see it among my events.

#### Acceptance Criteria

1. THE Calendar SHALL show the Linked_Event of a Quest as any other Event
2. WHEN the user edits the Linked_Event in the Event_Form (name, date, time, type, address, repeat), THE Calendar_Service SHALL save it as for any Event, and THE Deadline of the Quest SHALL be the end date of the Linked_Event
3. WHEN the Linked_Event is deleted, THE Calendar_Service SHALL delete only the Event, THE Quest SHALL stay and have no Deadline, and the Quest and its XP SHALL be unchanged
4. WHEN a deletion of the Linked_Event is undone, THE Calendar_Service SHALL give the Quest its Linked_Event back
5. THE Event_Form and the Event detail SHALL NOT complete the Quest
6. WHEN a Quest is deleted, THE Questlog_App SHALL delete its Linked_Event

### Requirement 3: Showing the Deadline

**User Story:** As a user, I want to see the deadline on the quest, so that I know how soon it is.

#### Acceptance Criteria

1. THE Quest_Card of an open Quest with a Deadline SHALL show the Deadline date
2. WHILE a Quest is Overdue, THE Quest_Card SHALL show the Deadline in the destructive colour with the text Po termínu (Overdue in English), so that the state does not rely on colour alone
3. WHILE a Quest is done, THE Quest_Card SHALL NOT show the Quest as Overdue
4. THE Quest_Card SHALL show the Deadline of a Quest in the Board and in the detail of a Mission
5. THE Quest_Card SHALL announce the Deadline, and Overdue, to a screen reader
