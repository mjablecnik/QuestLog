# Implementation Plan: Address History

## Overview

Remember saved addresses for 30 days of non-use and suggest them in the Event_Form.

## Tasks

- [x] 1. Data and service
  - [x] 1.1 Table, migration and pure rules
    - Add `CalendarAddresses` to `calendar_tables.dart`, schema 5 with `createTable`, regenerate Drift code, dump `drift_schema_v5.json`; add `lib/core/calendar/address_history.dart`
    - _Requirements: 1.1, 1.2, 1.3, 2.2_

  - [x] 1.2 Service
    - Remember in `create` and `update`, add `suggestAddresses` and `purgeExpiredAddresses`, purge at start in `app_shell.dart`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3_

  - [x]* 1.3 Property and service tests
    - Retention edge with a fake clock, one entry per address, limit, newest first, deleted Event keeps its address, migration from schema 4
    - **Validates: Requirements 1.2, 1.3, 1.4, 2.1, 2.2, 2.3**

- [x] 2. Checkpoint — Ensure all tests pass, ask the user if questions arise.

- [x] 3. Form
  - [x] 3.1 Suggestion rows under the Address field
    - `CalendarTextField.onFocusChange`, `address_suggestions.dart`, wiring in `event_form_screen.dart`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [x] 3.2 Widget tests of the form
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 4. Documentation
  - [x] 4.1 Update `CLAUDE.md`, `README.md`, `DOCS.md`
    - _Requirements: 1.1_

- [x] 5. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `scripts/check.sh` is green
