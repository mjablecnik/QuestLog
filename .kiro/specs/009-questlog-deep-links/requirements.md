# Requirements Document

## Introduction

This spec lets a link of the form `questlog://calendar` open Questlog (Flutter, iOS primary, `/workspace/QuestLog/`) on one of its tabs. With the iOS Shortcuts app the user makes a Home Screen icon with its own name and picture that opens the app on the Calendar tab, and can put that icon in a folder. There is no network access and no schema change.

## Glossary

Terms defined in `002-questlog-ui` (Questlog_App, Shell, Tab_Bar) keep their meaning here. Additional terms:

- **Deep_Link**: A URL with the scheme `questlog` whose host names a tab: `quests`, `missions`, `calendar`, `notes` or `settings`.

## Requirements

### Requirement 1: Opening a Tab from a Link

**User Story:** As a user, I want an icon that opens Questlog on the calendar, so that I reach it in one tap.

#### Acceptance Criteria

1. WHEN the Questlog_App receives a Deep_Link, THE Shell SHALL show the tab it names
2. WHILE a screen is open above the Shell, WHEN a Deep_Link arrives, THE Questlog_App SHALL close it and show the tab
3. WHEN the Questlog_App is started by a Deep_Link, THE Shell SHALL show the tab it names once the Shell is ready
4. IF a URL is not a Deep_Link or names no tab, THEN THE Questlog_App SHALL ignore it
5. THE Questlog_App SHALL register the scheme `questlog` with iOS
