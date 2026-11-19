# Requirements Document

## Introduction

This spec adds a **calendar** to Questlog, the personal gamified to-do application built in Flutter (iOS primary) under `/workspace/QuestLog/`. The calendar is a fourth bottom tab, **Kalendář**, with a month overview, a day detail, an event detail, and forms to create, edit and delete events. It is not linked to Missions and the tab shows no Hero_Bar. It is linked to the Board in one way: an event marked "Na nástěnku" appears on the Board_Screen on its day as a task to do, for example wishing someone a happy birthday or going to a meeting, and completing it earns XP that depends on the length of the event or, for all-day events, on its type (Requirements 15 and 16). The visual reference is the user's calendar screenshots, restyled with the Questlog Design_Tokens; the approved preview is `.design/calendar-preview.html`.

Events have one of ten fixed Event_Types (dance, work, birthday, name day, public holiday, notable day, date, meeting, seminar, lesson), each with its own colour; notable days are drawn in a softer style than the other types so that they are told apart from public holidays at a glance. The type replaces the free colour choice of the reference app. Events may repeat (daily, weekly, monthly, yearly), may be all-day or timed, and may span several days. The first start on schema version 3 also fills the calendar with the thirteen Czech public holidays, sixteen notable and folk days and six name days, repeating every year (Requirement 14). All data lives in the local Questlog_Database (schema version 3); there is no server, no account and no synchronisation with the system calendar.

Out of scope: reminders and notifications, an event URL, the Week, Day and List views, user-defined event types or colours, import from or export to the system calendar, and sharing events. This spec overrides `002-questlog-ui` Requirement 1 criteria 2 and 3 (three tabs, Hero_Bar on two of them): the app has four tabs and the Calendar_Screen shows no Hero_Bar. It also extends `002-questlog-ui` Requirement 3: besides Quests without a Mission, the Board_Screen lists Event_Tasks. The visible palette is not part of this spec; every colour comes from the Design_Tokens.

## Glossary

Terms defined in `001-questlog-domain` and `002-questlog-ui` (Questlog_App, Questlog_Database, App_Shell, Board_Screen, Hero_Bar, Settings_Screen, Quest_Card, Today, Board_Day, Day_Start, Difficulty, Total_XP, Xp_Engine, Design_Tokens, Effective_Language, Clock) keep their meaning here. Additional terms:

