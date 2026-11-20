import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/settings/rules_section.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';

final AppLocalizationsEn l10n = AppLocalizationsEn();

class _Fixture {
  _Fixture(this.db, this.container);

  final QuestlogDatabase db;
  final ProviderContainer container;
}

/// Pumps the Rules_Section alone. Today is Sunday 2026-11-15, 12:00.
Future<_Fixture> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final QuestlogDatabase db = createTestDatabase();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 15, 12))),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
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
        home: const Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.all(Space.s16),
            child: RulesSection(),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
  return _Fixture(db, container);
}

/// Lets the real Drift streams deliver, then finishes the frames.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

Future<void> _seedRule(
  WidgetTester tester,
  _Fixture f, {
  String name = 'Pay rent',
  DateTime? anchor,
}) async {
  await tester.runAsync(
    () => f.container
        .read(recurrenceServiceProvider)
        .create(
          RuleDraft(
            name: name,
            cadence: Cadence.monthly,
            requestedAnchor: anchor ?? DateTime(2026, 11, 20),
            bonus: MissionBonus.small,
            quests: const <RuleQuestDraft>[
              RuleQuestDraft(name: 'Transfer', difficulty: Difficulty.easy),
              RuleQuestDraft(name: 'Check bill', difficulty: Difficulty.hard),
            ],
          ),
        ),
  );
  await _settle(tester);
}

Future<void> _postNow(WidgetTester tester) async {
  await tester.tap(find.text(l10n.rule_postNow));
  await _settle(tester);
}

void main() {
  testWidgets('without rules only the add row and its hint show', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text(l10n.rule_addRow), findsOneWidget);
    expect(find.text(l10n.rule_addHint), findsOneWidget);
    expect(find.text(l10n.rule_postNow), findsNothing);
    expect(find.text(l10n.settings_rulesActive(0).toUpperCase()), findsOneWidget);
  });

  testWidgets('a rule row shows cadence, quest count and the next date', (
    tester,
  ) async {
    final _Fixture f = await _pump(tester);
    await _seedRule(tester, f);

    expect(find.text('Pay rent'), findsOneWidget);
    expect(
      find.textContaining(
        '${l10n.rule_cadenceMonthly} · 2 quests · next Nov 20',
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.rule_postNow), findsOneWidget);
    expect(find.text(l10n.settings_rulesActive(1).toUpperCase()), findsOneWidget);
  });

  testWidgets(
    'posting by hand shows the skipped-posting message and dims the pill',
    (tester) async {
      final _Fixture f = await _pump(tester);
      await _seedRule(tester, f);

      await _postNow(tester);

      expect(
        find.text(
          '${l10n.rule_postedMessage('Pay rent')} ${l10n.rule_postedSkippedNote}',
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.rule_posted), findsOneWidget);
      expect(find.text(l10n.rule_postNow), findsNothing);
      final List<MissionSummary> open = await tester.runAsync(
        () => f.container.read(missionServiceProvider).watchOpen().first,
      ) as List<MissionSummary>;
      expect(open.single.name, 'Pay rent');
    },
  );

  testWidgets('posting again closes the unfinished earlier mission', (
    tester,
  ) async {
    final _Fixture f = await _pump(tester);
    await _seedRule(tester, f);
    await _postNow(tester);

    await tester.tap(find.text(l10n.rule_posted));
    await _settle(tester);

    expect(find.textContaining(l10n.rule_postedClosedNote), findsOneWidget);
  });

  testWidgets('tapping the row opens the Rule_Sheet for editing', (
    tester,
  ) async {
    final _Fixture f = await _pump(tester);
    await _seedRule(tester, f);

    await tester.tap(find.text('Pay rent'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.rule_sheetEditTitle), findsOneWidget);
  });

  testWidgets(
    'the add row opens the sheet and a saved rule appears with its next date',
    (tester) async {
      await _pump(tester);

      await tester.tap(find.text(l10n.rule_addRow));
      await tester.pumpAndSettle();
      expect(find.text(l10n.rule_sheetTitle), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey<String>('rule-name-field')),
        'Water plants',
      );
      await tester.enterText(
        find.byWidgetPredicate(
          (Widget w) =>
              w is TextField &&
              w.decoration?.hintText == l10n.mission_questNamePlaceholder,
        ),
        'Fill the can',
      );
      await tester.pump();
      await tester.tap(find.text(l10n.rule_saveAction));
      await _settle(tester);

      expect(find.text('Water plants'), findsOneWidget);
      expect(find.textContaining('1 quest · next'), findsOneWidget);
      expect(find.text(l10n.rule_sheetTitle), findsNothing);
    },
  );
}
