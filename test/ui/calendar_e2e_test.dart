import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/l10n/app_localizations_en.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:questlog/ui/widgets/calendar/event_task_card.dart';

import 'a11y/_a11y_harness.dart';

/// A calendar day with Questlog: a new birthday goes onto the Board, is
/// completed for XP, and is deleted and brought back.
void main() {
  final AppLocalizationsEn en = AppLocalizationsEn();

  a11yTest('create an event, do it on the Board, delete it and undo', (tester, track) async {
    final A11yEnv env = await A11yEnv.pump(tester, Subject.shell);
    track(env);
    final ProviderContainer container = ProviderScope.containerOf(tester.element(find.byType(QuestlogTabBar)));

    // A stream read is a chain of queries on timers in the fake zone, so settle
    // a few times (a loaded machine needs the extra rounds).
    Future<void> tap(Finder finder) async {
      await tester.tap(finder);
      for (int i = 0; i < 5; i++) {
        await env.settle();
      }
    }

    // The seeded 17 November public holiday exists but is no Event_Task.
    await tap(find.byKey(const ValueKey<ShellTab>(ShellTab.calendar)));
    expect(find.text('Den boje za svobodu a demokracii'), findsOneWidget);
    expect(find.byType(EventTaskCard), findsNothing);

    // Create a birthday on today (15 November): it is On_Board by default.
    await tap(find.byKey(const ValueKey<String>('add-fab')));
    await tester.enterText(find.byKey(const ValueKey<String>('form-name')), 'Popřát Evě');
    await tester.pump();
    await tap(find.text(en.calendar_typeBirthday));
    await tap(find.byKey(const ValueKey<String>('form-save')));
    expect(find.text(en.calendar_formCreateTitle), findsNothing);
    expect(find.text('Popřát Evě'), findsWidgets);

    // On the Board it is a task worth 25 XP (a timed one-hour event); do it.
    await tap(find.byKey(const ValueKey<ShellTab>(ShellTab.quests)));
    expect(find.byType(EventTaskCard), findsOneWidget);
    await tap(find.bySemanticsLabel(en.a11y_completeEvent('Popřát Evě')));
    expect(await tester.runAsync(() => container.read(xpEngineProvider).readTotal()), 25);

    // Delete it from its detail and bring it back with Undo.
    await tap(find.byKey(const ValueKey<ShellTab>(ShellTab.calendar)));
    await tap(find.byKey(const ValueKey<String>('day-2026-11-15')));
    await tap(find.text('Popřát Evě').last);
    await tap(find.byKey(const ValueKey<String>('detail-menu')));
    await tap(find.text(en.common_delete));
    await tap(find.text(en.common_delete).last);
    expect(find.text(en.calendar_deleted('Popřát Evě')), findsOneWidget);
    expect(await tester.runAsync(() => container.read(xpEngineProvider).readTotal()), 25);
    await tap(find.text(en.calendar_undo));
    expect(find.text('Popřát Evě'), findsWidgets);
    expect(await tester.runAsync(() => container.read(xpEngineProvider).readTotal()), 25);
  });
}
