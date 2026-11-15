# Questlog

Personal gamified to-do app: Quests (one-off tasks) and Missions (long-term goals made
of quests), XP and levels, and recurring missions posted from rules. Flutter, iOS
primary, local SQLite via Drift, no server and no account.

## Development

```bash
flutter pub get
dart run build_runner build   # Drift code generation
scripts/check.sh              # analyze + tests + structure check
```

The specs live in `.kiro/specs/`, the visual design in `.design/`.

## iOS bundle identifier and display name

Both are set in one place: `ios/Flutter/AppIdentity.xcconfig` (`APP_BUNDLE_IDENTIFIER`,
`APP_DISPLAY_NAME`). `Info.plist` and the Runner target read them, so change them there
before the iOS build. The `RunnerTests` target keeps its own literal identifier
(`com.jablecnik.questlog.RunnerTests`); it is not shipped.
