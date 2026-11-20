# Questlog — Documentation

Reference material for working on Questlog. For what the app is and how to start it, see
[README.md](./README.md); for the full feature list, [FEATURES.md](./FEATURES.md).

## Environment Variables

None. Questlog is a local-only app with no server, no account and no network access at
runtime, so it reads no environment variables. `.env.example` exists only to state that,
as the project standard requires it; it holds no keys, and the code holds no `.env`
loader.

## Project Structure

```
questlog/
├── lib/
│   ├── main.dart            entry point: opens the database, starts the ProviderScope
│   ├── app.dart             root widget: theme, locale, shell
│   ├── core/                pure Dart: clock, board day (04:00), XP and levels, cadence,
│   │   │                    validation, domain errors
│   │   ├── calendar/        event types, repeat rules, Easter, event XP, month grid dates
│   │   └── notes/           the notes tree (listing, moving, visibility, trash), names and previews, trash policy
│   ├── data/                Drift tables, database, models, mappers, preferences enums
│   │   ├── calendar/        calendar tables, models, mappers, the one-time seed, filter store
│   │   └── notes/           the note_nodes table and its mappers
│   ├── services/            quest, mission, recurrence and settings services, XP engine,
│   │                        Riverpod providers
│   │   ├── calendar/        calendar service and its providers
│   │   └── notes/           notes service and its providers
│   ├── ui/
│   │   ├── theme/           design tokens (two themes of the blue palette), typography, ThemeData
│   │   ├── state/           UI providers, reorder logic, reward queue, board-day signal
│   │   ├── screens/         board, missions, mission_detail, settings, shell, calendar, notes (list and Trash), note_editor
│   │   ├── sheets/          quest, mission and rule bottom sheets (calendar/: filter, month picker, delete; notes/: add, name, move, link)
│   │   ├── widgets/         cards, common, hero, reward, sheet
│   │   └── forms/           validators, posting day, error text
│   └── l10n/                app_cs.arb (template), app_en.arb, generated localizations
├── assets/
│   ├── fonts/               static TTFs of Figtree, the one typeface of the app
│   │   └── licenses/        one SIL OFL text per family, `<Family>-OFL.txt`
│   └── icons/               24px SVG icons drawn with currentColor strokes
├── drift_schemas/           drift_schema_v1.json to v6, the schema dump per version
├── test/                    mirrors lib/ (core, data, services, ui); goldens/, helpers/
├── scripts/                 check.sh, check-structure.sh
├── screenshots/             the five README screenshots (English, dark theme, 780x1688)
├── ios/, linux/             platform projects (iOS identity: ios/Flutter/AppIdentity.xcconfig)
├── .kiro/specs/             001-questlog-domain to 010-questlog-quest-deadline (requirements, design, tasks)
├── .design/                 the approved visual design: DESIGN.md, artboards/, screens/, icon/ (app icon + launch screen generator)
├── .agents/                 development pipeline artifacts (state, issues, use cases, reports)
├── l10n.yaml                Flutter localization generator configuration
└── pubspec.yaml             dependencies, fonts, assets
```

### Data

One SQLite file, `questlog.sqlite`, in the platform's application documents directory
(`getApplicationDocumentsDirectory()`), opened lazily in a background isolate. Ten
tables:

| Table | Holds |
|---|---|
| `quests` | event (`event_id`, the calendar event of the Deadline, cleared when that event is deleted), name, note, effort tier (column `difficulty`), optional mission, Board section (`board`: `todo`, `today` or null = not on the Board; quests without a mission are never null), sort order, completion time and awarded XP |
| `missions` | name, bonus size, status (open, completed, closed), sort order, awarded bonus, optional rule |
| `recurring_rules` | name, cadence, anchor date, next index, bonus size, last posted date |
| `rule_quests` | the quests a rule posts with each mission |
| `app_state` | the singleton row: total XP, hero name, language, theme (the old display font column stays, unused) |
| `calendar_events` | name, note, location, event type, start and end (a date plus minutes since midnight, no time zone, no minutes for an all-day event), repeat rule and its end, the On_Board flag |
| `calendar_skipped_dates` | dates on which a repeating event is deleted for one occurrence |
| `calendar_completions` | the completed occurrences of events (event, date, time, awarded XP) |
| `calendar_addresses` | the addresses saved on events (lower-cased key, last spelling, last use), for suggestions; forgotten 30 days after the last use |
| `note_nodes` | Folders and Notes in one table: optional parent (none is the top level; deleting a folder row deletes what is inside it), folder flag, name, the Markdown body, whether the name follows the first line, created, edited and deleted times |

