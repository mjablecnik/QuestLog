# Requirements Document

## Introduction

This spec adds **notes** to Questlog, the personal gamified to-do application built in Flutter (iOS primary) under `/workspace/QuestLog/`. Notes are a fifth bottom tab, **Poznámky**. The tab shows a list of Folders and Notes; the user creates Folders and sub-Folders to organise Notes, and a Note is the last level: opening it shows its text in a WYSIWYG editor. The text of a Note is Markdown, stored as Markdown, and shown formatted while it is edited. Folders and Notes can be renamed, moved to another Folder and deleted; deleting moves them to a Trash, from which they can be restored and in which they are removed for good after 30 days. The tab shows no Hero_Bar. Notes are not linked to Quests, Missions or the Calendar and award no XP.

All data lives in the local Questlog_Database (schema version 4); there is no server, no account and no synchronisation. The visual reference is the approved preview `.design/notes-preview.html`, drawn in the blue palette, the only palette of the app; every colour comes from the Design_Tokens and works in both themes.

Out of scope: search inside Notes, tags, attachments and images, tables, opening links from a Note, links between Notes, manual ordering of Folders or Notes, duplicating a Node, sharing and export, reminders, XP for Notes, and a Trash undo other than restoring from the Trash. This spec overrides `003-questlog-calendar` Requirement 1 criterion 1 (four tabs): the app has five tabs, with Poznámky between Kalendář and Nastavení.

## Glossary

Terms defined in `001-questlog-domain`, `002-questlog-ui` and `003-questlog-calendar` (Questlog_App, Questlog_Database, App_Shell, Hero_Bar, Settings_Screen, Design_Tokens, Effective_Language, Clock, Snackbar) keep their meaning here. Additional terms:

- **Notes_Tab**: The Poznámky tab of the App_Shell.
- **Notes_Screen**: The screen of the Notes_Tab, listing the content of the Current_Folder.
- **Node**: A Folder or a Note.
- **Folder**: A named Node that contains other Nodes. It has a name of 1 to 80 characters.
- **Note**: A named Node that has a Markdown_Body and cannot contain other Nodes.
- **Root_Folder**: The top level of the Notes_Screen, shown with the title Poznámky. It is not stored as a row; a Node whose parent is none lies in the Root_Folder.
- **Current_Folder**: The Folder (or the Root_Folder) whose content the Notes_Screen shows.
- **Folder_Row**: The row of one Folder in the Notes_Screen.
- **Note_Row**: The row of one Note in the Notes_Screen, with a Note_Preview and a last-edited date.
- **Note_Preview**: The first two non-empty lines of a Markdown_Body with the Markdown markers removed.
- **Breadcrumb**: The path of Folders from the Root_Folder to the Current_Folder, shown above the title.
- **Markdown_Body**: The text of a Note, stored as Markdown of at most 100 000 characters.
- **Supported_Formatting**: Headings of level 1 to 3, bold, italic, inline code, code blocks, links, bulleted lists, checklists and block quotes.
- **Note_Editor**: The full-screen WYSIWYG editor of one Note's text. It shows the Supported_Formatting formatted and no Markdown markers.
- **Format_Toolbar**: The bar of formatting buttons above the keyboard in the Note_Editor.
- **Autosave_Delay**: The pause of 500 ms after the last change of the text after which the Note_Editor saves.
- **Automatic_Name**: The state of a Note whose name follows the first non-empty line of its text. It ends when the Note is renamed by the user.
- **Add_Sheet**: The bottom sheet opened by the add button with the choices Nová poznámka and Nová složka.
- **Name_Sheet**: The bottom sheet with one name field, used to create a Folder and to rename a Node.
- **Move_Sheet**: The bottom sheet showing the tree of Folders in which the user picks the destination of a Node.
- **Node_Menu**: The "···" menu with Přejmenovat, Přesunout and Přesunout do koše, shown in a Folder's top bar and in the Note_Editor.
- **Swipe_Actions**: The actions revealed by swiping a Folder_Row or Note_Row to the left: Přejmenovat, Přesunout and Smazat.
- **Trash**: The place that keeps deleted Nodes until they are restored or purged.
- **Trashed_Node**: A Node that was deleted by the user and has a deletion time. A Folder is trashed together with everything inside it as one Trashed_Node.
- **Trash_Screen**: The screen listing the Trashed_Nodes.
- **Trash_Retention**: 30 days, counted from the deletion time of a Trashed_Node.
- **Purge**: The permanent deletion of every Trashed_Node whose Trash_Retention has passed, together with what is inside it.
- **Notes_Service**: The component that creates, edits, moves, trashes, restores and purges Nodes and streams the tree.
- **Note_Tree**: The pure-Dart view of all stored Nodes with the rules for listing, counting, moving and trashing.

