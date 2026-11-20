import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/mission_detail/mission_detail_screen.dart';
import 'package:questlog/ui/screens/missions/missions_screen.dart';
import 'package:questlog/ui/sheets/mission_sheet.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/cards/mission_card.dart';
import 'package:questlog/ui/widgets/cards/progress_ring.dart';
import 'package:questlog/ui/widgets/common/skeleton_list.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/seed.dart';
import '../../../helpers/test_database.dart';

final AppLocalizationsEn l10n = AppLocalizationsEn();

class _Env {
  _Env(this.tester, this.db, this.container, this.clock);

  final WidgetTester tester;
  final QuestlogDatabase db;
  final ProviderContainer container;
  final FixedClock clock;

  /// Runs a real async action (Drift) while the test clock is faked.
  Future<T> run<T>(Future<T> Function() action) async {
    final T? value = await tester.runAsync(action);
    return value as T;
  }

  /// Lets Drift streams deliver, then rebuilds.
  Future<void> settle() async {
    for (int i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  /// Creates a Mission with quests; completes the first [doneCount] of them.
  Future<int> mission(
    String name, {
    required int quests,
    int doneCount = 0,
    MissionBonus bonus = MissionBonus.medium,
    bool complete = false,
  }) {
    return run(() async {
      final mission = await container
          .read(missionServiceProvider)
          .create(
            MissionDraft(
              name: name,
              bonus: bonus,
              quests: <QuestDraft>[
                for (int i = 0; i < quests; i++)
                  QuestDraft(
                    name: '$name quest $i',
                    difficulty: Difficulty.easy,
                  ),
              ],
            ),
          );
      final rows = await db.select(db.quests).get();
      final mine = rows.where((q) => q.missionId == mission.id).toList();
      for (final q in mine.take(doneCount)) {
        await container.read(questServiceProvider).complete(q.id);
      }
      if (complete) {
        await container.read(missionServiceProvider).complete(mission.id);
      }
      return mission.id;
    });
  }

  /// Disposes everything so no timer outlives the test body.
  Future<void> finish() async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    // Drift schedules a zero-duration timer when its streams close.
    await tester.pump(const Duration(milliseconds: 1));
    await run(() => db.close());
  }
}

Future<_Env> _pump(
  WidgetTester tester, {
  DateTime? now,
  bool settleAfter = true,
  Future<void> Function(_Env env)? seed,
}) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final QuestlogDatabase db = createTestDatabase();
  final FixedClock clock = FixedClock(now ?? DateTime(2026, 11, 15, 11));
  final ProviderContainer container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock),
    ],
  );
  final _Env env = _Env(tester, db, container, clock);
  // Seeded before the screen exists: Drift writes with live streams need real
  // time that the fake clock does not give.
  if (seed != null) await seed(env);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildTheme(
          palette: QuestlogPalette.guildBoard,
        ),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MissionsScreen(),
      ),
    ),
  );
  if (settleAfter) await env.settle();
  return env;
}

