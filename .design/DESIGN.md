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
└── preview.html         generated; published as a Claude artifact for review
```

**Regenerating:** `node .design/render.mjs` then `node .design/build-preview.mjs`, both from
the project root. The project has no `node_modules` yet, so point `NODE_PATH` at a sibling
project that has Playwright installed (e.g. `NODE_PATH=../worklog/node_modules`). Chromium
is pre-installed in the sandbox — never run `playwright install`.

---

## 1. Concept

A **guild notice board**. Quests are light parchment slips pinned to a dark board;
completing one "turns it in" — the slip dims and gets a brass seal. Missions are dark raised
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
| `--parchment` | `#F1E7D3` | open quest card, reward card |
| `--parchment-edge` | `#E3D6BB` | 1px inset highlight on parchment |
| `--ink` | `#1F2A26` | text on parchment |
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

- **Hero bar** — level badge (52px circle, brass ring, `--brass-soft` fill), name + level,
  `current / next XP`, remaining XP, 6px brass progress bar.
- **Quest card** — check circle · title + meta row (mission chip, difficulty pips 1–3,
  or "bez mise") · brass `+XP`. `.done` variant: `--board-raised` ground, strike-through,
  brass filled check, completion time in the meta row.
- **Difficulty pips** — three 7px diamonds; filled count = tier. Snadný +10, Běžný +25,
  Těžký +50 XP. No colour coding of difficulty.
- **Mission card** — 56px progress ring (r 24, stroke 5, round caps; stroke hidden at
  0 %) with `done/total` inside · title + "Zbývá: …" · brass bonus `+XP` with a caps
  caption ("za dokončení" / "získáno").
- **Swipe actions** — left swipe reveals *Upravit* (raised ground) and *Smazat*
  (destructive), 84px each.
- **Sheets** — bottom sheet over scrim; grabber, `Zrušit` left, display title centred,
  labelled field groups, one brass primary button at the bottom ("Vyvěsit quest",
  "Zahájit misi").
- **Context menu** — mission detail `···` opens a 196px menu: Upravit misi · Přidat quest ·
  Smazat misi (destructive last).
- **Reward card** — parchment card over scrim: brass seal with rays, `+XP`, "QUEST SPLNĚN",
  quest name, mission progress block when applicable, `Pokračovat`. Auto-dismisses.
- **Empty state** — pinned blank slip, display heading, one sentence of guidance.
- **Gear** — removed 2026-11-18 at Martin's request: Settings is now the third bottom tab
  (gear icon, label Nastavení/Settings) and the hero bar carries no button. The tab bar has
  three equal items and no press highlight. `.design/artboards/` and `.design/screens/` still
  show the old gear and two tabs; the running app and the README screenshots are current.
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

A parchment quest slip (pinned, three difficulty pips) stamped with a scalloped brass seal and
check, on the Guild Board green. The same mark plus a Figtree 700 "Questlog" wordmark is the
launch screen, in Guild Board and Daylight variants that follow the system appearance. The
single source is `icon/generate.mjs` (colours as literals there, from § 2): it writes the iOS
`AppIcon` set (opaque RGB), `LaunchImage` and the `LaunchBackground` colour set, and
`icon/app-icon.svg`. Run `NODE_PATH=../worklog/node_modules node .design/icon/generate.mjs`
from the project root. Not included: iOS 18 dark/tinted icon variants, a Linux window icon.
