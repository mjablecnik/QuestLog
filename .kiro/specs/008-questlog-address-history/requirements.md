# Requirements Document

## Introduction

This spec adds suggestions to the Address field of the Event_Form of Questlog (Flutter, iOS primary, `/workspace/QuestLog/`). The app has no network access, so the suggestions are not looked up in a map service: they are the addresses the user has already saved on events. An address that has not been used for 30 days is forgotten. The schema goes from version 4 to 5 with one new table.

## Glossary

Terms defined in `003-questlog-calendar` (Questlog_App, Calendar_Service, Event_Form, Event) keep their meaning here. Additional terms:

- **Address_History**: The addresses the user has saved on Events, each with the time it was last used.
- **Address_Suggestion**: An entry of the Address_History shown under the Address field of the Event_Form.
- **Address_Retention**: 30 days; an address whose last use is older is forgotten.

## Requirements

### Requirement 1: Remembering Addresses

**User Story:** As a user, I want the app to remember the addresses I type, so that I do not type the same place again.

#### Acceptance Criteria

1. WHEN an Event with a non-blank address is created or edited, THE Calendar_Service SHALL store the trimmed address in the Address_History with the current time as its last use
2. WHEN an address that is already in the Address_History is saved again, THE Calendar_Service SHALL update its last use and SHALL NOT add a second entry
3. THE Calendar_Service SHALL treat two addresses that differ only in letter case as the same address and keep the spelling saved last
4. WHEN an Event is deleted, THE Calendar_Service SHALL keep its address in the Address_History

### Requirement 2: Forgetting Addresses

**User Story:** As a user, I want addresses I no longer use to disappear, so that the list stays short and relevant.

#### Acceptance Criteria

1. WHEN the Questlog_App starts, THE Calendar_Service SHALL delete the addresses whose last use is older than the Address_Retention
2. WHEN Address_Suggestions are requested, THE Calendar_Service SHALL NOT return an address whose last use is older than the Address_Retention
3. THE Calendar_Service SHALL NOT delete an Event or change its address because the address left the Address_History

### Requirement 3: Suggestions in the Event_Form

**User Story:** As a user, I want to pick an earlier address from a list under the field, so that I fill it with one tap.

#### Acceptance Criteria

1. WHILE the Address field has focus, THE Event_Form SHALL show up to 5 Address_Suggestions under it, the most recently used first
2. WHEN the user types in the Address field, THE Event_Form SHALL show only the Address_Suggestions that contain the typed text, ignoring case and diacritics
3. THE Event_Form SHALL NOT show an Address_Suggestion that equals the typed text
4. WHEN an Address_Suggestion is tapped, THE Event_Form SHALL put its text in the Address field and hide the Address_Suggestions
5. WHILE there is no Address_Suggestion, THE Event_Form SHALL show nothing under the Address field
6. THE Event_Form SHALL give each Address_Suggestion a touch target of at least 44 points and a label for a screen reader