- **Calendar_Screen**: The Kalendář tab showing the Month_View.
- **Month_View**: The grid of the Visible_Month with weekday headings, day cells and Event_Chips.
- **Visible_Month**: The calendar month currently shown by the Month_View.
- **Calendar_Today**: The calendar date of the Clock in local time, changing at local midnight. It is not the Board_Day: the calendar does not use Day_Start.
- **Selected_Day**: The date last tapped in the Month_View, or Calendar_Today when none was tapped since the Calendar_Screen opened.
- **Event_Chip**: The small coloured label for one Event_Occurrence inside a day cell.
- **Day_Sheet**: The bottom sheet listing the Event_Occurrences of one date.
- **Event_Detail_Screen**: The read-only screen showing one Event_Occurrence.
- **Event_Form**: The screen for creating or editing a Calendar_Event.
- **Calendar_Event**: A stored event with a name, an Event_Type, a start, an end, an all-day flag, an optional note, an optional location and a Repeat_Rule.
- **Event_Type**: One of Dance, Work, Birthday, Name_Day, Public_Holiday, Notable_Day, Date, Meeting, Seminar, Lesson; each has a fixed colour in the Design_Tokens.
- **Repeat_Rule**: The repetition of a Calendar_Event: None, Daily, Weekly, Monthly, Yearly, Easter_Relative or Nth_Weekday, with an optional Repeat_End.
- **Repeat_End**: The last calendar date on which a repeating Calendar_Event may start, inclusive.
- **Event_Occurrence**: One appearance of a Calendar_Event on the calendar, either its only one or one repetition of its Repeat_Rule. It is identified by its Calendar_Event and its start date.
- **Skipped_Date**: A start date on which a repeating Calendar_Event is deliberately not shown.
- **Type_Filter**: The set of Event_Types currently shown in the Month_View and Day_Sheet.
- **Event_Search**: The screen that finds Calendar_Events by text.
- **Czech_Public_Holiday**: One of the thirteen Czech days off listed in Requirement 14, all of the Event_Type Public_Holiday.
- **Czech_Notable_Day**: One of the sixteen notable and folk days listed in Requirement 14, one of them a "významný den" of the law and fifteen folk days such as Valentýn or Mikuláš. They are not days off.
- **Czech_Name_Day**: One of the name days listed in Requirement 14, of the Event_Type Name_Day.
- **Nth_Weekday**: A Repeat_Rule used only by built-in days, repeating every year in a given month on the n-th given weekday, for example the second Sunday of May.
- **Soft_Chip**: The Event_Chip style of the Event_Type Notable_Day: a tinted fill with a solid bar on the left edge and body text colour, instead of a solid fill.
- **Easter_Relative**: A Repeat_Rule used only by built-in holidays, repeating every year on the date that lies a fixed number of days from Easter Sunday of that year.
- **On_Board**: The flag of a Calendar_Event saying that its Event_Occurrences appear on the Board_Screen as Event_Tasks. The Event_Form shows it as the switch "Na nástěnku".
- **Event_Task**: The Board_Screen row for one Event_Occurrence of an On_Board Calendar_Event on the Board_Day whose Today equals the start date of that Event_Occurrence.
- **Event_Completion**: The stored record that one Event_Occurrence was completed, with the completion time and the XP awarded.
- **Event_XP**: The XP an Event_Task awards, one of the Difficulty values 10, 25, 50 or 100, derived by the rules of Requirement 16.
- **Calendar_Service**: The component that creates, edits, deletes and queries Calendar_Events and expands Repeat_Rules into Event_Occurrences.

## Requirements

### Requirement 1: Calendar Tab

**User Story:** As a user, I want a Kalendář tab in the bottom bar, so that I can reach my events with one tap.

#### Acceptance Criteria

1. THE App_Shell SHALL offer four tabs in a bottom tab bar, in this order: Questy, Mise, Kalendář, Nastavení
2. WHEN the Kalendář tab is tapped, THE App_Shell SHALL show the Calendar_Screen in place with the Visible_Month and Selected_Day it had when the user left it
3. WHEN the Questlog_App starts, THE Calendar_Screen SHALL show the month of Calendar_Today
4. THE Calendar_Screen SHALL NOT show a Hero_Bar
5. THE Kalendář tab SHALL show no highlight, ripple or frame while it is pressed, like the other tabs

### Requirement 2: Month Overview

**User Story:** As a user, I want to see a whole month at once and move between months, so that I can plan ahead.

#### Acceptance Criteria

1. THE Month_View SHALL show the Visible_Month as a grid of six week rows with Monday as the first weekday, with weekday headings in the Effective_Language
2. THE Month_View SHALL show the days of the neighbouring months that complete the first and last week in a faded style
3. THE Month_View SHALL show the title with the Visible_Month name and year in the Effective_Language
4. WHEN the previous or next arrow is tapped, THE Month_View SHALL show the previous or next month
5. WHEN the user swipes horizontally on the Month_View, THE Month_View SHALL show the next month for a swipe to the left and the previous month for a swipe to the right
6. WHEN the "Dnes" button is tapped, THE Month_View SHALL show the month of Calendar_Today
7. THE Month_View SHALL mark the cell of Calendar_Today with the accent colour
8. WHEN the title is tapped, THE Calendar_Screen SHALL open a month picker offering the twelve months of a chosen year, and WHEN a month is chosen, THE Month_View SHALL show it
9. THE Month_View SHALL allow navigation only between January 2000 and December 2100
10. WHEN Calendar_Today changes at local midnight while the Calendar_Screen is shown, THE Month_View SHALL move the today mark to the new date

