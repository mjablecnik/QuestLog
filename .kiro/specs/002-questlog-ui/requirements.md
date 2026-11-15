# Requirements Document

## Introduction

This spec defines the user interface of Questlog, the personal gamified to-do application built in Flutter (iOS primary) under `/workspace/questlog/`. It builds on `001-questlog-domain`, which provides every service, rule and stream the screens use; the UI contains no business logic of its own. The visual contract is `.design/DESIGN.md` together with the artboards in `.design/artboards/` (direction "Guild Board", dark by default, light variant "Daylight", typeface Figtree).

The application has two tabs, **Questy** (the quest board) and **Mise** (missions), reached from a hero bar that shows the hero's Level and XP and carries the gear that opens **Nastavení** (settings). Quests are created, edited, completed, reordered by drag and deleted on the board; Missions are created and completed from the Missions tab and their detail screen; recurring rules and the temporary display-font switch live in Settings. All user-facing text is Czech or English; all code, identifiers and this document are English.

Out of scope: a history screen (the data is retained by spec 001), notifications, projects, due dates, streaks, onboarding, and the iOS build and App Store steps, which the user performs.

## Glossary

Terms defined in `001-questlog-domain` (Quest, Mission, Instance, Difficulty, Mission_Bonus, Total_XP, Level, Level_Threshold, Level_Progress, Recurring_Rule, Cadence, Anchor_Date, Occurrence, Next_Occurrence, Posting, Reconciliation, Day_Start, Board_Day, Today, History_Query, Clock, and the services Quest_Service, Mission_Service, Xp_Engine, Recurrence_Service, Settings_Service) keep their meaning here. Additional terms:

- **Questlog_App**: The Flutter application at `/workspace/questlog/`.
- **App_Shell**: The root widget that applies theme and locale, hosts the tabs and runs Reconciliation.
- **Hero_Bar**: The header shown on the Board_Screen and Missions_Screen with the Level badge, hero name, Level_Progress and the Settings gear.
- **Board_Screen**: The Questy tab listing open Quests and the Quests done on the current Board_Day.
- **Missions_Screen**: The Mise tab listing open Missions and the section "Dokončeno dnes" of Missions completed on the current Board_Day.
- **Mission_Detail_Screen**: The screen showing one Mission with all of its Quests.
- **Settings_Screen**: The screen reached from the gear, containing profile, language, theme, recurring rules, the display-font picker and the About footer.
- **Quest_Sheet**: The bottom sheet for creating or editing a Quest.
- **Mission_Sheet**: The bottom sheet for creating or editing a Mission.
- **Rule_Sheet**: The bottom sheet for creating, editing or deleting a Recurring_Rule.
- **Font_Sheet**: The bottom sheet of the temporary display-font picker.
- **Reward_Card**: The parchment card over a scrim that reports XP earned for a completed Quest or Mission, and a Level-up.
- **Quest_Card**: The list row for one Quest with check circle, title, meta row and XP.
- **Mission_Card**: The list row for one Mission with progress ring, title, remaining XP and bonus.
- **Design_Tokens**: The colour, typography, spacing, radius, elevation and motion constants in `lib/ui/theme/`, mirroring `.design/theme.css`.
- **Display_Font**: The typeface used for titles and XP figures, one of the six offered by Settings_Service.
- **Effective_Language**: The language actually shown, `cs` or `en`, resolved by Settings_Service from the language setting and the device language.

## Requirements

### Requirement 1: App Shell and Navigation

**User Story:** As a user, I want to land on my quest board and move between quests, missions and settings with one tap, so that the app is quick to use.

#### Acceptance Criteria

1. WHEN the Questlog_App starts, THE App_Shell SHALL show a branded splash until the Questlog_Database is open and the first Reconciliation has finished, and SHALL then show the Board_Screen
2. THE App_Shell SHALL offer exactly two tabs, Questy and Mise, in a bottom tab bar, and SHALL NOT offer a third tab
3. THE Board_Screen and the Missions_Screen SHALL each show the Hero_Bar with the Settings gear at its right end
4. WHEN the gear is tapped, THE App_Shell SHALL open the Settings_Screen, and WHEN the Settings_Screen is closed, THE App_Shell SHALL return to the tab it came from with its scroll position unchanged
5. WHEN the Questlog_App returns from the background, THE App_Shell SHALL run Reconciliation once, and SHALL NOT run it again until the next return from the background
6. WHEN Reconciliation posts one or more Instances, THE App_Shell SHALL show a brief message naming the posted Missions
7. IF Reconciliation fails with a storage error, THEN THE App_Shell SHALL show the existing data, show an inline retry message and SHALL NOT block the user from using the rest of the app
8. THE App_Shell SHALL support the iOS edge-swipe back gesture on every pushed screen

