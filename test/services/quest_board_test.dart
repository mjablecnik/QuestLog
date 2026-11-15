import 'package:glados/glados.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/seed.dart';
import '../helpers/test_database.dart';

void main() {
  late QuestlogDatabase db;
  late XpEngine xp;
  late QuestService quests;

  setUp(() {
    db = createTestDatabase();
    xp = XpEngine(db);
    quests = QuestService(db, xp, FixedClock(DateTime(2026, 11, 15, 10)));
  });
  tearDown(() => db.close());

  List<String> names(List<BoardQuest> board) => board.map((b) => b.quest.name).toList();

  group('watchOpenBoard', () {
    test('returns open Quests of standalone and open Missions in sort order', () async {
      final open = await seedMission(db, name: 'Open mission');
      final completed = await seedMission(db, status: MissionStatus.completed);
      final closed = await seedMission(db, status: MissionStatus.closed);
      await seedQuest(db, name: 'third', sortOrder: 3);
      await seedQuest(db, name: 'first', sortOrder: 1, missionId: open);
      await seedQuest(db, name: 'in closed', sortOrder: 2, missionId: closed);
      await seedQuest(db, name: 'in completed', sortOrder: 4, missionId: completed);
      await seedQuest(db, name: 'done', sortOrder: 5, completedAt: DateTime(2026, 11, 15, 9));

      final board = await quests.watchOpenBoard().first;

      expect(names(board), ['first', 'third']);
    });

    test('missionName is set for Mission Quests and null for standalone Quests', () async {
      final missionId = await seedMission(db, name: 'Spring cleaning');
      await seedQuest(db, name: 'in mission', sortOrder: 1, missionId: missionId);
      await seedQuest(db, name: 'alone', sortOrder: 2);

      final board = await quests.watchOpenBoard().first;

      expect(board.map((b) => b.missionName), ['Spring cleaning', null]);
    });

    test('emits again when a Quest is created or completed', () async {
      final emitted = <List<String>>[];
      final sub = quests.watchOpenBoard().listen((b) => emitted.add(names(b)));
      await pumpEventQueue();
      final created = await quests.create(
        const QuestDraft(name: 'Stream me', difficulty: Difficulty.easy),
      );
      await pumpEventQueue();
      await quests.complete(created.id);
      await pumpEventQueue();
      await sub.cancel();

      expect(emitted, [<String>[], ['Stream me'], <String>[]]);
    });
  });

  group('watchDoneToday', () {
    test('keeps a Quest done before 04:00 in the previous Board_Day', () async {
      // Done at 03:30 on the 15th: belongs to the Board_Day of the 14th.
      await seedQuest(db, name: 'night', completedAt: DateTime(2026, 11, 15, 3, 30));
      await seedQuest(db, name: 'morning', sortOrder: 2, completedAt: DateTime(2026, 11, 15, 4));

      final onThe14th = await quests.watchDoneToday(DateTime(2026, 11, 14)).first;
      final onThe15th = await quests.watchDoneToday(DateTime(2026, 11, 15)).first;
      final onThe16th = await quests.watchDoneToday(DateTime(2026, 11, 16)).first;

      expect(names(onThe14th), ['night']);
      expect(names(onThe15th), ['morning']);
      expect(onThe16th, isEmpty);
    });

    test('the window ends at the next 04:00', () async {
      await seedQuest(db, name: 'last minute', completedAt: DateTime(2026, 11, 16, 3, 59));
      await seedQuest(db, name: 'next day', sortOrder: 2, completedAt: DateTime(2026, 11, 16, 4));

      expect(names(await quests.watchDoneToday(DateTime(2026, 11, 15)).first), ['last minute']);
    });

    test('lists the newest completion first and carries the Mission name', () async {
      final missionId = await seedMission(db, name: 'Mission');
      await seedQuest(db, name: 'older', completedAt: DateTime(2026, 11, 15, 8));
      await seedQuest(
        db,
        name: 'newer',
        sortOrder: 2,
        missionId: missionId,
        completedAt: DateTime(2026, 11, 15, 9),
      );

      final board = await quests.watchDoneToday(DateTime(2026, 11, 15)).first;

      expect(names(board), ['newer', 'older']);
      expect(board.map((b) => b.missionName), ['Mission', null]);
    });

    test('excludes done Quests of closed Missions but keeps them in history', () async {
      final closed = await seedMission(db, status: MissionStatus.closed);
      await seedQuest(
        db,
        name: 'closed one',
        missionId: closed,
        completedAt: DateTime(2026, 11, 15, 9),
      );

      expect(await quests.watchDoneToday(DateTime(2026, 11, 15)).first, isEmpty);
      final history = await quests.history(DateTime(2026, 11, 15), DateTime(2026, 11, 15));
      expect(history.map((h) => h.name), ['closed one']);
    });

    test('a Quest reopened after completion leaves the done list', () async {
      final created = await quests.create(
        const QuestDraft(name: 'Oops', difficulty: Difficulty.easy),
      );
      await quests.complete(created.id);
      final emitted = <int>[];
      final sub = quests
          .watchDoneToday(DateTime(2026, 11, 15))
          .listen((b) => emitted.add(b.length));
      await pumpEventQueue();
      await quests.reopen(created.id);
      await pumpEventQueue();
      await sub.cancel();

      expect(emitted, [1, 0]);
    });
  });

  group('history', () {
    test('filters by Board_Day range, newest first', () async {
      await seedQuest(db, name: 'too early', completedAt: DateTime(2026, 11, 10, 12));
      await seedQuest(db, name: 'a', sortOrder: 2, completedAt: DateTime(2026, 11, 11, 4));
      await seedQuest(db, name: 'b', sortOrder: 3, completedAt: DateTime(2026, 11, 12, 20));
      await seedQuest(db, name: 'c', sortOrder: 4, completedAt: DateTime(2026, 11, 13, 3, 59));
      await seedQuest(db, name: 'too late', sortOrder: 5, completedAt: DateTime(2026, 11, 13, 4));
      await seedQuest(db, name: 'open', sortOrder: 6);

      final history = await quests.history(DateTime(2026, 11, 11), DateTime(2026, 11, 12));

      expect(history.map((h) => h.name), ['c', 'b', 'a']);
    });

    test('carries Difficulty, awarded XP, completion time and Mission name', () async {
      final missionId = await seedMission(db, name: 'Mission');
      await seedQuest(
        db,
        name: 'hard one',
        difficulty: Difficulty.hard,
        awardedXp: 42,
        missionId: missionId,
        completedAt: DateTime(2026, 11, 15, 9),
      );
      await seedQuest(db, name: 'alone', sortOrder: 2, completedAt: DateTime(2026, 11, 15, 8));

      final history = await quests.history(DateTime(2026, 11, 15), DateTime(2026, 11, 15));

      expect(history.first.name, 'hard one');
      expect(history.first.difficulty, Difficulty.hard);
      expect(history.first.awardedXp, 42);
      expect(history.first.completedAt, DateTime(2026, 11, 15, 9));
      expect(history.first.missionName, 'Mission');
      expect(history.last.missionName, isNull);
    });

    test('a reopened Quest is absent', () async {
      final created = await quests.create(
        const QuestDraft(name: 'Undo', difficulty: Difficulty.easy),
      );
      await quests.complete(created.id);
      expect(await quests.history(DateTime(2026, 11, 15), DateTime(2026, 11, 15)), hasLength(1));

      await quests.reopen(created.id);

      expect(await quests.history(DateTime(2026, 11, 15), DateTime(2026, 11, 15)), isEmpty);
    });

    test('has no write side effects', () async {
      await seedQuest(db, name: 'done', completedAt: DateTime(2026, 11, 15, 9));
      await xp.apply(25);
      final before = await db.select(db.quests).get();

      await quests.history(DateTime(2026, 11, 1), DateTime(2026, 11, 30));
      await quests.watchOpenBoard().first;
      await quests.watchDoneToday(DateTime(2026, 11, 15)).first;

      expect(await db.select(db.quests).get(), before);
      expect(await xp.readTotal(), 25);
    });

    test('a range spanning a DST change still covers whole Board_Days', () async {
      // Europe/Prague moves to summer time on 2026-03-29; the logic is wall-clock based.
      await seedQuest(db, name: 'before', completedAt: DateTime(2026, 3, 29, 3, 59));
      await seedQuest(db, name: 'after', sortOrder: 2, completedAt: DateTime(2026, 3, 29, 4, 1));

      final history = await quests.history(DateTime(2026, 3, 29), DateTime(2026, 3, 29));

      expect(history.map((h) => h.name), ['after']);
    });
  });
}