### Requirement 3: Events in the Month

**User Story:** As a user, I want each day cell to show its events in their type colour, so that I can read the month at a glance.

#### Acceptance Criteria

1. THE Month_View SHALL show every Event_Occurrence that touches a date as an Event_Chip in that date's cell, filled with the colour of its Event_Type and labelled with the event name
2. WHERE a date has at most three Event_Occurrences, THE Month_View SHALL show all of them as Event_Chips
3. WHERE a date has more than three Event_Occurrences, THE Month_View SHALL show two Event_Chips and a "+N" label with the number of the remaining ones
4. THE Month_View SHALL list all-day Event_Occurrences before timed ones, and timed ones by start time
5. WHEN an Event_Occurrence spans several dates, THE Month_View SHALL show an Event_Chip on every date it touches
6. WHEN the Calendar_Event is created, edited or deleted, THE Month_View SHALL show the change without a manual refresh
7. THE Event_Chip text SHALL reach a contrast ratio of at least 4.5:1 against the Event_Type colour in both themes
8. THE Month_View SHALL expose an accessibility label per day cell naming the date and the number of events

### Requirement 4: Event Types

**User Story:** As a user, I want to classify events by type instead of choosing colours, so that the same kind of event always looks the same.

#### Acceptance Criteria

1. THE Questlog_App SHALL offer exactly ten Event_Types: Dance, Work, Birthday, Name_Day, Public_Holiday, Notable_Day, Date, Meeting, Seminar and Lesson, shown in Czech as Tanec, Práce, Narozeniny, Jmeniny, Státní svátek, Významný den, Rande, Meeting, Seminář and Lekce
2. THE Design_Tokens SHALL define one distinct colour per Event_Type, and SHALL define it for the light and the dark theme
3. THE Questlog_App SHALL show the Event_Type colour with the type name wherever it shows the colour alone, so that the type is never conveyed by colour only
4. THE Questlog_App SHALL NOT offer a free colour choice for events
5. THE Month_View SHALL draw the Event_Chip of the Event_Type Notable_Day as a Soft_Chip and every other Event_Chip with a solid fill
6. THE Day_Sheet SHALL draw the bar of a Notable_Day as a Soft_Chip bar, in the colour of the Event_Type
7. THE Design_Tokens SHALL choose the ten Event_Type colours so that no two differ by less than 25 in CIE76 colour difference in the dark theme

### Requirement 5: Type Filter

**User Story:** As a user, I want to hide some kinds of events, so that I can look at only dance or only work.

#### Acceptance Criteria

1. WHEN the filter button is tapped, THE Calendar_Screen SHALL open a sheet with one toggle per Event_Type
2. THE Type_Filter SHALL contain all ten Event_Types when the Questlog_App starts
3. WHILE the Type_Filter lacks at least one Event_Type, THE Month_View and THE Day_Sheet SHALL show only Event_Occurrences of the Event_Types in the Type_Filter
4. WHILE the Type_Filter lacks at least one Event_Type, THE Calendar_Screen SHALL show the filter button in the accent colour
5. WHEN the user turns every toggle off, THE Calendar_Screen SHALL show an empty month and a message that the filter hides all events, with a button that restores all types
6. THE Questlog_App SHALL store the Type_Filter and restore it on the next start, so that a hidden Event_Type stays hidden

### Requirement 6: Day Detail

**User Story:** As a user, I want to open a day and see its events in order, so that I know my schedule.

#### Acceptance Criteria

