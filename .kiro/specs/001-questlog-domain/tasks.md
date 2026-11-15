# Implementation Plan: Questlog Domain

## Overview

Build the Questlog domain layer in a new Flutter project at `/workspace/questlog/`: pure rules in `lib/core/`, the Drift schema in `lib/data/`, and the Quest_Service, Mission_Service, Xp_Engine, Recurrence_Service and Settings_Service in `lib/services/`, wired together with Riverpod providers. Work proceeds bottom-up: scaffolding, pure rules, database, then services. Each implementation task is followed by its tests; correctness properties from `design.md` are checked with `glados` property tests, and service tests run against a real in-memory SQLite database. No screens are built here; spec `002-questlog-ui` consumes these services.

## Tasks

- [x] 1. Scaffold the Flutter project
  - [x] 1.1 Create the project and dependencies
    - Run `git init` in `/workspace/questlog/` and set the commit author to `Martin Jablečník <martin.jablecnik@email.cz>` (see the Git note below)
    - Run `git config --global --add safe.directory /opt/flutter` if flutter fails with dubious ownership (see skill `sandbox-flutter`)
    - Run `flutter create --org com.jablecnik --project-name questlog --platforms=ios,linux .` in `/workspace/questlog/` (keep the existing `.design/` and `.kiro/`)
    - Add to `pubspec.yaml`: `drift`, `path_provider`, `path`, `flutter_riverpod`; dev: `drift_dev`, `build_runner`, `glados`, `flutter_test`, `flutter_lints`; set version `0.1.0+1`
    - Create the empty directories `lib/core`, `lib/data`, `lib/services`, `test/helpers`, `test/core`, `test/services`
    - Replace the generated `lib/main.dart` counter app with a minimal `main()` that runs `ProviderScope` with an empty `MaterialApp`
    - Delete the generated `test/widget_test.dart`
    - _Requirements: 14.1, 14.5, 14.6_

  - [x] 1.2 Add repository hygiene files and check scripts
    - Create `.env.example` containing only a comment that the app has no environment variables, and extend `.gitignore` with `.env`, `.env.*`, `!.env.example`
    - Copy `check-structure.sh` from `/workspace/tool-configs/templates/scripts/` to `scripts/check-structure.sh` and fill in its marked placeholders
    - Create `scripts/check.sh` (bash, `set -euo pipefail`, Script Portability pattern) running `flutter analyze`, `flutter test` and `scripts/check-structure.sh`
    - Make both scripts executable
    - Run `scripts/check.sh` and confirm it passes on the empty project
    - _Requirements: 14.2, 14.3, 14.4_