### Requirement 2: Hero Bar

**User Story:** As a user, I want to see my level and XP at a glance, so that progress feels tangible.

#### Acceptance Criteria

1. THE Hero_Bar SHALL show the Level badge with the current Level, the Level as "Úroveň N" (English "Level N"), and a 6px progress bar filled to Level_Progress
2. THE Hero_Bar SHALL show the XP earned inside the current Level and the current Level_Threshold as "current / threshold XP", and the XP remaining until the next Level
3. WHEN the hero name is not empty, THE Hero_Bar SHALL show it above the Level line, and WHEN the hero name is empty, THE Hero_Bar SHALL show only the Level line
4. WHEN Total_XP changes, THE Hero_Bar SHALL animate the progress bar to its new value, and WHEN the Level changes, THE Hero_Bar SHALL update the Level badge
5. WHEN a Level change makes the progress bar wrap from full to empty, THE Hero_Bar SHALL fill the bar to its end before restarting at the new Level's progress
6. THE Hero_Bar SHALL format all XP figures with tabular numerals and locale-appropriate grouping

### Requirement 3: Quest Board

**User Story:** As a user, I want one board with everything I should do and what I finished today, so that I can work through it.

#### Acceptance Criteria

1. THE Board_Screen SHALL list the open board Quests in manual order as Quest_Cards, followed by the Quests done on the current Board_Day
2. THE Quest_Card SHALL show a check circle, the Quest name, a meta row and the XP of the Quest's Difficulty
3. WHEN a Quest belongs to a Mission, THE Quest_Card meta row SHALL show a Mission chip with the Mission name and the Difficulty pips, and WHEN it does not, THE meta row SHALL show "bez mise" (English "no mission") and the Difficulty pips
4. THE Difficulty pips SHALL show one, two or three filled diamonds for Easy, Normal and Hard, with no colour coding of difficulty
5. THE done Quest_Card SHALL use the raised ground, a struck-through name, a filled brass check and the completion time in the meta row
6. WHEN the check circle of an open Quest is tapped, THE Board_Screen SHALL call Quest_Service to complete it, update the list at once and show the Reward_Card
7. WHEN the check circle of a done Quest is tapped, THE Board_Screen SHALL call Quest_Service to reopen it, move it back among the open Quests and show a brief message with the XP withdrawn
8. WHEN reopening a Quest also reopens its Mission, THE Board_Screen SHALL say so in the same message
9. WHILE the first data load is pending, THE Board_Screen SHALL show skeleton cards in place of Quest_Cards
10. WHEN there are no open board Quests and no Quests done today, THE Board_Screen SHALL show the empty state with a heading and one sentence of guidance that points to the add button
11. THE Board_Screen SHALL show a floating add button that opens the Quest_Sheet
12. WHEN the Board_Day changes while the Questlog_App is open or in the background, THE Board_Screen SHALL stop showing Quests completed on earlier days without requiring a restart
13. WHEN the tap on a check circle fails with an error, THE Board_Screen SHALL restore the previous state of the card and show the localized error message

### Requirement 4: Quest Reordering

**User Story:** As a user, I want to drag quests into my own order, so that the board reflects my priorities.

#### Acceptance Criteria

1. WHEN a Quest_Card of an open Quest is long-pressed, THE Board_Screen SHALL lift the card with haptic feedback and let it be dragged vertically among the open Quest_Cards
2. WHEN the card is dropped, THE Board_Screen SHALL call Quest_Service to persist the new relative order of the open board Quests shown
3. THE Board_Screen SHALL NOT allow done Quest_Cards to be dragged or open Quests to be dropped among them
4. WHEN the drag is cancelled, THE Board_Screen SHALL return the card to its original position and persist nothing
5. IF persisting the order fails, THEN THE Board_Screen SHALL restore the previous order and show the localized error message
6. THE Mission_Detail_Screen SHALL allow the open Quests of the Mission to be reordered in the same way, and THE Board_Screen and Mission_Detail_Screen SHALL show the shared Quests in the same relative order
7. WHEN the drag handle gesture and the swipe gesture compete, THE Quest_Card SHALL treat a horizontal drag as a swipe and a long press followed by movement as a reorder