1. WHEN a day cell is tapped, THE Calendar_Screen SHALL set the Selected_Day to that date and open the Day_Sheet for it
2. THE Day_Sheet SHALL show the full date with the weekday in the Effective_Language and the number of events
3. THE Day_Sheet SHALL list all-day Event_Occurrences first, marked "Celý den", and then timed ones by start time
4. THE Day_Sheet SHALL show for each timed Event_Occurrence its start and end time, a vertical bar in the Event_Type colour, the name and the Event_Type name
5. WHEN an Event_Occurrence spans several dates, THE Day_Sheet SHALL show on each date only the part of the time range that falls on that date, and "Celý den" for dates fully inside it
6. WHEN an Event_Occurrence in the Day_Sheet is tapped, THE Questlog_App SHALL open its Event_Detail_Screen
7. WHEN the add button in the Day_Sheet is tapped, THE Questlog_App SHALL open the Event_Form for a new event with the Day_Sheet date preset
8. IF the date has no Event_Occurrence to show, THEN THE Day_Sheet SHALL show the text "Žádné události" and an add button
9. WHEN the Day_Sheet is dismissed by the close button, a swipe down or a tap outside it, THE Calendar_Screen SHALL return to the Month_View without changing the Visible_Month
10. WHEN a Calendar_Event is changed or deleted while the Day_Sheet is open, THE Day_Sheet SHALL show the change

### Requirement 7: Event Detail

**User Story:** As a user, I want to open an event and read everything about it, so that I do not have to remember it.

#### Acceptance Criteria

1. THE Event_Detail_Screen SHALL show the event name, an Event_Type badge in the Event_Type colour with the type name, and the start and end as weekday, date and time
2. WHERE the Calendar_Event is all-day, THE Event_Detail_Screen SHALL show dates without times and the label "Celý den"
3. THE Event_Detail_Screen SHALL show the note, the Repeat_Rule and the location, and SHALL show "Nenastaveno" for the note and location when they are empty
4. THE Event_Detail_Screen SHALL describe a Repeat_Rule in words, such as "středa každý týden", and SHALL show "Nikdy" when it is None
5. WHEN the location is tapped, THE Questlog_App SHALL copy it to the clipboard and show a snackbar confirming it
6. WHERE the Event_Occurrence has an Event_Completion, THE Event_Detail_Screen SHALL show "Splněno" with the completion time and the Event_XP awarded
7. THE Event_Detail_Screen SHALL offer a close button, a menu with "Upravit", "Duplikovat" and "Smazat", and an "Upravit" button at the bottom
8. WHEN "Upravit" is chosen, THE Questlog_App SHALL open the Event_Form for the Calendar_Event
9. WHEN "Duplikovat" is chosen, THE Questlog_App SHALL open the Event_Form for a new event prefilled with every value of the Calendar_Event, including On_Board, except its Repeat_Rule, which is None
10. WHEN "Smazat" is chosen, THE Questlog_App SHALL start the deletion flow of Requirement 11

### Requirement 8: Event Form Fields

**User Story:** As a user, I want a form to create and edit events, so that I can enter exactly what I need.

#### Acceptance Criteria

1. THE Event_Form SHALL offer a name field, a note field, an Event_Type picker, an all-day switch, a start date and time, an end date and time, a Repeat_Rule picker, a location field and the On_Board switch "Na nástěnku"
2. THE Event_Form SHALL require a name of 1 to 80 characters after trimming, and SHALL accept a note of at most 500 characters and a location of at most 120 characters
3. WHILE the name is empty after trimming, THE Event_Form SHALL show the save button as disabled
4. THE Event_Form SHALL show the Event_Type picker as a grid of ten options, each with its colour and name, with exactly one selected
5. WHEN the all-day switch is turned on, THE Event_Form SHALL hide the time pickers and keep the dates
6. WHEN the start is moved, THE Event_Form SHALL move the end by the same amount so that the duration is kept
7. IF the end is before the start, THEN THE Event_Form SHALL show an inline error under the end and SHALL NOT save
8. WHEN the Event_Form opens for a new event, THE Event_Form SHALL preset the date to the date given by the caller, the start to the next full hour after the Clock time when the date is Calendar_Today and to 09:00 otherwise, the duration to one hour, and the Event_Type to the one used for the last saved event, or Meeting when none was saved yet, and the On_Board switch to on for every Event_Type except Public_Holiday and Notable_Day
9. WHEN the Event_Form opens for an existing Calendar_Event, THE Event_Form SHALL show its stored values
10. WHEN the user taps back with unsaved changes, THE Event_Form SHALL ask for confirmation before discarding them, and SHALL NOT ask when nothing changed
11. WHEN the save button succeeds, THE Questlog_App SHALL close the Event_Form and show the saved Calendar_Event in the Month_View
12. IF saving fails with a storage error, THEN THE Event_Form SHALL stay open with its values and show an inline error with a retry
13. WHEN the user picks another Event_Type in the Event_Form for a new event and has not touched the On_Board switch, THE Event_Form SHALL set the switch to on for every Event_Type except Public_Holiday and Notable_Day, and to off for those two
14. WHILE the On_Board switch is on, THE Event_Form SHALL show the Event_XP that the current values would award as "Za splnění: +N XP", and SHALL update it when the start, the end, the all-day switch or the Event_Type changes

