# Implementation Plan: Trash Preview

## Overview

Let the user open a trashed Note in a read-only preview from the Trash_Screen and restore it from there. The work lives in `lib/ui/screens/notes/` and `lib/ui/screens/note_editor/note_task_component.dart` and is verified with widget tests.

## Tasks

- [x] 1. Read-only pieces
  - [x] 1.1 Read-only mode of the task component
    - In `lib/ui/screens/note_editor/note_task_component.dart` add the `NoteTaskComponentBuilder.readOnly` constructor, built on the package's `ReadOnlyTaskComponentBuilder`, whose view model has no `setComplete`
    - _Requirements: 2.2_

  - [x] 1.2 Tappable Trash_Row
    - In `lib/ui/screens/notes/trash_row.dart` add an optional `onTap` and the screen reader hint for a Note; add the string keys for the hint and the empty text to `app_cs.arb` and `app_en.arb` and regenerate the localizations
    - _Requirements: 1.4, 1.6_

- [x] 2. The preview
  - [x] 2.1 Build `TrashPreviewScreen`
    - Add `lib/ui/screens/notes/trash_preview_screen.dart` with `openTrashPreview`: the name, back, the Obnovit pill, the `SuperReader` with the editor's stylesheet, the empty text, and closing when the Note is no longer a Trashed_Node
    - _Requirements: 1.2, 1.3, 1.4, 2.1, 2.3, 3.1, 3.2_

  - [x] 2.2 Open it from the Trash_Screen
    - In `lib/ui/screens/notes/trash_screen.dart` pass `onTap` for a Note row only, show the confirmation Snackbar when the preview restored the Note
    - _Requirements: 1.1, 1.5, 3.1_

  - [x] 2.3 Test the preview
    - Widget tests in `test/ui/screens/notes/trash_screen_test.dart`: open a trashed Note, formatted and read-only, checklist tap changes nothing, empty text, Obnovit restores and closes, a Purge closes it, a Folder row opens nothing, deletion time and last-edited date unchanged
    - _Requirements: 1.1, 1.3, 1.4, 1.5, 2.1, 2.2, 2.4, 3.1, 3.2_

- [x] 3. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `flutter analyze` and the notes tests are green

- [x] 4. Documentation
  - [x] 4.1 Bring the documents up to date
    - Update `CLAUDE.md`, `README.md` and `DOCS.md` where they describe the Trash
    - _Requirements: 1.1_

- [x] 5. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `scripts/check.sh` is green

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP; none are marked here.
- Opening a preview never restores a Note and never touches its dates.
- Never `pkill -f` by pattern in this sandbox.
