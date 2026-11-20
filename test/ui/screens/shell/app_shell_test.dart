import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/app.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/services/recurrence_service.dart';
import 'package:questlog/services/settings_service.dart';
import 'package:questlog/ui/screens/board/board_screen.dart';
import 'package:questlog/ui/screens/calendar/calendar_screen.dart';
import 'package:questlog/ui/screens/missions/missions_screen.dart';
import 'package:questlog/ui/screens/notes/notes_screen.dart';
import 'package:questlog/ui/screens/settings/settings_screen.dart';
import 'package:questlog/ui/screens/shell/deep_link.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:questlog/ui/screens/shell/reconcile_banner.dart';
import 'package:questlog/ui/screens/shell/splash_screen.dart';
import 'package:questlog/ui/state/ui_providers.dart';
import 'package:questlog/ui/widgets/common/add_fab.dart';
import 'package:questlog/ui/widgets/hero/hero_bar.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/seed.dart';
import '../../../helpers/test_database.dart';

/// Counts Reconciliation runs and lets a test hold, fail or fill each one.
class SpyRecurrence extends RecurrenceService {
  SpyRecurrence(super.db, super.clock);

  int calls = 0;
  Completer<List<Mission>>? gate;
  Object? failure;
  List<Mission> posted = const <Mission>[];

  @override
  Future<List<Mission>> reconcile() async {
    calls++;
    final Completer<List<Mission>>? held = gate;
    if (held != null) return held.future;
    final Object? error = failure;
    if (error != null) throw error;
    return posted;
  }
}

Mission _mission(int id, String name) => Mission(
  id: id,
  name: name,
  bonus: MissionBonus.small,
  status: MissionStatus.open,
  ruleId: null,
  createdAt: DateTime(2026, 11, 16, 12),
  completedAt: null,
  awardedBonus: null,
);

const Key _questsTab = ValueKey<ShellTab>(ShellTab.quests);
const Key _missionsTab = ValueKey<ShellTab>(ShellTab.missions);
const Key _settingsTab = ValueKey<ShellTab>(ShellTab.settings);
const Key _calendarTab = ValueKey<ShellTab>(ShellTab.calendar);
const Key _notesTab = ValueKey<ShellTab>(ShellTab.notes);

