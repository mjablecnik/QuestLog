# Questlog — Visual Design Reference

**Status: proposal, round 3 (2026-11-15).** Name *Questlog*, direction, typography and the
recurring-mission behaviour are approved; only the small points in § 5 remain before a spec
is written. Once approved, this file becomes
the visual contract the Flutter implementation is compared against.

```
.design/
├── DESIGN.md            this file — tokens and rules, in prose
├── theme.css            the tokens and shared components every artboard links
├── artboards/           13 artboards as .dc.html, plus canvas.json (frame layout)
├── screens/             the same artboards rendered to PNG at 2×
├── render.mjs           artboards → screens/*.png (Playwright)
├── build-preview.mjs    screens + notes → preview.html (the review page)
├── preview.html         generated; published as a Claude artifact for review
├── calendar-preview.html  the approved calendar screens (spec 003)
└── notes-preview.html     the approved notes screens, Trash and editor (spec 004)
```

**Regenerating:** `node .design/render.mjs` then `node .design/build-preview.mjs`, both from
the project root. The project has no `node_modules` yet, so point `NODE_PATH` at a sibling
project that has Playwright installed (e.g. `NODE_PATH=../worklog/node_modules`). Chromium
is pre-installed in the sandbox — never run `playwright install`.

---

## 1. Concept

