# Requirements Document

## Introduction

Questlog is a personal, gamified to-do application for a single user, built in Flutter (iOS primary) under `/workspace/questlog/`. Work is split into **Quests** (one-off tasks) and **Missions** (long-running goals composed of several quests). Completing quests and missions awards XP, and accumulated XP raises the hero's Level. Missions can also be generated automatically from **Recurring_Rules** (for example "cleaning, monthly, on the 1st").

This spec covers the domain layer only: the data model, local SQLite persistence, the business rules (XP, levels, mission completion, recurring posting, ordering, visibility windows) and the settings/profile store. It contains no screens; the UI is specified in `002-questlog-ui` and consumes the services defined here. The visual contract lives in `.design/DESIGN.md`.

All data is stored locally on the device. There is no server, no account and no network access. In v1 there are no due dates, no streaks and no history screen; finished work is nevertheless retained and queryable so that a history view can be added later without a data migration. A future optional "project" parent for missions and quests is deliberately not modelled yet.

## Glossary

- **Questlog_App**: The Flutter application at `/workspace/questlog/`.
- **Questlog_Database**: The local SQLite database (accessed through Drift) holding all persistent state.
- **Quest**: A one-off task with a name, a Difficulty, an optional note, an optional parent Mission and a done/open state.
- **Mission**: A long-running goal that groups Quests and carries a Mission_Bonus. A Mission has one of three states: `open`, `completed` or `closed`.
- **Instance**: A Mission created from a Recurring_Rule. It is an ordinary Mission that additionally references its rule.
- **Difficulty**: The XP tier of a Quest: Easy (10 XP), Normal (25 XP) or Hard (50 XP).
- **Mission_Bonus**: The extra XP granted when a Mission is completed: Small (50 XP), Medium (100 XP) or Large (200 XP).
- **Total_XP**: The lifetime XP counter, never reset by a Level change and never below zero.
- **Level**: The hero's level, derived from Total_XP. Level 1 is the starting level.
- **Level_Threshold**: The XP needed to advance from Level L to Level L+1, equal to `100 + 50 × (L − 1)`.
- **Level_Progress**: The XP earned inside the current Level (Total_XP minus the cumulative XP needed to reach the current Level) together with the current Level_Threshold.
- **Quest_Service**: The component that creates, edits, deletes, completes, reopens and reorders Quests.
- **Mission_Service**: The component that creates, edits, deletes and completes Missions.
- **Xp_Engine**: The component that computes Levels and Level_Progress and applies XP changes to Total_XP.
- **Recurring_Rule**: A template that periodically posts an Instance: name, Cadence, anchor date, Mission_Bonus and an ordered list of quest templates.
- **Cadence**: How often a Recurring_Rule repeats: Daily, Weekly, Biweekly, Monthly, Quarterly or Yearly.
- **Anchor_Date**: The calendar date of a Recurring_Rule's first Occurrence, from which every other Occurrence is computed.
- **Occurrence**: The calendar date on which a Recurring_Rule is due. Occurrence number `k` is the Anchor_Date advanced by `k` Cadence periods.
- **Next_Occurrence**: The Occurrence a Recurring_Rule will post next, identified by an index into its Occurrences.
- **Posting**: Creating an Instance of a Recurring_Rule, either automatically (Reconciliation) or manually ("post now").
- **Recurrence_Service**: The component that manages Recurring_Rules, performs Reconciliation and manual Posting.
- **Reconciliation**: The procedure that posts every Recurring_Rule whose Next_Occurrence is Today or earlier.
- **Settings_Service**: The component that stores and exposes the hero name, language, theme and display-font preferences.
- **Day_Start**: The local time at which a new Board_Day begins: 04:00.
- **Board_Day**: The current logical day. It starts at Day_Start, so between 00:00 and 04:00 local time the Board_Day is still the previous calendar date.
- **Today**: The calendar date of the current Board_Day.
- **History_Query**: A read-only query over completed Quests and completed Missions in a range of Board_Days, independent of the visibility windows.
- **Clock**: The injectable source of the current local date and time used by all services.

## Requirements

### Requirement 1: Quest Lifecycle

**User Story:** As a user, I want to create, edit and delete quests, so that I can keep my own to-do list.

#### Acceptance Criteria

