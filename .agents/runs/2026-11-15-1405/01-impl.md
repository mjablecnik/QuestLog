# Phase 1 — Implementation

**Target:** `.` (the repository root is the single Flutter project) — passed by the orchestrator. Spec: `001-questlog-domain`. Spec `002-questlog-ui` was deliberately not touched.

## Result
OK

## Headline
All tasks of `001-questlog-domain` (1.1 through checkpoint 11) are implemented and checked off in `tasks.md`. `scripts/check.sh` is green: analysis clean, 182 tests passing (with and without `TZ=Europe/Prague`), structure check clean. No issues were opened.

## Needs attention
Nothing.

## What changed
- `lib/core/`: clock, 04:00 board day (+ `boardDayRange`), domain errors, XP/level maths, cadence and occurrence arithmetic, validation.
- `lib/data/`: Drift schema (tables, converters, preferences enums), `QuestlogDatabase` with `runTransaction`, domain models, row mappers, `quest_writes.dart` (shared "insert quest last" helper). Schema dump in `drift_schemas/drift_schema_v1.json`.
- `lib/services/`: `XpEngine`, `SettingsService`, `QuestService`, `MissionService`, `RecurrenceService`, and `providers.dart` (Riverpod providers for database, clock, services and every `watch*` stream). `lib/main.dart` stays a minimal `ProviderScope`.
- `test/`: unit and property tests per component (glados properties 1-11 from the design), helpers (`fixed_clock`, `generators`, `test_database`, `seed`), `test/services/providers_test.dart`, and `test/domain_flow_test.dart` (end-to-end scenario).
- `scripts/check.sh` (analyze, tests, structure check) and `scripts/check-structure.sh` (from the template set).
- 31 task commits on top of `9ed0099`, one Conventional Commit per task (feat then test), kept as-is.

## Decisions made
- Squash overridden by the orchestrator: the per-task commits are kept instead of regrouped.
- Service methods that validate synchronously are `async`, so validation errors surface as Future errors.
- `db.runTransaction` is the only transaction entry point; nested calls join the outer transaction, SQLite exceptions map to `StorageError`, `DomainError` is rethrown unchanged.
- Total_XP is a stored counter; each Quest/Mission records `awarded_xp` / `awarded_bonus`, so reopening and deleting reverse exactly what was granted.
- Recurring rule edits re-anchor only when the Cadence or posting day changed; otherwise the next Occurrence (including a skipped one) is preserved.
- `postNow` skips exactly the nearest automatic posting when it is still ahead of today (index becomes `nextIndex + 1`), otherwise continues from `firstIndexAfter(today)`.
- Posting an Instance closes earlier open Instances of the same rule: their open Quests are deleted, done Quests and their XP stay, no bonus is awarded.
- Deleting a rule leaves its open Instance as an ordinary Mission (`rule_id` set null by the foreign key).
- `watchRules` uses `customSelect(readsFrom: ...)` so it re-emits on changes to rules, templates and missions.
- Riverpod 3 pauses providers nobody listens to, so tests that read stream providers keep them alive with `container.listen`.
- `sqlite3_flutter_libs` was not added, per the spec notes.