### Requirement 5: Quest Sheet

**User Story:** As a user, I want a quick form to post a quest or change one, so that capturing a task takes seconds.

#### Acceptance Criteria

1. WHEN the add button is tapped, THE Questlog_App SHALL open the Quest_Sheet in create mode with the name field focused and the keyboard shown
2. THE Quest_Sheet SHALL contain a name field, a Difficulty selector showing Snadný +10, Běžný +25 and Těžký +50 XP (default Běžný), an optional note field and a Mission picker listing the open Missions with "bez mise" as the first option
3. THE Quest_Sheet SHALL have a grabber, "Zrušit" at the left, the title centred and one brass primary button labelled "Vyvěsit quest" in create mode and "Uložit" in edit mode
4. WHEN the name is empty after trimming, longer than 80 characters or the note is longer than 500 characters, THE Quest_Sheet SHALL show a localized error beside the offending field, SHALL keep everything the user typed and SHALL NOT call Quest_Service
5. WHEN the Quest_Sheet is opened from the Mission_Detail_Screen, THE Quest_Sheet SHALL preselect that Mission
6. WHEN a done Quest is edited, THE Quest_Sheet SHALL show the Difficulty selector and Mission picker as disabled and SHALL allow only the name and note to change
7. WHEN the primary button succeeds, THE Questlog_App SHALL close the sheet with the sheet transition and show the new or changed Quest on the board
8. WHEN the Quest_Sheet contains input and is dismissed by "Zrušit", the grabber or a swipe, THE Questlog_App SHALL ask for confirmation before discarding it, and SHALL NOT ask when the sheet is untouched
9. IF Quest_Service reports an invalid-state error because the chosen Mission is no longer open, THEN THE Quest_Sheet SHALL show the error beside the Mission picker and keep the sheet open

### Requirement 6: Swipe Actions and Deletion

**User Story:** As a user, I want to edit or delete a quest or mission with a swipe, so that the list stays uncluttered.

#### Acceptance Criteria

1. WHEN a Quest_Card is swiped left, THE Questlog_App SHALL reveal two 84px actions, "Upravit" on the raised ground and "Smazat" in the destructive colour
2. WHEN "Upravit" is tapped, THE Questlog_App SHALL open the Quest_Sheet in edit mode for that Quest
3. WHEN "Smazat" is tapped on a Quest, THE Questlog_App SHALL ask for confirmation naming the Quest before calling Quest_Service
4. WHEN a done Quest is deleted, THE confirmation text SHALL state that the XP already earned is kept
5. WHEN a Mission_Card is swiped left, THE Questlog_App SHALL reveal the same "Upravit" and "Smazat" actions for the Mission
6. WHEN "Smazat" is tapped on a Mission, THE Questlog_App SHALL ask for confirmation that names the Mission and states how many Quests will be deleted with it and that earned XP is kept
7. WHEN the user confirms a deletion, THE Questlog_App SHALL call the service and remove the row with the list transition
8. WHEN the user cancels a deletion or taps elsewhere, THE Questlog_App SHALL close the revealed actions and change nothing
9. WHILE one row shows revealed actions, THE Questlog_App SHALL close it when another row is swiped

### Requirement 7: Reward Card

**User Story:** As a user, I want a satisfying "turned in" moment when I finish something, so that the game feels rewarding.

#### Acceptance Criteria

