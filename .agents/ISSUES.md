# Issues

## [LOW] The bundled fonts ship without their licence files
- Run: 2026-11-15-1405
- Phase: docs
- Status: RESOLVED (2026-11-15-1405)
- What: the comment in `pubspec.yaml` says the SIL OFL licences are in `assets/fonts/OFL-*.txt`, but no such file exists in `assets/fonts/` or in git.
- Impact: the OFL asks for the licence to travel with the fonts when they are redistributed (an App Store build embeds them); the comment points at files that are not there.
- Tried: nothing; the documentation phase may not touch pubspec or assets.
- Next: add the OFL text for each family to `assets/fonts/` (and surface it in the app if wanted), or fix the comment; the five temporary families disappear anyway once the display font is chosen.

## [LOW] No project licence has been chosen
- Run: 2026-11-15-1405
- Phase: docs
- Status: RESOLVED (2026-11-15-1405)
- What: the repository has no LICENSE file and `pubspec.yaml` is `publish_to: 'none'`; the README licence section therefore states "all rights reserved" instead of a licence type.
- Impact: none for a private app; the README wording is a placeholder if the project is ever shared.
- Tried: nothing; choosing a licence is Martin's decision.
- Next: Martin picks a licence (or confirms "all rights reserved"), then README.md gets the type and a LICENSE file is added.

## [LOW] The iOS-only cases have not been run
- Run: 2026-11-15-1405
- Phase: verify
- Status: OPEN
- What: the sandbox has only Linux desktop, so UC-008 (edge-swipe back on every pushed screen), the keyboard half of UC-029 and UC-145 (software keyboard with every sheet, safe areas, home indicator), the felt half of UC-144 (haptics) and UC-169 (`flutter build ios` plus an on-device walk of UC-001/008/127/144/145) were not executed. The haptic platform calls themselves are asserted by `test/ui/haptics_flow_test.dart`.
- Impact: nothing in the iOS build or on a real device is confirmed; everything else in the catalogue passed on the real Linux app.
- Tried: nothing, by design (Pass L of the walkthrough is a hand-over list).
- Next: Martin builds for iOS and walks those cases on a device; the keyboard clearance of the sheets and the safe-area padding are the likeliest places to find something.

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

## [LOW] Mission and rule sheet quest rows show only +XP for the effort tier
- Run: 2026-11-18 (four effort tiers)
- Phase: ui
- Status: OPEN
- What: the per-quest chip in the mission sheet and the rule sheet cycles through the four tiers on tap and shows only `+10/+25/+50/+100`; it has no pips, no tier name and no time hint, unlike the quest sheet's effort picker.
- Impact: when planning a mission the user sees the XP but not the time guidance that defines each tier; the fourth step makes the cycle one tap longer.
- Tried: nothing; tier names must not clutter rows and the chips are deliberately compact.
- Next: Martin decides whether the chip should also draw the four pips, or open the same picker.

## [LOW] The app icon and launch screen still draw three pips
- Run: 2026-11-18 (four effort tiers)
- Phase: docs
- Status: OPEN
- What: `.design/icon/generate.mjs` draws the quest slip with three diamonds, while the quest card now has four.
- Impact: cosmetic mismatch only; the icon is a mark, not a rendering of the card.
- Tried: left as is, since regenerating the icon set was not asked for.
- Next: redraw with four diamonds if Martin wants the match; run `generate.mjs`.

## [LOW] A Quest and a Mission bonus can skip a Level
- Run: 2026-11-18 (four effort tiers)
- Phase: domain
- Status: OPEN
- What: with the level curve unchanged (100 + 50 × (L − 1)), a single +100 Quest crosses at most one Level, but a Quest plus its Mission bonus can skip one (0 + 100 + 200 = 300 XP: Level 3, 50/200 into the bar). The reward card reports `levelBefore` and `levelAfter` of the whole step.
- Impact: none observed; a Full day Quest makes it slightly more likely early on, and early levels now pass quickly (Level 2 is one Full day Quest).
- Tried: tests pin the curve and the edge cases; no change made.
- Next: Martin decides whether Level 2 at 100 XP is too cheap now, or raises the curve (a domain-spec change).