void main() {
  group('listing', () {
    testWidgets('shows skeleton cards while the first load is pending', (
      tester,
    ) async {
      final _Env env = await _pump(tester, settleAfter: false);
      expect(find.byType(SkeletonList), findsOneWidget);
      await env.settle();
      expect(find.byType(SkeletonList), findsNothing);
      await env.finish();
    });

    testWidgets('open Missions show ring, remaining XP and the bonus', (
      tester,
    ) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.mission('Clean up', quests: 3, doneCount: 1);
          await env.mission('Taxes', quests: 3, bonus: MissionBonus.large);
        },
      );

      expect(find.byType(MissionCard), findsNWidgets(2));
      expect(find.text('Clean up'), findsOneWidget);
      // The ring figure is the number of quests still open.
      Finder ringFigure(int index, String text) => find.descendant(
        of: find.byType(ProgressRing).at(index),
        matching: find.text(text, findRichText: true),
      );
      expect(ringFigure(0, '2'), findsOneWidget);
      // Two easy quests (+10 each) are still open.
      expect(find.text(l10n.missions_remaining(20)), findsOneWidget);
      expect(find.text(l10n.missions_remaining(30)), findsOneWidget);
      expect(ringFigure(1, '3'), findsOneWidget);
      expect(find.text('+100'), findsOneWidget);
      expect(find.text('+200'), findsOneWidget);
      expect(
        find.text(l10n.missions_bonusCaption.toUpperCase()),
        findsNWidgets(2),
      );
      final ring = tester.widgetList<ProgressRing>(find.byType(ProgressRing));
      expect(ring.map((r) => '${r.done}/${r.total}'), <String>['1/3', '0/3']);
      expect(
        find.text(l10n.missions_sectionOpen.toUpperCase()),
        findsOneWidget,
      );
      expect(
        find.text(l10n.missions_sectionDoneToday.toUpperCase()),
        findsNothing,
      );
      await env.finish();
    });

    testWidgets('a Mission card sums the XP of all four effort tiers and names none', (
      tester,
    ) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.run(
            () => env.container.read(missionServiceProvider).create(
              MissionDraft(
                name: 'Move house',
                bonus: MissionBonus.small,
                quests: <QuestDraft>[
                  for (final Difficulty d in Difficulty.values)
                    QuestDraft(name: 'Step ${d.name}', difficulty: d),
                ],
              ),
            ),
          );
        },
      );

      // 10 + 25 + 50 + 100.
      expect(find.text(l10n.missions_remaining(185)), findsOneWidget);
      for (final String name in <String>[
        l10n.quest_effortMoment,
        l10n.quest_effortHour,
        l10n.quest_effortPart,
        l10n.quest_effortDay,
      ]) {
        expect(find.text(name), findsNothing, reason: name);
      }
      await env.finish();
    });

    testWidgets('a Mission with every Quest done shows the ready caption', (
      tester,
    ) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.mission('Pack', quests: 2, doneCount: 2);
        },
      );

      expect(find.text(l10n.missions_readyToComplete), findsOneWidget);
      expect(find.textContaining('Remaining'), findsNothing);
      await env.finish();
    });
  });

  group('Completed today', () {
    testWidgets('lists only Missions completed on the current Board_Day', (
      tester,
    ) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.mission('Still open', quests: 1);
          await env.mission(
            'Finished today',
            quests: 1,
            doneCount: 1,
            bonus: MissionBonus.small,
            complete: true,
          );
          await env.run(
            () => seedMission(
              env.db,
              name: 'Finished yesterday',
              status: MissionStatus.completed,
              completedAt: DateTime(2026, 11, 14, 12),
              awardedBonus: 100,
            ),
          );
        },
      );

      expect(
        find.text(l10n.missions_sectionDoneToday.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text('Finished today'), findsOneWidget);
      expect(find.text('Finished yesterday'), findsNothing);
      expect(find.text('+50'), findsOneWidget);
      expect(
        find.text(l10n.missions_earnedCaption.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text('Still open'), findsOneWidget);
      await env.finish();
    });

    testWidgets('empties after 04:00 without a restart', (tester) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.mission('Still open', quests: 1);
          await env.mission(
            'Finished today',
            quests: 1,
            doneCount: 1,
            complete: true,
          );
        },
      );
      expect(find.text('Finished today'), findsOneWidget);

      env.clock.set(DateTime(2026, 11, 16, 4, 0, 1));
      await tester.pump(const Duration(hours: 17));
      await env.settle();

      expect(find.text('Finished today'), findsNothing);
      expect(
        find.text(l10n.missions_sectionDoneToday.toUpperCase()),
        findsNothing,
      );
      expect(find.text('Still open'), findsOneWidget);
      await env.finish();
    });
  });

  group('actions', () {
    testWidgets('empty state button opens the Mission sheet', (tester) async {
      final _Env env = await _pump(tester);
      expect(find.text(l10n.missions_emptyTitle), findsOneWidget);

      await tester.tap(find.text(l10n.missions_emptyAction));
      await tester.pumpAndSettle();

      expect(find.byType(MissionSheet), findsOneWidget);
      expect(find.text(l10n.mission_sheetCreateTitle), findsOneWidget);
      await env.finish();
    });

    testWidgets('the add button opens the Mission sheet', (tester) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.mission('Clean up', quests: 1);
        },
      );

      await tester.tap(find.byKey(const ValueKey<String>('add-fab')));
      await tester.pumpAndSettle();

      expect(find.byType(MissionSheet), findsOneWidget);
      await env.finish();
    });

    testWidgets('tapping a Mission opens its detail', (tester) async {
      int id = 0;
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          id = await env.mission('Clean up', quests: 1);
        },
      );

      await tester.tap(find.text('Clean up'));
      await tester.pumpAndSettle();

      final MissionDetailScreen detail = tester.widget(
        find.byType(MissionDetailScreen),
      );
      expect(detail.missionId, id);
      await env.finish();
    });

    testWidgets('swipe Edit opens the sheet in edit mode', (tester) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.mission('Clean up', quests: 1);
        },
      );

      await tester.drag(find.byType(MissionCard), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('mission-swipe-edit')),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.mission_sheetEditTitle), findsOneWidget);
      await env.finish();
    });

    testWidgets('delete confirmation names the Mission and the Quest count', (
      tester,
    ) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.mission('Clean up', quests: 3);
        },
      );

      await tester.drag(find.byType(MissionCard), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('mission-swipe-delete')),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.mission_deleteTitle), findsOneWidget);
      expect(find.text(l10n.mission_deleteBody('Clean up', 3)), findsOneWidget);
      expect(l10n.mission_deleteBody('Clean up', 3), contains('3 quests'));

      // Cancel changes nothing.
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(find.text('Clean up'), findsOneWidget);
      expect(
        await env.run(() => env.db.select(env.db.missions).get()),
        hasLength(1),
      );
      await env.finish();
    });

    testWidgets('confirming the deletion removes the Mission and its Quests', (
      tester,
    ) async {
      final _Env env = await _pump(
        tester,
        seed: (_Env env) async {
          await env.mission('Clean up', quests: 2);
        },
      );

      await tester.drag(find.byType(MissionCard), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('mission-swipe-delete')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.common_delete),
        ),
      );
      await tester.pump();
      // Removal transition, then the service call.
      await tester.pump(const Duration(milliseconds: 400));
      await env.settle();

      expect(find.text('Clean up'), findsNothing);
      expect(find.text(l10n.missions_emptyTitle), findsOneWidget);
      expect(
        await env.run(() => env.db.select(env.db.missions).get()),
        isEmpty,
      );
      expect(await env.run(() => env.db.select(env.db.quests).get()), isEmpty);
      await env.finish();
    });
  });
}
