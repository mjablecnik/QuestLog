# Use Cases

The catalogue of everything that must hold for Questlog to count as working. IDs are
stable: later runs extend this file at the end and never renumber. A case that the
current spec has made obsolete is marked `OBSOLETE (<run-id>)` in place, not deleted.

## Requirement references

- `D-n.m` — `.kiro/specs/001-questlog-domain/requirements.md`, requirement *n*, acceptance criterion *m*
- `U-n.m` — `.kiro/specs/002-questlog-ui/requirements.md`, requirement *n*, acceptance criterion *m*

Every requirement of both specs maps to at least one case; the map is at the end of
this file.

## How a case is verified

Each case carries a `Verify:` line with exactly one of these methods.

- **APP** — the real application: the Linux release bundle
  `build/linux/x64/release/bundle/questlog` run under Xvfb against a real on-disk
  SQLite database, driven with `xdotool` and checked on `scrot` screenshots. This is
  the preferred method and most cases use it.
- **APP+DB** — APP, plus `sqlite3` edits to that on-disk database between launches.
  Needed wherever the case depends on a date or time in the past: there is no
  `faketime` in this sandbox and `lib/main.dart` hard-wires `SystemClock`, so the only
  way to put the real app in a "yesterday" state is to backdate its rows and relaunch.
- **TEST** — a Flutter unit, widget, property or golden test with an in-memory
  database and a controllable `Clock`. Used where the behaviour cannot be reached from
  the UI at all (clock injection, device locale, reduced motion, text scale), or where
  it is pure computation.
- **IOS** — iOS-only. Martin verifies on the device; the sandbox has no iOS
  toolchain and no touch input. Haptics, the edge-swipe back gesture, the software
  keyboard and safe areas fall here.

Note for every APP case: the sandbox has no `LANG`, so `Effective_Language` resolves
to **English**. Czech strings are reached by selecting *Čeština* in Settings → Jazyk
first; cases that name Czech text say so.

---

## Area: shell and navigation

### UC-001 — Cold start shows the splash, then the board
- Area: shell
- Requirement: U-1.1
- Preconditions: no database file exists
- Data needed: none — a fresh `HOME`, so the app creates the database itself
- Steps: launch the bundle, screenshot within the first second, then screenshot after two seconds
- Expected: the first screenshot shows the branded splash; the second shows the Board screen; no exception in stdout
- Verify: APP

### UC-002 — Exactly two tabs, Questy and Mise
- Area: shell
- Requirement: U-1.2
- Preconditions: app running on the Board
- Data needed: none
- Steps: screenshot the bottom tab bar
- Expected: two tabs only, labelled Quests and Missions (Czech: Questy, Mise); no third tab anywhere
- Verify: APP

### UC-003 — Hero bar with the gear on both tabs
- Area: shell
- Requirement: U-1.3
- Preconditions: app running
- Data needed: none
- Steps: screenshot the Board, tap the Mise tab, screenshot
- Expected: both screens carry the hero bar, and a gear button sits at its right end on both
- Verify: APP

### UC-004 — Gear opens Settings and closing it returns to the same tab
- Area: shell
- Requirement: U-1.4
- Preconditions: app running
- Data needed: 12 open quests, so the Board scrolls
- Steps: on the Board scroll halfway down, tap the gear, screenshot, tap back, screenshot
- Expected: Settings opens with the title Nastavení/Settings; back returns to the Board (not the Missions tab) with the scroll position unchanged
- Verify: APP

### UC-005 — Reconciliation runs once per return from the background
- Area: shell
- Requirement: U-1.5, D-9.8
- Preconditions: one recurring rule whose next occurrence is in the past
- Data needed: one recurring rule (daily, 1 quest template), `nextIndex`/`anchorDate` set so the next occurrence is yesterday
- Steps: with the app open, unfocus and refocus the window twice (`xdotool windowactivate` away and back)
- Expected: exactly one instance of the rule is posted across both cycles; the missions list shows one instance, not two
- Verify: APP+DB

### UC-006 — Posting message names the posted missions
- Area: shell
- Requirement: U-1.6
- Preconditions: two recurring rules both due
- Data needed: two recurring rules (any cadence, 1 quest template each) with past next occurrences
- Steps: launch the app, screenshot the first second after the board appears
- Expected: a brief message naming both posted missions; it does not cover the tab bar or the add button
- Verify: APP+DB

### UC-007 — A storage failure during reconciliation does not block the app
- Area: shell
- Requirement: U-1.7, U-18.3
- Preconditions: reconciliation fails
- Data needed: an existing database with 3 quests, then the database file made read-only (`chmod 444`) before launch
- Steps: launch, screenshot, then try to open the quest sheet and switch tabs
- Expected: the existing quests are listed, an inline retry message is shown, no exception text, and tabs and sheets still open
- Verify: APP

### UC-008 — iOS edge-swipe back on every pushed screen
- Area: shell
- Requirement: U-1.8
- Preconditions: app on device
- Data needed: one mission with 2 quests
- Steps: open Settings and swipe from the left edge; open a mission detail and swipe from the left edge
- Expected: both screens pop back to where they were pushed from
- Verify: IOS

---

## Area: hero bar, XP and levels

### UC-009 — Hero bar shows level badge, level line and progress bar
- Area: hero
- Requirement: U-2.1, U-2.2
- Preconditions: app on the Board
- Data needed: `appState.totalXp = 160` (level 2, 60 inside the level, threshold 150)
- Steps: screenshot the hero bar
- Expected: badge reads 2; the line reads "Level 2"/"Úroveň 2"; the bar is filled about 40 %; the figures read 60 / 150 XP and 90 XP remaining
- Verify: APP+DB

### UC-010 — Hero name shown above the level line, omitted when empty
- Area: hero
- Requirement: U-2.3, D-12.7
- Preconditions: app on the Board
- Data needed: `appState.heroName = ''` for the first pass, then `'Martin'`
- Steps: screenshot the hero bar; set the name in Settings → Profil; screenshot again
- Expected: with no name only the level line shows; with a name it appears above the level line
- Verify: APP

### UC-011 — Progress bar animates when XP changes
- Area: hero
- Requirement: U-2.4
- Preconditions: one open quest on the Board
- Data needed: one quest (Normal, +25), `totalXp = 10`
- Steps: tap the check circle, capture three screenshots about 150 ms apart
- Expected: the bar is at an intermediate width in the middle frame and at its final width in the last; the badge still reads 1
- Verify: APP

### UC-012 — Level-up fills the bar to the end before restarting
- Area: hero
- Requirement: U-2.5, U-7.3
- Preconditions: one Hard quest, XP just below the level-1 threshold
- Data needed: one quest (Hard, +50), `totalXp = 80` (so completion gives 130 → level 2)
- Steps: tap the check circle and capture a burst of screenshots through the animation
- Expected: the bar reaches full, then restarts at 30/150; the badge changes 1 → 2; the reward card shows the level-up variant
- Verify: APP

### UC-013 — Level thresholds and derived level
- Area: xp
- Requirement: D-6.1, D-6.2, D-6.3, D-6.4, D-6.7
- Preconditions: none
- Data needed: none — pure computation over a generated range of Total_XP values
- Steps: assert the threshold formula `100 + 50 × (L − 1)`, the level for 0/99/100/249/250, progress inside the level, and that no upper level cap exists
- Expected: level 1 below 100 XP, the stated boundaries hold, progress and Total_XP are reported separately
- Verify: TEST

### UC-014 — Level before and after a change, including downward
- Area: xp
- Requirement: D-6.5, D-6.6
- Preconditions: none
- Data needed: `totalXp = 110`, one done quest with `awardedXp = 50`
- Steps: reopen the quest through Quest_Service
- Expected: the result reports level 2 before and level 1 after
- Verify: TEST

### UC-015 — Total_XP never goes below zero
- Area: xp
- Requirement: D-2.6
- Preconditions: a done quest whose recorded XP exceeds Total_XP
- Data needed: one done quest with `awardedXp = 50`, `totalXp = 10` (an inconsistent state written directly)
- Steps: reopen the quest
- Expected: Total_XP ends at 0, not negative; the hero bar shows level 1 at 0 XP
- Verify: TEST

### UC-016 — XP figures use tabular numerals and locale grouping
- Area: hero
- Requirement: U-2.6
- Preconditions: app on the Board
- Data needed: `totalXp = 12345`
- Steps: screenshot the hero bar in English, switch to Čeština, screenshot again
- Expected: the digits are monospaced (figures do not shift between frames as XP changes) and grouping follows the locale (`12,345` vs `12 345`)
- Verify: APP+DB

---

## Area: quest board

