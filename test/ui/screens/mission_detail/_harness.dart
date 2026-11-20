import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/mission_detail/detail_quest_row.dart';
import 'package:questlog/ui/screens/mission_detail/mission_detail_screen.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/cards/check_circle.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';

/// "Now" of every test: 12:00 on the Board_Day of 15 Nov 2026.
final DateTime testNow = DateTime(2026, 11, 15, 12);

/// Text shown by the stand-in for the Missions screen under the detail route.
const String homeLabel = 'missions-home';

class DetailFixture {
  DetailFixture(this.db, this.container, this.clock);

  final QuestlogDatabase db;
  final ProviderContainer container;
  final FixedClock clock;

  MissionServiceHandle get missions => MissionServiceHandle(container);

  /// Quests of [missionId] in manual order.
  Future<List<Quest>> quests(int missionId) async {
    final MissionDetail? detail = await container
        .read(missionServiceProvider)
        .watchDetail(missionId)
        .first;
    return detail?.quests ?? <Quest>[];
  }
}

/// Small facade over the real services for seeding.
class MissionServiceHandle {
  MissionServiceHandle(this._c);

  final ProviderContainer _c;

  Future<int> create(
    String name, {
    MissionBonus bonus = MissionBonus.medium,
    List<(String, Difficulty)> quests = const <(String, Difficulty)>[],
  }) async {
    final Mission mission = await _c
        .read(missionServiceProvider)
        .create(
          MissionDraft(
            name: name,
            bonus: bonus,
            quests: <QuestDraft>[
              for (final (String n, Difficulty d) in quests)
                QuestDraft(name: n, difficulty: d),
            ],
          ),
        );
    return mission.id;
  }
}

Future<void> Function()? _dispose;

/// `testWidgets` that disposes the scope inside the test body: the Board_Day
/// timer must be gone before the framework checks for pending timers.
void detailTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (WidgetTester tester) async {
    _dispose = null;
    try {
      await body(tester);
    } finally {
      await _dispose?.call();
    }
  });
}

/// Runs a real async action (Drift) while the test clock is faked.
Future<T> realAsync<T>(WidgetTester tester, Future<T> Function() action) async {
  final T? value = await tester.runAsync(action);
  return value as T;
}

/// Lets Drift streams deliver, then finishes animations.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 40)),
  );
  await tester.pumpAndSettle();
}

/// Builds the app with a "home" route that opens the detail of the Mission
/// returned by [seed] (called with real async before the first frame).
Future<(DetailFixture, int)> pumpDetail(
  WidgetTester tester, {
  required Future<int> Function(DetailFixture f) seed,
  Locale locale = const Locale('en'),
  List<Override> overrides = const <Override>[],
  QuestlogPalette palette = QuestlogPalette.guildBoard,
}) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final QuestlogDatabase db = createTestDatabase();
  final FixedClock clock = FixedClock(testNow);
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock),
      ...overrides,
    ],
  );
  final DetailFixture f = DetailFixture(db, container, clock);
  _dispose = () async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    container.dispose();
    // Cancelled Drift streams close on zero-length timers of the fake zone.
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  };
  final int missionId = await realAsync(tester, () => seed(f));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildTheme(palette: palette),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) =>
                        MissionDetailScreen(missionId: missionId),
                  ),
                ),
                child: const Text(homeLabel),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text(homeLabel));
  await tester.pump();
  await settle(tester);
  return (f, missionId);
}

/// The check circle of the row showing [questName].
Finder checkOf(String questName) => find.descendant(
  of: find.ancestor(
    of: find.text(questName),
    matching: find.byType(DetailQuestRow),
  ),
  matching: find.byType(CheckCircle),
);

/// Taps the check of [questName] and lets the service and the stream finish.
Future<void> toggle(WidgetTester tester, String questName) async {
  await tester.tap(checkOf(questName));
  await settle(tester);
}

/// Completes the open Quests named [names] through the real service.
Future<void> completeQuests(
  WidgetTester tester,
  DetailFixture f,
  int missionId,
  Iterable<String> names, {
  DateTime? at,
}) async {
  // One transaction: separate writes would queue behind a stream refresh whose
  // continuation sits in the test's fake zone, and the test would deadlock.
  await realAsync(
    tester,
    () => f.db.transaction(() async {
      final List<Quest> all = await f.quests(missionId);
      if (at != null) f.clock.set(at);
      for (final Quest q in all) {
        if (names.contains(q.name)) {
          await f.container.read(questServiceProvider).complete(q.id);
        }
      }
      f.clock.set(testNow);
    }),
  );
  await settle(tester);
}
