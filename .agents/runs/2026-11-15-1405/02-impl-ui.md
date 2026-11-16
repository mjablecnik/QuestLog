# Phase 1b — Implementation (spec 002-questlog-ui)

**Target:** `.` (the repository root is the single Flutter project) — passed by the orchestrator. Spec: `002-questlog-ui`.

## Result
OK WITH ISSUES

## Headline
All tasks of `002-questlog-ui` are implemented and checked off in `tasks.md`, including the optional golden tests (14.3) and the checkpoints. `scripts/check.sh` is green: analysis clean, 638 tests passing, structure check clean; `xvfb-run -a flutter run -d linux` builds and starts without exceptions. Two issues were opened (one MEDIUM palette contrast, one LOW unused strings).

## Needs attention
- MEDIUM in `.agents/ISSUES.md`: the approved palette fails 4.5:1 body-text contrast for several pairs (requirement 16.6). Fixing it means changing the approved `.design` colours, which needs Martin's sign-off. `test/ui/theme/contrast_test.dart` pins the known gaps so regressions and fixes are both noticed.
- LOW in `.agents/ISSUES.md`: ARB keys `a11y_dragHandle` and `a11y_openSettings` are unused (the labels come from other strings).
- The iOS build and on-device check are not covered (sandbox has Linux only).

## What changed
- `lib/ui/`: theme and tokens, shared widgets (cards, check circle, hero bar, sheet scaffold, reward card/overlay, segmented control), app shell, Board, Missions, Mission detail, Settings (profile, language, theme, rules, temporary font picker), Quest/Mission/Rule/Font sheets; `lib/l10n/` cs+en ARB files.
- `lib/app.dart`: now hosts `RewardOverlay` in the `MaterialApp` builder, above the Navigator; `AppShell` no longer contains it.
- `lib/ui/widgets/common/questlog_segmented.dart`: the selected option gets a heavier outline while pressed.
- `lib/ui/screens/settings/settings_screen.dart`, `open_settings.dart`: name field touch target raised to 44 px; settings snackbars cleared on return.
- Tests: per-component and per-screen widget tests, property tests (properties 1-6 of the design), `test/ui/e2e_scenario_test.dart`, `test/ui/theme/token_usage_test.dart`, `test/ui/a11y/` (layout 320/430 at 1.3 scale in cs/en, touch targets, semantic labels, announcements, pressed state, reduced motion, catalogue check), `test/goldens/` (Board, Missions, Settings, dark and light; PNGs committed).
- Per-task Conventional Commits, kept as they are (no squash, as instructed by the orchestrator).

## Decisions made
- The reward overlay moved to `QuestlogApp`'s builder: a reward earned on the pushed Mission detail route was invisible because the shell is offstage under that route (requirements 7.1/10.6). A regression test (`test/ui/screens/shell/reward_over_route_test.dart`) covers it.
- Layout tests load the real bundled fonts with `FontLoader`; the test engine's square-glyph font is about twice as wide and produced false overflows.
- Palette left as approved by the design; contrast gaps are logged rather than silently changed.
- Pressed-state test skips text fields (they answer a touch with focus, not a press).
- Goldens use the seeded Czech data and real fonts at 390x844.
- Lessons appended to `.agents/MEMORY.md` (Drift deadlock in widget tests, Ahem font, animation frame timing, shell hygiene).

Foreign dirty paths left alone: none.
