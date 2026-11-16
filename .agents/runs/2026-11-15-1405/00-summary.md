# Run 2026-11-15-1405 — Questlog (specs 001-questlog-domain + 002-questlog-ui)

## Status

No phase failed. Six reports, all `OK` or `OK WITH ISSUES`, nothing blocked.

| Phase | Result | In short |
|---|---|---|
| impl (001, `01-impl.md`) | OK | domain, data and services built; 182 tests green |
| impl (002, `02-impl-ui.md`) | OK WITH ISSUES | whole UI built; 638 tests green; palette contrast + dead ARB keys logged |
| build (`03-build.md`) | OK | tree already green, Linux bundle builds and starts; no repairs needed |
| cases (`04-cases.md`) | OK WITH ISSUES | 169 use cases, 99-step walkthrough; three spec gaps found, not decided |
| verify (`05-verify.md`) | OK WITH ISSUES | 97/99 steps run on the real app, 0 failed; 28 fixes with regression tests |
| docs (`06-docs.md`) | OK WITH ISSUES | CLAUDE.md/README rewritten, DOCS.md added, every command re-run |

The `impl` phase ran twice — once for spec 001 and once for spec 002 — which is why the
reports are numbered 01 through 06 for five phase names. Per-task commits were
deliberately **not** squashed (project rule in `CLAUDE.md`): 117 commits between
`a117d8c~1` and `b70c9bd`, one logical change each.

## What was built

Both specs are fully implemented: 46/46 tasks in `001-questlog-domain`, 62/62 in
`002-questlog-ui`, all checked off and all verified against the running app.

- **Domain and data** — 04:00 board day, XP/level maths, cadence and occurrence
  arithmetic, Drift schema (v1) with a single transaction entry point, Quest/Mission/
  Recurrence/Settings/XP services, Riverpod providers.
- **UI** — theme and tokens, app shell with Board and Missions tabs, mission detail,
  settings (profile, language, theme, rules, temporary font picker), every sheet,
  reward overlay, cs+en localisation, goldens for both themes.
- **Quality** — `scripts/check.sh` green: analyze clean, 660 tests, structure check OK.
  The Linux release bundle builds and launches.

Specified but not delivered:

- **iOS is entirely unverified.** The sandbox has Linux only, so the iOS build and five
  device-only cases (edge-swipe back, software keyboard, safe areas, home indicator,
  felt haptics) were never executed.
- **D-13.4 schema migration** is untestable — the schema has only ever had version 1.
- **U-16.6 contrast** is not met by the approved palette (see below).
- The **display-font picker is temporary** by design; removing it later needs a schema
  v2 migration if the `display_font` column goes.

## Open issues

Eight entries in `.agents/ISSUES.md`, all `OPEN`, all from this run. One MEDIUM, seven LOW.

1. **[MEDIUM] Approved palette fails 4.5:1 text contrast** (impl) — `inkDim`, `textDim`,
   `inkOnDestructive`, `inkOnBrass` and brass-as-text measure 1.69–4.22 against their
   backgrounds. Secondary labels may be hard to read for low-vision users.
   `test/ui/theme/contrast_test.dart` pins each failing pair.
2. **[LOW] Bundled fonts ship without OFL licence files** (docs) — `pubspec.yaml`
   points at `assets/fonts/OFL-*.txt`, which do not exist.
3. **[LOW] No project licence chosen** (docs) — no `LICENSE`; README says
   "all rights reserved" as a placeholder.
4. **[LOW] iOS-only cases not run** (verify) — UC-008, UC-029 (keyboard), UC-144
   (haptics), UC-145, UC-169.
5. **[LOW] Reward caption mismatch** (cases) — DESIGN.md says "QUEST SPLNĚN", the
   requirement and the ARB files say "QUEST SPLNĚNO".
6. **[LOW] No way back to `system` language** (cases) — the two-segment control
   matches U-11.5, but D-12.2's `system` becomes unreachable after the first choice.
7. **[LOW] Schema migration unverifiable** (cases) — nothing to migrate from yet.
8. **[LOW] Two a11y ARB keys unused** (impl) — `a11y_dragHandle`, `a11y_openSettings`.

Full text, with what was tried and the next step for each, in `.agents/ISSUES.md`.

## Needs your decision

- **The palette.** Fixing U-16.6 means darkening `inkDim`, `textDim` and
  `inkOnDestructive` in the approved `.design` colours, and not using brass as body
  text. Nothing was changed without your sign-off. Approve the darkening, or accept
  the gaps as a deliberate trade-off.
- **"QUEST SPLNĚN" or "QUEST SPLNĚNO"?** The app follows the requirement; whichever
  you pick, the losing document (DESIGN.md + artboard, or requirements + ARB files)
  gets corrected.
- **Should the language control get a third "Systém" segment**, like the theme control
  already has, or is the asymmetry intended?
- **Licence** — pick one, or confirm "all rights reserved" and the README stays as is.
- **iOS** — the build and the five device cases are yours; the sheet keyboard clearance
  and the safe-area padding are the likeliest places to find something.

## Where to look

- Phase reports: `.agents/runs/2026-11-15-1405/01-impl.md`, `02-impl-ui.md`,
  `03-build.md`, `04-cases.md`, `05-verify.md`, `06-docs.md`
- Issue register: `.agents/ISSUES.md`
- Use-case catalogue (169 cases, reused by later runs): `.agents/USE_CASES.md`
- Lessons learned: `.agents/MEMORY.md`
- Run state and SHAs: `.agents/PIPELINE_STATE.json`
- Project docs rewritten this run: `CLAUDE.md`, `README.md`, `DOCS.md`
- `.agents/tmp/` is empty — `VERIFY_TASKS.md` was consumed and deleted by `verify`.
