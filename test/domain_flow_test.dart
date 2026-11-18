import 'package:glados/glados.dart';
import 'package:questlog/core/board_day.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/mission_service.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/recurrence_service.dart';
import 'package:questlog/services/xp_engine.dart';

import 'helpers/fixed_clock.dart';
import 'helpers/test_database.dart';

/// One scenario through the whole domain layer on an in-memory database:
/// a weekly rule posts a Mission, the user completes it across a Level boundary,
/// the Board_Day rolls over at 04:00, and a manual posting skips the next
/// automatic one.
void main() {
  late QuestlogDatabase db;
  late FixedClock clock;
  late XpEngine xp;
  late QuestService quests;
  late MissionService missions;
  late RecurrenceService recurrence;

  setUp(() {
    db = createTestDatabase();
    clock = FixedClock(DateTime(2026, 11, 14, 20)); // Saturday evening
    xp = XpEngine(db);
    quests = QuestService(db, xp, clock);
    missions = MissionService(db, xp, clock);
    recurrence = RecurrenceService(db, clock);
  });
  tearDown(() => db.close());

  test('rule, quests, mission, levels, day rollover and manual posting', () async {
    // A weekly Monday rule with two Quest templates and the largest bonus.
    final rule = await recurrence.create(
      RuleDraft(
        name: 'Weekly review',
        cadence: Cadence.weekly,
        requestedAnchor: DateTime(2026, 11, 16),
        bonus: MissionBonus.large,
        quests: const [
          RuleQuestDraft(name: 'Plan the week', difficulty: Difficulty.hard),
          RuleQuestDraft(name: 'Tidy the inbox', difficulty: Difficulty.normal),
        ],
      ),
    );
    expect(
      await recurrence.reconcile(),
      isEmpty,
      reason: 'Monday has not come yet',
    );

    // A standalone Quest earns 50 XP on Saturday.
    final standalone = await quests.create(
      const QuestDraft(name: 'Call the bank', difficulty: Difficulty.hard),
    );
    final first = await quests.complete(standalone.id);
    expect((first.awardedXp, first.levelBefore, first.levelAfter), (50, 1, 1));

    // Monday: the rule posts exactly one Instance with the templates in order.
    clock.set(DateTime(2026, 11, 16, 9));
    final posted = await recurrence.reconcile();
    expect(posted, hasLength(1));
    final mission = posted.single;
    expect(mission.name, 'Weekly review');
    expect(mission.ruleId, rule.id);
    expect(
      await recurrence.reconcile(),
      isEmpty,
      reason: 'idempotent within the Board_Day',
    );

    // The Instance's Quests belong to the Mission, so the Board never lists them.
    expect(await quests.watchOpenBoard().first, isEmpty);
    final board = (await missions.watchDetail(mission.id).first)!.quests;
    expect(board.map((q) => q.name), ['Plan the week', 'Tidy the inbox']);
    expect((await missions.watchOpen().first).single.total, 2);

    // The hard Quest takes Total_XP from 50 to 100: Level 1 -> 2.
    final hard = await quests.complete(board[0].id);
    expect((hard.awardedXp, hard.levelBefore, hard.levelAfter), (50, 1, 2));
    expect(hard.missionReadyToComplete, isFalse);

    final normal = await quests.complete(board[1].id);
    expect(normal.missionReadyToComplete, isTrue);
    expect(await xp.readTotal(), 125);

    // Completing the Mission adds its 200 XP bonus: 325 XP is Level 3.
    final done = await missions.complete(mission.id);
    expect((done.awardedBonus, done.levelBefore, done.levelAfter), (200, 2, 3));
    expect(await xp.readTotal(), 325);
    expect(progressFor(325).level, 3);

    // Still the same Board_Day at 03:59 on Tuesday: Monday's work shows as today.
    clock.set(DateTime(2026, 11, 17, 3, 59));
    var today = todayOf(clock.now());
    expect(today, DateTime(2026, 11, 16));
    expect(
      await quests.watchDoneToday(today).first,
      isEmpty,
      reason: "Monday's done Quests belong to the Mission, not to the Board",
    );
    expect(
      (await missions.watchCompletedToday(today).first).single.name,
      'Weekly review',
    );

    // At 04:00 the board rolls over: nothing done today, history keeps it all.
    clock.set(DateTime(2026, 11, 17, 4));
    today = todayOf(clock.now());
    expect(today, DateTime(2026, 11, 17));
    expect(await quests.watchDoneToday(today).first, isEmpty);
    expect(await missions.watchCompletedToday(today).first, isEmpty);
    final questHistory = await quests.history(
      DateTime(2026, 11, 16),
      DateTime(2026, 11, 16),
    );
    expect(questHistory.map((q) => q.name), [
      'Tidy the inbox',
      'Plan the week',
    ]);
    expect(questHistory.map((q) => q.awardedXp), [25, 50]);
    final missionHistory = await missions.history(
      DateTime(2026, 11, 16),
      DateTime(2026, 11, 16),
    );
    expect(missionHistory.single.awardedBonus, 200);
    expect(
      (await quests.history(
        DateTime(2026, 11, 14),
        DateTime(2026, 11, 14),
      )).single.name,
      'Call the bank',
    );

    // Tuesday, a manual posting skips Monday 23 November.
    clock.set(DateTime(2026, 11, 17, 10));
    final manual = await recurrence.postNow(rule.id);
    expect(manual.skippedNextPosting, isTrue);
    expect(
      manual.closedPreviousInstance,
      isFalse,
      reason: 'the earlier Instance was completed',
    );
    expect(
      (await recurrence.watchRules().first).single.nextOccurrence,
      DateTime(2026, 11, 30),
    );

    clock.set(DateTime(2026, 11, 23, 9));
    expect(
      await recurrence.reconcile(),
      isEmpty,
      reason: 'the 23rd was skipped',
    );
    expect(await db.select(db.missions).get(), hasLength(2));

    // The following Monday posts again and closes the manual Instance for free.
    clock.set(DateTime(2026, 11, 30, 9));
    final next = await recurrence.reconcile();
    expect(next, hasLength(1));
    final all = await db.select(db.missions).get();
    expect(all.map((m) => m.status), [
      MissionStatus.completed,
      MissionStatus.closed,
      MissionStatus.open,
    ]);
    expect(all[1].awardedBonus, isNull);
    expect(
      await xp.readTotal(),
      325,
      reason: 'closing a Mission never changes Total_XP',
    );
    expect(
      (await recurrence.watchRules().first).single.hasOpenInstance,
      isTrue,
    );
  });
}
