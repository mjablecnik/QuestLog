import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/sheets/mission_sheet.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/sheet/questlog_sheet.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/seed.dart';
import '../../helpers/test_database.dart';

final AppLocalizationsEn l10n = AppLocalizationsEn();

final Finder _nameField = find.byKey(
  const ValueKey<String>('mission-name-field'),
);

/// Quest row text fields, in order (every TextField except the name field).
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

/// Pumps an app with a button that opens the Mission_Sheet. The ProviderScope
/// sits above the MaterialApp because the sheet lives on the root navigator.
Future<_Fixture> _pump(WidgetTester tester, {MissionSummary? editing}) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final QuestlogDatabase db = createTestDatabase();
  final ProviderContainer container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 15, 12))),
    ],
  );
  final _Fixture fixture = _Fixture(db, container);
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
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showMissionSheet(context, editing: editing),
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
  return fixture;
}

MissionSummary _summary({
  MissionStatus status = MissionStatus.open,
  MissionBonus bonus = MissionBonus.small,
}) {
  return MissionSummary(
    id: 1,
    name: 'Move house',
    bonus: bonus,
    status: status,
    done: 0,
    total: 0,
    remainingXp: 0,
    ruleId: null,
    completedAt: status == MissionStatus.completed
        ? DateTime(2026, 11, 14, 12)
        : null,
    awardedBonus: status == MissionStatus.completed ? 50 : null,
  );
}

/// Runs a real async action (Drift) while the test clock is faked.
Future<T> _async<T>(WidgetTester tester, Future<T> Function() action) async {
  final T? value = await tester.runAsync(action);
  return value as T;
}

Future<void> _tapPrimary(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  // Let the real Drift future finish, then the closing transition.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pumpAndSettle();
}

