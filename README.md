<div align="center">

# ⚔️ Questlog

### A guild notice board for your to-do list

**Quests for one-off tasks, Missions for long-term goals, XP and levels for the satisfaction of turning them in. Everything stays on your phone.**

[Quick Start](#-installation) · [Usage](#-usage) · [Documentation](./DOCS.md)

</div>

## 📖 Table of Contents

- [Description](#-description)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Usage](#-usage)
- [Deployment](#-deployment)
- [Documentation](#-documentation)
- [Author](#-author)
- [Show your support](#-show-your-support)
- [License](#-license)

## 📋 Description

Questlog is a personal gamified to-do app for one user, built with Flutter for iOS first
(the Linux desktop build is used for development and tests).

- **Quests** are one-off tasks with a difficulty (easy, normal, hard) that decides the XP
  they award; the Board lists the open ones and lets you reorder them by dragging.
- **Missions** are long-term goals made of quests, with a progress ring and a bonus XP
  reward (small, medium, large) when the last quest is done.
- **XP and levels** are shown in the hero bar; completing a quest or mission opens a reward
  card, and reopening one takes the XP back.
- **Recurring missions** are posted automatically from rules set up in Settings (daily,
  weekly, biweekly, monthly, quarterly or yearly).
- **Two looks and two languages**: the dark "Guild Board" and the light "Daylight" theme
  (or follow the system), in Czech or English.
  Two temporary Settings controls (a title-font picker and a palette switch between the
  original and a higher-contrast look) exist only until the final choices are made.
- **Local only**: data lives in a SQLite file on the device through Drift. There is no
  server, no account and no network access.

The board day rolls over at 04:00, so a late evening still belongs to the same day.

## 🔧 Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) 3.47 or newer (Dart 3.13 or
  newer; see `environment.sdk` in `pubspec.yaml`)
- For the Linux desktop build: the Flutter Linux toolchain (clang, CMake, GTK 3
  development headers); for running it on a machine without a display, `xvfb-run`
- For the iOS build: a Mac with Xcode

## 🚀 Installation

```bash
git clone <repository-url> questlog
cd questlog
flutter pub get
timeout 500 dart run build_runner build   # generates the Drift database code
```

Questlog has no environment variables. `.env.example` exists only to say so; there is
nothing to copy.

> [!NOTE]
> The Drift code generation takes about a minute. The generated `lib/data/database.g.dart`
> and the localization files in `lib/l10n/` are committed, so a fresh clone builds and
> runs without it; run it again only after changing `lib/data/tables.dart`.

## 🎮 Usage

```bash
flutter run -d linux                # run the desktop app
scripts/check.sh                    # flutter analyze + all tests (about 4 min) + directory-size check
```

On a machine without a display, run the app as `xvfb-run -a flutter run -d linux`; the
tests need no display.

The app has two tabs, Quests (the Board) and Missions; new items are created with the
plus button on each, and Settings opens from the gear in the hero bar.

The bundle identifier and the display name for iOS are set in one place,
`ios/Flutter/AppIdentity.xcconfig` (`APP_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME`);
`Info.plist` and the Runner target read them, so change them there before the iOS build. The `RunnerTests` target keeps its own literal identifier
(`com.jablecnik.questlog.RunnerTests`); it is not shipped.

## 📦 Deployment

There is no server and no hosted deployment. Questlog is installed on an iPhone from
Xcode, built on a Mac from this repository. That build has not been run from this
repository's Linux development environment, so it is the one part of the project that is
not exercised by the checks above; the open items are listed in `.agents/ISSUES.md`.

## 📚 Documentation

For more details see [DOCS.md](./DOCS.md)

## 👤 Author

👤 **Martin Jablečník**

- Website: [www.jablecnik.com](https://www.jablecnik.com)
- Github: [@mjablecnik](https://github.com/mjablecnik)

## ⭐️ Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2026 Martin Jablečník.
No licence has been chosen yet; all rights reserved.