## Requirements

### Requirement 1: Notes Tab

**User Story:** As a user, I want a Poznámky tab in the bottom bar, so that I can reach my notes with one tap.

#### Acceptance Criteria

1. THE App_Shell SHALL offer five tabs in a bottom tab bar, in this order: Questy, Mise, Kalendář, Poznámky, Nastavení
2. WHEN the Poznámky tab is tapped, THE App_Shell SHALL show the Notes_Screen with the Current_Folder it had when the user left it
3. WHEN the Questlog_App starts, THE Notes_Screen SHALL show the Root_Folder
4. THE Notes_Screen SHALL NOT show a Hero_Bar
5. THE Poznámky tab SHALL show no highlight, ripple or frame while it is pressed, like the other tabs
6. IF the Current_Folder is no longer visible when the Notes_Screen is shown, THEN THE Notes_Screen SHALL show the Root_Folder

### Requirement 2: Browsing Folders and Notes

**User Story:** As a user, I want to see the Folders and Notes of a Folder and open them, so that I can find a Note by where I put it.

#### Acceptance Criteria

1. THE Notes_Screen SHALL show the name of the Current_Folder as its title, and Poznámky for the Root_Folder
2. THE Notes_Screen SHALL show the number of Folders and the number of Notes directly inside the Current_Folder next to the title
3. THE Notes_Screen SHALL list the Folders under the heading Složky, above the Notes under the heading Poznámky, and SHALL omit the heading of a section that has no Nodes
4. THE Folder_Row SHALL show the Folder name, the number of Folders directly inside it, the number of Notes at any depth inside it, and a chevron
5. THE Note_Row SHALL show the Note name, its Note_Preview and the date of its last edit
6. THE Note_Row SHALL show the last-edited date as "dnes" for today, "včera" for yesterday, as day and month for the current year, and as day, month and year for earlier years
7. THE Notes_Screen SHALL list Folders in alphabetical order of their names, ignoring case and diacritics, and Notes with the most recently edited first
8. WHEN a Folder_Row is tapped, THE Notes_Screen SHALL make that Folder the Current_Folder
9. WHILE the Current_Folder is a Folder, THE Notes_Screen SHALL show the Breadcrumb from Poznámky to that Folder, with every segment except the last one tappable to make it the Current_Folder
10. IF the Breadcrumb does not fit the width, THEN THE Notes_Screen SHALL shorten its middle segments to an ellipsis and keep the first and the last two segments
11. WHILE the Current_Folder is a Folder, THE Notes_Screen SHALL show a back button labelled with the name of its parent, and WHEN it is tapped, THE Notes_Screen SHALL make the parent the Current_Folder
12. IF the Current_Folder contains no Nodes, THEN THE Notes_Screen SHALL show an empty state that invites the user to add a Note or a Folder
13. WHILE the Nodes are being read for the first time, THE Notes_Screen SHALL show a skeleton list
14. THE Notes_Screen SHALL NOT show a Trashed_Node, nor anything inside a Trashed_Node
15. WHEN the system back action is performed while the Current_Folder is a Folder, THE Notes_Screen SHALL make the parent the Current_Folder instead of leaving the tab

### Requirement 3: Creating Folders and Notes

**User Story:** As a user, I want to add a Folder or a Note where I am, so that I can organise my notes as I write them.

#### Acceptance Criteria

1. WHEN the add button is tapped, THE Notes_Screen SHALL open the Add_Sheet with the choices Nová poznámka and Nová složka and a line naming the Current_Folder as the place of creation
2. WHEN Nová složka is chosen, THE Notes_Screen SHALL open the Name_Sheet titled Nová složka with an empty, focused name field
3. WHILE the trimmed name in the Name_Sheet is empty, THE Name_Sheet SHALL keep its primary button disabled
4. THE Name_Sheet SHALL NOT accept more than 80 characters in the name field
5. WHEN the primary button of the Name_Sheet is pressed for a new Folder, THE Notes_Service SHALL create the Folder in the Current_Folder and THE Notes_Screen SHALL show it in the list
6. WHEN Nová poznámka is chosen, THE Notes_Screen SHALL open the Note_Editor on an empty Note that belongs to the Current_Folder
7. IF the Note_Editor is left while the text of a new Note is empty, THEN THE Notes_Service SHALL NOT create a Note
8. THE Notes_Service SHALL allow two Nodes in the same Folder to have the same name

