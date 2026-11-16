# Implementation Plan: Questlog UI

## Overview

Build the Questlog screens on top of the finished domain layer from `001-questlog-domain`. Work proceeds from the bottom up: dependencies, assets and localization; Design_Tokens and the theme; pure UI logic (reorder, validation, posting day, rewards, Board_Day signal); shared widgets; then the shell and each screen with its sheets; finally cross-cutting verification. Every task is followed by its tests, and the design contract is `.design/DESIGN.md` with the artboards in `.design/artboards/`. Spec 001 must be complete before this plan starts; the services and providers named below come from it.

## Tasks

- [ ] 1. Add dependencies, assets and localization setup
  - [x] 1.1 Add packages and configuration
    - Run `git config --global --add safe.directory /opt/flutter` if flutter fails with dubious ownership (skill `sandbox-flutter`)
    - Add `flutter_svg`, `flutter_slidable`, `intl`, `package_info_plus` and `flutter_localizations` (SDK) to `pubspec.yaml`; commit the updated `pubspec.lock`
    - Create `l10n.yaml` with `arb-dir: lib/l10n`, `template-arb-file: app_cs.arb`, `output-localization-file: app_localizations.dart`, `synthetic-package: false`, `output-dir: lib/l10n`
    - Create the directories listed under Project Structure in `design.md` (`lib/ui/...`, `lib/l10n/`, `assets/fonts/`, `assets/icons/`, `test/ui/`, `test/goldens/`)
    - _Requirements: 14.1, 19.1, 19.6_

  - [x] 1.2 Bundle fonts and SVG icons
    - Obtain the static TTF files for Figtree (400–800) and for Bricolage Grotesque, Sora, Outfit, Unbounded and Cinzel (600–800), all SIL Open Font Licence, from Google Fonts into `assets/fonts/`; if the sandbox has no network access, stop and ask the user to place the files there
    - Declare every family and weight under `flutter: fonts:` in `pubspec.yaml`, and declare `assets/icons/`
    - Draw the SVG icons listed in `design.md` on a 24px grid with `currentColor` strokes into `assets/icons/`
    - Add a test that loads every declared font family and icon asset and fails when one is missing
    - _Requirements: 13.5, 15.8, 19.6_

  - [x] 1.3 Make the bundle identifier and display name configurable
    - Set the display name `Questlog` and the bundle identifier `com.jablecnik.questlog` (same prefix as TimeLog's `com.jablecnik.timelogApp`) in `ios/Runner/Info.plist` and the Xcode project in one place; document in the project README where the user changes them
    - _Requirements: 19.7_

- [ ] 2. Implement Design_Tokens, typography and theme
  - [x] 2.1 Implement tokens, typography and theme
    - `lib/ui/theme/tokens.dart`: `QuestlogPalette.guildBoard` and `daylight` with the values in `.design/DESIGN.md`, `Space`, `Radii`, `Metrics`, `Motion`
    - `lib/ui/theme/typography.dart`: `displayFamilyName`, `buildDisplayTextTheme`, `buildBodyTextTheme` as two separate roles, with tabular figures for XP
    - `lib/ui/theme/questlog_theme.dart`: `buildTheme` for dark and light with brass selection and cursor colours, sheet and dialog shapes, snackbar and pressed states
    - _Requirements: 13.4, 13.6, 15.1, 15.2, 15.3, 15.4, 15.7_

  - [x] 2.2 Write theme tests
    - **Property 7: Text contrast**
    - For every text and background pair used by the design, in both palettes, the contrast ratio is at least 4.5:1
    - **Validates: Requirements 15.1, 16.6**
    - Unit: `buildTheme` succeeds for both palettes and for each `DisplayFont`; the body family stays Figtree when the display font changes
    - _Requirements: 13.4_

- [ ] 3. Implement the pure UI logic
  - [x] 3.1 Implement reordering helper
    - `lib/ui/state/reorder.dart`: `moveWithinSubset(shownIds, oldIndex, newIndex)` with Flutter's `ReorderableList` index semantics
    - _Requirements: 4.2, 4.6_

  - [x] 3.2 Write property tests for reordering
    - **Property 1: Reordering a subset preserves everything else**
    - For any list of ids and any valid old and new index, the result is a permutation with the moved id at the target position and all others in their original relative order
    - **Validates: Requirements 4.2, 4.6**

  - [x] 3.3 Implement form validators and error text
    - `lib/ui/forms/validators.dart`: `FieldError`, `validateName`, `validateNote`, `validateHeroName`, `validateRuleQuests`
    - `lib/ui/forms/error_text.dart`: `fieldErrorText`, `domainErrorText` (added after task 4.1 provides the strings)
    - _Requirements: 5.4, 9.3, 9.4, 11.4, 12.9, 18.1, 18.3_

  - [x] 3.4 Write property tests for validators
    - **Property 2: Client validation agrees with the domain**
    - For any string, each validator accepts exactly what the matching service accepts (name 1–80 trimmed, note ≤ 500, hero name ≤ 40 trimmed); compare against the services from spec 001 on an in-memory database
    - **Validates: Requirements 5.4, 9.3, 9.4, 11.4, 12.9, 19.2**

  - [x] 3.5 Implement posting day
    - `lib/ui/forms/posting_day.dart`: `PostingDay` hierarchy, `requestedAnchor`, `postingDayOf`, `defaultPostingDay`
    - _Requirements: 12.6, 12.7, 12.8_

  - [x] 3.6 Write property tests for posting day
    - **Property 3: Posting day yields a valid requested anchor**
    - For any Cadence, posting day and today, the requested anchor is on or after today, less than one period later, matches the posting day, and `postingDayOf` returns the posting day again; Monthly day 28 and Yearly Feb 29 are covered as examples
    - **Validates: Requirements 12.6, 12.7, 12.8**

  - [x] 3.7 Implement reward events
    - `lib/ui/state/reward_queue.dart`: `RewardEvent` (`QuestReward`, `MissionReward`), `rewardForQuest`, `rewardForMission`, `RewardQueue` notifier with `push` and `dismissCurrent`, showing one event at a time
    - _Requirements: 7.1, 7.3, 7.4, 7.6, 7.9_

  - [x] 3.8 Write property tests for rewards
    - **Property 4: Reward events reflect the service result**
    - For any completion results, `levelUp` is true exactly when the level rose, the XP is carried unchanged and the mission-complete offer matches `missionReadyToComplete`
    - **Validates: Requirements 7.1, 7.3, 7.4, 7.6**
    - Unit: events pushed in quick succession are shown in order, one at a time
    - _Requirements: 7.9_

  - [x] 3.9 Implement the Board_Day signal
    - `lib/ui/state/board_day.dart`: `untilNextBoardDay(now)` built on `core/board_day.dart`, `BoardDayNotifier` that schedules a timer in the foreground, cancels it on pause and re-evaluates on resume
    - _Requirements: 17.1, 17.2, 17.3, 17.4_

  - [x] 3.10 Write tests for the Board_Day signal
    - **Property 5: Next Board_Day is always in the future and 04:00**
    - For any local instant including DST changes, `untilNextBoardDay` is positive and lands on a local 04:00
    - **Validates: Requirements 17.1, 17.2**
    - Unit with `FixedClock` and fake timers: the notifier changes state when the clock passes 04:00, cancels while backgrounded and re-evaluates on resume
    - _Requirements: 17.2, 17.3_

- [ ] 4. Add localization
  - [x] 4.1 Write the translations
    - `lib/l10n/app_cs.arb` (template) and `app_en.arb` with every user-facing string used by this spec: tabs, Hero_Bar, board, quest and mission sheets, rewards, missions, detail, settings, rule sheet, font sheet, confirmations, snackbars and errors
    - Use ICU plurals for counts of Quests (Czech `one`/`few`/`other`) and the Czech wording quoted in the requirements
    - Run `flutter gen-l10n`
    - _Requirements: 14.1, 14.5, 14.6_

  - [x] 4.2 Write localization tests
    - **Property 6: Czech and English plural forms**
    - For any non-negative count, the Czech label uses `one` for 1, `few` for 2–4 and `other` otherwise, and the English label uses `one` for 1 and `other` otherwise
    - **Validates: Requirements 14.5**
    - Unit: every key in `app_cs.arb` exists in `app_en.arb` and the reverse; `domainErrorText` never contains exception text
    - _Requirements: 14.1, 14.6_

- [x] 5. Checkpoint — Foundations
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Implement shared widgets
  - [x] 6.1 Implement common widgets
    - `lib/ui/widgets/common/`: `AppIcon` (flutter_svg), `QuestlogSegmented`, `EmptyState` (pinned blank slip), `SkeletonList` (static under reduced motion), snackbar host, haptic helper and a semantic announcement helper that announces Quest and Mission completion and reopening
    - Every tappable widget has a 44×44 hit area, a pressed state and a semantic label
    - _Requirements: 3.9, 3.10, 15.8, 16.1, 16.2, 16.3, 16.4, 16.5, 16.9, 18.4_

  - [x] 6.2 Implement card widgets
    - `lib/ui/widgets/cards/`: `CheckCircle` (28px painted, 44px hit area), `DifficultyPips`, `ProgressRing` (r 24, stroke 5, round caps, no stroke at 0), `QuestCard` (open and done variants, light-theme outline) and `MissionCard` (remaining XP, "Připraveno k dokončení" state, bonus caption)
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 8.2, 8.3, 8.4, 15.5, 15.6, 16.1_

  - [x] 6.3 Write card widget tests
    - **Property 8: Progress ring geometry**
    - For any `done` in `0..total`, the ring sweep equals `done / total` and no stroke is drawn at 0
    - **Validates: Requirements 8.2, 8.3**
    - Widget: Quest_Card shows the Mission chip or "bez mise", correct pips and XP, strike-through and completion time when done; Mission_Card shows remaining XP or the ready caption; check circle hit area is at least 44×44
    - _Requirements: 3.2, 3.3, 3.5, 8.4, 16.1_

  - [x] 6.4 Implement Hero_Bar
    - `lib/ui/widgets/hero/`: `LevelBadge` and `HeroBar` reading Xp_Engine progress and the hero name, with an animated progress bar that fills to the end before wrapping on a Level-up, tabular XP figures and the gear button
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 1.3_

  - [x] 6.5 Write Hero_Bar tests
    - Widget: with and without a hero name, current / threshold text, remaining XP, progress animation and wrap on Level-up using fake time
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 6.6 Implement sheet scaffold and confirmation dialog
    - `lib/ui/widgets/sheet/`: `showQuestlogSheet` (grabber, "Zrušit", centred title, brass primary button, discard confirmation when `isDirty`), `confirmDestructive`
    - _Requirements: 5.3, 5.8, 9.2, 9.8, 18.5_

  - [x] 6.7 Implement the Reward_Card and overlay
    - `lib/ui/widgets/reward/`: `RewardCard` (seal with rays, "+N XP", caption, name, mission block, Level-up variant, "Dokončit misi" and "Pokračovat") and `RewardOverlay` consuming `RewardQueue`, auto-dismissing after 2.5 s unless the mission-complete offer is shown, plain fade under reduced motion
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 16.5_

  - [x] 6.8 Write reward and sheet widget tests
    - Widget: quest, mission and level-up variants render the right text; auto-dismiss at 2.5 s and no auto-dismiss with the mission offer; tapping the scrim dismisses; queued events appear one after another; reduced motion uses a fade; dirty sheet asks before discarding and clean sheet does not
    - _Requirements: 5.8, 7.1, 7.3, 7.4, 7.5, 7.8, 7.9_

- [ ] 7. Implement the application shell
  - [x] 7.1 Implement UI providers and the app root
    - `lib/ui/state/ui_providers.dart`: settings stream, effective locale (via `resolveLanguage` and the device locale), theme mode, display font, app version (`package_info_plus`), snackbar notifier
    - `lib/app.dart`: `QuestlogApp` with `MaterialApp`, localization delegates, theme and dark theme, `themeMode`, locale and `CupertinoPageTransitionsBuilder` so the edge-swipe back works
    - `lib/main.dart`: open the database, run `ProviderScope` with `SystemClock`, run `QuestlogApp`
    - Stream providers wrap every `watch*` of the services, so each screen stays bound to the observable queries
    - _Requirements: 1.8, 11.7, 11.8, 14.2, 14.3, 14.4, 15.2, 17.5_

  - [x] 7.2 Implement the app shell, splash and tabs
    - `lib/ui/screens/shell/`: `AppShell` with splash until the database is open and Reconciliation finished, two-tab bottom bar (Questy, Mise), lifecycle observer running Reconciliation once per resume, message for posted Missions, retry banner on storage errors, `RewardOverlay` above the tabs
    - Settings opens as a pushed screen from the gear and returns to the same tab with scroll position kept
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 1.6, 1.7, 17.3_

  - [x] 7.3 Write shell tests
    - Widget: splash then Board; exactly two tabs; Reconciliation runs once at start and once per resume; posted Missions produce a message; a failing Reconciliation shows data and a retry banner; switching tabs keeps each tab's scroll position
    - _Requirements: 1.1, 1.2, 1.5, 1.6, 1.7_

- [ ] 8. Implement the Board_Screen
  - [x] 8.1 Implement the quest list and board
    - `lib/ui/screens/board/`: `BoardScreen` with `HeroBar`, skeletons, empty state, FAB and a `QuestList` of open Quests (reorderable on long press, `Slidable` with "Upravit" and "Smazat") followed by the Quests done today
    - Check taps call `QuestService.complete` or `reopen`, push a reward event or a withdrawal message, and restore the card with an error message on failure
    - Reorder uses `moveWithinSubset`, shows the new order at once, calls `QuestService.reorder` and restores the previous order on failure
    - Done cards are neither draggable nor drop targets; a horizontal drag is a swipe, long press then move is a reorder
    - A not-found or invalid-state error from a service refreshes the list and shows the item-changed message
    - _Requirements: 3.1, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 3.12, 3.13, 4.1, 4.2, 4.3, 4.4, 4.5, 4.7, 6.1, 6.7, 6.8, 6.9, 18.2_

  - [x] 8.2 Write Board_Screen tests
    - Widget: open Quests in manual order and done Quests below; completing shows the Reward_Card and moves the card; unchecking moves it back with a withdrawal message (and the Mission-reopened note); drag-and-drop persists the new order and a cancelled drag persists nothing; a failing reorder restores the order; empty state and skeletons; clock advanced past 04:00 removes yesterday's done Quests
    - _Requirements: 3.1, 3.6, 3.7, 3.8, 3.10, 3.12, 3.13, 4.2, 4.3, 4.4, 4.5_

- [ ] 9. Implement the Quest_Sheet and quest deletion
  - [x] 9.1 Implement the Quest_Sheet
    - `lib/ui/sheets/quest_sheet.dart`: name, Difficulty selector (default Běžný), note, Mission picker with "bez mise" first, preset Mission, create and edit modes, disabled Difficulty and Mission for done Quests, inline errors from `validators.dart`, invalid-state error beside the picker, discard confirmation
    - Wire "Smazat" to `confirmDestructive` with the done-Quest wording and `QuestService.delete`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6.2, 6.3, 6.4, 6.7, 6.8_

  - [x] 9.2 Write Quest_Sheet tests
    - Widget: create mode focuses the name field; empty, 81-character name and 501-character note show inline errors and keep input and do not call the service; edit of a done Quest disables Difficulty and Mission; preset Mission; success closes the sheet and the card appears; dirty dismissal asks first; deletion confirmation text differs for done Quests
    - _Requirements: 5.1, 5.4, 5.5, 5.6, 5.7, 5.8, 6.3, 6.4_

- [ ] 10. Implement the Missions_Screen and Mission_Sheet
  - [x] 10.1 Implement the Missions_Screen
    - `lib/ui/screens/missions/missions_screen.dart`: open Mission_Cards, section "Dokončeno dnes" with earned bonus, skeletons, empty state with a create button, FAB, swipe actions with the Mission deletion confirmation, tap to open detail
    - _Requirements: 6.5, 6.6, 6.7, 6.8, 6.9, 8.1, 8.2, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 8.10_

  - [x] 10.2 Implement the Mission_Sheet
    - `lib/ui/sheets/mission_sheet.dart`: name, Mission_Bonus selector (default Střední), removable quest rows with name and Difficulty plus "Přidat quest" row, empty rows ignored, edit mode with only name and bonus and the earned-bonus note for completed Missions, discard confirmation
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9_

  - [x] 10.3 Write Missions_Screen and Mission_Sheet tests
    - Widget: open Missions listed with ring and remaining XP; the ready state caption; "Dokončeno dnes" contains only today's completed Missions and empties after 04:00; empty state button opens the sheet; sheet validation, empty quest rows ignored, row removal, edit mode hides quest rows; Mission deletion confirmation names the Quest count
    - _Requirements: 6.6, 8.1, 8.4, 8.5, 8.6, 8.7, 9.3, 9.4, 9.5, 9.6_

- [ ] 11. Checkpoint — Board and missions
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 12. Implement the Mission_Detail_Screen
  - [ ] 12.1 Implement the Mission_Detail_Screen
    - `lib/ui/screens/mission_detail/`: header with large progress and bonus, all Quests including older done ones (reorderable open Quests, same toggle behaviour as the board), `···` menu (Upravit misi, Přidat quest, Smazat misi last and destructive), "Dokončit misi" button when every Quest is done, completed state with seal, bonus and date, the reopen notice when the bonus is withdrawn, "Pravidelná mise" caption for Instances, empty state for a Mission without Quests, pop when the Mission disappears
    - Completing a Mission calls `MissionService.complete`, pushes the Mission reward and updates the screen
    - _Requirements: 4.6, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9, 10.10, 10.11_

  - [ ] 12.2 Write Mission_Detail_Screen tests
    - Widget: all Quests listed including older done ones; "Dokončit misi" appears only when all Quests are done and at least one exists; completing shows the Mission reward and the completed state; reopening a Quest of a completed Mission shows the open state and the withdrawn-bonus notice; menu items and order; deletion returns to Missions; "Přidat quest" presets the Mission; screen pops when the Mission is deleted; recurring caption
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.8, 10.9, 10.11_

- [ ] 13. Implement the Settings_Screen
  - [x] 13.1 Implement profile, language, theme and About
    - `lib/ui/screens/settings/`: group layout in the required order, hero-name field with 40-character limit saved on blur or submit with inline error, Total_XP in small type, language segmented control highlighting the Effective_Language, theme segmented control with icons, About with the app name and version
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 14.3, 14.4_

  - [x] 13.2 Write Settings_Screen tests
    - Widget: group order; hero name saved on blur and shown in the Hero_Bar; 41 characters show an error and do not save; switching language changes visible strings at once with scroll position kept and no empty flash; theme switch applies at once; version comes from the platform info stub
    - _Requirements: 11.1, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 14.3_

  - [x] 13.3 Implement recurring rules in Settings
    - `lib/ui/screens/settings/rules_section.dart` and `lib/ui/sheets/rule_sheet.dart`: rule rows with "cadence · N questů · příště date" and the "Vyvěsit teď" or "Vyvěšeno" pill, dashed add row, messages for manual posting driven by `PostResult.skippedNextPosting` and `PostResult.closedPreviousInstance`, Rule_Sheet with six Cadence chips, posting-day picker that changes with the Cadence, Mission_Bonus selector, quest template rows, help line, edit note, validation, "Uložit pravidlo", and "Smazat pravidlo" with confirmation
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9, 12.10, 12.11, 12.12_

  - [x] 13.4 Write recurring rule UI tests
    - Widget: rows show next date and quest count; the pill dims after a manual posting; manual posting shows the skipped-posting message and the closed-Mission message when applicable; Cadence chips switch the picker and keep name and templates; Monthly day limited to 1–28; validation keeps input; delete confirmation wording; saved rule appears with its next date
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.7, 12.8, 12.9, 12.10, 12.12_

  - [x] 13.5 Implement the temporary display-font picker
    - `lib/ui/screens/settings/font_section.dart` and `lib/ui/sheets/font_sheet.dart`: row "Písmo titulků" showing the current font, sheet of six rows each in its own face with sample, character note and brass tick, applying the font at once through Settings_Service
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

  - [x] 13.6 Write font picker tests
    - Widget: six rows in the right order; choosing a font stores it and changes the title style family at once; body text keeps the Figtree family
    - _Requirements: 13.2, 13.3, 13.4_

- [ ] 14. Verify cross-cutting requirements
  - [ ] 14.1 Write layout, touch-target and accessibility tests
    - Pump Board, Missions, Mission detail and Settings at widths 320 and 430 and at text scale 1.3 in Czech and English, and assert no overflow
    - Walk each screen's tappable widgets and assert a hit area of at least 44×44, a semantic label and a pressed state
    - Assert that completing and reopening a Quest and a Mission produce a semantic announcement
    - Assert that reduced motion replaces animations with fades of at most 150 ms
    - Confirm every screen and sheet has a widget test on the in-memory database (the catalogue of tasks 6–13)
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5, 16.7, 16.8, 19.3_

  - [ ] 14.2 Write token-usage and icon checks
    - Add a test that scans `lib/ui/` for literal `Color(0x…)` values, literal `Duration(milliseconds:` values and `Icons.` usages outside `lib/ui/theme/` and fails when found
    - _Requirements: 15.4, 15.8_

  - [ ]* 14.3 Add golden tests
    - Golden comparison of the Board_Screen, Missions_Screen and Settings_Screen in dark and light, with the bundled fonts, run on Linux
    - _Requirements: 19.4_

  - [ ] 14.4 Write an end-to-end UI scenario
    - On an in-memory database with a `FixedClock`: create a Mission with Quests, complete all Quests, complete the Mission and cross a Level boundary, check the Hero_Bar and the "Dokončeno dnes" section, advance the clock past 04:00 and check both lists, switch language and theme, post a rule by hand
    - _Requirements: 3.6, 7.3, 7.6, 8.5, 8.6, 10.6, 12.3, 14.3, 17.3_

- [ ] 15. Checkpoint — UI complete
  - Run `scripts/check.sh` and ensure analysis, all tests and the structure check pass; run the app once under Xvfb on Linux (`xvfb-run -a flutter run -d linux`) to confirm it starts; ask the user if questions arise.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 1, "tasks": ["1.1"] },
    { "id": 2, "tasks": ["1.2", "1.3", "3.1", "3.3", "3.5", "3.7", "3.9"] },
    { "id": 3, "tasks": ["2.1", "3.2", "3.4", "3.6", "3.8", "3.10", "4.1"] },
    { "id": 4, "tasks": ["2.2", "4.2", "6.1"] },
    { "id": 5, "tasks": ["6.2", "6.4", "6.6", "6.7"] },
    { "id": 6, "tasks": ["6.3", "6.5", "6.8", "7.1"] },
    { "id": 7, "tasks": ["7.2"] },
    { "id": 8, "tasks": ["7.3", "8.1", "10.2", "13.1"] },
    { "id": 9, "tasks": ["8.2", "9.1", "10.1", "13.2", "13.3", "13.5"] },
    { "id": 10, "tasks": ["9.2", "10.3", "12.1", "13.4", "13.6"] },
    { "id": 11, "tasks": ["12.2", "14.1", "14.2", "14.3", "14.4"] }
  ]
}
```

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP; goldens are optional because they need regenerating after every deliberate visual change.
- Spec `001-questlog-domain` must be finished first; this plan uses its services, providers, models and the `FixedClock` test helper.
- Ad-hoc commands run in zsh; every `.sh` file is bash with `set -euo pipefail`.
- Flutter commands first need `git config --global --add safe.directory /opt/flutter` (skill `sandbox-flutter`). Only Linux desktop and web run in the sandbox, so widget tests and an Xvfb launch are the available verification; haptics, edge-swipe back, safe areas and the keyboard on iOS are checked by the user on a device or simulator.
- The iOS build is done by the user. The bundle identifier is `com.jablecnik.questlog` (confirmed by the user, following TimeLog's `com.jablecnik.timelogApp`) and is set in one place (task 1.3).
- Fonts are bundled, not fetched. If the sandbox cannot download the TTF files, ask the user to place them in `assets/fonts/`.
- The font picker is temporary: once the user chooses a font, remove `font_section.dart`, `font_sheet.dart`, the `DisplayFont` setting and the five unused font families in one change.
- A history screen is deliberately not part of this spec; the data is retained and `History_Query` exists in the services, so a small later spec can add the screen.
- Where the artboards in `.design/artboards/` and these requirements differ, the requirements win; update the artboard afterwards.
- Git: the repository exists from 001 task 1.1; commit each completed task as one Conventional Commit per `code-git.md` — no tool-attribution trailers, no remote/push.