### Requirement 9: Repeating Events

**User Story:** As a user, I want events like lessons, birthdays and name days to repeat by themselves, so that I enter them once.

#### Acceptance Criteria

1. THE Event_Form SHALL offer the Repeat_Rule choices Nikdy, Každý den, Každý týden, Každý měsíc and Každý rok, and an optional Repeat_End date for the repeating ones
2. THE Calendar_Service SHALL repeat a weekly Calendar_Event on the weekday of its start date
3. THE Calendar_Service SHALL repeat a monthly Calendar_Event on the day of the month of its start date, and WHERE a month has fewer days, on the last day of that month
4. THE Calendar_Service SHALL repeat a yearly Calendar_Event on the month and day of its start date, and WHERE the start date is 29 February, on 28 February in years without it
5. THE Calendar_Service SHALL give every Event_Occurrence of a Calendar_Event the duration of the first one
6. THE Calendar_Service SHALL NOT produce an Event_Occurrence that starts after the Repeat_End
7. THE Calendar_Service SHALL NOT produce an Event_Occurrence that starts on a Skipped_Date
8. IF the Repeat_End is before the start date, THEN THE Event_Form SHALL show an inline error and SHALL NOT save
9. WHEN a repeating Calendar_Event is edited, THE Calendar_Service SHALL apply the change to the whole series
10. THE Calendar_Service SHALL produce the Event_Occurrences of a date range without storing them, so that a series with no Repeat_End needs no stored occurrences
11. THE Calendar_Service SHALL repeat an Easter_Relative Calendar_Event every year on the date that is its offset in days from Easter Sunday of that year, calculated by the Gregorian computus
12. THE Event_Form SHALL NOT offer Easter_Relative or Nth_Weekday as a choice
13. IF a Calendar_Event has the Easter_Relative or the Nth_Weekday Repeat_Rule, THEN THE Event_Form SHALL show it as "Každý rok podle Velikonoc" or "Každý rok podle dne v týdnu" and SHALL keep it unless the user picks another Repeat_Rule
14. THE Event_Detail_Screen SHALL describe an Easter_Relative Repeat_Rule as "každý rok podle Velikonoc" and an Nth_Weekday Repeat_Rule in words such as "každý rok, 2. neděle v květnu"
15. THE Calendar_Service SHALL repeat an Nth_Weekday Calendar_Event every year on the n-th occurrence of its weekday in its month, counted from the first day of that month

### Requirement 10: Event Search

**User Story:** As a user, I want to find an event by text, so that I can jump to it without paging through months.

#### Acceptance Criteria

1. WHEN the search button is tapped, THE Calendar_Screen SHALL open the Event_Search with the keyboard shown
2. THE Event_Search SHALL match Calendar_Events whose name, note or location contains the typed text, ignoring case and diacritics
3. THE Event_Search SHALL list each matching Calendar_Event once, with its name, Event_Type colour and name, and the date of its nearest Event_Occurrence on or after Calendar_Today, or of its latest one when none is upcoming
4. THE Event_Search SHALL order the results by that date, upcoming ones first in ascending order and then past ones in descending order
5. WHEN a result is tapped, THE Questlog_App SHALL open the Event_Detail_Screen of that Event_Occurrence
6. IF no Calendar_Event matches, THEN THE Event_Search SHALL show the text "Nic nenalezeno"
7. WHILE the text field is empty, THE Event_Search SHALL show a hint and no results
8. THE Event_Search SHALL ignore the Type_Filter

