import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/calendar/event_type.dart';
import 'package:questlog/data/calendar/calendar_filter_store.dart';

void main() {
  late Directory dir;
  late File file;
  late FileCalendarFilterStore store;
  final Set<EventType> all = EventType.values.toSet();

  setUp(() {
    dir = Directory.systemTemp.createTempSync('calendar_filter_');
    file = File('${dir.path}/calendar_filter.txt');
    store = FileCalendarFilterStore(file);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('a missing file means all ten types', () async {
    expect(await store.load(), all);
  });

  test('round trip of a subset', () async {
    final Set<EventType> shown = <EventType>{EventType.dance, EventType.lesson, EventType.nameDay};
    await store.save(shown);
    expect(await store.load(), shown);
    expect(file.readAsStringSync(), contains('nameDay'));
  });

  test('no type shown is stored and loaded as empty', () async {
    await store.save(<EventType>{});
    expect(await store.load(), isEmpty);
  });

  test('garbage and an empty file load as all types', () async {
    file.writeAsStringSync('???,;;');
    expect(await store.load(), all);
    file.writeAsStringSync('');
    expect(await store.load(), all);
  });

  test('unknown keys are ignored', () async {
    file.writeAsStringSync('dance,party,work');
    expect(await store.load(), <EventType>{EventType.dance, EventType.work});
  });

  test('saving into a missing directory does not throw', () async {
    final FileCalendarFilterStore broken = FileCalendarFilterStore(File('${dir.path}/nope/x.txt'));
    await broken.save(<EventType>{EventType.work});
    expect(await broken.load(), all);
  });

  test('the memory store round trips', () async {
    final MemoryCalendarFilterStore memory = MemoryCalendarFilterStore();
    expect(await memory.load(), all);
    await memory.save(<EventType>{EventType.date});
    expect(await memory.load(), <EventType>{EventType.date});
  });
}
