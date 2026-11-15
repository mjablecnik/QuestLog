import 'package:drift/drift.dart' show OrderingTerm;
import 'package:glados/glados.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/recurrence_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/test_database.dart';

/// A day in the test calendar, 10:00 local, counted from 2026-01-01.
DateTime day(int offset, {int hour = 10, int minute = 0}) =>
    DateTime(2026, 1, 1 + offset, hour, minute);

/// A requested anchor that is valid for [cadence] (a Monthly day stays in 1-28).
DateTime requestedFor(Cadence cadence, int offset) {
  final date = DateTime(2026, 1, 1 + offset);
  return cadence == Cadence.monthly ? DateTime(date.year, date.month, date.day % 28 + 1) : date;
}

RuleDraft rule({
  String name = 'Cleaning',
  Cadence cadence = Cadence.monthly,
  DateTime? anchor,
  MissionBonus bonus = MissionBonus.medium,
  List<RuleQuestDraft>? quests,
}) =>
    RuleDraft(
      name: name,
      cadence: cadence,
      requestedAnchor: anchor ?? DateTime(2026, 1, 1),
      bonus: bonus,
      quests: quests ??
          const [
            RuleQuestDraft(name: 'Vacuum', difficulty: Difficulty.easy),
            RuleQuestDraft(name: 'Mop', difficulty: Difficulty.normal),
            RuleQuestDraft(name: 'Windows', difficulty: Difficulty.hard),
          ],
    );

/// A fresh database with the services under test and a clock set by the caller.
class Harness {
  Harness(this.clock)
      : db = createTestDatabase() {
    xp = XpEngine(db);
    recurrence = RecurrenceService(db, clock);
    quests = QuestService(db, xp, clock);
  }

  final FixedClock clock;
  final QuestlogDatabase db;
  late final XpEngine xp;
  late final RecurrenceService recurrence;
  late final QuestService quests;

  Future<List<MissionRow>> instancesOf(int ruleId) {
    return (db.select(db.missions)
          ..where((m) => m.ruleId.equals(ruleId))
          ..orderBy([(m) => OrderingTerm.asc(m.id)]))
        .get();
  }

  Future<int> openInstanceCount(int ruleId) async =>
      (await instancesOf(ruleId)).where((m) => m.status == MissionStatus.open).length;

  Future<void> close() => db.close();
}