### Requirement 11: Deleting Events

**User Story:** As a user, I want to delete an event and be able to take it back, so that a wrong tap costs nothing.

#### Acceptance Criteria

1. THE Event_Form for an existing Calendar_Event and THE Event_Detail_Screen SHALL each offer a "Smazat" action
2. WHEN "Smazat" is chosen for a Calendar_Event without a Repeat_Rule, THE Questlog_App SHALL ask for confirmation naming the event in a bottom sheet with a destructive "Smazat" button and a "Zrušit" button
3. WHEN "Smazat" is chosen for a repeating Calendar_Event, THE Questlog_App SHALL ask which Event_Occurrences to delete: "Jen tuto událost", "Tuto a všechny další" or "Všechny události v sérii"
4. WHEN "Jen tuto událost" is confirmed, THE Calendar_Service SHALL add the start date of that Event_Occurrence to the Skipped_Dates of the Calendar_Event
5. WHEN "Tuto a všechny další" is confirmed for an Event_Occurrence that is not the first, THE Calendar_Service SHALL set the Repeat_End of the Calendar_Event to the day before that Event_Occurrence starts
6. WHEN "Tuto a všechny další" is confirmed for the first Event_Occurrence, THE Calendar_Service SHALL delete the Calendar_Event
7. WHEN "Všechny události v sérii" is confirmed, THE Calendar_Service SHALL delete the Calendar_Event
8. WHEN a deletion succeeds, THE Questlog_App SHALL close the screens of the deleted event and show a snackbar with an "Zpět" action
9. WHEN "Zpět" is tapped within the snackbar duration, THE Calendar_Service SHALL restore the Calendar_Event, its Skipped_Dates and its Repeat_End exactly as they were before the deletion, together with every Event_Completion that the deletion removed and the XP they had awarded
11. WHEN a Calendar_Event or an Event_Occurrence that has an Event_Completion is deleted, THE Xp_Engine SHALL keep the XP already awarded
10. IF deleting fails with a storage error, THEN THE Questlog_App SHALL keep the event and show an error message

### Requirement 12: Persistence and Migration

**User Story:** As a user, I want my events to be kept on the device and my existing quests to be untouched, so that updating the app loses nothing.

#### Acceptance Criteria

1. THE Questlog_Database SHALL store Calendar_Events, their Repeat_Rule, their On_Board flag, their Skipped_Dates and their Event_Completions, and SHALL be migrated from schema version 2 to 3 by adding them
2. WHEN the migration runs, THE Questlog_Database SHALL keep every existing row of every existing table unchanged
3. THE Questlog_App SHALL store each start and end as local calendar date and time without a time zone, so that an event stays at the same wall-clock time when the device time zone or daylight saving time changes
4. THE Calendar_Service SHALL read the current date and time only through the Clock
5. IF a stored Calendar_Event has an Event_Type the Questlog_App does not know, THEN THE Calendar_Service SHALL show it as Meeting and SHALL NOT delete it

### Requirement 13: Language, Theme and Accessibility

**User Story:** As a user, I want the calendar to look and read like the rest of the app, in both languages and both themes.

#### Acceptance Criteria

1. THE Questlog_App SHALL show every calendar text in Czech or English according to the Effective_Language, including month names, weekday names and date formats
2. THE Questlog_App SHALL style the calendar only with Design_Tokens, in the dark and the light theme
3. THE Questlog_App SHALL make every calendar control at least 44 by 44 logical pixels
4. THE Questlog_App SHALL give every icon-only calendar control an accessibility label
5. WHEN the system text size is increased, THE Month_View SHALL keep all Event_Chips inside their cells by truncating the name
6. THE Questlog_App SHALL show no press highlight, ripple or hover tint on calendar controls, and SHALL show a focus ring on keyboard focus

