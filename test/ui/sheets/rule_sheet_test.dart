import 'dart:ui' show Tristate;

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
import 'package:questlog/ui/sheets/rule_sheet.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

final AppLocalizationsEn l10n = AppLocalizationsEn();

final Finder _nameField = find.byKey(const ValueKey<String>('rule-name-field'));

/// Quest template text fields, in order.
Finder get _rowFields => find.byWidgetPredicate(
  (Widget w) =>
      w is TextField &&
      w.decoration?.hintText == l10n.mission_questNamePlaceholder,
);

class _Fixture {
  _Fixture(this.db, this.container);

  final QuestlogDatabase db;
  final ProviderContainer container;
}

/// Pumps an app with a button that opens the Rule_Sheet. Today is Sunday
/// 2026-11-15, 12:00.
Future<_Fixture> _pump(
  WidgetTester tester, {
  RuleSummary? editing,
  bool seedAndEdit = false,
}) async {
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
  if (seedAndEdit) {
    final _Fixture seedFixture = _Fixture(db, container);
    editing = await _seedRule(tester, seedFixture);
  }
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
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showRuleSheet(context, editing: editing),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return _Fixture(db, container);
}

/// Runs a real async action (Drift) while the test clock is faked.
Future<T> _async<T>(WidgetTester tester, Future<T> Function() action) async {
  final T? value = await tester.runAsync(action);
  return value as T;
}

Future<List<RuleSummary>> _rules(WidgetTester tester, _Fixture f) => _async(
  tester,
  () => f.container.read(recurrenceServiceProvider).watchRules().first,
);

Future<RuleSummary> _seedRule(
  WidgetTester tester,
  _Fixture f, {
  String name = 'Pay rent',
  Cadence cadence = Cadence.monthly,
  DateTime? anchor,
}) async {
  await _async(
    tester,
    () => f.container
        .read(recurrenceServiceProvider)
        .create(
          RuleDraft(
            name: name,
            cadence: cadence,
            requestedAnchor: anchor ?? DateTime(2026, 11, 20),
            bonus: MissionBonus.small,
            quests: const <RuleQuestDraft>[
              RuleQuestDraft(name: 'Transfer', difficulty: Difficulty.easy),
              RuleQuestDraft(name: 'Check bill', difficulty: Difficulty.hard),
            ],
          ),
        ),
  );
  return (await _rules(tester, f)).single;
}

