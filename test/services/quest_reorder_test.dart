import 'package:drift/drift.dart' show OrderingTerm;
import 'package:glados/glados.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/seed.dart';
import '../helpers/test_database.dart';

Future<List<QuestRow>> inOrder(QuestlogDatabase db) {
  return (db.select(db.quests)..orderBy([(q) => OrderingTerm.asc(q.sortOrder)])).get();
}

void main() {
  QuestDraft draft(String name, {int? missionId}) =>
      QuestDraft(name: name, difficulty: Difficulty.normal, missionId: missionId);

  // Feature: questlog-domain, Property 6: reordering a subset preserves all other positions
  Glados2(
    any.listWithLengthInRange(2, 10, any.intInRange(0, 100)),
    any.listWithLengthInRange(2, 10, any.bool),
  ).test(
    'a subset ends in the requested order and every other Quest keeps its position',
    (keys, mask) async {
      final db = createTestDatabase();
      try {
        final quests = QuestService(db, XpEngine(db), FixedClock(DateTime(2026, 11, 15, 10)));
        final count = keys.length;
        for (var i = 0; i < count; i++) {
          await quests.create(draft('Q$i'));
        }
        final before = await inOrder(db);
        final indices = [for (var i = 0; i < count; i++) if (mask[i % mask.length]) i];
        // The requested order: the subset sorted by the generated keys (stable).
        final requested = [...indices]
          ..sort((a, b) {
            final byKey = keys[a].compareTo(keys[b]);
            return byKey != 0 ? byKey : a.compareTo(b);
          });

        await quests.reorder([for (final i in requested) before[i].id]);

        final after = await inOrder(db);
        final subsetIds = {for (final i in indices) before[i].id};
        // Expected final sequence: the subset slots filled by the requested order.
        final expected = [...before.map((q) => q.id)];
        for (var slot = 0; slot < indices.length; slot++) {
          expected[indices[slot]] = before[requested[slot]].id;
        }
        expect(after.map((q) => q.id).toList(), expected);
        for (final q in before.where((q) => !subsetIds.contains(q.id))) {
          final now = after.firstWhere((a) => a.id == q.id);
          expect(now.sortOrder, q.sortOrder, reason: 'untouched Quest keeps its sort_order');
        }
        expect(after.map((q) => q.sortOrder).toSet().length, count);
      } finally {
        await db.close();
      }
    },
  );

  group('unit', () {
    late QuestlogDatabase db;
    late QuestService quests;

    setUp(() {
      db = createTestDatabase();
      quests = QuestService(db, XpEngine(db), FixedClock(DateTime(2026, 11, 15, 10)));
    });
    tearDown(() => db.close());

    test('an unknown id is rejected and nothing changes', () async {
      final a = await quests.create(draft('A'));
      final b = await quests.create(draft('B'));
      await expectLater(
        quests.reorder([b.id, 999, a.id]),
        throwsA(isA<ValidationError>()),
      );
      expect((await inOrder(db)).map((q) => q.id), [a.id, b.id]);
    });

    test('a duplicate id is rejected and nothing changes', () async {
      final a = await quests.create(draft('A'));
      final b = await quests.create(draft('B'));
      await expectLater(
        quests.reorder([b.id, a.id, b.id]),
        throwsA(isA<ValidationError>()),
      );
      expect((await inOrder(db)).map((q) => q.id), [a.id, b.id]);
    });

    test('an empty or single-id list changes nothing', () async {
      final a = await quests.create(draft('A'));
      final b = await quests.create(draft('B'));
      await quests.reorder([]);
      await quests.reorder([b.id]);
      expect((await inOrder(db)).map((q) => q.id), [a.id, b.id]);
    });

    test('new Quests are placed last, also after a reorder', () async {
      final a = await quests.create(draft('A'));
      final b = await quests.create(draft('B'));
      await quests.reorder([b.id, a.id]);
      final c = await quests.create(draft('C'));
      expect((await inOrder(db)).map((q) => q.id), [b.id, a.id, c.id]);
    });

    test('reordering Quests of a Mission keeps the same relative order everywhere', () async {
      final missionId = await seedMission(db);
      final standalone = await quests.create(draft('standalone'));
      final m1 = await quests.create(draft('m1', missionId: missionId));
      final other = await quests.create(draft('other'));
      final m2 = await quests.create(draft('m2', missionId: missionId));

      // The Mission view sends only its own Quests.
      await quests.reorder([m2.id, m1.id]);

      final all = (await inOrder(db)).map((q) => q.id).toList();
      final inMission =
          (await inOrder(db)).where((q) => q.missionId == missionId).map((q) => q.id).toList();
      expect(inMission, [m2.id, m1.id]);
      expect(all, [standalone.id, m2.id, other.id, m1.id]);
    });
  });
}
