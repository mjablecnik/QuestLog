# Phase 5 — Docs

**Target:** `.` (the whole Flutter app, passed by the orchestrator).

## Result
OK WITH ISSUES

## Headline
`CLAUDE.md` no longer claims that no code or git repository exists; it now describes the implemented app, its real layout, commands and gotchas. `README.md` was rewritten to the standard's section order and a new `DOCS.md` was added. Every documented command was run and works; `.env.example` has no keys because the code reads no environment variables, so the two agree.

## Needs attention
- Two LOW entries opened in `.agents/ISSUES.md`: the bundled fonts have no OFL licence files although `pubspec.yaml` says they do, and no project licence is chosen (README says "all rights reserved").
- The iOS build is described but not run (no Mac here); it stays Martin's to verify.
- The display-font picker removal also needs a schema v2 migration if the `display_font` column should go (written into `CLAUDE.md`).

## What changed
- `CLAUDE.md`: status, commands (pub get, codegen, check, single test, goldens, run), real layout, agent rules kept (no due dates/streaks/history/notifications/projects), temporary font-picker removal list, sandbox gotchas, git rules (local only, never push).
- `README.md`: hero, ToC, Description, Prerequisites, Installation, Usage, Deployment, Documentation, Author, Support, License. Corrects the earlier claim of a Quests/Missions/Settings structure: the shell has two tabs and Settings opens from the hero-bar gear.
- `DOCS.md` (new): environment variables (none), structure, data tables, game rules, testing, troubleshooting.
- `.agents/ISSUES.md`: two LOW entries. `.agents/PIPELINE_STATE.json`: docs phase recorded.

Commands run and confirmed: `flutter pub get`; `timeout 500 dart run build_runner build` (exit 0, 50 s, no diff in generated files); `scripts/check.sh` (analyze clean, 660 tests, structure OK) both under `xvfb-run -a` and without it; `flutter test test/core/xp_rules_test.dart`; `flutter test --update-goldens test/goldens` (no golden changed); `flutter analyze`; `scripts/check-structure.sh` and `--list`; `xvfb-run -a flutter run -d linux` (builds and starts; stopped by timeout).
Not run: the iOS build.

## Decisions made
- Full README treatment (personal app) but without badges, since none is checkable, and without the footer block, because there is no remote for bug-report links.
- Created `DOCS.md` although there are no environment variables and no API: the project has a non-trivial structure, data model, testing and troubleshooting content.
- Documented that tests need no display (verified), only `flutter run` does, so `xvfb-run` is not prefixed on `check.sh`.
- Left `.env.example` as the comment-only file the earlier phases created; it satisfies the standard and matches the code.
- Left alone: no foreign dirty paths existed.
