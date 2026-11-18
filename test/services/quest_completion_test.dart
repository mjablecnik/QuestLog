import 'package:drift/drift.dart' show Value;
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

/// Opens a fresh database, runs [body] against its services and closes it, so
/// that each property-test iteration starts from an empty state.
Future<void> withServices(
  Future<void> Function(QuestlogDatabase db, XpEngine xp, QuestService quests) body,
) async {
  final db = createTestDatabase();
  try {
    final xp = XpEngine(db);
    final quests = QuestService(db, xp, FixedClock(DateTime(2026, 11, 15, 10)));
    await body(db, xp, quests);
  } finally {
    await db.close();
  }
}

QuestDraft draft(Difficulty difficulty, {int? missionId, String name = 'Quest'}) =>
    QuestDraft(name: name, difficulty: difficulty, missionId: missionId);

void main() {
  group('properties', () {
    // Feature: questlog-domain, Property 2: completing then reopening a Quest restores Total_XP
    Glados3(any.intInRange(0, 5000), any.choose(Difficulty.values), any.bool).test(
      'complete followed by reopen leaves Total_XP and Quest state unchanged',
      (startXp, difficulty, inMission) async {
        await withServices((db, xp, quests) async {
          await xp.apply(startXp);
          final missionId = inMission ? await seedMission(db) : null;
          final created = await quests.create(draft(difficulty, missionId: missionId));

          await quests.complete(created.id);
          await quests.reopen(created.id);

          expect(await xp.readTotal(), startXp);
          final row = await db.select(db.quests).getSingle();
          expect(row.completedAt, isNull);
          expect(row.awardedXp, isNull);
          expect(row.difficulty, difficulty);
          expect(row.missionId, missionId);
        });
      },
    );

    // Feature: questlog-domain, Property 3: Quest completion is idempotent
    Glados3(any.intInRange(0, 5000), any.choose(Difficulty.values), any.intInRange(2, 5)).test(
      'completing repeatedly awards the Difficulty XP exactly once',
      (startXp, difficulty, times) async {
        await withServices((db, xp, quests) async {
          await xp.apply(startXp);
          final created = await quests.create(draft(difficulty));

          for (var i = 0; i < times; i++) {
            await quests.complete(created.id);
          }

          expect(await xp.readTotal(), startXp + difficulty.xp);
          expect((await db.select(db.quests).getSingle()).awardedXp, difficulty.xp);
        });
      },
    );

    // Feature: questlog-domain, Property 4: Total_XP never goes below zero
    Glados(any.listWithLengthInRange(0, 25, any.intInRange(0, 1000))).test(
      'Total_XP stays at or above zero over any sequence of operations',
      (codes) async {
        await withServices((db, xp, quests) async {
          // A done Quest whose XP was never added to Total_XP (0), so reopening
          // it has to clamp instead of going negative.
          final stale = await quests.create(draft(Difficulty.hard, name: 'stale'));
          await (db.update(db.quests)..where((q) => q.id.equals(stale.id))).write(
            QuestsCompanion(
              completedAt: Value(DateTime(2026, 11, 15, 9)),
              awardedXp: const Value(500),
            ),
          );

          for (final code in codes) {
            final ids = (await db.select(db.quests).get()).map((q) => q.id).toList();
            final pick = ids.isEmpty ? null : ids[(code ~/ 5) % ids.length];
            switch (code % 5) {
              case 0:
              case 1:
                await quests.create(draft(Difficulty.values[(code ~/ 5) % Difficulty.values.length]));
              case 2:
                if (pick != null) await quests.complete(pick);
              case 3:
                if (pick != null) await quests.reopen(pick);
              case 4:
                if (pick != null) await quests.delete(pick);
            }
            expect(await xp.readTotal(), greaterThanOrEqualTo(0));
          }
        });
      },
    );
  });

  group('unit', () {
    late QuestlogDatabase db;
    late XpEngine xp;
    late QuestService quests;

    setUp(() {
      db = createTestDatabase();
      xp = XpEngine(db);
      quests = QuestService(db, xp, FixedClock(DateTime(2026, 11, 15, 10)));
    });
    tearDown(() => db.close());

    test('completion records the Clock time and the XP of the Difficulty', () async {
      final created = await quests.create(draft(Difficulty.normal));
      final result = await quests.complete(created.id);

      expect(result.awardedXp, 25);
      expect(result.mission, isNull);
      expect(result.missionReadyToComplete, isFalse);
      final row = await db.select(db.quests).getSingle();
      expect(row.completedAt, DateTime(2026, 11, 15, 10));
      expect(row.awardedXp, 25);
      expect(await xp.readTotal(), 25);
    });

    test('a second completion awards nothing and reports an unchanged Level', () async {
      final created = await quests.create(draft(Difficulty.hard));
      await quests.complete(created.id);
      final again = await quests.complete(created.id);

      expect(again.awardedXp, 0);
      expect(again.levelBefore, again.levelAfter);
      expect(await xp.readTotal(), 50);
    });

    test('awarded XP stays at the completion-time value after a Difficulty change', () async {
      final created = await quests.create(draft(Difficulty.easy));
      await quests.complete(created.id);

      final edited = await quests.update(created.id, draft(Difficulty.hard));
      expect(edited.difficulty, Difficulty.easy, reason: 'a done Quest ignores a Difficulty change');
      expect(edited.awardedXp, 10);

      final reopened = await quests.reopen(created.id);
      expect(reopened.revokedXp, 10);
      expect(await xp.readTotal(), 0);
    });

    test('a Difficulty change while open applies to the next completion', () async {
      final created = await quests.create(draft(Difficulty.easy));
      await quests.update(created.id, draft(Difficulty.hard));
      final result = await quests.complete(created.id);
      expect(result.awardedXp, 50);
    });

    test('a whole-day Quest awards 100 XP and exactly fills Level 1', () async {
      final created = await quests.create(draft(Difficulty.fullDay));
      final result = await quests.complete(created.id);

      expect(result.awardedXp, 100);
      expect(result.levelBefore, 1);
      expect(result.levelAfter, 2);
      expect(await xp.readTotal(), 100);
      expect((await db.select(db.quests).getSingle()).awardedXp, 100);
    });

    test('a whole-day Quest from 90 XP crosses into Level 2 mid-bar', () async {
      await xp.apply(90);
      final created = await quests.create(draft(Difficulty.fullDay));
      final result = await quests.complete(created.id);

      expect(result.levelBefore, 1);
      expect(result.levelAfter, 2);
      expect(progressFor(await xp.readTotal()).xpIntoLevel, 90);
    });

    test('reopening a done whole-day Quest takes the 100 XP back and drops the Level', () async {
      final created = await quests.create(draft(Difficulty.fullDay));
      await quests.complete(created.id);
      final reopened = await quests.reopen(created.id);

      expect(reopened.revokedXp, 100);
      expect(reopened.levelAfter, 1);
      expect(await xp.readTotal(), 0);
    });

    test('tiers stored before the fourth one existed keep their XP, no migration needed', () async {
      for (final (String name, int expected) in [('easy', 10), ('normal', 25), ('hard', 50)]) {
        await db.customStatement(
          'INSERT INTO quests (name, difficulty, sort_order, created_at) '
          "VALUES ('Old $name', '$name', 1, 0)",
        );
        final id = (await (db.select(db.quests)..where((q) => q.name.equals('Old $name'))).getSingle()).id;
        expect((await quests.complete(id)).awardedXp, expected, reason: name);
      }
    });

    test('missionReadyToComplete is true only when the last Quest is completed', () async {
      final missionId = await seedMission(db);
      final a = await quests.create(draft(Difficulty.easy, missionId: missionId, name: 'A'));
      final b = await quests.create(draft(Difficulty.normal, missionId: missionId, name: 'B'));

      final first = await quests.complete(a.id);
      expect(first.missionReadyToComplete, isFalse);
      expect(first.mission, const MissionProgress(done: 1, total: 2, remainingXp: 25));

      final last = await quests.complete(b.id);
      expect(last.missionReadyToComplete, isTrue);
      expect(last.mission, const MissionProgress(done: 2, total: 2, remainingXp: 0));
    });

    test('a Quest of a non-open Mission is never ready to complete the Mission', () async {
      final missionId = await seedMission(db);
      final a = await quests.create(draft(Difficulty.easy, missionId: missionId));
      await (db.update(db.missions)).write(
        const MissionsCompanion(status: Value(MissionStatus.closed)),
      );
      final result = await quests.complete(a.id);
      expect(result.missionReadyToComplete, isFalse);
    });

    test('completion reports the Level change', () async {
      await xp.apply(90);
      final created = await quests.create(draft(Difficulty.easy));
      final result = await quests.complete(created.id);

      expect(result.levelBefore, 1);
      expect(result.levelAfter, 2);
    });

    test('reopen reports the lower Level and keeps Total_XP at zero when clamped', () async {
      final created = await quests.create(draft(Difficulty.hard));
      await quests.complete(created.id);
      await xp.apply(60);
      expect(await xp.readTotal(), 110);

      final result = await quests.reopen(created.id);
      expect(result.levelAfter, 1);
      expect(await xp.readTotal(), 60);

      final stale = await quests.create(draft(Difficulty.hard, name: 'stale'));
      await (db.update(db.quests)..where((q) => q.id.equals(stale.id))).write(
        QuestsCompanion(
          completedAt: Value(DateTime(2026, 11, 15, 9)),
          awardedXp: const Value(500),
        ),
      );
      await xp.apply(-60);
      await quests.reopen(stale.id);
      expect(await xp.readTotal(), 0);
    });

    test('reopening an open Quest changes nothing', () async {
      final created = await quests.create(draft(Difficulty.normal));
      final result = await quests.reopen(created.id);
      expect(result.revokedXp, 0);
      expect(result.missionReopened, isFalse);
      expect(await xp.readTotal(), 0);
    });

    test('reopening a Quest of a completed Mission reopens it and takes the bonus back', () async {
      final missionId = await seedMission(
        db,
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 9),
        awardedBonus: 100,
      );
      final questId = await db.into(db.quests).insert(
            QuestsCompanion.insert(
              name: 'Done',
              difficulty: Difficulty.normal,
              missionId: Value(missionId),
              sortOrder: 1,
              createdAt: DateTime(2026, 11, 15, 7),
              completedAt: Value(DateTime(2026, 11, 15, 8)),
              awardedXp: const Value(25),
            ),
          );
      await xp.apply(125);

      final result = await quests.reopen(questId);

      expect(result.missionReopened, isTrue);
      expect(result.revokedXp, 25);
      expect(result.revokedBonus, 100);
      expect(await xp.readTotal(), 0);
      final mission = await db.select(db.missions).getSingle();
      expect(mission.status, MissionStatus.open);
      expect(mission.completedAt, isNull);
      expect(mission.awardedBonus, isNull);
    });

    test('unknown ids are not found', () async {
      await expectLater(quests.complete(7), throwsA(isA<NotFoundError>()));
      await expectLater(quests.reopen(7), throwsA(isA<NotFoundError>()));
    });
  });
}
