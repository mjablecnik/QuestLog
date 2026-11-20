# Implementation Plan: Note Title Field

## Overview

Add a Title_Field to the Note_Editor, let the Notes_Service name a Note from it, restore the iOS caret, handles and toolbar of the Body_Field, and stop the title of the Notes_Screen from breaking inside a word. The work lives in `lib/services/notes/`, `lib/ui/state/notes_state.dart`, `lib/ui/screens/note_editor/` and `lib/ui/screens/notes/`; it is verified with unit and widget tests, and the iOS controls are checked on the device.

## Tasks

- [x] 1. Naming in the Notes_Service
  - [x] 1.1 Add the optional `title` to `saveBody`
    - In `lib/services/notes/notes_service.dart`, a non-blank trimmed title is validated like a rename, stored as `name` and sets `autoName` false; a blank title sets `autoName` true and derives the name from the body; `null` leaves the naming as it is
    - A new Note is created when the title is non-blank or the body is not blank; a save that changes neither body nor name writes nothing
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6_

  - [x] 1.2 Test the naming
    - In `test/services/notes/notes_service_test.dart`: title set, cleared and unchanged, too long, a new Note with only a title, a new Note with nothing, saving the same content twice leaves `updatedAt` alone
    - **Property 1: Name follows the title** and **Property 2: Saving the same content writes nothing**
    - **Validates: Requirements 2.2, 2.3**

- [x] 2. Note_Editor with two fields
  - [x] 2.1 Carry the title in `NoteSaveController`
    - In `lib/ui/state/notes_state.dart`, `markChanged` takes an optional `readTitle`; `flush` passes it to `saveBody`
    - _Requirements: 2.1_

  - [x] 2.2 Build the Title_Field
    - Add `lib/ui/screens/note_editor/note_title_field.dart` and the `editor_titleHint` key to `app_cs.arb` (Název) and `app_en.arb` (Title); regenerate the localizations
    - _Requirements: 1.2, 1.3_

  - [x] 2.3 Lay out the editor
    - In `note_editor_screen.dart`, show the Title_Field above the Body_Field, fill it from `NoteNode.name` unless `autoName`, focus it for a new Note, move the focus to the Body_Field on return, follow a rename from the Node_Menu, and feed both fields to the save controller
    - _Requirements: 1.1, 1.4, 1.5, 1.6, 1.7, 2.1_

  - [x] 2.4 Restore the iOS overlays
    - Pass the iOS and Android handle and toolbar-anchor builders with the accent colour next to the desktop caret as `documentOverlayBuilders`
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [x] 2.5 Test the editor
    - In `test/ui/screens/note_editor/note_editor_screen_test.dart`: field shown and focused for a new Note, return moves the focus, a typed title becomes the name, a cleared title restores the automatic name, a title-only Note is created, the overlay list holds the iOS handles builder, a rename from the menu reaches the field
    - _Requirements: 1.1, 1.4, 1.5, 1.6, 1.7, 2.2, 2.3, 2.4, 3.2_

- [x] 3. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `flutter analyze` and the note editor, a11y and notes end-to-end tests are green

- [x] 4. Title row of the Notes_Screen
  - [x] 4.1 Measure and stack
    - In `lib/ui/screens/notes/notes_screen.dart`, `_TitleRow` measures the title and the Count_Label and shows the label under the title when they do not fit side by side, the Trash button staying at the right end
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 4.2 Test the title row
    - Widget test: Poznámky stays on one line at 390 points, the Count_Label moves under it when it does not fit, no overflow at 320 points and a text scale of 130 %
    - _Requirements: 4.1, 4.2, 4.4_

- [x] 5. Documentation
  - [x] 5.1 Bring the documents up to date
    - Update the Notes paragraph of `CLAUDE.md`, and `README.md` / `DOCS.md` where they describe how a Note is named
    - _Requirements: 2.2, 2.3_

- [x] 6. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `scripts/check.sh` is green

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP; none are marked here.
- Existing Notes with an Automatic_Name keep their text untouched and open with an empty Title_Field.
- The iOS caret, handles and Cut, Copy and Paste toolbar cannot be run in the sandbox; Martin checks them on the device (open LOW entry in `.agents/ISSUES.md`).
- Never `pkill -f` by pattern in this sandbox.