1. WHEN a Quest is completed, THE Questlog_App SHALL show the Reward_Card over the scrim with a brass seal, the awarded "+N XP", the caption "QUEST SPLNĚNO" (English "QUEST COMPLETE") and the Quest name
2. WHEN the completed Quest belongs to a Mission, THE Reward_Card SHALL show a Mission progress block with done and total counts, a progress bar and the XP remaining on the Mission
3. WHEN the completion raises the Level, THE Reward_Card SHALL show the Level-up variant with the new Level and the caption "NOVÁ ÚROVEŇ" (English "LEVEL UP")
4. WHEN the Quest_Service reports that the Mission is ready to be completed, THE Reward_Card SHALL show a primary button "Dokončit misi" and a secondary "Pokračovat" and SHALL NOT dismiss itself
5. WHEN the Reward_Card has no "Dokončit misi" button, THE Reward_Card SHALL dismiss itself after 2.5 seconds, and WHEN "Pokračovat" or the scrim is tapped it SHALL dismiss at once
6. WHEN a Mission is completed, THE Questlog_App SHALL show the Reward_Card with the caption "MISE SPLNĚNA" (English "MISSION COMPLETE"), the Mission_Bonus, the Mission name and, when the Level rose, the Level-up variant
7. WHILE the Reward_Card is shown, THE Questlog_App SHALL apply the XP change to the Hero_Bar behind the scrim so that the bar finishes animating when the card closes
8. WHEN reduced motion is requested by the device, THE Reward_Card SHALL appear and disappear with a plain fade and SHALL NOT animate the rays or seal
9. WHEN several rewards are triggered in quick succession, THE Questlog_App SHALL show them one after another and SHALL NOT stack Reward_Cards

### Requirement 8: Missions Screen

**User Story:** As a user, I want to see all my ongoing missions with their progress, so that I can pick what to work on.

#### Acceptance Criteria

1. THE Missions_Screen SHALL list the open Missions as Mission_Cards
2. THE Mission_Card SHALL show a 56px progress ring with "done/total" inside, the Mission name, "Zbývá: N XP" (English "Remaining: N XP") and the Mission_Bonus with the caption "za dokončení" (English "on completion")
3. WHEN a Mission has no done Quests, THE Mission_Card SHALL draw the ring without a progress stroke
4. WHEN the Mission has Quests that are all done and the Mission is still open, THE Mission_Card SHALL show the caption "Připraveno k dokončení" (English "Ready to complete") in place of the remaining XP
5. THE Missions_Screen SHALL show a section "Dokončeno dnes" (English "Completed today") listing only the Missions completed on the current Board_Day, each with the awarded bonus and the caption "získáno" (English "earned")
6. WHEN the Board_Day changes, THE Missions_Screen SHALL remove Missions completed on earlier days from the section without a restart
7. WHEN there are no open Missions and none completed today, THE Missions_Screen SHALL show an empty state with guidance and a button that opens the Mission_Sheet
8. WHEN a Mission_Card is tapped, THE Questlog_App SHALL open the Mission_Detail_Screen
9. THE Missions_Screen SHALL show a floating add button that opens the Mission_Sheet
10. WHILE the first data load is pending, THE Missions_Screen SHALL show skeleton cards

### Requirement 9: Mission Sheet

**User Story:** As a user, I want to create a mission with its first quests in one go, so that I can plan a goal quickly.

#### Acceptance Criteria

1. THE Mission_Sheet SHALL contain a name field, a Mission_Bonus selector showing Malá +50, Střední +100 and Velká +200 XP (default Střední) and a list of quest rows, each with a name field and a Difficulty selector, with an "Přidat quest" row below them
2. THE Mission_Sheet SHALL have "Zrušit", the centred title and one brass primary button labelled "Zahájit misi" in create mode and "Uložit" in edit mode
3. WHEN the name is empty after trimming or longer than 80 characters, THE Mission_Sheet SHALL show a localized error beside the name field, keep the user's input and SHALL NOT call Mission_Service
4. WHEN a quest row is left empty, THE Mission_Sheet SHALL ignore it on submit, and WHEN a quest row exceeds 80 characters, THE Mission_Sheet SHALL show an error beside it
5. WHEN a quest row is removed with its remove button, THE Mission_Sheet SHALL delete the row with the list transition
6. WHEN the Mission_Sheet is in edit mode, THE Mission_Sheet SHALL allow only the name and Mission_Bonus to change and SHALL NOT show the quest rows
7. WHEN a completed Mission's Mission_Bonus is edited, THE Mission_Sheet SHALL say that the bonus already earned does not change
8. WHEN the Mission_Sheet contains input and is dismissed, THE Questlog_App SHALL ask for confirmation before discarding it
9. WHEN the primary button succeeds, THE Questlog_App SHALL close the sheet and show the new Mission on the Missions_Screen

### Requirement 10: Mission Detail

**User Story:** As a user, I want to open a mission, work through its quests and finish it, so that long-term goals have a clear ending.

