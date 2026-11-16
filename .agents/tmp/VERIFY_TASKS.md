# Verification walkthrough — run 2026-11-15-1405

Ordered walkthrough of `.agents/USE_CASES.md` for the `verify` phase. Work top to
bottom: the passes are arranged so one trip through the application covers as many
cases as possible, and the time-dependent and visual cases come after the live ones so
the database can be mangled freely once the interactive passes are done.

Mark a step `[x]` only when every case it covers actually held. A case that failed and
could not be fixed goes into `.agents/ISSUES.md` with its UC id — never ticked.

---

## How to drive the real application

The app runs for real in this sandbox. The `build` phase already launched the release
bundle under Xvfb and screenshotted the Board, so this path is proven; what follows
only adds input and a controlled database location.

### Prerequisites checked on 2026-11-16

| Tool | Path | Use |
|---|---|---|
| `xvfb-run` / `Xvfb` | `/usr/bin` | the display |
| `xdotool` | `/usr/bin` | clicks, drags, typing, window geometry |
| `scrot` | `/usr/bin` | screenshots |
| `ffmpeg` | `/usr/bin` | cropping screenshots (`import`, `convert`, `xwd` are **not** installed) |
| `sqlite3` | `/usr/bin` | seeding and backdating the real on-disk database |

There is **no window manager** (openbox, matchbox, twm — none) and **no `faketime`**.
Both facts shape the recipe below.

### 1. Start a display and launch against a controlled HOME

```bash
cd /workspace/questlog
git config --global --add safe.directory /opt/flutter     # sandbox-flutter skill

WORK=/tmp/claude-1000/-workspace/<session>/scratchpad/verify   # NOT inside the repo
QL_HOME="$WORK/home"
mkdir -p "$QL_HOME"

flutter build linux --release        # already built by the build phase; rebuild if stale

Xvfb :99 -screen 0 520x1000x24 >/dev/null 2>&1 &
export DISPLAY=:99

HOME="$QL_HOME" build/linux/x64/release/bundle/questlog >"$WORK/app.log" 2>&1 &
sleep 3
```

`HOME` is what makes this work: `lib/data/database.dart` opens
`getApplicationDocumentsDirectory()/questlog.sqlite`, which on Linux resolves under
`$HOME`. Find the file once and keep the path:

```bash
DB="$(find "$QL_HOME" -name questlog.sqlite | head -1)"   # expect $QL_HOME/Documents/questlog.sqlite
```

A fresh `$QL_HOME` is therefore a fresh install, and deleting the file resets the app.

### 2. Size the window to an iPhone viewport

`linux/runner/my_application.cc` asks for 1280×720 and installs a **GTK header bar**,
which is a client-side widget and so is drawn *inside* the window. The design artboards
are 390×844 logical pixels, so set that plus the header strip and crop it away:

```bash
WID="$(xdotool search --name questlog | tail -1)"
xdotool windowmove  "$WID" 0 0
xdotool windowsize  "$WID" 390 881        # 844 + ~37px header bar; measure once and reuse
shot() { scrot -o "$WORK/$1.raw.png"; ffmpeg -y -loglevel error -i "$WORK/$1.raw.png" \
         -vf crop=390:844:0:37 "$WORK/$1.png"; }
```

Verify the crop offset on the first screenshot and then keep it constant. For UC-143
also resize to 320 and 430 wide and screenshot again.

### 3. Click, drag and type

With no window manager the X input focus is `PointerRoot`, so **keyboard events go to
whatever the pointer is over**. Move the pointer into the window before typing.

```bash
tap()   { xdotool mousemove $1 $(( $2 + 37 )) click 1; sleep 0.4; }   # y in app coords
swipe() { xdotool mousemove $1 $(( $2 + 37 )) mousedown 1; \
          xdotool mousemove_relative -- -170 0; sleep 0.2; xdotool mouseup 1; }
lift()  { xdotool mousemove $1 $(( $2 + 37 )) mousedown 1; sleep 0.8; }   # long press
drop()  { xdotool mousemove_relative -- 0 $1; sleep 0.3; xdotool mouseup 1; }
say()   { xdotool type --delay 40 -- "$1"; }
key()   { xdotool key --clearmodifiers "$1"; }
```

