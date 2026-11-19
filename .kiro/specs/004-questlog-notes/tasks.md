# Implementation Plan: Questlog Notes

## Overview

Add the Poznámky tab to Questlog: a tree of Folders and Notes, a WYSIWYG Markdown editor, rename, move and delete for both, and a Trash that purges itself after 30 days. The pure logic (the Note_Tree rules, note names and previews, the Trash policy) goes first in `lib/core/notes/`, then the schema v4 table in `lib/data/notes/`, then `Notes_Service` and providers in `lib/services/notes/`, then the Markdown conversion for the editor package, then the screens, sheets and widgets in `lib/ui/`. Tests are interleaved with the code they check: unit and property tests (`glados`) for the core, service and migration tests on an in-memory database, widget and golden tests for the UI, and one end-to-end scenario. The gate is `scripts/check.sh`. The visual reference is `.design/notes-preview.html`.

## Tasks

- [ ] 1. Pure notes logic (`lib/core/notes/`)
  - [ ] 1.1 Add `note_node.dart` and `note_tree.dart`
    - `NoteNode` value class with the fields from the design (`id`, `parentId`, `isFolder`, `name`, `body`, `autoName`, `createdAt`, `updatedAt`, `deletedAt`)
    - `NoteTree` with `byId`, `isVisible`, `children`, `breadcrumb`, `folderCount`, `noteCount`, `noteCountDeep`, `hasContent`, `subtreeIds`, `canMove`, `trashEntries`, `restoreTarget` and `expiredIds`
    - `children` lists Folders by `searchKey(name)` from `lib/core/calendar/calendar_dates.dart`, then Notes by `updatedAt` descending, ties by id; it never returns a Node that is not visible
    - `canMove` is false for an unknown node or target, a target that is not visible, the node itself, anything inside the node, and the current parent
    - `trashEntries` orders by `deletedAt` ascending; `expiredIds` returns expired entries plus everything inside them; the file imports no Flutter and no Drift
    - _Requirements: 2.2, 2.3, 2.4, 2.7, 2.9, 2.14, 8.3, 8.4, 8.7, 10.6, 11.4, 11.8, 11.9, 12.1, 12.4_

  - [ ] 1.2 Write tests for `NoteTree`
    - **Property 1: A move never creates a cycle** — for random trees, `canMove` is false for the node and everything inside it, and after applying any accepted move every Node still reaches the Root_Folder
    - **Property 2: Visibility follows the ancestors** — for random trees and random `deletedAt` sets a Node is visible if and only if no node on its path to the root has `deletedAt`; `children`, the counts and `breadcrumb` never contain an invisible Node
    - **Property 3: Listing order is total and stable** — Folders before Notes, Folders by `searchKey`, Notes by `updatedAt` descending, same input gives the same order
    - **Property 4: Counts match the visible tree** — `noteCountDeep` equals the number of visible Notes in the subtree; `folderCount + noteCount` equals `children(...).length`
    - **Property 5: Restore target** — `restoreTarget` is the parent when it exists and is visible, otherwise null
    - **Property 8: Purge removes exactly the expired** — `expiredIds(now)` holds every Node at least 30 days trashed plus its subtree and nothing else
    - **Validates: Requirements 2.2, 2.3, 2.4, 2.7, 2.14, 8.3, 8.7, 10.6, 11.8, 11.9, 12.1, 12.4**

  - [ ] 1.3 Add `note_title.dart`
    - `deriveNoteName(String body)`: first non-empty line, Markdown markers removed (heading `#`, quote `>`, list `-`/`*`/`1.`, checklist `- [ ]`/`- [x]`, emphasis `*`/`_`, backticks, link syntax reduced to its text), cut to 80 characters; null when there is no non-empty line
    - `notePreview(String body)`: the first two non-empty lines with the same markers removed, joined by a space, empty string when none
    - _Requirements: 2.5, 6.1, 6.2, 6.3_

  - [ ] 1.4 Write tests for note names and previews
    - **Property 6: Names derived from text** — `deriveNoteName` is null exactly when no line has non-space text, otherwise 1 to 80 characters and never starts with `#`, `>`, `-`, `*`, a backtick or a digit followed by a dot
    - Unit tests: heading, quote, checklist, bold and link lines, a 200-character line, Czech diacritics, `\r\n` line ends, blank lines first
    - **Validates: Requirements 6.1, 6.2, 6.3**

  - [ ] 1.5 Add `trash_policy.dart`
    - `trashRetention` (30 days), `daysUntilPurge(deletedAt, now)` rounded up and never below 1 while not expired, `isExpired(deletedAt, now)` true from exactly `deletedAt + 30 days`
    - _Requirements: 11.5, 11.7, 12.1, 12.3_

  - [ ] 1.6 Write tests for the Trash policy
    - **Property 7: Days until Purge** — for any deletion time and any `now` before expiry the result is between 1 and 30, is 30 at the deletion time and never increases as `now` grows
    - Unit tests at 0, 1 minute, 29 days 23 hours, 30 days exactly and 31 days
    - **Validates: Requirements 11.5, 12.3**

  - [ ] 1.7 Add `note_dates.dart`
    - `NoteDateKind noteDateKind(DateTime edited, DateTime now)` returning `today`, `yesterday`, `thisYear` or `earlier` by calendar date in local time, so the UI can pick the localized format
    - _Requirements: 2.6_

  - [ ] 1.8 Write tests for note dates
    - Unit tests around midnight, the first and last day of a year and a leap day
    - _Requirements: 2.6_

