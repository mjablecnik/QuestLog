# Issues

## [MEDIUM] Approved palette fails 4.5:1 text contrast for several pairs
- Run: 2026-11-15-1405
- Phase: impl
- Status: OPEN
- What: lib/ui/theme/tokens.dart follows the approved .design palette exactly, but test/ui/theme/contrast_test.dart measures body-text pairs below 4.5:1: inkDim/parchment (3.79 guildBoard, 4.06 daylight), inkOnDestructive/destructive (3.14 both), inkOnBrass/brass (3.19 daylight), textDim/board, textDim/boardRaised and textDim/sheet in daylight (4.10, 4.22, 4.22). Brass used as text is 2.92 on daylight board and 1.69 on guildBoard parchment cards.
- Impact: secondary labels and brass text may be hard to read for low-vision users (accessibility requirement on contrast is only partly met).
- Tried: left the approved colours untouched because DESIGN.md is the visual contract; the test lists each failing pair in _knownGaps with a floor so it fails on regressions or when a pair is fixed.
- Next: darken inkDim, textDim and inkOnDestructive tokens slightly (daylight) with Martin's sign-off, then empty _knownGaps; avoid brass as text on parchment.
