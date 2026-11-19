import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/mission_detail/mission_detail_screen.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:questlog/ui/state/reward_queue.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/widgets/cards/mission_card.dart';
import 'package:questlog/ui/widgets/reward/reward_card.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/seed.dart';
import '../../../helpers/test_database.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a reward earned on the pushed Mission detail is visible and '
      'tappable above that route', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final QuestlogDatabase db = createTestDatabase();

    // Seeded before the first frame so no Drift stream is listening yet.
    await tester.runAsync(() async {
      final int mission = await seedMission(db, name: 'Bathroom');
      await seedQuest(db, name: 'Buy tiles', missionId: mission);
      await seedQuest(db, name: 'Lay tiles', missionId: mission, sortOrder: 2);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(
            FixedClock(DateTime(2026, 11, 16, 12)),
          ),
          deviceLocaleProvider.overrideWithValue(const Locale('en')),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
        ],
        child: const QuestlogApp(),
      ),
    );
    await _settle(tester);
    await _settle(tester);

    await tester.tap(find.byKey(const ValueKey<ShellTab>(ShellTab.missions)));
    await _settle(tester);
    await tester.tap(find.byType(MissionCard));
    await _settle(tester);
    expect(find.byType(MissionDetailScreen), findsOneWidget);

    ProviderScope.containerOf(
      tester.element(find.byType(MissionDetailScreen)),
    ).read(rewardQueueProvider.notifier).push(
      const MissionReward(
        missionName: 'Bathroom',
        bonus: 25,
        levelUp: false,
        level: 1,
      ),
    );
    await tester.pump();
    await _settle(tester);

    // The card is on screen and the scrim above the route takes hits.
    expect(find.byType(RewardCard).hitTestable(), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  });
}
