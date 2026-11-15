import 'package:glados/glados.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/mission_service.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/seed.dart';
import '../helpers/test_database.dart';

DateTime at(int minutes) => DateTime(2026, 11, 1, 0, minutes);

void main() {
  // Feature: questlog-domain, Property 13: History contains exactly the finished items in range
  group('Property 13', () {
    Glados3(
      any.listWithLengthInRange(0, 12, any.intInRange(0, 14 * 24 * 60)),
      any.listWithLengthInRange(0, 12, any.intInRange(0, 3)),
      any.intInRange(0, 14 * 10 + 5),
    ).test(
      'Quest history returns exactly the done Quests in range, newest first',
      (minutes, fates, rangeCode) async {
        final db = createTestDatabase();
        try {
          final xp = XpEngine(db);
          final quests = QuestService(db, xp, FixedClock(DateTime(2026, 11, 20, 10)));
          final expectedIds = <int>[];
          final completions = <int, DateTime>{};
          final firstDay = rangeCode % 15;
          final lastDay = firstDay + rangeCode ~/ 15 % 6;
          final start = DateTime(2026, 11, 1 + firstDay, 4);
          final end = DateTime(2026, 11, 1 + lastDay + 1, 4);

          for (var i = 0; i < minutes.length; i++) {
            final completedAt = at(minutes[i]);
            final id = await seedQuest(db, name: 'q$i', sortOrder: i + 1, completedAt: completedAt);
            // 0 = stays done, 1 = reopened afterwards, 2 = deleted afterwards.
            final fate = fates.isEmpty ? 0 : fates[i % fates.length];
            if (fate == 1) await quests.reopen(id);
            if (fate == 2) await quests.delete(id);
            if (fate == 0) {
              completions[id] = completedAt;
              if (!completedAt.isBefore(start) && completedAt.isBefore(end)) expectedIds.add(id);
            }
          }
          expectedIds.sort((a, b) {
            final byTime = completions[b]!.compareTo(completions[a]!);
            return byTime != 0 ? byTime : b.compareTo(a);
          });

          final history = await quests.history(
            DateTime(2026, 11, 1 + firstDay),
            DateTime(2026, 11, 1 + lastDay),
          );

          expect(history.map((h) => h.id).toList(), expectedIds);
        } finally {
          await db.close();
        }
      },
    );

    Glados3(
      any.listWithLengthInRange(0, 10, any.intInRange(0, 14 * 24 * 60)),
      any.listWithLengthInRange(0, 10, any.intInRange(0, 3)),
      any.intInRange(0, 14 * 10 + 5),
    ).test(
      'Mission history returns exactly the completed Missions in range, newest first',
      (minutes, fates, rangeCode) async {
        final db = createTestDatabase();
        try {
          final xp = XpEngine(db);
          final clock = FixedClock(DateTime(2026, 11, 20, 10));
          final quests = QuestService(db, xp, clock);
          final missions = MissionService(db, xp, clock);
          final completions = <int, DateTime>{};
          final firstDay = rangeCode % 15;
          final lastDay = firstDay + rangeCode ~/ 15 % 6;
          final start = DateTime(2026, 11, 1 + firstDay, 4);
          final end = DateTime(2026, 11, 1 + lastDay + 1, 4);

          for (var i = 0; i < minutes.length; i++) {
            final completedAt = at(minutes[i]);
            final id = await seedMission(
              db,
              name: 'm$i',
              status: MissionStatus.completed,
              completedAt: completedAt,
              awardedBonus: 50,
            );
            final questId = await seedQuest(
              db,
              missionId: id,
              sortOrder: i + 1,
              completedAt: completedAt,
            );
            final fate = fates.isEmpty ? 0 : fates[i % fates.length];
            if (fate == 1) await quests.reopen(questId); // reopens the Mission too
            if (fate == 2) await missions.delete(id);
            if (fate == 0) completions[id] = completedAt;
          }
          final expectedIds = [
            for (final entry in completions.entries)
              if (!entry.value.isBefore(start) && entry.value.isBefore(end)) entry.key,
          ]..sort((a, b) {
              final byTime = completions[b]!.compareTo(completions[a]!);
              return byTime != 0 ? byTime : b.compareTo(a);
            });

          final history = await missions.history(
            DateTime(2026, 11, 1 + firstDay),
            DateTime(2026, 11, 1 + lastDay),
          );

          expect(history.map((h) => h.id).toList(), expectedIds);
          expect(history.every((h) => h.awardedBonus == 50), isTrue);
        } finally {
          await db.close();
        }
      },
    );
  });

  group('unit', () {
    late QuestlogDatabase db;
    late XpEngine xp;
    late MissionService missions;

    setUp(() {
      db = createTestDatabase();
      xp = XpEngine(db);
      missions = MissionService(db, xp, FixedClock(DateTime(2026, 11, 15, 10)));
    });
    tearDown(() => db.close());

    test('watchOpen reports done and total counts and the remaining Quest XP', () async {
      final id = await seedMission(db, name: 'Open one');
      await seedQuest(db, missionId: id, sortOrder: 1, completedAt: DateTime(2026, 11, 15, 9));
      await seedQuest(db, missionId: id, sortOrder: 2, difficulty: Difficulty.easy);
      await seedQuest(db, missionId: id, sortOrder: 3, difficulty: Difficulty.hard);
      final empty = await seedMission(db, name: 'Empty');

      final summaries = await missions.watchOpen().first;

      expect(summaries.map((s) => s.id), [id, empty]);
      final first = summaries.first;
      expect(first.name, 'Open one');
      expect([first.done, first.total, first.remainingXp], [1, 3, 60]);
      final second = summaries.last;
      expect([second.done, second.total, second.remainingXp], [0, 0, 0]);
      expect(second.ruleId, isNull);
    });

    test('watchOpen excludes completed and closed Missions', () async {
      final open = await seedMission(db, name: 'open');
      await seedMission(db, name: 'done', status: MissionStatus.completed);
      await seedMission(db, name: 'closed', status: MissionStatus.closed);

      expect((await missions.watchOpen().first).map((s) => s.id), [open]);
    });

    test('watchOpen exposes the rule id of a recurring Instance', () async {
      final ruleId = await db.into(db.recurringRules).insert(
            RecurringRulesCompanion.insert(
              name: 'Rule',
              cadence: Cadence.monthly,
              anchorDate: DateTime(2026, 11, 1),
              bonus: MissionBonus.small,
              createdAt: DateTime(2026, 11, 1),
            ),
          );
      await seedMission(db, ruleId: ruleId);

      expect((await missions.watchOpen().first).single.ruleId, ruleId);
    });

    test('watchOpen emits again when a Quest is added', () async {
      final id = await seedMission(db);
      final totals = <int>[];
      final sub = missions.watchOpen().listen((s) => totals.add(s.single.total));
      await pumpEventQueue();
      await missions.addQuest(id, const QuestDraft(name: 'x', difficulty: Difficulty.easy));
      await pumpEventQueue();
      await sub.cancel();

      expect(totals, [0, 1]);
    });

    test('watchDetail returns all Quests including those completed on earlier days', () async {
      final id = await seedMission(db, name: 'Detail');
      await seedQuest(
        db,
        name: 'old done',
        missionId: id,
        sortOrder: 2,
        completedAt: DateTime(2026, 10, 1, 9),
      );
      await seedQuest(db, name: 'open', missionId: id, sortOrder: 1);

      final detail = await missions.watchDetail(id).first;

      expect(detail!.mission.name, 'Detail');
      expect(detail.quests.map((q) => q.name), ['open', 'old done']);
    });

    test('watchDetail returns a Mission without Quests, and null when missing or closed', () async {
      final empty = await seedMission(db);
      final closed = await seedMission(db, status: MissionStatus.closed);
      await seedQuest(db, missionId: closed, completedAt: DateTime(2026, 11, 15, 9));

      expect((await missions.watchDetail(empty).first)!.quests, isEmpty);
      expect(await missions.watchDetail(closed).first, isNull);
      expect(await missions.watchDetail(999).first, isNull);
    });

    test('a completed Mission is visible until 04:00 the next day, then absent', () async {
      final id = await seedMission(
        db,
        name: 'Finished',
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 21),
        awardedBonus: 100,
      );

      final sameDay = await missions.watchCompletedToday(DateTime(2026, 11, 15)).first;
      expect(sameDay.map((s) => s.id), [id]);
      expect(sameDay.single.awardedBonus, 100);
      expect(sameDay.single.completedAt, DateTime(2026, 11, 15, 21));

      // 03:59 the next calendar day is still Board_Day the 15th; 04:00 starts the 16th.
      expect(await missions.watchCompletedToday(DateTime(2026, 11, 16)).first, isEmpty);
      expect(await missions.watchCompletedToday(DateTime(2026, 11, 14)).first, isEmpty);
    });

    test('a Mission completed at 03:30 belongs to the previous Board_Day', () async {
      await seedMission(
        db,
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 3, 30),
        awardedBonus: 50,
      );
      expect(await missions.watchCompletedToday(DateTime(2026, 11, 15)).first, isEmpty);
      expect(await missions.watchCompletedToday(DateTime(2026, 11, 14)).first, hasLength(1));
    });

    test('completed Missions are listed newest first with their Quest counts', () async {
      final older = await seedMission(
        db,
        name: 'older',
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 8),
        awardedBonus: 50,
      );
      final newer = await seedMission(
        db,
        name: 'newer',
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 9),
        awardedBonus: 50,
      );
      await seedQuest(db, missionId: newer, completedAt: DateTime(2026, 11, 15, 8));
      await seedQuest(db, missionId: newer, sortOrder: 2, completedAt: DateTime(2026, 11, 15, 8));

      final list = await missions.watchCompletedToday(DateTime(2026, 11, 15)).first;

      expect(list.map((s) => s.id), [newer, older]);
      expect([list.first.done, list.first.total], [2, 2]);
    });

    test('a closed Mission appears in no stream and not in the Mission history', () async {
      final closed = await seedMission(
        db,
        status: MissionStatus.closed,
        completedAt: DateTime(2026, 11, 15, 9),
        awardedBonus: 50,
      );
      await seedQuest(db, missionId: closed, completedAt: DateTime(2026, 11, 15, 9));

      expect(await missions.watchOpen().first, isEmpty);
      expect(await missions.watchCompletedToday(DateTime(2026, 11, 15)).first, isEmpty);
      expect(await missions.watchDetail(closed).first, isNull);
      expect(await missions.history(DateTime(2026, 11, 1), DateTime(2026, 11, 30)), isEmpty);
    });

    test('history has no write side effects', () async {
      await seedMission(
        db,
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 9),
        awardedBonus: 50,
      );
      await xp.apply(50);
      final before = await db.select(db.missions).get();

      await missions.history(DateTime(2026, 11, 1), DateTime(2026, 11, 30));

      expect(await db.select(db.missions).get(), before);
      expect(await xp.readTotal(), 50);
    });
  });
}
