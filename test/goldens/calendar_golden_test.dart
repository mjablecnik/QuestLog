import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../ui/a11y/_a11y_harness.dart';

/// Golden comparison of the calendar screens and of the Board with Event_Tasks,
/// in Czech and in both themes, on a 390x844 screen. Everything renders with the
/// bundled Figtree over the seeded week of the accessibility harness.
///
/// Regenerate after an intended visual change with
/// `flutter test --update-goldens test/goldens/calendar_golden_test.dart`.
void main() {
  const Map<String, QuestlogPalette> themes = <String, QuestlogPalette>{
    'dark': QuestlogPalette.guildBoard,
    'light': QuestlogPalette.daylight,
  };

  Future<A11yEnv> open(
    WidgetTester tester,
    void Function(A11yEnv) track,
    Subject subject,
    QuestlogPalette palette,
  ) async {
    final A11yEnv env = await A11yEnv.pump(
      tester,
      subject,
      palette: palette,
      locale: const Locale('cs'),
      calendarEvents: true,
    );
    track(env);
    return env;
  }

  Future<void> tapKey(WidgetTester tester, A11yEnv env, String key) async {
    await tester.tap(find.byKey(ValueKey<String>(key)));
    await env.settle();
  }

  for (final MapEntry<String, QuestlogPalette> theme in themes.entries) {
    a11yTest('the month in the ${theme.key} theme', (tester, track) async {
      await open(tester, track, Subject.calendar, theme.value);
      await expectLater(
        find.byKey(A11yEnv.boundaryKey),
        matchesGoldenFile('calendar_month_${theme.key}.png'),
      );
    });

    a11yTest('the Board with Event_Tasks in the ${theme.key} theme', (tester, track) async {
      await open(tester, track, Subject.board, theme.value);
      await expectLater(
        find.byKey(A11yEnv.boundaryKey),
        matchesGoldenFile('board_events_${theme.key}.png'),
      );
    });
  }

  a11yTest('the day sheet in the dark theme', (tester, track) async {
    final A11yEnv env = await open(tester, track, Subject.calendar, themes['dark']!);
    await tapKey(tester, env, 'day-2026-11-18');
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('calendar_day_dark.png'));
  });

  a11yTest('the event detail in the light theme', (tester, track) async {
    final A11yEnv env = await open(tester, track, Subject.calendar, themes['light']!);
    await tapKey(tester, env, 'day-2026-11-18');
    await tester.tap(find.text('Seminář TypeScript'));
    await env.settle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('calendar_detail_light.png'));
  });

  a11yTest('the event form in the dark theme', (tester, track) async {
    final A11yEnv env = await open(tester, track, Subject.calendar, themes['dark']!);
    await tapKey(tester, env, 'day-2026-11-18');
    await tapKey(tester, env, 'day-add');
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('calendar_form_dark.png'));
  });
}
