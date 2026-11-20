import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/core/calendar/repeat_rule.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/services/calendar/calendar_service.dart';

import '_harness.dart';

void main() {
  addressHistoryTests();
  late CalendarHarness h;

  setUp(() async => h = await CalendarHarness.open());
  tearDown(() => h.close());

  group('create and update', () {
    test('create stores the draft with the Clock time', () async {
      final CalendarEvent e = await h.service.create(
        h.draft(name: '  Porada  ', note: 'Zasedačka', location: 'Brno', type: EventType.work, onBoard: true),
      );
      expect(e.name, 'Porada');
      expect(e.note, 'Zasedačka');
      expect(e.location, 'Brno');
      expect(e.type, EventType.work);
      expect(e.onBoard, isTrue);
      expect(e.createdAt, DateTime(2026, 11, 19, 10));
      expect(e.updatedAt, DateTime(2026, 11, 19, 10));
      expect(e.duration, const Duration(hours: 1));
    });

    test('blank note and location are stored as null', () async {
      final CalendarEvent e = await h.service.create(h.draft(note: '   ', location: ''));
      expect(e.note, isNull);
      expect(e.location, isNull);
    });

    test('an all-day event keeps no minutes', () async {
      final CalendarEvent e = await h.service.create(h.draft(startMinute: null));
      expect(e.allDay, isTrue);
      expect(e.startMinute, isNull);
      expect(e.endMinute, isNull);
    });

    test('update changes the whole series and the update time, not the creation time', () async {
      final CalendarEvent e = await h.service.create(
        h.draft(name: 'Lekce', repeat: const CadenceRepeat(Cadence.weekly)),
      );
      h.clock.set(DateTime(2026, 11, 20, 9));
      final CalendarEvent u = await h.service.update(e.id, h.draft(name: 'Salsa', repeat: const CadenceRepeat(Cadence.weekly)));
      expect(u.name, 'Salsa');
      expect(u.createdAt, e.createdAt);
      expect(u.updatedAt, DateTime(2026, 11, 20, 9));
      final List<EventOccurrence> all = await h.range(d(2026, 11, 1), d(2026, 12, 31));
      expect(all.every((EventOccurrence o) => o.event.name == 'Salsa'), isTrue);
      expect(all.length, greaterThan(5));
    });

    test('update of a missing event throws NotFoundError', () async {
      expect(() => h.service.update(999, h.draft()), throwsA(isA<NotFoundError>()));
    });
  });

  group('validation', () {
    Matcher invalid(String field) =>
        throwsA(isA<ValidationError>().having((ValidationError e) => e.field, 'field', field));

    test('name: empty after trimming and over 80 characters', () async {
      expect(() => h.service.create(h.draft(name: '   ')), invalid('name'));
      expect(() => h.service.create(h.draft(name: 'x' * 81)), invalid('name'));
      await h.service.create(h.draft(name: 'x' * 80));
    });

    test('note over 500 and location over 120 characters', () async {
      expect(() => h.service.create(h.draft(note: 'x' * 501)), invalid('note'));
      expect(() => h.service.create(h.draft(location: 'x' * 121)), invalid('location'));
      await h.service.create(h.draft(note: 'x' * 500, location: 'x' * 120));
    });

    test('end before start, by date and by time on the same date', () async {
      expect(() => h.service.create(h.draft(endDate: d(2026, 11, 18))), invalid('end'));
      expect(() => h.service.create(h.draft(startMinute: 600, endMinute: 540)), invalid('end'));
      await h.service.create(h.draft(startMinute: 600, endMinute: 600));
    });

    test('a later date may end at an earlier time', () async {
      final CalendarEvent e = await h.service.create(
        h.draft(endDate: d(2026, 11, 20), startMinute: 22 * 60, endMinute: 2 * 60),
      );
      expect(e.duration, const Duration(hours: 4));
    });

    test('repeat end before the start date', () async {
      expect(
        () => h.service.create(h.draft(repeat: CadenceRepeat(Cadence.weekly, end: d(2026, 11, 18)))),
        invalid('repeatEnd'),
      );
    });

    test('half a time and minutes out of range', () async {
      final EventDraft half = EventDraft(
        name: 'Půl',
        type: EventType.meeting,
        startDate: d(2026, 11, 19),
        endDate: d(2026, 11, 19),
        startMinute: 600,
        onBoard: false,
      );
      expect(() => h.service.create(half), invalid('time'));
      expect(() => h.service.create(h.draft(startMinute: 1500, endMinute: 1600)), invalid('time'));
    });
  });

  group('lastUsedType', () {
    test('is Meeting when nothing was saved, and built-in events do not count', () async {
      final CalendarHarness seeded = await CalendarHarness.open(keepSeed: true);
      addTearDown(seeded.close);
      expect(await seeded.service.lastUsedType(), EventType.meeting);
    });

    test('is the type of the most recently saved event', () async {
      await h.service.create(h.draft(type: EventType.dance));
      h.clock.advance(const Duration(minutes: 5));
      final CalendarEvent second = await h.service.create(h.draft(type: EventType.lesson));
      expect(await h.service.lastUsedType(), EventType.lesson);
      h.clock.advance(const Duration(minutes: 5));
      final CalendarEvent first = (await h.range(d(2026, 11, 19), d(2026, 11, 19)))
          .map((EventOccurrence o) => o.event)
          .firstWhere((CalendarEvent e) => e.id != second.id);
      await h.service.update(first.id, h.draft(type: EventType.seminar));
      expect(await h.service.lastUsedType(), EventType.seminar);
    });
  });

  group('reads', () {
    test('occurrences are sorted: date, all-day first, start minute', () async {
      await h.service.create(h.draft(name: 'B', startMinute: 12 * 60, endMinute: 13 * 60));
      await h.service.create(h.draft(name: 'A', startMinute: 8 * 60, endMinute: 9 * 60));
      await h.service.create(h.draft(name: 'Celý', startMinute: null));
      await h.service.create(h.draft(name: 'Zítra', date: d(2026, 11, 20)));
      final List<String> names = (await h.range(d(2026, 11, 19), d(2026, 11, 20))).map((o) => o.event.name).toList();
      expect(names, <String>['Celý', 'A', 'B', 'Zítra']);
    });

    test('a multi-day event shows up for every date it touches and for none other', () async {
      await h.service.create(h.draft(name: 'Seminář', date: d(2026, 11, 18), endDate: d(2026, 11, 20)));
      for (final (int day, bool shown) in <(int, bool)>[(17, false), (18, true), (19, true), (20, true), (21, false)]) {
        final List<EventOccurrence> r = await h.range(d(2026, 11, day), d(2026, 11, day));
        expect(r.isNotEmpty, shown, reason: 'day $day');
      }
    });

    test('watchRange re-emits after create, edit and delete', () async {
      final List<List<String>> seen = <List<String>>[];
      final sub = h.service.watchRange(d(2026, 11, 1), d(2026, 11, 30)).listen(
        (List<EventOccurrence> l) => seen.add(l.map((o) => o.event.name).toList()),
      );
      addTearDown(sub.cancel);
      await pumpEventQueue();
      expect(seen.last, isEmpty);
      final CalendarEvent e = await h.service.create(h.draft(name: 'Nová'));
      await pumpEventQueue();
      expect(seen.last, <String>['Nová']);
      await h.service.update(e.id, h.draft(name: 'Upravená'));
      await pumpEventQueue();
      expect(seen.last, <String>['Upravená']);
      await h.service.deleteOccurrence(e.id, d(2026, 11, 19), DeleteScope.all);
      await pumpEventQueue();
      expect(seen.last, isEmpty);
    });

    test('watchEvent follows the row and ends with null', () async {
      final CalendarEvent e = await h.service.create(h.draft(name: 'Sleduj'));
      final List<String?> seen = <String?>[];
      final sub = h.service.watchEvent(e.id).listen((CalendarEvent? v) => seen.add(v?.name));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await h.service.update(e.id, h.draft(name: 'Změněno'));
      await pumpEventQueue();
      await h.service.deleteOccurrence(e.id, d(2026, 11, 19), DeleteScope.all);
      await pumpEventQueue();
      expect(seen, <String?>['Sleduj', 'Změněno', null]);
    });
  });

  group('search', () {
    test('matches name, note and location, ignoring case and diacritics', () async {
      await h.service.create(h.draft(name: 'Řehoř', date: d(2026, 12, 1)));
      await h.service.create(h.draft(name: 'Porada', note: 'Důležitá schůzka', date: d(2026, 12, 2)));
      await h.service.create(h.draft(name: 'Oběd', location: 'Černá růže', date: d(2026, 12, 3)));
      expect((await h.service.search('REHOR')).single.event.name, 'Řehoř');
      expect((await h.service.search('dulezita')).single.event.name, 'Porada');
      expect((await h.service.search('cerna ruze')).single.event.name, 'Oběd');
      expect(await h.service.search('neexistuje'), isEmpty);
      expect(await h.service.search('   '), isEmpty);
    });

    test('upcoming first ascending, then past descending, one result per event', () async {
      await h.service.create(h.draft(name: 'Lekce minulá', date: d(2026, 10, 1)));
      await h.service.create(h.draft(name: 'Lekce starší', date: d(2026, 9, 1)));
      await h.service.create(h.draft(name: 'Lekce později', date: d(2026, 12, 24)));
      await h.service.create(h.draft(name: 'Lekce brzy', date: d(2026, 11, 22)));
      await h.service.create(h.draft(name: 'Lekce týdně', date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly)));
      final List<SearchResult> r = await h.service.search('lekce');
      expect(r.map((SearchResult x) => x.event.name).toList(), <String>[
        'Lekce brzy',
        'Lekce týdně',
        'Lekce později',
        'Lekce minulá',
        'Lekce starší',
      ]);
      expect(r[0].occurrenceDate, d(2026, 11, 22));
      expect(r[1].occurrenceDate, d(2026, 11, 25));
    });

    test('a series that has ended is found by its latest occurrence', () async {
      await h.service.create(h.draft(
        name: 'Kurz',
        date: d(2026, 9, 1),
        repeat: CadenceRepeat(Cadence.weekly, end: d(2026, 9, 30)),
      ));
      final List<SearchResult> r = await h.service.search('kurz');
      expect(r.single.occurrenceDate, d(2026, 9, 29));
    });
  });

  group('deletion and restore', () {
    Future<CalendarEvent> weekly() => h.service.create(
      h.draft(name: 'Salsa', date: d(2026, 11, 4), repeat: const CadenceRepeat(Cadence.weekly)),
    );
    Future<List<DateTime>> starts() async =>
        (await h.range(d(2026, 11, 1), d(2026, 12, 6))).map((o) => o.start).toList();

    test('an event without repeat is deleted whatever the scope', () async {
      final CalendarEvent e = await h.service.create(h.draft());
      await h.service.deleteOccurrence(e.id, d(2026, 11, 19), DeleteScope.onlyThis);
      expect(await h.service.getEvent(e.id), isNull);
    });

    test('only this adds a skipped date', () async {
      final CalendarEvent e = await weekly();
      await h.service.deleteOccurrence(e.id, d(2026, 11, 11), DeleteScope.onlyThis);
      expect(await starts(), <DateTime>[d(2026, 11, 4), d(2026, 11, 18), d(2026, 11, 25), d(2026, 12, 2)]);
      expect(await h.service.getEvent(e.id), isNotNull);
    });

    test('this and following shortens the series to the day before', () async {
      final CalendarEvent e = await weekly();
      await h.service.deleteOccurrence(e.id, d(2026, 11, 18), DeleteScope.thisAndFollowing);
      expect(await starts(), <DateTime>[d(2026, 11, 4), d(2026, 11, 11)]);
      expect((await h.service.getEvent(e.id))!.repeat.end, d(2026, 11, 17));
    });

    test('this and following on the first occurrence deletes the event', () async {
      final CalendarEvent e = await weekly();
      await h.service.deleteOccurrence(e.id, d(2026, 11, 4), DeleteScope.thisAndFollowing);
      expect(await h.service.getEvent(e.id), isNull);
    });

    test('this and following keeps an earlier repeat end', () async {
      final CalendarEvent e = await h.service.create(h.draft(
        date: d(2026, 11, 4),
        repeat: CadenceRepeat(Cadence.weekly, end: d(2026, 11, 12)),
      ));
      await h.service.deleteOccurrence(e.id, d(2026, 11, 25), DeleteScope.thisAndFollowing);
      expect((await h.service.getEvent(e.id))!.repeat.end, d(2026, 11, 12));
    });

    test('all deletes the event with its skipped dates and completions', () async {
      final CalendarEvent e = await weekly();
      await h.service.deleteOccurrence(e.id, d(2026, 11, 11), DeleteScope.onlyThis);
      await h.service.completeOccurrence(e.id, d(2026, 11, 18));
      await h.service.deleteOccurrence(e.id, d(2026, 11, 25), DeleteScope.all);
      expect(await h.db.select(h.db.calendarEvents).get(), isEmpty);
      expect(await h.db.select(h.db.calendarSkippedDates).get(), isEmpty);
      expect(await h.db.select(h.db.calendarCompletions).get(), isEmpty);
    });

    test('restore puts back the event, skipped dates, repeat end and completions', () async {
      final CalendarEvent e = await weekly();
      await h.service.deleteOccurrence(e.id, d(2026, 11, 11), DeleteScope.onlyThis);
      await h.service.completeOccurrence(e.id, d(2026, 11, 18));
      final before = await starts();
      for (final DeleteScope scope in DeleteScope.values) {
        final snapshot = await h.service.deleteOccurrence(e.id, d(2026, 11, 25), scope);
        await h.service.restore(snapshot);
        expect(await starts(), before, reason: scope.name);
        expect((await h.service.getEvent(e.id))!.repeat.end, isNull, reason: scope.name);
        expect(await h.db.select(h.db.calendarCompletions).get(), hasLength(1), reason: scope.name);
        expect(await h.db.select(h.db.calendarSkippedDates).get(), hasLength(1), reason: scope.name);
      }
    });

    test('deleting a missing event throws NotFoundError', () {
      expect(() => h.service.deleteOccurrence(42, d(2026, 11, 19), DeleteScope.all), throwsA(isA<NotFoundError>()));
    });
  });
}