Future<void> _tapPrimary(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  // Let the real Drift future finish, then the closing transition.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

bool _isSelected(WidgetTester tester, String label) {
  final Finder chip = find.bySemanticsLabel(label);
  return tester.getSemantics(chip.first).flagsCollection.isSelected ==
      Tristate.isTrue;
}

void main() {
  group('create mode', () {
    testWidgets('shows the form with Monthly, Medium and one empty row', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text(l10n.rule_sheetTitle), findsOneWidget);
      expect(find.text(l10n.rule_saveAction), findsOneWidget);
      expect(find.text(l10n.rule_deleteAction), findsNothing);
      expect(find.text(l10n.rule_helpNoCarryOver), findsOneWidget);
      for (final Cadence cadence in Cadence.values) {
        expect(
          find.text(ruleCadenceLabel(l10n, cadence)),
          findsOneWidget,
          reason: cadence.name,
        );
      }
      expect(_isSelected(tester, l10n.rule_cadenceMonthly), isTrue);
      expect(_isSelected(tester, l10n.rule_cadenceDaily), isFalse);
      // The default posting day of a Monthly rule is today's day of the month.
      expect(find.text(l10n.rule_postingMonthDay(15)), findsOneWidget);
      expect(_rowFields, findsNWidgets(1));
    });

    testWidgets('an empty name and no quest show errors and save nothing', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);

      await _tapPrimary(tester, l10n.rule_saveAction);

      expect(find.text(l10n.error_nameRequired), findsOneWidget);
      expect(find.text(l10n.error_noQuestTemplate), findsOneWidget);
      expect(find.text(l10n.rule_sheetTitle), findsOneWidget);
      expect(await _rules(tester, f), isEmpty);
    });

    testWidgets('an over-long quest name is rejected beside its row', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);

      await tester.enterText(_nameField, 'Rent');
      await tester.enterText(_rowFields.first, 'x' * 121);
      await _tapPrimary(tester, l10n.rule_saveAction);

      expect(find.text(l10n.error_nameTooLong), findsOneWidget);
      expect(await _rules(tester, f), isEmpty);
    });

    testWidgets('saves a Monthly rule with its templates and closes', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);

      await tester.enterText(_nameField, '  Pay rent ');
      await tester.enterText(_rowFields.first, 'Transfer money');
      await tester.tap(find.text(l10n.mission_addQuest));
      await tester.pumpAndSettle();
      expect(_rowFields, findsNWidgets(2));
      await tester.enterText(_rowFields.at(1), 'Check bill');
      await _tapPrimary(tester, l10n.rule_saveAction);

      expect(find.text(l10n.rule_sheetTitle), findsNothing);
      final RuleSummary rule = (await _rules(tester, f)).single;
      expect(rule.name, 'Pay rent');
      expect(rule.cadence, Cadence.monthly);
      expect(rule.anchorDate, DateTime(2026, 11, 15));
      expect(rule.bonus, MissionBonus.medium);
      expect(rule.quests.map((RuleQuest q) => q.name), <String>[
        'Transfer money',
        'Check bill',
      ]);
    });

    testWidgets('empty quest rows are ignored on save', (tester) async {
      final _Fixture f = await _pump(tester);

      await tester.enterText(_nameField, 'Rent');
      await tester.tap(find.text(l10n.mission_addQuest));
      await tester.pumpAndSettle();
      await tester.enterText(_rowFields.at(1), 'Only one');
      await _tapPrimary(tester, l10n.rule_saveAction);

      final RuleSummary rule = (await _rules(tester, f)).single;
      expect(rule.quests.single.name, 'Only one');
    });

    testWidgets('a removed row is gone', (tester) async {
      await _pump(tester);

      await tester.tap(find.text(l10n.mission_addQuest));
      await tester.pumpAndSettle();
      expect(_rowFields, findsNWidgets(2));
      await tester.tap(find.bySemanticsLabel(l10n.a11y_removeRow).first);
      await tester.pumpAndSettle();

      expect(_rowFields, findsNWidgets(1));
    });

    testWidgets('the bonus and the difficulty are stored', (tester) async {
      final _Fixture f = await _pump(tester);

      await tester.enterText(_nameField, 'Rent');
      await tester.enterText(_rowFields.first, 'Transfer');
      await tester.tap(find.text(l10n.mission_bonusLarge));
      await tester.pump();
      // Normal -> Hard.
      await tester.tap(find.text('+${Difficulty.normal.xp}').first);
      await tester.pump();
      await _tapPrimary(tester, l10n.rule_saveAction);

      final RuleSummary rule = (await _rules(tester, f)).single;
      expect(rule.bonus, MissionBonus.large);
      expect(rule.quests.single.difficulty, Difficulty.hard);
    });
  });

  group('cadence and posting day', () {
    testWidgets('Daily has no posting day row', (tester) async {
      await _pump(tester);

      await tester.tap(find.text(l10n.rule_cadenceDaily));
      await tester.pumpAndSettle();

      expect(find.text(l10n.rule_postingDayLabel), findsNothing);
      expect(_isSelected(tester, l10n.rule_cadenceDaily), isTrue);
    });

    testWidgets('Weekly offers the weekday and keeps name and quests', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);

      await tester.enterText(_nameField, 'Clean');
      await tester.enterText(_rowFields.first, 'Vacuum');
      await tester.tap(find.text(l10n.rule_cadenceWeekly));
      await tester.pumpAndSettle();

      expect(find.text(l10n.rule_postingDayLabel), findsOneWidget);
      // 2026-11-15 is a Sunday.
      expect(find.text(ruleWeekdayName(l10n, DateTime.sunday)), findsOneWidget);
      expect(find.text('Clean'), findsOneWidget);
      expect(find.text('Vacuum'), findsOneWidget);

      await tester.tap(find.text(ruleWeekdayName(l10n, DateTime.sunday)));
      await tester.pumpAndSettle();
      expect(find.text(l10n.rule_postingDayWeekdayTitle), findsOneWidget);
      await tester.tap(find.text(ruleWeekdayName(l10n, DateTime.wednesday)));
      await tester.pumpAndSettle();
      expect(
        find.text(ruleWeekdayName(l10n, DateTime.wednesday)),
        findsOneWidget,
      );

      await _tapPrimary(tester, l10n.rule_saveAction);
      final RuleSummary rule = (await _rules(tester, f)).single;
      expect(rule.cadence, Cadence.weekly);
      expect(rule.anchorDate.weekday, DateTime.wednesday);
      expect(rule.anchorDate.isBefore(DateTime(2026, 11, 15)), isFalse);
    });

    testWidgets('a day of the month can be chosen for Monthly', (tester) async {
      final _Fixture f = await _pump(tester);

      await tester.enterText(_nameField, 'Rent');
      await tester.enterText(_rowFields.first, 'Transfer');
      await tester.tap(find.text(l10n.rule_postingMonthDay(15)));
      await tester.pumpAndSettle();
      expect(find.text(l10n.rule_postingDayMonthTitle), findsOneWidget);
      await tester.tap(find.text('28'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.rule_postingMonthDay(28)), findsOneWidget);

      await _tapPrimary(tester, l10n.rule_saveAction);
      final RuleSummary rule = (await _rules(tester, f)).single;
      expect(rule.anchorDate, DateTime(2026, 11, 28));
    });

    testWidgets('switching the cadence back restores the earlier day', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(find.text(l10n.rule_postingMonthDay(15)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.rule_cadenceWeekly));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.rule_cadenceMonthly));
      await tester.pumpAndSettle();

      expect(find.text(l10n.rule_postingMonthDay(3)), findsOneWidget);
    });
  });

  group('edit mode', () {
    testWidgets('saving an edit stores the new name', (tester) async {
      final _Fixture f = await _pump(tester, seedAndEdit: true);

      await tester.enterText(_nameField, 'Pay the rent');
      await tester.pump();
      await _tapPrimary(tester, l10n.rule_saveAction);

      final List<RuleSummary> rules = await _rules(tester, f);
      expect(rules.single.name, 'Pay the rent');
      expect(find.text(l10n.rule_sheetEditTitle), findsNothing);
    });

    testWidgets('deleting asks first and removes the rule', (tester) async {
      final _Fixture f = await _pump(tester, seedAndEdit: true);

      await tester.ensureVisible(find.text(l10n.rule_deleteAction));
      await tester.tap(find.text(l10n.rule_deleteAction));
      await tester.pumpAndSettle();
      expect(find.text(l10n.rule_deleteTitle), findsOneWidget);
      expect(find.text(l10n.rule_deleteBody('Pay rent')), findsOneWidget);
      expect((await _rules(tester, f)).length, 1);

      await tester.tap(find.text(l10n.rule_deleteAction).last);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(await _rules(tester, f), isEmpty);
      expect(find.text(l10n.rule_sheetEditTitle), findsNothing);
    });

    testWidgets('cancelling the deletion keeps the rule', (tester) async {
      final _Fixture f = await _pump(tester, seedAndEdit: true);

      await tester.ensureVisible(find.text(l10n.rule_deleteAction));
      await tester.tap(find.text(l10n.rule_deleteAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_cancel).last);
      await tester.pumpAndSettle();

      expect((await _rules(tester, f)).length, 1);
      expect(find.text(l10n.rule_sheetEditTitle), findsOneWidget);
    });

    testWidgets('shows the stored values and the delete button', (
      tester,
    ) async {
      final RuleSummary rule = RuleSummary(
        id: 1,
        name: 'Pay rent',
        cadence: Cadence.monthly,
        anchorDate: DateTime(2026, 11, 20),
        bonus: MissionBonus.small,
        quests: const <RuleQuest>[
          RuleQuest(
            name: 'Transfer',
            difficulty: Difficulty.easy,
            sortOrder: 1,
          ),
          RuleQuest(
            name: 'Check bill',
            difficulty: Difficulty.hard,
            sortOrder: 2,
          ),
        ],
        nextOccurrence: DateTime(2026, 11, 20),
        hasOpenInstance: false,
      );
      await _pump(tester, editing: rule);

      expect(find.text(l10n.rule_sheetEditTitle), findsOneWidget);
      expect(find.text(l10n.rule_editNote), findsOneWidget);
      expect(find.text('Pay rent'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Check bill'), findsOneWidget);
      expect(find.text(l10n.rule_postingMonthDay(20)), findsOneWidget);
      expect(find.text(l10n.rule_deleteAction), findsOneWidget);
    });
  });
}
