import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/widgets/cards/check_circle.dart';
import 'package:questlog/ui/widgets/reward/reward_card.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/seed.dart';
import '../helpers/test_database.dart';

const String _light = 'HapticFeedbackType.lightImpact';
const String _medium = 'HapticFeedbackType.mediumImpact';
const String _heavy = 'HapticFeedbackType.heavyImpact';

/// Drift streams run on real async: give them time, then finish the frames.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

void main() {
  final AppLocalizationsEn en = AppLocalizationsEn();

  testWidgets('the platform haptic fires for a quest, a mission, a reorder '
      'lift and a confirmed deletion', (tester) async {
    tester.view.physicalSize = const Size(430, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final List<String> haptics = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String);
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final QuestlogDatabase db = createTestDatabase();
    final FixedClock clock = FixedClock(DateTime(2026, 11, 16, 12));
    await tester.runAsync(() async {
      final int mission = await seedMission(db, name: 'Only mission');
      await seedQuest(db, name: 'Mission step', missionId: mission, sortOrder: 1);
      await seedQuest(db, name: 'Alpha', sortOrder: 2);
      await seedQuest(db, name: 'Beta', sortOrder: 3);
      await seedQuest(db, name: 'Gamma', sortOrder: 4);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          deviceLocaleProvider.overrideWithValue(const Locale('en')),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
        ],
        child: const QuestlogApp(),
      ),
    );
    await _settle(tester);
    await _settle(tester);

    Finder check(String name) => find.byWidgetPredicate(
      (Widget w) =>
          w is CheckCircle && w.semanticLabel == en.a11y_completeQuest(name),
    );

    // Completing a quest.
    haptics.clear();
    await tester.tap(check('Alpha'));
    await _settle(tester);
    expect(haptics, contains(_heavy));

    // Completing a mission: open it (the Board lists no mission quests),
    // complete its last quest, then the reward's mission button.
    await tester.tap(find.byKey(const ValueKey<ShellTab>(ShellTab.missions)));
    await _settle(tester);
    await tester.tap(find.text('Only mission'));
    await _settle(tester);
    await tester.tap(check('Mission step'));
    await _settle(tester);
    final Finder completeButton = find.text(en.mission_completeAction);
    expect(completeButton, findsOneWidget);
    haptics.clear();
    await tester.ensureVisible(completeButton);
    await tester.tap(completeButton);
    await _settle(tester);
    expect(find.byType(RewardCard), findsOneWidget);
    expect(completeButton, findsNothing);
    expect(haptics, contains(_heavy));
    await tester.tap(find.text(en.common_continue));
    await _settle(tester);
    await tester.tap(find.bySemanticsLabel(en.common_back));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey<ShellTab>(ShellTab.quests)));
    await _settle(tester);

    // Lifting a card to reorder it.
    haptics.clear();
    final TestGesture lift = await tester.startGesture(
      tester.getCenter(find.text('Beta')),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    expect(haptics, <String>[_light]);
    await lift.cancel();
    await _settle(tester);

    // Confirming a destructive action.
    await tester.drag(find.text('Gamma'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    haptics.clear();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await _settle(tester);
    expect(haptics, contains(_medium));
    expect(find.text('Gamma'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  });
}
