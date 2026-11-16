# AI Log

## 2026-11-16 — 2026-11-15-1405

- Built the whole app from scratch in one pipeline run: specs `001-questlog-domain`
  (46/46 tasks) and `002-questlog-ui` (62/62) are implemented, checked off and verified.
  The `impl` phase ran twice, once per spec, hence reports `01-impl.md` and `02-impl-ui.md`.
- Phase results, from the reports themselves: impl OK, impl-ui OK WITH ISSUES, build OK,
  cases OK WITH ISSUES, verify OK WITH ISSUES, docs OK WITH ISSUES. Nothing failed.
- `verify` drove the real Linux release bundle under Xvfb (xdotool + scrot + sqlite3
  backdating of the app's own database, no fake clock available), ran 97 of 99 walkthrough
  steps and fixed 28 defects, each with its own commit and a regression test.
- `cases` wrote `.agents/USE_CASES.md`: 169 cases covering all 34 requirements of both
  specs, with a stable ID scheme later runs extend at the end.
- Final state: `scripts/check.sh` green (analyze clean, 660 tests, structure OK), Linux
  release bundle builds and launches, `CLAUDE.md`/`README.md`/`DOCS.md` match the code.
- 117 commits from `a117d8c~1` to the run's end, deliberately not squashed — one
  Conventional Commit per task or fix, as the project's `CLAUDE.md` requires.
- Left open: 8 issues (1 MEDIUM palette contrast against requirement U-16.6, 7 LOW).
  Five of them wait on Martin: the palette darkening, the "QUEST SPLNĚN(O)" caption,
  a third "Systém" language segment, the project licence, and the iOS build plus its
  five device-only cases — the sandbox has Linux only, so nothing iOS was ever run.
