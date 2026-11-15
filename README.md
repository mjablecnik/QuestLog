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
