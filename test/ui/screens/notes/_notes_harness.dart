import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/services/notes/notes_providers.dart';
import 'package:questlog/services/notes/notes_service.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';

/// An English themed app around a notes screen on a 390 by 844 phone, over an
/// in-memory database with a controllable clock.
class NotesUiHarness {
  late QuestlogDatabase db;
  late FixedClock clock;

  NotesService get service => NotesService(db, clock);

  Future<void> pump(
    WidgetTester tester, {
    required Widget home,
    DateTime? now,
    Brightness brightness = Brightness.dark,
    double? textScale,
    Locale locale = const Locale('en'),
    Future<void> Function(NotesService service, FixedClock clock)? seed,
    NotesService Function(QuestlogDatabase db, FixedClock clock)? serviceBuilder,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (textScale != null) {
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }
    db = createTestDatabase();
    clock = FixedClock(now ?? DateTime(2026, 11, 19, 10));
    if (seed != null) await tester.runAsync(() => seed(service, clock));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          if (serviceBuilder != null) notesServiceProvider.overrideWithValue(serviceBuilder(db, clock)),
        ],
        child: MaterialApp(
          theme: buildTheme(
            palette: brightness == Brightness.dark ? QuestlogPalette.guildBoard : QuestlogPalette.daylight,
          ),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await settle(tester);
  }

  Future<NoteNode> folder(WidgetTester tester, String name, {int? parent}) async {
    final NoteNode? node = await tester.runAsync(() => service.createFolder(parentId: parent, name: name));
    await settle(tester);
    return node!;
  }

  Future<NoteNode> note(WidgetTester tester, String body, {int? parent, String name = 'Untitled'}) async {
    NoteNode? node;
    await tester.runAsync(() async {
      node = await service.saveBody(parentId: parent, body: body, untitledName: name);
    });
    await settle(tester);
    return node!;
  }

  Future<void> run(WidgetTester tester, Future<void> Function() action) async {
    await tester.runAsync(action);
    await settle(tester);
  }

  /// Gives the Drift streams real time to emit, then rebuilds, until the tree
  /// has not changed for a few rounds.
  Future<void> settle(WidgetTester tester) async {
    int stable = 0;
    int last = -1;
    for (int i = 0; i < 80 && stable < 5; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        await db.customSelect('SELECT 1').get();
      });
      await tester.pump(const Duration(milliseconds: 50));
      final int now = tester.allWidgets.length * 31 + tester.allElements.length;
      stable = now == last ? stable + 1 : 0;
      last = now;
    }
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Disposes the scope inside the test body so Drift's zero-length timers are
  /// flushed before the framework verifies that none are pending.
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  }
}

/// A [testWidgets] that tears the harness down at the end of the test body.
void notesTest(NotesUiHarness h, String description, Future<void> Function(WidgetTester tester) body) {
  testWidgets(description, (WidgetTester tester) async {
    await body(tester);
    await h.dispose(tester);
  });
}