Coordinates come from the screenshots, not from guesswork: **screenshot, read the PNG
with the Read tool, compute the coordinate, then click.** That loop is the whole method
— every step below assumes it.

### 4. Seed and backdate with sqlite3

Stop the app before touching the database (`kill %1`), edit, relaunch. `DateTime`
columns are Drift's default, i.e. **Unix seconds**; `anchorDate` and `lastPostedOn` are
`YYYY-MM-DD` text.

```bash
NOW=$(date +%s); T=$(date -d 'today 09:00' +%s); OLD=$(date -d '36 hours ago' +%s)
sqlite3 "$DB" "UPDATE app_state SET total_xp=160, hero_name='Martin' WHERE id=1;"
sqlite3 "$DB" "INSERT INTO quests(name,difficulty,sort_order,created_at)
               VALUES('Vynést koš','normal',0,$NOW);"
sqlite3 "$DB" "UPDATE quests SET completed_at=$OLD, awarded_xp=25 WHERE id=1;"
sqlite3 "$DB" "UPDATE recurring_rules SET anchor_date='$(date -d yesterday +%F)', next_index=0;"
```

Backdating is the **only** way to put the real app into a "yesterday" state: there is
no `faketime` and `lib/main.dart` hard-wires `SystemClock`. Write the seeds as one
`seed-*.sql` file per pass under `$WORK`, never in the repository.

Confirm every expectation that is about stored state by reading the rows back, not only
by looking at the screen.

### 5. Language

The sandbox has no `LANG`, so `Effective_Language` resolves to **English**. Every case
that names a Czech string needs Settings → Jazyk → Čeština selected first; Pass E does
that once and the later passes stay in Czech.

### 6. Optional: integration_test

An `integration_test` driver would give programmatic taps instead of coordinates, but it
needs `integration_test: sdk: flutter` added to `dev_dependencies` — a pubspec change
this phase does not otherwise need. The xdotool route already covers the restart case
(UC-127) by killing the process and relaunching against the same `$QL_HOME`, which is a
truer restart than a driver can produce. **Only add the driver if the coordinate loop
turns out to be too brittle for the sheet-heavy passes (C, E, F)** — and if you do, note
the pubspec change in the phase report.

---

## Pass A — fresh install and empty states

- [ ] 1. Build the release bundle, start Xvfb, launch against an empty `$QL_HOME`, screenshot at ~0.3 s and at ~2.5 s
      Covers: UC-001
- [ ] 2. Screenshot the empty Board and the bottom tab bar; confirm two tabs only; switch to Mise and screenshot its empty state; tap the empty-state button and confirm the mission sheet opens, then cancel
      Covers: UC-002, UC-025, UC-066
- [ ] 3. Screenshot the hero bar on both tabs; open Settings with the gear, screenshot the defaults, read `app_state` with sqlite3; go back and confirm the tab returned to is the one you left
      Covers: UC-003, UC-122
- [ ] 4. Screenshot the Settings footer and compare the version with `version:` in `pubspec.yaml` (0.1.0)
      Covers: UC-114

## Pass B — create, complete, hero bar and rewards

- [ ] 5. From the Board add button, create four quests (Easy / Normal / Hard / Normal, one with a 200-character note); screenshot the sheet in create mode first, then the board
      Covers: UC-026, UC-029 (keyboard part is iOS), UC-030, UC-031
- [ ] 6. Screenshot the three difficulty cards close up; confirm the pips and the XP figures and that no colour differs by tier
      Covers: UC-018
- [ ] 7. Create a mission "Úklid" with two quests from the Missions tab, then create one more standalone quest; screenshot a mission quest and a standalone quest side by side
      Covers: UC-019, UC-068, UC-071
- [ ] 8. Complete one standalone quest: screenshot the reward card, screenshot at 1 s and 3.5 s, screenshot the board and the hero bar afterwards
      Covers: UC-021, UC-052, UC-056, UC-058
- [ ] 9. Complete a quest of "Úklid" and screenshot the reward card's mission progress block
      Covers: UC-053
- [ ] 10. Tap two check circles within ~300 ms and screenshot repeatedly through both rewards
      Covers: UC-060