### Requirement 4: Note Editor

**User Story:** As a user, I want to write a Note in an editor that shows the formatting while I type, so that I do not have to read Markdown markers.

#### Acceptance Criteria

1. WHEN a Note_Row is tapped, THE Notes_Screen SHALL open the Note_Editor on that Note with its Markdown_Body shown formatted
2. THE Note_Editor SHALL show the Supported_Formatting as formatted text and SHALL NOT show Markdown markers
3. THE Note_Editor SHALL be a full-screen view without the tab bar, with a back button labelled with the name of the Folder, the Node_Menu button and a Hotovo button
4. WHILE the text of a Note is being edited, THE Note_Editor SHALL save the Markdown_Body after the Autosave_Delay without any action by the user
5. WHEN the Hotovo button or the back button is pressed, THE Note_Editor SHALL save any unsaved change before it closes
6. WHEN the Questlog_App goes to the background, THE Note_Editor SHALL save any unsaved change
7. THE Notes_Service SHALL store the text of a Note as Markdown
8. IF a Markdown_Body contains Markdown outside the Supported_Formatting, THEN THE Note_Editor SHALL show it as plain text and SHALL keep it in the saved Markdown_Body
9. IF a save fails, THEN THE Note_Editor SHALL keep the text on the screen and show a message with a retry action
10. IF a Markdown_Body is longer than 100 000 characters, THEN THE Notes_Service SHALL reject the save with a validation error and THE Note_Editor SHALL tell the user that the Note is too long
11. WHEN the text of a Note is saved unchanged, THE Notes_Service SHALL NOT change the last-edited date of the Note

### Requirement 5: Format Toolbar

**User Story:** As a user, I want formatting buttons above the keyboard, so that I can format text without knowing Markdown.

#### Acceptance Criteria

1. WHILE the keyboard is shown in the Note_Editor, THE Format_Toolbar SHALL be shown directly above it
2. THE Format_Toolbar SHALL offer buttons for bold, italic, heading, bulleted list, checklist, quote, code and link
3. WHILE the text at the caret has a format, THE Format_Toolbar SHALL show the button of that format as selected
4. WHEN a button for bold, italic or code is pressed while text is selected, THE Note_Editor SHALL apply the format to the selection, or remove it when the whole selection already has it
5. WHEN a button for bold, italic or code is pressed while no text is selected, THE Note_Editor SHALL apply the format to the text typed next
6. WHEN the heading button is pressed, THE Note_Editor SHALL change the current block through heading 1, heading 2, heading 3 and back to a paragraph, one step per press
7. WHEN the button for bulleted list, checklist, quote or code is pressed, THE Note_Editor SHALL turn the current block into that kind of block, or back into a paragraph when it already is
8. WHEN the link button is pressed, THE Note_Editor SHALL open a sheet asking for an address and, when confirmed, apply the link to the selected text
9. IF the Format_Toolbar does not fit the screen width, THEN THE Format_Toolbar SHALL scroll horizontally
10. WHEN a checklist item is tapped, THE Note_Editor SHALL toggle its checked state

### Requirement 6: Note Names

**User Story:** As a user, I want a new Note to be named after what I wrote, so that I do not have to name every Note first.

#### Acceptance Criteria

1. WHEN a new Note is first saved, THE Notes_Service SHALL name it after the first non-empty line of its text, without Markdown markers, cut to 80 characters
2. WHILE a Note has an Automatic_Name, WHEN its text is saved, THE Notes_Service SHALL update its name from the first non-empty line of the text
3. IF the text of a Note has no non-empty line, THEN THE Notes_Service SHALL name it Bez názvu, or Untitled when the Effective_Language is English
4. WHEN a Note is renamed by the user, THE Notes_Service SHALL end its Automatic_Name and keep the chosen name when the text changes

### Requirement 7: Renaming

**User Story:** As a user, I want to rename a Folder or a Note, so that its name keeps matching what is in it.

#### Acceptance Criteria

1. WHEN Přejmenovat is chosen for a Node, THE Notes_Screen SHALL open the Name_Sheet titled Přejmenovat with the current name filled in and the name field focused
2. WHILE the trimmed name is empty or equal to the current name, THE Name_Sheet SHALL keep its primary button disabled
3. WHEN the primary button is pressed, THE Notes_Service SHALL store the new trimmed name of the Node
4. THE Notes_Service SHALL NOT change the last-edited date of a Note when it is renamed

