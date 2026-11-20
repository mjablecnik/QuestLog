# Requirements Document

## Introduction

This spec changes how a Note is named and fixes two defects of the Notes_Tab in Questlog, the personal gamified to-do application built in Flutter (iOS primary) under `/workspace/QuestLog/`. Until now the name of a Note followed the first line of its text (`004-questlog-notes`, Requirement 6) and the Note_Editor was one WYSIWYG field. The Note_Editor now has two fields: a single-line Title_Field for the name and the WYSIWYG Body_Field for the text, so that the name is separate from the text.

The spec also fixes two defects found on a device: the Note_Editor shows no caret, no selection handles and no Cut/Copy/Paste toolbar on iOS, because the Note_Editor replaced the package's list of document overlays with the desktop caret alone; and the title Poznámky of the Notes_Screen is broken inside the word on a phone, because it shares the row with the counts and gets only half of it.

There is no schema change: the `name` and `autoName` columns of `004-questlog-notes` already hold what is needed. Images, attachments and a Markdown-preserving clipboard stay out of scope, as in `004-questlog-notes`.

## Glossary

Terms defined in `001-questlog-domain`, `002-questlog-ui`, `003-questlog-calendar` and `004-questlog-notes` (Questlog_App, Notes_Screen, Note, Note_Row, Note_Preview, Markdown_Body, Note_Editor, Format_Toolbar, Autosave_Delay, Automatic_Name, Node_Menu, Notes_Service, Design_Tokens, Effective_Language) keep their meaning here. Additional terms:

- **Title_Field**: The single-line text field at the top of the Note_Editor, in which the name of a Note is typed.
- **Body_Field**: The WYSIWYG area of the Note_Editor that shows the Markdown_Body with the Supported_Formatting.
- **Note_Title**: The trimmed text of the Title_Field.
- **Count_Label**: The text in the title row of the Notes_Screen that counts the Folders and Notes of the Current_Folder.
- **Platform_Controls**: The caret, the selection handles and the Cut, Copy and Paste toolbar that the editor package draws on iOS.

## Requirements

### Requirement 1: Title Field

**User Story:** As a user, I want a separate field for the name of a note, so that the name is not just the first line of the text.

#### Acceptance Criteria

1. THE Note_Editor SHALL show the Title_Field above the Body_Field and above the Format_Toolbar
2. WHILE the Title_Field is empty and not focused, THE Title_Field SHALL show the hint Název, or Title when the Effective_Language is English
3. THE Title_Field SHALL accept one line of at most 80 characters
4. WHEN a Note is opened, THE Title_Field SHALL show the name of the Note, unless the Note has an Automatic_Name, in which case it SHALL be empty
5. WHEN a new Note is opened, THE Note_Editor SHALL focus the Title_Field
6. WHEN the return key is pressed in the Title_Field, THE Note_Editor SHALL move the focus to the Body_Field and insert no line break
7. WHEN a Note is renamed with the Node_Menu while the Note_Editor is open, THE Title_Field SHALL show the new name

### Requirement 2: Saving and Naming

**User Story:** As a user, I want the name and the text of a note saved by themselves, so that I never have to press save.

#### Acceptance Criteria

1. WHEN the Title_Field or the Body_Field changes, THE Note_Editor SHALL save both after the Autosave_Delay, and at once when the editor is left or the app goes to the background
2. WHEN a Note is saved and the Note_Title is not empty, THE Notes_Service SHALL store the Note_Title as the name of the Note and end its Automatic_Name
3. WHEN a Note is saved and the Note_Title is empty, THE Notes_Service SHALL give the Note an Automatic_Name that follows the first non-empty line of its text, or Bez názvu (Untitled when the Effective_Language is English) when no line gives a name
4. WHEN a new Note is first saved with a non-empty Note_Title or a text that is not blank, THE Notes_Service SHALL create the Note
5. IF a new Note has an empty Note_Title and a blank text, THEN THE Notes_Service SHALL NOT create it
6. IF the Note_Title is longer than 80 characters, THEN THE Notes_Service SHALL reject the save and THE Note_Editor SHALL show the save failure banner
7. WHILE the Note has a name chosen by the user, THE Note_Preview SHALL start with the first non-empty line of its text

### Requirement 3: Caret and Platform Controls on iOS

**User Story:** As a user, I want to see where I am typing in a note and to use the system copy and paste controls, so that I can edit text on my phone.

#### Acceptance Criteria

1. WHILE the Body_Field has focus on iOS, THE Body_Field SHALL show the caret in the accent colour of the Design_Tokens
2. WHEN text is selected in the Body_Field on iOS, THE Body_Field SHALL show the selection handles in the accent colour and the Cut, Copy and Paste toolbar
3. WHILE the Title_Field has focus, THE Title_Field SHALL show the caret in the accent colour of the Design_Tokens
4. THE Body_Field SHALL show the caret on desktop as before

### Requirement 4: Title Row of the Notes Screen

**User Story:** As a user, I want the title of the Notes_Screen to be readable, so that Poznámky is never cut in the middle of the word.

#### Acceptance Criteria

1. THE Notes_Screen SHALL NOT break the title of the Current_Folder inside a word when the title fits the width of the screen on one line
2. IF the title and the Count_Label do not fit side by side on one line, THEN THE Notes_Screen SHALL show the Count_Label under the title
3. WHILE the Root_Folder is shown, THE Notes_Screen SHALL keep the Trash button at the right end of the title row
4. THE Notes_Screen SHALL keep the title row free of overflow at a screen width of 320 points and a text scale of 130 %
