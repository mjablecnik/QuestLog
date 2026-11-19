import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/widgets/cards/check_circle.dart';
import 'package:questlog/ui/widgets/cards/mission_card.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/seed.dart';
import '../../helpers/test_database.dart';

/// Requirement 16.4: completing and reopening a Quest, completing and reopening
/// a Mission are spoken to screen-reader users, in the language of the app.
void main() {
  for (final String code in <String>['en', 'cs']) {
    testWidgets('state changes are announced ($code)', (tester) async {
      tester.view.physicalSize = const Size(430, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final AppLocalizations l10n = lookupAppLocalizations(Locale(code));
      final QuestlogDatabase db = createTestDatabase();

      final List<String> spoken = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
            dynamic message,
          ) async {
            final Map<dynamic, dynamic> map = message as Map<dynamic, dynamic>;
            if (map['type'] == 'announce') {
              final Map<dynamic, dynamic> data =
                  map['data'] as Map<dynamic, dynamic>;
              spoken.add(data['message'] as String);
            }
            return null;
          });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler<dynamic>(
              SystemChannels.accessibility,
              null,
            ),
      );

      // Seeded before the first frame: no Drift stream is listening yet.
      await tester.runAsync(() async {
        await seedQuest(db, name: 'Milk');
        final int mission = await seedMission(db, name: 'Bathroom');
        await seedQuest(db, name: 'Buy tiles', missionId: mission);
        await seedQuest(
          db,
          name: 'Lay tiles',
          missionId: mission,
          sortOrder: 2,
        );
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            clockProvider.overrideWithValue(
              FixedClock(DateTime(2026, 11, 16, 12)),
            ),
            deviceLocaleProvider.overrideWithValue(Locale(code)),
            appVersionProvider.overrideWith((ref) async => '1.0.0'),
          ],
          child: const QuestlogApp(),
        ),
      );

      Future<void> settle() async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await tester.pumpAndSettle();
      }

      Finder check(String label) => find.byWidgetPredicate(
        (Widget w) => w is CheckCircle && w.semanticLabel == label,
      );
      Future<void> tapCheck(String label) async {
        await tester.tap(check(label));
        await tester.pump();
        await settle();
      }

      bool said(String prefix) => spoken.any((m) => m.startsWith(prefix));

      await settle();
      await settle();

      // Quest completed.
      await tapCheck(l10n.a11y_completeQuest('Milk'));
      expect(
        said(l10n.a11y_questCompleted('Milk', Difficulty.normal.xp)),
        true,
      );

      // Quest reopened.
      await tapCheck(l10n.a11y_reopenQuest('Milk'));
      expect(said(l10n.a11y_questReopened('Milk')), true);

      // Mission completed, from the button of the Mission detail.
      await tester.tap(find.byKey(const ValueKey<ShellTab>(ShellTab.missions)));
      await settle();
      await tester.tap(find.byType(MissionCard));
      await settle();
      await tapCheck(l10n.a11y_completeQuest('Buy tiles'));
      await tapCheck(l10n.a11y_completeQuest('Lay tiles'));
      await tester.tap(find.text(l10n.mission_completeAction));
      await settle();
      expect(
        said(l10n.a11y_missionCompleted('Bathroom', MissionBonus.small.xp)),
        true,
      );
      // Dismiss every card still queued.
      while (find.text(l10n.common_continue).evaluate().isNotEmpty) {
        await tester.tap(find.text(l10n.common_continue).first);
        await settle();
      }

      // Mission reopened by reopening one of its Quests.
      await tapCheck(l10n.a11y_reopenQuest('Lay tiles'));
      expect(said(l10n.a11y_missionReopened('Bathroom')), true);
      expect(said(l10n.a11y_questReopened('Lay tiles')), true);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
      await tester.runAsync(db.close);
    });
  }
}