void main() {
  late QuestlogDatabase db;
  late FixedClock clock;
  late SpyRecurrence spy;
  late ProviderContainer container;

  /// Like [testWidgets], but disposes the tree (cancelling the Board_Day timer,
  /// which the test binding checks for before tear-downs run) and closes the
  /// database at the end of the body.
  void shellTest(
    String description,
    Future<void> Function(WidgetTester tester) body,
  ) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 10));
        await tester.runAsync(() => db.close());
      }
    });
  }

  /// Drift streams run on real async: give them time, then rebuild.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump();
  }

  /// Pumps the real [QuestlogApp] (default home: the shell). [setUp] may seed the
  /// database and prime the [SpyRecurrence] before the first Reconciliation.
  Future<void> pumpApp(
    WidgetTester tester, {
    bool realRecurrence = false,
    Future<void> Function()? seed,
    void Function(SpyRecurrence spy)? prime,
    Stream<Uri>? links,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    db = createTestDatabase();
    clock = FixedClock(DateTime(2026, 11, 16, 12));
    spy = SpyRecurrence(db, clock);
    prime?.call(spy);
    if (seed != null) await tester.runAsync(seed);
    final overrides = [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock),
      if (!realRecurrence) recurrenceServiceProvider.overrideWithValue(spy),
      deviceLocaleProvider.overrideWithValue(const Locale('en')),
      appVersionProvider.overrideWith((ref) async => '1.0.0'),
      if (links != null) deepLinksProvider.overrideWithValue(links),
    ];
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const QuestlogApp()),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(QuestlogApp)),
    );
  }

  void goToBackground(WidgetTester tester) {
    for (final AppLifecycleState s in <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
  }

  void returnToForeground(WidgetTester tester) {
    for (final AppLifecycleState s in <AppLifecycleState>[
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
  }

  int tabIndex(WidgetTester tester) =>
      tester.widget<IndexedStack>(find.byType(IndexedStack)).index!;

  group('splash', () {
    shellTest('shows until the first Reconciliation finishes, then the Board', (
      tester,
    ) async {
      await pumpApp(tester, prime: (s) => s.gate = Completer<List<Mission>>());
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Preparing your board…'), findsOneWidget);
      expect(find.byType(QuestlogTabBar), findsNothing);
      expect(find.byType(BoardScreen), findsNothing);
      expect(spy.calls, 1);

      spy.gate!.complete(const <Mission>[]);
      await tester.pump();
      await tester.pump();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(BoardScreen), findsOneWidget);
      expect(find.byType(QuestlogTabBar), findsOneWidget);
      expect(spy.calls, 1);
    });

    shellTest('a failing first Reconciliation still leaves the splash', (
      tester,
    ) async {
      await pumpApp(
        tester,
        prime: (s) => s.failure = const StorageError('disk'),
      );
      await settle(tester);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(BoardScreen), findsOneWidget);
    });
  });

  group('tabs', () {
    shellTest('five tabs, Quests, Missions, Calendar, Notes, then Settings, switch on tap', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);

      expect(
        find.descendant(
          of: find.byType(QuestlogTabBar),
          matching: find.byType(InkWell),
        ),
        findsNWidgets(5),
      );
      expect(find.byKey(_questsTab), findsOneWidget);
      expect(find.byKey(_missionsTab), findsOneWidget);
      expect(find.byKey(_calendarTab), findsOneWidget);
      expect(find.byKey(_notesTab), findsOneWidget);
      expect(find.byKey(_settingsTab), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(QuestlogTabBar),
          matching: find.text('Quests'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(QuestlogTabBar),
          matching: find.text('Missions'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(QuestlogTabBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );
      expect(tabIndex(tester), 0);

      await tester.tap(find.byKey(_missionsTab));
      await settle(tester);
      expect(tabIndex(tester), 1);

      await tester.tap(find.byKey(_calendarTab));
      await settle(tester);
      expect(tabIndex(tester), 2);
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(HeroBar), findsNothing);

      await tester.tap(find.byKey(_notesTab));
      await settle(tester);
      expect(tabIndex(tester), 3);
      expect(find.byType(NotesScreen), findsOneWidget);
      expect(find.byType(HeroBar), findsNothing);

      await tester.tap(find.byKey(_settingsTab));
      await settle(tester);
      expect(tabIndex(tester), 4);
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.tap(find.byKey(_questsTab));
      await settle(tester);
      expect(tabIndex(tester), 0);
      expect(find.byType(SettingsScreen), findsNothing);
    });

    shellTest('tabs have 44 px hit areas and a selected semantic state', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      for (final Key key in <Key>[_questsTab, _missionsTab, _calendarTab, _notesTab, _settingsTab]) {
        final Size size = tester.getSize(find.byKey(key));
        expect(size.height, greaterThanOrEqualTo(44));
        expect(size.width, greaterThanOrEqualTo(44));
      }
      final handle = tester.ensureSemantics();
      final quests = tester.getSemantics(find.byKey(_questsTab));
      final missions = tester.getSemantics(find.byKey(_missionsTab));
      // `toString` is stable enough to read the flags without private API.
      expect(quests.label, 'Quests');
      expect(missions.label, 'Missions');
      expect(tester.getSemantics(find.byKey(_calendarTab)).label, 'Calendar');
      expect(tester.getSemantics(find.byKey(_notesTab)).label, 'Notes');
      expect(tester.getSemantics(find.byKey(_settingsTab)).label, 'Settings');
      expect(
        quests.flagsCollection.isSelected,
        isNot(missions.flagsCollection.isSelected),
      );
      handle.dispose();
    });

    shellTest('Settings is a tab: no back button, no hero bar, no add button', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      await tester.tap(find.byKey(_settingsTab));
      await settle(tester);

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Back'), findsNothing);
      expect(find.byType(HeroBar), findsNothing);
      expect(find.byType(AddFab), findsNothing);
      expect(find.byType(QuestlogTabBar), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsWidgets);
    });

    shellTest('a message raised on the Settings tab is cleared on leaving it', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      await tester.tap(find.byKey(_settingsTab));
      await settle(tester);
      container
          .read(snackbarProvider.notifier)
          .show(const SnackMessage('Rule posted'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Rule posted'), findsOneWidget);

      await tester.tap(find.byKey(_questsTab));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('scroll position', () {
    double offset(WidgetTester tester, Type screen) {
      final Finder scrollable = find.descendant(
        of: find.byType(screen, skipOffstage: false),
        matching: find.byType(Scrollable, skipOffstage: false),
      );
      return tester.state<ScrollableState>(scrollable.first).position.pixels;
    }

    /// Scrolls [screen] on [tab], leaves the tab, comes back, and compares.
    Future<void> checkRetention(
      WidgetTester tester, {
      required Type screen,
      required Key tab,
      required Key other,
      required Future<void> Function() seed,
    }) async {
      await pumpApp(tester, seed: seed);
      await settle(tester);
      await tester.tap(find.byKey(tab));
      await settle(tester);

      final Finder lists = find.descendant(
        of: find.byType(screen),
        matching: find.byType(Scrollable),
      );
      expect(lists, findsWidgets);
      await tester.drag(lists.first, const Offset(0, -600));
      await settle(tester);
      final double before = offset(tester, screen);
      expect(before, greaterThan(0));

      await tester.tap(find.byKey(other));
      await settle(tester);
      await tester.tap(find.byKey(tab));
      await settle(tester);
      expect(offset(tester, screen), before);
    }

    shellTest('the Missions tab keeps its offset across tab switches', (
      tester,
    ) async {
      await checkRetention(
        tester,
        screen: MissionsScreen,
        tab: _missionsTab,
        other: _questsTab,
        seed: () async {
          for (int i = 0; i < 40; i++) {
            await seedMission(db, name: 'Mission $i');
          }
        },
      );
    });

    shellTest('the Settings tab keeps its offset across tab switches', (
      tester,
    ) async {
      await checkRetention(
        tester,
        screen: SettingsScreen,
        tab: _settingsTab,
        other: _questsTab,
        // Enough recurring rules to make the Settings list taller than the screen.
        seed: () async {
          for (int i = 0; i < 12; i++) {
            await db.into(db.recurringRules).insert(
              RecurringRulesCompanion.insert(
                name: 'Rule $i',
                cadence: Cadence.monthly,
                anchorDate: DateTime(2026, 12, 1),
                bonus: MissionBonus.small,
                createdAt: DateTime(2026, 11, 15),
              ),
            );
          }
        },
      );
    });

    shellTest('the Quests tab keeps its offset across tab switches', (
      tester,
    ) async {
      await checkRetention(
        tester,
        screen: BoardScreen,
        tab: _questsTab,
        other: _missionsTab,
        seed: () async {
          for (int i = 0; i < 40; i++) {
            await seedQuest(db, name: 'Quest $i', sortOrder: i + 1);
          }
        },
      );
    });
  });

  group('Reconciliation', () {
    shellTest('runs once at start and not again on rebuilds or tab changes', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      expect(spy.calls, 1);

      await tester.tap(find.byKey(_missionsTab));
      await settle(tester);
      await tester.tap(find.byKey(_questsTab));
      await settle(tester);
      // A resume without leaving the app (control centre) does not count.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      expect(spy.calls, 1);
    });

    shellTest('runs exactly once per return from the background', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      expect(spy.calls, 1);

      goToBackground(tester);
      await settle(tester);
      expect(spy.calls, 1);
      returnToForeground(tester);
      await settle(tester);
      expect(spy.calls, 2);

      // Nothing more until the next return.
      await settle(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(spy.calls, 2);

      goToBackground(tester);
      returnToForeground(tester);
      await settle(tester);
      expect(spy.calls, 3);
    });

    shellTest('a new Board_Day on resume still costs one run, not two', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      expect(spy.calls, 1);

      goToBackground(tester);
      clock.set(DateTime(2026, 11, 17, 12));
      returnToForeground(tester);
      await settle(tester);
      expect(spy.calls, 2);
    });

    shellTest('posted Missions produce a message naming them', (tester) async {
      await pumpApp(
        tester,
        prime: (s) => s.posted = <Mission>[
          _mission(1, 'Weekly review'),
          _mission(2, 'Pay rent'),
        ],
      );
      await settle(tester);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Posted: Weekly review, Pay rent'), findsOneWidget);
    });

    shellTest('the message follows the stored language, not the device one', (
      tester,
    ) async {
      // The device says English; the stored setting says Czech. Reconciliation
      // finishes before the first settings emission, so the message must not
      // use the language the tree runs in at that moment.
      await pumpApp(
        tester,
        seed: () => SettingsService(db).setLanguage(AppLanguage.cs),
        prime: (s) => s.posted = <Mission>[_mission(1, 'Weekly review')],
      );
      await settle(tester);
      expect(find.text('Vyvěšeno: Weekly review'), findsOneWidget);
      expect(find.text('Posted: Weekly review'), findsNothing);
    });

    shellTest('no message when nothing was posted', (tester) async {
      await pumpApp(tester);
      await settle(tester);
      expect(find.byType(SnackBar), findsNothing);
    });

    shellTest('the real service posts a due rule and the shell says so', (
      tester,
    ) async {
      await pumpApp(
        tester,
        realRecurrence: true,
        seed: () async {
          await RecurrenceService(db, clock).create(
            RuleDraft(
              name: 'Weekly review',
              cadence: Cadence.daily,
              requestedAnchor: DateTime(2026, 11, 16),
              bonus: MissionBonus.small,
              quests: const <RuleQuestDraft>[
                RuleQuestDraft(name: 'Plan', difficulty: Difficulty.easy),
              ],
            ),
          );
        },
      );
      await settle(tester);
      await settle(tester);
      expect(find.text('Posted: Weekly review'), findsOneWidget);
    });

    shellTest('messages pushed to snackbarProvider are shown and cleared', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      container
          .read(snackbarProvider.notifier)
          .show(const SnackMessage('Hello from a screen'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Hello from a screen'), findsOneWidget);
      expect(container.read(snackbarProvider), isNull);
    });
  });

  group('storage error', () {
    shellTest('shows the data with a retry banner that reruns Reconciliation', (
      tester,
    ) async {
      await pumpApp(
        tester,
        prime: (s) => s.failure = const StorageError('disk full'),
      );
      await settle(tester);

      expect(spy.calls, 1);
      expect(find.byType(ReconcileBanner), findsOneWidget);
      expect(
        find.text('Recurring missions could not be checked.'),
        findsOneWidget,
      );
      // The rest of the app is still there and usable.
      expect(find.byType(BoardScreen), findsOneWidget);
      await tester.tap(find.byKey(_missionsTab));
      await settle(tester);
      expect(tabIndex(tester), 1);
      expect(find.byType(ReconcileBanner), findsOneWidget);

      spy.failure = null;
      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(spy.calls, 2);
      expect(find.byType(ReconcileBanner), findsNothing);
    });

    shellTest('a failing retry keeps the banner', (tester) async {
      await pumpApp(
        tester,
        prime: (s) => s.failure = const StorageError('disk full'),
      );
      await settle(tester);
      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(spy.calls, 2);
      expect(find.byType(ReconcileBanner), findsOneWidget);
    });

    shellTest('the retry button is at least 44 px', (tester) async {
      await pumpApp(
        tester,
        prime: (s) => s.failure = const StorageError('disk full'),
      );
      await settle(tester);
      final Size size = tester.getSize(find.byType(TextButton));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width, greaterThanOrEqualTo(44));
    });
  });

  group('links', () {
    test('shellTabFromUri reads questlog://<tab> and ignores the rest', () {
      expect(shellTabFromUri(Uri.parse('questlog://calendar')), ShellTab.calendar);
      expect(shellTabFromUri(Uri.parse('questlog://Notes')), ShellTab.notes);
      expect(shellTabFromUri(Uri.parse('questlog:///missions')), ShellTab.missions);
      expect(shellTabFromUri(Uri.parse('questlog://nowhere')), isNull);
      expect(shellTabFromUri(Uri.parse('https://calendar')), isNull);
      expect(shellTabFromUri(Uri.parse('questlog://')), isNull);
    });

    shellTest('a questlog://calendar link opens the Calendar tab, also when it arrives later', (tester) async {
      final StreamController<Uri> links = StreamController<Uri>();
      addTearDown(links.close);
      await pumpApp(tester, links: links.stream);
      await settle(tester);
      expect(find.byType(BoardScreen), findsOneWidget);
      links.add(Uri.parse('questlog://calendar'));
      await settle(tester);
      expect(tabIndex(tester), 2);
      links.add(Uri.parse('questlog://bogus'));
      await settle(tester);
      expect(tabIndex(tester), 2);
    });
  });
}