#### Acceptance Criteria

1. THE Mission_Detail_Screen SHALL show the Mission name, a large progress ring or bar with "done/total", the Mission_Bonus and all Quests of the Mission, including Quests completed on earlier days
2. THE Mission_Detail_Screen SHALL show a "···" button that opens a menu with "Upravit misi", "Přidat quest" and, last and in the destructive colour, "Smazat misi"
3. WHEN "Přidat quest" is chosen, THE Questlog_App SHALL open the Quest_Sheet with this Mission preselected
4. WHEN "Smazat misi" is chosen, THE Questlog_App SHALL ask for the confirmation described in Requirement 6, and after the deletion SHALL return to the Missions_Screen
5. WHEN every Quest of an open Mission is done and the Mission has at least one Quest, THE Mission_Detail_Screen SHALL show a primary button "Dokončit misi"
6. WHEN "Dokončit misi" is tapped, THE Mission_Detail_Screen SHALL call Mission_Service to complete the Mission, show the Mission Reward_Card and SHALL then show the Mission as completed
7. WHEN the Mission is `completed`, THE Mission_Detail_Screen SHALL show the seal, the earned bonus and the completion date, and SHALL NOT offer "Přidat quest"
8. WHEN a done Quest of a `completed` Mission is reopened, THE Mission_Detail_Screen SHALL show the Mission as open again and tell the user that the bonus was withdrawn
9. WHEN the Mission was deleted or closed while the screen is open, THE Mission_Detail_Screen SHALL close itself and return to the previous screen
10. WHEN a Mission has no Quests, THE Mission_Detail_Screen SHALL show an empty state that points to "Přidat quest"
11. THE Mission_Detail_Screen SHALL show an Instance's recurrence with the caption "Pravidelná mise" (English "Recurring mission") when it has a rule

### Requirement 11: Settings Screen and Profile

**User Story:** As a user, I want one settings screen for my name, language, theme and routines, so that I can adapt the app.

#### Acceptance Criteria

1. THE Settings_Screen SHALL show a back navigation, the title "Nastavení" and the labelled groups in this order: Profil, Jazyk, Vzhled, Pravidelné mise, Dočasné, O aplikaci
2. THE Profile group SHALL contain a hero-name field with a 40-character limit and a counter that shows the Total_XP in small type next to the name
3. WHEN the hero name field loses focus or is submitted, THE Settings_Screen SHALL save the trimmed name through Settings_Service and the Hero_Bar SHALL update at once
4. IF the hero name exceeds 40 characters, THEN THE Settings_Screen SHALL show a localized error beside the field and SHALL NOT save
5. THE Language group SHALL show a segmented control with Čeština and English that highlights the Effective_Language, and selecting a segment SHALL store the explicit language
6. THE Theme group SHALL show a segmented control with Světlý, Tmavý and Systém, each with an icon, highlighting the stored value
7. THE About group SHALL show the application name and the version read from the platform build information, not from a second copy of the version string
8. WHEN a setting changes, THE Questlog_App SHALL apply it to every visible screen at once without reloading or rebuilding the navigation stack

### Requirement 12: Recurring Rules in Settings

**User Story:** As a user, I want to manage routine missions and trigger one by hand, so that cleaning or planning appears on its own.

#### Acceptance Criteria