- [ ] 2. Implement the pure core rules
  - [x] 2.1 Implement Clock, board day and errors
    - `lib/core/clock.dart`: `Clock` interface and `SystemClock`
    - `lib/core/board_day.dart`: `dayStart` (4 hours), `boardDayStart(DateTime now)` and `todayOf(DateTime now)` built with the `DateTime(y, m, d, 4)` constructor
    - `lib/core/errors.dart`: sealed `DomainError` with `ValidationError`, `NotFoundError`, `InvalidStateError`, `StorageError`
    - Add `test/helpers/fixed_clock.dart` with a settable `FixedClock`
    - _Requirements: 7.7, 7.8, 13.7_

  - [x] 2.2 Write unit and property tests for the board day
    - **Property 11: Board_Day boundary is the most recent 04:00**
    - For any local instant, including instants around DST changes, `boardDayStart` returns the most recent 04:00 at or before it and `todayOf` returns that boundary's calendar date
    - Unit cases: 03:59 belongs to the previous day, 04:00 starts the new day, 00:30 belongs to the previous day
    - **Validates: Requirements 7.2, 7.3, 7.7, 7.8**

  - [x] 2.3 Implement XP rules
    - `lib/core/xp_rules.dart`: `Difficulty` (10/25/50), `MissionBonus` (50/100/200) with `xp` getters, `levelThreshold`, `xpToReachLevel`, `levelFor`, `progressFor`, `LevelProgress`
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 2.4 Write property tests for levels
    - **Property 1: Level derivation is consistent with thresholds**
    - For any non-negative Total_XP, `levelFor` returns the largest Level with `xpToReachLevel(L) <= Total_XP`, XP-into-level is in `[0, threshold)`, and `levelFor` never decreases as Total_XP grows
    - Unit cases: 0 XP is Level 1, 99 XP is Level 1, 100 XP is Level 2, 249 XP is Level 2, 250 XP is Level 3
    - **Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.6**

  - [x] 2.5 Implement Cadence and Occurrence arithmetic
    - `lib/core/cadence.dart`: `Cadence` enum, `occurrenceDate(anchor, cadence, k)`, `firstIndexAfter(anchor, cadence, date)`, `firstAnchor(cadence, requested, today:, lastPosted:)`
    - Month-based Cadences keep the anchor's day of month, clamped to the target month's last day, always computed from the anchor
    - _Requirements: 8.3, 8.4, 8.5, 8.7_

  - [x] 2.6 Write property tests for Occurrences
    - **Property 7: Occurrences are strictly increasing and computed from the anchor**
    - For any anchor, Cadence and indices `j < k`, occurrence `j` is strictly before occurrence `k`; month-based results equal the anchor's day clamped to the month length (31st, Feb 29)
    - Unit cases: Monthly anchor Jan 31 yields Feb 28/29, Mar 31; Yearly anchor Feb 29 yields Feb 28 in non-leap years; Biweekly steps 14 days
    - **Validates: Requirements 8.3, 8.4, 8.5**

- [x] 3. Checkpoint — Core rules
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Implement the database
  - [x] 4.1 Define tables, preferences and the database
    - `lib/data/preferences.dart`: `AppLanguage`, `AppTheme`, `DisplayFont`
    - `lib/data/tables.dart`: Drift tables `Missions`, `Quests`, `RecurringRules`, `RuleQuests`, `AppState` exactly as in the Data Models section of `design.md` (CHECK constraints, indexes, foreign keys)
    - `lib/data/database.dart`: `QuestlogDatabase` with `schemaVersion = 1`, `PRAGMA foreign_keys = ON` in `beforeOpen`, creation of the singleton `app_state` row (Total_XP 0, default settings) in `onCreate`, a lazily opened file database via `path_provider`, and a `QuestlogDatabase.forTesting(QueryExecutor)` constructor
    - Run `dart run build_runner build` and `dart run drift_dev schema dump lib/data/database.dart drift_schemas/` to produce version 1
    - _Requirements: 13.1, 13.2, 13.4, 13.5, 13.6_

  - [x] 4.2 Add test helpers and database tests
    - `test/helpers/test_database.dart`: factory returning a `QuestlogDatabase` over `NativeDatabase.memory()`
    - Test: a fresh database has Total_XP 0 and the default settings
    - Test: a transaction that throws leaves all tables unchanged
    - Test: deleting a Mission cascades to its Quests, deleting a rule sets `missions.rule_id` to null and cascades to `rule_quests`
    - If `NativeDatabase.memory()` fails on Linux for a missing SQLite library, install it or use `sqlite3` with a bundled build before continuing
    - _Requirements: 13.2, 13.3, 13.5_