- [ ] 2. Schema version 4 (`lib/data/`)
  - [ ] 2.1 Add the table and the migration
    - Create `lib/data/notes/notes_tables.dart` with `NoteNodes` as in the design (self-referencing `parent_id` with `ON DELETE CASCADE`, name 1 to 80, body up to 100 000, two indexes)
    - Add `NoteNodes` to `@DriftDatabase` in `lib/data/database.dart`, set `schemaVersion => 4`, add `if (from < 4) await m.createTable(noteNodes);` to `onUpgrade`
    - Run `timeout 500 dart run build_runner build` in the background and poll the log; commit the regenerated `database.g.dart`; add `drift_schemas/drift_schema_v4.json` with the project's schema dump command
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

  - [ ] 2.2 Add `notes_mappers.dart`
    - `NoteNodeRow` to `NoteNode` and `NoteNode` to a Drift companion; a Folder's `body` is always empty
    - _Requirements: 13.3_

  - [ ] 2.3 Write migration and data tests
    - A v3 database with Quests, Missions and Calendar events opens as v4: the table exists and every earlier row is unchanged
    - A fresh database has the table; deleting a Folder row deletes the rows inside it, several levels deep; a name of 0 or 81 characters and a body over 100 000 characters are rejected by the CHECK constraints
    - _Requirements: 13.1, 13.2, 13.3, 13.4_