- [ ] 11. Screenshot a done card close up; capture a three-frame burst of the hero-bar bar animation on the next completion
      Covers: UC-011, UC-020
- [ ] 12. Reopen a done quest from the Board; screenshot the message and the hero bar
      Covers: UC-022, UC-136
- [ ] 13. Screenshot the Board with four open and two done quests and confirm the order and the section split
      Covers: UC-017

## Pass C — sheets, validation, swipe and deletion

- [ ] 14. In the quest sheet try empty, whitespace-only and 81-character names, and a 501-character note; screenshot each error
      Covers: UC-032, UC-033
- [ ] 15. Close an untouched quest sheet; then close a dirty one with Zrušit and again with a swipe; screenshot both confirmations
      Covers: UC-037
- [ ] 16. Edit an open quest: new name, difficulty Hard, a note, a different mission; save and screenshot the card
      Covers: UC-036, UC-044
- [ ] 17. Swipe a card horizontally without a long press, then long-press and move vertically; screenshot both outcomes
      Covers: UC-051
- [ ] 18. Swipe the first card, then the second, and screenshot; cancel a deletion and tap elsewhere
      Covers: UC-049, UC-050
- [ ] 19. Delete an open quest named "Vynést koš": screenshot the confirmation, confirm, read `app_state.total_xp` before and after
      Covers: UC-045
- [ ] 20. Swipe a done quest and tap "Upravit": screenshot the sheet with the difficulty selector and mission picker disabled, change the name, save, confirm the XP and mission are unchanged. Then delete the done quest and screenshot the confirmation wording about kept XP; check Total_XP afterwards
      Covers: UC-035, UC-046
- [ ] 21. Open the mission sheet and walk its validation: empty / whitespace / 81-character name; three rows with only one filled; an 81-character row; remove the middle row
      Covers: UC-070, UC-072, UC-073, UC-074, UC-077
- [ ] 22. Trigger a validation error in each of the four sheets and in the hero-name field, confirming each message sits beside its field
      Covers: UC-133

## Pass D — missions and mission detail

- [ ] 23. Seed three missions at 0 %, part-done and all-done-but-open; screenshot the Missions screen and each card
      Covers: UC-061, UC-062, UC-063
- [ ] 24. Tap a mission card; screenshot the detail and the "···" menu; use "Přidat quest" and confirm the picker is preselected
      Covers: UC-034, UC-067, UC-079
- [ ] 25. On a mission with one quest open, confirm there is no "Dokončit misi"; complete the quest and confirm the reward card offers "Dokončit misi" and does not auto-dismiss after 5 s
      Covers: UC-055, UC-081
- [ ] 26. Complete the mission: screenshot the mission reward card, the detail afterwards and the hero bar; read `missions.awarded_bonus`
      Covers: UC-057, UC-082
- [ ] 27. On the completed mission's detail, screenshot the seal, bonus and date and confirm the menu no longer offers "Přidat quest"
      Covers: UC-083
- [ ] 28. Reopen a done quest of that completed mission from the detail; screenshot the message and the detail; read Total_XP
      Covers: UC-023, UC-084
- [ ] 29. Edit a mission from its swipe action (name and bonus only, no quest rows); then edit a completed mission's bonus and screenshot the notice; check the earned bonus did not change
      Covers: UC-047, UC-075, UC-076
- [ ] 30. Delete a mission with three quests (one done) from the detail menu: screenshot the confirmation, confirm, land back on the Missions screen, read the `quests` table
      Covers: UC-048, UC-080, UC-160
- [ ] 31. Delete every quest of a mission with sqlite3, relaunch, open the detail and screenshot the empty state
      Covers: UC-086
- [ ] 32. Reorder four open quests by long-press drag; screenshot mid-drag; relaunch and confirm the order stuck. Then try to drag a done card and to drop an open card among the done ones. Then cancel a drag with Escape / a release outside the list
      Covers: UC-039, UC-040, UC-041
- [ ] 33. Reorder a mission's quests on the detail screen, go back and confirm the Board shows the same relative order with the standalone quests untouched
      Covers: UC-043
- [ ] 34. Complete a quest on the Board, switch to Mise without refreshing, and confirm the ring and remaining XP already match
      Covers: UC-130

