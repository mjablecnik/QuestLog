import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/ui/screens/calendar/calendar_screen.dart';
import 'package:questlog/ui/screens/calendar/event_form_screen.dart';
import 'package:questlog/ui/widgets/calendar/event_chip.dart';

import '_calendar_harness.dart';

void main() {
  final CalendarUiHarness h = CalendarUiHarness();

  Future<void> openCreate(WidgetTester tester, {DateTime? now, DateTime? date}) async {
    await h.pump(
      tester,
      now: now,
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const ValueKey<String>('open'),
              onPressed: () => showEventForm(context, presetDate: date),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('open')));
    await h.settle(tester);
  }

  Future<void> openEdit(WidgetTester tester, CalendarEvent event) async {
    final BuildContext context = tester.element(find.byKey(const ValueKey<String>('open')));
    showEventForm(context, editing: event);
    await h.settle(tester);
  }

  // Rows below the fold are built but count as off screen for the finders.
  Finder xp() => find.byKey(const ValueKey<String>('form-xp'), skipOffstage: false);
  Finder key(String k) => find.byKey(ValueKey<String>(k), skipOffstage: false);

  Finder t(String text) => find.text(text, skipOffstage: false);

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
  }

  Finder name() => find.byKey(const ValueKey<String>('form-name'));
  Finder save() => find.byKey(const ValueKey<String>('form-save'));

  bool saveEnabled(WidgetTester tester) => tester.widget<FilledButton>(save()).onPressed != null;

  calendarTest(h, 'EventFormScreen: save is disabled until the name has text', (tester) async {
    await openCreate(tester);
    expect(find.text(en.calendar_formCreateTitle), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
    await tester.enterText(name(), '   ');
    await tester.pump();
    expect(saveEnabled(tester), isFalse);
    await tester.enterText(name(), 'Porada');
    await tester.pump();
    expect(saveEnabled(tester), isTrue);
  });

  calendarTest(h, 'a new event starts on the next full hour, lasts one hour, with the last used type', (tester) async {
    await openCreate(tester, now: DateTime(2026, 11, 19, 10, 20), date: d(2026, 11, 19));
    await h.add(tester, name: 'Dřívější', type: EventType.lesson, date: d(2026, 11, 1));
    // The form opened before the event existed, so reopen it.
    await tester.tap(find.byKey(const ValueKey<String>('form-back')));
    await h.settle(tester);
    await tester.tap(find.byKey(const ValueKey<String>('open')));
    await h.settle(tester);
    expect(find.text('11:00'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);
    expect(find.text('Thu, Nov 19, 2026'), findsNWidgets(2));
    final Semantics selected = tester.widget<Semantics>(find.bySemanticsLabel(en.calendar_typeLesson).first.evaluate().isEmpty
        ? find.byType(Semantics).first
        : find.byType(Semantics).first);
    expect(selected, isNotNull);
  });

  calendarTest(h, 'a new event on another day starts at 09:00; at 23:xx on today it starts at 23:00 and ends after midnight', (tester) async {
    await openCreate(tester, now: DateTime(2026, 11, 19, 10), date: d(2026, 11, 25));
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
  });

  calendarTest(h, 'late in the evening the one-hour end falls on the next day', (tester) async {
    await openCreate(tester, now: DateTime(2026, 11, 19, 23, 30), date: d(2026, 11, 19));
    expect(find.text('23:00'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('Fri, Nov 20, 2026'), findsOneWidget);
  });

  calendarTest(h, 'the board switch follows the type until the user touches it, and the XP line follows the values', (tester) async {
    await openCreate(tester, now: DateTime(2026, 11, 19, 10), date: d(2026, 11, 19));
    expect(xp(), findsOneWidget);
    expect(find.text(en.calendar_onBoardXp(25), skipOffstage: false), findsOneWidget);

    await reveal(tester, t(en.calendar_typePublicHoliday));
    await tester.tap(t(en.calendar_typePublicHoliday));
    await tester.pump();
    expect(xp(), findsNothing);

    await reveal(tester, t(en.calendar_typeBirthday));
    await tester.tap(t(en.calendar_typeBirthday));
    await tester.pump();
    expect(xp(), findsOneWidget);

    // All-day: the XP comes from the type (10 for a birthday).
    await reveal(tester, find.text(en.calendar_allDay));
    await tester.tap(t(en.calendar_allDay));
    await tester.pump();
    expect(find.text(en.calendar_onBoardXp(10), skipOffstage: false), findsOneWidget);

    // Once the switch is touched, a type change leaves it alone.
    await tester.tap(t(en.calendar_onBoard));
    await tester.pump();
    expect(xp(), findsNothing);
    await reveal(tester, t(en.calendar_typeMeeting));
    await tester.tap(t(en.calendar_typeMeeting));
    await tester.pump();
    expect(xp(), findsNothing);
  });

  calendarTest(h, 'the all-day switch hides the times and keeps the dates', (tester) async {
    await openCreate(tester, now: DateTime(2026, 11, 19, 10), date: d(2026, 11, 19));
    expect(find.text('11:00'), findsOneWidget);
    await reveal(tester, find.text(en.calendar_allDay));
    await tester.tap(t(en.calendar_allDay));
    await tester.pump();
    expect(find.text('11:00'), findsNothing);
    expect(find.text('12:00'), findsNothing);
    expect(find.text('Thu, Nov 19, 2026'), findsNWidgets(2));
  });

  calendarTest(h, 'the repeat choices do not offer the built-in rules', (tester) async {
    await openCreate(tester);
    await reveal(tester, key('form-repeat'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('form-repeat')));
    await h.settle(tester);
    for (final String label in <String>[
      en.calendar_repeatNever,
      en.calendar_repeatDaily,
      en.calendar_repeatWeekly,
      en.calendar_repeatMonthly,
      en.calendar_repeatYearly,
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    expect(find.text(en.calendar_repeatEaster), findsNothing);
    expect(find.text(en.calendar_repeatNth), findsNothing);
  });

  calendarTest(h, 'saving creates the event and closes the form', (tester) async {
    await openCreate(tester, now: DateTime(2026, 11, 19, 10), date: d(2026, 11, 19));
    await tester.enterText(name(), 'Porada');
    await reveal(tester, key('form-location'));
    await tester.enterText(find.byKey(const ValueKey<String>('form-location')), 'Brno');
    await tester.pump();
    await tester.tap(save());
    await h.settle(tester);
    expect(find.text(en.calendar_formCreateTitle), findsNothing);
    final List<EventOccurrence> all = (await tester.runAsync(() => h.service.occurrencesIn(d(2026, 11, 19), d(2026, 11, 19))))!;
    expect(all.single.event.name, 'Porada');
    expect(all.single.event.location, 'Brno');
    expect(all.single.event.onBoard, isTrue);
    expect(all.single.event.startMinute, 11 * 60);
  });

  calendarTest(h, 'a name over 80 characters is rejected with an inline error', (tester) async {
    await openCreate(tester);
    await tester.enterText(name(), 'x' * 81);
    await tester.pump();
    await tester.tap(save());
    await h.settle(tester);
    expect(find.text(en.calendar_errorNameLong), findsOneWidget);
    expect(find.text(en.calendar_formCreateTitle), findsOneWidget);
  });

  calendarTest(h, 'an end before the start shows an inline error and does not save', (tester) async {
    await h.pump(
      tester,
      home: Builder(
        builder: (BuildContext context) => TextButton(
          key: const ValueKey<String>('open'),
          onPressed: () => showEventForm(
            context,
            prefill: EventDraft(
              name: 'Obráceně',
              type: EventType.meeting,
              startDate: d(2026, 11, 19),
              endDate: d(2026, 11, 19),
              startMinute: 12 * 60,
              endMinute: 11 * 60,
              onBoard: false,
            ),
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('open')));
    await h.settle(tester);
    expect(find.text(en.calendar_errorEnd), findsOneWidget);
    await tester.tap(save());
    await h.settle(tester);
    expect(find.text(en.calendar_formCreateTitle), findsOneWidget);
    final List<EventOccurrence> all = (await tester.runAsync(() => h.service.occurrencesIn(d(2026, 11, 1), d(2026, 11, 30))))!;
    expect(all, isEmpty);
  });

  calendarTest(h, 'the back button asks before discarding changes and not when nothing changed', (tester) async {
    await openCreate(tester);
    await tester.tap(find.byKey(const ValueKey<String>('form-back')));
    await h.settle(tester);
    expect(find.text(en.calendar_formCreateTitle), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('open')));
    await h.settle(tester);
    await tester.enterText(name(), 'Rozepsané');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('form-back')));
    await h.settle(tester);
    expect(find.text(en.sheet_discardTitle), findsOneWidget);
    await tester.tap(find.text(en.sheet_keepEditing));
    await h.settle(tester);
    expect(find.text(en.calendar_formCreateTitle), findsOneWidget);
    expect(find.text('Rozepsané'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('form-back')));
    await h.settle(tester);
    await tester.tap(find.text(en.common_discard));
    await h.settle(tester);
    expect(find.text(en.calendar_formCreateTitle), findsNothing);
  });

  group('editing', () {
    calendarTest(h, 'shows the stored values and saving changes the event', (tester) async {
      await openCreate(tester);
      await tester.tap(find.byKey(const ValueKey<String>('form-back')));
      await h.settle(tester);
      final CalendarEvent e = await h.add(tester, name: 'Stará', type: EventType.work, note: 'Poznámka', location: 'Praha');
      await openEdit(tester, e);
      expect(find.text(en.calendar_formEditTitle), findsOneWidget);
      expect(find.text('Stará'), findsOneWidget);
      expect(find.text('Poznámka'), findsOneWidget);
      expect(find.text('Praha', skipOffstage: false), findsOneWidget);
      expect(find.text('18:00'), findsOneWidget);
      await tester.enterText(name(), 'Nová');
      await tester.pump();
      await tester.tap(save());
      await h.settle(tester);
      final CalendarEvent? stored = await tester.runAsync<CalendarEvent?>(() => h.service.getEvent(e.id));
      expect(stored!.name, 'Nová');
      expect(stored.type, EventType.work);
    });

    calendarTest(h, 'a built-in Easter rule is shown and kept', (tester) async {
      await openCreate(tester);
      await tester.tap(find.byKey(const ValueKey<String>('form-back')));
      await h.settle(tester);
      final CalendarEvent e = await h.add(
        tester,
        name: 'Velikonoce',
        type: EventType.notableDay,
        date: d(2000, 1, 1),
        startMinute: null,
        repeat: const EasterRelative(0),
      );
      await openEdit(tester, e);
      await reveal(tester, key('form-repeat'));
      expect(find.text(en.calendar_repeatEaster, skipOffstage: false), findsWidgets);
      await reveal(tester, key('form-name'));
      await tester.enterText(name(), 'Velikonoční neděle');
      await tester.pump();
      await tester.tap(save());
      await h.settle(tester);
      final CalendarEvent? stored = await tester.runAsync<CalendarEvent?>(() => h.service.getEvent(e.id));
      expect(stored!.repeat, isA<EasterRelative>());
      expect(stored.name, 'Velikonoční neděle');
    });

    calendarTest(h, 'the delete button removes the event after a confirmation and offers undo', (tester) async {
      await openCreate(tester);
      await tester.tap(find.byKey(const ValueKey<String>('form-back')));
      await h.settle(tester);
      final CalendarEvent e = await h.add(tester, name: 'Smaž mě');
      await openEdit(tester, e);
      await reveal(tester, key('form-delete'));
      await tester.tap(find.byKey(const ValueKey<String>('form-delete')));
      await h.settle(tester);
      expect(find.text(en.calendar_deleteTitle), findsOneWidget);
      await tester.tap(find.text(en.common_delete).last);
      await h.settle(tester);
      expect(await tester.runAsync<CalendarEvent?>(() => h.service.getEvent(e.id)), isNull);
      expect(find.text(en.calendar_formEditTitle), findsNothing);
      expect(find.text(en.calendar_undo), findsOneWidget);
      await tester.tap(find.text(en.calendar_undo));
      await h.settle(tester);
      expect(await tester.runAsync<CalendarEvent?>(() => h.service.getEvent(e.id)), isNotNull);
    });
  });

  calendarTest(h, 'tapping the add button of the month opens the form with the selected day', (tester) async {
    await h.pump(tester, home: const CalendarScreen(), now: DateTime(2026, 11, 19, 10));
    await tester.tap(find.byKey(const ValueKey<String>('day-2026-11-24')));
    await h.settle(tester);
    await tester.tap(find.byKey(const ValueKey<String>('day-close')));
    await h.settle(tester);
    await tester.tap(find.byKey(const ValueKey<String>('add-fab')));
    await h.settle(tester);
    expect(find.text(en.calendar_formCreateTitle), findsOneWidget);
    expect(find.text('Tue, Nov 24, 2026'), findsNWidgets(2));
    expect(find.byType(EventChip), findsNothing);
  });

  group('address suggestions', () {
    Finder suggestion(String a) => find.byKey(ValueKey<String>('address-suggestion-$a'), skipOffstage: false);

    Future<void> seed(WidgetTester tester, List<String> addresses) async {
      for (final String a in addresses) {
        await tester.runAsync(() async {
          await h.service.create(
            EventDraft(
              name: 'E',
              location: a,
              type: EventType.meeting,
              startDate: d(2026, 11, 19),
              endDate: d(2026, 11, 19),
              repeat: const NoRepeat(),
              onBoard: false,
            ),
          );
          h.clock.advance(const Duration(minutes: 1));
        });
      }
    }

    Future<void> settleLookup(WidgetTester tester) async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    calendarTest(h, 'focus shows the remembered addresses, typing narrows them, a tap fills the field', (tester) async {
      await openCreate(tester);
      await seed(tester, <String>['Brno, Česká 1', 'Praha, Dlouhá 2']);
      await reveal(tester, key('form-location'));
      expect(suggestion('Brno, Česká 1'), findsNothing);
      await tester.tap(key('form-location'));
      await settleLookup(tester);
      expect(suggestion('Brno, Česká 1'), findsOneWidget);
      expect(suggestion('Praha, Dlouhá 2'), findsOneWidget);
      await tester.enterText(key('form-location'), 'dlou');
      await settleLookup(tester);
      expect(suggestion('Brno, Česká 1'), findsNothing);
      expect(tester.getSize(suggestion('Praha, Dlouhá 2')).height, greaterThanOrEqualTo(44));
      await tester.tap(suggestion('Praha, Dlouhá 2'));
      await settleLookup(tester);
      expect(tester.widget<TextField>(find.descendant(of: key('form-location'), matching: find.byType(TextField))).controller!.text, 'Praha, Dlouhá 2');
      expect(suggestion('Praha, Dlouhá 2'), findsNothing);
    });

    calendarTest(h, 'nothing shows without a match or without focus', (tester) async {
      await openCreate(tester);
      await seed(tester, <String>['Brno']);
      await reveal(tester, key('form-location'));
      await tester.tap(key('form-location'));
      await tester.enterText(key('form-location'), 'zzz');
      await settleLookup(tester);
      expect(suggestion('Brno'), findsNothing);
    });
  });
}
