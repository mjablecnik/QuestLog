import 'package:glados/glados.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/mission_service.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/seed.dart';
import '../helpers/test_database.dart';

/// Opens a fresh database with all three services and closes it afterwards, so
/// that each property-test iteration starts from an empty state.
Future<void> withServices(
  Future<void> Function(
    QuestlogDatabase db,
    XpEngine xp,
    QuestService quests,
    MissionService missions,
  ) body,
) async {
  final db = createTestDatabase();
  try {
    final xp = XpEngine(db);
    final clock = FixedClock(DateTime(2026, 11, 15, 10));
    await body(db, xp, QuestService(db, xp, clock), MissionService(db, xp, clock));
  } finally {
    await db.close();
  }
}

QuestDraft quest(Difficulty difficulty, {String name = 'Quest'}) =>
    QuestDraft(name: name, difficulty: difficulty);

void main() {
  group('properties', () {
    // Feature: questlog-domain, Property 12: Mission completion requires every quest done
    Glados3(
      any.choose(MissionStatus.values),
      any.listWithLengthInRange(0, 4, any.bool),
      any.choose(MissionBonus.values),
    ).test(
      'complete succeeds if and only if the Mission is open, non-empty and fully done',
      (status, doneFlags, bonus) async {
        await withServices((db, xp, quests, missions) async {
          final missionId = await seedMission(db, status: status, bonus: bonus);
          for (var i = 0; i < doneFlags.length; i++) {
            await seedQuest(
              db,
              name: 'q$i',
              sortOrder: i + 1,
              missionId: missionId,
              completedAt: doneFlags[i] ? DateTime(2026, 11, 15, 9) : null,
            );
          }
          final expectedSuccess =
              status == MissionStatus.open && doneFlags.isNotEmpty && doneFlags.every((d) => d);
          final totalBefore = await xp.readTotal();

          if (expectedSuccess) {
            final result = await missions.complete(missionId);
            expect(result.awardedBonus, bonus.xp);
            expect(await xp.readTotal(), totalBefore + bonus.xp);
            final row = await db.select(db.missions).getSingle();
            expect(row.status, MissionStatus.completed);
            expect(row.awardedBonus, bonus.xp);
            expect(row.completedAt, DateTime(2026, 11, 15, 10));
          } else {
            await expectLater(missions.complete(missionId), throwsA(isA<InvalidStateError>()));
            expect(await xp.readTotal(), totalBefore);
            final row = await db.select(db.missions).getSingle();
            expect(row.status, status);
            expect(row.awardedBonus, isNull);
          }
        });
      },
    );

    // Feature: questlog-domain, Property 5: Total_XP matches the award ledger
    Glados(any.listWithLengthInRange(0, 30, any.intInRange(0, 10000))).test(
      'Total_XP equals awards minus revocations over any operation sequence',
      (codes) async {
        await withServices((db, xp, quests, missions) async {
          var ledger = 0;
          final recordedBonus = <int, int>{};

          for (final code in codes) {
            final pick = code ~/ 7;
            final questRows = await db.select(db.quests).get();
            final missionRows = await db.select(db.missions).get();
            final aQuest = questRows.isEmpty ? null : questRows[pick % questRows.length];
            final aMission = missionRows.isEmpty ? null : missionRows[pick % missionRows.length];
            final difficulty = Difficulty.values[pick % Difficulty.values.length];

            switch (code % 7) {
              case 0:
                await quests.create(quest(difficulty));
              case 1:
                await missions.create(
                  MissionDraft(
                    name: 'M',
                    bonus: MissionBonus.values[pick % 3],
                    quests: [quest(difficulty), quest(Difficulty.values[(pick + 1) % Difficulty.values.length])],
                  ),
                );
              case 2:
                if (aQuest != null) ledger += (await quests.complete(aQuest.id)).awardedXp;
              case 3:
                if (aQuest != null) {
                  final result = await quests.reopen(aQuest.id);
                  ledger -= result.revokedXp;
                  if (result.missionReopened) {
                    ledger -= recordedBonus.remove(aQuest.missionId)!;
                  }
                }
              case 4:
                if (aMission != null) {
                  try {
                    final result = await missions.complete(aMission.id);
                    ledger += result.awardedBonus;
                    recordedBonus[aMission.id] = result.awardedBonus;
                  } on InvalidStateError {
                    // Not completable right now; nothing is awarded.
                  }
                }
              case 5:
                if (aQuest != null) await quests.delete(aQuest.id);
              case 6:
                if (aMission != null) {
                  await missions.delete(aMission.id);
                  recordedBonus.remove(aMission.id);
                }
            }

            expect(await xp.readTotal(), ledger);
          }
        });
      },
    );
  });

  group('unit', () {
    late QuestlogDatabase db;
    late XpEngine xp;
    late QuestService quests;
    late MissionService missions;

    setUp(() {
      db = createTestDatabase();
      xp = XpEngine(db);
      final clock = FixedClock(DateTime(2026, 11, 15, 10));
      quests = QuestService(db, xp, clock);
      missions = MissionService(db, xp, clock);
    });
    tearDown(() => db.close());

    test('completing the last Quest does not complete the Mission', () async {
      final mission = await missions.create(
        MissionDraft(
          name: 'M',
          bonus: MissionBonus.medium,
          quests: [quest(Difficulty.easy)],
        ),
      );
      final questId = (await db.select(db.quests).getSingle()).id;

      final result = await quests.complete(questId);

      expect(result.missionReadyToComplete, isTrue);
      final row = await db.select(db.missions).getSingle();
      expect(row.id, mission.id);
      expect(row.status, MissionStatus.open);
      expect(await xp.readTotal(), 10, reason: 'no bonus yet');
    });

    test('completion awards the bonus and reports the Level change', () async {
      await xp.apply(60);
      final mission = await missions.create(
        MissionDraft(
          name: 'M',
          bonus: MissionBonus.medium,
          quests: [quest(Difficulty.easy)],
        ),
      );
      await quests.complete((await db.select(db.quests).getSingle()).id);

      final result = await missions.complete(mission.id);

      expect(result.awardedBonus, 100);
      expect(result.levelBefore, 1);
      expect(result.levelAfter, 2);
      expect(await xp.readTotal(), 170);
    });

    test('completing twice is rejected and awards the bonus once', () async {
      final mission = await missions.create(
        MissionDraft(name: 'M', bonus: MissionBonus.small, quests: [quest(Difficulty.easy)]),
      );
      await quests.complete((await db.select(db.quests).getSingle()).id);
      await missions.complete(mission.id);

      await expectLater(missions.complete(mission.id), throwsA(isA<InvalidStateError>()));
      expect(await xp.readTotal(), 10 + 50);
    });

    test('an unknown Mission is not found', () async {
      await expectLater(missions.complete(404), throwsA(isA<NotFoundError>()));
    });

    test('reopening a Quest of a completed Mission removes exactly the recorded bonus', () async {
      final mission = await missions.create(
        MissionDraft(
          name: 'M',
          bonus: MissionBonus.large,
          quests: [quest(Difficulty.normal), quest(Difficulty.hard)],
        ),
      );
      final ids = (await db.select(db.quests).get()).map((q) => q.id).toList();
      for (final id in ids) {
        await quests.complete(id);
      }
      await missions.complete(mission.id);
      expect(await xp.readTotal(), 25 + 50 + 200);

      // The bonus category changes after completion; the recorded 200 stays authoritative.
      await missions.update(mission.id, 'M', MissionBonus.small);
      final result = await quests.reopen(ids.first);

      expect(result.missionReopened, isTrue);
      expect(await xp.readTotal(), 50, reason: '25 + 50 + 200 - 25 - 200');
      final row = await db.select(db.missions).getSingle();
      expect(row.status, MissionStatus.open);
      expect(row.completedAt, isNull);
      expect(row.awardedBonus, isNull);

      // It can be completed again and awards the current bonus category.
      await quests.complete(ids.first);
      final again = await missions.complete(mission.id);
      expect(again.awardedBonus, 50);
    });
  });
}