- [x] 5. Implement the Xp_Engine and Settings_Service
  - [x] 5.1 Implement Xp_Engine
    - `lib/services/xp_engine.dart`: `readTotal`, `apply(delta)` (clamped at zero, returns `XpChange` with before/after totals and Levels), `watchProgress`
    - `apply` must run inside the caller's transaction (accept the active transaction through the database's zone)
    - Add `XpChange` and result types to `lib/data/models.dart`
    - _Requirements: 2.2, 2.6, 6.5, 6.6, 6.7_

  - [x] 5.2 Write Xp_Engine tests
    - Unit: positive delta raises Total_XP and reports Level change across 100 XP; negative delta across a Level boundary reports the lower Level; delta below zero clamps at 0
    - Unit: `watchProgress` emits a new value after `apply`
    - _Requirements: 6.5, 6.6, 6.7, 2.6_

  - [x] 5.3 Implement Settings_Service
    - `lib/services/settings_service.dart`: `watch`, `setHeroName` (trim, max 40 characters, empty allowed), `setLanguage`, `setTheme`, `setDisplayFont`, `resolveLanguage(setting, deviceLanguageCode)` (system resolves to `cs` or `en`, otherwise `en`)
    - Add `AppSettings` to `lib/data/models.dart`
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8_

  - [x] 5.4 Write Settings_Service tests
    - Defaults: language `system`, theme `system`, font Figtree, name empty
    - Hero name of 41 characters throws `ValidationError`; whitespace-only name is stored as empty
    - `resolveLanguage('system', 'de')` returns `en`; `'cs'` returns `cs`
    - Each setter emits the new `AppSettings` on `watch`
    - _Requirements: 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8_

- [x] 6. Implement the Quest_Service
  - [x] 6.1 Implement Quest creation, editing and deletion
    - `lib/services/quest_service.dart`: `create`, `update`, `delete` with validation (name 1–80 trimmed, note ≤ 500), Mission existence and `open` check, `sort_order = max + 1`
    - Editing a done Quest changes only name and note
    - Deleting a Quest never touches Total_XP
    - Add `Quest`, `QuestDraft` to `lib/data/models.dart`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 3.1_

  - [x] 6.2 Write Quest creation and editing tests
    - Name boundaries (empty, whitespace only, 80 and 81 characters), note boundary (500 and 501), unknown Mission, `completed` and `closed` Mission, done-Quest edit ignoring Difficulty and Mission changes, delete leaving Total_XP unchanged
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.7, 1.8_

  - [x] 6.3 Implement completion and reopening
    - `complete(id)` in one transaction: mark done, `completed_at` from the Clock, `awarded_xp` from the Difficulty at that moment, `XpEngine.apply(+xp)`, return `CompleteQuestResult` with Levels, Mission progress and `missionReadyToComplete`
    - Completing an already done Quest is a no-op returning the existing result without awarding XP
    - `reopen(id)` in one transaction: clear completion, `XpEngine.apply(-awarded_xp)`; when the parent Mission is `completed`, set it back to `open` and subtract its `awarded_bonus`, clearing the bonus fields
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9_

  - [x] 6.4 Write completion property and unit tests
    - **Property 2: Completing then reopening a Quest restores Total_XP**
    - For any open Quest and starting Total_XP, complete followed by reopen leaves Total_XP and Quest state unchanged
    - **Validates: Requirements 2.2, 2.5, 2.9**
    - **Property 3: Quest completion is idempotent**
    - For any open Quest, completing twice changes Total_XP by the Difficulty XP exactly once
    - **Validates: Requirements 2.8**
    - **Property 4: Total_XP never goes below zero**
    - For any sequence of create, complete, reopen and delete operations Total_XP stays at or above zero
    - **Validates: Requirements 2.6, 6.7**
    - Unit: awarded XP stays at the completion-time value, and a Difficulty change on a done Quest is ignored; `missionReadyToComplete` is true only when the last Quest is completed; Level change is reported
    - _Requirements: 2.3, 2.4_

  - [x] 6.5 Implement reordering
    - `reorder(orderedIds)`: validate ids (unknown or duplicate → `ValidationError`, no writes), collect the subset's current `sort_order` values, sort them, assign them in the requested order, all in one transaction
    - _Requirements: 3.2, 3.3, 3.4, 3.5_

  - [x] 6.6 Write reorder tests
    - **Property 6: Reordering a subset preserves all other positions**
    - For any set of Quests and any permutation of a subset, the subset ends in the requested relative order and every other Quest keeps its position
    - **Validates: Requirements 3.2, 3.3, 3.4**
    - Unit: unknown id and duplicate id are rejected with nothing changed; new Quests are placed last; the Board and a Mission show the same relative order for shared Quests
    - _Requirements: 3.1, 3.5_

  - [x] 6.7 Implement board streams and Quest history
    - Add `BoardQuest` (Quest plus nullable Mission name, joined in the query) to `lib/data/models.dart`
    - `watchOpenBoard()` returning `BoardQuest` (standalone or `open` Mission, open, in `sort_order`), `watchDoneToday(today)` returning `BoardQuest` completed within the Board_Day of the supplied `today` (`boardDayStartOf(today)` up to the next Day_Start), `history(fromDay, toDay)` returning `HistoryQuest` newest first with name, Difficulty, awarded XP, completion time and Mission name
    - The Board_Day comes from the caller, never from a timer inside the service, so the UI's Board_Day signal drives the refresh
    - Add `boardDayStartOf(today)` to `lib/core/board_day.dart` with a unit test across a DST change
    - _Requirements: 7.1, 7.2, 7.3, 7.9, 7.10, 15.4, 15.6, 15.7_

  - [x] 6.8 Write board stream and history tests
    - Quests done before 04:00 today belong to the previous Board_Day and drop out when `watchDoneToday` is called with the next `today`; done Quests of `closed` Missions are excluded from the board but present in history
    - `BoardQuest.missionName` is set for Mission Quests and null for standalone Quests
    - History range filter, newest-first order, reopened Quest absent, no write side effects
    - _Requirements: 7.1, 7.2, 7.3, 7.9, 7.10, 15.4, 15.6, 15.7_