### Requirement 8: Moving

**User Story:** As a user, I want to move a Folder or a Note into another Folder, so that I can reorganise my notes.

#### Acceptance Criteria

1. WHEN Přesunout is chosen for a Node, THE Notes_Screen SHALL open the Move_Sheet showing Poznámky and all Folders as a tree, indented by depth, with the name of the Node under the title
2. THE Move_Sheet SHALL mark the Folder that currently contains the Node as its current location and select it at the start
3. WHILE a Folder is being moved, THE Move_Sheet SHALL show that Folder and the Folders inside it as unavailable
4. THE Move_Sheet SHALL NOT show a Trashed_Node
5. WHILE the selected destination is the current location, THE Move_Sheet SHALL keep its primary button disabled
6. WHEN the primary button is pressed, THE Notes_Service SHALL make the selected destination the parent of the Node, and THE Notes_Screen SHALL show the Node in the destination and no longer in the old Folder
7. IF the destination is the Node itself, a Folder inside it, or a Trashed_Node, THEN THE Notes_Service SHALL reject the move and leave all Nodes unchanged
8. THE Notes_Service SHALL NOT change the last-edited date of a Note when it is moved

### Requirement 9: Actions Under Swipe and Menu

**User Story:** As a user, I want to reach rename, move and delete both by swiping a row and from the menu of an open Folder or Note, so that I can use whichever is closer.

#### Acceptance Criteria

1. WHEN a Folder_Row or a Note_Row is swiped to the left, THE Notes_Screen SHALL reveal the Swipe_Actions Přejmenovat, Přesunout and Smazat, the last one in the destructive colour
2. THE Notes_Screen SHALL keep at most one row with revealed Swipe_Actions at a time
3. WHILE the Current_Folder is a Folder, THE Notes_Screen SHALL show the Node_Menu button in its top bar, offering Přejmenovat, Přesunout and Přesunout do koše for the Current_Folder
4. THE Note_Editor SHALL show the Node_Menu button next to Hotovo, offering Přejmenovat, Přesunout and Přesunout do koše for the Note
5. WHILE a new Note has not been saved yet, THE Note_Editor SHALL show the entries of the Node_Menu as disabled
6. THE Node_Menu and the Swipe_Actions SHALL start the same rename, move and delete flows as each other
7. WHEN the Current_Folder is moved from its Node_Menu, THE Notes_Screen SHALL keep showing it, with an updated Breadcrumb
8. WHEN the Current_Folder or the Note open in the Note_Editor is moved to the Trash from its Node_Menu, THE Notes_Screen SHALL show the parent Folder, or THE Note_Editor SHALL close

### Requirement 10: Moving to the Trash

**User Story:** As a user, I want deleting to be safe, so that a mistake does not lose my notes.

#### Acceptance Criteria

1. WHEN Smazat or Přesunout do koše is chosen for a Note or for a Folder with no Nodes inside, THE Notes_Service SHALL move it to the Trash without a confirmation dialog, and THE Notes_Screen SHALL show a Snackbar saying so
2. WHEN Smazat or Přesunout do koše is chosen for a Folder that contains Nodes, THE Notes_Screen SHALL show a warning dialog naming the Folder, stating how many Folders and Notes are inside it and that they will be removed for good after 30 days
3. WHEN the button Přesunout do koše of the warning dialog is pressed, THE Notes_Service SHALL move the Folder and everything inside it to the Trash
4. WHEN the warning dialog is dismissed or Zrušit is pressed, THE Notes_Service SHALL leave all Nodes unchanged
5. WHEN a Node is moved to the Trash, THE Notes_Service SHALL store the time of the Clock as its deletion time
6. WHILE a Folder is a Trashed_Node, THE Questlog_App SHALL NOT show anything inside it on the Notes_Screen or in the Move_Sheet

### Requirement 11: Trash Screen

**User Story:** As a user, I want to see what is in the Trash and get it back or delete it for good, so that I stay in control of my notes.

#### Acceptance Criteria