void addressHistoryTests() {
  late CalendarHarness h;

  setUp(() async => h = await CalendarHarness.open());
  tearDown(() => h.close());

  group('address history', () {
    test('a saved address is suggested, newest first, once per spelling', () async {
      await h.service.create(h.draft(location: 'Brno, Česká 1'));
      h.clock.advance(const Duration(hours: 1));
      await h.service.create(h.draft(location: 'Praha, Dlouhá 2'));
      h.clock.advance(const Duration(hours: 1));
      await h.service.create(h.draft(location: '  brno, česká 1 '));
      expect(await h.service.suggestAddresses(''), <String>['brno, česká 1', 'Praha, Dlouhá 2']);
    });

    test('suggestions match ignoring case and diacritics, never the typed text itself', () async {
      await h.service.create(h.draft(location: 'Řehořova 5, Praha'));
      expect(await h.service.suggestAddresses('rehor'), <String>['Řehořova 5, Praha']);
      expect(await h.service.suggestAddresses('xyz'), isEmpty);
      expect(await h.service.suggestAddresses('řehořova 5, praha'), isEmpty);
    });

    test('at most the limit is returned', () async {
      for (int i = 0; i < 7; i++) {
        h.clock.advance(const Duration(minutes: 1));
        await h.service.create(h.draft(location: 'Street $i'));
      }
      final List<String> found = await h.service.suggestAddresses('');
      expect(found, hasLength(5));
      expect(found.first, 'Street 6');
    });

    test('an edit remembers the new address; a blank one remembers nothing', () async {
      final CalendarEvent e = await h.service.create(h.draft(location: 'A'));
      await h.service.update(e.id, h.draft(location: 'B'));
      await h.service.create(h.draft(location: '   '));
      expect((await h.service.suggestAddresses('')).toSet(), <String>{'A', 'B'});
    });

    test('an address expires 30 days after its last use, and using it again renews it', () async {
      await h.service.create(h.draft(location: 'Old'));
      await h.service.create(h.draft(location: 'Renewed'));
      h.clock.advance(const Duration(days: 29));
      await h.service.create(h.draft(location: 'Renewed'));
      h.clock.advance(const Duration(days: 1, minutes: 1));
      expect(await h.service.suggestAddresses(''), <String>['Renewed']);
      await h.service.purgeExpiredAddresses();
      expect(await h.db.select(h.db.calendarAddresses).get(), hasLength(1));
    });

    test('deleting an event keeps its address and forgetting it keeps the event', () async {
      final CalendarEvent e = await h.service.create(h.draft(location: 'Brno'));
      await h.service.deleteOccurrence(e.id, e.startDate, DeleteScope.all);
      expect(await h.service.suggestAddresses(''), <String>['Brno']);
      final CalendarEvent kept = await h.service.create(h.draft(location: 'Plzeň'));
      h.clock.advance(const Duration(days: 31));
      await h.service.purgeExpiredAddresses();
      expect(await h.service.suggestAddresses(''), isEmpty);
      expect((await h.service.getEvent(kept.id))!.location, 'Plzeň');
    });
  });
}
