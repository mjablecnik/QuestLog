# Memory

## Riverpod 3 stream providers pause without listeners
- Project: questlog
- Problem: `container.read(streamProvider.future)` in a test hung until timeout (or returned a stale first value) because Riverpod 3 pauses providers with no listener.
- Solution: call `container.listen(provider, (_, _) {})` for each stream provider first, `await pumpEventQueue()` after writes, then read `.value`.
- Source: impl, 2026-11-15 14:45

## Drift streams deadlock widget tests that await several DB writes
- Project: questlog
- Problem: in a widget test with a mounted Drift-stream widget, several separate awaited writes inside `tester.runAsync` hang forever (the stream refresh continuation sits in the fake-async zone).
- Solution: seed before the first `pumpWidget`, or wrap the writes in one `db.transaction`. Give streams real time with `runAsync(Future.delayed(50ms))` then pump. Dispose inside the test body (`pumpWidget(SizedBox())`, `pump(10ms)`, `runAsync(db.close)`).
- Source: impl, 2026-11-16

## glados clashes with flutter_test imports
- Project: questlog
- Problem: importing both `package:glados/glados.dart` and `flutter_test` gives ambiguous names.
- Solution: hide the clashing symbols on the glados import (see the spec notes of 001).
- Source: impl, 2026-11-16

## Widget tests render every font as Ahem
- Project: questlog
- Problem: text is about 2x too wide in tests, so layout tests report overflows that cannot happen on a device.
- Solution: register the bundled fonts with `FontLoader` inside `tester.runAsync` (assets/fonts/<Family>-<weight>.ttf) before pumping; see test/ui/a11y/_a11y_harness.dart.
- Source: impl, 2026-11-16

## Animations need one more frame than the state change
- Project: questlog
- Problem: a pixel or `transientCallbackCount` check right after the frame that applies setState/route push sees the animation still at its start. A touch also only counts as pressed after `kPressTimeout`.
- Solution: pump the press timeout, then 16 ms (starts the animation), then the animation length before measuring.
- Source: impl, 2026-11-16

## Shell hygiene: pkill/pgrep -f match their own shell; per-file test timeout
- Project: questlog
- Problem: `pkill -f flutter_tester` or `pgrep -f "check.sh"` in a monitor matches the very shell running it (kills it / never exits). Long test files also hit the default test timeout.
- Solution: wait on a PID with `kill -0`, never pkill by pattern; run `timeout N flutter test --timeout 60s <file>` in the foreground.
- Source: impl, 2026-11-16

## Headless screenshots and long codegen in the sandbox
- Project: questlog
- Problem: `import`/`xwd` are not installed, and `dart run build_runner build` (~50 s, 296 outputs) trips the 2-minute tool timeout when run in the foreground.
- Solution: `scrot -o file.png` inside `xvfb-run -a` (run the release bundle `build/linux/x64/release/bundle/questlog` in the same script, sleep ~12 s, scrot, kill). Run build_runner in the background with `timeout 500` and poll its log.
- Source: build, 2026-11-16 01:20

## Drift lists go stale after a rejected action: mark the tables updated
- Project: questlog
- Problem: after a not-found / invalid-state / rejected-reorder error the list kept showing the vanished row. Invalidating a Riverpod stream provider does not re-query, because drift reuses the last value of an identical stream, and drift watchers are not told about writes from outside (sqlite3 CLI, `customStatement`).
- Solution: `db.markTablesUpdated(db.allTables)` forces every watcher to query again; `showDomainError` and the Mission detail close path do it. Test it with a raw `customStatement('DELETE ...')`, then assert the card is gone.
- Source: verify, 2026-11-16

## NativeDatabase.createInBackground reports failures as DriftRemoteException
- Project: questlog
- Problem: with the file database (background isolate) a SQLite failure such as a read-only file arrives as `DriftRemoteException` (`package:drift/remote.dart`, flagged experimental by the analyzer), not `SqliteException`, so `runTransaction` leaked a raw exception to the UI; in-memory test databases never show it. Writes that bypass `runTransaction` (the settings write did) leak the same way.
- Solution: map `DriftRemoteException.remoteCause` to `StorageError` in `runTransaction` (with `// ignore: experimental_member_use` on the import) and route every write through it. Test with a `chmod 444` temp file opened via `createInBackground`.
- Source: verify, 2026-11-16

## Seeding the real app's database for a walkthrough
- Project: questlog
- Problem: a recurring rule only shows "Vyvěšeno" when an open mission with its `rule_id` exists (`last_posted_on` alone is not enough); enum columns hold the names (`status 'open'|'completed'`, `bonus small|medium|large`, `difficulty easy|normal|hard`); DateTime columns are Unix seconds. The app does not notice sqlite3 writes while it runs.
- Solution: seed with the app stopped (launch once to create the schema), keep `total_xp` equal to the sum of awarded XP, relaunch. Simulate a resume with `xdotool windowunmap` then `windowmap`. A long session crosses the 04:00 board day.
- Source: verify, 2026-11-16

## Never run dart format on a whole file that is not already formatted
- Project: questlog
- Problem: `dart format` on `database.dart` / `database_test.dart` rewrote most of the file and buried a three-line fix.
- Solution: format only files that are already clean, or apply the edit by hand; check `git diff --stat` before committing.
- Source: verify, 2026-11-16

## Full-app widget tests need an explicit teardown
- Project: questlog
- Problem: a widget test that mounts the whole app over a real in-memory drift database ends with "A Timer is still pending" (drift stream clean-up timers), and a settings write racing a pushed screen localizes a snackbar with the old language.
- Solution: end the test with `await tester.pumpWidget(const SizedBox()); await tester.pump(); await tester.runAsync(db.close);`; read the stored language from the database for messages raised outside a widget. For screenshot comparison against the artboards crop both images to the same width first (`export W=430`), a mismatch looks like a layout bug.
- Source: verify, 2026-11-16