void main() {
  group('create mode', () {
    testWidgets('shows the fields, default bonus and the primary label', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text(l10n.mission_sheetCreateTitle), findsOneWidget);
      expect(find.text(l10n.mission_createAction), findsOneWidget);
      expect(find.text(l10n.mission_bonusSmall), findsOneWidget);
      expect(find.text('+50 XP'), findsOneWidget);
      expect(find.text('+100 XP'), findsOneWidget);
      expect(find.text('+200 XP'), findsOneWidget);
      expect(find.text(l10n.mission_addQuest), findsOneWidget);
      expect(_rowFields, findsNWidgets(1));
      // The default bonus is Medium.
      final Semantics medium = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.text(l10n.mission_bonusMedium),
              matching: find.byWidgetPredicate(
                (Widget w) => w is Semantics && w.properties.selected != null,
              ),
            )
            .first,
      );
      expect(medium.properties.selected, isTrue);
    });

    testWidgets('empty name shows an error, keeps input, calls no service', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);
      await tester.enterText(_rowFields.first, 'Pack boxes');

      await _tapPrimary(tester, l10n.mission_createAction);

      expect(find.text(l10n.error_nameRequired), findsOneWidget);
      expect(find.text('Pack boxes'), findsOneWidget);
      expect(find.text(l10n.mission_sheetCreateTitle), findsOneWidget);
      expect(
        await _async(tester, () => f.db.select(f.db.missions).get()),
        isEmpty,
      );
    });

    testWidgets('a name of only spaces is rejected', (tester) async {
      final _Fixture f = await _pump(tester);
      await tester.enterText(_nameField, '    ');

      await _tapPrimary(tester, l10n.mission_createAction);

      expect(find.text(l10n.error_nameRequired), findsOneWidget);
      expect(
        await _async(tester, () => f.db.select(f.db.missions).get()),
        isEmpty,
      );
    });

    testWidgets('a name over 80 characters shows an error and keeps input', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);
      final String longName = 'x' * 81;
      await tester.enterText(_nameField, longName);

      await _tapPrimary(tester, l10n.mission_createAction);

      expect(find.text(l10n.error_nameTooLong), findsOneWidget);
      expect(find.text(longName), findsOneWidget);
      expect(
        await _async(tester, () => f.db.select(f.db.missions).get()),
        isEmpty,
      );
    });

    testWidgets('typing clears the name error', (tester) async {
      await _pump(tester);
      await _tapPrimary(tester, l10n.mission_createAction);
      expect(find.text(l10n.error_nameRequired), findsOneWidget);

      await tester.enterText(_nameField, 'M');
      await tester.pump();

      expect(find.text(l10n.error_nameRequired), findsNothing);
    });

    testWidgets('a quest row over 80 characters shows an error beside it', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);
      await tester.enterText(_nameField, 'Move house');
      await tester.enterText(_rowFields.first, 'q' * 81);

      await _tapPrimary(tester, l10n.mission_createAction);

      expect(find.text(l10n.error_nameTooLong), findsOneWidget);
      expect(find.text(l10n.mission_sheetCreateTitle), findsOneWidget);
      expect(
        await _async(tester, () => f.db.select(f.db.missions).get()),
        isEmpty,
      );
    });

    testWidgets('empty quest rows are ignored on submit', (tester) async {
      final _Fixture f = await _pump(tester);
      await tester.enterText(_nameField, 'Move house');
      await tester.tap(find.text(l10n.mission_addQuest));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.mission_addQuest));
      await tester.pumpAndSettle();
      expect(_rowFields, findsNWidgets(3));
      await tester.enterText(_rowFields.at(1), '  Pack  ');

      await _tapPrimary(tester, l10n.mission_createAction);

      expect(find.text(l10n.mission_sheetCreateTitle), findsNothing);
      final List<QuestRow> quests = await _async(
        tester,
        () => f.db.select(f.db.quests).get(),
      );
      expect(quests.map((QuestRow q) => q.name), <String>['Pack']);
    });

    testWidgets('a row can be removed with its remove button', (tester) async {
      await _pump(tester);
      await tester.tap(find.text(l10n.mission_addQuest));
      await tester.pumpAndSettle();
      expect(_rowFields, findsNWidgets(2));
      await tester.enterText(_rowFields.at(0), 'first');
      await tester.enterText(_rowFields.at(1), 'second');

      await tester.tap(find.bySemanticsLabel(l10n.a11y_removeRow).first);
      await tester.pump();
      // The row is still animating out, then it is gone.
      await tester.pumpAndSettle();

      expect(_rowFields, findsNWidgets(1));
      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('row removal fades instead of sliding under reduced motion', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await _pump(tester);
      await tester.tap(find.text(l10n.mission_addQuest));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel(l10n.a11y_removeRow).first);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(SizeTransition), findsNothing);
      await tester.pumpAndSettle();

      expect(_rowFields, findsNWidgets(1));
    });

    testWidgets('the difficulty chip cycles and shows the quest xp', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('+25'), findsOneWidget);

      await tester.tap(find.text('+25'));
      await tester.pump();
      expect(find.text('+50'), findsOneWidget);

      await tester.tap(find.text('+50'));
      await tester.pump();
      expect(find.text('+100'), findsOneWidget);

      await tester.tap(find.text('+100'));
      await tester.pump();
      expect(find.text('+10'), findsOneWidget);
    });

    testWidgets('creating persists the Mission with its Quests and closes', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);
      await tester.enterText(_nameField, '  Autumn clean-up ');
      await tester.tap(find.text(l10n.mission_bonusLarge));
      await tester.pump();
      await tester.enterText(_rowFields.first, 'Sort the wardrobe');
      await tester.tap(find.text('+25')); // normal -> hard
      await tester.pump();
      await tester.tap(find.text(l10n.mission_addQuest));
      await tester.pumpAndSettle();
      await tester.enterText(_rowFields.at(1), 'Wash windows');

      await _tapPrimary(tester, l10n.mission_createAction);

      expect(find.text(l10n.mission_sheetCreateTitle), findsNothing);
      final List<MissionRow> missions = await _async(
        tester,
        () => f.db.select(f.db.missions).get(),
      );
      expect(missions, hasLength(1));
      expect(missions.single.name, 'Autumn clean-up');
      expect(missions.single.bonus, MissionBonus.large);
      expect(missions.single.status, MissionStatus.open);
      final List<QuestRow> quests = await _async(
        tester,
        () => (f.db.select(
          f.db.quests,
        )..orderBy([($QuestsTable q) => OrderingTerm.asc(q.sortOrder)])).get(),
      );
      expect(quests.map((QuestRow q) => q.name), <String>[
        'Sort the wardrobe',
        'Wash windows',
      ]);
      expect(quests.map((QuestRow q) => q.difficulty), <Difficulty>[
        Difficulty.hard,
        Difficulty.normal,
      ]);
      expect(
        quests.every((QuestRow q) => q.missionId == missions.single.id),
        isTrue,
      );
    });
  });

  group('dismissal', () {
    testWidgets('a clean sheet closes without asking', (tester) async {
      await _pump(tester);

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.mission_sheetCreateTitle), findsNothing);
      expect(find.text(l10n.sheet_discardTitle), findsNothing);
    });

    testWidgets('a sheet with input asks before discarding', (tester) async {
      await _pump(tester);
      await tester.enterText(_nameField, 'Move house');
      await tester.pump();

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(find.text(l10n.sheet_discardTitle), findsOneWidget);

      await tester.tap(find.text(l10n.sheet_keepEditing));
      await tester.pumpAndSettle();
      expect(find.text(l10n.mission_sheetCreateTitle), findsOneWidget);
      expect(find.text('Move house'), findsOneWidget);

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_discard));
      await tester.pumpAndSettle();
      expect(find.text(l10n.mission_sheetCreateTitle), findsNothing);
    });

    testWidgets('text typed only into a quest row also counts as input', (
      tester,
    ) async {
      await _pump(tester);
      await tester.enterText(_rowFields.first, 'Pack');
      await tester.pump();

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsOneWidget);
    });

    testWidgets('a successful save closes without asking', (tester) async {
      await _pump(tester);
      await tester.enterText(_nameField, 'Move house');

      await _tapPrimary(tester, l10n.mission_createAction);

      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(find.byType(QuestlogSheet), findsNothing);
    });
  });

  group('edit mode', () {
    testWidgets('shows only name and bonus, with the edit title and Save', (
      tester,
    ) async {
      await _pump(tester, editing: _summary());

      expect(find.text(l10n.mission_sheetEditTitle), findsOneWidget);
      expect(find.text(l10n.common_save), findsOneWidget);
      expect(find.text(l10n.mission_createAction), findsNothing);
      expect(find.text('Move house'), findsOneWidget);
      expect(_rowFields, findsNothing);
      expect(find.text(l10n.mission_addQuest), findsNothing);
      expect(find.text(l10n.mission_editBonusNote), findsNothing);
    });

    testWidgets('a completed Mission shows the earned-bonus note', (
      tester,
    ) async {
      await _pump(tester, editing: _summary(status: MissionStatus.completed));

      expect(find.text(l10n.mission_editBonusNote), findsOneWidget);
      expect(find.text(l10n.mission_bonusHelp), findsNothing);
      expect(_rowFields, findsNothing);
    });

    testWidgets('is clean until something changes', (tester) async {
      await _pump(tester, editing: _summary());

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      expect(find.byType(QuestlogSheet), findsNothing);
    });

    testWidgets('saving updates the name and bonus through the service', (
      tester,
    ) async {
      final _Fixture f = await _pump(tester);
      // Seed after pumping so the stream-free sheet is unaffected; open an
      // edit sheet for the seeded Mission on top.
      final int id = await _async(
        tester,
        () => seedMission(f.db, name: 'Old name', bonus: MissionBonus.small),
      );
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      final BuildContext context = tester.element(find.text('open'));
      showMissionSheet(
        context,
        editing: MissionSummary(
          id: id,
          name: 'Old name',
          bonus: MissionBonus.small,
          status: MissionStatus.open,
          done: 0,
          total: 0,
          remainingXp: 0,
          ruleId: null,
          completedAt: null,
          awardedBonus: null,
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(_nameField, 'New name');
      await tester.tap(find.text(l10n.mission_bonusLarge));
      await tester.pump();

      await _tapPrimary(tester, l10n.common_save);

      expect(find.byType(QuestlogSheet), findsNothing);
      final List<MissionRow> missions = await _async(
        tester,
        () => f.db.select(f.db.missions).get(),
      );
      expect(missions.single.name, 'New name');
      expect(missions.single.bonus, MissionBonus.large);
    });

    testWidgets('an empty name is rejected in edit mode too', (tester) async {
      await _pump(tester, editing: _summary());
      await tester.enterText(_nameField, '');

      await _tapPrimary(tester, l10n.common_save);

      expect(find.text(l10n.error_nameRequired), findsOneWidget);
      expect(find.byType(QuestlogSheet), findsOneWidget);
    });
  });
}