1. THE Settings_Screen SHALL list every Recurring_Rule as a row with a repeat icon, the name, the line "cadence · N questů · příště date" and a brass outline pill "Vyvěsit teď" (English "Post now"), and SHALL end the list with a dashed add row
2. WHEN a rule has an `open` Instance, THE rule row SHALL show the pill as "Vyvěšeno" (English "Posted") in a dimmed state
3. WHEN "Vyvěsit teď" is tapped, THE Settings_Screen SHALL call Recurrence_Service to post the rule and show a message that the Mission was posted and that the nearest scheduled posting was skipped when it was
4. WHEN a posted Instance closes an earlier `open` Instance, THE Settings_Screen message SHALL say that the unfinished Mission was closed without bonus
5. WHEN a rule row is tapped, THE Questlog_App SHALL open the Rule_Sheet in edit mode, and WHEN the add row is tapped, in create mode
6. THE Rule_Sheet SHALL contain a name field, six Cadence chips (Denně, Týdně, Každé 2 týdny, Měsíčně, Čtvrtletně, Ročně), a posting-day picker, a Mission_Bonus selector and an ordered list of quest templates with name and Difficulty, plus a help line stating that unfinished quests do not carry over
7. THE posting-day picker SHALL offer no choice for Daily, a weekday for Weekly and Biweekly, a day of the month 1–28 for Monthly, and a full date for Quarterly and Yearly
8. WHEN the Cadence chip changes, THE Rule_Sheet SHALL replace the posting-day picker with the one that suits the new Cadence and SHALL keep the name and quest templates
9. WHEN the name is empty or longer than 80 characters or no quest template has a name, THE Rule_Sheet SHALL show localized errors beside the fields, keep the input and SHALL NOT call Recurrence_Service
10. WHEN the primary button "Uložit pravidlo" succeeds, THE Rule_Sheet SHALL close and THE Settings_Screen SHALL show the rule with its next date
11. WHEN a rule is edited, THE Rule_Sheet SHALL state that changes apply to the next posted Mission only
12. WHEN "Smazat pravidlo" is tapped, THE Questlog_App SHALL ask for confirmation stating that the currently posted Mission is kept and that no further Missions will be posted

### Requirement 13: Temporary Display-Font Picker

**User Story:** As the owner, I want to try six title fonts on real data and choose one, so that I decide by using the app.

#### Acceptance Criteria

1. THE Settings_Screen SHALL show in the group "Dočasné" a row "Písmo titulků" with the current Display_Font name that opens the Font_Sheet
2. THE Font_Sheet SHALL list Figtree, Bricolage Grotesque, Sora, Outfit, Unbounded and Cinzel, each row set in its own face with the sample "Nástěnka · +25", the font name, a two-word character note and a brass tick on the current choice
3. WHEN a font is chosen, THE Questlog_App SHALL store it through Settings_Service and SHALL apply it at once to page titles, sheet titles, Hero_Bar Level text and XP figures
4. THE Display_Font SHALL affect only the display role, and THE body role SHALL remain Figtree
5. THE Questlog_App SHALL bundle all six font families as assets, so that the picker works without a network connection
6. THE Design_Tokens SHALL define the display and body roles as two separate text-style families, so that removing the picker and the unused fonts later is a change in one place

### Requirement 14: Localization

**User Story:** As a Czech user who is also learning in English, I want the whole app in Czech or English and switchable instantly, so that language never gets in the way.

#### Acceptance Criteria

1. THE Questlog_App SHALL ship Czech and English translations of every user-facing string through generated localization, with Czech as the template language
2. THE Questlog_App SHALL show the Effective_Language resolved by Settings_Service, falling back to English when the device language is neither Czech nor English
3. WHEN the language changes, THE Questlog_App SHALL switch every visible string at once with no reload, no empty or untranslated flash and the scroll position of every screen preserved
4. WHEN the language changes, THE Questlog_App SHALL update the semantic language of the application so that screen readers use the right voice
5. THE Questlog_App SHALL format dates, times and numbers with the Effective_Language's locale, and SHALL pluralise counts of Quests correctly in Czech (1, 2–4, 5+) and English
6. THE Questlog_App SHALL show domain errors only as localized messages, never as exception text

### Requirement 15: Theming and Design Fidelity

**User Story:** As a user, I want the app to look like the approved Guild Board design in dark and light, so that it is pleasant to use day and night.

#### Acceptance Criteria

1. THE Design_Tokens SHALL define the Guild Board (dark) and Daylight (light) palettes with the values in `.design/DESIGN.md`
2. WHEN the theme setting is `system`, THE Questlog_App SHALL follow the device brightness and SHALL follow it live when the device changes
3. THE Design_Tokens SHALL define the card, field, sheet and reward-card corner radii, touch-target minimum, spacing scale, and the transition durations of about 200 ms for hover and press states, about 300 ms for sheets and menus and 300–400 ms for screen transitions
4. THE Questlog_App SHALL take every colour, radius, spacing and duration from the Design_Tokens and SHALL NOT use literal values elsewhere in widget code
5. THE Questlog_App SHALL render open Quest_Cards as parchment slips, done Quest_Cards and Mission_Cards on the raised ground, and use brass only for reward, completion and primary actions
6. WHEN the light theme is active, THE Quest_Card SHALL add the 1px parchment-edge outline
7. THE Questlog_App SHALL style text selection and text-field cursors with the brass colour
8. THE Questlog_App SHALL use SVG assets for all icons rather than an icon font

