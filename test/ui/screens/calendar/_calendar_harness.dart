import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/data/calendar/calendar_filter_store.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/calendar/calendar_providers.dart';
import 'package:questlog/services/calendar/calendar_service.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import 'package:questlog/services/xp_engine.dart' as xp_engine;

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';

DateTime d(int y, int m, int day) => DateTime(y, m, day);

final AppLocalizationsEn en = AppLocalizationsEn();

/// An English themed app around [home] on a 390 by 844 phone, over an
/// in-memory database with a controllable clock. The built-in holidays are
/// removed unless [keepSeed] is true, so a test sees only its own events.
class CalendarUiHarness {
  late QuestlogDatabase db;
  late FixedClock clock;
  late MemoryCalendarFilterStore filterStore;

  CalendarService get service => CalendarService(db, xp_engine.XpEngine(db), clock);

  Future<void> pump(
    WidgetTester tester, {
    required Widget home,
    DateTime? now,
    bool keepSeed = false,
    Set<EventType>? filter,
    Brightness brightness = Brightness.dark,
    double? textScale,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (textScale != null) {
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }
    db = createTestDatabase();
    if (!keepSeed) await tester.runAsync(() => db.delete(db.calendarEvents).go());
    clock = FixedClock(now ?? DateTime(2026, 11, 19, 10));
    filterStore = MemoryCalendarFilterStore(filter);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
          calendarFilterStoreProvider.overrideWithValue(filterStore),
          initialCalendarFilterProvider.overrideWithValue(filter ?? EventType.values.toSet()),
        ],
        child: MaterialApp(
          theme: buildTheme(
            palette: brightness == Brightness.dark ? QuestlogPalette.guildBoard : QuestlogPalette.daylight,
          ),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await settle(tester);
  }

  /// Creates an event through the service on real async time.
  Future<CalendarEvent> add(
    WidgetTester tester, {
    String name = 'Event',
    EventType type = EventType.meeting,
    DateTime? date,
    DateTime? endDate,
    int? startMinute = 18 * 60,
    int? endMinute = 19 * 60,
    RepeatRule repeat = const NoRepeat(),
    bool onBoard = false,
    String? note,
    String? location,
  }) async {
    final DateTime day = date ?? d(2026, 11, 19);
    final CalendarEvent? event = await tester.runAsync(
      () => service.create(
        EventDraft(
          name: name,
          note: note,
          location: location,
          type: type,
          startDate: day,
          endDate: endDate ?? day,
          startMinute: startMinute,
          endMinute: startMinute == null ? null : endMinute,
          repeat: repeat,
          onBoard: onBoard,
        ),
      ),
    );
    await settle(tester);
    return event!;
  }

  /// Gives the Drift streams real time to emit, then rebuilds.
  ///
  /// A stream read is a chain of queries, each continuing on a timer in the
  /// test's fake zone, so real waits alternate with pumps until the widget tree
  /// has not changed for a few rounds (a loaded machine needs more rounds).
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
void calendarTest(
  CalendarUiHarness h,
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (WidgetTester tester) async {
    await body(tester);
    await h.dispose(tester);
  });
}
