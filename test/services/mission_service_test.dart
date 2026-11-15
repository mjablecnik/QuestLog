import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:glados/glados.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/mission_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/seed.dart';
import '../helpers/test_database.dart';

void main() {
  late QuestlogDatabase db;
  late XpEngine xp;
  late FixedClock clock;
  late MissionService missions;

  setUp(() {
    db = createTestDatabase();
    xp = XpEngine(db);
    clock = FixedClock(DateTime(2026, 11, 15, 10));
    missions = MissionService(db, xp, clock);
  });
  tearDown(() => db.close());

  QuestDraft quest(String name, {Difficulty difficulty = Difficulty.normal}) =>
      QuestDraft(name: name, difficulty: difficulty);

  Matcher validationOn(String field) =>
      isA<ValidationError>().having((e) => e.field, 'field', field);

  group('create', () {
    test('stores an open Mission with its Quests in the given order', () async {
      final mission = await missions.create(
        MissionDraft(
          name: '  Move house ',
          bonus: MissionBonus.large,
          quests: [quest('Pack'), quest('Carry'), quest('Unpack')],
        ),
      );

      expect(mission.name, 'Move house');
      expect(mission.status, MissionStatus.open);
      expect(mission.bonus, MissionBonus.large);
      expect(mission.ruleId, isNull);
      expect(mission.createdAt, DateTime(2026, 11, 15, 10));
      final rows = await (db.select(db.quests)
            ..orderBy([(q) => OrderingTerm.asc(q.sortOrder)]))
          .get();
      expect(rows.map((q) => q.name), ['Pack', 'Carry', 'Unpack']);
      expect(rows.every((q) => q.missionId == mission.id), isTrue);
    });

    test('initial Quests are ordered after existing Quests', () async {
      await seedQuest(db, name: 'existing', sortOrder: 7);
      await missions.create(
        MissionDraft(name: 'M', bonus: MissionBonus.small, quests: [quest('new')]),
      );
      final rows = await (db.select(db.quests)
            ..orderBy([(q) => OrderingTerm.asc(q.sortOrder)]))
          .get();
      expect(rows.map((q) => q.name), ['existing', 'new']);
      expect(rows.last.sortOrder, 8);
    });

    test('a Mission without Quests is allowed', () async {
      final mission =
          await missions.create(const MissionDraft(name: 'Empty', bonus: MissionBonus.small));
      expect(mission.status, MissionStatus.open);
    });

    test('name boundaries: empty, whitespace only, 80 and 81 characters', () async {
      for (final bad in ['', '   ', 'a' * 81]) {
        await expectLater(
          missions.create(MissionDraft(name: bad, bonus: MissionBonus.small)),
          throwsA(validationOn('name')),
        );
      }
      final ok = await missions.create(
        MissionDraft(name: 'a' * 80, bonus: MissionBonus.small),
      );
      expect(ok.name, hasLength(80));
    });

    test('an invalid initial Quest rejects the whole Mission and writes nothing', () async {
      await expectLater(
        missions.create(
          MissionDraft(
            name: 'M',
            bonus: MissionBonus.small,
            quests: [quest('fine'), quest('   ')],
          ),
        ),
        throwsA(isA<ValidationError>()),
      );
      expect(await db.select(db.missions).get(), isEmpty);
      expect(await db.select(db.quests).get(), isEmpty);
    });
  });

  group('update', () {
    test('changes name and bonus', () async {
      final mission =
          await missions.create(const MissionDraft(name: 'Old', bonus: MissionBonus.small));
      final updated = await missions.update(mission.id, ' New ', MissionBonus.medium);
      expect(updated.name, 'New');
      expect(updated.bonus, MissionBonus.medium);
    });

    test('validates the name and requires an existing Mission', () async {
      final mission =
          await missions.create(const MissionDraft(name: 'M', bonus: MissionBonus.small));
      await expectLater(
        missions.update(mission.id, '', MissionBonus.small),
        throwsA(validationOn('name')),
      );
      await expectLater(
        missions.update(999, 'x', MissionBonus.small),
        throwsA(isA<NotFoundError>()),
      );
    });

    test('editing the bonus of a completed Mission leaves the recorded bonus', () async {
      final id = await seedMission(
        db,
        bonus: MissionBonus.small,
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 9),
        awardedBonus: 50,
      );
      final updated = await missions.update(id, 'Renamed', MissionBonus.large);

      expect(updated.bonus, MissionBonus.large);
      expect(updated.awardedBonus, 50);
      expect(updated.status, MissionStatus.completed);
      expect(updated.completedAt, DateTime(2026, 11, 15, 9));
    });
  });

  group('addQuest', () {
    test('places the Quest after the Mission existing Quests', () async {
      final mission = await missions.create(
        MissionDraft(name: 'M', bonus: MissionBonus.small, quests: [quest('first')]),
      );
      await seedQuest(db, name: 'standalone', sortOrder: 50);

      final added = await missions.addQuest(mission.id, quest('second'));

      expect(added.missionId, mission.id);
      expect(added.sortOrder, 51);
      expect(added.isDone, isFalse);
    });

    test('is rejected for a completed or closed Mission', () async {
      final completed = await seedMission(db, status: MissionStatus.completed);
      final closed = await seedMission(db, status: MissionStatus.closed);
      await expectLater(
        missions.addQuest(completed, quest('x')),
        throwsA(isA<InvalidStateError>()),
      );
      await expectLater(
        missions.addQuest(closed, quest('x')),
        throwsA(isA<InvalidStateError>()),
      );
      expect(await db.select(db.quests).get(), isEmpty);
    });

    test('validates the Quest and requires an existing Mission', () async {
      final mission =
          await missions.create(const MissionDraft(name: 'M', bonus: MissionBonus.small));
      await expectLater(missions.addQuest(mission.id, quest('')), throwsA(validationOn('name')));
      await expectLater(missions.addQuest(999, quest('x')), throwsA(isA<NotFoundError>()));
    });
  });

  group('delete', () {
    test('removes the Mission and all its Quests and leaves Total_XP unchanged', () async {
      final mission = await missions.create(
        MissionDraft(name: 'M', bonus: MissionBonus.small, quests: [quest('a'), quest('b')]),
      );
      final other = await seedQuest(db, name: 'other', sortOrder: 99);
      await db.update(db.quests).write(
            QuestsCompanion(
              completedAt: Value(DateTime(2026, 11, 15, 9)),
              awardedXp: const Value(25),
            ),
          );
      await xp.apply(75);

      await missions.delete(mission.id);

      expect(await db.select(db.missions).get(), isEmpty);
      final remaining = await db.select(db.quests).get();
      expect(remaining.map((q) => q.id), [other], reason: 'only the standalone Quest survives');
      expect(await xp.readTotal(), 75);
    });

    test('deleting a completed Mission keeps the awarded bonus in Total_XP', () async {
      final id = await seedMission(
        db,
        status: MissionStatus.completed,
        completedAt: DateTime(2026, 11, 15, 9),
        awardedBonus: 50,
      );
      await xp.apply(50);
      await missions.delete(id);
      expect(await xp.readTotal(), 50);
    });

    test('a missing Mission is not found', () async {
      await expectLater(missions.delete(5), throwsA(isA<NotFoundError>()));
    });
  });
}