1. WHEN a Quest is created with a name, a Difficulty and optionally a note and a Mission, THE Quest_Service SHALL store it as open with a creation timestamp taken from the Clock
2. IF a Quest name is empty after trimming whitespace or longer than 80 characters, THEN THE Quest_Service SHALL reject the operation with a validation error
3. IF a Quest note is longer than 500 characters, THEN THE Quest_Service SHALL reject the operation with a validation error
4. WHEN a Quest is created or edited with a Mission reference, THE Quest_Service SHALL verify that the Mission exists and is `open`
5. IF the referenced Mission does not exist or is not `open`, THEN THE Quest_Service SHALL reject the operation with an invalid-state error
6. WHEN an open Quest is edited, THE Quest_Service SHALL update its name, Difficulty, note and Mission
7. WHEN a done Quest is edited, THE Quest_Service SHALL update its name and note and SHALL leave its Difficulty and Mission unchanged
8. WHEN a Quest is deleted, THE Quest_Service SHALL remove it and SHALL leave Total_XP unchanged
9. WHEN a Quest is created without a Mission, THE Quest_Service SHALL store it as a standalone Quest

### Requirement 2: Quest Completion and XP

**User Story:** As a user, I want completing a quest to award XP, and un-completing it to take that XP back, so that an accidental tap is harmless.

#### Acceptance Criteria

1. WHEN an open Quest is completed, THE Quest_Service SHALL mark it done, record the completion timestamp from the Clock and record the XP awarded for its Difficulty
2. WHEN an open Quest is completed, THE Xp_Engine SHALL add the awarded XP to Total_XP in the same database transaction
3. WHEN a Quest is completed, THE Quest_Service SHALL return the awarded XP, the Level before and after, and the progress of the parent Mission when one exists
4. WHEN a Quest is completed and every Quest of its open Mission is then done, THE Quest_Service SHALL report that the Mission is ready to be completed
5. WHEN a done Quest is reopened, THE Quest_Service SHALL mark it open, clear its completion timestamp and subtract the XP recorded at completion from Total_XP in the same database transaction
6. WHEN a done Quest is reopened, THE Xp_Engine SHALL keep Total_XP at zero or above
7. WHEN a done Quest belonging to a `completed` Mission is reopened, THE Mission_Service SHALL reopen that Mission and subtract its recorded Mission_Bonus from Total_XP in the same database transaction
8. IF an open Quest is completed twice, THEN THE Quest_Service SHALL award its XP only once
9. WHEN a Quest is completed, THE Quest_Service SHALL award the XP of the Difficulty at completion time, independent of later Difficulty changes

### Requirement 3: Quest Ordering

**User Story:** As a user, I want to drag quests into my own order, so that the list reflects my priorities.

#### Acceptance Criteria

1. WHEN a Quest is created, THE Quest_Service SHALL place it after all existing Quests in the manual order
2. WHEN the user reorders a list of open Quests, THE Quest_Service SHALL persist the new relative order of exactly those Quests
3. WHEN a subset of Quests is reordered, THE Quest_Service SHALL leave the positions held by all other Quests unchanged
4. THE Quest_Service SHALL return Quests in manual order, so that the Board and each Mission show the same relative order of the Quests they have in common
5. IF a reorder request contains an unknown Quest identifier or a duplicate identifier, THEN THE Quest_Service SHALL reject it with a validation error and SHALL change nothing

### Requirement 4: Mission Lifecycle

**User Story:** As a user, I want to create, edit and delete missions together with their quests, so that I can track larger goals.

#### Acceptance Criteria

1. WHEN a Mission is created with a name, a Mission_Bonus and an optional list of quests, THE Mission_Service SHALL store the Mission as `open` and create its Quests in the given order in the same database transaction
2. IF a Mission name is empty after trimming whitespace or longer than 80 characters, THEN THE Mission_Service SHALL reject the operation with a validation error
3. WHEN a Mission is edited, THE Mission_Service SHALL update its name and Mission_Bonus
4. WHEN the Mission_Bonus of a `completed` Mission is edited, THE Mission_Service SHALL leave the recorded bonus unchanged
5. WHEN a Mission is deleted, THE Mission_Service SHALL delete all of its Quests in the same database transaction and SHALL leave Total_XP unchanged
6. WHEN a Quest is added to an `open` Mission, THE Mission_Service SHALL place it after the Mission's existing Quests
7. IF a Quest is added to a Mission that is not `open`, THEN THE Mission_Service SHALL reject the operation with an invalid-state error
8. THE Mission_Service SHALL return each `open` Mission with its done count, total count and the sum of XP of its remaining Quests