- [ ] 3. Notes service (`lib/services/notes/`)
  - [ ] 3.1 Add `notes_service.dart`
    - `NotesService` with `watchAll`, `createFolder`, `saveBody`, `rename`, `move`, `moveToTrash`, `restore`, `deleteForever`, `emptyTrash` and `purgeExpired` as in the design, every write inside `runTransaction`
    - `saveBody` creates the Note on the first non-empty body, names it with `deriveNoteName` while `autoName` is true (falling back to the `untitledName` argument), skips the write when the body is unchanged, and sets `updatedAt` from the `Clock` only when the body changed; `rename` sets `autoName` false and leaves `updatedAt`; `move` leaves `updatedAt`
    - Errors: `ValidationError('name' / 'body')`, `NotFoundError`, `InvalidStateError` as listed in the design; no call touches `XpEngine`, `app_state` or any Quest, Mission or Calendar table
    - _Requirements: 3.5, 3.7, 3.8, 4.7, 4.10, 4.11, 6.1, 6.2, 6.3, 6.4, 7.3, 7.4, 8.6, 8.7, 8.8, 10.1, 10.3, 10.5, 11.8, 11.9, 11.11, 11.12, 12.1, 14.7_

  - [ ] 3.2 Add `notes_providers.dart`
    - `notesServiceProvider`, `noteNodesProvider` (stream), `noteTreeProvider` (derived `AsyncValue<NoteTree>`) and `trashCountProvider`
    - _Requirements: 2.13, 11.1_

  - [ ] 3.3 Write service tests
    - On an in-memory database with a fake `Clock`: create Folders and Notes, first-save naming and renaming, `autoName` ending after rename, unchanged body leaves `updatedAt`, blank new body creates nothing, too long body rejected
    - Move accepted and rejected (self, descendant, trashed target); trash a Folder with content and see only one Trashed_Node; restore to the old parent and to the root when the parent is trashed or gone; `deleteForever` and `emptyTrash`; `purgeExpired` at 29 days 23 hours and at 30 days; an inner Node trashed earlier than its Folder is purged first without losing the rest
    - After every scenario `Total_XP` and the XP rows are unchanged
    - _Requirements: 3.5, 3.7, 3.8, 4.7, 4.10, 4.11, 6.1, 6.2, 6.3, 6.4, 7.3, 7.4, 8.6, 8.7, 8.8, 10.1, 10.3, 10.5, 11.8, 11.9, 11.11, 11.12, 12.1, 12.4, 14.7_

- [ ] 4. Checkpoint — core, data and service
  - Run `scripts/check.sh`; ensure all tests pass, ask the user if questions arise

- [ ] 5. Markdown conversion for the editor (`lib/ui/screens/note_editor/`)
  - [ ] 5.1 Add the editor dependency and prove it
    - Spike first: `flutter pub add appflowy_editor`, commit the updated `pubspec.yaml` and `pubspec.lock`, run `flutter analyze` and a widget test that pumps an `AppFlowyEditor` under the Questlog theme
    - Confirm on the Linux desktop run that the editor accepts text, that a Czech diacritic sentence round-trips, and that its styles can be set from `context.palette` with no literal colours; if any of this fails, switch to `super_editor` with `super_editor_markdown`, keep `note_markdown.dart` as the only adapter, and record the change in `design.md` (Overview, "Editor package")
    - The dependency update is its own commit, apart from the feature commits
    - _Requirements: 4.2, 4.8_

  - [ ] 5.2 Add `note_markdown.dart`
    - `documentFromMarkdown(String)` and `markdownFromDocument(Document)` for headings 1 to 3, bold, italic, inline code, code blocks, links, bulleted lists, checklists and quotes
    - Markdown outside the Supported_Formatting (tables, images, HTML, numbered lists unless the package supports them without loss) becomes plain paragraphs holding the original text, so it survives a round trip
    - _Requirements: 4.2, 4.7, 4.8_

  - [ ] 5.3 Write Markdown tests
    - **Property 9: Markdown round trip is stable** — for generated Markdown made of the Supported_Formatting a second pass changes nothing, and unknown constructs appear unchanged in the result
    - Unit tests: empty body, one blank line, a 100 000-character body, nested bullets, a checked and an unchecked item, a fenced ABAP block, Czech text
    - **Validates: Requirements 4.2, 4.7, 4.8**