- [x] 7. Implement the Mission_Service
  - [x] 7.1 Implement Mission creation, editing, deletion and adding Quests
    - `lib/services/mission_service.dart`: `create` (Mission plus initial Quests in one transaction, ordered after existing Quests), `update` (name and bonus; recorded bonus of a `completed` Mission unchanged), `delete` (cascade, Total_XP unchanged), `addQuest` (only to `open` Missions)
    - Add `Mission`, `MissionStatus`, `MissionDraft`, `MissionSummary`, `MissionDetail` to `lib/data/models.dart` with the fields in `design.md` — `Mission` and `MissionSummary` expose `ruleId`, `completedAt` and `awardedBonus`, which 002 needs for the recurring caption, the completion date and the "completed today" bonus
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_

  - [x] 7.2 Write Mission lifecycle tests
    - Name validation, Quests created in given order, adding a Quest to a `completed` or `closed` Mission is rejected, deleting a Mission removes all its Quests and leaves Total_XP unchanged, editing the bonus of a `completed` Mission leaves the recorded bonus
    - _Requirements: 4.1, 4.2, 4.4, 4.5, 4.7_

  - [x] 7.3 Implement Mission completion
    - `complete(id)`: require `open`, at least one Quest and all Quests done, else `InvalidStateError`; set `completed`, `completed_at`, `awarded_bonus`, `XpEngine.apply(+bonus)`, return `CompleteMissionResult`
    - Completion is never triggered automatically by Quest completion
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

  - [x] 7.4 Write Mission completion property tests
    - **Property 12: Mission completion requires every quest done**
    - For any Mission, `complete` succeeds if and only if the Mission is `open`, has at least one Quest and all Quests are done
    - **Validates: Requirements 5.1, 5.3, 5.4, 5.5, 5.6**
    - **Property 5: Total_XP matches the award ledger**
    - For any sequence of Quest and Mission operations, Total_XP equals the sum of XP awarded by completions minus XP revoked by reopenings, with deletions contributing nothing
    - **Validates: Requirements 1.8, 2.2, 2.5, 2.7, 4.5, 5.2**
    - Unit: reopening a Quest of a `completed` Mission reopens the Mission and removes exactly the recorded bonus
    - _Requirements: 2.7, 5.7_

  - [x] 7.5 Implement Mission streams and history
    - `watchOpen()` (done count, total count, remaining Quest XP), `watchDetail(id)` (all Quests including those completed on earlier days), `watchCompletedToday(today)` (same caller-supplied Board_Day rule as `watchDoneToday`; summaries carry the awarded Mission_Bonus), `history(fromDay, toDay)` returning `HistoryMission` newest first
    - `closed` Missions and their Quests never appear in any stream
    - _Requirements: 4.8, 7.4, 7.5, 7.6, 7.10, 15.5, 15.6_

  - [x] 7.6 Write Mission stream and history tests
    - Summary counts and remaining XP, old done Quests visible in an open Mission's detail, `completed` Mission visible until 04:00 the next day then absent, `closed` Mission absent
    - **Property 13: History contains exactly the finished items in range**
    - For any set of done Quests and `completed` Missions and any date range, the History_Query returns exactly the items completed in the range, newest first, and never reopened or deleted items
    - **Validates: Requirements 15.1, 15.3, 15.4, 15.5, 15.7**