A **guild notice board**. In the light theme Quests are parchment slips pinned to the board; in
the dark theme they are dark raised cards, because bright slips glare in the dark (changed
2026-11-18 at Martin's request). Completing one "turns it in" — the card dims and gets a brass seal. Missions are dark raised
cards with a brass progress ring; they differ from quests by *structure*, never by a second
accent hue. Brass is the only accent and always means the same thing: reward, completion,
primary action.

## 2. Tokens

### Guild Board — dark (default)

| Token | Value | Used for |
|---|---|---|
| `--board` | `#121A17` | screen background (green-biased ink, not pure black) |
| `--board-raised` | `#1A2522` | tab bar, mission cards, sheets, completed quests |
| `--board-line` | `rgba(236,230,216,0.08)` | dividers, track of progress bars |
| `--text` | `#ECE6D8` | text on the board |
| `--text-dim` / `--text-faint` | `0.62` / `0.42` alpha of `--text` | secondary text / caps labels |
| `--parchment` | `#F1E7D3` | reward card, empty-state slip (open quest card in the light theme only) |
| `--parchment-edge` | `#E3D6BB` | 1px inset highlight on parchment |
| `--ink` | `#1F2A26` | text on parchment |
| `--slip`, `--slip-edge` | dark: `--board-raised`, `--board-line`; light: `--parchment`, `--parchment-edge` | quest card fill and 1px outline |
| `--slip-text` / `--slip-text-dim` / `--slip-text-faint` | dark: `--text` / `--text-dim` / `--text-faint`; light: `--ink` / `--ink-dim` / `--ink-faint` | quest card name, meta, empty pips and the open check ring |
| `--slip-done` | dark: transparent; light: `--board-raised` | done quest card fill |
| `--ink-dim` / `--ink-faint` | `0.60` / `0.38` alpha of `--ink` | secondary text / empty pips on parchment |
| `--brass` | `#D8AE5A` | XP, seals, FAB, primary button, active tab, progress fill |
| `--brass-soft` | `rgba(216,174,90,0.18)` | selected segment / chip background, level badge fill |
| `--ink-on-brass` | `#2A1F0A` | text and icons on brass |
| `--destructive` | `#D96B5A` | delete action |
| `--scrim` | `rgba(8,12,10,0.72)` | behind sheets and the reward card |
| `--field` | `rgba(236,230,216,0.06)` | form fields |
| `--field-active` | `rgba(216,174,90,0.10)` + 1px inset `--brass` | focused field |

### Daylight — light

Same structure; only these change: `--board #F4EEE1`, `--board-raised #FBF7EE`,
`--text #1F2A26`, `--parchment #FFFDF7`, `--parchment-edge #E9DFC9`, `--brass #B4832A`
(darkened for contrast on light grounds), `--ink-on-brass #FFF8E8`, `--sheet #FBF7EE`.
Quest cards gain a 1px `--parchment-edge` outline because the shadow alone is too weak
on a light ground.

### Dark quest cards

Changed 2026-11-18 at Martin's request (his choice of three proposals, "Tmavé karty"): in every
dark palette an open Quest card is `--board-raised` with a 1px `--board-line` border and no
shadow; its name is `--text`, the +XP and filled pips are the accent, empty pips and the open
check ring are `--text-faint`. A done card is transparent with the same outline, dimmed text,
a strikethrough and an accent-filled check, so open and done still read apart. A card lifted
by drag gets a scrim shadow. The reward card and the empty-state slip stay parchment (they are
celebratory or pinned paper, and short-lived). Light palettes are unchanged. The roles are
`slip*` in `QuestlogPalette`; dark palettes derive them from `brightness`, so no palette
restates them.

### Palette (chosen 2026-11-19)

Martin chose the **Blue** palette; the other experiments (Original, Higher contrast, Green) and the
Settings switch were removed. The tables above describe the structure; the values are now:
dark board `#0F1319`, raised `#18202B`, text `#E6EAF2`, accent (`--brass`) `#78B4C4`, ink on accent
`#08131A`, sheet `#18202B`; light board `#EDF1F6`, raised `#F8FAFD`, text `#15202B`, accent
`#2B7287`, ink on accent `#F4FAFC`, parchment `#FFFFFF`. The dark values follow TimeLog's Midnight
theme (`timelog_app/lib/core/theme.dart`). Every text pair reaches 4.5:1 and the accent fill 3:1.
The app icon and launch screen (§ 6) are not re-tinted. Values live in `lib/ui/theme/tokens.dart`;
the green-and-brass values in the tables above are historical.

### Shape

Cards `14px`, fields and buttons `12px`, sheets `24px` top corners, reward card `22px`.
Checks, level badge, FAB and seals are circles. Touch targets ≥ 44px (the painted quest
check is 28px inside a 44px row).

## 3. Type

- **Display — Figtree by default** 700 (titles) / 800 (the 48px reward figure),
  `letter-spacing -0.02em`. **v1 ships a temporary switch** in Settings between the six
  candidates (Figtree, Bricolage Grotesque, Sora, Outfit, Unbounded, Cinzel) — Martin
  wants to choose by living with them; the choice is a local setting that drives only the
  display role. Once he settles, the switch and the unused font assets are removed. Page titles 32–36px, sheet titles 24px, XP figures 17px on cards and 48px on
  the reward card. Always `tabular-nums` for XP.
- **Body — Figtree** 400–600. Base 15px, card titles 16px/600, card meta 12.5px,
  caps labels 11px/600 with `0.14em` tracking.
- Both roles resolve to the same family today, **on purpose kept as two tokens**
  (`--font-display`, `--font-body`; in Flutter two named `TextStyle`s / `TextTheme` roles).
  Martin may want a different display face later — that must stay a one-place change.
  Fraunces was the original proposal and was rejected; the six alternatives compared are
  kept in `artboards/TypeOptions.dc.html` for reference (not part of the review page);
  `artboards/FontPicker.dc.html` shows the in-app switch.
- Google Fonts; in Flutter via `google_fonts` (`GoogleFonts.figtree`).

## 4. Components

- **Tap feedback** — changed 2026-11-18 at Martin's request: a touch gives no splash, highlight or
  hover tint on any control (theme-wide `NoSplash`, transparent button overlays). State is shown
  by selection (filled, brass border) or an in-place fill the control draws itself, as the Effort
  rows do. Only keyboard focus is painted.
- **Hero bar** — level badge (52px circle, brass ring, `--brass-soft` fill), name + level,
  `current / next XP`, remaining XP, 6px brass progress bar.
- **Quest card** — check circle · title + meta row (effort pips 1–4; changed 2026-11-18 at
  Martin's request: no mission chip and no "bez mise" label, because the Board lists only
  quests without a mission) · brass `+XP`. `.done` variant: `--board-raised` ground, strike-through,
  brass filled check, completion time in the meta row.
- **Effort pips** — four 7px diamonds; filled count = tier (changed 2026-11-18 at Martin's
  request, was three pips and Snadný/Běžný/Těžký). +10, +25, +50, +100 XP. No colour coding.
  Tier names (Chvilka, Hodinka, Část dne, Celý den) are never shown in a list, only in the
  quest sheet.
- **Mission card** — 56px progress ring (r 24, stroke 5, round caps; stroke hidden at
  0 %) with the number of quests still open inside (changed 2026-11-19 at Martin's
  request, was `done/total`: a low number shows a mission that is nearly finished) · title + "Zbývá: …" · brass bonus `+XP` with a caps
  caption ("za dokončení" / "získáno").
- **Notes** (spec `004-questlog-notes`, approved preview `notes-preview.html`, blue palette) — a fifth tab with no
  hero bar. Folder row: 40px tinted icon tile, name, summary, chevron, on a raised outlined card. Note row: name,
  last-edited date, two-line preview (the name line is left out). Swipe reveals three 76px actions (rename, move,
  delete); the same actions are in a "···" menu in a Folder and in the editor. The editor has no tab bar; its format
  bar sits above the keyboard with 44px buttons. Checklist checks are round, 44px hit area. The Trash is a bin icon
  with a count badge at the top level; its rows show where an item came from and the days left, red at one day.
- **Swipe actions** — left swipe reveals *Upravit* (raised ground) and *Smazat*
  (destructive), 84px each.
- **Sheets** — bottom sheet over scrim; grabber, `Zrušit` left, display title centred,
  labelled field groups, one brass primary button at the bottom ("Vyvěsit quest",
  "Zahájit misi").
- **Quest sheet effort picker** — label *Námaha* (Effort). Four stacked rows, each with the tier
  name, its time description ("do ~30 min", "do ~2 h", "2–4 h", "celý den"), `+XP` and the four
  pips; the selected row has a brass border and `--brass-soft` fill. One hint line below tells
  the user to pick by time and to go one step up for a trip, waiting or something unpleasant.
  Default is tier 2. Artboards still show the old three-segment *Obtížnost* selector.
- **Context menu** — mission detail `···` opens a 196px menu: Upravit misi · Přidat quest ·
  Smazat misi (destructive last).
- **Reward card** — parchment card over scrim: brass seal with rays, `+XP`, "QUEST SPLNĚN",
  quest name, mission progress block when applicable, `Pokračovat`. Auto-dismisses.
- **Empty state** — pinned blank slip, display heading, one sentence of guidance. On the
  Board the sentence also says that quests of a mission live under Missions.
- **Gear** — removed 2026-11-18 at Martin's request: Settings is now the third bottom tab
  (gear icon, label Nastavení/Settings) and the hero bar carries no button. The tab bar has
  three equal items and no press highlight. `.design/artboards/` and `.design/screens/` still
  show the old gear and two tabs, and the Board artboards still show mission chips and mission
  quests among the posted quests (Board and Missions split strictly, 2026-11-18); the running
  app and the README screenshots are current.
- **Settings** — a tab (no back nav), display title, labelled groups with segmented controls:
  *Jazyk* (Čeština / English), *Vzhled* (Světlý / Tmavý / Systém, with icons), then the
  *Pravidelné mise* list (`.rule` rows: repeat icon tile, name, "cadence · N questů ·
  příště date", and a brass outline pill **Vyvěsit teď**; the pill reads *Vyvěšeno* and
  dims while a manually posted instance is pending) with a dashed add row, and an
  a *Dočasné* group with the display-font picker row, and an *O aplikaci* footer with the
  version. Tapping a rule row opens the rule sheet.
- **Font picker sheet (temporary)** — list of the six faces, each row set in its own face
  ("Nástěnka · +25" + name and a two-word character note), brass tick on the current one,
  help line that only titles and numbers change.
- **Recurring mission sheet** — same sheet anatomy as New mission, plus *Opakování* chips
  (Denně · Týdně · Každé 2 týdny · Měsíčně · Čtvrtletně · Ročně), a picker row for the
  posting day ("Vyvěsit vždy · 1. den v měsíci ›" — weekday for weekly/biweekly, day of
  month for monthly, a date for quarterly/yearly, none for daily), and a help line.
  Primary button "Uložit pravidlo".
  Semantics: the rule is a template; a fresh mission instance is posted on the scheduled
  day. **Manual posting replaces the nearest automatic one** — if an instance of the rule
  was posted by hand (finished, partly finished or untouched), the next scheduled posting
  is skipped and the rule resumes at the one after. Unfinished quests never carry over; an
  unfinished instance is closed without the completion bonus when the next one is posted.

## 5. Open questions

Tracked in `preview.html` § 05: confirm the posting-day semantics per cadence; confirm
that an unfinished recurring instance is closed (not kept) when the next one is posted.

Resolved: name (Questlog); display face (Figtree, separate role); theme default follows
system; recurring missions with six cadences, exact day and manual posting; **no** due
dates, streaks or history in v1; "projects" (as in TimeLog) deliberately left out of the UI
but the data model should leave room for an optional parent of missions/quests.

## 6. App icon and launch screen

A parchment quest slip (pinned, three pips; the icon is not redrawn for the fourth tier) stamped with a scalloped brass seal and
check, on the Guild Board green. The same mark plus a Figtree 700 "Questlog" wordmark is the
launch screen, in Guild Board and Daylight variants that follow the system appearance. The
single source is `icon/generate.mjs` (colours as literals there, from § 2): it writes the iOS
`AppIcon` set (opaque RGB), `LaunchImage` and the `LaunchBackground` colour set, and
`icon/app-icon.svg`. Run `NODE_PATH=../worklog/node_modules node .design/icon/generate.mjs`
from the project root. Not included: iOS 18 dark/tinted icon variants, a Linux window icon.