void main() {
  group('properties', () {
    // Feature: questlog-domain, Property 8: reconciliation posts at most once per rule and is idempotent
    Glados3(
      any.listWithLengthInRange(1, 4, any.intInRange(0, 6 * 40)),
      any.listWithLengthInRange(1, 6, any.intInRange(0, 120)),
      any.intInRange(0, 40),
    ).test(
      'each rule posts at most once per run and a second run in the same Board_Day posts none',
      (ruleCodes, launchGaps, createOffset) async {
        final h = Harness(FixedClock(day(createOffset)));
        try {
          final ruleIds = <int>[];
          for (final code in ruleCodes) {
            final cadence = Cadence.values[code % 6];
            final created = await h.recurrence.create(
              rule(cadence: cadence, anchor: requestedFor(cadence, code ~/ 6)),
            );
            ruleIds.add(created.id);
          }

          var offset = createOffset;
          for (final gap in launchGaps) {
            offset += gap;
            h.clock.set(day(offset));
            final before = {
              for (final id in ruleIds) id: (await h.instancesOf(id)).length,
            };

            final posted = await h.recurrence.reconcile();

            expect(
              posted.map((m) => m.ruleId).toSet().length,
              posted.length,
              reason: 'no rule posts twice in one run',
            );
            for (final id in ruleIds) {
              final grown = (await h.instancesOf(id)).length - before[id]!;
              expect(grown, lessThanOrEqualTo(1));
              expect(await h.openInstanceCount(id), lessThanOrEqualTo(1));
            }
            expect(await h.recurrence.reconcile(), isEmpty, reason: 'second run is a no-op');
          }
        } finally {
          await h.close();
        }
      },
    );

    // Feature: questlog-domain, Property 9: manual posting skips exactly the nearest automatic posting
    Glados3(
      any.intInRange(0, 6 * 40),
      any.intInRange(0, 90),
      any.listWithLengthInRange(3, 3, any.bool),
    ).test(
      'after postNow the Next_Occurrence is after Today and the skipped date posts nothing',
      (ruleCode, gap, doneFlags) async {
        final h = Harness(FixedClock(day(0)));
        try {
          final cadence = Cadence.values[ruleCode % 6];
          final created = await h.recurrence.create(
            rule(cadence: cadence, anchor: requestedFor(cadence, ruleCode ~/ 6)),
          );
          h.clock.set(day(gap));
          final today = DateTime(2026, 1, 1 + gap);
          final nextBefore = (await h.recurrence.watchRules().first).single.nextOccurrence;

          final result = await h.recurrence.postNow(created.id);

          expect(result.skippedNextPosting, nextBefore.isAfter(today));
          final nextAfter = (await h.recurrence.watchRules().first).single.nextOccurrence;
          expect(nextAfter.isAfter(today), isTrue);

          // Whatever the user does with the manually posted Instance, it changes nothing.
          final questRows = await (h.db.select(h.db.quests)
                ..orderBy([(q) => OrderingTerm.asc(q.sortOrder)]))
              .get();
          for (var i = 0; i < questRows.length; i++) {
            if (doneFlags[i]) await h.quests.complete(questRows[i].id);
          }

          final skippedDate = nextBefore.isAfter(today) ? nextBefore : today;
          h.clock.set(DateTime(skippedDate.year, skippedDate.month, skippedDate.day, 10));
          expect(await h.recurrence.reconcile(), isEmpty);
          expect((await h.instancesOf(created.id)), hasLength(1));
        } finally {
          await h.close();
        }
      },
    );

    // Feature: questlog-domain, Property 10: posting closes the previous Instance without bonus
    Glados3(
      any.listWithLengthInRange(3, 3, any.bool),
      any.bool,
      any.choose(Cadence.values),
    ).test(
      'a new Instance closes the earlier one, awards nothing and leaves one open Instance',
      (doneFlags, manual, cadence) async {
        final h = Harness(FixedClock(day(0)));
        try {
          final created = await h.recurrence.create(
            rule(cadence: cadence, anchor: requestedFor(cadence, 0)),
          );
          await h.recurrence.postNow(created.id);
          final first = (await h.instancesOf(created.id)).single;
          final questRows = await (h.db.select(h.db.quests)
                ..orderBy([(q) => OrderingTerm.asc(q.sortOrder)]))
              .get();
          for (var i = 0; i < questRows.length; i++) {
            if (doneFlags[i]) await h.quests.complete(questRows[i].id);
          }
          final totalBefore = await h.xp.readTotal();
          final doneBefore = doneFlags.where((d) => d).length;

          if (manual) {
            await h.recurrence.postNow(created.id);
          } else {
            final next = (await h.recurrence.watchRules().first).single.nextOccurrence;
            h.clock.set(DateTime(next.year, next.month, next.day, 10));
            expect(await h.recurrence.reconcile(), hasLength(1));
          }

          final instances = await h.instancesOf(created.id);
          expect(instances, hasLength(2));
          expect(instances.first.id, first.id);
          expect(instances.first.status, MissionStatus.closed);
          expect(instances.first.awardedBonus, isNull);
          expect(instances.last.status, MissionStatus.open);
          expect(await h.openInstanceCount(created.id), 1);
          expect(await h.xp.readTotal(), totalBefore);
          final remaining = await (h.db.select(h.db.quests)
                ..where((q) => q.missionId.equals(first.id)))
              .get();
          expect(remaining, hasLength(doneBefore));
          expect(remaining.every((q) => q.completedAt != null), isTrue);
        } finally {
          await h.close();
        }
      },
    );
  });

  group('unit', () {
    late Harness h;

    setUp(() => h = Harness(FixedClock(DateTime(2026, 11, 14, 10))));
    tearDown(() => h.close());

    Matcher validationOn(String field) =>
        isA<ValidationError>().having((e) => e.field, 'field', field);

    group('create and validation', () {
      test('stores the rule with templates in order and the first Anchor_Date', () async {
        final created = await h.recurrence.create(
          rule(cadence: Cadence.monthly, anchor: DateTime(2026, 11, 1)),
        );

        expect(created.name, 'Cleaning');
        expect(created.cadence, Cadence.monthly);
        expect(created.anchorDate, DateTime(2026, 12, 1), reason: 'first 1st on or after Nov 14');
        expect(created.nextIndex, 0);
        expect(created.lastPostedOn, isNull);
        expect(created.quests.map((q) => q.name), ['Vacuum', 'Mop', 'Windows']);
        expect(created.quests.map((q) => q.difficulty),
            [Difficulty.easy, Difficulty.normal, Difficulty.hard]);
      });

      test('Monthly posting day 29 is rejected, 28 is accepted', () async {
        await expectLater(
          h.recurrence.create(rule(anchor: DateTime(2026, 11, 29))),
          throwsA(validationOn('postingDay')),
        );
        final ok = await h.recurrence.create(rule(anchor: DateTime(2026, 11, 28)));
        expect(ok.anchorDate, DateTime(2026, 11, 28));
      });

      test('a rule without templates is rejected', () async {
        await expectLater(
          h.recurrence.create(rule(quests: const [])),
          throwsA(validationOn('quests')),
        );
      });

      test('name boundaries and template names are validated', () async {
        for (final bad in ['', '  ', 'a' * 81]) {
          await expectLater(h.recurrence.create(rule(name: bad)), throwsA(validationOn('name')));
        }
        await expectLater(
          h.recurrence.create(
            rule(quests: const [RuleQuestDraft(name: ' ', difficulty: Difficulty.easy)]),
          ),
          throwsA(validationOn('quests.name')),
        );
        expect(await h.db.select(h.db.recurringRules).get(), isEmpty);
        final ok = await h.recurrence.create(rule(name: 'a' * 80));
        expect(ok.name, hasLength(80));
      });
    });

    group('posting', () {
      test('an Instance copies the rule name, bonus and templates in order', () async {
        final created = await h.recurrence.create(
          rule(cadence: Cadence.daily, bonus: MissionBonus.large),
        );
        h.clock.set(DateTime(2026, 11, 15, 10));

        final posted = await h.recurrence.reconcile();

        expect(posted, hasLength(1));
        final mission = posted.single;
        expect(mission.name, 'Cleaning');
        expect(mission.bonus, MissionBonus.large);
        expect(mission.status, MissionStatus.open);
        expect(mission.ruleId, created.id);
        final quests = await (h.db.select(h.db.quests)
              ..orderBy([(q) => OrderingTerm.asc(q.sortOrder)]))
            .get();
        expect(quests.map((q) => q.name), ['Vacuum', 'Mop', 'Windows']);
        expect(quests.map((q) => q.difficulty),
            [Difficulty.easy, Difficulty.normal, Difficulty.hard]);
        expect(quests.every((q) => q.missionId == mission.id && q.completedAt == null), isTrue);
      });

      test('a rule due at 03:59 posts only after 04:00', () async {
        // Anchor on the 15th: due on Board_Day the 15th, which starts at 04:00.
        await h.recurrence.create(rule(cadence: Cadence.monthly, anchor: DateTime(2026, 11, 15)));

        h.clock.set(DateTime(2026, 11, 15, 3, 59));
        expect(await h.recurrence.reconcile(), isEmpty);

        h.clock.set(DateTime(2026, 11, 15, 4));
        expect(await h.recurrence.reconcile(), hasLength(1));
      });

      test('several missed Occurrences post a single Instance', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.weekly));
        h.clock.set(DateTime(2027, 2, 1, 10));

        expect(await h.recurrence.reconcile(), hasLength(1));
        expect(await h.instancesOf(created.id), hasLength(1));
        final summary = (await h.recurrence.watchRules().first).single;
        expect(summary.nextOccurrence.isAfter(DateTime(2027, 2, 1)), isTrue);
      });

      test('a rule that is not yet due posts nothing', () async {
        await h.recurrence.create(rule(cadence: Cadence.monthly, anchor: DateTime(2026, 12, 1)));
        expect(await h.recurrence.reconcile(), isEmpty);
      });

      test('postNow reports skippedNextPosting when posted early', () async {
        final created = await h.recurrence.create(
          rule(cadence: Cadence.monthly, anchor: DateTime(2026, 12, 1)),
        );

        final result = await h.recurrence.postNow(created.id);

        expect(result.skippedNextPosting, isTrue);
        expect(result.closedPreviousInstance, isFalse);
        expect(result.mission.ruleId, created.id);
        final next = (await h.recurrence.watchRules().first).single.nextOccurrence;
        expect(next, DateTime(2027, 1, 1), reason: 'the Dec 1 posting was skipped');
      });

      test('postNow does not report a skip when the rule was already due', () async {
        final created = await h.recurrence.create(
          rule(cadence: Cadence.daily, anchor: DateTime(2026, 11, 14)),
        );

        final result = await h.recurrence.postNow(created.id);

        expect(result.skippedNextPosting, isFalse);
        final next = (await h.recurrence.watchRules().first).single.nextOccurrence;
        expect(next, DateTime(2026, 11, 15));
      });

      test('closedPreviousInstance reflects whether an open Instance existed', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.daily));

        final first = await h.recurrence.postNow(created.id);
        final second = await h.recurrence.postNow(created.id);

        expect(first.closedPreviousInstance, isFalse);
        expect(second.closedPreviousInstance, isTrue);
        expect(await h.openInstanceCount(created.id), 1);
      });

      test('closing an Instance keeps its done Quests and their XP', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.daily));
        await h.recurrence.postNow(created.id);
        final firstQuest = (await h.db.select(h.db.quests).get()).first;
        await h.quests.complete(firstQuest.id);

        await h.recurrence.postNow(created.id);

        final kept = await (h.db.select(h.db.quests)..where((q) => q.id.equals(firstQuest.id)))
            .getSingle();
        expect(kept.completedAt, isNotNull);
        expect(await h.xp.readTotal(), firstQuest.difficulty.xp);
        expect(await h.db.select(h.db.quests).get(), hasLength(1 + 3));
      });

      test('a failed posting writes nothing', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.daily));
        await h.db.customStatement('DROP TABLE quests');

        await expectLater(h.recurrence.postNow(created.id), throwsA(isA<StorageError>()));

        expect(await h.instancesOf(created.id), isEmpty);
      });

      test('postNow on an unknown rule is not found', () async {
        await expectLater(h.recurrence.postNow(99), throwsA(isA<NotFoundError>()));
      });
    });

    group('editing and deleting', () {
      test('editing a rule changes only the next Instance', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.daily));
        await h.recurrence.postNow(created.id);
        final firstInstance = (await h.instancesOf(created.id)).single;

        await h.recurrence.update(
          created.id,
          rule(
            name: 'Deep cleaning',
            cadence: Cadence.daily,
            bonus: MissionBonus.large,
            quests: const [RuleQuestDraft(name: 'Everything', difficulty: Difficulty.hard)],
          ),
        );

        final untouched = (await h.instancesOf(created.id)).single;
        expect(untouched.name, 'Cleaning');
        expect(untouched.bonus, MissionBonus.medium);
        expect(
          await (h.db.select(h.db.quests)..where((q) => q.missionId.equals(firstInstance.id))).get(),
          hasLength(3),
        );

        final next = await h.recurrence.postNow(created.id);
        expect(next.mission.name, 'Deep cleaning');
        expect(next.mission.bonus, MissionBonus.large);
        final quests = await (h.db.select(h.db.quests)
              ..where((q) => q.missionId.equals(next.mission.id)))
            .get();
        expect(quests.map((q) => q.name), ['Everything']);
        final templates = await h.db.select(h.db.ruleQuests).get();
        expect(templates.map((t) => t.name), ['Everything'], reason: 'templates are replaced');
      });

      test('editing the name only keeps a skipped posting skipped', () async {
        final created = await h.recurrence.create(
          rule(cadence: Cadence.monthly, anchor: DateTime(2026, 12, 1)),
        );
        await h.recurrence.postNow(created.id); // skips Dec 1
        final before = (await h.recurrence.watchRules().first).single.nextOccurrence;

        // The UI sends a requested anchor derived from the unchanged posting day.
        await h.recurrence.update(
          created.id,
          rule(name: 'Renamed', cadence: Cadence.monthly, anchor: DateTime(2026, 11, 1)),
        );

        final summary = (await h.recurrence.watchRules().first).single;
        expect(summary.name, 'Renamed');
        expect(summary.nextOccurrence, before);
        expect(summary.nextOccurrence, DateTime(2027, 1, 1));
      });

      test('changing the posting day re-anchors after the last posting', () async {
        final created = await h.recurrence.create(
          rule(cadence: Cadence.monthly, anchor: DateTime(2026, 11, 14)),
        );
        await h.recurrence.postNow(created.id); // posts on Nov 14

        final updated = await h.recurrence.update(
          created.id,
          rule(cadence: Cadence.monthly, anchor: DateTime(2026, 11, 14 + 1)),
        );

        expect(updated.anchorDate, DateTime(2026, 11, 15));
        expect(updated.nextIndex, 0);
      });

      test('changing the Cadence re-anchors and resets the index', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.monthly));
        final updated = await h.recurrence.update(
          created.id,
          rule(cadence: Cadence.weekly, anchor: DateTime(2026, 11, 16)),
        );
        expect(updated.cadence, Cadence.weekly);
        expect(updated.anchorDate, DateTime(2026, 11, 16));
        expect(updated.nextIndex, 0);
      });

      test('a re-anchored rule never posts on or before the day it was last posted', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.daily));
        await h.recurrence.postNow(created.id); // last posted today, Nov 14

        final updated = await h.recurrence.update(
          created.id,
          rule(cadence: Cadence.weekly, anchor: DateTime(2026, 11, 14)),
        );

        expect(updated.anchorDate, DateTime(2026, 11, 21));
        expect(await h.recurrence.reconcile(), isEmpty);
      });

      test('update validates like create and requires an existing rule', () async {
        final created = await h.recurrence.create(rule());
        await expectLater(
          h.recurrence.update(created.id, rule(quests: const [])),
          throwsA(validationOn('quests')),
        );
        await expectLater(h.recurrence.update(99, rule()), throwsA(isA<NotFoundError>()));
      });

      test('deleting a rule keeps its open Instance as an ordinary Mission', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.daily));
        await h.recurrence.postNow(created.id);

        await h.recurrence.delete(created.id);

        final mission = await h.db.select(h.db.missions).getSingle();
        expect(mission.status, MissionStatus.open);
        expect(mission.ruleId, isNull);
        expect(await h.db.select(h.db.ruleQuests).get(), isEmpty);
        expect(await h.db.select(h.db.quests).get(), hasLength(3));

        h.clock.set(DateTime(2026, 12, 25, 10));
        expect(await h.recurrence.reconcile(), isEmpty);
        expect(await h.db.select(h.db.missions).get(), hasLength(1));
      });

      test('deleting an unknown rule is not found', () async {
        await expectLater(h.recurrence.delete(5), throwsA(isA<NotFoundError>()));
      });
    });

    group('watchRules', () {
      test('is empty without rules', () async {
        expect(await h.recurrence.watchRules().first, isEmpty);
      });

      test('carries the rule fields, templates, next date and open-Instance flag', () async {
        final created = await h.recurrence.create(
          rule(cadence: Cadence.weekly, anchor: DateTime(2026, 11, 16), bonus: MissionBonus.small),
        );

        final summary = (await h.recurrence.watchRules().first).single;

        expect(summary.id, created.id);
        expect(summary.name, 'Cleaning');
        expect(summary.cadence, Cadence.weekly);
        expect(summary.anchorDate, DateTime(2026, 11, 16));
        expect(summary.bonus, MissionBonus.small);
        expect(summary.quests.map((q) => q.name), ['Vacuum', 'Mop', 'Windows']);
        expect(summary.nextOccurrence, DateTime(2026, 11, 16));
        expect(summary.hasOpenInstance, isFalse);
      });

      test('reflects a manual posting, a template edit and a deletion', () async {
        final created = await h.recurrence.create(rule(cadence: Cadence.monthly, anchor: DateTime(2026, 12, 1)));
        final snapshots = <RuleSummary?>[];
        final sub = h.recurrence
            .watchRules()
            .listen((rules) => snapshots.add(rules.isEmpty ? null : rules.single));
        await pumpEventQueue();

        await h.recurrence.postNow(created.id);
        await pumpEventQueue();
        await h.recurrence.update(
          created.id,
          rule(
            cadence: Cadence.monthly,
            anchor: DateTime(2026, 12, 1),
            quests: const [RuleQuestDraft(name: 'Only', difficulty: Difficulty.easy)],
          ),
        );
        await pumpEventQueue();
        await h.recurrence.delete(created.id);
        await pumpEventQueue();
        await sub.cancel();

        final posted = snapshots.firstWhere((s) => s != null && s.hasOpenInstance)!;
        expect(posted.nextOccurrence, DateTime(2027, 1, 1));
        final edited = snapshots.firstWhere((s) => s != null && s.quests.length == 1)!;
        expect(edited.hasOpenInstance, isTrue);
        expect(snapshots.last, isNull);
      });
    });
  });
}