### Requirement 5: Mission Completion and Bonus

**User Story:** As a user, I want to finish a mission when all its quests are done and receive a bonus, so that long-term work is rewarded.

#### Acceptance Criteria

1. WHEN a Mission is completed and all of its Quests are done and it has at least one Quest, THE Mission_Service SHALL mark it `completed`, record the completion timestamp from the Clock and record its Mission_Bonus as awarded
2. WHEN a Mission is completed, THE Xp_Engine SHALL add the Mission_Bonus to Total_XP in the same database transaction
3. IF a Mission with at least one open Quest is completed, THEN THE Mission_Service SHALL reject the operation with an invalid-state error
4. IF a Mission with no Quests is completed, THEN THE Mission_Service SHALL reject the operation with an invalid-state error
5. IF a Mission that is not `open` is completed, THEN THE Mission_Service SHALL reject the operation with an invalid-state error
6. THE Mission_Service SHALL NOT complete a Mission automatically when its last Quest is completed
7. WHEN a Mission is completed, THE Mission_Service SHALL return the awarded bonus and the Level before and after

### Requirement 6: Levels and XP Progress

**User Story:** As a user, I want my level to rise as I earn XP, with a fresh progress bar for every level, so that progress feels continuous.

#### Acceptance Criteria

1. THE Xp_Engine SHALL define the Level_Threshold of Level L as `100 + 50 × (L − 1)` XP
2. THE Xp_Engine SHALL derive the Level from Total_XP, with Level 1 for Total_XP below 100
3. THE Xp_Engine SHALL return Level_Progress as the XP earned inside the current Level and the current Level_Threshold
4. THE Xp_Engine SHALL NOT impose an upper limit on the Level
5. WHEN Total_XP changes, THE Xp_Engine SHALL return the Level before and after the change
6. WHEN Total_XP decreases across a Level boundary, THE Xp_Engine SHALL return the lower Level
7. THE Xp_Engine SHALL expose Total_XP separately from Level_Progress

### Requirement 7: Visibility Windows

**User Story:** As a user, I want finished items to stay visible until the next day starts at 4:00 and then disappear, so that the board stays tidy without a history to maintain.

#### Acceptance Criteria

1. THE Quest_Service SHALL return as open board Quests all open Quests that are standalone or belong to an `open` Mission
2. THE Quest_Service SHALL return as done board Quests all Quests whose completion timestamp falls within the current Board_Day, that is at or after the most recent Day_Start
3. WHEN the Board_Day changes, THE Quest_Service SHALL stop returning Quests completed on earlier days as done board Quests
4. THE Mission_Service SHALL return as completed Missions only those whose completion timestamp falls within the current Board_Day, each with its awarded Mission_Bonus
5. THE Mission_Service SHALL return each `open` Mission together with all of its Quests, including Quests completed on earlier days
6. THE Mission_Service SHALL NOT return `closed` Missions or the Quests of `closed` Missions
7. THE Board_Day boundary SHALL be computed from the local date and time supplied by the Clock as the most recent local 04:00, not from a fixed 24-hour offset
8. THE Recurrence_Service SHALL use Today, not the calendar date, wherever a Recurring_Rule is compared with the current date
9. THE Quest_Service SHALL return with every board Quest the name of its Mission, or no name when the Quest is standalone
10. THE Quest_Service and Mission_Service SHALL evaluate the done and completed windows for the Today supplied by the caller, so that a consumer can refresh them when the Board_Day changes

### Requirement 8: Recurring Rule Definition

**User Story:** As a user, I want to define rules such as "cleaning every month on the 1st", so that routine missions appear on their own.

#### Acceptance Criteria

