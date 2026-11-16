# Issues

## [LOW] The reward caption differs between DESIGN.md and the requirements
- Run: 2026-11-15-1405
- Phase: cases
- Status: OPEN
- What: `.design/DESIGN.md` § 4 and the `QuestComplete` artboard write the quest reward caption as "QUEST SPLNĚN"; requirement U-7.1 of `.kiro/specs/002-questlog-ui/requirements.md` writes "QUEST SPLNĚNO", and `lib/l10n/app_cs.arb` (`reward_questComplete`) follows the requirement.
- Impact: UC-152 compares the real reward card against `.design/screens/QuestComplete.png`, where the two strings will not match. The risk is that the verify phase "fixes" the app to match the artboard, which would contradict the requirement that wins per `CLAUDE.md`.
- Tried: nothing changed — the implementation is already on the requirement's side, which is the correct side.
- Next: Martin picks the wording he wants and it is corrected in the losing document (DESIGN.md plus the artboard, or the requirement plus the ARB files).

## [LOW] Once the language is set there is no way back to `system`
- Run: 2026-11-15-1405
- Phase: cases
- Status: OPEN
- What: D-12.2 offers the language values `system`, `cs` and `en` with `system` as the default, but U-11.5 specifies a two-segment control (Čeština / English) only, and `lib/ui/screens/settings/settings_screen.dart` implements exactly that. Selecting either segment stores an explicit language and nothing ever stores `system` again.
- Impact: `system` is reachable only on a fresh install. The theme control, by contrast, does offer Systém. No case can verify a return to `system` from the UI, so UC-119 (the fallback) is a test rather than an app case.
- Tried: left as specified — the implementation matches U-11.5 and no acceptance criterion was invented to cover the gap.
- Next: Martin decides whether the language control gets a third Systém segment like the theme control, or whether the asymmetry is intended.

## [LOW] The schema-migration requirement cannot be verified yet
- Run: 2026-11-15-1405
- Phase: cases
- Status: OPEN
- What: D-13.4 requires that a schema update migrates existing data without loss, but the Drift schema is still at its first version, so there is no earlier version to migrate from. UC-129 is written to record this explicitly rather than pass vacuously.
- Impact: the requirement is untested until the second schema version exists; a broken migration path would not be noticed before then.
- Tried: nothing — there is nothing to test against.
- Next: when the first schema change lands, add a migration test from the previous version and tick UC-129 properly.

## [LOW] Two accessibility strings in the ARB files are unused
- Run: 2026-11-15-1405
- Phase: impl
- Status: OPEN
- What: `a11y_dragHandle` and `a11y_openSettings` exist in app_cs.arb and app_en.arb but no widget reads them. The Board drag affordance is spoken through the hint `a11y_dragHint`, and the gear is labelled with `settings_title`.
- Impact: none for users; dead translation keys, and requirement 16.3 (spoken drag handle, gear) is met through the other strings (covered by test/ui/a11y/semantic_labels_test.dart).
- Tried: kept them, because removing keys touches both language files and the generated localizations for no behaviour change.
- Next: either use them as the semantic labels (drag handle, gear) or delete them from both ARB files.

## [MEDIUM] Approved palette fails 4.5:1 text contrast for several pairs
- Run: 2026-11-15-1405
- Phase: impl
- Status: OPEN
- What: lib/ui/theme/tokens.dart follows the approved .design palette exactly, but test/ui/theme/contrast_test.dart measures body-text pairs below 4.5:1: inkDim/parchment (3.79 guildBoard, 4.06 daylight), inkOnDestructive/destructive (3.14 both), inkOnBrass/brass (3.19 daylight), textDim/board, textDim/boardRaised and textDim/sheet in daylight (4.10, 4.22, 4.22). Brass used as text is 2.92 on daylight board and 1.69 on guildBoard parchment cards.
- Impact: secondary labels and brass text may be hard to read for low-vision users (accessibility requirement on contrast is only partly met).
- Tried: left the approved colours untouched because DESIGN.md is the visual contract; the test lists each failing pair in _knownGaps with a floor so it fails on regressions or when a pair is fixed.
- Next: darken inkDim, textDim and inkOnDestructive tokens slightly (daylight) with Martin's sign-off, then empty _knownGaps; avoid brass as text on parchment.