1. WHILE the Current_Folder is the Root_Folder, THE Notes_Screen SHALL show a Trash button with the number of Trashed_Nodes as a badge, and no badge when there are none
2. WHEN the Trash button is tapped, THE Notes_Screen SHALL open the Trash_Screen titled Koš with the number of Trashed_Nodes
3. THE Trash_Screen SHALL show an information line saying that Nodes stay in the Trash for 30 days and that a Folder is restored with its content
4. THE Trash_Screen SHALL list the Trashed_Nodes with the one nearest to its Purge first
5. THE Trash_Screen SHALL show for each Trashed_Node its name, an icon of its kind, the name of the Folder it came from (or Poznámky), and the number of days left until its Purge
6. THE Trash_Screen SHALL show a Folder together with the number of Notes inside it
7. WHILE a Trashed_Node has one day or less left, THE Trash_Screen SHALL show its remaining time in the destructive colour
8. WHEN Obnovit is pressed for a Trashed_Node, THE Notes_Service SHALL restore it to the Folder it came from
9. IF the Folder a Trashed_Node came from no longer exists or is itself trashed, THEN THE Notes_Service SHALL restore the Trashed_Node to the Root_Folder
10. WHEN a row of the Trash_Screen is swiped to the left, THE Trash_Screen SHALL reveal the actions Obnovit and Navždy
11. WHEN Navždy is chosen, THE Trash_Screen SHALL show a confirmation dialog naming the Node and stating that it cannot be restored, and WHEN it is confirmed, THE Notes_Service SHALL delete the Node and everything inside it permanently
12. WHEN Vysypat koš is pressed, THE Trash_Screen SHALL show a confirmation dialog with the number of Trashed_Nodes, and WHEN it is confirmed, THE Notes_Service SHALL delete all Trashed_Nodes and everything inside them permanently
13. IF the Trash is empty, THEN THE Trash_Screen SHALL show an empty state and SHALL hide the Vysypat koš button
14. THE Trash_Screen SHALL NOT open a trashed Note for reading or editing
15. WHEN a Trashed_Node is restored or deleted permanently, THE Trash_Screen SHALL show a Snackbar saying so

### Requirement 12: Trash Retention and Purge

**User Story:** As a user, I want the Trash to clean itself, so that I never have to empty it by hand.

#### Acceptance Criteria

1. THE Notes_Service SHALL delete a Trashed_Node and everything inside it permanently once the Trash_Retention has passed since its deletion time
2. THE App_Shell SHALL request a Purge when the Questlog_App starts, when it returns from the background and when the Trash_Screen opens
3. THE Notes_Service SHALL compute the days left until Purge from the Clock, rounded up, so that a Trashed_Node shows 30 on the day it was deleted and never less than 1 before it is purged
4. THE Purge SHALL NOT delete a Node that is not a Trashed_Node, unless it lies inside a Trashed_Node that is being purged
5. IF a Purge fails, THEN THE App_Shell SHALL continue to show the app and try again at the next Purge request

### Requirement 13: Storage

**User Story:** As a user, I want my notes stored on the device with the rest of my data, so that they work offline and survive app updates.

#### Acceptance Criteria

1. THE Questlog_Database SHALL be at schema version 4 and store all Nodes in one table `note_nodes`
2. WHEN a database of schema version 3 is opened, THE Questlog_Database SHALL add the table `note_nodes` and SHALL NOT change any existing data
3. THE Questlog_Database SHALL store the parent of a Node as optional, with no parent meaning the Root_Folder
4. WHEN the row of a Folder is deleted, THE Questlog_Database SHALL delete the rows of everything inside it
5. THE Questlog_App SHALL keep a dump of schema version 4 in `drift_schemas/`

### Requirement 14: Presentation and Accessibility

**User Story:** As a user, I want Notes to look and behave like the rest of Questlog, so that the app feels like one thing.

#### Acceptance Criteria

1. THE Questlog_App SHALL show every text of the Notes in Czech or English according to the Effective_Language
2. THE Questlog_App SHALL take all colours, sizes, spacing and durations of the Notes screens from the Design_Tokens, and they SHALL read correctly in both themes
3. THE Notes_Screen, the Trash_Screen and the Note_Editor SHALL give every control a touch target of at least 44 by 44 points
4. THE Notes_Screen, the Trash_Screen and the Note_Editor SHALL show no splash, highlight or hover tint while a control is pressed
5. THE Notes_Screen and the Trash_Screen SHALL offer the actions of a row to assistive technology as custom actions and SHALL give each control a semantic label
6. WHILE the text scale is enlarged, THE Notes_Screen, the Trash_Screen and the Note_Editor SHALL NOT clip text
7. THE Questlog_App SHALL NOT award XP for creating, editing, moving or deleting a Node