The schema is at version 6 (v6 added `quests.event_id`; v5 added `calendar_addresses`; v4 added `note_nodes`; v3 added the three calendar tables and fills them once with 35 built-in events: 13 Czech public holidays, 16 notable and folk days and 6 name days; v2 added `quests.board` and `missions.sort_order`; the upgrade puts every quest without a mission in Todo and keeps the old Mission order). Adding the fourth effort tier (`fullDay`) needed no migration:
`quests.difficulty` and `rule_quests.difficulty` are plain text holding the enum name, with no
`CHECK`, so the stored values `easy`, `normal` and `hard` keep their meaning. A change to the
schema needs a migration step in
`lib/data/database.dart` and a new dump in `drift_schemas/`.

### Calendar

The Kalendář tab is independent of quests and missions except for one link: an event with
`on_board` set appears on the Board, in Today, on the Board_Day whose date is the event's
start date, and completing it awards XP once (a completion row per event and date; reopening
removes it and the XP). Occurrences of a repeating event are never stored: the service expands
the rule for the range on screen (daily, weekly, monthly and yearly reuse `occurrenceDate` of
`lib/core/cadence.dart`; two built-in rules exist only for the seed: relative to Easter, and
the n-th weekday of a month). Event XP: a timed event 10 / 25 / 50 / 100 XP by length (up to
30 min, 2 h, 5 h, longer); an all-day event 10 XP for birthday, name day, public holiday,
notable day and date, 25 XP for the rest. The calendar uses the calendar day (midnight), the
Board uses the Board_Day (04:00). The type filter is remembered in `calendar_filter.txt` beside
the database. In the month view an event of several days is one bar per week row across the days it
covers (`layoutWeek` in `lib/ui/screens/calendar/week_lanes.dart` gives each bar a lane, the same on
all its days; up to three lanes show, more show two and a "+N" in the days that have events in the
lanes left out). The Address field of the event form lists the remembered addresses that match what is typed (up to 5, newest first); an address is forgotten 30 days after its last use, at start and on every lookup, and the event keeps its own (spec `008-questlog-address-history`). Notifications, an event URL, week and day views and user-defined types are not
part of it (specs `003-questlog-calendar`, `006-questlog-calendar-spans`).

### Notes

The Poznámky tab is independent of the rest of the app and awards no XP. Folders and Notes are rows of
`note_nodes`; `NoteTree` (`lib/core/notes/`) holds every rule about the tree in pure Dart, and
`NotesService` streams all rows, so the tree is built in memory. Deleting sets `deleted_at` on one row, so
a Folder goes to the Trash with everything inside it; a node is visible only while neither it nor any
ancestor is trashed. Restore clears the time, or first moves the node to the top level when its parent
is gone or trashed. A Trashed_Node is purged 30 days after its deletion time (at start, on return from
the background and when the Trash opens); the foreign key's cascade removes what is inside it. A Note's
text is Markdown, edited with `super_editor` in `lib/ui/screens/note_editor/`; `note_markdown.dart` converts
between the two and escapes plain text, because the package's own codec changes text typed in a WYSIWYG
editor (for example ABAP field symbols such as `<fs_line>`). The language after a code fence is not kept.
A Note has a title field above its text. A typed title is the Note's name; with an empty title the name
follows the first line of the text (and the title field stays empty), and renaming from the menu also sets
a chosen name. A Note in the Trash opens in a read-only preview (`trash_preview_screen.dart`, a
`SuperReader` with the editor's stylesheet) with an Obnovit button; opening it changes nothing.
Search, tags, images, tables, opening links and a Trash undo are not part of it (specs
`004-questlog-notes`, `005-questlog-note-title`, `007-questlog-trash-preview`). The editor keeps the package's own overlays (accent colour
set) so that iOS shows the caret, the selection handles and the Cut, Copy and Paste toolbar; copy and paste
carry plain text only.

### Quest Deadline

A Quest may have a Deadline. Saving one creates an all-day event of the type Quest (not on the Board) named like the Quest and links it in `quests.event_id`; the Deadline is that event's end date, so changing the event in the Calendar changes the Deadline, and deleting the event (or undoing it) only clears (or restores) the link. Clearing the Deadline in the Quest sheet deletes the event, deleting the Quest deletes its event, and renaming the Quest renames the event. An open Quest whose Deadline is before the Board_Day shows "Overdue" in the destructive colour on its card (Board and Mission detail); a done Quest does not. Completing is only possible on the Quest (spec `010-questlog-quest-deadline`).

### Deep links

The URL scheme `questlog` (registered in `ios/Runner/Info.plist`) opens a tab: `questlog://quests`, `missions`, `calendar`, `notes` or `settings`; anything else is ignored. To get a Home Screen icon that opens the Calendar: in the iOS Shortcuts app make a shortcut with the action "Open URLs" and the URL `questlog://calendar`, then Share → Add to Home Screen and pick a name and an icon; the icon can be put in a folder. The same steps are in the app under Settings → Home Screen shortcut (`lib/ui/screens/settings/shortcut_guide.dart`): pick a tab, copy its link, follow the numbered steps. See `lib/ui/screens/shell/deep_link.dart` (spec `009-questlog-deep-links`).

