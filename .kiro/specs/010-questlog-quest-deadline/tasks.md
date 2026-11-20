# Implementation Plan: Quest Deadline

## Tasks

- [x] 1. Data and services
  - [x] 1.1 Column and migration
    - `quests.event_id`, schema 6, dump `drift_schema_v6.json`, regenerate Drift code
    - _Requirements: 1.2, 2.3_

  - [x] 1.2 Quest_Service
    - `QuestDraft.deadline`, create/move/clear/rename of the Linked_Event, delete with the Quest, `watchDeadlines`, `isOverdue`
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 2.6, 3.2_

  - [x] 1.3 Calendar_Service undo
    - The deletion snapshot keeps the Quest id and `restore` links it again
    - _Requirements: 2.3, 2.4_

  - [x]* 1.4 Service and migration tests
    - **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 1.6, 2.2, 2.3, 2.4, 2.6**

- [x] 2. Checkpoint — Ensure all tests pass, ask the user if questions arise.

- [x] 3. UI
  - [x] 3.1 Deadline field in the Quest_Sheet
    - _Requirements: 1.1, 1.6_

  - [x] 3.2 Deadline and Overdue on the Quest_Card
    - Board and Mission detail
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [x] 3.3 Widget tests, including the Calendar showing the Event
    - _Requirements: 2.1, 2.5, 3.1, 3.2, 3.3_

- [x] 4. Documentation
  - [x] 4.1 Update `CLAUDE.md` (the no-due-dates rule), `README.md`, `DOCS.md`
    - _Requirements: 1.1_

- [x] 5. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `scripts/check.sh` is green
