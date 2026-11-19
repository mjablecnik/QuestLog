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
Calendar (2026-11-19, Martin's request, spec `003-questlog-calendar`; schema v3): a fourth tab, Kalendář, with a month
overview, day sheet, event detail, event form, search and a type filter. Ten fixed event types with their own colour, repeat
(daily, weekly, monthly, yearly), Czech public holidays, notable days and name days seeded once. An event with `On the board`
shows on the Board as a task on its day and awards 10-100 XP (by length, or by type when all-day). The tab has no hero bar.
README screenshots do not show the calendar yet (retake them).
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
  core/                 pure Dart: clock, board day (04:00), XP/levels, cadence, errors; calendar/ (types, repeats, Easter, event XP)
  data/                 Drift tables, database (+ .g.dart), models, mappers, preferences; calendar/ (tables, seed, filter store)
  services/             quest/mission/recurrence/settings services, XP engine, providers; calendar/ (service, providers)
  ui/                   theme/ (tokens, typography), state/, screens/, sheets/,
                        widgets/ (cards, common, hero, reward, sheet), forms/
  l10n/                 ARB files (cs, en) + generated localizations
assets/fonts, assets/icons   bundled static TTFs (+ licenses/ OFL texts) and 24px SVG icons (nothing fetched at runtime)
drift_schemas/               schema dump per version (currently v3)
scripts/                     check.sh, check-structure.sh (max 15 source files per directory)
screenshots/                 README screenshots (English, dark theme, real app at 2x); retake them after visible UI changes
test/                        mirrors lib/ (core, data, services, ui) + goldens/, helpers/
.kiro/specs/                 001 domain, 002 UI, 003 calendar: requirements, design, tasks
.design/                     approved visual contract (DESIGN.md, artboards/, screens/, icon/generate.mjs = app icon + launch screen)
.agents/                     pipeline artifacts: PIPELINE_STATE.json, ISSUES.md, MEMORY.md,
                             USE_CASES.md, runs/2026-11-15-1405/ (one report per phase)
```

Humans read `README.md` and `DOCS.md`; do not duplicate them here.

## Rules for any agent working here

- Follow the Kiro spec workflow (`kiro-spec` skill) and the global standards in
  `~/.claude/standards/` (English code/docs, Czech+English user-facing strings).
- Where `.design/` artboards and spec requirements differ, the requirements win.
- No due dates, streaks, history screen, notifications or projects in v1 — do not add
  scope the specs do not ask for.
- No `DateTime.now` outside `lib/core/clock.dart`, no literal colours, durations or
  spacing in `lib/ui`, no icon-font icons; guard tests under `test/` fail on them.
- Bundle id `com.jablecnik.questlog`, display name `Questlog`: iOS reads both from
  `ios/Flutter/AppIdentity.xcconfig`; Linux keeps its own copy of the id
  (`APPLICATION_ID` in `linux/CMakeLists.txt`).

## Temporary display-font picker

Settings has a "Title font" row and a `FontSheet` offering six display faces (Figtree,
Bricolage Grotesque, Sora, Outfit, Unbounded, Cinzel) so Martin can choose one. Once he
has, remove: `lib/ui/screens/settings/font_section.dart`, `lib/ui/sheets/font_sheet.dart`,
`displayFontProvider`, the five unchosen families in `pubspec.yaml` and `assets/fonts/`,
the licence files and `lib/core/font_licenses.dart` entries of those five families
(`assets/fonts/licenses/<Family>-OFL.txt`, SIL OFL: they must leave together with their
fonts), and the `font_*` ARB keys. The `display_font` column of `app_state` needs a schema v3
migration to drop it (plus a new dump in `drift_schemas/`), or can stay unused.
Figtree stays as the body face either way.

## Temporary palette switch

Settings has a "Palette" control with four options (Original, Higher contrast, Blue, Green),
same lifetime as the font picker. In every palette `brass` is the accent colour. Remove once
Martin has chosen: `lib/ui/screens/settings/palette_section.dart`,
`lib/ui/state/palette_choice.dart`, `lib/data/palette_choice_store.dart`, the palette
selection in `lib/app.dart` and `lib/main.dart`, the losing palettes in `tokens.dart`
(`guildBoardHighContrast`, `daylightHighContrast`, `blueDark/Light`, `greenDark/Light`), the
`settings_palette*` ARB keys, their tests (`palette_section_test.dart`, the palette cases in
`palette_choice_store_test.dart`, `contrast_test.dart`, `theme_test.dart`, `layout_test.dart`)
and the `board_{blue,green}_*` goldens (regenerate `settings_*` goldens). The winner's values
are folded into `guildBoard`/`daylight` (including the `slip*` roles, which dark palettes derive from `brightness` and light ones from the parchment values); if a non-Original palette wins, keep or drop
`brassText`/`brassOnParchment` and delete `_knownGaps` in `test/ui/theme/contrast_test.dart`.
The choice lives in `palette_choice.txt` beside the database (not in it), so no migration is
involved. The app icon and launch screen are not re-tinted by any palette.

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