1. WHEN a Recurring_Rule is created, THE Recurrence_Service SHALL store its name, Cadence, Anchor_Date, Mission_Bonus and ordered quest templates, each with a name and a Difficulty
2. IF a Recurring_Rule has an empty name, a name longer than 80 characters or no quest template, THEN THE Recurrence_Service SHALL reject the operation with a validation error
3. THE Recurrence_Service SHALL define Occurrence number `k` as the Anchor_Date advanced by `k` days for Daily, `7k` days for Weekly, `14k` days for Biweekly, `k` months for Monthly, `3k` months for Quarterly and `k` years for Yearly
4. WHEN an Occurrence falls in a month shorter than the day of the Anchor_Date, THE Recurrence_Service SHALL use the last day of that month
5. THE Recurrence_Service SHALL compute each Occurrence from the Anchor_Date and the index `k`, not from the previous Occurrence
6. IF a Monthly Recurring_Rule has a posting day outside 1–28, THEN THE Recurrence_Service SHALL reject the operation with a validation error
7. WHEN a Recurring_Rule is created or its Cadence or posting day is changed, THE Recurrence_Service SHALL set the Anchor_Date to the first Occurrence that is on or after Today and strictly after the date of the rule's last Posting
8. WHEN a Recurring_Rule is created or its Anchor_Date is reset, THE Recurrence_Service SHALL set its Next_Occurrence to index 0

### Requirement 9: Automatic Posting

**User Story:** As a user, I want due recurring missions to appear on the board by themselves, so that I do not have to remember them.

#### Acceptance Criteria

1. WHEN Reconciliation runs and the Next_Occurrence date of a Recurring_Rule is Today or earlier, THE Recurrence_Service SHALL post exactly one Instance of that rule
2. WHEN several Occurrences of one Recurring_Rule are overdue, THE Recurrence_Service SHALL post only one Instance
3. WHEN a Recurring_Rule has been posted by Reconciliation, THE Recurrence_Service SHALL advance its Next_Occurrence to the first Occurrence dated after Today
4. WHEN an Instance is posted, THE Recurrence_Service SHALL create an `open` Mission named after the rule with the rule's Mission_Bonus and one new Quest per quest template in template order
5. WHEN an Instance is posted and the rule has an earlier `open` Instance, THE Recurrence_Service SHALL set the earlier Instance to `closed`, delete its open Quests and award no Mission_Bonus
6. WHEN an earlier Instance is closed, THE Recurrence_Service SHALL keep the XP already awarded for its done Quests
7. WHEN Reconciliation runs twice on the same Board_Day, THE Recurrence_Service SHALL post no additional Instance on the second run
8. THE Recurrence_Service SHALL perform Reconciliation only when invoked and SHALL NOT depend on background execution
9. THE Recurrence_Service SHALL post every due Recurring_Rule in one database transaction

### Requirement 10: Manual Posting

**User Story:** As a user, I want to post a recurring mission by hand, and have the next automatic posting skipped, so that I never get the same mission twice.

#### Acceptance Criteria

1. WHEN a Recurring_Rule is posted manually, THE Recurrence_Service SHALL create an Instance in the same way as an automatic Posting
2. WHEN a Recurring_Rule is posted manually and its Next_Occurrence date is after Today, THE Recurrence_Service SHALL advance the Next_Occurrence by one index
3. WHEN a Recurring_Rule is posted manually and its Next_Occurrence date is Today or earlier, THE Recurrence_Service SHALL advance the Next_Occurrence to the first Occurrence dated after Today
4. WHEN a Recurring_Rule is posted manually, THE Recurrence_Service SHALL close any earlier `open` Instance in the same way as an automatic Posting
5. THE Recurrence_Service SHALL decide whether to skip the nearest automatic Posting independent of whether the manually posted Instance is untouched, partly done or fully done
6. WHEN Reconciliation runs on the original Occurrence date of a skipped Posting, THE Recurrence_Service SHALL post no Instance for that rule
7. WHEN a Recurring_Rule is posted manually, THE Recurrence_Service SHALL report whether the nearest automatic Posting was skipped and whether an earlier `open` Instance was closed

### Requirement 11: Recurring Rule Editing and Deletion

**User Story:** As a user, I want to edit and remove recurring rules, so that I can adjust routines over time.

#### Acceptance Criteria

1. WHEN a Recurring_Rule is edited, THE Recurrence_Service SHALL apply the changes only to future Instances
2. WHEN a Recurring_Rule is deleted, THE Recurrence_Service SHALL keep its existing `open` Instance as an ordinary Mission with no rule reference
3. WHEN a Recurring_Rule is deleted, THE Recurrence_Service SHALL post no further Instances for it
4. THE Recurrence_Service SHALL return each Recurring_Rule with its Next_Occurrence date and whether an `open` Instance of it exists
5. THE Recurrence_Service SHALL return each Recurring_Rule with its Cadence, Anchor_Date, Mission_Bonus and ordered quest templates, so that a consumer can show and edit the rule without a second query

