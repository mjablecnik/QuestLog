import 'package:drift/native.dart';
import 'package:questlog/data/database.dart';

/// A fresh [QuestlogDatabase] over an in-memory SQLite database.
///
/// Close it with `await db.close()` in `tearDown`.
QuestlogDatabase createTestDatabase() {
  return QuestlogDatabase.forTesting(NativeDatabase.memory());
}
