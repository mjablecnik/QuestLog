import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/ui/screens/board/board_screen.dart';
import 'package:questlog/ui/state/reward_queue.dart';
import 'package:questlog/ui/widgets/common/skeleton_list.dart';

import '../../../helpers/seed.dart';
import '_board_harness.dart';

void main() {
  final BoardHarness h = BoardHarness();

  Finder check(String label) => find.bySemanticsLabel(label);

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(BoardScreen)));

  Future<void> tapCheck(WidgetTester tester, String label) async {
    await tester.tap(check(label));
    await h.settle(tester);
  }

  boardTest(h, 'shows skeletons while the first load is pending', (
    tester,
  ) async {
    await h.pump(tester, settleStreams: false);
    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.text('The board is empty'), findsNothing);
    await h.settle(tester);
    expect(find.byType(SkeletonList), findsNothing);
  });

  boardTest(h, 'shows the empty state with guidance for the add button', (
    tester,
  ) async {
    await h.pump(tester);
    expect(find.text('The board is empty'), findsOneWidget);
    expect(find.textContaining('Tap the + button'), findsOneWidget);
    expect(find.byTooltip('Post a quest'), findsOneWidget);
  });

  boardTest(h, 'lists open quests in manual order, then done today', (
    tester,
  ) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      await seedQuest(h.db, name: 'Second', sortOrder: 2);
      await seedQuest(h.db, name: 'First', sortOrder: 1);
      await seedQuest(h.db, name: 'Third', sortOrder: 3);
      await seedQuest(
        h.db,
        name: 'Finished',
        sortOrder: 4,
        completedAt: DateTime(2026, 11, 15, 8, 52),
      );
    });
    await h.settle(tester);

    expect(h.order(tester, ['First', 'Second', 'Third', 'Finished']), [
      'First',
      'Second',
      'Third',
      'Finished',
    ]);
    expect(find.text('POSTED QUESTS'), findsOneWidget);
    expect(find.text('DONE TODAY'), findsOneWidget);
    expect(find.text('3 open · Sunday, November 15'), findsOneWidget);
    expect(find.text('1 QUEST · 25 XP'), findsOneWidget);
    expect(find.text('today 08:52'), findsOneWidget);
    final double doneHeader = tester.getTopLeft(find.text('DONE TODAY')).dy;
    expect(tester.getTopLeft(find.text('Third')).dy, lessThan(doneHeader));
    expect(
      tester.getTopLeft(find.text('Finished')).dy,
      greaterThan(doneHeader),
    );
  });

  boardTest(h, 'completing a quest pushes the reward and moves the card down', (
    tester,
  ) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      await seedQuest(h.db, name: 'Alpha', sortOrder: 1);
      await seedQuest(
        h.db,
        name: 'Beta',
        sortOrder: 2,
        difficulty: Difficulty.hard,
      );
    });
    await h.settle(tester);

    await tapCheck(tester, 'Complete quest Alpha');

    final List<RewardEvent> queue = container(tester).read(rewardQueueProvider);
    expect(queue, hasLength(1));
    final QuestReward reward = queue.single as QuestReward;
    expect(reward.questName, 'Alpha');
    expect(reward.xp, 25);
    expect(
      tester.getTopLeft(find.text('Alpha')).dy,
      greaterThan(tester.getTopLeft(find.text('DONE TODAY')).dy),
    );
    expect(check('Reopen quest Alpha'), findsOneWidget);
    expect(find.text('2 open · Sunday, November 15'), findsNothing);
    expect(find.text('1 open · Sunday, November 15'), findsOneWidget);
  });

  boardTest(h, 'a failed completion keeps the card and shows the error', (
    tester,
  ) async {
    await h.pump(tester);
    await tester.runAsync(() => seedQuest(h.db, name: 'Alpha'));
    await h.settle(tester);
    h.service.completeError = const StorageError('disk full');

    await tapCheck(tester, 'Complete quest Alpha');

    expect(
      find.text('The data could not be saved. Nothing was changed.'),
      findsOneWidget,
    );
    expect(find.textContaining('disk full'), findsNothing);
    expect(container(tester).read(rewardQueueProvider), isEmpty);
    expect(check('Complete quest Alpha'), findsOneWidget);
    expect(find.text('DONE TODAY'), findsNothing);
  });

  boardTest(h, 'a not-found error shows the item-changed message', (
    tester,
  ) async {
    await h.pump(tester);
    await tester.runAsync(() => seedQuest(h.db, name: 'Alpha'));
    await h.settle(tester);
    h.service.completeError = const NotFoundError('quest', 1);

    await tapCheck(tester, 'Complete quest Alpha');

    expect(
      find.text(
        'That item has changed in the meantime. The list was refreshed.',
      ),
      findsOneWidget,
    );
  });

  boardTest(h, 'unchecking moves the card back and shows the withdrawal', (
    tester,
  ) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      await seedQuest(h.db, name: 'Alpha', sortOrder: 1);
      await seedQuest(
        h.db,
        name: 'Beta',
        sortOrder: 2,
        completedAt: DateTime(2026, 11, 15, 8),
      );
    });
    await h.settle(tester);

    await tapCheck(tester, 'Reopen quest Beta');

    expect(find.text('25 XP withdrawn'), findsOneWidget);
    expect(find.text('DONE TODAY'), findsNothing);
    expect(check('Complete quest Beta'), findsOneWidget);
    expect(h.order(tester, ['Alpha', 'Beta']), ['Alpha', 'Beta']);
  });

  boardTest(h, 'reopening the last quest of a completed mission says so', (
    tester,
  ) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      final int mission = await seedMission(
        h.db,
        name: 'Cleanup',
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 9),
        awardedBonus: 100,
      );
      await seedQuest(
        h.db,
        name: 'Sweep',
        missionId: mission,
        completedAt: DateTime(2026, 11, 15, 9),
      );
    });
    await h.settle(tester);

    await tapCheck(tester, 'Reopen quest Sweep');

    expect(find.text('125 XP withdrawn · mission reopened'), findsOneWidget);
    expect(find.text('Cleanup'), findsOneWidget);
    expect(check('Complete quest Sweep'), findsOneWidget);
  });

  boardTest(h, 'add button opens the quest sheet', (tester) async {
    await h.pump(tester);
    await tester.tap(find.byTooltip('Post a quest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('New quest'), findsOneWidget);
  });

  boardTest(h, 'after 04:00 yesterday\'s done quests are no longer shown', (
    tester,
  ) async {
    await h.pump(tester, now: DateTime(2026, 11, 15, 10));
    await h.seed(tester, () async {
      await seedQuest(h.db, name: 'Open one', sortOrder: 1);
      await seedQuest(
        h.db,
        name: 'Done early',
        sortOrder: 2,
        completedAt: DateTime(2026, 11, 15, 8),
      );
    });
    await h.settle(tester);
    expect(find.text('Done early'), findsOneWidget);
    expect(find.text('DONE TODAY'), findsOneWidget);

    // Day_Start passes while the app is open: the signal fires on its own.
    h.clock.set(DateTime(2026, 11, 16, 4, 0, 1));
    await tester.pump(const Duration(hours: 19));
    await h.settle(tester);

    expect(find.text('Done early'), findsNothing);
    expect(find.text('DONE TODAY'), findsNothing);
    expect(find.text('Open one'), findsOneWidget);
    expect(find.text('1 open · Monday, November 16'), findsOneWidget);
  });

  boardTest(h, 'swiping reveals Edit and Delete; delete asks first', (
    tester,
  ) async {
    await h.pump(tester);
    late int id;
    await h.seed(tester, () async {
      id = await seedQuest(h.db, name: 'Alpha');
    });
    await h.settle(tester);

    Future<void> swipe() async {
      await tester.drag(find.text('Alpha'), const Offset(-300, 0));
      await tester.pumpAndSettle();
    }

    await swipe();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(
      tester.getSize(find.text('Delete').hitTestable()).width,
      greaterThan(0),
    );

    // Cancel changes nothing.
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete quest?'), findsOneWidget);
    expect(find.text('Quest “Alpha” will be deleted.'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);
    expect(h.service.reorderCalls, isEmpty);

    await swipe();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await h.settle(tester);

    expect(find.text('Alpha'), findsNothing);
    expect(find.text('The board is empty'), findsOneWidget);
    final remaining = await tester.runAsync(
      () => (h.db.select(h.db.quests)..where((q) => q.id.equals(id))).get(),
    );
    expect(remaining, isEmpty);
  });

  boardTest(h, 'deleting a done quest says the earned XP is kept', (
    tester,
  ) async {
    await h.pump(tester);
    await tester.runAsync(
      () =>
          seedQuest(h.db, name: 'Beta', completedAt: DateTime(2026, 11, 15, 8)),
    );
    await h.settle(tester);

    await tester.drag(find.text('Beta'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(
      find.text('Quest “Beta” will be deleted. The XP already earned is kept.'),
      findsOneWidget,
    );
  });

  boardTest(h, 'a failed delete shows the item-changed message', (
    tester,
  ) async {
    await h.pump(tester);
    await tester.runAsync(() => seedQuest(h.db, name: 'Alpha'));
    await h.settle(tester);
    h.service.deleteError = const NotFoundError('quest', 1);

    await tester.drag(find.text('Alpha'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await h.settle(tester);

    expect(
      find.text(
        'That item has changed in the meantime. The list was refreshed.',
      ),
      findsOneWidget,
    );
  });

  boardTest(h, 'Edit opens the quest sheet in edit mode', (tester) async {
    await h.pump(tester);
    await tester.runAsync(() => seedQuest(h.db, name: 'Alpha'));
    await h.settle(tester);

    await tester.drag(find.text('Alpha'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Edit quest'), findsOneWidget);
  });

  Future<void> seedThree(WidgetTester tester) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      await seedQuest(h.db, name: 'Alpha', sortOrder: 1);
      await seedQuest(h.db, name: 'Beta', sortOrder: 2);
      await seedQuest(h.db, name: 'Gamma', sortOrder: 3);
    });
    await h.settle(tester);
  }

  /// Long press on [name], then move it by [dy] and release (or not).
  Future<void> dragCard(
    WidgetTester tester,
    String name,
    double dy, {
    bool release = true,
  }) async {
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.text(name)),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    if (dy != 0) {
      await gesture.moveBy(Offset(0, dy / 2));
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.moveBy(Offset(0, dy / 2));
      await tester.pump(const Duration(milliseconds: 50));
    }
    if (release) {
      await gesture.up();
    } else {
      await gesture.cancel();
    }
    await tester.pumpAndSettle();
    await h.settle(tester);
  }

  boardTest(h, 'long press then move reorders and persists the new order', (
    tester,
  ) async {
    await seedThree(tester);

    await dragCard(tester, 'Alpha', 200);

    expect(h.service.reorderCalls, hasLength(1));
    expect(h.service.reorderCalls.single, hasLength(3));
    expect(h.service.reorderCalls.single.first, isNot(1));
    expect(h.order(tester, ['Alpha', 'Beta', 'Gamma']).first, isNot('Alpha'));
  });

  boardTest(h, 'a long press released in place persists nothing', (
    tester,
  ) async {
    await seedThree(tester);

    await dragCard(tester, 'Beta', 0);

    expect(h.service.reorderCalls, isEmpty);
    expect(h.order(tester, ['Alpha', 'Beta', 'Gamma']), [
      'Alpha',
      'Beta',
      'Gamma',
    ]);
  });

  boardTest(h, 'a cancelled drag persists nothing', (tester) async {
    await seedThree(tester);

    await dragCard(tester, 'Alpha', 200, release: false);

    expect(h.service.reorderCalls, isEmpty);
    expect(h.order(tester, ['Alpha', 'Beta', 'Gamma']), [
      'Alpha',
      'Beta',
      'Gamma',
    ]);
  });

  boardTest(h, 'a failing reorder restores the previous order and says so', (
    tester,
  ) async {
    await seedThree(tester);
    h.service.reorderError = const StorageError('disk full');

    await dragCard(tester, 'Alpha', 200);

    expect(h.service.reorderCalls, hasLength(1));
    expect(h.order(tester, ['Alpha', 'Beta', 'Gamma']), [
      'Alpha',
      'Beta',
      'Gamma',
    ]);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
