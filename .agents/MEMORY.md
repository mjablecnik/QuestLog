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
