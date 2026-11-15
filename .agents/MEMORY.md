# Memory

## Riverpod 3 stream providers pause without listeners
- Project: questlog
- Problem: `container.read(streamProvider.future)` in a test hung until timeout (or returned a stale first value) because Riverpod 3 pauses providers with no listener.
- Solution: call `container.listen(provider, (_, _) {})` for each stream provider first, `await pumpEventQueue()` after writes, then read `.value`.
- Source: impl, 2026-11-15 14:45