### UC-017 — Open quests in manual order, then today's done quests
- Area: board
- Requirement: U-3.1, D-7.1, D-7.2
- Preconditions: app on the Board
- Data needed: 4 open quests with `sortOrder` 0–3, 2 quests completed today (`completedAt` after today's 04:00)
- Steps: screenshot the whole Board, scrolling if needed
- Expected: the four open quests appear in sortOrder, then a section header, then the two done quests
- Verify: APP+DB

### UC-018 — Quest card anatomy
- Area: board
- Requirement: U-3.2, U-3.4
- Preconditions: app on the Board
- Data needed: three open quests, one Easy, one Normal, one Hard
- Steps: screenshot the three cards
- Expected: each shows a check circle, the name, a meta row and the XP (+10/+25/+50); the pips show 1/2/3 filled diamonds and no colour differs between tiers
- Verify: APP+DB

### UC-019 — Mission chip versus "no mission" in the meta row
- Area: board
- Requirement: U-3.3, D-7.9
- Preconditions: app on the Board, Czech selected
- Data needed: one standalone quest, one quest in an open mission named "Úklid"
- Steps: screenshot both cards
- Expected: the mission quest shows a chip reading "Úklid" plus pips; the standalone quest shows "bez mise" plus pips
- Verify: APP+DB

### UC-020 — Done quest card styling
- Area: board
- Requirement: U-3.5
- Preconditions: app on the Board
- Data needed: one quest completed today at a known time
- Steps: screenshot the done card
- Expected: raised ground, struck-through name, a filled brass check, and the completion time in the meta row
- Verify: APP+DB

### UC-021 — Completing a quest from the board
- Area: board
- Requirement: U-3.6, D-2.1, D-2.2, D-2.3
- Preconditions: one open quest on the Board
- Data needed: one open quest (Normal, +25), `totalXp = 0`
- Steps: tap the check circle, screenshot, dismiss the reward card, screenshot
- Expected: the card moves to the done section immediately, the reward card appears, and the hero bar reads 25 XP afterwards
- Verify: APP

### UC-022 — Reopening a quest withdraws the XP and says so
- Area: board
- Requirement: U-3.7, D-2.5
- Preconditions: one quest completed today
- Data needed: one quest completed today with `awardedXp = 25`, `totalXp = 25`
- Steps: tap the filled check circle of the done card, screenshot
- Expected: the card returns among the open quests, a brief message names the XP withdrawn, and the hero bar reads 0 XP
- Verify: APP+DB

### UC-023 — Reopening a quest that also reopens its mission
- Area: board
- Requirement: U-3.8, D-2.7, U-10.8
- Preconditions: a completed mission with one done quest
- Data needed: one mission (bonus Medium) status `completed` with `awardedBonus = 100`, one quest in it done with `awardedXp = 25`, `totalXp = 125`
- Steps: tap the done quest's check circle on the Board, screenshot the message, then open the mission detail
- Expected: the message says both the quest XP and the mission bonus were withdrawn; Total_XP is 0; the mission shows as open again
- Verify: APP+DB

### UC-024 — Skeleton cards during the first load
- Area: board
- Requirement: U-3.9, U-8.10
- Preconditions: first frame after the splash
- Data needed: 5 open quests and 2 open missions, so the loaded state differs visibly
- Steps: pump the Board and the Missions screen with a pending data future and screenshot before resolving it
- Expected: skeleton cards occupy the list on both screens, not an empty state and not real cards
- Verify: TEST

### UC-025 — Board empty state
- Area: board
- Requirement: U-3.10
- Preconditions: fresh database
- Data needed: none
- Steps: launch with a fresh `HOME`, screenshot the Board
- Expected: a heading and one sentence of guidance pointing at the add button; no skeletons, no stray section headers
- Verify: APP

### UC-026 — Floating add button opens the quest sheet
- Area: board
- Requirement: U-3.11
- Preconditions: app on the Board
- Data needed: none
- Steps: tap the floating add button, screenshot
- Expected: the quest sheet opens in create mode
- Verify: APP

### UC-027 — Board stops showing yesterday's done quests
- Area: board
- Requirement: U-3.12, D-7.3, D-7.10
- Preconditions: one quest completed before the most recent 04:00
- Data needed: one quest with `completedAt` set to 36 hours ago, one open quest
- Steps: edit the row with sqlite3, relaunch, screenshot
- Expected: the done section is gone; only the open quest is listed; Total_XP is unchanged
- Verify: APP+DB

### UC-028 — A failed check-circle tap restores the card
- Area: board
- Requirement: U-3.13, U-18.2
- Preconditions: a quest that no longer exists in the database
- Data needed: one open quest, deleted with sqlite3 while the app holds it on screen
- Steps: delete the row externally, then tap the card's check circle, screenshot
- Expected: the card reverts to its previous state, a localized message explains the item changed, and no exception text appears
- Verify: APP+DB

---

## Area: quest sheet

### UC-029 — Create mode opens focused with the keyboard
- Area: quest-sheet
- Requirement: U-5.1
- Preconditions: app on the Board
- Data needed: none
- Steps: tap the add button and type without tapping a field
- Expected: the characters land in the name field (focus is already there); on iOS the software keyboard is already up
- Verify: APP (keyboard presence itself: IOS)

### UC-030 — Quest sheet contents and defaults
- Area: quest-sheet
- Requirement: U-5.2, U-5.3
- Preconditions: quest sheet open in create mode, Czech selected
- Data needed: two open missions, so the picker has entries
- Steps: screenshot the sheet
- Expected: name field; difficulty selector Snadný +10 / Běžný +25 / Těžký +50 with Běžný selected; optional note field; mission picker with "bez mise" first then the two missions; grabber, "Zrušit" at the left, centred title, one brass button "Vyvěsit quest"
- Verify: APP+DB

### UC-031 — Creating a quest puts it last in the order
- Area: quest-sheet
- Requirement: D-1.1, D-1.9, D-3.1, U-5.7
- Preconditions: three open quests exist
- Data needed: three open quests with `sortOrder` 0–2
- Steps: create a quest named "Nakoupit" with difficulty Easy and no mission, screenshot
- Expected: the sheet closes with its transition and the new card appears after the existing three, with +10 XP and "bez mise"
- Verify: APP+DB

### UC-032 — Name validation in the sheet
- Area: quest-sheet
- Requirement: U-5.4, D-1.2
- Preconditions: quest sheet open in create mode
- Data needed: none
- Steps: submit with an empty name; then with a name of only spaces; then with 81 characters
- Expected: each attempt shows a localized error beside the name field, keeps everything typed, and creates nothing
- Verify: APP

### UC-033 — Note length validation
- Area: quest-sheet
- Requirement: U-5.4, D-1.3
- Preconditions: quest sheet open with a valid name
- Data needed: none
- Steps: paste 501 characters into the note and submit
- Expected: a localized error beside the note field, input kept, no quest created
- Verify: APP

### UC-034 — Sheet opened from a mission detail preselects that mission
- Area: quest-sheet
- Requirement: U-5.5, U-10.3
- Preconditions: a mission detail screen is open
- Data needed: one open mission with 1 quest
- Steps: open the "···" menu, choose "Přidat quest", screenshot the sheet
- Expected: the mission picker already shows that mission, not "bez mise"
- Verify: APP+DB

### UC-035 — Editing a done quest locks difficulty and mission
- Area: quest-sheet
- Requirement: U-5.6, D-1.7
- Preconditions: one quest completed today
- Data needed: one done quest (Hard, +50) in an open mission, `totalXp = 50`
- Steps: swipe the done card left, tap "Upravit", screenshot, change the name, save, screenshot the board
- Expected: the difficulty selector and the mission picker are visibly disabled; the name change is saved; the XP and the mission are unchanged
- Verify: APP+DB

### UC-036 — Editing an open quest changes all four fields
- Area: quest-sheet
- Requirement: D-1.6
- Preconditions: an open quest in mission A
- Data needed: one open quest (Easy) in open mission A, plus open mission B
- Steps: edit it to a new name, difficulty Hard, a note, and mission B; save; screenshot
- Expected: the card shows the new name, +50, the chip for mission B, and the note is stored
- Verify: APP+DB

### UC-037 — Discard confirmation for a dirty sheet only
- Area: quest-sheet
- Requirement: U-5.8, U-18.5
- Preconditions: app on the Board
- Data needed: none
- Steps: open the sheet and press "Zrušit" without typing; reopen, type a name, press "Zrušit"; repeat the dirty case dismissing by swipe
- Expected: the untouched sheet closes with no prompt; both dirty dismissals ask for confirmation before discarding
- Verify: APP

### UC-038 — Chosen mission no longer open
- Area: quest-sheet
- Requirement: U-5.9, D-1.4, D-1.5
- Preconditions: the picked mission is completed between opening and submitting
- Data needed: one open mission with 1 done quest; set its `status = 'completed'` with sqlite3 after the picker is open
- Steps: open the quest sheet, pick the mission, change the row externally, submit
- Expected: an error appears beside the mission picker, the sheet stays open and keeps the input, and no quest is created
- Verify: APP+DB

---

## Area: quest reordering

### UC-039 — Long-press lift and vertical drag
- Area: reorder
- Requirement: U-4.1, U-4.2, D-3.2
- Preconditions: four open quests on the Board
- Data needed: four open quests named A–D, `sortOrder` 0–3
- Steps: long-press card D (`xdotool mousedown`, hold, move up past A, `mouseup`), screenshot mid-drag and after
- Expected: the card visibly lifts during the drag; after the drop the order is D, A, B, C; relaunching the app keeps that order
- Verify: APP+DB

### UC-040 — Done quests cannot be dragged or crossed
- Area: reorder
- Requirement: U-4.3
- Preconditions: two open and two done quests on the Board
- Data needed: two open quests, two quests completed today
- Steps: try to long-press and drag a done card; try to drag an open card below the done section
- Expected: the done card does not lift; the open card cannot be dropped among the done cards and snaps back
- Verify: APP+DB

### UC-041 — Cancelled drag persists nothing
- Area: reorder
- Requirement: U-4.4
- Preconditions: three open quests
- Data needed: three open quests, `sortOrder` 0–2
- Steps: long-press a card, drag it, press Escape / release outside the list, screenshot, relaunch
- Expected: the card returns to its original position and the stored `sortOrder` values are unchanged
- Verify: APP+DB

### UC-042 — A failed reorder restores the previous order
- Area: reorder
- Requirement: U-4.5, D-3.5
- Preconditions: a reorder request that the service rejects
- Data needed: three open quests; one of them deleted with sqlite3 just before the drop
- Steps: delete the row externally mid-drag, complete the drop, screenshot
- Expected: the list shows the previous order and a localized error message; nothing is persisted
- Verify: APP+DB

### UC-043 — Board and mission detail agree on relative order
- Area: reorder
- Requirement: U-4.6, D-3.3, D-3.4
- Preconditions: a mission with three quests, plus two standalone quests interleaved
- Data needed: one open mission with quests M1–M3, two standalone quests S1, S2, interleaved `sortOrder`
- Steps: reorder M3 above M1 on the mission detail, go back, screenshot the Board
- Expected: the Board shows M3 before M1 and the positions of S1 and S2 are unchanged
- Verify: APP+DB

---

## Area: swipe actions and deletion

### UC-044 — Swiping a quest card reveals Upravit and Smazat
- Area: swipe
- Requirement: U-6.1, U-6.2
- Preconditions: app on the Board, Czech selected
- Data needed: one open quest
- Steps: drag the card leftwards with xdotool, screenshot, tap "Upravit"
- Expected: two 84px actions appear, "Upravit" on the raised ground and "Smazat" in the destructive colour; "Upravit" opens the quest sheet in edit mode with the quest's values
- Verify: APP

### UC-045 — Deleting an open quest asks for confirmation naming it
- Area: swipe
- Requirement: U-6.3, U-6.7, D-1.8
- Preconditions: one open quest named "Vynést koš"
- Data needed: one open quest named "Vynést koš", `totalXp = 40`
- Steps: swipe left, tap "Smazat", screenshot the confirmation, confirm, screenshot
- Expected: the confirmation names the quest; after confirming the row leaves with the list transition and Total_XP is still 40
- Verify: APP+DB

### UC-046 — Deleting a done quest says the XP is kept
- Area: swipe
- Requirement: U-6.4
- Preconditions: one quest completed today
- Data needed: one done quest with `awardedXp = 50`, `totalXp = 50`
- Steps: swipe the done card, tap "Smazat", screenshot the confirmation, confirm
- Expected: the confirmation states the earned XP is kept; after deletion the hero bar still shows 50 XP
- Verify: APP+DB

### UC-047 — Swiping a mission card reveals the same actions
- Area: swipe
- Requirement: U-6.5
- Preconditions: Missions tab with one open mission
- Data needed: one open mission with 2 quests
- Steps: swipe the mission card left, screenshot
- Expected: "Upravit" and "Smazat" appear in the same geometry and colours as on a quest card
- Verify: APP+DB

### UC-048 — Deleting a mission names it and counts its quests
- Area: swipe
- Requirement: U-6.6, D-4.5
- Preconditions: a mission with three quests, one of them done
- Data needed: one open mission "Velký úklid" with 3 quests, one done with `awardedXp = 25`, `totalXp = 25`
- Steps: swipe, tap "Smazat", screenshot the confirmation, confirm, relaunch
- Expected: the confirmation names the mission, says three quests go with it and that earned XP is kept; after confirming both the mission and all three quest rows are gone and Total_XP is still 25
- Verify: APP+DB

### UC-049 — Cancelling a deletion changes nothing
- Area: swipe
- Requirement: U-6.8
- Preconditions: one open quest with actions revealed
- Data needed: one open quest
- Steps: tap "Smazat", cancel the confirmation, screenshot; swipe again and tap elsewhere on the list
- Expected: both times the revealed actions close and the quest is still there
- Verify: APP

### UC-050 — Only one row shows revealed actions
- Area: swipe
- Requirement: U-6.9
- Preconditions: three open quests
- Data needed: three open quests
- Steps: swipe the first card, then swipe the second, screenshot
- Expected: the first row has closed and only the second shows its actions
- Verify: APP

### UC-051 — Swipe and reorder gestures do not collide
- Area: swipe
- Requirement: U-4.7
- Preconditions: three open quests
- Data needed: three open quests
- Steps: drag a card horizontally without a long press; then long-press and move vertically
- Expected: the horizontal drag reveals the swipe actions and does not lift the card; the long press lifts it for reordering and does not reveal actions
- Verify: APP

---

## Area: reward card

### UC-052 — Quest reward card anatomy
- Area: reward
- Requirement: U-7.1
- Preconditions: one open quest, Czech selected
- Data needed: one open quest "Uklidit sklep" (Normal, +25)
- Steps: tap the check circle, screenshot the card
- Expected: a parchment card over the scrim with a brass seal, "+25 XP", the caption "QUEST SPLNĚNO" and the quest name
- Verify: APP

### UC-053 — Mission progress block on the reward card
- Area: reward
- Requirement: U-7.2
- Preconditions: a mission with 3 quests, 1 already done
- Data needed: one open mission (bonus Medium) with 3 quests, 1 done (+25), two open (+25, +50)
- Steps: complete one of the open quests, screenshot
- Expected: the card shows done/total as 2/3, a progress bar at two thirds, and 50 XP remaining on the mission
- Verify: APP+DB

### UC-054 — Level-up variant
- Area: reward
- Requirement: U-7.3
- Preconditions: a completion that crosses a level boundary
- Data needed: one open quest (Hard, +50), `totalXp = 80`
- Steps: complete it, screenshot
- Expected: the card shows the level-up variant with level 2 and the caption "NOVÁ ÚROVEŇ"
- Verify: APP+DB

### UC-055 — Mission-ready reward card offers Dokončit misi and waits
- Area: reward
- Requirement: U-7.4, U-7.5, D-2.4
- Preconditions: a mission whose last open quest is being completed
- Data needed: one open mission with 2 quests, 1 done, 1 open
- Steps: complete the last open quest, wait 5 seconds, screenshot
- Expected: the card shows a primary "Dokončit misi" and a secondary "Pokračovat", and is still on screen after 5 seconds
- Verify: APP+DB

### UC-056 — Reward card auto-dismisses after 2.5 s and on tap
- Area: reward
- Requirement: U-7.5
- Preconditions: two standalone open quests
- Data needed: two standalone open quests
- Steps: complete the first, screenshot at 1 s and at 3.5 s; complete the second and tap the scrim immediately
- Expected: the first card is present at 1 s and gone at 3.5 s; the second disappears at once when the scrim is tapped
- Verify: APP

### UC-057 — Mission reward card
- Area: reward
- Requirement: U-7.6, D-5.7
- Preconditions: a mission ready to complete
- Data needed: one open mission "Velký úklid" (bonus Large, +200) with 2 quests, both done, `totalXp = 50`
- Steps: open the mission detail, tap "Dokončit misi", screenshot
- Expected: the caption reads "MISE SPLNĚNA", the bonus +200 and the mission name are shown; the hero bar afterwards reads 250 XP; because 250 crosses a boundary the level-up variant also appears
- Verify: APP+DB

### UC-058 — XP is applied behind the scrim
- Area: reward
- Requirement: U-7.7
- Preconditions: one open quest
- Data needed: one open quest (Normal, +25), `totalXp = 0`
- Steps: complete it and screenshot while the card is up, then after it closes
- Expected: the hero bar visible behind the scrim already shows the new value or is mid-animation; it is settled by the time the card closes
- Verify: APP

### UC-059 — Reduced motion replaces the animations with a fade
- Area: reward
- Requirement: U-7.8, U-16.5
- Preconditions: the device requests reduced motion
- Data needed: one open quest (Normal, +25)
- Steps: pump the reward overlay with `MediaQuery.disableAnimations = true` and record the transitions
- Expected: appearance and disappearance are a plain fade of at most 150 ms; the rays and the seal do not animate; slide and scale transitions elsewhere become fades too
- Verify: TEST

### UC-060 — Several rewards queue instead of stacking
- Area: reward
- Requirement: U-7.9
- Preconditions: two open quests
- Data needed: two standalone open quests (+10, +25)
- Steps: tap both check circles within about 300 ms, screenshot repeatedly
- Expected: one card at a time, the second following the first; never two cards or two scrims at once; both XP amounts land in Total_XP
- Verify: APP

---

## Area: missions screen

### UC-061 — Open missions listed as mission cards
- Area: missions
- Requirement: U-8.1, U-8.2, D-4.8
- Preconditions: Missions tab, Czech selected
- Data needed: one open mission "Naučit se ABAP" (bonus Medium) with 4 quests, 1 done (+25), remaining 10+25+50
- Steps: screenshot the card
- Expected: a 56px ring reading 1/4, the name, "Zbývá: 85 XP", and "+100" with the caption "za dokončení"
- Verify: APP+DB

### UC-062 — Ring without a stroke at zero progress
- Area: missions
- Requirement: U-8.3
- Preconditions: a mission with no done quests
- Data needed: one open mission with 3 quests, none done
- Steps: screenshot the card
- Expected: the ring shows 0/3 with no progress stroke drawn, only the track
- Verify: APP+DB

### UC-063 — "Připraveno k dokončení" replaces the remaining XP
- Area: missions
- Requirement: U-8.4, D-5.6
- Preconditions: a mission whose quests are all done but which is still open
- Data needed: one open mission with 2 quests, both done
- Steps: screenshot the card
- Expected: the caption "Připraveno k dokončení" sits where the remaining XP was; the mission has not completed itself
- Verify: APP+DB

### UC-064 — "Dokončeno dnes" section
- Area: missions
- Requirement: U-8.5, D-7.4
- Preconditions: a mission completed today
- Data needed: one mission `completed` today with `awardedBonus = 100`, plus one open mission
- Steps: screenshot the Missions screen
- Expected: a section "Dokončeno dnes" below the open missions, listing the completed one with +100 and the caption "získáno"
- Verify: APP+DB

### UC-065 — Yesterday's completed missions leave the section
- Area: missions
- Requirement: U-8.6, D-7.4
- Preconditions: a mission completed before the most recent 04:00
- Data needed: one mission `completed` with `completedAt` 36 hours ago, one open mission
- Steps: edit the row, relaunch, screenshot
- Expected: the "Dokončeno dnes" section is gone; the open mission is still listed; Total_XP is unchanged
- Verify: APP+DB

### UC-066 — Missions empty state
- Area: missions
- Requirement: U-8.7
- Preconditions: no missions at all
- Data needed: none — fresh database
- Steps: open the Missions tab, screenshot, tap the empty-state button
- Expected: an empty state with guidance and a button; the button opens the mission sheet
- Verify: APP

### UC-067 — Tapping a mission card opens its detail
- Area: missions
- Requirement: U-8.8
- Preconditions: one open mission
- Data needed: one open mission with 2 quests
- Steps: tap the card, screenshot
- Expected: the mission detail screen for that mission opens
- Verify: APP+DB

### UC-068 — Missions add button opens the mission sheet
- Area: missions
- Requirement: U-8.9
- Preconditions: Missions tab
- Data needed: none
- Steps: tap the floating add button, screenshot
- Expected: the mission sheet opens in create mode
- Verify: APP

### UC-069 — Closed missions and their quests are hidden everywhere
- Area: missions
- Requirement: D-7.6
- Preconditions: a `closed` mission with one open and one done quest
- Data needed: one mission `status = 'closed'` with 1 open quest and 1 done quest (`awardedXp = 25`)
- Steps: screenshot the Board and the Missions screen
- Expected: neither the mission nor either of its quests appears on either screen; the rows still exist in the database
- Verify: APP+DB

---

## Area: mission sheet

### UC-070 — Mission sheet contents and defaults
- Area: mission-sheet
- Requirement: U-9.1, U-9.2
- Preconditions: mission sheet open in create mode, Czech selected
- Data needed: none
- Steps: screenshot the sheet
- Expected: name field; bonus selector Malá +50 / Střední +100 / Velká +200 with Střední selected; quest rows each with a name field and a difficulty selector; an "Přidat quest" row below; "Zrušit", centred title, one brass "Zahájit misi"
- Verify: APP

### UC-071 — Creating a mission with its quests in one go
- Area: mission-sheet
- Requirement: D-4.1, D-4.6, U-9.9
- Preconditions: mission sheet open in create mode
- Data needed: none
- Steps: enter "Velký úklid", bonus Velká, add three quest rows (Easy, Normal, Hard), submit, screenshot the Missions screen and then the detail
- Expected: the sheet closes, the card shows 0/3 and +200, and the detail lists the three quests in the order entered
- Verify: APP

### UC-072 — Mission name validation
- Area: mission-sheet
- Requirement: U-9.3, D-4.2
- Preconditions: mission sheet open
- Data needed: none
- Steps: submit with an empty name, then with spaces only, then with 81 characters
- Expected: a localized error beside the name field each time, input kept, nothing created
- Verify: APP

### UC-073 — Empty quest rows ignored, over-long ones flagged
- Area: mission-sheet
- Requirement: U-9.4
- Preconditions: mission sheet with a valid name
- Data needed: none
- Steps: add three quest rows, fill only the first, submit; then add a row with 81 characters and submit
- Expected: the first submit creates a mission with exactly one quest; the second shows an error beside the offending row and creates nothing
- Verify: APP

### UC-074 — Removing a quest row
- Area: mission-sheet
- Requirement: U-9.5
- Preconditions: mission sheet with three quest rows filled
- Data needed: none
- Steps: tap the remove button on the middle row, screenshot
- Expected: the row leaves with the list transition and the other two keep their text and difficulties
- Verify: APP

### UC-075 — Edit mode changes only name and bonus
- Area: mission-sheet
- Requirement: U-9.6, D-4.3
- Preconditions: an open mission with 2 quests
- Data needed: one open mission with 2 quests
- Steps: swipe the mission card, tap "Upravit", screenshot, change name and bonus, save, screenshot
- Expected: no quest rows are shown; the saved card has the new name and bonus and still 2 quests
- Verify: APP+DB

### UC-076 — Editing a completed mission's bonus does not change what was earned
- Area: mission-sheet
- Requirement: U-9.7, D-4.4
- Preconditions: a mission completed today
- Data needed: one mission `completed` today, bonus Small, `awardedBonus = 50`, `totalXp = 50`
- Steps: edit it to bonus Velká, screenshot the notice, save, screenshot
- Expected: the sheet says the bonus already earned does not change; after saving the "Dokončeno dnes" row still shows +50 and Total_XP is still 50
- Verify: APP+DB

### UC-077 — Mission sheet discard confirmation
- Area: mission-sheet
- Requirement: U-9.8
- Preconditions: mission sheet open
- Data needed: none
- Steps: close an untouched sheet; then type a name and close; then fill a quest row only and close
- Expected: no prompt for the untouched sheet; a confirmation for both dirty cases
- Verify: APP

---

## Area: mission detail and completion

### UC-078 — Mission detail anatomy
- Area: mission-detail
- Requirement: U-10.1, D-7.5
- Preconditions: a mission with quests done on several days
- Data needed: one open mission (bonus Medium) with 3 quests: one done 36 hours ago, one done today, one open
- Steps: open the detail, screenshot
- Expected: the name, a large ring or bar reading 2/3, the bonus +100, and all three quests listed including the one done 36 hours ago
- Verify: APP+DB

### UC-079 — The "···" menu
- Area: mission-detail
- Requirement: U-10.2
- Preconditions: mission detail open, Czech selected
- Data needed: one open mission with 1 quest
- Steps: tap "···", screenshot
- Expected: a menu with "Upravit misi", "Přidat quest" and "Smazat misi" last and in the destructive colour
- Verify: APP+DB

### UC-080 — Deleting a mission from the detail returns to the list
- Area: mission-detail
- Requirement: U-10.4
- Preconditions: mission detail open
- Data needed: one open mission with 2 quests
- Steps: "···" → "Smazat misi", confirm, screenshot
- Expected: the confirmation of UC-048 appears, and after confirming the app is back on the Missions screen with the mission gone
- Verify: APP+DB

### UC-081 — "Dokončit misi" appears only when everything is done
- Area: mission-detail
- Requirement: U-10.5, D-5.3
- Preconditions: mission detail open
- Data needed: one open mission with 2 quests, 1 done, 1 open
- Steps: screenshot; complete the remaining quest; dismiss the reward card; screenshot
- Expected: no "Dokončit misi" button while a quest is open; it appears once both are done
- Verify: APP+DB

### UC-082 — Completing a mission awards the bonus
- Area: mission-detail
- Requirement: U-10.6, D-5.1, D-5.2
- Preconditions: a mission ready to complete
- Data needed: one open mission (bonus Medium) with 2 quests, both done (+25, +25), `totalXp = 50`
- Steps: tap "Dokončit misi", dismiss the reward card, screenshot the detail and the hero bar
- Expected: the mission shows as completed, Total_XP is 150, and the mission's `awardedBonus` is 100
- Verify: APP+DB

### UC-083 — Completed mission detail shows the seal and date and hides Přidat quest
- Area: mission-detail
- Requirement: U-10.7
- Preconditions: a mission completed today
- Data needed: one mission `completed` today with `awardedBonus = 100` and 2 done quests
- Steps: open the detail, screenshot, open the "···" menu, screenshot
- Expected: the seal, the earned bonus and the completion date are shown; the menu no longer offers "Přidat quest"
- Verify: APP+DB

### UC-084 — Reopening a quest of a completed mission reopens the mission
- Area: mission-detail
- Requirement: U-10.8, D-2.7
- Preconditions: a completed mission's detail is open
- Data needed: one mission `completed` today, bonus Medium, `awardedBonus = 100`, 2 done quests (+25 each), `totalXp = 150`
- Steps: tap a done quest's check circle, screenshot
- Expected: the detail shows the mission as open again, the message says the bonus was withdrawn, and Total_XP is 25
- Verify: APP+DB

### UC-085 — Detail closes itself when the mission disappears
- Area: mission-detail
- Requirement: U-10.9
- Preconditions: mission detail open
- Data needed: one open mission with 1 quest; the mission row deleted with sqlite3 while the detail is open
- Steps: delete the row externally and wait for the observable query to fire, screenshot
- Expected: the detail pops back to the Missions screen; no exception text, no blank screen
- Verify: APP+DB

### UC-086 — Mission with no quests shows an empty state
- Area: mission-detail
- Requirement: U-10.10, D-5.4
- Preconditions: an open mission whose quests were all deleted
- Data needed: one open mission with no quest rows
- Steps: open the detail, screenshot, then try to complete it
- Expected: an empty state pointing at "Přidat quest"; no "Dokončit misi" button, and the service rejects completion of an empty mission
- Verify: APP+DB

### UC-087 — An instance is marked as a recurring mission
- Area: mission-detail
- Requirement: U-10.11
- Preconditions: a mission posted from a rule, Czech selected
- Data needed: one recurring rule, one open instance of it (`ruleId` set) with 2 quests
- Steps: open the instance's detail, screenshot
- Expected: the caption "Pravidelná mise" is shown; a non-instance mission's detail does not show it
- Verify: APP+DB

### UC-088 — Mission completion is rejected in the wrong states
- Area: mission-detail
- Requirement: D-5.5, D-4.7
- Preconditions: none
- Data needed: one `completed` mission with 2 done quests; one `closed` mission with 1 done quest
- Steps: call Mission_Service.complete on each, and add a quest to each
- Expected: every call fails with an invalid-state error and changes nothing, including Total_XP
- Verify: TEST

### UC-089 — Reordering a subset leaves every other position untouched
- Area: reorder
- Requirement: D-3.3
- Preconditions: none
- Data needed: generated sets of 5–20 quests with arbitrary `sortOrder`, reordering a random subset
- Steps: run the property test over many generated cases
- Expected: the quests outside the subset hold their positions in every case
- Verify: TEST

---

## Area: recurring rules

### UC-090 — Rule rows in Settings
- Area: recurring
- Requirement: U-12.1
- Preconditions: Settings open, Czech selected
- Data needed: one recurring rule "Úklid", Monthly, posting day 1, bonus Medium, 3 quest templates
- Steps: screenshot the "Pravidelné mise" group
- Expected: a row with a repeat icon, the name, a line reading "Měsíčně · 3 questy · příště <date>" and a brass outline pill "Vyvěsit teď"; the list ends with a dashed add row
- Verify: APP+DB

### UC-091 — The pill reads "Vyvěšeno" while an instance is open
- Area: recurring
- Requirement: U-12.2, D-11.4
- Preconditions: a rule with an open instance
- Data needed: one recurring rule plus one open mission with its `ruleId`
- Steps: screenshot the rule row
- Expected: the pill reads "Vyvěšeno" and is dimmed
- Verify: APP+DB

### UC-092 — "Vyvěsit teď" posts the mission
- Area: recurring
- Requirement: U-12.3, D-10.1
- Preconditions: a rule with no open instance
- Data needed: one recurring rule "Úklid", Weekly, 2 quest templates (Easy, Normal), bonus Small
- Steps: tap "Vyvěsit teď", screenshot the message, go to the Missions tab, screenshot
- Expected: a message says the mission was posted; an open mission named "Úklid" appears with 0/2, bonus +50, and its two quests in template order
- Verify: APP+DB

### UC-093 — Manual posting reports the skipped scheduled posting
- Area: recurring
- Requirement: U-12.3, D-10.2, D-10.7
- Preconditions: a rule whose next occurrence is in the future
- Data needed: one recurring rule, anchor date two days ahead, `nextIndex = 0`
- Steps: tap "Vyvěsit teď", screenshot the message, reopen Settings, screenshot the row
- Expected: the message also says the nearest scheduled posting was skipped; the row's "příště" date has moved to the occurrence after the skipped one
- Verify: APP+DB

### UC-094 — Posting closes an earlier unfinished instance without a bonus
- Area: recurring
- Requirement: U-12.4, D-9.5, D-9.6, D-10.4
- Preconditions: a rule with an earlier open instance that is partly done
- Data needed: one recurring rule (2 quest templates); one open instance of it with one quest done (+25) and one open; `totalXp = 25`
- Steps: tap "Vyvěsit teď", screenshot the message, go to the Missions tab, screenshot, inspect the database
- Expected: the message says the unfinished mission was closed without a bonus; only the new instance is listed; the old mission's `status` is `closed`, its open quest row is deleted, its done quest row is kept, Total_XP is still 25
- Verify: APP+DB

### UC-095 — Manual posting on or after the due date skips to the next future occurrence
- Area: recurring
- Requirement: D-10.3, D-10.5, D-10.6
- Preconditions: a rule whose next occurrence is today or earlier
- Data needed: one daily recurring rule with its next occurrence yesterday
- Steps: post it manually, then run reconciliation (relaunch the app)
- Expected: the next occurrence is the first one dated after today; reconciliation posts nothing extra, whether the manual instance is untouched, partly done or fully done
- Verify: APP+DB

### UC-096 — Rule sheet opens in edit and create mode
- Area: recurring
- Requirement: U-12.5
- Preconditions: Settings open with one rule
- Data needed: one recurring rule, Monthly, 2 quest templates
- Steps: tap the rule row, screenshot; close; tap the dashed add row, screenshot
- Expected: the first opens the rule sheet in edit mode prefilled with the rule's name, cadence, posting day, bonus and templates; the second opens it empty in create mode
- Verify: APP+DB

### UC-097 — Rule sheet contents
- Area: recurring
- Requirement: U-12.6, D-11.5
- Preconditions: rule sheet open in create mode, Czech selected
- Data needed: none
- Steps: screenshot the whole sheet
- Expected: name field; six cadence chips Denně / Týdně / Každé 2 týdny / Měsíčně / Čtvrtletně / Ročně; a posting-day picker; a bonus selector; an ordered list of quest templates with name and difficulty; a help line saying unfinished quests do not carry over; the primary button "Uložit pravidlo"
- Verify: APP

### UC-098 — Posting-day picker per cadence
- Area: recurring
- Requirement: U-12.7, U-12.8
- Preconditions: rule sheet open with a name and one quest template filled
- Data needed: none
- Steps: select each of the six cadence chips in turn, screenshotting the picker row each time
- Expected: Denně offers no choice; Týdně and Každé 2 týdny offer a weekday; Měsíčně offers a day 1–28; Čtvrtletně and Ročně offer a full date; the name and the quest templates survive every change
- Verify: APP

### UC-099 — Rule validation
- Area: recurring
- Requirement: U-12.9, D-8.2, D-8.6
- Preconditions: rule sheet open
- Data needed: none
- Steps: submit with an empty name; with 81 characters; with no named quest template; and (through the service) with a monthly posting day of 29
- Expected: localized errors beside the offending fields, input kept, nothing saved; the service rejects day 29 with a validation error
- Verify: APP for the first three, TEST for the monthly day bound

### UC-100 — Saving a rule shows it with its next date
- Area: recurring
- Requirement: U-12.10, D-8.1, D-8.7, D-8.8
- Preconditions: rule sheet open in create mode
- Data needed: none
- Steps: enter "Úklid", cadence Měsíčně, posting day 1, bonus Střední, two quest templates; save; screenshot Settings; inspect the database
- Expected: the sheet closes and the row shows "Měsíčně · 2 questy · příště <the next 1st on or after today>"; the stored `anchorDate` is that date and `nextIndex` is 0
- Verify: APP+DB

### UC-101 — Editing a rule applies to future instances only
- Area: recurring
- Requirement: U-12.11, D-11.1
- Preconditions: a rule with an open instance
- Data needed: one recurring rule (2 templates, bonus Small) plus its open instance with 2 quests
- Steps: edit the rule to a new name, bonus Velká and three templates; screenshot the notice; save; screenshot the Missions tab; post the rule manually; screenshot
- Expected: the sheet says changes apply to the next posted mission only; the existing instance keeps its old name, bonus and two quests; the newly posted instance has the new name, +200 and three quests
- Verify: APP+DB

### UC-102 — Deleting a rule keeps its posted mission
- Area: recurring
- Requirement: U-12.12, D-11.2, D-11.3
- Preconditions: a rule with an open instance
- Data needed: one recurring rule plus its open instance with 2 quests
- Steps: open the rule sheet, tap "Smazat pravidlo", screenshot the confirmation, confirm, screenshot Settings and the Missions tab; relaunch
- Expected: the confirmation says the posted mission is kept and no further missions will be posted; the rule row is gone; the mission is still listed as an ordinary mission with no recurrence caption and `ruleId` null; relaunching posts nothing
- Verify: APP+DB

### UC-103 — Reconciliation posts one instance per due rule
- Area: recurring
- Requirement: D-9.1, D-9.4, D-9.9, U-17.3
- Preconditions: two due rules and one not-yet-due rule
- Data needed: rule A (daily, 2 templates) due yesterday; rule B (weekly, 1 template) due 3 days ago; rule C (monthly, 1 template) due in 10 days
- Steps: edit the rows, launch the app, screenshot the message and the Missions tab
- Expected: one instance each for A and B, none for C; each instance is open, named after its rule, carries the rule's bonus and one quest per template in template order
- Verify: APP+DB

### UC-104 — Several overdue occurrences still post only one instance
- Area: recurring
- Requirement: D-9.2, D-9.3
- Preconditions: a daily rule overdue by five days
- Data needed: one daily recurring rule with its next occurrence five days ago, 1 template
- Steps: launch, screenshot the Missions tab, inspect the rule row in the database
- Expected: exactly one instance exists; the rule's next occurrence is now the first one dated after today
- Verify: APP+DB

### UC-105 — Reconciliation twice on the same board day posts nothing extra
- Area: recurring
- Requirement: D-9.7
- Preconditions: a due rule already reconciled once
- Data needed: one due recurring rule, 1 template
- Steps: launch the app (first reconciliation), quit, launch again, screenshot
- Expected: still exactly one instance; no second message
- Verify: APP+DB

### UC-106 — Occurrence arithmetic for all six cadences
- Area: recurring
- Requirement: D-8.3, D-8.5
- Preconditions: none
- Data needed: anchor dates across month and year boundaries, indices 0–40, all six cadences
- Steps: assert occurrence `k` equals the anchor advanced by `k` days / `7k` days / `14k` days / `k` months / `3k` months / `k` years, computed from the anchor and not from the previous occurrence
- Expected: every case matches; drift does not accumulate over 40 indices
- Verify: TEST

### UC-107 — Short months clamp to the last day
- Area: recurring
- Requirement: D-8.4
- Preconditions: none
- Data needed: anchor 2026-01-31, monthly; anchor 2024-02-29, yearly
- Steps: compute occurrences 1–12
- Expected: February yields 28 (or 29 in a leap year), April yields 30, and the yearly rule yields 2025-02-28
- Verify: TEST

### UC-108 — Anchor is reset forward when cadence or posting day changes
- Area: recurring
- Requirement: D-8.7
- Preconditions: a rule already posted once
- Data needed: one recurring rule with `lastPostedOn` = today and an anchor in the past
- Steps: change the cadence through the service
- Expected: the new anchor is the first occurrence on or after today and strictly after `lastPostedOn`, and `nextIndex` is 0
- Verify: TEST

---

## Area: settings, profile, localization, theme and font

### UC-109 — Settings group order
- Area: settings
- Requirement: U-11.1
- Preconditions: Settings open, Czech selected
- Data needed: one recurring rule, so the group is not empty
- Steps: screenshot Settings from top to bottom
- Expected: back navigation, the title "Nastavení", then the groups Profil, Jazyk, Vzhled, Pravidelné mise, Dočasné, O aplikaci in that order
- Verify: APP+DB

### UC-110 — Hero name field, limit, counter and Total_XP
- Area: settings
- Requirement: U-11.2, U-11.3, U-11.4, D-12.6
- Preconditions: Settings open
- Data needed: `totalXp = 275`
- Steps: screenshot the Profile group; type "  Martin  ", move focus away, screenshot the hero bar; then try 41 characters
- Expected: the field has a 40-character limit with a counter and shows 275 XP in small type beside the name; the trimmed name "Martin" is saved and the hero bar updates at once; 41 characters shows a localized error and saves nothing
- Verify: APP+DB

### UC-111 — Language segmented control switches everything at once
- Area: settings
- Requirement: U-11.5, U-14.1, U-14.3, D-12.2
- Preconditions: Settings open, 10 open quests so the Board scrolls
- Data needed: 10 open quests, 2 open missions, 1 recurring rule
- Steps: note that English is highlighted; select Čeština; screenshot Settings, the Board and the Missions screen; scroll the Board first and check the position after the switch
- Expected: every visible string changes in the same frame with no empty or untranslated flash, scroll positions are preserved, and the highlight follows the selection
- Verify: APP+DB

### UC-112 — Theme segmented control
- Area: settings
- Requirement: U-11.6, U-15.1, D-12.4
- Preconditions: Settings open
- Data needed: 3 open quests, 1 open mission, 1 recurring rule — enough to judge every ground
- Steps: select Světlý, screenshot Settings and both tabs; select Tmavý, screenshot the same; select Systém, screenshot
- Expected: the control shows Světlý / Tmavý / Systém each with an icon, highlights the stored value, and the palettes match the `.design/DESIGN.md` token tables for Daylight and Guild Board
- Verify: APP+DB

### UC-113 — System theme follows the device brightness live
- Area: settings
- Requirement: U-15.2
- Preconditions: theme set to `system`
- Data needed: 3 open quests
- Steps: pump the app with `MediaQuery.platformBrightness` light, assert the Daylight palette, change it to dark and pump again
- Expected: the palette follows the platform brightness without a restart; Xvfb cannot change the desktop brightness, so this is a test, not an APP case
- Verify: TEST

### UC-114 — About group shows the version from the build information
- Area: settings
- Requirement: U-11.7, D-14.6
- Preconditions: Settings open
- Data needed: none
- Steps: screenshot the O aplikaci footer and compare with the `version:` line in `pubspec.yaml`
- Expected: the application name and that exact version are shown, read from the platform build information rather than a second copy of the string in Dart source
- Verify: APP

### UC-115 — A setting change applies without rebuilding the navigation stack
- Area: settings
- Requirement: U-11.8, D-12.8
- Preconditions: a mission detail pushed, then Settings on top of it
- Data needed: one open mission with 2 quests
- Steps: open a mission detail, open Settings from the hero bar, change the theme and the language, close Settings
- Expected: the detail behind is already in the new theme and language and is still the same pushed screen with its scroll position; nothing reloaded or popped
- Verify: APP+DB

### UC-116 — Font picker row and sheet
- Area: settings
- Requirement: U-13.1, U-13.2, D-12.5
- Preconditions: Settings open, Czech selected
- Data needed: none
- Steps: screenshot the "Dočasné" group, tap "Písmo titulků", screenshot the sheet
- Expected: the row shows the current font name (Figtree by default); the sheet lists Figtree, Bricolage Grotesque, Sora, Outfit, Unbounded and Cinzel, each row set in its own face with the sample "Nástěnka · +25", the name, a two-word character note and a brass tick on the current choice
- Verify: APP

### UC-117 — Choosing a font applies to the display role only
- Area: settings
- Requirement: U-13.3, U-13.4, U-13.6
- Preconditions: font sheet open
- Data needed: 3 open quests, 1 open mission
- Steps: choose Cinzel, screenshot Settings, the Board, the Missions screen and the quest sheet; then choose Unbounded and repeat; then return to Figtree
- Expected: page titles, sheet titles, the hero bar level text and the XP figures change face at once; card titles, meta rows and body text stay Figtree; each choice survives a relaunch
- Verify: APP+DB

### UC-118 — All six fonts and every icon are bundled, nothing is fetched
- Area: settings
- Requirement: U-13.5, U-15.8, U-19.6
- Preconditions: none
- Data needed: none
- Steps: assert every family and every `assets/icons/*.svg` declared in `pubspec.yaml` resolves from the bundle; then run the app with no network and walk the font sheet
- Expected: all six faces render, all icons are SVG assets rather than an icon font, and no asset is requested over the network
- Verify: TEST for the asset manifest, APP for the font sheet rendering

### UC-119 — Device language falls back to English
- Area: settings
- Requirement: D-12.3, U-14.2
- Preconditions: language setting `system`
- Data needed: device locale `de_DE`, then `cs_CZ`, then `en_GB`
- Steps: resolve the effective language for each
- Expected: `de_DE` resolves to `en`, `cs_CZ` to `cs`, `en_GB` to `en`
- Verify: TEST

### UC-120 — Semantic language of the application follows the setting
- Area: settings
- Requirement: U-14.4
- Preconditions: app running
- Data needed: none
- Steps: switch to Čeština and inspect the semantics tree's locale, then switch to English
- Expected: the announced locale matches the effective language each time
- Verify: TEST

### UC-121 — Dates, times and numbers follow the locale, and Czech plurals are right
- Area: settings
- Requirement: U-14.5
- Preconditions: none
- Data needed: quest counts 0, 1, 2, 4, 5, 11, 21 and a completion timestamp and a next-occurrence date
- Steps: assert the plural forms for Czech (1 / 2–4 / 5+) and English, and the formatting of the date, the time and a 4-digit XP figure in both locales
- Expected: "1 quest", "2 questy", "5 questů" in Czech and the English equivalents; dates, times and grouping match the locale
- Verify: TEST

### UC-122 — Settings defaults on a fresh database
- Area: settings
- Requirement: D-12.1, D-13.5
- Preconditions: fresh database
- Data needed: none
- Steps: launch with a fresh `HOME`, screenshot Settings, inspect the `app_state` row
- Expected: hero name empty, language `system`, theme `system`, display font `figtree`, Total_XP 0, exactly one `app_state` row with id 1
- Verify: APP+DB

### UC-123 — A setting change reaches every observer
- Area: settings
- Requirement: D-12.8
- Preconditions: two listeners on the settings stream
- Data needed: none
- Steps: change the hero name, the language, the theme and the font in turn
- Expected: each listener receives each new value exactly once
- Verify: TEST

---

## Area: day rollover, live data and persistence

### UC-124 — Board day boundary is the most recent local 04:00
- Area: rollover
- Requirement: D-7.7, U-17.1
- Preconditions: none
- Data needed: clock values 03:59, 04:00, 04:01, 23:59 and 00:30 on several dates, including a DST change
- Steps: compute the board day and the day start for each
- Expected: between 00:00 and 04:00 the board day is the previous calendar date; the boundary is the most recent local 04:00 and not a fixed 24-hour offset; the next day start is always in the future and always at 04:00
- Verify: TEST

### UC-125 — The board-day signal schedules and cancels its refresh
- Area: rollover
- Requirement: U-17.2, U-17.3
- Preconditions: app in the foreground with a controllable clock
- Data needed: one quest completed 10 minutes before the next 04:00
- Steps: advance the clock past 04:00 while in the foreground; then background the app, advance the clock, and return to the foreground
- Expected: in the foreground the done list refreshes at the boundary without a restart; the timer is cancelled in the background; on return the board day is re-evaluated, the done lists refresh and reconciliation runs
- Verify: TEST

### UC-126 — Done and completed windows are evaluated for the caller's Today
- Area: rollover
- Requirement: D-7.10
- Preconditions: none
- Data needed: quests and missions completed across three consecutive board days
- Steps: query the board and the missions for each of the three Today values
- Expected: each query returns only the items of the Today it was given
- Verify: TEST

### UC-127 — Everything survives an app restart
- Area: persistence
- Requirement: D-13.1, U-17.5
- Preconditions: a session that touched every table
- Data needed: created in the app itself — set a hero name, Čeština, light theme, Cinzel; create 3 quests (one with a note), complete one; create a mission with 2 quests and complete one of them; create a recurring rule and post it now
- Steps: quit the process, relaunch with the same `HOME`, screenshot every screen, compare with the screenshots taken before quitting
- Expected: the hero name, XP, level, quests and their order, notes, done states, missions and their progress, the rule and its posted instance, the language, the theme and the display font are all exactly as before
- Verify: APP

### UC-128 — Multi-row operations are atomic
- Area: persistence
- Requirement: D-13.2, D-13.3
- Preconditions: none
- Data needed: a mission with 3 quests; an injected failure partway through creating it, deleting it and posting an instance
- Steps: make each multi-row operation fail mid-transaction
- Expected: no partial rows afterwards; Total_XP, quests and missions are exactly as before the attempt
- Verify: TEST

### UC-129 — Schema migration keeps existing data
- Area: persistence
- Requirement: D-13.4
- Preconditions: a database at the previous schema version
- Data needed: 3 quests, 1 mission, 1 rule and a non-default settings row written at schema version N−1
- Steps: open the database with the current schema and read everything back
- Expected: the migration runs and every row and setting is still there; if version 1 is the only schema so far, the case records that explicitly rather than passing vacuously
- Verify: TEST

### UC-130 — Observable queries drive the screens
- Area: persistence
- Requirement: D-13.6, U-17.5
- Preconditions: Board and Missions both rendered
- Data needed: one open mission with 2 quests
- Steps: complete a quest on the Board, then switch to the Missions tab without any manual refresh
- Expected: the mission card's ring and remaining XP already reflect the completion; both tabs agree after every change
- Verify: APP+DB

### UC-131 — The clock is only ever read through Clock
- Area: persistence
- Requirement: D-13.7, U-17.4
- Preconditions: none
- Data needed: none
- Steps: grep `lib/` for `DateTime.now`, `DateTime.timestamp` and `Stopwatch` outside `lib/core/clock.dart`
- Expected: no hits outside the clock itself (an animation-only use is listed explicitly in the case result if one exists)
- Verify: TEST

### UC-132 — Completing the same quest twice awards once
- Area: xp
- Requirement: D-2.8, D-2.9
- Preconditions: one open quest
- Data needed: one open quest (Normal, +25), `totalXp = 0`
- Steps: call complete twice; then change a done quest's difficulty to Hard and reopen it
- Expected: Total_XP is 25, not 50; reopening withdraws the 25 recorded at completion, not 50
- Verify: TEST

---

## Area: errors and feedback

### UC-133 — Validation errors appear beside the field that caused them
- Area: errors
- Requirement: U-18.1
- Preconditions: each sheet open in turn
- Data needed: none
- Steps: trigger one validation error in the quest sheet, the mission sheet, the rule sheet and the hero-name field
- Expected: in every case the message sits beside the offending field, not in a snackbar or a dialog
- Verify: APP

### UC-134 — Not-found and invalid-state errors refresh the list
- Area: errors
- Requirement: U-18.2
- Preconditions: a row deleted externally while on screen
- Data needed: one open quest and one open mission, each deleted with sqlite3 while shown
- Steps: act on each stale row (complete the quest, open the mission)
- Expected: the list refreshes and a short message explains the item changed; no exception text
- Verify: APP+DB

### UC-135 — Domain errors are shown only as localized messages
- Area: errors
- Requirement: U-14.6, U-18.3
- Preconditions: Czech selected
- Data needed: a read-only database file, plus one stale row
- Steps: trigger a storage error and an invalid-state error and screenshot both messages
- Expected: both are Czech sentences offering a retry where appropriate; no class name, stack frame, SQL fragment or file path appears
- Verify: APP

### UC-136 — Snackbar placement and styling
- Area: errors
- Requirement: U-18.4
- Preconditions: app on the Board with quests
- Data needed: 3 open quests
- Steps: reopen a done quest to raise a snackbar, screenshot
- Expected: the snackbar sits above the tab bar and does not cover it or the add button, and uses the design tokens
- Verify: APP+DB

---

## Area: accessibility, layout and motion

### UC-137 — Hit areas of at least 44×44
- Area: a11y
- Requirement: U-16.1
- Preconditions: every screen and sheet rendered
- Data needed: the accessibility harness seed — quests of all three difficulties, a mission, a rule
- Steps: measure the hit area of every tappable element, including the 28px painted check circle
- Expected: no tappable element is smaller than 44×44 logical pixels
- Verify: TEST

### UC-138 — Every tappable element has a visible pressed state
- Area: a11y
- Requirement: U-16.2
- Preconditions: every screen and sheet rendered
- Data needed: the accessibility harness seed
- Steps: press and hold each tappable element and compare the rendered frame with the idle frame
- Expected: each one changes visibly while pressed
- Verify: TEST

### UC-139 — Semantic labels in the effective language
- Area: a11y
- Requirement: U-16.3
- Preconditions: every screen rendered in Czech and in English
- Data needed: the accessibility harness seed
- Steps: read the semantics tree and check the check circles, both add buttons, the gear, the swipe actions, the drag affordance and the "···" menu
- Expected: every one of them carries a label, and the label is in the effective language
- Verify: TEST

### UC-140 — Completion and reopening are announced
- Area: a11y
- Requirement: U-16.4
- Preconditions: a quest and a mission
- Data needed: one open quest, one mission ready to complete
- Steps: complete and reopen the quest, complete the mission, capturing the semantics announcements
- Expected: an announcement for each of the four events, in the effective language
- Verify: TEST

### UC-141 — Body text contrast of at least 4.5:1 in both themes
- Area: a11y
- Requirement: U-16.6
- Preconditions: none
- Data needed: every body-text / ground pair of both palettes
- Steps: compute the contrast ratio for each pair
- Expected: every pair reaches 4.5:1 — currently it does not; the gaps are the MEDIUM entry in `ISSUES.md` and are pinned in `test/ui/theme/contrast_test.dart`, so this case passes only once Martin signs off on the darkened tokens
- Verify: TEST

### UC-142 — Text at 130 % does not clip or overflow
- Area: a11y
- Requirement: U-16.7
- Preconditions: every screen and sheet rendered at `textScaler` 1.3
- Data needed: the accessibility harness seed, with the longest Czech strings
- Steps: render each screen and sheet at 1.0 and 1.3 and check for clipping and overflow
- Expected: no clipped text and no horizontal overflow at either scale
- Verify: TEST

### UC-143 — No horizontal overflow from 320 to 430 logical pixels
- Area: a11y
- Requirement: U-16.8
- Preconditions: every screen and sheet rendered
- Data needed: the accessibility harness seed
- Steps: render at widths 320, 375, 390 and 430 in both themes and both languages
- Expected: no overflow at any width; additionally resize the real app window to 320 and 430 and screenshot the Board, Missions and Settings
- Verify: TEST, plus APP for the window-resize spot check

### UC-144 — Haptics on the four events
- Area: a11y
- Requirement: U-16.9
- Preconditions: app on the device
- Data needed: one open quest, one mission ready to complete, three open quests to reorder
- Steps: complete a quest, complete a mission, pick a card up to reorder, confirm a destructive action
- Expected: haptic feedback on all four; the sandbox can only assert that the platform call is made, so the felt behaviour is Martin's check
- Verify: IOS (the call itself: TEST)

### UC-145 — Software keyboard, safe areas and the home indicator
- Area: a11y
- Requirement: U-5.1, U-16.8
- Preconditions: app on the device
- Data needed: one open mission, so the quest sheet has a picker
- Steps: open each sheet with the keyboard up, scroll it, and rotate nothing; check the top notch and the bottom home-indicator insets on every screen
- Expected: no field is hidden behind the keyboard, the primary button stays reachable, and nothing is clipped by the notch, the status bar or the home indicator
- Verify: IOS

---

## Area: visual fidelity against the design

Each of these compares the real application against the approved artboard render in
`.design/screens/`. The method is the same every time: set the window to 390×844, put
the app in the state the artboard shows, select Czech, screenshot with `scrot`, and read
the screenshot and the design PNG side by side. The requirement that wins any
disagreement is the spec, not the artboard (`CLAUDE.md`).

### UC-146 — Quest board, dark
- Area: visual
- Requirement: U-15.5, U-15.6, U-19.4
- Preconditions: dark theme, Czech
- Data needed: the artboard's content — a hero bar with a name and a level, 4–5 open quests mixing standalone and mission quests across all three difficulties, 1–2 quests done today
- Steps: compose that state, screenshot, compare with `.design/screens/QuestBoard.png`
- Expected: open quests render as parchment slips, done quests and mission cards on the raised ground, brass only on reward, completion and primary actions; grounds, radii, spacing and type sizes match the tokens
- Verify: APP+DB

### UC-147 — Quest board, light
- Area: visual
- Requirement: U-15.1, U-15.6
- Preconditions: light theme, Czech
- Data needed: the same content as UC-146
- Steps: screenshot, compare with `.design/screens/QuestBoardLight.png`
- Expected: the Daylight palette, and every quest card carries the 1px parchment-edge outline that the dark theme does not have
- Verify: APP+DB

### UC-148 — Empty board, both themes
- Area: visual
- Requirement: U-3.10, U-15.1
- Preconditions: fresh database
- Data needed: none
- Steps: screenshot the empty Board in dark and in light, compare with `.design/screens/EmptyBoard.png`
- Expected: the pinned blank slip, the display heading and the single sentence of guidance match in both themes
- Verify: APP

### UC-149 — Missions screen, both themes
- Area: visual
- Requirement: U-8.2, U-15.1
- Preconditions: Czech
- Data needed: the artboard's content — 2–3 open missions at different progress including one at 0 % and one ready to complete, and one mission completed today
- Steps: screenshot in both themes, compare with `.design/screens/Missions.png`
- Expected: ring geometry (56px, radius 24, stroke 5, round caps, hidden at 0 %), the remaining-XP line, the brass bonus with its caps caption, and the "Dokončeno dnes" section all match
- Verify: APP+DB

### UC-150 — Mission detail, both themes
- Area: visual
- Requirement: U-10.1, U-15.1
- Preconditions: Czech
- Data needed: one open mission with 4 quests, 2 done
- Steps: screenshot in both themes, compare with `.design/screens/MissionDetail.png`
- Expected: header, large progress indicator, bonus, quest list and the "···" button match the artboard
- Verify: APP+DB

### UC-151 — Quest sheet and mission sheet, both themes
- Area: visual
- Requirement: U-5.3, U-9.2, U-15.1
- Preconditions: Czech
- Data needed: two open missions, so the quest sheet's picker is populated
- Steps: screenshot both sheets in both themes, compare with `.design/screens/NewQuest.png` and `NewMission.png`
- Expected: sheet anatomy — grabber, Zrušit left, centred display title, labelled field groups, one brass primary button at the bottom, 24px top corners, scrim — matches both artboards
- Verify: APP+DB

### UC-152 — Reward card, both themes
- Area: visual
- Requirement: U-7.1, U-15.1
- Preconditions: Czech
- Data needed: one open mission with 3 quests, 1 done, so the card shows the mission progress block
- Steps: complete a quest, screenshot the card in both themes, compare with `.design/screens/QuestComplete.png`
- Expected: parchment card over the scrim, brass seal with rays, the 48px XP figure, the caps caption, the quest name, the mission progress block and "Pokračovat" all match; the card's 22px radius is correct
- Verify: APP+DB

### UC-153 — Swipe actions, both themes
- Area: visual
- Requirement: U-6.1, U-15.1
- Preconditions: Czech
- Data needed: 3 open quests
- Steps: reveal the actions on one card, screenshot in both themes, compare with `.design/screens/SwipeActions.png`
- Expected: two 84px actions, "Upravit" on the raised ground and "Smazat" in the destructive colour, with the artboard's geometry
- Verify: APP+DB

### UC-154 — Settings screen, both themes
- Area: visual
- Requirement: U-11.1, U-12.1, U-15.1
- Preconditions: Czech
- Data needed: a hero name, a non-zero Total_XP, and 2 recurring rules, one of them with an open instance
- Steps: screenshot the whole screen (scrolling as needed) in both themes, compare with `.design/screens/Settings.png`
- Expected: group order and labels, the segmented controls with their icons, the rule rows with the repeat icon tile and the brass outline pill (one of them dimmed as "Vyvěšeno"), the dashed add row, the Dočasné row and the version footer all match
- Verify: APP+DB

### UC-155 — Recurring-mission sheet, both themes
- Area: visual
- Requirement: U-12.6, U-15.1
- Preconditions: Czech
- Data needed: one recurring rule, Monthly, posting day 1, 3 quest templates
- Steps: open the rule sheet in edit mode, screenshot in both themes, compare with `.design/screens/RecurringMission.png`
- Expected: the six cadence chips, the posting-day picker row, the bonus selector, the ordered templates, the help line and "Uložit pravidlo" match
- Verify: APP+DB

### UC-156 — Font picker sheet, both themes
- Area: visual
- Requirement: U-13.2, U-15.1
- Preconditions: Czech
- Data needed: none
- Steps: screenshot the font sheet in both themes, compare with `.design/screens/FontPicker.png`
- Expected: six rows each set in their own face with the sample "Nástěnka · +25", the names, the character notes, the brass tick on Figtree, and the help line
- Verify: APP

### UC-157 — Token discipline, selection colour and radii
- Area: visual
- Requirement: U-15.3, U-15.4, U-15.7
- Preconditions: none
- Data needed: none
- Steps: assert the token values for card, field, sheet and reward radii, the touch-target minimum, the spacing scale and the three transition durations (≈200 ms, ≈300 ms, 300–400 ms); grep widget code for literal colours, radii, spacings and durations; check the text selection and cursor colour of every field
- Expected: the tokens hold those values, no literal appears in widget code outside `lib/ui/theme/`, and selection and cursors are brass
- Verify: TEST (the brass cursor additionally spot-checked in APP by selecting text in the quest sheet)

---

## Area: completed-work retention and history

### UC-158 — Done quests and completed missions are retained past their window
- Area: history
- Requirement: D-15.1
- Preconditions: items completed before the most recent 04:00
- Data needed: 2 quests and 1 mission completed 36 hours ago
- Steps: relaunch the app, confirm they are off the board, then read the rows
- Expected: all three rows are still in the database with their timestamps and awarded amounts
- Verify: APP+DB

### UC-159 — A closed instance keeps its done quests
- Area: history
- Requirement: D-15.2, D-9.6
- Preconditions: a rule posting over an unfinished instance
- Data needed: one rule with an open instance that has 1 done quest (+25) and 1 open quest
- Steps: post the rule now, then read the rows
- Expected: the done quest row is kept with its `awardedXp`; the open quest row is gone; the mission is `closed`
- Verify: APP+DB

### UC-160 — Deletion is permanent
- Area: history
- Requirement: D-15.3
- Preconditions: a mission with done quests
- Data needed: one open mission with 1 done quest and 1 open quest
- Steps: delete the mission, then read the tables
- Expected: the mission row and both quest rows are gone, including the done one
- Verify: APP+DB

### UC-161 — Quest history query
- Area: history
- Requirement: D-15.4, D-15.6, D-15.7
- Preconditions: quests completed across several board days
- Data needed: 5 done quests spread over 3 board days, 2 of them in a mission; plus one that is then reopened
- Steps: query a range of board days; then reopen one quest and query again
- Expected: the done quests are returned newest first with name, difficulty, awarded XP, completion timestamp and mission name where applicable; the query changes nothing, Total_XP included; the reopened quest is no longer returned
- Verify: TEST

### UC-162 — Mission history query
- Area: history
- Requirement: D-15.5, D-15.6
- Preconditions: missions completed across several board days
- Data needed: 3 `completed` missions spread over 3 board days with different awarded bonuses
- Steps: query a range of board days
- Expected: the missions are returned newest first with name and awarded bonus, and nothing is modified
- Verify: TEST

---

## Area: project structure and checks

### UC-163 — Source layout and the structure check
- Area: scaffolding
- Requirement: D-14.1, D-14.3, U-19.1
- Preconditions: none
- Data needed: none
- Steps: run `scripts/check-structure.sh`; confirm `lib/main.dart` sits in the root of `lib/` and that `core/`, `data/`, `services/`, `ui/` and `l10n/` hold the rest
- Expected: the script passes and no directory holds more than 15 source files
- Verify: TEST

### UC-164 — scripts/check.sh is the one gate
- Area: scaffolding
- Requirement: D-14.2, U-19.5
- Preconditions: none
- Data needed: none
- Steps: run `xvfb-run -a scripts/check.sh`
- Expected: static analysis, every unit, widget, property and golden test, and the structure check all pass
- Verify: TEST

### UC-165 — Env example, gitignore, lockfile and a single version
- Area: scaffolding
- Requirement: D-14.4, D-14.5, D-14.6
- Preconditions: none
- Data needed: none
- Steps: check that `.env.example` exists, that `.gitignore` covers `.env` files while keeping `.env.example`, that `pubspec.lock` is tracked, and that the version string appears only in `pubspec.yaml`
- Expected: all four hold
- Verify: TEST

### UC-166 — Widget tests exist for every screen and sheet
- Area: scaffolding
- Requirement: U-19.3, U-19.4
- Preconditions: none
- Data needed: none
- Steps: check that `test/ui/` holds a test for the Board, the Missions screen, the mission detail, Settings and each of the four sheets, each using an in-memory database and a controllable clock; and that `test/goldens/` holds Board, Missions and Settings in both themes
- Expected: all nine screens and sheets are covered and the six goldens exist and match
- Verify: TEST

### UC-167 — No business rule is duplicated in widget code
- Area: scaffolding
- Requirement: U-19.2
- Preconditions: none
- Data needed: none
- Steps: check that the XP amounts, the level formula, the bonus amounts, the board-day boundary and the occurrence arithmetic appear only under `lib/core/`, `lib/data/` and `lib/services/`, and that `lib/ui/forms/validators.dart` mirrors rather than redefines the domain limits
- Expected: widget code holds no rule of its own beyond mirrored form validation, and the mirrored limits agree with the domain (property test)
- Verify: TEST

### UC-168 — Bundle identifier and display name live in one place
- Area: scaffolding
- Requirement: U-19.7
- Preconditions: none
- Data needed: none
- Steps: find where `com.jablecnik.questlog` and the display name `Questlog` are set and count the places
- Expected: each is defined once and read from there by every platform target
- Verify: TEST

### UC-169 — iOS build and on-device run
- Area: scaffolding
- Requirement: U-19.7
- Preconditions: Martin's Mac with Xcode
- Data needed: none
- Steps: `flutter build ios`, install on the device, walk UC-001, UC-008, UC-127, UC-144 and UC-145
- Expected: the app builds, launches, and the gesture, keyboard, safe-area and haptic cases pass
- Verify: IOS

---

## Requirement coverage map

### 001-questlog-domain

| Req | Cases |
|---|---|
| D-1 Quest lifecycle | UC-031, UC-032, UC-033, UC-035, UC-036, UC-038, UC-045 |
| D-2 Quest completion and XP | UC-015, UC-021, UC-022, UC-023, UC-055, UC-084, UC-132 |
| D-3 Quest ordering | UC-031, UC-039, UC-042, UC-043, UC-089 |
| D-4 Mission lifecycle | UC-048, UC-061, UC-071, UC-075, UC-076, UC-088 |
| D-5 Mission completion and bonus | UC-057, UC-063, UC-081, UC-082, UC-086, UC-088 |
| D-6 Levels and XP progress | UC-013, UC-014 |
| D-7 Visibility windows | UC-017, UC-019, UC-027, UC-064, UC-065, UC-069, UC-078, UC-124, UC-126 |
| D-8 Recurring rule definition | UC-099, UC-100, UC-106, UC-107, UC-108 |
| D-9 Automatic posting | UC-005, UC-094, UC-103, UC-104, UC-105, UC-159 |
| D-10 Manual posting | UC-092, UC-093, UC-094, UC-095 |
| D-11 Rule editing and deletion | UC-091, UC-096, UC-101, UC-102 |
| D-12 Settings and profile | UC-010, UC-110, UC-111, UC-112, UC-116, UC-119, UC-122, UC-123 |
| D-13 Persistence and consistency | UC-122, UC-127, UC-128, UC-129, UC-130, UC-131 |
| D-14 Scaffolding and checks | UC-114, UC-163, UC-164, UC-165 |
| D-15 Completed-work history | UC-158, UC-159, UC-160, UC-161, UC-162 |

### 002-questlog-ui

| Req | Cases |
|---|---|
| U-1 App shell and navigation | UC-001, UC-002, UC-003, UC-004, UC-005, UC-006, UC-007, UC-008 |
| U-2 Hero bar | UC-009, UC-010, UC-011, UC-012, UC-016 |
| U-3 Quest board | UC-017 – UC-028, UC-148 |
| U-4 Quest reordering | UC-039, UC-040, UC-041, UC-042, UC-043, UC-051 |
| U-5 Quest sheet | UC-029 – UC-038, UC-145, UC-151 |
| U-6 Swipe actions and deletion | UC-044 – UC-050, UC-153 |
| U-7 Reward card | UC-052 – UC-060, UC-152 |
| U-8 Missions screen | UC-061 – UC-068, UC-149 |
| U-9 Mission sheet | UC-070 – UC-077, UC-151 |
| U-10 Mission detail | UC-034, UC-078 – UC-087, UC-150 |
| U-11 Settings and profile | UC-109, UC-110, UC-111, UC-112, UC-114, UC-115, UC-154 |
| U-12 Recurring rules in settings | UC-090 – UC-102, UC-154, UC-155 |
| U-13 Display-font picker | UC-116, UC-117, UC-118, UC-156 |
| U-14 Localization | UC-111, UC-119, UC-120, UC-121, UC-135 |
| U-15 Theming and design fidelity | UC-112, UC-113, UC-118, UC-146 – UC-157 |
| U-16 Interaction, motion, accessibility | UC-059, UC-137 – UC-145 |
| U-17 Day rollover and live data | UC-103, UC-124, UC-125, UC-127, UC-130, UC-131 |
| U-18 Errors and feedback | UC-007, UC-028, UC-037, UC-133, UC-134, UC-135, UC-136 |
| U-19 Project structure and verification | UC-024, UC-118, UC-143, UC-163 – UC-169 |
</content>
</invoke>
