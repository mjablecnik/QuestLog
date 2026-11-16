# Phase 3 — Cases

**Target:** `.` (the whole Flutter app, specs 001 + 002) — passed explicitly by the orchestrator, and consistent with `target` in `PIPELINE_STATE.json`.

## Result
OK WITH ISSUES

## Headline
`.agents/USE_CASES.md` now holds 169 use cases covering every user-visible behaviour of both specs; all 34 requirements of `001-questlog-domain` and `002-questlog-ui` map to at least one case, and every case states the data it needs and how it is verified. `.agents/tmp/VERIFY_TASKS.md` orders them into 99 steps across twelve passes, with a worked recipe for driving the real Linux app under Xvfb (xdotool clicks and drags, scrot screenshots, sqlite3 seeding of the app's own on-disk database). Three spec gaps turned up while writing and went into `ISSUES.md` rather than being decided here.

## Needs attention
- **Reward caption mismatch** (LOW in `ISSUES.md`): `.design/DESIGN.md` says "QUEST SPLNĚN", requirement U-7.1 and the ARB files say "QUEST SPLNĚNO". UC-152 compares the card against the artboard, so the verify phase must not "fix" the app to match the picture — the requirement wins. Martin picks the wording.
- **No way back to `system` language** (LOW): D-12.2 offers `system`/`cs`/`en`, U-11.5 specifies a two-segment control and the implementation matches it, so `system` is reachable only on a fresh install. The theme control does offer Systém. Needs Martin's decision, not an invented criterion.
- **D-13.4 schema migration is unverifiable** (LOW): the schema is still at version 1, so UC-129 records that rather than passing vacuously.
- **The contrast requirement (U-16.6) will fail verification by design.** UC-141 is written to fail while the MEDIUM palette issue from `impl` is open; step 97 of the walkthrough tells `verify` not to tick it and not to change the approved colours without Martin's sign-off.
- **Five cases are iOS-only** and cannot be touched here: UC-008 (edge-swipe back), UC-029's keyboard half, UC-144's felt haptics, UC-145 (keyboard, safe areas, home indicator) and UC-169 (`flutter build ios` plus an on-device walk). Pass L of the walkthrough is the hand-over list.

## What changed
- **Created `.agents/USE_CASES.md`** — 169 cases, IDs UC-001…UC-169, grouped by area but numbered globally and sequentially so later runs extend at the end. Each case carries Area, Requirement (as `D-n.m` for spec 001 and `U-n.m` for spec 002), Preconditions, Data needed, Steps, Expected and a `Verify:` method. The file ends with a two-table requirement coverage map; a script check confirms no gaps in the IDs, no case missing any of the four mandatory lines, and no requirement without a case.
- **Created `.agents/tmp/VERIFY_TASKS.md`** — 99 ordered steps in twelve passes (fresh install and empty states → create/complete/rewards → sheets, validation, swipe and deletion → missions and detail → settings, language, theme, font → recurring rules → backdated states → restart persistence → visual comparison against `.design/screens` → error paths → test-only cases → iOS hand-over). Every case id appears in exactly one step. The file opens with the driving recipe described below and ends with the note that `verify` is the consumer and deletes it.
- **Appended three LOW entries to `.agents/ISSUES.md`.** No existing entry was touched.
- No source file, test, script or spec was read-modified — this phase writes documents only.

## Decisions made

**The sandbox driving method, settled by probing what exists.** `xdotool`, `scrot`, `ffmpeg`, `xvfb-run` and `sqlite3` are installed; `import`, `convert`, `xwd`, `wmctrl` and every window manager are not, and neither is `faketime`. That shaped four choices:

- *Controlled `HOME`.* `lib/data/database.dart` opens `getApplicationDocumentsDirectory()/questlog.sqlite`, which on Linux sits under `$HOME`. Launching the release bundle with `HOME` pointed at a scratch directory makes a fresh install, a known database path for seeding, and a genuine restart (kill the process, relaunch against the same `HOME`) all trivial. UC-127 uses exactly that for persistence.
- *sqlite3 backdating instead of a fake clock.* `lib/main.dart` hard-wires `SystemClock` and there is no `faketime`, so the real app can never be told it is a different day. Everything that depends on a past date — the 04:00 board-day window (UC-027, UC-065), reconciliation of due rules (UC-103, UC-104, UC-105), a closed unfinished instance (UC-094) — is driven by editing the app's own rows while it is stopped and relaunching. Drift's `DateTime` columns are Unix seconds and `anchorDate`/`lastPostedOn` are `YYYY-MM-DD` text; the recipe spells that out. These cases are marked `APP+DB` rather than `APP`.
- *A 390×844 window with the header strip cropped.* `linux/runner/my_application.cc` asks for 1280×720 and installs a client-side `GtkHeaderBar`, so the screenshot includes a title strip. The recipe resizes to 390×881 and crops 37px off the top with `ffmpeg`, because `convert` and `import` are missing. 390×844 is also what the artboards are drawn at, which is what makes the Pass I comparisons meaningful, and the same handle covers the 320/430 widths of UC-143.
- *Typing follows the pointer.* With no window manager the X input focus is `PointerRoot`, so the recipe moves the pointer into the window before any `xdotool type`. Coordinates are taken by screenshotting, reading the PNG, computing the point and then clicking — stated explicitly as the loop, because guessed coordinates are the usual way this kind of walkthrough quietly stops testing anything.

**Four verification methods, not two.** Each case is marked `APP` (the real app), `APP+DB` (the real app plus sqlite3 edits), `TEST` (widget/unit/property/golden with an in-memory database and a controllable Clock) or `IOS` (Martin). `TEST` was used only where the behaviour is genuinely unreachable from a running Linux app — clock injection (UC-124, UC-125), device locale (UC-119), device brightness (UC-113), reduced motion (UC-059), text scale (UC-142), injected transaction failures (UC-128) — or where the case is pure computation (UC-013, UC-106, UC-107). Everything else is driven on the real app, which is what the orchestrator asked for and what the 638 existing in-memory tests cannot do.

**`integration_test` was deliberately not required.** It would need `integration_test: sdk: flutter` in `dev_dependencies`, and the xdotool route already covers the restart case more honestly than a driver can. The walkthrough proposes it only as a fallback if the coordinate loop proves too brittle on the sheet-heavy passes, and tells `verify` to report the pubspec change if it takes that route.

**English is the default in this sandbox.** There is no `LANG`, so `Effective_Language` resolves to English and the app's Czech strings are not on screen until Settings → Jazyk → Čeština is selected. Pass E does that once, and the passes that assert Czech wording (the reward captions, the swipe labels, the rule row line, the font-sheet sample) come after it.

**Czech plurals win over the literal requirement text.** U-12.1 writes the rule row as "cadence · N questů · příště date", but U-14.5 requires correct Czech plural forms and `rule_line` in `app_cs.arb` implements them. UC-090 therefore expects "Měsíčně · 3 questy · příště …", not the literal "questů" of the requirement sentence.

**The two cases that must not pass are written to fail.** UC-141 (contrast) and UC-129 (migration) describe the real state rather than a reachable target, and the walkthrough says so at the step. Writing them as passable would have hidden the open palette question and the untested migration path, which is the one failure mode this pipeline is built to avoid.

## Working tree
Nothing foreign was left behind: `git status --porcelain` was empty at the start of the phase, so every path in this phase's commits is one this phase created. No sandbox scaffolding was written into the repository — the verify harness lives in the walkthrough as a recipe, to be materialised in the session scratchpad when `verify` runs.
