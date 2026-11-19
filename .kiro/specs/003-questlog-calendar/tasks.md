# Implementation Plan: Questlog Calendar

## Overview

Add the Kalendář tab to Questlog: the month overview, day sheet, event detail, event form, deletion with undo, search and type filter, plus the Event_Tasks on the Board that award XP. The pure logic (event types, repeat expansion, Easter, n-th weekday, Event_XP) goes first in `lib/core/calendar/`, then the schema v3 tables with the one-time seed of holidays, notable days and name days in `lib/data/calendar/`, then `CalendarService` and providers in `lib/services/calendar/`, then the screens, sheets and widgets in `lib/ui/`. Tests are interleaved with the code they check: unit and property tests (`glados`) for the core, service and migration tests on an in-memory database, widget and golden tests for the UI, and one end-to-end scenario. The gate is `scripts/check.sh`.

## Tasks

- [ ] 1. Pure calendar logic (`lib/core/calendar/`)
  - [ ] 1.1 Add `event_type.dart`
    - Create the `EventType` enum with the ten values `dance, work, birthday, nameDay, publicHoliday, notableDay, date, meeting, seminar, lesson`, the stored `key`, `fromKey` (unknown value falls back to `meeting`), `onBoardByDefault` (false for `publicHoliday` and `notableDay`) and `isSoft` (true for `notableDay`)
    - _Requirements: 4.1, 8.8, 8.13, 12.5_

  - [ ] 1.2 Add `easter.dart`
    - `easterSunday(int year)` by the Gregorian computus, returning a date-only `DateTime`
    - `nthWeekdayOfMonth(int year, int month, int weekday, int ordinal)` returning the date of the n-th given weekday of the month
    - _Requirements: 9.11, 9.15, 14.5, 14.16_

  - [ ] 1.3 Write tests for Easter and the n-th weekday
    - **Property 4: Easter-relative days are consistent with Easter Sunday** — for every year 2000 to 2100 Easter Sunday is a Sunday between 22 March and 25 April, Velký pátek is two days before it and Velikonoční pondělí one day after; a fixed table of known Easter dates (including 5 April 2026) matches
    - **Property 5: The n-th weekday is the right weekday of the right month** — for any year, month, weekday and ordinal 1 to 4 the result is in that month, has that weekday and its day of month is in the range of the ordinal; second Sunday of May 2026 is 10 May, third Sunday of June 2026 is 21 June
    - **Validates: Requirements 9.11, 9.15, 14.3, 14.5, 14.16**

  - [ ] 1.4 Add `repeat_rule.dart`
    - Sealed `RepeatRule` with `NoRepeat`, `CadenceRepeat` (daily, weekly, monthly, yearly only), `EasterRelative(offsetDays)` and `NthWeekday(month, weekday, ordinal)`, each with an optional inclusive `end`
    - `occurrenceStarts({firstStart, spanDays, rule, skipped, from, to})` returning the start dates of the occurrences that touch the range, in order, never before `firstStart`, never after `end`, never on a skipped date
    - `CadenceRepeat` must call `occurrenceDate` and `firstIndexAfter` from `lib/core/cadence.dart` (no second implementation of month-end clamping); a series without an end must only iterate over the requested range
    - _Requirements: 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.10, 9.11, 9.15_

  - [ ] 1.5 Write property tests for expansion
    - **Property 1: Occurrences stay inside their bounds** — for any rule, Repeat_End, skipped dates and range, every start is on or after the first start, on or before the end, on no skipped date, and the occurrence touches the range
    - **Property 2: Monthly and yearly clamping never drifts** — monthly occurrence k falls on the start's day of month or the month's last day; yearly 29 February falls on 28 February in non-leap years
    - **Property 3: Every occurrence keeps the first duration** — span days and minutes are equal for all occurrences of a series
    - **Validates: Requirements 9.3, 9.4, 9.5, 9.6, 9.7, 9.10**

  - [ ] 1.6 Add `event_xp.dart`
    - `eventXp({type, allDay, duration})`: timed 10 up to 30 minutes, 25 up to 120, 50 up to 300, 100 above (a duration that spans midnight is above); all-day 10 for birthday, nameDay, publicHoliday, notableDay, date and 25 for dance, work, meeting, seminar, lesson
    - The function takes the duration as an argument and never reads the `Clock`
    - _Requirements: 16.1, 16.2, 16.5, 16.6_

  - [ ] 1.7 Write tests for Event_XP
    - Unit tests at the boundaries 30, 31, 120, 121, 300, 301 minutes and for every all-day type
    - **Property 6: Event_XP is always a Difficulty value** — for any type, all-day flag and duration the result is 10, 25, 50 or 100, and for timed events it does not decrease when the duration grows
    - **Validates: Requirements 16.1, 16.2, 16.5**

  - [ ] 1.8 Add `calendar_dates.dart`
    - `monthGridDates(month)` returning the 42 dates of six weeks, Monday first
    - `coveredDates(start, spanDays)`, `isNavigableMonth(month)` (January 2000 to December 2100) and `searchKey(text)` (lower case, diacritics removed, covering all Czech letters)
    - _Requirements: 2.1, 2.9, 3.5, 6.5, 10.2_

  - [ ] 1.9 Write tests for dates and search key
    - Unit tests: `monthGridDates` for months that start on every weekday, February in leap and non-leap years, the navigation limits
    - **Property 11: A multi-day occurrence touches exactly its dates** — an occurrence with a span of d days is returned for every date from its start to start plus d and for no other
    - **Property 12: Search ignores case and diacritics** — a substring of a name, lower-cased and stripped of diacritics, is found by `searchKey` matching
    - **Validates: Requirements 3.5, 6.5, 10.2**