- [ ] 6. Notes tab and list screens (`lib/ui/`)
  - [ ] 6.1 Add the icons
    - Add 24px SVGs drawn with `currentColor` to `assets/icons/`: `notes`, `folder`, `folder_plus`, `note_plus`, `move`, `undo`, `bold`, `italic`, `heading`, `list`, `checklist`, `quote`, `code`, `link`, and register them in `IconAsset` (`lib/ui/widgets/common/app_icon.dart`); `trash`, `edit`, `more`, `gear`, `plus`, `chevron_*` and `check` already exist
    - Take the shapes from `.design/notes-preview.html`
    - _Requirements: 14.2_

  - [ ] 6.2 Add the strings
    - Add every `notes_*` and `trash_*` key to `lib/l10n/app_cs.arb` (template) and `app_en.arb`: tab label, headings, counts with plurals, empty states, sheet titles and buttons, menu and swipe labels, dialogs, snackbars, Trash texts, date labels, editor messages, the untitled name and semantic labels; run the l10n generator
    - Czech uses the words of the preview (Poznámky, Složky, Nová poznámka, Nová složka, Přejmenovat, Přesunout, Přesunout do koše, Smazat, Koš, Obnovit, Navždy, Vysypat koš, Hotovo, Bez názvu)
    - _Requirements: 14.1_

  - [ ] 6.3 Make the tab bar five tabs
    - Add `ShellTab.notes` between `calendar` and `settings` in `lib/ui/screens/shell/questlog_tab_bar.dart` with `IconAsset.notes` and the new label, and build `NotesScreen` for it in `lib/ui/screens/shell/app_shell.dart`
    - Update the existing tests that expect four tabs, and the doc comments in both files
    - _Requirements: 1.1, 1.2, 1.5_

  - [ ] 6.4 Add Notes UI state
    - Add `lib/ui/state/notes_state.dart` with the kept-alive `currentFolderProvider` (null at start, so the app opens at the Root_Folder) and the `NoteSaveController` from the design
    - Add `Motion.autosave` (500 ms) to `lib/ui/theme/tokens.dart`
    - _Requirements: 1.2, 1.3, 4.4, 4.5_

  - [ ] 6.5 Add the sheets
    - `lib/ui/sheets/notes/`: `add_sheet.dart`, `name_sheet.dart` (80-character limit, disabled primary button while blank or, for rename, unchanged), `move_sheet.dart` (indented tree, current location marked and selected, unavailable Folders dimmed and not tappable, primary button disabled on the current location) and `link_sheet.dart`, all built on `questlog_sheet.dart`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 5.8, 7.1, 7.2, 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ] 6.6 Add the Notes_Screen
    - `lib/ui/screens/notes/notes_screen.dart`, `folder_row.dart`, `note_row.dart`, `breadcrumb.dart` and `lib/ui/widgets/notes/trash_button.dart` after `.design/notes-preview.html`: title and counts, Trash button with badge at the Root_Folder, Složky and Poznámky sections, Folder_Row counts, Note_Row preview and date label, Breadcrumb with the ellipsis rule, back button labelled with the parent, empty state, skeleton list, add button opening the Add_Sheet, Name_Sheet and the editor
    - The screen reads `noteTreeProvider` and `currentFolderProvider` only; it shows no Hero_Bar
    - _Requirements: 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.8, 2.9, 2.10, 2.11, 2.12, 2.13, 3.1, 3.2, 3.5, 3.6, 11.1_

  - [ ] 6.7 Add swipe actions, the Node_Menu and the shared flows
    - `node_swipe_row.dart` (`flutter_slidable`, one open row per list, Přejmenovat, Přesunout, destructive Smazat), `node_menu.dart` (same entries, delete last in the destructive colour, shown in a Folder's top bar) and `notes_actions.dart` with `renameNode`, `moveNode` and `trashNode`
    - `trashNode` shows the warning dialog with the Folder and Note counts only when `hasContent` is true, otherwise trashes at once and shows a Snackbar; moving the Current_Folder keeps it open, trashing it shows its parent
    - _Requirements: 7.1, 8.6, 9.1, 9.2, 9.3, 9.6, 9.7, 9.8, 10.1, 10.2, 10.3, 10.4_

  - [ ] 6.8 Write widget tests for the list screens
    - Sections and omitted empty section, counts, sort order, date labels, Breadcrumb and its ellipsis, back button, empty state, skeleton, add flow for a Folder, Name_Sheet limits and disabled button
    - Swipe reveals three actions and only one row stays open; menu and swipe start the same flows; Move_Sheet marks and disables correctly; the warning dialog appears for a Folder with content and not for an empty one; dismiss leaves everything unchanged
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.6, 2.9, 2.10, 2.11, 2.12, 2.13, 3.1, 3.2, 3.3, 3.4, 3.5, 7.1, 7.2, 8.1, 8.2, 8.3, 8.5, 9.1, 9.2, 9.6, 10.1, 10.2, 10.4_

- [ ] 7. Note_Editor (`lib/ui/screens/note_editor/`)
  - [ ] 7.1 Add the editor style and the save controller wiring
    - `editor_style.dart`: text, heading, quote, code, link, list and checkbox styles from `context.palette` and the text theme, caret in the accent colour
    - Complete `NoteSaveController`: debounce with `Motion.autosave`, `flush`, a failed state that keeps the text and allows retry, a validation failure for a body over 100 000 characters
    - _Requirements: 4.2, 4.4, 4.5, 4.9, 4.10, 14.2_

  - [ ] 7.2 Add the Format_Toolbar
    - `format_toolbar.dart`: bold, italic, heading (paragraph, H1, H2, H3, paragraph), bulleted list, checklist, quote, code and link buttons, 44-point targets, horizontal scroll when too wide, selected state read from the editor selection; the link button opens `showLinkSheet` and applies the link to the selection
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.10, 14.3_

  - [ ] 7.3 Add the Note_Editor screen
    - `note_editor_screen.dart`: full-screen route without the tab bar, back button with the Folder name, Node_Menu button and Hotovo, editor with the Format_Toolbar above the keyboard, flush on Hotovo, back and `AppLifecycleState.paused`, a banner with retry on a failed save and a message for a too long Note
    - A new Note is created by its first non-empty save and not at all when the text stays empty; its Node_Menu entries are disabled until then; trashing the Note from the menu closes the editor
    - _Requirements: 3.6, 3.7, 4.1, 4.3, 4.4, 4.5, 4.6, 4.9, 4.10, 5.1, 9.4, 9.5, 9.6, 9.8_

  - [ ] 7.4 Write widget tests for the editor
    - Opening shows formatted text without Markdown markers; autosave fires after 500 ms of fake time and not before; flush on Hotovo, back and pause; an empty new Note creates no row; a failed save keeps the text and shows the retry; too long text shows the message
    - Toolbar: pressed state follows the caret, bold on a selection and on an empty selection, heading cycle, list, checklist, quote and code toggles, link sheet applies a link, a checklist item toggles when tapped; Node_Menu disabled for an unsaved Note
    - _Requirements: 3.6, 3.7, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.9, 4.10, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.10, 9.5_

- [ ] 8. Checkpoint — Notes screens and editor
  - Run `scripts/check.sh`; ensure all tests pass, ask the user if questions arise

- [ ] 9. Trash
  - [ ] 9.1 Add the Trash_Screen
    - `lib/ui/screens/notes/trash_screen.dart` and `trash_row.dart` after the preview: title Koš with the count, information line, rows ordered by `trashEntries`, kind icon, origin ("z <Folder>" or "z Poznámky"), days left with the destructive colour at one day or less, Obnovit pill, swipe with Obnovit and Navždy, `confirmDestructive` for Navždy and for Vysypat koš (with the count), empty state and hidden Vysypat koš when empty; trashed Notes are not opened
    - Opening the screen calls `purgeExpired()`
    - _Requirements: 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.10, 11.11, 11.12, 11.13, 11.14, 12.2_

  - [ ] 9.2 Request the Purge from the shell
    - In `app_shell.dart` call `notesService.purgeExpired()` at start and on return from the background, next to the reconciliation triggers; catch, log and ignore any error so the splash and the tabs are never blocked
    - _Requirements: 12.2, 12.5_

  - [ ] 9.3 Write widget tests for the Trash
    - Order, labels, days left and the red remaining time at one day; Obnovit to the old parent and to the root; swipe actions; both confirmation dialogs with their counts and the cancel path; empty state; a trashed Note does not open; the badge count on the Notes_Screen follows trashing and restoring
    - Shell test: a failing Purge does not stop the app from showing the tabs
    - _Requirements: 11.1, 11.2, 11.4, 11.5, 11.7, 11.8, 11.10, 11.11, 11.12, 11.13, 11.14, 12.2, 12.5_

- [ ] 10. Cross-cutting checks and documentation
  - [ ] 10.1 Write presentation and accessibility tests
    - Extend the a11y harness to the Notes_Screen, Trash_Screen and Note_Editor: 44-point targets, semantic labels, custom semantic actions for rename, move and delete on rows, no splash or highlight on press, no clipped text at 200 % text scale, all palettes and both themes
    - Guard test that `lib/core/notes/` imports no Flutter and no Drift; the existing guard tests (no `DateTime.now`, literal colours, durations or spacing in `lib/ui`) pass with the new files
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6_

  - [ ]* 10.2 Add golden tests
    - Goldens for the Notes_Screen at the Root_Folder and inside a Folder, the Trash_Screen, and the Note_Editor, in the Blue palette dark and light, compared against `.design/notes-preview.html`
    - _Requirements: 14.2_

  - [ ] 10.3 Write the end-to-end scenario
    - In the style of `test/domain_flow_test.dart`: create a Folder and a sub-Folder, create a Note, type formatted text, leave, reopen and see it formatted, move the Note, delete the Folder with the warning, restore it from the Trash, delete a Note for good, and see that `Total_XP` never changed
    - _Requirements: 3.5, 3.6, 4.1, 4.4, 8.6, 10.3, 11.8, 11.11, 14.7_

  - [ ] 10.4 Update the documentation
    - Update `CLAUDE.md` (Status paragraph, Layout lines for `core/notes`, `data/notes`, `services/notes`, the editor package, schema v4, five tabs), `README.md` and `DOCS.md` with the Notes feature, the Trash rules and the dependency; add `.design/notes-preview.html` to the file list of `.design/DESIGN.md` and a short Notes section there
    - Retake the README screenshots affected by the fifth tab with `xvfb-run`; Martin does the iOS build and on-device checks, so note that as an open LOW entry in `.agents/ISSUES.md`
    - _Requirements: 14.1_

- [ ] 11. Checkpoint — final
  - Run `scripts/check.sh` (analyze, all tests, structure check); ensure everything is green, ask the user if questions arise

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.3", "1.5", "1.7", "2.1", "5.1", "6.1", "6.2"] },
    { "id": 1, "tasks": ["1.2", "1.4", "1.6", "1.8", "2.2", "5.2", "6.3", "6.4"] },
    { "id": 2, "tasks": ["2.3", "3.1", "5.3"] },
    { "id": 3, "tasks": ["3.2", "3.3", "9.2"] },
    { "id": 4, "tasks": ["6.5", "7.1", "7.2"] },
    { "id": 5, "tasks": ["6.6", "7.3"] },
    { "id": 6, "tasks": ["6.7", "7.4"] },
    { "id": 7, "tasks": ["6.8", "9.1"] },
    { "id": 8, "tasks": ["9.3", "10.1", "10.2"] },
    { "id": 9, "tasks": ["10.3", "10.4"] }
  ]
}
```

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP.
- Spec `004-questlog-notes` is the next spec after `003-questlog-calendar`; it overrides `003` Requirement 1 criterion 1 (five tabs instead of four) and adds schema version 4. Start from a clean working tree: the repository currently has uncommitted palette-switch changes that are not part of this spec.
- Task 5.1 is a spike on purpose: if `appflowy_editor` fails the checks, the fallback is `super_editor` with `super_editor_markdown`, and only `note_markdown.dart`, `editor_style.dart`, `format_toolbar.dart` and the editor screen change.
- Run `git config --global --add safe.directory /opt/flutter` once per sandbox. Drift codegen takes about 50 s: run `build_runner` in the background and poll the log. Edit only the `.arb` files for strings.
- The dependency update (task 5.1) is its own commit. One Conventional Commit per task, author `Martin Jablečník <martin.jablecnik@email.cz>`, no tool-attribution trailers.
- Notes award no XP and are not linked to Quests, Missions or the Calendar. Links inside a Note are stored and shown but not opened in v1; search, tags, images, tables and a Trash undo are out of scope.
- `lib/core/notes/` is pure Dart. All durations, colours and spacing in `lib/ui` come from `tokens.dart`; use `Clock`, never `DateTime.now`.
- The iOS build and every on-device check (keyboard behaviour, toolbar above the keyboard, swipe feel) are Martin's.
