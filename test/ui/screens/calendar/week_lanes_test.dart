import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/data/calendar/calendar_models.dart';
import 'package:questlog/ui/screens/calendar/week_lanes.dart';

/// Monday 16 November 2026.
final DateTime monday = DateTime(2026, 11, 16);

DateTime day(int offset, [DateTime? from]) {
  final DateTime base = from ?? monday;
  return DateTime(base.year, base.month, base.day + offset);
}

int _nextId = 1;

/// An occurrence that starts [startOffset] days after [from] (default [monday]) and lasts [span] days more.
EventOccurrence occ(
  int startOffset,
  int span, {
  String name = 'E',
  int? startMinute,
  DateTime? from,
}) {
  final DateTime start = day(startOffset, from);
  final DateTime end = day(startOffset + span, from);
  final CalendarEvent event = CalendarEvent(
    id: _nextId++,
    name: name,
    type: EventType.meeting,
    startDate: start,
    endDate: end,
    startMinute: startMinute,
    endMinute: startMinute == null ? null : (span == 0 ? startMinute + 60 : 600),
    onBoard: false,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
  return EventOccurrence(event: event, start: start);
}

void main() {
  group('layoutWeek', () {
    test('an event on one day is one segment of one column in lane 0', () {
      final List<WeekSegment> s = layoutWeek(<EventOccurrence>[occ(2, 0)], monday);
      expect(s, hasLength(1));
      expect((s.single.startColumn, s.single.endColumn, s.single.lane), (2, 2, 0));
      expect(s.single.continuesBefore, isFalse);
      expect(s.single.continuesAfter, isFalse);
    });

    test('a weekend seminar covers two columns', () {
      final List<WeekSegment> s = layoutWeek(<EventOccurrence>[occ(5, 1, name: 'Seminář')], monday);
      expect((s.single.startColumn, s.single.endColumn), (5, 6));
      expect(s.single.covers(5), isTrue);
      expect(s.single.covers(4), isFalse);
    });

    test('an event that runs over the end of the week is cut there and goes on', () {
      final EventOccurrence e = occ(4, 4); // Friday to Tuesday
      final WeekSegment first = layoutWeek(<EventOccurrence>[e], monday).single;
      expect((first.startColumn, first.endColumn, first.continuesBefore, first.continuesAfter), (4, 6, false, true));
      final WeekSegment second = layoutWeek(<EventOccurrence>[e], day(7)).single;
      expect((second.startColumn, second.endColumn, second.continuesBefore, second.continuesAfter), (0, 1, true, false));
    });

    test('an event from an earlier week that ends in this one continues from before', () {
      final WeekSegment s = layoutWeek(<EventOccurrence>[occ(-3, 5)], monday).single; // Friday to Wednesday
      expect((s.startColumn, s.endColumn, s.continuesBefore, s.continuesAfter), (0, 2, true, false));
    });

    test('an event that spans the whole week from both sides fills all seven columns', () {
      final WeekSegment s = layoutWeek(<EventOccurrence>[occ(-4, 20)], monday).single;
      expect((s.startColumn, s.endColumn, s.continuesBefore, s.continuesAfter), (0, 6, true, true));
    });

    test('an event outside the week gives no segment', () {
      expect(layoutWeek(<EventOccurrence>[occ(-5, 4), occ(7, 2)], monday), isEmpty);
    });

    test('events that overlap get different lanes, events that do not share lane 0', () {
      final List<WeekSegment> s = layoutWeek(
        <EventOccurrence>[occ(0, 2, name: 'A'), occ(1, 0, name: 'B'), occ(4, 0, name: 'C')],
        monday,
      );
      int laneOf(String n) => s.firstWhere((WeekSegment x) => x.occurrence.event.name == n).lane;
      expect(laneOf('A'), 0);
      expect(laneOf('B'), 1);
      expect(laneOf('C'), 0);
    });

    test('lanes go to longer events first, then all-day before timed, then by time, then by name', () {
      final List<WeekSegment> s = layoutWeek(
        <EventOccurrence>[
          occ(1, 0, name: 'Zebra', startMinute: 600),
          occ(1, 0, name: 'Early', startMinute: 480),
          occ(1, 0, name: 'Beta'),
          occ(1, 0, name: 'Alpha'),
          occ(0, 2, name: 'Long'),
        ],
        monday,
      );
      final List<String> byLane = (<WeekSegment>[...s]..sort((WeekSegment a, WeekSegment b) => a.lane.compareTo(b.lane)))
          .map((WeekSegment x) => x.occurrence.event.name)
          .toList();
      expect(byLane, <String>['Long', 'Alpha', 'Beta', 'Early', 'Zebra']);
    });

    test('a daylight saving change inside the week does not shift a column', () {
      final DateTime week = DateTime(2026, 3, 23); // clocks go forward on Sunday 29 March
      final WeekSegment s = layoutWeek(<EventOccurrence>[occ(6, 0, from: week)], week).single;
      expect((s.startColumn, s.endColumn), (6, 6));
      final WeekSegment t = layoutWeek(<EventOccurrence>[occ(3, 2, from: week)], week).single;
      expect((t.startColumn, t.endColumn), (3, 5));
    });
  });

  group('lanesShown', () {
    test('shows all up to three, otherwise two, and leaves a line for "+N" when it must hide', () {
      expect(lanesShown(2, 10), 2);
      expect(lanesShown(3, 10), 3);
      expect(lanesShown(4, 10), 2);
      expect(lanesShown(3, 2), 1);
      expect(lanesShown(2, 1), 0);
      expect(lanesShown(5, 0), 0);
    });
  });

  // Properties 1 and 2: each int encodes one occurrence (start from -5 to 12 days around the week,
  // 0 to 8 days more, all-day or timed).
  final Glados<List<int>> anyWeek = Glados(any.list(any.intInRange(0, 3000)));
  List<EventOccurrence> decode(List<int> picks) => <EventOccurrence>[
    for (final int v in picks)
      occ(
        v % 18 - 5,
        (v ~/ 18) % 9,
        name: 'E${v % 7}',
        startMinute: (v ~/ 162) % 2 == 0 ? null : 60 * (v ~/ 324 % 20),
      ),
  ];

  anyWeek.test('Property 1: no two segments in one lane share a column', (picks) {
    final List<WeekSegment> segments = layoutWeek(decode(picks), monday);
    for (int i = 0; i < segments.length; i++) {
      for (int j = i + 1; j < segments.length; j++) {
        if (segments[i].lane != segments[j].lane) continue;
        final bool overlap =
            segments[i].startColumn <= segments[j].endColumn && segments[j].startColumn <= segments[i].endColumn;
        expect(overlap, isFalse, reason: 'lane ${segments[i].lane}');
      }
    }
  });

  anyWeek.test('Property 2: a segment covers exactly the days of its occurrence in the week', (picks) {
    final List<EventOccurrence> all = decode(picks);
    final List<WeekSegment> segments = layoutWeek(all, monday);
    final List<EventOccurrence> touching = <EventOccurrence>[
      for (final EventOccurrence o in all)
        if (!o.end.isBefore(monday) && !o.start.isAfter(day(6))) o,
    ];
    expect(segments, hasLength(touching.length));
    for (final WeekSegment s in segments) {
      final EventOccurrence o = s.occurrence;
      final List<int> columns = <int>[
        for (int c = 0; c < 7; c++)
          if (!day(c).isBefore(o.start) && !day(c).isAfter(o.end)) c,
      ];
      expect(<int>[for (int c = s.startColumn; c <= s.endColumn; c++) c], columns);
      expect(s.continuesBefore, o.start.isBefore(monday));
      expect(s.continuesAfter, o.end.isAfter(day(6)));
    }
  });
}