- [ ] 2. Data layer (`lib/data/calendar/`, schema version 3)
  - [ ] 2.1 Add the tables and the 2 to 3 migration
    - Create `calendar_tables.dart` with `CalendarEvents`, `CalendarSkippedDates` and `CalendarCompletions` exactly as in the design DDL (date columns through `DateOnlyConverter`, CHECK constraints, composite primary keys, `idx_calendar_events_start`)
    - Add them to `@DriftDatabase`, raise `schemaVersion` to 3, add `if (from < 3)` creating the three tables with `m.createTable`, and run `timeout 500 dart run build_runner build` in the background
    - Dump the schema to `drift_schemas/drift_schema_v3.json`
    - Do not alter any existing table
    - _Requirements: 12.1, 12.2_

  - [ ] 2.2 Add models and mappers
    - `calendar_models.dart`: `CalendarEvent` (with `allDay`, `spanDays`, `duration`), `EventOccurrence`, `EventCompletion`, `EventDraft`, `DeletedEventSnapshot`, `SearchResult`
    - `calendar_mappers.dart`: row to model and draft to companion; start and end as date plus minutes with no time zone; the rule columns map to and from `RepeatRule`; an unknown `event_type` maps to `meeting` without touching the row
    - _Requirements: 9.5, 12.3, 12.5_

  - [ ] 2.3 Add the seed
    - `calendar_seed_data.dart`: the 35 built-in events as const data, with the exact Czech names, dates, offsets, types, start dates and On_Board flags of Requirement 14 (13 public holidays, 16 notable and folk days, 6 name days; all all-day)
    - `calendar_seed.dart`: `seedCalendarDefaults(db)` inserting them in one transaction; call it from `onCreate` after `createAll` and from the `from < 3` step, and nowhere else
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.6, 14.7, 14.8, 14.10, 14.11, 14.12, 14.13, 14.14, 14.15, 14.17, 14.18, 14.19_

  - [ ] 2.4 Write tests for the seed content
    - Count by type (13, 16, 6), names, dates, rules, offsets and start dates against the requirement text; On_Board off for the first two groups and on for name days
    - Expand the seeded events for 2026 and check 3, 5 and 6 April, 10 May, 21 June, 1 January, 24 to 26 December
    - A seeded event can be updated and deleted through the service-level helpers used by the ordinary flow
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.10, 14.11, 14.12, 14.13, 14.14, 14.15, 14.17, 14.18_

  - [ ] 2.5 Write migration and storage property tests
    - Use the v2 schema dump to build a v2 database with quests, missions, a rule and app state, migrate to v3, compare every old row, count 35 events, reopen and count again; a fresh `onCreate` database holds the same 35 events
    - **Property 13: Migration keeps data and seeds once** — for any v2 content the old rows are unchanged, exactly 35 events are added and a second open adds none
    - **Property 14: Wall-clock times are zone-independent** — reading a stored event under different device time zones gives the same start and end date and minutes
    - **Validates: Requirements 12.2, 12.3, 14.9, 14.19**

  - [ ] 2.6 Add `calendar_filter_store.dart`
    - `CalendarFilterStore` interface and `FileCalendarFilterStore` writing the shown `EventType.key` values, comma separated, to `calendar_filter.txt` beside the database, following `palette_choice_store.dart`
    - A missing, unreadable or unparsable file loads as all ten types
    - _Requirements: 5.2, 5.6_

  - [ ] 2.7 Write tests for the filter store
    - Round trip, missing file, garbage content, unknown keys ignored, all types removed is stored and loaded as empty
    - _Requirements: 5.2, 5.6_