### Requirement 14: Czech Public Holidays and Notable Days

**User Story:** As a user, I want the Czech public holidays to be in the calendar from the start and repeat every year, so that I never enter them myself.

#### Acceptance Criteria

1. WHEN the Questlog_Database is created or migrated to schema version 3, THE Questlog_Database SHALL insert the thirteen Czech_Public_Holidays as all-day Calendar_Events of the Event_Type Public_Holiday
2. THE Questlog_Database SHALL insert these fixed-date Czech_Public_Holidays with the Yearly Repeat_Rule and no Repeat_End: 1 January "Nový rok", 1 May "Svátek práce", 8 May "Den vítězství", 5 July "Den slovanských věrozvěstů Cyrila a Metoděje", 6 July "Den upálení mistra Jana Husa", 28 September "Den české státnosti", 28 October "Den vzniku samostatného československého státu", 17 November "Den boje za svobodu a demokracii", 24 December "Štědrý den", 25 December "1. svátek vánoční" and 26 December "2. svátek vánoční"
3. THE Questlog_Database SHALL insert "Velký pátek" with the Easter_Relative Repeat_Rule and an offset of minus two days, and "Velikonoční pondělí" with an offset of plus one day, both with no Repeat_End
4. THE Questlog_Database SHALL start every inserted series on 1 January 2000, except "Velký pátek", which SHALL start on 1 January 2016, the first year in which it is a public holiday
5. THE Calendar_Service SHALL produce Easter Sunday 2026 as 5 April, so that "Velký pátek" falls on 3 April 2026 and "Velikonoční pondělí" on 6 April 2026
6. THE Questlog_Database SHALL insert the Czech_Public_Holidays once and SHALL NOT insert them again on a later start, so that a deleted holiday stays deleted
7. THE Questlog_Database SHALL store the names of the Czech_Public_Holidays in Czech regardless of the Effective_Language
8. THE Calendar_Service SHALL treat an inserted Czech_Public_Holiday as an ordinary Calendar_Event that can be opened, edited, duplicated and deleted by the flows of Requirements 7, 8 and 11
9. WHEN the migration to schema version 3 runs, THE Questlog_Database SHALL keep every existing row of every existing table unchanged
10. THE Questlog_Database SHALL insert every Czech_Public_Holiday with On_Board off
11. WHEN the Questlog_Database is created or migrated to schema version 3, THE Questlog_Database SHALL insert the sixteen Czech_Notable_Days as all-day Calendar_Events of the Event_Type Notable_Day, with no Repeat_End and On_Board off
12. THE Questlog_Database SHALL insert these Czech_Notable_Days with the Yearly Repeat_Rule: 14 February "Valentýn", 8 March "Mezinárodní den žen", 1 April "Apríl", 22 April "Den Země", 30 April "Pálení čarodějnic", 1 June "Den dětí", 31 October "Halloween", 2 November "Dušičky", 11 November "Svatý Martin", 5 December "Mikuláš" and 31 December "Silvestr"
13. THE Questlog_Database SHALL insert these Czech_Notable_Days with the Easter_Relative Repeat_Rule: "Zelený čtvrtek" with an offset of minus three days, "Bílá sobota" with minus one day and "Velikonoční neděle" with zero days
14. THE Questlog_Database SHALL insert these Czech_Notable_Days with the Nth_Weekday Repeat_Rule: "Den matek" on the second Sunday of May and "Den otců" on the third Sunday of June
15. THE Questlog_Database SHALL start every inserted Czech_Notable_Day series on 1 January 2000
16. THE Calendar_Service SHALL produce the second Sunday of May 2026 as 10 May and the third Sunday of June 2026 as 21 June
17. WHEN the Questlog_Database is created or migrated to schema version 3, THE Questlog_Database SHALL insert the Czech_Name_Days as all-day Calendar_Events of the Event_Type Name_Day with the Yearly Repeat_Rule, no Repeat_End, On_Board on and a start on 1 January 2000
18. THE Questlog_Database SHALL insert these Czech_Name_Days: 7 February "Veronika", 7 June "Iveta", 15 July "Jindřich", 16 July "Luboš", 19 October "Michala" and 5 December "Jitka"
19. THE Questlog_Database SHALL insert the Czech_Notable_Days and the Czech_Name_Days once together with the Czech_Public_Holidays, and SHALL NOT insert them again on a later start