### Requirement 12: Settings and Profile

**User Story:** As a user, I want to set my name, language, theme and display font, so that the app feels like mine.

#### Acceptance Criteria

1. THE Settings_Service SHALL store the hero name, language, theme mode and display font in the Questlog_Database
2. THE Settings_Service SHALL offer the language values `system`, `cs` and `en`, with `system` as the default
3. WHEN the language is `system` and the device language is neither Czech nor English, THE Settings_Service SHALL resolve the effective language to English
4. THE Settings_Service SHALL offer the theme values `light`, `dark` and `system`, with `system` as the default
5. THE Settings_Service SHALL offer the display fonts Figtree, Bricolage Grotesque, Sora, Outfit, Unbounded and Cinzel, with Figtree as the default
6. IF the hero name is longer than 40 characters after trimming whitespace, THEN THE Settings_Service SHALL reject the operation with a validation error
7. WHEN the hero name is empty, THE Settings_Service SHALL report no name and THE Questlog_App SHALL display only the Level
8. WHEN a setting changes, THE Settings_Service SHALL emit the new value to all observers

### Requirement 13: Persistence and Consistency

**User Story:** As a user, I want my data to survive restarts and never end up half-written, so that I can trust the app.

#### Acceptance Criteria

1. THE Questlog_Database SHALL persist all Quests, Missions, Recurring_Rules, Settings and Total_XP on the device
2. WHEN an operation changes more than one row, THE Questlog_Database SHALL apply the changes in a single transaction
3. IF a transaction fails, THEN THE Questlog_Database SHALL leave all data as it was before the operation
4. WHEN the Questlog_App starts after a schema update, THE Questlog_Database SHALL migrate existing data to the new schema without data loss
5. WHEN the Questlog_Database is first created, THE Questlog_Database SHALL initialise Total_XP to zero and the settings to their defaults
6. THE Questlog_Database SHALL expose observable queries so that dependent views update when the data changes
7. THE Questlog_App SHALL read the current time only through the Clock, so that tests can control time

### Requirement 14: Project Scaffolding and Checks

**User Story:** As a developer, I want a standards-conforming Flutter project with automated checks, so that structure and quality hold from the first commit.

#### Acceptance Criteria

1. THE Questlog_App SHALL keep source files in `lib/` organised into `core/`, `data/` and `services/` subdirectories, with the entry point `lib/main.dart` in the root of `lib/`
2. THE Questlog_App SHALL provide `scripts/check.sh` that runs static analysis, all tests and `scripts/check-structure.sh`
3. IF any directory contains more than 15 source files, THEN `scripts/check-structure.sh` SHALL fail the check
4. THE Questlog_App SHALL provide `.env.example` and list `.env` files in `.gitignore`
5. THE Questlog_App SHALL commit the dependency lockfile `pubspec.lock`
6. THE Questlog_App SHALL keep the application version in `pubspec.yaml` only

### Requirement 15: Completed-Work History

**User Story:** As a user, I want finished work to be kept after it disappears from the board, so that a history view can be added later.

#### Acceptance Criteria

1. THE Questlog_Database SHALL retain every done Quest and every `completed` Mission after it leaves its visibility window
2. WHEN a Mission is set to `closed`, THE Recurrence_Service SHALL retain its done Quests
3. WHEN the user deletes a Quest or a Mission, THE Questlog_Database SHALL remove it permanently, together with the done Quests of a deleted Mission
4. THE Quest_Service SHALL provide a History_Query that returns done Quests whose completion timestamp falls within a given range of Board_Days, newest first, each with its name, Difficulty, awarded XP, completion timestamp and Mission name when it has one
5. THE Mission_Service SHALL provide a History_Query that returns `completed` Missions whose completion timestamp falls within a given range of Board_Days, newest first, each with its name and awarded Mission_Bonus
6. THE History_Query SHALL NOT modify any data, including Total_XP
7. WHEN a done Quest is reopened, THE History_Query SHALL no longer return it
