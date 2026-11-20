import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/ui/sheets/quest_sheet.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/cards/difficulty_pips.dart';
import 'package:questlog/ui/widgets/common/effort_picker.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/seed.dart';
import '../../helpers/test_database.dart';

final AppLocalizationsEn l10n = AppLocalizationsEn();

/// A real [QuestService] that counts calls and can be told to fail.
class _SpyQuestService extends QuestService {
  _SpyQuestService(super.db, super.xp, super.clock);

  int createCalls = 0;
  int updateCalls = 0;
  DomainError? failWith;

  @override
  Future<Quest> create(QuestDraft draft) {
    createCalls++;
    if (failWith != null) throw failWith!;
    return super.create(draft);
  }

  @override
  Future<Quest> update(int id, QuestDraft draft) {
    updateCalls++;
    if (failWith != null) throw failWith!;
    return super.update(id, draft);
  }
}

class _Fixture {
  _Fixture(this.db, this.service, this.container);

  final QuestlogDatabase db;
  final _SpyQuestService service;
  final ProviderContainer container;

  String? get snackText => container.read(snackbarProvider)?.text;

  Future<List<Quest>> quests() async {
    final rows = await db.select(db.quests).get();
    return rows
        .map(
          (r) => Quest(
            id: r.id,
            name: r.name,
            note: r.note,
            difficulty: r.difficulty,
            missionId: r.missionId,
            sortOrder: r.sortOrder,
            createdAt: r.createdAt,
            completedAt: r.completedAt,
            awardedXp: r.awardedXp,
          ),
        )
        .toList();
  }
}

