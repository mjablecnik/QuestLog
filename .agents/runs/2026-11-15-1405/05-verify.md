# Phase 4 — Verify

**Target:** `.` (the whole Flutter app, passed by the orchestrator). Services: none; Questlog has no server, the walkthrough ran the real Linux release bundle `build/linux/x64/release/bundle/questlog` under Xvfb against a scratch SQLite file, so no `ENV_SETUP.md` was needed.

## Result
OK WITH ISSUES

## Headline
97 of the 99 walkthrough steps were run against the real app and ticked; 0 failed and 0 are blocked. Of the use cases, about 163 passed, 5 are iOS-only (handed over), UC-141 (contrast) fails by the already accepted MEDIUM entry and UC-129 (schema migration) cannot be verified because the schema is still version 1. Every defect found on the way was fixed with its own commit and a regression test; `xvfb-run -a scripts/check.sh` is green (analyze clean, 660 tests, structure check OK).

## Needs attention
- Step 99 and the iOS-only cases (UC-008, keyboard half of UC-029/UC-145, felt haptics of UC-144, UC-169) need Martin on an iOS build; one LOW entry opened in `.agents/ISSUES.md`.
- Step 97 (body-text contrast, UC-141) is deliberately not ticked: it still fails by the accepted MEDIUM palette entry, and the pinned `_knownGaps` in `test/ui/theme/contrast_test.dart` did not grow.
- Accepted LOW entries stay open: no `system` language option, UC-129, unused a11y strings, the "QUEST SPLNĚNO" caption.
- `CLAUDE.md` still says "No code exists yet"; left for the docs phase.
- Commits of this phase were not squashed, as the orchestrator instructed.

## What changed
Fixes (28 commits since `f8d9c7a`, each one change):
- Mission detail: progress fill is drawn (0450179); a stale row explains itself and refreshes (24ab388).
- Reopen message counts the withdrawn bonus (888eccd, test 2f76af0).
- Board and Missions visuals aligned with the artboards, both themes: date line wraps and uses the numeric Czech form (5210dc0, 9b9526c), rhythm/line heights/add button (a0077ce), hero XP text wraps (463249c), Daylight done-card outline and shadow (848d386), empty state position (2369db0), create-sheet button icons (902e06b), reward card XP unit and track (a4fd03c), rules count in capitals (17c90e9), Figtree/Bricolage Czech notes (0f5f8f8).
- Posted-missions snackbar uses the stored language (9e09693, test 4984e1e).
- Every list reloads after a stale-item or rejected-reorder error (c59123e, 31ed526).
- Storage failures from the database isolate and from settings writes become `StorageError` (c292fed, 6cb2fab, b4e32c2).
- New guards: no `DateTime.now` outside the clock (dd38ceb), no icon-font icons (5f2544b, 6e1436e), literal spacing/radius scan (f389ac1), token values pinned (a1cedf8), empty-state tokens (0bc3425), haptic calls asserted in a full-app test (dbb3135).

Observations, not defects: the empty Mission shows "Zbývá: 0 XP" (spec-driven); Linux `APPLICATION_ID` in `linux/CMakeLists.txt` is a second copy of the bundle id (iOS reads `ios/Flutter/AppIdentity.xcconfig`); the MaterialIcons font is bundled as a stub and `cupertino_icons` is declared but nothing uses them; the schema is still version 1.

Left alone: no foreign dirty paths existed. `.agents/tmp/VERIFY_TASKS.md` was consumed and deleted.

## Decisions made
- Did not fix the accepted MEDIUM contrast gap, the missing `system` language, or the caption mismatch; the brief listed them as accepted.
- Accepted deviations from the artboards, recorded rather than changed: the "Vyvěšeno" pill outline, the artboard's richer rule subtitle, the Profile section, 44 px chips, and the level formula (the requirements win over artboards).
- Mapped `DriftRemoteException` (experimental drift API) instead of catching generic exceptions, since it is the only way the background isolate reports a failure; the import carries an explicit ignore with the reason.
- Added guard tests next to each fix so a regression fails in `check.sh`, not in a manual walk.
- Report numbered 05 because impl ran twice (01, 02) and the cases report already took 04.