## Pass E — settings, language, theme and font

- [ ] 35. Seed a hero name and `total_xp = 275`; screenshot the Profile group; type "  Martin  " and blur; try 41 characters; screenshot the hero bar after each
      Covers: UC-010, UC-110
- [ ] 36. Scroll Settings top to bottom and screenshot the group order and labels
      Covers: UC-109
- [ ] 37. With ten quests on the Board scrolled halfway, switch to Čeština; screenshot Settings, the Board and the Missions screen and check the scroll positions
      Covers: UC-004, UC-111
- [ ] 38. Switch the theme to Světlý, screenshot all three screens; to Tmavý, screenshot again; then Systém. Compare the colours against the token tables in `.design/DESIGN.md`
      Covers: UC-112
- [ ] 39. Push a mission detail, open Settings over it, change theme and language, close Settings and confirm the detail is restyled, not rebuilt
      Covers: UC-115
- [ ] 40. Screenshot the "Dočasné" row and the font sheet; choose Cinzel and screenshot the Board, Missions, Settings and the quest sheet; choose Unbounded and repeat; relaunch to confirm the choice persists; return to Figtree
      Covers: UC-116, UC-117, UC-118 (the APP half)
- [ ] 41. Seed `total_xp = 12345`; screenshot the hero bar in both languages and compare the grouping and the digit widths
      Covers: UC-016
- [ ] 42. Seed `total_xp = 160` and screenshot the hero bar; then seed `total_xp = 80`, add a Hard quest, complete it and capture the level-up burst
      Covers: UC-009, UC-012, UC-054

## Pass F — recurring rules

- [ ] 43. Create a rule "Úklid": cadence Měsíčně, posting day 1, bonus Střední, two quest templates. Screenshot the sheet, then the saved row, then read `anchor_date` and `next_index`
      Covers: UC-097, UC-100
- [ ] 44. Reopen the rule sheet and cycle all six cadence chips, screenshotting the posting-day picker each time; confirm the name and templates survive. Then try an empty name, an 81-character name and no named template
      Covers: UC-096, UC-098, UC-099 (the APP half)
- [ ] 45. Screenshot the rule row's line and pill; tap "Vyvěsit teď"; screenshot the message; check the posted mission on the Missions tab and its quest order
      Covers: UC-090, UC-092
- [ ] 46. Screenshot the rule row again while the instance is open (the dimmed "Vyvěšeno" pill); open the instance's detail and screenshot the "Pravidelná mise" caption
      Covers: UC-087, UC-091
- [ ] 47. Set the rule's anchor two days ahead, relaunch, post it manually and screenshot the message about the skipped posting; check the new "příště" date
      Covers: UC-093
- [ ] 48. Complete one quest of the open instance, leave the other open, then post the rule again: screenshot the message about the closed mission, check that the old mission is `closed`, its open quest row gone, its done quest row kept and Total_XP unchanged
      Covers: UC-094, UC-159
- [ ] 49. Edit the rule (new name, bonus Velká, three templates) and screenshot the notice; confirm the existing instance is untouched; post again and confirm the new instance carries the changes
      Covers: UC-101
- [ ] 50. Delete the rule: screenshot the confirmation, confirm, check the row is gone, the mission remains with `rule_id` null and no recurrence caption, and relaunching posts nothing
      Covers: UC-102

## Pass G — backdated states (stop, edit, relaunch)

- [ ] 51. Backdate a done quest's `completed_at` to 36 hours ago, relaunch, screenshot the Board; confirm Total_XP unchanged and the row still present
      Covers: UC-027, UC-158
- [ ] 52. Backdate a completed mission's `completed_at` the same way, relaunch, screenshot the Missions screen
      Covers: UC-065
- [ ] 53. Seed a mission completed today with a bonus and screenshot the "Dokončeno dnes" section
      Covers: UC-064
- [ ] 54. Seed a mission with `status = 'closed'` holding one open and one done quest; relaunch and confirm neither it nor its quests appear on either screen while the rows still exist
      Covers: UC-069
- [ ] 55. Seed a mission with quests done 36 hours ago, done today and still open; screenshot the detail and confirm all three are listed
      Covers: UC-078
