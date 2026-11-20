# Questlog

Personal gamified TODO app for a single user (Martin): **Quests** (one-off tasks) and
**Missions** (long-term goals made of quests), XP and levels, recurring missions posted
from rules. Flutter, iOS primary (Linux desktop is used for development and tests),
local-only SQLite via Drift + Riverpod — no server, no account, no network at runtime.

## Status

Both specs (`001-questlog-domain`, `002-questlog-ui`) are fully implemented and verified
on the Linux desktop app (pipeline run `2026-11-15-1405`); `scripts/check.sh` is green.
Quests have four effort tiers (10/25/50/100 XP, 2026-11-18, Martin's request; no migration).
Board sections (2026-11-19, Martin's request; schema v2): the Board has Today and Todo. New quests
land in Todo; a quest moves between sections by long-press drag (one flat reorderable list, the
section headers are non-draggable entries) or the Board picker of the quest sheet. A mission's quests
are off the Board (`quests.board` null) until Martin posts one, then it shows in Today/Todo, with
the mission name on its card; the sheet's "Off the board" removes it again. Missions are reorderable
by long-press drag (`missions.sort_order`). Quests without a mission always have a section.
In the dark theme Quest cards are dark raised cards, not parchment slips (2026-11-18, Martin's
request; `slip*` roles in `tokens.dart`); the light theme is unchanged.
Calendar (2026-11-19, Martin's request, spec `003-questlog-calendar`; schema v3): a tab, Kalendář, with a month
overview, day sheet, event detail, event form, search and a type filter. Eleven fixed event types (the eleventh, Quest, is the lime event of a Quest Deadline) with their own colour, repeat
(daily, weekly, monthly, yearly), Czech public holidays, notable days and name days seeded once. An event with `On the board`
shows on the Board as a task on its day and awards 10-100 XP (by length, or by type when all-day). The tab has no hero bar.
Notes (2026-11-19, Martin's request, spec `004-questlog-notes`; schema v4): a fifth tab, Poznámky, between Kalendář and Nastavení. Folders and
sub-Folders of any depth hold Notes written in a WYSIWYG editor (`super_editor`; the stored text is Markdown, converted by
`lib/ui/screens/note_editor/note_markdown.dart`, which escapes plain text because the package's own codec is lossy) that saves by itself.
Rename, move and delete work from a swipe and from a menu; deleting moves a node to a Trash (30 days, then purged at start, on
return from the background and when the Trash opens). No XP, no hero bar. The mission ring now shows the quests still open.
A Note has a title field (2026-11-20, Martin's request, spec `005-questlog-note-title`): a typed title is the name, an empty
one leaves the name to the first line of the text; the editor keeps `super_editor`'s default overlay list (accent colour set), because a
list with the desktop caret alone leaves iOS with no caret, handles or Cut/Copy/Paste toolbar.
A Note in the Trash opens in a read-only preview (spec `007-questlog-trash-preview`; `SuperReader`, Obnovit button).
Month view (2026-11-20, Martin's request, spec `006-questlog-calendar-spans`): an event of several days is one bar per week
row across its days, lanes from `layoutWeek` (`lib/ui/screens/calendar/week_lanes.dart`) so a bar keeps one height.
Address history (2026-11-20, Martin's request, spec `008-questlog-address-history`; schema v5): the Event_Form suggests addresses saved on earlier events, from the `calendar_addresses` table, forgotten after 30 days without use (no map service: there is no network).
Deep links (spec `009-questlog-deep-links`): `questlog://calendar` (also quests, missions, notes, settings) opens that tab; Martin makes the Home Screen icon in Shortcuts (Open URL, Add to Home Screen). Package `app_links`; `deepLinksProvider` is empty except in `main`.
Quest Deadline (2026-11-20, Martin's request, spec `010-questlog-quest-deadline`; schema v6): a Quest may have a date; it is an all-day event of the type Quest in the Calendar linked by `quests.event_id` (`ON DELETE SET NULL`), the Deadline is the event's end date, so editing the event moves it, deleting the event leaves the Quest without a date. An open Quest after its Deadline shows "Po termínu" (`destructiveText`). Completing happens only on the Quest.
Not done: the iOS build and every on-device check — Martin does those himself (open LOW
entry in `.agents/ISSUES.md`).

## Commands

Run from the project root. Once per sandbox:
`git config --global --add safe.directory /opt/flutter` (skill `sandbox-flutter`).

```bash
flutter pub get
timeout 500 dart run build_runner build   # Drift codegen, ~50 s: run it in the background and poll the log
scripts/check.sh                          # analyze + all tests (~4 min) + structure check: the gate
flutter test test/core/xp_rules_test.dart                  # one test file
flutter test --update-goldens test/goldens                 # regenerate goldens, deliberately
xvfb-run -a flutter run -d linux          # run the app (the sandbox has no DISPLAY)
```

`l10n.yaml` + `generate: true` regenerate `lib/l10n/app_localizations*.dart`; edit only the
`.arb` files (`app_cs.arb` is the template). `lib/data/database.g.dart` is committed.

## Layout

```
lib/
  main.dart, app.dart   entry point; root widget (theme, locale, shell)
  core/                 pure Dart: clock, board day (04:00), XP/levels, cadence, errors; calendar/ (types, repeats, Easter, event XP); notes/ (tree rules, names, trash policy)
  data/                 Drift tables, database (+ .g.dart), models, mappers, preferences; calendar/ (tables, seed, filter store); notes/ (note_nodes table)
  services/             quest/mission/recurrence/settings services, XP engine, providers; calendar/ (service, providers); notes/ (service, providers)
  ui/                   theme/ (tokens, typography), state/, screens/, sheets/,
                        widgets/ (cards, common, hero, reward, sheet), forms/
  l10n/                 ARB files (cs, en) + generated localizations
assets/fonts, assets/icons   bundled static TTFs (+ licenses/ OFL texts) and 24px SVG icons (nothing fetched at runtime)
drift_schemas/               schema dump per version (currently v6)
scripts/                     check.sh, check-structure.sh (max 15 source files per directory)
screenshots/                 README screenshots (English, dark theme, real app at 2x); retake them after visible UI changes
test/                        mirrors lib/ (core, data, services, ui) + goldens/, helpers/
.kiro/specs/                 001 domain, 002 UI, 003 calendar, 004 notes, 005-010 later changes: requirements, design, tasks
.design/                     approved visual contract (DESIGN.md, artboards/, screens/, icon/generate.mjs = app icon + launch screen)
.agents/                     pipeline artifacts: PIPELINE_STATE.json, ISSUES.md, MEMORY.md,
                             USE_CASES.md, runs/2026-11-15-1405/ (one report per phase)
```

Humans read `README.md`, `FEATURES.md` and `DOCS.md`; do not duplicate them here.

## Rules for any agent working here

- Follow the Kiro spec workflow (`kiro-spec` skill) and the global standards in
  `~/.claude/standards/` (English code/docs, Czech+English user-facing strings).
- Where `.design/` artboards and spec requirements differ, the requirements win.
- No streaks, history screen, notifications or projects in v1, and no due dates except the
  optional Quest Deadline of spec `010` — do not add scope the specs do not ask for.
- No `DateTime.now` outside `lib/core/clock.dart`, no literal colours, durations or
  spacing in `lib/ui`, no icon-font icons; guard tests under `test/` fail on them.
- Bundle id `com.jablecnik.questlog`, display name `Questlog`: iOS reads both from
  `ios/Flutter/AppIdentity.xcconfig`; Linux keeps its own copy of the id
  (`APPLICATION_ID` in `linux/CMakeLists.txt`).

## Typography

One face, Figtree, for body text and titles alike (Martin's choice, 2026-11-20; the title-font picker and
the other five families are gone). Titles and XP figures differ only in weight and tight spacing
(`buildDisplayTextTheme` in `lib/ui/theme/typography.dart`). The `display_font` column of `app_state`
stays in the schema, unused, so that no migration is needed.

## Palette

The only palette is the blue one (Martin's choice, 2026-11-19): `guildBoard` is its dark theme,
`daylight` its light theme, both in `lib/ui/theme/tokens.dart`; `brass` is the accent colour. The
temporary palette switch is gone. The old `palette_choice.txt` beside the database is no longer
read. The app icon and launch screen were not re-tinted.

## Sandbox gotchas

- Only Linux desktop/web run here; the iOS build and device checks are Martin's.
- Do NOT add `sqlite3_flutter_libs`. `glados` clashes with `flutter_test` names: hide the
  clashing symbols on the glados import.
- Widget tests draw text in Ahem unless the bundled fonts are loaded (see
  `test/ui/a11y/_a11y_harness.dart`); Riverpod 3 stream providers need a listener in
  tests. More lessons: `grep -n -i <topic> .agents/MEMORY.md` (never read it whole).
- Never `pkill -f` / `pgrep -f` by pattern (it matches its own shell), and never run
  `dart format` on a whole file that is not already formatted.

## Git

Local repository, no remote: never push. Author exactly
`Martin Jablečník <martin.jablecnik@email.cz>`; one Conventional Commit per task or
logical change (`feat:`, `fix:`, `test:`, `docs:`, `chore:`...), per
`~/.claude/standards/code-git.md`. Never add tool-attribution trailers
(no Co-Authored-By/Generated-with/session links).
