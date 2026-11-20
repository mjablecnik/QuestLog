# Requirements Document

## Introduction

This spec lets the user read a Note that is in the Trash of Questlog (Flutter, iOS primary, `/workspace/QuestLog/`) before deciding whether to restore it. Until now the Trash_Screen listed a Trashed_Node with its name and a Obnovit button, and the row could not be opened, so the only way to see what a deleted Note held was to restore it.

A Trashed_Node that is a Note can now be opened in a read-only Trash_Preview that shows its name and its text formatted as in the Note_Editor, with a Obnovit button. A Folder row stays as it is. There is no schema change and the Trash_Retention does not change; looking at a Note does not restore it or postpone its Purge.

## Glossary

Terms defined in `001-questlog-domain`, `002-questlog-ui`, `003-questlog-calendar`, `004-questlog-notes` and `005-questlog-note-title` (Questlog_App, Notes_Service, Note, Folder, Trashed_Node, Trash_Screen, Trash_Retention, Purge, Note_Editor, Markdown_Body, Supported_Formatting, Format_Toolbar, Snackbar, Design_Tokens) keep their meaning here. Additional terms:

- **Trash_Preview**: The full-screen, read-only view of one Trashed_Node that is a Note, with its name, its Markdown_Body formatted and a Obnovit button.
- **Preview_Body**: The part of the Trash_Preview that shows the Markdown_Body with the Supported_Formatting and no Markdown markers.

## Requirements

### Requirement 1: Opening a Trashed Note

**User Story:** As a user, I want to open a note in the Trash, so that I can see what it holds before I restore or lose it.

#### Acceptance Criteria

1. WHEN a Trashed_Node that is a Note is tapped in the Trash_Screen, THE Trash_Screen SHALL open the Trash_Preview of that Note
2. THE Trash_Preview SHALL show the name of the Note at the top, a back button that closes it, and the Obnovit button
3. THE Preview_Body SHALL show the Markdown_Body formatted like the Note_Editor shows it
4. IF the Markdown_Body is empty, THEN THE Preview_Body SHALL show the text Prázdná poznámka, or Empty note when the Effective_Language is English
5. WHEN a Trashed_Node that is a Folder is tapped in the Trash_Screen, THE Trash_Screen SHALL do nothing, as before
6. THE Trash_Screen SHALL tell a screen reader that a Trashed_Node that is a Note can be opened

### Requirement 2: Read-Only

**User Story:** As a user, I want the preview to be only for reading, so that I cannot change a deleted note by accident.

#### Acceptance Criteria

1. THE Trash_Preview SHALL NOT show a caret, the Format_Toolbar or a keyboard, and SHALL NOT change the Markdown_Body or the name of the Note
2. WHEN a checklist item is tapped in the Preview_Body, THE Preview_Body SHALL leave its checked state as it is
3. THE Trash_Preview SHALL allow the text to be scrolled when it is longer than the screen
4. THE Notes_Service SHALL NOT change the deletion time or the last-edited date of a Note because its Trash_Preview was opened

### Requirement 3: Restoring from the Preview

**User Story:** As a user, I want to restore the note straight from the preview, so that I do not have to go back to the list.

#### Acceptance Criteria

1. WHEN the Obnovit button of the Trash_Preview is pressed, THE Notes_Service SHALL restore the Note as the Trash_Screen does, and THE Trash_Preview SHALL close and the Trash_Screen SHALL show the Snackbar Obnovit confirmation
2. IF the Note is no longer a Trashed_Node while the Trash_Preview is open, THEN THE Trash_Preview SHALL close
