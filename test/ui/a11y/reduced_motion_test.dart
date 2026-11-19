import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/state/reward_queue.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/reward/reward_card.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/seed.dart';
import '../../helpers/test_database.dart';

/// Requirement 16.5: when the device asks for reduced motion, slides, scales
/// and rays give way to fades of at most 150 ms. Each widget family has its own
/// test; this one drives the real app through the device flag and checks that
/// nothing is still animating once one fade has run.
void main() {
  test('the reduced-motion fade is at most 150 ms', () {
    expect(
      Motion.reducedFade,
      lessThanOrEqualTo(const Duration(milliseconds: 150)),
    );
  });

  Future<int> framesLeftAfterFade(
    WidgetTester tester, {
    required bool reduced,
    required Future<void> Function(WidgetTester) trigger,
  }) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: reduced);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    final QuestlogDatabase db = createTestDatabase();
    await tester.runAsync(() => seedQuest(db, name: 'Milk'));
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
    for (int i = 0; i < 2; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pumpAndSettle();
    }

    await trigger(tester);
    await tester.pump(Motion.reducedFade + const Duration(milliseconds: 1));
    final int left = tester.binding.transientCallbackCount;

    // Let everything finish, then dispose inside the test body.
    await tester.pumpAndSettle(
      const Duration(seconds: 1),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 20),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
    return left;
  }

  /// Completing a Quest shows no card any more; the Mission reward still does.
  Future<void> showMissionReward(WidgetTester tester) async {
    ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(rewardQueueProvider.notifier).push(
      const MissionReward(
        missionName: 'Bathroom',
        bonus: 25,
        levelUp: false,
        level: 1,
      ),
    );
    // Builds the reward card; its entry animation starts on this frame.
    await tester.pump();
    expect(find.byType(RewardCard), findsOneWidget);
  }

  Future<void> openSheet(WidgetTester tester) async {
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.byTooltip(l10n.a11y_addQuest));
    await tester.pump();
    // The route's animation starts at the first frame after it is built.
    await tester.pump(const Duration(milliseconds: 1));
  }

  final Map<String, Future<void> Function(WidgetTester)> triggers = {
    'reward card': showMissionReward,
    'quest sheet': openSheet,
  };

  triggers.forEach((String name, Future<void> Function(WidgetTester) trigger) {
    testWidgets('$name: one fade and nothing is left animating', (
      tester,
    ) async {
      expect(
        await framesLeftAfterFade(tester, reduced: true, trigger: trigger),
        0,
      );
    });

    testWidgets('$name: without the flag the full animation is still running '
        'after that time', (tester) async {
      expect(
        await framesLeftAfterFade(tester, reduced: false, trigger: trigger),
        greaterThan(0),
      );
    });
  });
}
