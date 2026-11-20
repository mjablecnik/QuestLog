# Requirements Document

## Introduction

This spec changes how the Month_View of the Kalendář tab in Questlog (Flutter, iOS primary, `/workspace/QuestLog/`) draws an Event_Occurrence that lasts several days. Until now such an occurrence was drawn as a separate Event_Chip in the cell of every day it touches, so a weekend seminar looked like two unrelated chips. From now on it is drawn as one continuous bar across the days it covers, as in other calendar apps.

This spec overrides `003-questlog-calendar` Requirement 3 criterion 1 for an Event_Occurrence that touches more than one date: it is no longer one Event_Chip per date but one Span_Bar per week row. Everything else of `003-questlog-calendar` Requirement 3 (the number of shown events, the "+N" label, the order, the colours, the Soft_Chip of a notable day) keeps its meaning. The Day_Sheet, the event detail, the event form and the data are unchanged; no schema change.

## Glossary

Terms defined in `001-questlog-domain`, `002-questlog-ui` and `003-questlog-calendar` (Questlog_App, Calendar_Screen, Month_View, Visible_Month, Event_Chip, Day_Sheet, Event_Occurrence, Event_Type, Calendar_Today, Design_Tokens) keep their meaning here. Additional terms:

- **Week_Row**: One of the six rows of seven day cells of the Month_View.
- **Span_Bar**: The part of one Event_Chip that lies in one Week_Row. An Event_Occurrence that touches one date has one Span_Bar one cell wide; one that touches several dates has one Span_Bar in each Week_Row it touches, as wide as the cells it covers there.
- **Lane**: A horizontal slot of a Week_Row below the date numbers. A Span_Bar occupies one Lane in all the cells it covers.
- **Continuing_End**: The end of a Span_Bar at which the Event_Occurrence goes on into the neighbouring Week_Row.

## Requirements

### Requirement 1: Continuous Bars

**User Story:** As a user, I want an event that lasts several days to look like one bar across those days, so that I see at a glance how long it lasts.

#### Acceptance Criteria

1. WHEN an Event_Occurrence touches more than one date, THE Month_View SHALL draw it in each Week_Row it touches as one Span_Bar across all the day cells it covers in that Week_Row
2. THE Span_Bar SHALL show no gap at the borders between the day cells it covers
3. THE Span_Bar SHALL show the event name once, at the start of the Span_Bar, and cut it off at the end of the Span_Bar instead of wrapping it
4. THE Span_Bar SHALL have rounded corners at the first and last date of the Event_Occurrence and square corners at a Continuing_End
5. WHEN an Event_Occurrence touches one date, THE Month_View SHALL draw it as one Span_Bar one cell wide, looking as an Event_Chip did before
6. THE Span_Bar SHALL have the colour of its Event_Type, and the Soft_Chip style when the Event_Type is a notable day, as an Event_Chip does

### Requirement 2: Lanes

**User Story:** As a user, I want a bar to stay at the same height on all its days, so that it reads as one line.

#### Acceptance Criteria

1. THE Month_View SHALL keep an Event_Occurrence in the same Lane in all the day cells it covers within a Week_Row
2. THE Month_View SHALL give the Lanes first to the Event_Occurrences that touch more dates, then to all-day ones before timed ones, then to timed ones by start time, then by name
3. WHERE the Event_Occurrences of a Week_Row need at most three Lanes, THE Month_View SHALL show all of them
4. WHERE the Event_Occurrences of a Week_Row need more than three Lanes, THE Month_View SHALL show two Lanes and, in each day cell that has Event_Occurrences in the Lanes that are not shown, a "+N" label with their number
5. IF the day cells are too small for the Lanes to be shown, THEN THE Month_View SHALL show fewer Lanes and put the rest into the "+N" label, so that nothing leaves its cell

### Requirement 3: Interaction and Layout

**User Story:** As a user, I want the calendar to work as before when I tap it, so that bars change only how it looks.

#### Acceptance Criteria

1. WHEN a Span_Bar is tapped, THE Month_View SHALL open the Day_Sheet of the date under the finger
2. THE Month_View SHALL report to a screen reader, for each day cell, the date and the number of Event_Occurrences that touch it, as before
3. THE Month_View SHALL keep every Span_Bar inside its Week_Row, without overflow, at a screen width of 320 points and a text scale of 130 %