### Data export

Settings → Data → Export data writes every table of the database into one JSON file (`questlog-export-<date>.json`, in the temporary directory) and opens the system share sheet, so the file can be saved to Files or sent with AirDrop. The export walks `db.allTables` and copies rows as stored, so a table or column added by a later migration is exported without changes (`lib/data/database_export.dart`, `lib/services/export_service.dart`, `lib/ui/screens/settings/export_row.dart`). The file has `format` (`questlog-export`), `formatVersion`, `app`, `appVersion`, `schemaVersion`, `exportedAt`, `rowCounts` (rows per table, for checking an import) and `tables` (table name to a list of rows keyed by column name). Integers stay integers, so dates and booleans keep the database representation; a BLOB would be `{"$blob": "<base64>"}`. There is no import yet.

### Rules of the game

| Rule | Value |
|---|---|
| Quest XP (effort tier) | 1 Moment 10, 2 Hour 25, 3 Part of a day 50, 4 Full day 100 |
| Mission bonus | small 50, medium 100, large 200 |
| XP to advance from level L | 100 + 50 × (L − 1) |
| Board day | starts at 04:00 local time |
| Recurring cadences | daily, weekly, biweekly, monthly, quarterly, yearly |

Out of scope in version 1: streaks, a history screen, notifications and projects, and any
due date except the optional Quest Deadline.

### Font licences

The bundled font family (Figtree) is under the SIL Open Font License 1.1, which requires the licence
text to travel with the fonts. The unmodified texts from `google/fonts` are bundled as
`assets/fonts/licenses/<Family>-OFL.txt` and registered with Flutter's `LicenseRegistry` at
app start (`registerFontLicenses` in `lib/core/font_licenses.dart`). Settings → About →
"Licenses" opens Flutter's licence page, which lists them as "<Family> (font)" beside the
framework and package licences. A test fails when a font file has no licence file.

### Palette

The app has one palette in two themes, the blue one Martin chose on 2026-11-19 (it follows
TimeLog's Midnight theme). `brass` is the accent colour in the code (the name is kept to avoid
churn).

| Theme | Board / accent | Notes |
|---|---|---|
| Dark (`guildBoard`) | `#0F1319` / `#78B4C4` | Quest cards are dark raised cards (`slip*` roles), not parchment slips. |
| Light (`daylight`) | `#EDF1F6` / `#2B7287` | Quest cards are paper slips. |

The reward card and the empty-state slip stay parchment. Every body-text pair reaches 4.5:1,
the accent as text (`brassText` on boards, `brassOnParchment` on slips) 4.5:1 and the accent as
a fill 3:1 (`test/ui/theme/contrast_test.dart`). The temporary palette switch (Original, Higher
contrast, Blue, Green) was removed together with its `palette_choice.txt` file, which is no
longer read.

## Testing

The tests are headless and need no display (also true for the golden tests); only running
the app does.

```bash
scripts/check.sh                                # analyze + all tests (about 4 min) + structure check
flutter test                                    # every test
flutter test test/core/xp_rules_test.dart       # one test file
flutter test --update-goldens test/goldens      # regenerate goldens (deliberately)
flutter analyze                                 # static analysis only
scripts/check-structure.sh --list               # file count per directory
```

`check-structure.sh` fails when a directory holds more than 15 source files.

What the tests cover: the pure rules in `test/core/`, the database and services in
`test/data/` and `test/services/` (including property tests with `glados`), and the
screens, widgets, accessibility, localization and design-token guards in `test/ui/`.
`test/ui/e2e_scenario_test.dart` plays a whole day in the app, and the goldens in
`test/goldens/` cover Board, Missions and Settings in both themes. There is no coverage
tooling configured.

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `fatal: detected dubious ownership in repository at '/opt/flutter'` | Git distrusts the SDK directory. Run `git config --global --add safe.directory /opt/flutter` once. |
| `flutter run -d linux` fails with no display | Prefix it with `xvfb-run -a`; only running the app needs a display, the tests do not. |
| Analyzer errors about a missing `database.g.dart` | Run `dart run build_runner build`; it takes about a minute, so give it a longer timeout than a shell's default. |
| Widget tests overflow although the app does not | Tests draw text in the Ahem fallback unless the bundled fonts are loaded; use `test/ui/a11y/_a11y_harness.dart`. |
| A test hangs while it reads a Riverpod stream | Riverpod 3 pauses stream providers without a listener; call `container.listen(provider, (_, _) {})` first. |
| Importing `glados` and `flutter_test` is ambiguous | Hide the clashing symbols on the `glados` import. |
| Goldens differ after a design change | Regenerate them with `--update-goldens` and review the images in the diff. |

Known open points (the iOS-only checks, the
unused translation keys) are tracked in `.agents/ISSUES.md`.
