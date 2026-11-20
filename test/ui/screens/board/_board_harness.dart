import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/xp_engine.dart';
import 'package:questlog/ui/screens/board/board_screen.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';

/// A [QuestService] that records reorder calls and can be told to fail.
class SpyQuestService extends QuestService {
  SpyQuestService(super.db, super.xp, super.clock);

  final List<List<int>> reorderCalls = <List<int>>[];
  DomainError? reorderError;
  DomainError? completeError;
  DomainError? deleteError;

  @override
  Future<void> reorder(List<int> orderedIds) async {
    reorderCalls.add(List<int>.of(orderedIds));
    final DomainError? error = reorderError;
    if (error != null) throw error;
    return super.reorder(orderedIds);
  }

  @override
  Future<CompleteQuestResult> complete(int id) async {
    final DomainError? error = completeError;
    if (error != null) throw error;
    return super.complete(id);
  }

  @override
  Future<void> delete(int id) async {
    final DomainError? error = deleteError;
    if (error != null) throw error;
    return super.delete(id);
  }
}

/// Board_Screen over an in-memory database, a controllable clock and a spy
/// service, in an English themed app.
class BoardHarness {
  late QuestlogDatabase db;
  late FixedClock clock;
  late SpyQuestService service;

  Future<void> pump(
    WidgetTester tester, {
    DateTime? now,
    bool settleStreams = true,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    db = createTestDatabase();
    clock = FixedClock(now ?? DateTime(2026, 11, 15, 10));
    service = SpyQuestService(db, XpEngine(db), clock);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          questServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          theme: buildTheme(
            palette: QuestlogPalette.guildBoard,
          ),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BoardScreen(),
        ),
      ),
    );
    if (settleStreams) await settle(tester);
  }

  /// Disposes the scope inside the test body so Drift's zero-length timers are
  /// flushed before the framework verifies that none are pending.
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  }

  /// Runs [body] against the database in one transaction on real async.
  ///
  /// One transaction on purpose: with several separate writes, the second waits
  /// for a stream refresh whose continuation sits in the test's fake zone, and
  /// the test deadlocks.
  Future<void> seed(WidgetTester tester, Future<void> Function() body) async {
    await tester.runAsync(() => db.transaction(body));
  }

  /// Gives the Drift streams real time to emit, then rebuilds.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump();
  }

  /// Vertical centres of the named quest cards, top to bottom.
  List<String> order(WidgetTester tester, List<String> names) {
    final List<String> sorted = List<String>.of(names)
      ..sort(
        (String a, String b) => tester
            .getTopLeft(find.text(a))
            .dy
            .compareTo(tester.getTopLeft(find.text(b)).dy),
      );
    return sorted;
  }
}

/// A [testWidgets] that tears the harness down at the end of the test body.
void boardTest(
  BoardHarness h,
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (WidgetTester tester) async {
    await body(tester);
    await h.dispose(tester);
  });
}
