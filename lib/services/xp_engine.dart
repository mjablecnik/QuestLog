import 'package:drift/drift.dart' show Value;

import '../core/xp_rules.dart';
import '../data/database.dart';
import '../data/models.dart';

/// Computes Levels and applies XP changes to the stored Total_XP.
///
/// [apply] joins the transaction that is active in the current zone, so a
/// service that awards XP and changes its own rows commits or rolls back both
/// together.
class XpEngine {
  XpEngine(this._db);

  final QuestlogDatabase _db;

  /// The current Total_XP.
  Future<int> readTotal() async {
    final row = await _db.select(_db.appState).getSingle();
    return row.totalXp;
  }

  /// Adds [delta] (which may be negative) to Total_XP, clamped at zero.
  Future<XpChange> apply(int delta) {
    return _db.runTransaction(() async {
      final before = await readTotal();
      final after = before + delta < 0 ? 0 : before + delta;
      if (after != before) {
        await _db.update(_db.appState).write(AppStateCompanion(totalXp: Value(after)));
      }
      return XpChange(
        totalBefore: before,
        totalAfter: after,
        levelBefore: levelFor(before),
        levelAfter: levelFor(after),
      );
    });
  }

  /// Total_XP as a stream, separate from the Level_Progress.
  Stream<int> watchTotal() {
    return _db.select(_db.appState).watchSingle().map((row) => row.totalXp).distinct();
  }

  /// Level, XP inside the Level and its threshold as a stream.
  Stream<LevelProgress> watchProgress() {
    return watchTotal().map(progressFor).distinct();
  }
}
