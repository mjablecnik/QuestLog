# Questlog

Personal gamified TODO app for a single user (Martin): **Quests** (one-off tasks) and
**Missions** (long-term goals made of quests), XP and levels, recurring missions posted
from rules. Flutter, iOS primary (Linux desktop used for development/tests), local-only
SQLite via Drift + Riverpod — no server, no account, no network at runtime.

## Status

Design and both specs are approved and complete. **No code exists yet** — implementation
has not started. There is deliberately no git repository yet (see Git below).

## Where everything lives

- `.kiro/specs/001-questlog-domain/` — domain layer: data model, Drift schema, services,
  XP rules, recurring posting, 04:00 board-day boundary. **Implement this first.**
- `.kiro/specs/002-questlog-ui/` — screens, theming, localization (cs/en), rewards.
  Starts only after 001 is fully done (its tasks checked and `scripts/check.sh` green).
- `.design/DESIGN.md` + `.design/artboards/` — the approved visual contract ("Guild
  Board" dark / "Daylight" light, Figtree). Where artboards and spec requirements
  differ, the requirements win.
- Each spec's `tasks.md` is the work plan: follow it task by task, check boxes only when
  the implementation exists and its tests pass. The Notes sections carry sandbox
  gotchas already verified by a toolchain spike (glados/flutter_test import clash,
  do NOT add `sqlite3_flutter_libs`, fonts are downloadable and get bundled).

## Rules for any agent working here

- Follow the Kiro spec workflow (`kiro-spec` skill) and the global standards in
  `~/.claude/standards/` (English code/docs, Czech+English user-facing strings).
- Sandbox: run `git config --global --add safe.directory /opt/flutter` before any
  flutter/dart command (`sandbox-flutter` skill). Only Linux desktop/web run here;
  the iOS build and device checks are done by Martin himself.
- Bundle id `com.jablecnik.questlog`, display name `Questlog`, set in one place
  (002 task 1.3).
- No due dates, streaks, history screen, notifications or projects in v1 — do not
  add scope the specs don't ask for.

## Git

Initialize the repository here at the very first implementation task (001 task 1.1):
`git init`, author exactly `Martin Jablečník <martin.jablecnik@email.cz>`, then commit
each completed task as one Conventional Commit (`feat:`, `test:`, `chore:`...), per
`~/.claude/standards/code-git.md`. Never add tool-attribution trailers
(no Co-Authored-By/Generated-with/session links). Never push — there is no remote.