### Requirement 15: Events on the Board

**User Story:** As a user, I want today's calendar events to show up on my board as things I have to do, so that I do not forget to wish someone happy birthday or to go to a meeting.

#### Acceptance Criteria

1. WHEN a Board_Day begins, WHEN the Questlog_App starts and WHEN it returns from the background, THE Board_Screen SHALL show an Event_Task for every Event_Occurrence of an On_Board Calendar_Event whose start date equals Today
2. THE Board_Screen SHALL show the Event_Tasks in the Today section above the Quests, all-day ones first and then timed ones by start time
3. THE Event_Task SHALL show a check circle, the event name, the Event_Type colour with the type name, the time range or "Celý den", the Event_XP with its effort pips, and a calendar mark that tells it apart from a Quest_Card
4. WHEN the check circle of an Event_Task is tapped, THE Calendar_Service SHALL store an Event_Completion for that Event_Occurrence and THE Xp_Engine SHALL add the Event_XP to Total_XP
5. WHEN an Event_Task is completed, THE Board_Screen SHALL give the same feedback as for a completed Quest and update the Hero_Bar
6. WHILE the Board_Day lasts, THE Board_Screen SHALL keep a completed Event_Task in the Today section in its done style, like a done Quest
7. WHEN the check circle of a completed Event_Task is tapped, THE Calendar_Service SHALL delete its Event_Completion and THE Xp_Engine SHALL subtract the XP it had awarded from Total_XP
8. IF an Event_Task is not completed when its Board_Day ends, THEN THE Board_Screen SHALL stop showing it, no XP SHALL be awarded and no penalty SHALL apply
9. WHEN an Event_Task is tapped outside its check circle, THE Questlog_App SHALL open the Event_Detail_Screen of its Event_Occurrence
10. THE Board_Screen SHALL NOT let the user reorder, swipe-delete or move an Event_Task between sections
11. THE Calendar_Service SHALL identify an Event_Completion by its Calendar_Event and the start date of its Event_Occurrence, so that completing the same Event_Occurrence twice stores one Event_Completion and awards its XP once
12. THE Board_Screen SHALL include Event_Tasks in the counts and the empty state of the Today section
13. THE Calendar_Service SHALL produce Event_Tasks from the Calendar_Events at read time and SHALL NOT store a copy of an Event_Occurrence until it is completed
14. THE Board_Screen SHALL ignore the Type_Filter

### Requirement 16: Event XP

**User Story:** As a user, I want the XP of an event to match how big it is, so that a long seminar is worth more than a quick greeting.

#### Acceptance Criteria

1. THE Calendar_Service SHALL derive the Event_XP of a timed Event_Occurrence from its duration: up to and including 30 minutes 10 XP, up to and including 120 minutes 25 XP, up to and including 300 minutes 50 XP, and longer 100 XP
2. THE Calendar_Service SHALL derive the Event_XP of an all-day Event_Occurrence from its Event_Type: 10 XP for Birthday, Name_Day, Public_Holiday, Notable_Day and Date, and 25 XP for Dance, Work, Meeting, Seminar and Lesson
3. THE Calendar_Service SHALL use for every Event_Occurrence of a repeating Calendar_Event the duration of its first one
4. THE Calendar_Service SHALL store the Event_XP awarded in the Event_Completion at the moment of completion, and a later edit of the Calendar_Event SHALL NOT change it
5. THE Event_XP SHALL always be one of the Difficulty values 10, 25, 50 or 100
6. THE Calendar_Service SHALL calculate the Event_XP without reading the Clock
