# Implementation Plan: Deep Links

## Tasks

- [x] 1. Links
  - [x] 1.1 Parser, provider and Shell wiring
    - Add `deep_link.dart`, listen in `app_shell.dart`, override in `main.dart`
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 1.2 iOS registration
    - `CFBundleURLTypes` and `FlutterDeepLinkingEnabled` in `Info.plist`, dependency `app_links`
    - _Requirements: 1.5_

  - [x] 1.3 Tests
    - Parser and Shell tests in `test/ui/screens/shell/app_shell_test.dart`
    - _Requirements: 1.1, 1.4_

- [x] 2. Checkpoint — Ensure all tests pass, ask the user if questions arise.
  - `scripts/check.sh` is green