### Requirement 16: Interaction, Motion and Accessibility

**User Story:** As a user, I want controls that are easy to hit and understand, and the option to reduce motion, so that the app is comfortable.

#### Acceptance Criteria

1. THE Questlog_App SHALL give every tappable element a hit area of at least 44×44 logical pixels, including the 28px painted check circle
2. THE Questlog_App SHALL give every tappable element a visible pressed state
3. THE Questlog_App SHALL provide semantic labels for check circles, the add buttons, the gear, swipe actions, the drag handle and the "···" menu, in the Effective_Language
4. THE Questlog_App SHALL announce through semantics when a Quest or Mission is completed or reopened
5. WHEN the device requests reduced motion, THE Questlog_App SHALL replace slide, scale and ray animations with fades of at most 150 ms
6. THE Questlog_App SHALL keep text contrast of at least 4.5:1 for body text on every ground in both themes
7. THE Questlog_App SHALL honour the device text-size setting up to 130 % without clipped text or horizontal overflow
8. THE Questlog_App SHALL NOT produce horizontal overflow on any iPhone screen width from 320 to 430 logical pixels
9. THE Questlog_App SHALL offer haptic feedback on completing a Quest, completing a Mission, picking up a card to reorder and confirming a destructive action

### Requirement 17: Day Rollover and Live Data

**User Story:** As a user, I want the board to be right when I open the app in the morning, and to update itself when a new day starts at 4:00, so that I never see yesterday's finished items.

#### Acceptance Criteria

1. THE Questlog_App SHALL provide a Board_Day signal that changes when the Clock passes the next Day_Start
2. WHILE the Questlog_App is in the foreground, THE Board_Day signal SHALL schedule a refresh for the next Day_Start and SHALL cancel it when the app goes to the background
3. WHEN the Questlog_App returns to the foreground, THE Board_Day signal SHALL re-evaluate the Board_Day and, when it changed, THE Questlog_App SHALL refresh the done lists and run Reconciliation
4. THE Questlog_App SHALL read the current time only through the Clock
5. WHILE an operation runs, THE Questlog_App SHALL keep screens bound to the observable queries of the services, so that all tabs show consistent data after every change

### Requirement 18: Errors and Feedback

**User Story:** As a user, I want clear, calm feedback when something cannot be done, so that I know what to do next.

#### Acceptance Criteria

1. IF a service call fails with a validation error, THEN THE Questlog_App SHALL show the message beside the field that caused it
2. IF a service call fails with a not-found or invalid-state error, THEN THE Questlog_App SHALL refresh the affected list and show a short message explaining that the item changed
3. IF a service call fails with a storage error, THEN THE Questlog_App SHALL show a localized message offering a retry and SHALL NOT show exception text
4. THE Questlog_App SHALL show transient messages in a bottom snackbar styled with the Design_Tokens that does not cover the tab bar or add button
5. THE Questlog_App SHALL ask for confirmation before every destructive action and before discarding a non-empty sheet

### Requirement 19: Project Structure and Verification

**User Story:** As a developer, I want the UI code organised and covered by automated tests, so that the app can keep growing.

#### Acceptance Criteria

1. THE Questlog_App SHALL place UI code under `lib/ui/` in subdirectories by responsibility and generated localization under `lib/l10n/`, so that no directory exceeds the limit enforced by `scripts/check-structure.sh`
2. THE Questlog_App SHALL keep business rules in the services of spec 001 and SHALL NOT duplicate them in widgets, except client-side form validation that mirrors the domain limits
3. THE Questlog_App SHALL provide widget tests for every screen and sheet using an in-memory Questlog_Database and a controllable Clock
4. THE Questlog_App SHALL provide a golden or screenshot comparison of the Board_Screen, Missions_Screen and Settings_Screen in both themes
5. WHEN `scripts/check.sh` runs, THE Questlog_App SHALL pass static analysis, all unit, widget and property tests and the structure check
6. THE Questlog_App SHALL declare all fonts and SVG icons as assets in `pubspec.yaml` and SHALL NOT fetch any asset at runtime
7. THE Questlog_App SHALL keep the bundle identifier and display name configurable in one place so that the user can set them before the iOS build