- [ ] 56. Seed three rules — due yesterday, due 3 days ago, due in 10 days — relaunch and screenshot the message and the Missions tab; read the rule rows back
      Covers: UC-006, UC-103
- [ ] 57. Seed a daily rule overdue by five days, relaunch, confirm one instance and a next occurrence after today
      Covers: UC-104
- [ ] 58. With a due rule, relaunch twice and confirm the second launch posts nothing and shows no message
      Covers: UC-105
- [ ] 59. With a due rule, unfocus and refocus the window twice and confirm exactly one instance across both cycles
      Covers: UC-005
- [ ] 60. Post a due rule manually, then relaunch, and confirm reconciliation adds nothing — repeating with the manual instance untouched, partly done and fully done
      Covers: UC-095

## Pass H — restart persistence

- [ ] 61. From a fresh `$QL_HOME`, do a full session in the app: hero name, Čeština, light theme, Cinzel, three quests (one noted) with one completed, a mission with two quests and one completed, a rule created and posted now. Screenshot every screen, kill the process, relaunch against the same `$QL_HOME`, screenshot every screen again and diff the pairs
      Covers: UC-127

## Pass I — visual comparison against `.design/screens`

Work in Czech at 390×844, both themes, reading each screenshot next to its design PNG.

- [ ] 62. Quest board, dark — compose the artboard's content and compare with `QuestBoard.png`
      Covers: UC-146
- [ ] 63. Quest board, light — same content, compare with `QuestBoardLight.png`, checking the 1px parchment-edge outline
      Covers: UC-147
- [ ] 64. Empty board in both themes — compare with `EmptyBoard.png`
      Covers: UC-148
- [ ] 65. Missions screen in both themes — compare with `Missions.png`, checking the ring geometry
      Covers: UC-149
- [ ] 66. Mission detail in both themes — compare with `MissionDetail.png`
      Covers: UC-150
- [ ] 67. Quest sheet and mission sheet in both themes — compare with `NewQuest.png` and `NewMission.png`
      Covers: UC-151
- [ ] 68. Reward card in both themes — compare with `QuestComplete.png`
      Covers: UC-152
- [ ] 69. Swipe actions in both themes — compare with `SwipeActions.png`
      Covers: UC-153
- [ ] 70. Settings in both themes, with two rules one of them posted — compare with `Settings.png`
      Covers: UC-154
- [ ] 71. Recurring-mission sheet in both themes — compare with `RecurringMission.png`
      Covers: UC-155
- [ ] 72. Font picker sheet in both themes — compare with `FontPicker.png`
      Covers: UC-156
- [ ] 73. Resize the window to 320 and then 430 wide and screenshot the Board, Missions and Settings; also spot-check the brass text cursor by selecting text in the quest sheet
      Covers: UC-143 (the APP half), UC-157 (the APP half)

## Pass J — error paths

Run these last of the live passes: they deliberately corrupt the environment.

- [ ] 74. Delete a quest row with sqlite3 while its card is on screen, then tap its check circle; repeat with a mission row and opening its detail; and once more mid-drag, deleting the row between the lift and the drop so the reorder is rejected and the previous order is restored
      Covers: UC-028, UC-042, UC-085, UC-134
- [ ] 75. With a mission picked in an open quest sheet, set that mission's `status = 'completed'` externally, then submit
      Covers: UC-038
- [ ] 76. `chmod 444` the database file and launch with a due rule: screenshot the retry message, confirm the existing data shows and that tabs and sheets still open; screenshot both a storage and an invalid-state message in Czech and check for any exception text
      Covers: UC-007, UC-135

## Pass K — cases that only a test can reach

Run `xvfb-run -a scripts/check.sh` first; it already covers most of these (638 tests,
including the six goldens). For each case below, confirm the covering test exists and
asserts what the case says — and where it does not, write it.

- [ ] 77. Run `xvfb-run -a scripts/check.sh` and record the result
      Covers: UC-164
- [ ] 78. Structure, env, lockfile, single version string, bundle id and display name
      Covers: UC-163, UC-165, UC-168
- [ ] 79. XP and level arithmetic: thresholds, derived level, progress, no cap, level before/after including downward, the zero floor, double completion and difficulty changed after completion
      Covers: UC-013, UC-014, UC-015, UC-132