/// Pumps a host with an "open" button over an in-memory database. [launch]
/// runs `showQuestSheet` with whatever arguments the test needs.
Future<_Fixture> _pumpHost(
  WidgetTester tester, {
  required Future<void> Function(BuildContext context) launch,
  Future<void> Function(QuestlogDatabase db)? seed,
  Locale locale = const Locale('en'),
  Size size = const Size(800, 1800),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final QuestlogDatabase db = createTestDatabase();
  late _SpyQuestService spy;
  final ProviderContainer container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 15, 12))),
      questServiceProvider.overrideWith((ref) {
        spy = _SpyQuestService(
          ref.watch(databaseProvider),
          ref.watch(xpEngineProvider),
          ref.watch(clockProvider),
        );
        return spy;
      }),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
  if (seed != null) await seed(db);
  // Instantiate the spy before the first tap.
  container.read(questServiceProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildTheme(
          palette: QuestlogPalette.guildBoard,
        ),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (BuildContext context, Widget? child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => Center(
              child: TextButton(
                onPressed: () => launch(context),
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
  return _Fixture(db, spy, container);
}

Future<_Fixture> _pumpCreate(
  WidgetTester tester, {
  int? presetMissionId,
  Future<void> Function(QuestlogDatabase db)? seed,
  Locale locale = const Locale('en'),
  Size size = const Size(800, 1800),
  double textScale = 1,
}) => _pumpHost(
  tester,
  seed: seed,
  locale: locale,
  size: size,
  textScale: textScale,
  launch: (context) =>
      showQuestSheet(context, presetMissionId: presetMissionId),
);

Future<_Fixture> _pumpEdit(
  WidgetTester tester, {
  required int questId,
  Future<void> Function(QuestlogDatabase db)? seed,
}) async {
  late Quest quest;
  Future<_Fixture> fixture() => _pumpHost(
    tester,
    seed: (db) async {
      if (seed != null) await seed(db);
    },
    launch: (context) => showQuestSheet(context, editing: quest),
  );
  // The Quest model is read from a throw-away database first, with the same
  // seed, so the sheet receives a faithful snapshot.
  final QuestlogDatabase probe = createTestDatabase();
  if (seed != null) await seed(probe);
  final row = await (probe.select(
    probe.quests,
  )..where((q) => q.id.equals(questId))).getSingle();
  await probe.close();
  quest = Quest(
    id: row.id,
    name: row.name,
    note: row.note,
    difficulty: row.difficulty,
    missionId: row.missionId,
    sortOrder: row.sortOrder,
    createdAt: row.createdAt,
    completedAt: row.completedAt,
    awardedXp: row.awardedXp,
  );
  return fixture();
}

Finder get _nameField => find.byType(TextField).first;
Finder get _noteField => find.byType(TextField).last;
Finder get _primary => find.byType(FilledButton);
Finder get _sheet => find.byType(QuestSheet);

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(_primary);
  await tester.pumpAndSettle();
}

void main() {
  group('create mode', () {
    testWidgets('focuses the name field and shows the create labels', (
      tester,
    ) async {
      await _pumpCreate(tester);

      final EditableTextState state = tester.state<EditableTextState>(
        find.descendant(of: _nameField, matching: find.byType(EditableText)),
      );
      expect(state.widget.focusNode.hasFocus, isTrue);
      expect(find.text(l10n.quest_sheetCreateTitle), findsOneWidget);
      expect(
        find.descendant(
          of: _primary,
          matching: find.text(l10n.quest_createAction),
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.common_delete), findsNothing);
      // The artboard gives the create button an up arrow before the label.
      expect(
        find.descendant(of: _primary, matching: find.byType(SvgPicture)),
        findsOneWidget,
      );
      // Default effort is the second step, with the XP of every step.
      for (final String xp in <String>['+10 XP', '+25 XP', '+50 XP', '+100 XP']) {
        expect(find.text(xp), findsOneWidget, reason: xp);
      }
      expect(
        tester.widget<EffortPicker>(find.byType(EffortPicker)).selected,
        Difficulty.normal,
      );
    });

    group('effort picker', () {
      testWidgets('shows names, time descriptions, XP, four pips each and the hint (en)', (
        tester,
      ) async {
        await _pumpCreate(tester);

        for (final String text in <String>[
          'Moment', 'up to ~30 min', '+10 XP',
          'Hour', 'up to ~2 h', '+25 XP',
          'Part of a day', '2–4 h', '+50 XP',
          'Full day', 'the whole day', '+100 XP',
          l10n.quest_effortLabel.toUpperCase(),
          l10n.quest_effortHint,
        ]) {
          expect(find.text(text), findsOneWidget, reason: text);
        }
        expect(find.byType(DifficultyPips), findsNWidgets(4));
        // 4 options x 4 pips; 1 + 2 + 3 + 4 of them filled.
        expect(find.byKey(const ValueKey<String>('pip-on')), findsNWidgets(10));
        expect(find.byKey(const ValueKey<String>('pip-off')), findsNWidgets(6));
      });

      testWidgets('shows names, time descriptions, XP and the hint (cs)', (
        tester,
      ) async {
        await _pumpCreate(tester, locale: const Locale('cs'));

        for (final String text in <String>[
          'Chvilka', 'do ~30 min', '+10 XP',
          'Hodinka', 'do ~2 h', '+25 XP',
          'Část dne', '2–4 h', '+50 XP',
          'Celý den', 'celý den', '+100 XP',
          'NÁMAHA',
          'Zvol podle toho, kolik času ti to zabere. Cesta, čekání nebo něco nepříjemného? Klidně o stupeň výš — za námahu patří víc XP.',
        ]) {
          expect(find.text(text), findsOneWidget, reason: text);
        }
      });

      for (final Locale locale in const <Locale>[Locale('cs'), Locale('en')]) {
        testWidgets('does not overflow on a 390 px screen at large text (${locale.languageCode})', (
          tester,
        ) async {
          await _pumpCreate(
            tester,
            locale: locale,
            size: const Size(390, 844),
            textScale: 2,
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(EffortPicker), findsOneWidget);
        });
      }

      testWidgets('picking the fourth step stores the whole-day tier', (
        tester,
      ) async {
        final f = await _pumpCreate(tester);
        await tester.enterText(_nameField, 'Drive to the notary');
        await tester.tap(find.text('+100 XP'));
        await tester.pump();
        await _submit(tester);

        expect((await f.quests()).single.difficulty, Difficulty.fullDay);
      });
    });

    testWidgets('lists "no mission" first, then the open missions', (
      tester,
    ) async {
      await _pumpCreate(
        tester,
        seed: (db) async {
          await seedMission(db, name: 'Cleanup');
          await seedMission(
            db,
            name: 'Done mission',
            status: MissionStatus.completed,
          );
        },
      );

      expect(find.text('Cleanup'), findsOneWidget);
      expect(find.text('Done mission'), findsNothing);
      final double none = tester
          .getTopLeft(find.text(l10n.quest_missionNone))
          .dx;
      final double mission = tester.getTopLeft(find.text('Cleanup')).dx;
      expect(none, lessThan(mission));
    });

    testWidgets(
      'empty name shows an inline error and does not call the service',
      (tester) async {
        final f = await _pumpCreate(tester);
        await tester.enterText(_noteField, 'keep me');
        await _submit(tester);

        expect(find.text(l10n.error_nameRequired), findsOneWidget);
        expect(f.service.createCalls, 0);
        expect(_sheet, findsOneWidget);
        expect(find.text('keep me'), findsOneWidget);
      },
    );

    testWidgets('81-character name is rejected, 80 is accepted', (
      tester,
    ) async {
      final f = await _pumpCreate(tester);
      await tester.enterText(_nameField, 'a' * 81);
      await _submit(tester);

      expect(find.text(l10n.error_nameTooLong), findsOneWidget);
      expect(f.service.createCalls, 0);
      expect(find.text('a' * 81), findsOneWidget);

      // The error clears live once the input is valid again.
      await tester.enterText(_nameField, 'a' * 80);
      await tester.pump();
      expect(find.text(l10n.error_nameTooLong), findsNothing);
      await _submit(tester);
      expect(f.service.createCalls, 1);
      expect(_sheet, findsNothing);
    });

    testWidgets('501-character note is rejected and the name is kept', (
      tester,
    ) async {
      final f = await _pumpCreate(tester);
      await tester.enterText(_nameField, 'Wash the car');
      await tester.enterText(_noteField, 'n' * 501);
      await _submit(tester);

      expect(find.text(l10n.error_noteTooLong), findsOneWidget);
      expect(f.service.createCalls, 0);
      expect(find.text('Wash the car'), findsOneWidget);
      expect(find.text('n' * 501), findsOneWidget);
      expect(await f.quests(), isEmpty);
    });

    testWidgets('success closes the sheet and the quest is stored', (
      tester,
    ) async {
      final f = await _pumpCreate(tester);
      await tester.enterText(_nameField, '  Hang the laundry ');
      await tester.enterText(_noteField, 'balcony');
      await tester.tap(find.text('+50 XP'));
      await tester.pump();
      await _submit(tester);

      expect(_sheet, findsNothing);
      final List<Quest> stored = await f.quests();
      expect(stored, hasLength(1));
      expect(stored.single.name, 'Hang the laundry');
      expect(stored.single.note, 'balcony');
      expect(stored.single.difficulty, Difficulty.hard);
      expect(stored.single.missionId, isNull);
      expect(stored.single.createdAt, DateTime(2026, 11, 15, 12));
    });

    testWidgets('a preset mission is preselected and saved with the quest', (
      tester,
    ) async {
      late int missionId;
      final f = await _pumpCreate(
        tester,
        presetMissionId: 1,
        seed: (db) async {
          missionId = await seedMission(db, name: 'Cleanup');
          await seedMission(db, name: 'Fitness');
        },
      );
      expect(missionId, 1);

      await tester.enterText(_nameField, 'Vacuum');
      await _submit(tester);

      final List<Quest> stored = await f.quests();
      expect(stored.single.missionId, missionId);
    });

    testWidgets('assigning a mission from outside its detail screen says where the quest went', (
      tester,
    ) async {
      final f = await _pumpCreate(
        tester,
        seed: (db) async => seedMission(db, name: 'Cleanup'),
      );
      await tester.tap(find.text('Cleanup'));
      await tester.pump();
      await tester.enterText(_nameField, 'Vacuum');
      await _submit(tester);

      expect((await f.quests()).single.missionId, isNotNull);
      expect(f.snackText, 'Added to mission Cleanup');
    });

    testWidgets('a quest without a mission, or posted inside a mission, shows no message', (
      tester,
    ) async {
      final loose = await _pumpCreate(
        tester,
        seed: (db) async => seedMission(db, name: 'Cleanup'),
      );
      await tester.enterText(_nameField, 'Vacuum');
      await _submit(tester);
      expect(loose.snackText, isNull);

      final inside = await _pumpCreate(
        tester,
        presetMissionId: 1,
        seed: (db) async => seedMission(db, name: 'Cleanup'),
      );
      await tester.enterText(_nameField, 'Dust');
      await _submit(tester);
      expect(inside.snackText, isNull);
    });

    testWidgets('picking "no mission" detaches a preset mission', (
      tester,
    ) async {
      final f = await _pumpCreate(
        tester,
        presetMissionId: 1,
        seed: (db) async => seedMission(db, name: 'Cleanup'),
      );
      await tester.tap(find.text(l10n.quest_missionNone));
      await tester.pump();
      await tester.enterText(_nameField, 'Vacuum');
      await _submit(tester);

      expect((await f.quests()).single.missionId, isNull);
    });

    testWidgets(
      'a mission that is no longer open shows the error beside the picker',
      (tester) async {
        final f = await _pumpCreate(
          tester,
          presetMissionId: 1,
          seed: (db) async => seedMission(db, name: 'Cleanup'),
        );
        f.service.failWith = const InvalidStateError('mission 1 is closed');
        await tester.enterText(_nameField, 'Vacuum');
        await _submit(tester);

        expect(find.text(l10n.error_missionNotOpen), findsOneWidget);
        expect(_sheet, findsOneWidget);
        expect(find.text('Vacuum'), findsOneWidget);

        // Choosing another mission clears the message.
        await tester.tap(find.text(l10n.quest_missionNone));
        await tester.pump();
        expect(find.text(l10n.error_missionNotOpen), findsNothing);
      },
    );

    testWidgets('other service errors are shown as localized text', (
      tester,
    ) async {
      final f = await _pumpCreate(tester);
      f.service.failWith = const StorageError('disk is full');
      await tester.enterText(_nameField, 'Vacuum');
      await _submit(tester);

      expect(find.text(l10n.error_storage), findsOneWidget);
      expect(find.textContaining('disk is full'), findsNothing);
      expect(_sheet, findsOneWidget);
    });
  });

  group('dismissal', () {
    testWidgets('an untouched sheet closes without asking', (tester) async {
      await _pumpCreate(tester);
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(_sheet, findsNothing);
    });

    testWidgets('a sheet with input asks first, and keeps it when told so', (
      tester,
    ) async {
      await _pumpCreate(tester);
      await tester.enterText(_nameField, 'Half-written');
      await tester.pump();
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsOneWidget);
      await tester.tap(find.text(l10n.sheet_keepEditing));
      await tester.pumpAndSettle();
      expect(_sheet, findsOneWidget);
      expect(find.text('Half-written'), findsOneWidget);

      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.common_discard));
      await tester.pumpAndSettle();
      expect(_sheet, findsNothing);
    });

    testWidgets('changing only the difficulty counts as input', (tester) async {
      await _pumpCreate(tester);
      await tester.tap(find.text('+10 XP'));
      await tester.pump();
      await tester.tap(find.text(l10n.common_cancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsOneWidget);
    });
  });

  group('edit mode', () {
    Future<void> seedOpen(QuestlogDatabase db) async {
      final int mission = await seedMission(db, name: 'Cleanup');
      await seedQuest(db, name: 'Old name', missionId: mission);
    }

    Future<void> seedDone(QuestlogDatabase db) async {
      final int mission = await seedMission(db, name: 'Cleanup');
      await seedQuest(
        db,
        name: 'Finished',
        difficulty: Difficulty.hard,
        missionId: mission,
        completedAt: DateTime(2026, 11, 15, 9),
      );
    }

    testWidgets('shows the stored values, the edit title and "Save"', (
      tester,
    ) async {
      await _pumpEdit(tester, questId: 1, seed: seedOpen);

      expect(find.text(l10n.quest_sheetEditTitle), findsOneWidget);
      expect(
        find.descendant(of: _primary, matching: find.text(l10n.common_save)),
        findsOneWidget,
      );
      expect(find.text('Old name'), findsOneWidget);
      expect(find.text(l10n.common_delete), findsOneWidget);
      // Only the create button carries the arrow.
      expect(
        find.descendant(of: _primary, matching: find.byType(SvgPicture)),
        findsNothing,
      );
    });

    testWidgets('editing an open quest saves difficulty and mission', (
      tester,
    ) async {
      final f = await _pumpEdit(tester, questId: 1, seed: seedOpen);
      await tester.enterText(_nameField, 'New name');
      await tester.tap(find.text('+10 XP'));
      await tester.pump();
      await tester.tap(find.text(l10n.quest_missionNone));
      await tester.pump();
      await _submit(tester);

      expect(_sheet, findsNothing);
      final Quest stored = (await f.quests()).single;
      expect(stored.name, 'New name');
      expect(stored.difficulty, Difficulty.easy);
      expect(stored.missionId, isNull);
    });

    testWidgets('a done quest has Difficulty and Mission disabled', (
      tester,
    ) async {
      final f = await _pumpEdit(tester, questId: 1, seed: seedDone);

      expect(
        tester.widget<EffortPicker>(find.byType(EffortPicker)).enabled,
        isFalse,
      );
      expect(find.text(l10n.quest_doneLockedHint), findsOneWidget);
      // The Mission it belongs to stays visible as the selection.
      for (final String label in <String>['Cleanup', l10n.quest_missionNone]) {
        final InkWell chip = tester.widget<InkWell>(
          find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
        );
        expect(chip.onTap, isNull, reason: label);
      }

      // Taps on the disabled controls change nothing, the name still saves.
      await tester.tap(find.text('+10 XP'), warnIfMissed: false);
      await tester.tap(find.text(l10n.quest_missionNone), warnIfMissed: false);
      await tester.pump();
      await tester.enterText(_nameField, 'Finished again');
      await _submit(tester);

      final Quest stored = (await f.quests()).single;
      expect(stored.name, 'Finished again');
      expect(stored.difficulty, Difficulty.hard);
      expect(stored.missionId, 1);
      expect(stored.isDone, isTrue);
    });

    testWidgets('the delete confirmation names the quest', (tester) async {
      final f = await _pumpEdit(tester, questId: 1, seed: seedOpen);
      await tester.tap(find.text(l10n.common_delete));
      await tester.pumpAndSettle();

      expect(find.text(l10n.quest_deleteTitle), findsOneWidget);
      expect(find.text(l10n.quest_deleteBody('Old name')), findsOneWidget);
      expect(find.textContaining('XP already earned'), findsNothing);

      // Cancelling changes nothing.
      await tester.tap(find.text(l10n.common_cancel).last);
      await tester.pumpAndSettle();
      expect(_sheet, findsOneWidget);
      expect(await f.quests(), hasLength(1));

      await tester.tap(find.text(l10n.common_delete));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.common_delete),
        ),
      );
      await tester.pumpAndSettle();

      expect(_sheet, findsNothing);
      expect(await f.quests(), isEmpty);
    });

    testWidgets('the delete confirmation of a done quest says the XP is kept', (
      tester,
    ) async {
      final f = await _pumpEdit(tester, questId: 1, seed: seedDone);
      await tester.tap(find.text(l10n.common_delete));
      await tester.pumpAndSettle();

      expect(find.text(l10n.quest_deleteDoneBody('Finished')), findsOneWidget);
      expect(find.text(l10n.quest_deleteBody('Finished')), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.common_delete),
        ),
      );
      await tester.pumpAndSettle();
      expect(_sheet, findsNothing);
      expect(await f.quests(), isEmpty);
    });

    testWidgets('deleting from a dirty sheet closes it without asking again', (
      tester,
    ) async {
      final f = await _pumpEdit(tester, questId: 1, seed: seedOpen);
      await tester.enterText(_nameField, 'Changed');
      await tester.pump();
      await tester.tap(find.text(l10n.common_delete));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.common_delete),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.sheet_discardTitle), findsNothing);
      expect(_sheet, findsNothing);
      expect(await f.quests(), isEmpty);
    });
  });

  group('deadline', () {
    testWidgets('picking a date saves the Quest with a Deadline and a calendar event', (tester) async {
      final _Fixture f = await _pumpCreate(tester);
      await tester.enterText(_nameField, 'Pay rent');
      await tester.pumpAndSettle();
      expect(find.text(l10n.quest_deadlineNone), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('quest-deadline-pick')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('11/20/2026'), findsOneWidget);
      expect(find.text(l10n.quest_deadlineLinkedHint), findsOneWidget);
      await _submit(tester);
      final events = await f.db.select(f.db.calendarEvents).get();
      expect(events.where((e) => e.name == 'Pay rent' && e.endDate == DateTime(2026, 11, 20)), hasLength(1));
      expect((await f.db.select(f.db.quests).get()).single.eventId, isNotNull);
    });

    testWidgets('"No deadline" clears a chosen date', (tester) async {
      final _Fixture f = await _pumpCreate(tester);
      await tester.enterText(_nameField, 'Pay rent');
      await tester.tap(find.byKey(const ValueKey<String>('quest-deadline-pick')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.quest_deadlineNone));
      await tester.pumpAndSettle();
      expect(find.text(l10n.quest_deadlineLinkedHint), findsNothing);
      await _submit(tester);
      expect((await f.db.select(f.db.quests).get()).single.eventId, isNull);
    });
  });
}