- [ ] 3. Checkpoint — core and data
  - Ensure `flutter analyze` and the tests under `test/core/calendar` and `test/data/calendar` pass, ask the user if questions arise

- [ ] 4. Calendar service (`lib/services/calendar/`)
  - [ ] 4.1 Create and update events
    - `CalendarService(db, xp, clock)` with `create`, `update` (applies to the whole series) and `lastUsedType` (type of the most recently saved event, else `meeting`)
    - Validate with `validatedName` and `ValidationError`: name 1 to 80 after trimming, note at most 500, location at most 120, end not before start, Repeat_End not before the start date; save sets `created_at` and `updated_at` from the `Clock`
    - Every write goes through `db.runTransaction`
    - _Requirements: 4.1, 8.2, 8.7, 8.8, 9.8, 9.9, 12.4_

  - [ ] 4.2 Add the read side
    - `watchRange(from, to)` (occurrences with their completions, all-day first then by start minute, watching all three tables), `watchEvent(id)`, `search(text)` and `watchEventTasks(today)`
    - `search` matches name, note and location with `searchKey`, one result per event, ordered by the nearest occurrence on or after the Clock's calendar date, then past ones descending, and ignores the Type_Filter
    - `watchEventTasks` returns the occurrences of On_Board events whose start date equals `today`, with their completions, all-day first then by start minute
    - _Requirements: 3.1, 3.4, 3.6, 6.3, 6.10, 10.2, 10.3, 10.4, 10.8, 15.1, 15.2, 15.13_

  - [ ] 4.3 Add deletion and restore
    - `deleteOccurrence(id, occurrenceDate, scope)` with `DeleteScope.onlyThis` (insert a Skipped_Date), `thisAndFollowing` (set `repeat_end` to the day before, or delete the event when it is the first occurrence) and `all` (delete the event); an event without a Repeat_Rule is deleted whatever the scope
    - Return a `DeletedEventSnapshot` (event, skipped dates, completions); `restore(snapshot)` writes them back with the same ids in one transaction
    - Deleting never changes Total_XP
    - _Requirements: 9.7, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 11.10, 11.11_

  - [ ] 4.4 Add completion of Event_Tasks
    - `completeOccurrence(id, occurrenceDate)`: in one transaction compute `eventXp` from the stored event, insert the `EventCompletion` with `awarded_xp` and call `XpEngine.apply(+xp)`; an existing completion is returned unchanged with no XP change
    - `reopenOccurrence`: delete the completion and apply the negative of its stored `awarded_xp`
    - XP uses the duration of the first occurrence for every occurrence of a series
    - _Requirements: 15.4, 15.7, 15.11, 15.13, 16.3, 16.4_

  - [ ] 4.5 Add providers
    - `calendar_providers.dart`: `calendarServiceProvider`, `calendarFilterStoreProvider`, `calendarTodayProvider` (Clock's calendar date, refreshed at local midnight and on resume, modelled on `boardDayProvider`), `visibleMonthProvider`, `selectedDayProvider`, `typeFilterProvider` (loads and saves through the store), `monthOccurrencesProvider`, `dayOccurrencesProvider` (both apply the Type_Filter), `eventTasksProvider` (Today from `boardDayProvider`, no filter)
    - `visibleMonthProvider` starts on the month of Calendar_Today and refuses months outside 2000 to 2100
    - _Requirements: 1.3, 2.9, 2.10, 5.2, 5.3, 5.6, 15.1, 15.8, 15.14_

  - [ ] 4.6 Write service tests
    - On an in-memory database with a fixed `Clock`: create, update (whole series), validation errors, last used type, `watchRange` and `watchEventTasks` re-emitting after create, edit, delete and completion, search ordering and diacritics, deletion scopes and restore, completion and reopening against `XpEngine`, deleting a completed event keeps Total_XP
    - Seeded holidays do not appear in `watchEventTasks`, a seeded name day does on its date
    - _Requirements: 3.6, 8.2, 8.7, 9.8, 9.9, 10.3, 10.4, 11.3, 11.4, 11.5, 11.6, 11.7, 11.11, 15.1, 15.4, 15.7_

  - [ ] 4.7 Write property tests for the service
    - **Property 7: Completing twice awards once, reopening restores Total_XP**
    - **Property 8: A later edit does not change awarded XP**
    - **Property 9: Delete then undo restores the calendar** — events, Skipped_Dates, Repeat_End, completions equal before and after; Total_XP unchanged by both steps
    - **Property 10: "This and following" keeps the past** — earlier occurrences unchanged, none on or after the chosen one remain
    - **Validates: Requirements 11.5, 11.6, 11.8, 11.9, 11.11, 15.4, 15.7, 15.11, 16.4**

  - [ ] 4.8 Write provider tests
    - Calendar_Today changes at local midnight while Today (Board_Day) changes at 04:00: at 03:59 and 04:00 an event on that date is an Event_Task only from 04:00, and the today mark of the Month_View moves at 00:00
    - Type_Filter is restored from the store and filters the month and day providers but not `eventTasksProvider` or search
    - _Requirements: 2.10, 5.3, 5.6, 10.8, 15.1, 15.14_

- [ ] 5. Checkpoint — services
  - Ensure `scripts/check.sh` passes (analyze, all tests, structure check), ask the user if questions arise

- [ ] 6. Theme, strings and the fourth tab
  - [ ] 6.1 Add the Event_Type colours and their tests
    - In `lib/ui/theme/tokens.dart` add `EventTypeColors` on `QuestlogPalette` with the ten colours and `eventChipInk` from the design table; no literal colour elsewhere
    - Add `test/ui/theme/event_colors_test.dart`: pairwise CIE76 distance of at least 25 in the dark theme, chip ink contrast of at least 4.5 on every solid fill, Soft_Chip text contrast against its tinted fill in both themes
    - _Requirements: 3.7, 4.2, 4.7, 13.2_

  - [ ] 6.2 Add the Kalendář tab
    - Add a 24px calendar SVG to `assets/icons/` and `IconAsset.calendar`; extend `ShellTab` to `quests, missions, calendar, settings`; update `QuestlogTabBar` and `AppShell` (keep every tab alive so the Visible_Month and Selected_Day survive tab changes); show no Hero_Bar on the new tab
    - Update the tab, shell and a11y tests for four tabs, their order, no press highlight and the preserved state
    - _Requirements: 1.1, 1.2, 1.4, 1.5_

  - [ ] 6.3 Add the calendar strings
    - Add every calendar string to `app_cs.arb` (template) and `app_en.arb`: tab label, headings, button and field labels, type names, repeat choices ("Nikdy", "Každý den", "Každý týden", "Každý měsíc", "Každý rok", "Každý rok podle Velikonoc", "Každý rok podle dne v týdnu"), repeat descriptions, empty states ("Žádné události", "Nic nenalezeno"), delete texts, "Splněno", "Za splnění: +N XP", accessibility labels; regenerate `lib/l10n`
    - Extend the l10n completeness test so both languages have the same keys
    - _Requirements: 13.1, 13.4_

- [ ] 7. Form, deletion, filter, month picker and search
  - [ ] 7.1 Add the type picker and `EventFormScreen`
    - `event_type_picker.dart`: grid of ten options, each with its colour and name, exactly one selected
    - `event_form_screen.dart`: create (with `presetDate`), edit (`eventId`) and duplicate (`prefill`); fields, all-day switch, start and end pickers (moving the start moves the end), Repeat_Rule picker with optional Repeat_End (never offering Easter_Relative or Nth_Weekday, but keeping them when editing an event that has one), location, On_Board switch with the live "Za splnění: +N XP" line from `eventXp`, disabled save while the name is empty, inline errors, unsaved-changes confirmation, storage-error retry, delete button for an existing event
    - New-event defaults: preset date, next full hour when the date is Calendar_Today (23:00 when the next full hour would be midnight) and 09:00 otherwise, one hour, last used type, On_Board from the type until the user touches the switch
    - _Requirements: 4.4, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10, 8.11, 8.12, 8.13, 8.14, 9.1, 9.8, 9.12, 9.13, 11.1_

  - [ ] 7.2 Write widget tests for the form
    - Disabled save, inline name, end and Repeat_End errors, all-day hiding the times, start moving the end, defaults for a new event, type change flipping On_Board until touched, XP line updating, repeat choices without Easter_Relative, an Easter_Relative event keeping its rule, unsaved-changes dialog, save closes and the event shows in the month
    - _Requirements: 8.2, 8.3, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10, 8.11, 8.13, 8.14, 9.1, 9.8, 9.12, 9.13_

  - [ ] 7.3 Add the deletion flow
    - `delete_event_sheet.dart` on `QuestlogSheet` and `confirm_destructive.dart`: one destructive button for an event without a Repeat_Rule, three ("Jen tuto událost", "Tuto a všechny další", "Všechny události v sérii") for a repeating one, "Zrušit" always
    - After a delete close the event screens and show a snackbar with "Zpět" that calls `restore`; on a storage error keep the event and show an error snackbar
    - _Requirements: 11.1, 11.2, 11.3, 11.8, 11.9, 11.10_

  - [ ] 7.4 Add the filter sheet and the month picker
    - `type_filter_sheet.dart`: ten toggles, saving through `typeFilterProvider`; `month_picker_sheet.dart`: twelve months and a year stepper limited to 2000 to 2100
    - _Requirements: 2.8, 2.9, 5.1, 5.4, 5.5, 5.6_

  - [ ] 7.5 Add `EventSearchScreen`
    - Text field with the keyboard shown, hint while empty, results with name, type colour and name and the occurrence date, "Nic nenalezeno" for no match, a tap opens the Event_Detail_Screen of that occurrence
    - _Requirements: 10.1, 10.3, 10.5, 10.6, 10.7_

  - [ ] 7.6 Write widget tests for sheets and search
    - Delete sheet with one and three choices and the snackbar undo, filter sheet toggles and the message for an empty month with its restore button, month picker limits, search results order, empty and hint states
    - _Requirements: 2.8, 2.9, 5.1, 5.5, 10.3, 10.5, 10.6, 10.7, 11.2, 11.3, 11.8, 11.9_

- [ ] 8. Event detail, day sheet and month
  - [ ] 8.1 Add `EventDetailScreen`
    - Name, type badge (Soft style for a notable day), start and end, "Celý den" for all-day, note, repeat in words, location (a tap copies it and shows a snackbar), "Splněno" with time and XP when completed, close button, menu with "Upravit", "Duplikovat" (all values except the Repeat_Rule) and "Smazat", and the bottom "Upravit" button
    - _Requirements: 4.3, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 7.10, 9.14_

  - [ ] 8.2 Add the Day_Sheet
    - `showDaySheet(context, date)` on `QuestlogSheet`: full date with weekday, event count, all-day events marked "Celý den", timed events with start, end, type bar and type name, partial ranges for multi-day events, tap opens the detail, add button opens the form with the date preset, empty state with an add button, dismiss by close button, swipe or tap outside, live updates
    - _Requirements: 4.3, 4.6, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 6.9, 6.10_

  - [ ] 8.3 Add `CalendarScreen`, `MonthGrid` and `EventChip`
    - Header with previous and next arrows, the title (opens the month picker), "Dnes", search and filter buttons (accent while the filter hides a type); weekday row; six-row grid in a `PageView` for horizontal swipe; neighbouring days faded; today mark; chips solid or Soft_Chip, all-day first, up to three or two plus "+N"; one `Semantics` node per cell; chip names truncated at large text sizes; add button with the Selected_Day preset; cell tap sets the Selected_Day and opens the Day_Sheet
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.10, 3.1, 3.2, 3.3, 3.4, 3.7, 3.8, 4.3, 4.5, 6.1, 6.7, 13.5_

  - [ ] 8.4 Write widget tests for detail, day sheet and month
    - Month: six rows, Monday first, arrows, swipe, "Dnes", today mark, chips and "+N", Soft_Chip for a notable day, semantics label, filter hiding types, large text scale without overflow; day sheet: order, empty state, dismiss, live update; detail: all fields, "Nenastaveno", "Nikdy", location copy, completed status, menu actions
    - Run the a11y harness for touch targets of 44 logical pixels and labels on icon-only controls
    - _Requirements: 2.1, 2.4, 2.5, 2.6, 2.7, 3.2, 3.3, 3.8, 4.3, 4.5, 6.3, 6.8, 7.2, 7.3, 7.4, 7.5, 7.6, 9.14, 13.3, 13.4, 13.5, 13.6_

- [ ] 9. Event_Tasks on the Board
  - [ ] 9.1 Add `EventTaskCard` and the Board integration
    - `event_task_card.dart` reusing `CheckCircle` and `DifficultyPips`: type colour dot and name, time range or "Celý den", Event_XP with its pips, calendar mark, done style; a tap outside the check circle opens the detail
    - `board_screen.dart` watches `eventTasksProvider(today)`; `quest_list.dart` renders the tasks as non-draggable entries above the Quests of the Today section, all-day first; counts and the empty state include them; tapping the check circle calls `completeOccurrence` or `reopenOccurrence` and gives the same feedback as a Quest; no reorder, no swipe delete, no section move; the Type_Filter has no effect
    - _Requirements: 15.1, 15.2, 15.3, 15.5, 15.6, 15.8, 15.9, 15.10, 15.12, 15.14_

  - [ ] 9.2 Write widget tests for the Board
    - Tasks appear in Today above Quests in the right order, check and uncheck update the hero bar and the done style, a task of yesterday is gone, no drag handle and no swipe actions, the empty Board with only an Event_Task is not empty, a tap opens the detail
    - _Requirements: 15.2, 15.3, 15.4, 15.6, 15.7, 15.8, 15.9, 15.10, 15.12_

- [ ] 10. End to end, goldens and documentation
  - [ ] 10.1 Add the end-to-end scenario
    - In `test/ui/e2e_scenario_test.dart`: create a birthday with On_Board on, see it on the Board on its day, complete it and see the XP in the hero bar, open it in the calendar, delete it and undo, and check the seeded 17 November on the month without an Event_Task
    - _Requirements: 8.11, 11.8, 11.9, 14.1, 15.1, 15.4_

  - [ ] 10.2 Add golden tests
    - Goldens for the month, the day sheet, the detail, the form and the Board with Event_Tasks, in Czech, dark and light; regenerate with `flutter test --update-goldens test/goldens` only for these new files
    - _Requirements: 13.1, 13.2_

  - [ ] 10.3 Update documentation and screenshots
    - `CLAUDE.md`: status paragraph, layout block (new directories, schema v3, four tabs), a "Changed 2026-11-19 at Martin's request" note; `DOCS.md` and `README.md`: calendar section and retaken screenshots of the Board and the calendar (English, dark, 2x); `.kiro/specs/002-questlog-ui/requirements.md`: add "Changed" notes at Requirement 1 criteria 2 and 3 and at Requirement 3 for the Event_Tasks; remove the "no notifications" claim only if it concerns the calendar (notifications themselves stay out of scope)
    - _Requirements: 1.1, 15.2_

- [ ] 11. Checkpoint — final
  - Ensure `scripts/check.sh` passes (analyze, all tests, structure check) and the app starts under `xvfb-run -a flutter run -d linux`, ask the user if questions arise

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.8", "6.3"] },
    { "id": 1, "tasks": ["1.3", "1.4", "1.6", "2.6", "6.1"] },
    { "id": 2, "tasks": ["1.5", "1.7", "1.9", "2.1", "2.7", "6.2"] },
    { "id": 3, "tasks": ["2.2"] },
    { "id": 4, "tasks": ["2.3", "4.1"] },
    { "id": 5, "tasks": ["2.4", "2.5", "4.2", "4.3", "4.4"] },
    { "id": 6, "tasks": ["4.5", "4.6", "4.7"] },
    { "id": 7, "tasks": ["4.8", "7.1", "7.3", "7.4", "7.5", "9.1"] },
    { "id": 8, "tasks": ["7.2", "7.6", "8.1", "9.2"] },
    { "id": 9, "tasks": ["8.2"] },
    { "id": 10, "tasks": ["8.3"] },
    { "id": 11, "tasks": ["8.4"] },
    { "id": 12, "tasks": ["10.1", "10.2"] },
    { "id": 13, "tasks": ["10.3"] }
  ]
}
```

## Notes

- Work in the project root `/workspace/QuestLog`. Once per sandbox: `git config --global --add safe.directory /opt/flutter` (skill `sandbox-flutter`). Drift codegen (`timeout 500 dart run build_runner build`) takes about 50 seconds: run it in the background and poll the log. `scripts/check.sh` takes about 4 minutes.
- No task in this plan is optional: every test sub-task is part of the work, and a task is marked `[x]` only when its code exists and its tests pass.
- Commits: local repository, never push. One Conventional Commit per sub-task, author exactly `Martin Jablečník <martin.jablecnik@email.cz>`, written in English. Do not add any tool attribution, Co-Authored-By, session or "generated with" lines to commit messages or tags: the user's global rule overrides any default.
- Waves in the dependency graph list tasks that may run in parallel only when they touch disjoint files. 6.3 creates every calendar string up front so that no later task edits the ARB files at the same time; if a later task needs another string it adds it after the wave.
- `lib/data` has eight files and `lib/services` six: every new file goes into the `calendar/` subdirectory named in the design, and `scripts/check-structure.sh` fails above 15 files in a directory.
- No `DateTime.now` outside `lib/core/clock.dart`, no literal colours, durations or spacing in `lib/ui`, no icon-font icons; the existing guard tests fail on them. Time zone independence (Property 14) is tested by reading the stored text and minutes and by passing explicit `DateTime` values to the `Clock`, not by changing the environment of the test process.
- Property tests with `glados`: hide the symbols that clash with `flutter_test` on the import, as the existing tests do. Widget tests need the bundled fonts loaded (see `test/ui/a11y/_a11y_harness.dart`); Riverpod 3 stream providers need a listener in tests.
- The Board uses Today (Board_Day, 04:00) and the calendar uses Calendar_Today (local midnight). Do not use one for the other: an Event_Task of a date appears at 04:00 of that date, while the today mark moves at 00:00.
- Easter_Relative and Nth_Weekday are internal: the form never offers them but must keep them on edit. Czech names of the 35 seeded events are stored as written in Requirement 14, whatever the Effective_Language.
- Out of scope and not to be added: reminders and notifications, an event URL, the Week, Day and List views, user-defined types or colours, synchronisation with the system calendar. The temporary font and palette switches stay as they are; they are removed in a separate change.
- iOS build and on-device checks are done by the user, not here.