- [ ] 80. Board-day arithmetic: the 04:00 boundary across midnight and a DST change, the next day start, and per-Today evaluation of the done and completed windows
      Covers: UC-124, UC-126
- [ ] 81. Board-day signal: refresh scheduled in the foreground, cancelled in the background, re-evaluated with reconciliation on return
      Covers: UC-125
- [ ] 82. Occurrence arithmetic for all six cadences over indices 0–40, short-month clamping, the monthly 1–28 bound, and the forward anchor reset after a cadence change
      Covers: UC-099 (the TEST half), UC-106, UC-107, UC-108
- [ ] 83. Mission completion rejected when not open, when a quest is open and when there are no quests; adding a quest to a non-open mission
      Covers: UC-088
- [ ] 84. Reorder property: a reordered subset leaves every other position unchanged
      Covers: UC-089
- [ ] 85. Transaction atomicity under an injected mid-transaction failure, and the schema-migration case (state explicitly if version 1 is still the only schema)
      Covers: UC-128, UC-129
- [ ] 86. `DateTime.now` appears nowhere in `lib/` outside `lib/core/clock.dart`
      Covers: UC-131
- [ ] 87. Settings: device-language fallback to English, the semantic application locale, locale formatting and Czech plurals (1 / 2–4 / 5+), and that a change reaches every observer
      Covers: UC-119, UC-120, UC-121, UC-123
- [ ] 88. Skeleton cards on the first load of the Board and the Missions screen
      Covers: UC-024
- [ ] 89. Theme follows `MediaQuery.platformBrightness` live when the setting is `system`
      Covers: UC-113
- [ ] 90. Asset manifest: all six font families and every `assets/icons/*.svg` resolve from the bundle, no icon font, nothing fetched at runtime
      Covers: UC-118 (the TEST half)
- [ ] 91. Accessibility sweep: 44×44 hit areas, visible pressed states, semantic labels in both languages, announcements on completion and reopening, and text at 130 % plus widths 320–430 without clipping or overflow
      Covers: UC-137, UC-138, UC-139, UC-140, UC-142, UC-143 (the TEST half)
- [ ] 92. Reduced motion: the reward card fades in ≤150 ms and the rays and seal do not animate; slide and scale transitions elsewhere become fades
      Covers: UC-059
- [ ] 93. Token discipline: the radii, touch-target minimum, spacing scale and the three duration bands; no literal colour, radius, spacing or duration in widget code; brass selection and cursor
      Covers: UC-157 (the TEST half)
- [ ] 94. Widget tests exist for all nine screens and sheets with an in-memory database and a controllable clock, and the six goldens match
      Covers: UC-166
- [ ] 95. No domain rule is duplicated in widget code, and `lib/ui/forms/validators.dart` agrees with the domain limits
      Covers: UC-167
- [ ] 96. History queries: done quests and completed missions over a range of board days, newest first, with the required fields; nothing modified; a reopened quest drops out
      Covers: UC-161, UC-162
- [ ] 97. Body-text contrast ≥ 4.5:1 in both themes. This currently **fails** — the gaps are the MEDIUM entry in `.agents/ISSUES.md` and are pinned in `test/ui/theme/contrast_test.dart`. Do not tick this step; confirm the pinned list has not grown and leave the issue open for Martin's sign-off
      Covers: UC-141
- [ ] 98. Haptics: assert the platform call is made on completing a quest, completing a mission, lifting a card to reorder and confirming a destructive action
      Covers: UC-144 (the TEST half)

## Pass L — hand to Martin (iOS only)

Do not attempt these; list them in the phase report as the iOS hand-over.

- [ ] 99. Record the iOS-only cases for Martin: edge-swipe back on every pushed screen, the software keyboard with every sheet, safe areas and the home indicator, the felt haptics, and the `flutter build ios` + on-device walk of UC-001/008/127/144/145
      Covers: UC-008, UC-029 (keyboard part), UC-144 (felt part), UC-145, UC-169

---

## When this file is done

`verify` deletes this file at the end of its phase (it is the consumer). `USE_CASES.md`
is persistent and stays.
</content>
