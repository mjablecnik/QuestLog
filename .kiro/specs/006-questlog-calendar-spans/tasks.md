# Implementation Plan: Calendar Spans

## Overview

Draw an Event_Occurrence that lasts several days as one continuous Span_Bar per Week_Row in the Month_View of `lib/ui/screens/calendar/`. A pure `layoutWeek` assigns Lanes, the Week_Row draws the bars above the day cells, and the Event_Chip gets square ends. It is verified with unit, property and widget tests.

## Tasks

- [x] 1. Lane layout
  - [x] 1.1 Write `layoutWeek` and `lanesShown`
    - Add `lib/ui/screens/calendar/week_lanes.dart`: segments with the column range, the Continuing_End flags and the lowest free Lane, in the order more dates, all-day before timed, start minute, name; `lanesShown` returns all Lanes up to three, otherwise two, fewer when the room is small
    - _Requirements: 1.1, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 1.2 Test the layout
    - Unit tests for columns, flags, order and `lanesShown`; property tests with `glados`
    - **Property 1: Lanes never overlap** and **Property 2: A bar covers exactly the days of the occurrence in the week**
    - **Validates: Requirements 1.1, 1.4, 1.5, 2.1, 2.2**

- [x] 2. Month_View
  - [x] 2.1 Square ends on the Event_Chip
    - In `lib/ui/widgets/calendar/event_chip.dart` add `continuesBefore` and `continuesAfter`, making that end square
    - _Requirements: 1.4, 1.6_

  - [x] 2.2 Draw the Week_Rows
    - In `lib/ui/screens/calendar/month_grid.dart` build each Week_Row as the row of cells with the bar layer above it (no pointer events, no semantics), pass each cell the Lanes shown and the hidden count, keep the cell label and the tap
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 2.1, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3_

  - [x] 2.3 Update and extend the calendar tests
    - In `test/ui/screens/calendar/calendar_screen_test.dart` find chips by position inside a cell; add tests for a two-day bar, a bar over the week boundary, one Lane per bar, "+N", a tap on a bar, and no overflow at 320 points and a text scale of 130 %
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.4, 3.1, 3.3_

- [x] 3. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `flutter analyze` and the calendar tests are green

- [x] 4. Documentation
  - [x] 4.1 Bring the documents up to date
    - Update the Calendar paragraph of `CLAUDE.md` and `DOCS.md` where they describe how a multi-day event is drawn
    - _Requirements: 1.1_

- [x] 5. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `scripts/check.sh` is green

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP; none are marked here.
- This spec overrides `003-questlog-calendar` Requirement 3 criterion 1 for an occurrence that touches more than one date.
- The bar layer must not take pointer events or semantics, or a tap would miss the cell and a screen reader would read the bars twice.
- Never `pkill -f` by pattern in this sandbox.