- [x] 8. Checkpoint — Quests, Missions and settings
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Implement the Recurrence_Service
  - [x] 9.1 Implement Recurring_Rule management
    - `lib/services/recurrence_service.dart`: `create`, `update`, `delete`
    - Validation: name 1–80, at least one quest template, Monthly posting day 1–28
    - On create and on Cadence or posting-day change: `firstAnchor(...)` with Today and the rule's `last_posted_on`, `next_index = 0`
    - Editing quest templates replaces `rule_quests`; existing Instances are untouched
    - Deleting a rule keeps its `open` Instance (foreign key sets `rule_id` to null)
    - Add `RecurringRule`, `RuleDraft`, `RuleQuestDraft`, `RuleSummary` to `lib/data/models.dart`
    - _Requirements: 8.1, 8.2, 8.6, 8.7, 8.8, 11.1, 11.2, 11.3_

  - [x] 9.2 Implement Posting and automatic Reconciliation
    - Private `_postInstance(rule)`: close the rule's earlier `open` Instance (`status = closed`, delete its open Quests, keep done Quests, no bonus), insert the Mission with the rule's name and bonus and one Quest per template in order, set `last_posted_on = Today`
    - `reconcile()`: in one transaction post each rule whose `occurrenceDate(anchor, cadence, next_index)` is Today or earlier, exactly once, then set `next_index = firstIndexAfter(..., Today)`; return the posted Missions
    - No timers or background work in this service
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 15.2_

  - [x] 9.3 Implement manual Posting
    - `postNow(ruleId)`: call `_postInstance`; if the Next_Occurrence date is after Today advance `next_index` by one, otherwise set it to `firstIndexAfter(..., Today)`
    - Return `PostResult` with the new Mission, `skippedNextPosting` (true when the Next_Occurrence was after Today) and `closedPreviousInstance` (true when an earlier `open` Instance was closed); add `PostResult` to `lib/data/models.dart`
    - Unit: `skippedNextPosting` is true when posted early and false when the rule was already due; `closedPreviousInstance` reflects whether an `open` Instance existed
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.7_

  - [x] 9.4 Write Recurrence_Service tests
    - **Property 8: Reconciliation posts at most once per rule and is idempotent**
    - For any rules and any gap since the last launch, `reconcile()` posts at most one Instance per rule and a second run on the same Board_Day posts none
    - **Validates: Requirements 9.1, 9.2, 9.3, 9.7**
    - **Property 9: Manual posting skips exactly the nearest automatic posting**
    - For any rule and any Today, after `postNow` the Next_Occurrence is dated after Today, `reconcile()` posts nothing on the skipped date, and the Instance's completion state has no effect
    - **Validates: Requirements 10.2, 10.3, 10.5, 10.6**
    - **Property 10: Posting closes the previous Instance without bonus**
    - For any rule with an open Instance in any completion state, posting a new Instance sets the earlier one to `closed`, awards no bonus, leaves Total_XP unchanged and leaves exactly one `open` Instance
    - **Validates: Requirements 9.5, 9.6, 10.4**
    - Unit: Instance Quests copy the templates in order; a rule due at 03:59 posts only after 04:00; editing a rule changes only the next Instance; deleting a rule keeps the open Instance as an ordinary Mission and Reconciliation never posts it again; validation errors for Monthly day 29 and rules without templates
    - _Requirements: 8.2, 8.6, 9.4, 11.1, 11.2, 11.3_

  - [x] 9.5 Implement rule streams
    - `watchRules()` returning `RuleSummary`: id, name, Cadence, Anchor_Date, Mission_Bonus, ordered quest templates (`RuleQuest`), Next_Occurrence date and whether an `open` Instance exists
    - Test that the summary reflects a manual posting, an edit of the templates and a deletion
    - _Requirements: 11.4, 11.5_

