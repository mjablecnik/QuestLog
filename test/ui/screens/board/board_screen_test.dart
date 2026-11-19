import 'package:drift/drift.dart' show Value;
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart' show QuestRow, QuestsCompanion;
import 'package:questlog/data/models.dart' show BoardSection;
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/l10n/app_localizations_cs.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/ui/screens/board/board_screen.dart';
import 'package:questlog/ui/widgets/cards/difficulty_pips.dart';
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

  boardTest(h, 'shows XP and pips for the four effort tiers but never a tier name', (
    tester,
  ) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      var order = 1;
      for (final Difficulty d in Difficulty.values) {
        await seedQuest(h.db, name: 'Quest ${d.name}', difficulty: d, sortOrder: order++);
      }
    });
    await h.settle(tester);

    for (final String xp in <String>['+10', '+25', '+50', '+100']) {
      expect(find.text(xp), findsOneWidget, reason: xp);
    }
    expect(find.byType(DifficultyPips), findsNWidgets(4));
    expect(find.byKey(const ValueKey<String>('pip-on')), findsNWidgets(10));
    for (final AppLocalizations l in <AppLocalizations>[AppLocalizationsEn(), AppLocalizationsCs()]) {
      for (final String name in <String>[
        l.quest_effortMoment,
        l.quest_effortHour,
        l.quest_effortPart,
        l.quest_effortDay,
        l.quest_effortMomentTime,
        l.quest_effortHourTime,
        l.quest_effortPartTime,
        l.quest_effortDayTime,
      ]) {
        expect(find.text(name), findsNothing, reason: name);
      }
    }
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
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('TODO'), findsOneWidget);
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

  boardTest(h, 'completing a quest shows no reward and moves the card down', (
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

    expect(container(tester).read(rewardQueueProvider), isEmpty);
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

  boardTest(h, 'a not-found error also reloads a list that went stale', (
    tester,
  ) async {
    await h.pump(tester);
    await tester.runAsync(() => seedQuest(h.db, name: 'Alpha'));
    await h.settle(tester);
    // A raw statement does not notify the table watchers, so the board still
    // shows the card of a row that is already gone.
    await tester.runAsync(
      () => h.db.customStatement('DELETE FROM quests WHERE name = ?', <Object>[
        'Alpha',
      ]),
    );
    h.service.completeError = const NotFoundError('quest', 1);

    await tapCheck(tester, 'Complete quest Alpha');
    await h.settle(tester);

    expect(check('Complete quest Alpha'), findsNothing);
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

  boardTest(h, 'shows only quests without a mission, counts and XP included', (
    tester,
  ) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      final int mission = await seedMission(h.db, name: 'Cleanup');
      await seedQuest(h.db, name: 'Free', sortOrder: 1);
      await seedQuest(h.db, name: 'Free done', sortOrder: 2, completedAt: DateTime(2026, 11, 15, 8));
      await seedQuest(h.db, name: 'Bound', sortOrder: 3, missionId: mission, difficulty: Difficulty.hard);
      await seedQuest(
        h.db,
        name: 'Bound done',
        sortOrder: 4,
        missionId: mission,
        completedAt: DateTime(2026, 11, 15, 9),
      );
    });
    await h.settle(tester);

    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Free done'), findsOneWidget);
    expect(find.text('Bound'), findsNothing);
    expect(find.text('Bound done'), findsNothing);
    expect(find.text('1 open · Sunday, November 15'), findsOneWidget);
    expect(find.text('+25 XP'), findsOneWidget);
    expect(find.text('1 QUEST · 25 XP'), findsOneWidget);
  });

  boardTest(h, 'a board of mission quests only shows the empty state', (
    tester,
  ) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      final int mission = await seedMission(h.db, name: 'Cleanup');
      await seedQuest(h.db, name: 'Bound', missionId: mission);
    });
    await h.settle(tester);

    expect(find.text('The board is empty'), findsOneWidget);
    expect(find.text('Bound'), findsNothing);
    expect(find.text('TODO'), findsNothing);
    expect(find.text('0 open · Sunday, November 15'), findsOneWidget);
  });

  boardTest(h, 'a quest that gets a mission leaves the board and returns when freed', (
    tester,
  ) async {
    await h.pump(tester);
    late int questId;
    late int missionId;
    await h.seed(tester, () async {
      missionId = await seedMission(h.db, name: 'Cleanup');
      questId = await seedQuest(h.db, name: 'Wanderer');
    });
    await h.settle(tester);
    expect(find.text('Wanderer'), findsOneWidget);

    await h.seed(tester, () async {
      await (h.db.update(h.db.quests)..where((q) => q.id.equals(questId)))
          .write(QuestsCompanion(missionId: Value<int?>(missionId), board: const Value<BoardSection?>(null)));
    });
    await h.settle(tester);
    expect(find.text('Wanderer'), findsNothing);

    await h.seed(tester, () async {
      await (h.db.update(h.db.quests)..where((q) => q.id.equals(questId)))
          .write(const QuestsCompanion(missionId: Value<int?>(null), board: Value<BoardSection?>(BoardSection.todo)));
    });
    await h.settle(tester);
    expect(find.text('Wanderer'), findsOneWidget);
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

  boardTest(h, 'a rejected reorder also reloads a list that went stale', (
    tester,
  ) async {
    await seedThree(tester);
    await tester.runAsync(
      () => h.db.customStatement('DELETE FROM quests WHERE name = ?', <Object>[
        'Beta',
      ]),
    );
    h.service.reorderError = const ValidationError('order', 'ids differ');

    await dragCard(tester, 'Alpha', 200);

    expect(find.text('Beta'), findsNothing);
    expect(find.text('Alpha'), findsOneWidget);
  });

  boardTest(h, 'a mission quest posted to Today shows under Today with its mission', (
    tester,
  ) async {
    await h.pump(tester);
    await h.seed(tester, () async {
      final int mission = await seedMission(h.db, name: 'Cleanup');
      await seedQuest(h.db, name: 'Posted', missionId: mission, board: BoardSection.today);
      await seedQuest(h.db, name: 'Hidden', missionId: mission, sortOrder: 2);
      await seedQuest(h.db, name: 'Loose', sortOrder: 3);
    });
    await h.settle(tester);

    expect(find.text('Hidden'), findsNothing);
    expect(find.text('Cleanup'), findsOneWidget);
    expect(h.order(tester, ['Posted', 'Loose']), ['Posted', 'Loose']);
    expect(
      tester.getTopLeft(find.text('TODO')).dy,
      greaterThan(tester.getTopLeft(find.text('Posted')).dy),
    );
    expect(
      tester.getTopLeft(find.text('TODO')).dy,
      lessThan(tester.getTopLeft(find.text('Loose')).dy),
    );
  });

  boardTest(h, 'an empty Today section shows its hint', (tester) async {
    await seedThree(tester);

    expect(find.text('Drag a quest here to focus on it today.'), findsOneWidget);
  });

  boardTest(h, 'dragging a quest above the Todo header moves it to Today', (
    tester,
  ) async {
    await seedThree(tester);

    await dragCard(tester, 'Alpha', -150);

    final List<QuestRow> rows = await tester.runAsync(
      () => h.db.select(h.db.quests).get(),
    ) as List<QuestRow>;
    final Map<String, BoardSection?> board = <String, BoardSection?>{
      for (final QuestRow r in rows) r.name: r.board,
    };
    expect(board['Alpha'], BoardSection.today);
    expect(board['Beta'], BoardSection.todo);
    expect(board['Gamma'], BoardSection.todo);
    expect(
      tester.getTopLeft(find.text('Alpha')).dy,
      lessThan(tester.getTopLeft(find.text('TODO')).dy),
    );
  });
}
