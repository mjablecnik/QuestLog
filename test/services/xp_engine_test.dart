import 'package:glados/glados.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/test_database.dart';

void main() {
  late QuestlogDatabase db;
  late XpEngine engine;

  setUp(() {
    db = createTestDatabase();
    engine = XpEngine(db);
  });
  tearDown(() => db.close());

  test('a fresh database reads Total_XP 0', () async {
    expect(await engine.readTotal(), 0);
  });

  test('a positive delta raises Total_XP and reports the Level change across 100 XP', () async {
    final change = await engine.apply(120);
    expect(
      change,
      const XpChange(totalBefore: 0, totalAfter: 120, levelBefore: 1, levelAfter: 2),
    );
    expect(await engine.readTotal(), 120);

    final within = await engine.apply(10);
    expect(within.levelBefore, 2);
    expect(within.levelAfter, 2);
  });

  test('a negative delta across a Level boundary reports the lower Level', () async {
    await engine.apply(260);
    final change = await engine.apply(-30);
    expect(change.levelBefore, 3);
    expect(change.levelAfter, 2);
    expect(change.totalAfter, 230);
    expect(await engine.readTotal(), 230);
  });

  test('a delta below zero clamps Total_XP at 0', () async {
    await engine.apply(40);
    final change = await engine.apply(-500);
    expect(change.totalAfter, 0);
    expect(change.appliedDelta, -40);
    expect(await engine.readTotal(), 0);

    final again = await engine.apply(-5);
    expect(again.totalAfter, 0);
    expect(again.appliedDelta, 0);
  });

  test('watchProgress emits a new value after apply', () async {
    final emitted = <LevelProgress>[];
    final sub = engine.watchProgress().listen(emitted.add);
    await pumpEventQueue();
    expect(emitted.last, const LevelProgress(level: 1, xpIntoLevel: 0, threshold: 100));

    await engine.apply(130);
    await pumpEventQueue();
    expect(emitted.last, const LevelProgress(level: 2, xpIntoLevel: 30, threshold: 150));
    await sub.cancel();
  });

  test('watchTotal exposes Total_XP separately from the progress', () async {
    final totals = <int>[];
    final sub = engine.watchTotal().listen(totals.add);
    await pumpEventQueue();
    await engine.apply(70);
    await pumpEventQueue();
    expect(totals, [0, 70]);
    await sub.cancel();
  });

  test('apply joins the surrounding transaction and rolls back with it', () async {
    await expectLater(
      db.transaction(() async {
        await engine.apply(80);
        throw StateError('boom');
      }),
      throwsStateError,
    );
    expect(await engine.readTotal(), 0);
  });
}