- [x] 10. Wire providers and verify end to end
  - [x] 10.1 Implement Riverpod providers
    - `lib/services/providers.dart`: providers for `QuestlogDatabase`, `Clock`, `XpEngine`, each service, and stream providers for the `watch*` methods
    - Keep `lib/main.dart` as the minimal `ProviderScope` app; the UI replaces it in spec 002
    - _Requirements: 13.6, 14.1_

  - [x] 10.2 Write an end-to-end domain test
    - Scenario on an in-memory database with a `FixedClock`: create rule and quests, `reconcile()`, complete all Quests, complete the Mission, cross a Level boundary, advance the clock across 04:00, check board and history, post manually and confirm the skipped automatic posting
    - _Requirements: 2.2, 5.2, 7.3, 9.1, 10.6, 15.1_

- [x] 11. Checkpoint — Domain complete
  - Run `scripts/check.sh` and ensure analysis, all tests and the structure check pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP; none are marked here, because the property tests guard the XP and posting rules.
- Ad-hoc commands run in zsh; every `.sh` file is bash with `set -euo pipefail`.
- Flutter commands first need `git config --global --add safe.directory /opt/flutter` (skill `sandbox-flutter`). Only Linux desktop and web are available in the sandbox; the iOS build is done by the user.
- The app has no environment variables; `.env.example` exists only to satisfy the project standard.
- Drift migrations live in code with schema dumps in `drift_schemas/`; there is no `migrations/` directory and no `scripts/migrate.sh`, because the database is created and migrated on the device at app start.
- Docker, deploy and server scripts from the template set are not applicable to a local-only iOS app.
- Domain error messages are for logs; user-facing text is localized in spec `002-questlog-ui`.
- The 4:00 Day_Start is a constant in `lib/core/board_day.dart`; making it configurable is out of scope for v1.
- Git: initialize the repository (`git init`) as the first step of task 1.1, author exactly `Martin Jablečník <martin.jablecnik@email.cz>`, and commit each completed task as one Conventional Commit per `code-git.md` — no tool-attribution trailers, no remote/push.
- Toolchain verified in the sandbox (Flutter 3.47.1): `drift`, `drift_dev`, `build_runner`, `flutter_riverpod` 3.x and `glados` 1.1.x resolve together, Drift code generation runs (about 2 minutes cold), and `NativeDatabase.memory()` works in `flutter test` on Linux. `glados` re-exports `test`, `expect` and `group`, which clash with `flutter_test`; test files that use both import `package:flutter_test/flutter_test.dart` with `hide expect, test, group, setUp, tearDown, setUpAll, tearDownAll`. The stock `test/widget_test.dart` from `flutter create` is deleted in task 1.1.
- Do not add `sqlite3_flutter_libs`: it is end-of-life (`0.6.0+eol`) and Drift 2.35 pulls in `sqlite3` 3.x, which provides the native SQLite itself. This was the only package in the spike marked end-of-life; the iOS build with the bundled SQLite has not been tried in the sandbox.
