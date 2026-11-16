# Questlog — Documentation

Reference material for working on Questlog. For what the app is and how to start it, see
[README.md](./README.md).

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
│   │                        validation, domain errors
│   ├── data/                Drift tables, database, models, mappers, preferences enums
│   ├── services/            quest, mission, recurrence and settings services, XP engine,
│   │                        Riverpod providers
│   ├── ui/
│   │   ├── theme/           design tokens (two palettes), typography, ThemeData
│   │   ├── state/           UI providers, reorder logic, reward queue, board-day signal
│   │   ├── screens/         board, missions, mission_detail, settings, shell
│   │   ├── sheets/          quest, mission, rule and font bottom sheets
│   │   ├── widgets/         cards, common, hero, reward, sheet
│   │   └── forms/           validators, posting day, error text
│   └── l10n/                app_cs.arb (template), app_en.arb, generated localizations
├── assets/
│   ├── fonts/               static TTFs: Figtree plus five temporary display families
│   └── icons/               24px SVG icons drawn with currentColor strokes
├── drift_schemas/           drift_schema_v1.json, the schema dump per version
├── test/                    mirrors lib/ (core, data, services, ui); goldens/, helpers/
├── scripts/                 check.sh, check-structure.sh
├── ios/, linux/             platform projects (iOS identity: ios/Flutter/AppIdentity.xcconfig)
├── .kiro/specs/             001-questlog-domain and 002-questlog-ui (requirements, design, tasks)
├── .design/                 the approved visual design: DESIGN.md, artboards/, screens/
├── .agents/                 development pipeline artifacts (state, issues, use cases, reports)
├── l10n.yaml                Flutter localization generator configuration
└── pubspec.yaml             dependencies, fonts, assets
```

### Data

One SQLite file, `questlog.sqlite`, in the platform's application documents directory
(`getApplicationDocumentsDirectory()`), opened lazily in a background isolate. Five
tables:

| Table | Holds |
|---|---|
| `quests` | name, note, difficulty, optional mission, sort order, completion time and awarded XP |
| `missions` | name, bonus size, status (open, completed, closed), awarded bonus, optional rule |
| `recurring_rules` | name, cadence, anchor date, next index, bonus size, last posted date |
| `rule_quests` | the quests a rule posts with each mission |
| `app_state` | the singleton row: total XP, hero name, language, theme, display font |

The schema is at version 1. A change to it needs a migration step in
`lib/data/database.dart` and a new dump in `drift_schemas/`.

### Rules of the game

| Rule | Value |
|---|---|
| Quest XP | easy 10, normal 25, hard 50 |
| Mission bonus | small 50, medium 100, large 200 |
| XP to advance from level L | 100 + 50 × (L − 1) |
| Board day | starts at 04:00 local time |
| Recurring cadences | daily, weekly, biweekly, monthly, quarterly, yearly |

Out of scope in version 1: due dates, streaks, a history screen, notifications and
projects.

### Temporary display-font picker

Settings has a "Title font" row that opens a sheet with six display faces (Figtree,
Bricolage Grotesque, Sora, Outfit, Unbounded, Cinzel). It only changes titles and
numbers; body text and controls always stay in Figtree. It exists until the final font is
chosen, after which the picker, the five other font families and their ARB keys are
removed.

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

Known open points (accessibility contrast of a few palette pairs, the iOS-only checks, the
unused translation keys) are tracked in `.agents/ISSUES.md`.
