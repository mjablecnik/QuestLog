import 'package:drift/drift.dart' show Value;
import 'package:glados/glados.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/xp_engine.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/seed.dart';
import '../helpers/test_database.dart';

void main() {
  late QuestlogDatabase db;
  late XpEngine xp;
  late FixedClock clock;
  late QuestService quests;

  setUp(() {
    db = createTestDatabase();
    xp = XpEngine(db);
    clock = FixedClock(DateTime(2026, 11, 15, 10));
    quests = QuestService(db, xp, clock);
  });
  tearDown(() => db.close());

  QuestDraft draft({
    String name = 'Quest',
    String? note,
    Difficulty difficulty = Difficulty.normal,
    int? missionId,
  }) =>
      QuestDraft(name: name, note: note, difficulty: difficulty, missionId: missionId);

  Matcher validationOn(String field) =>
      isA<ValidationError>().having((e) => e.field, 'field', field);

  group('create', () {
    test('stores an open standalone Quest stamped by the Clock', () async {
      final quest = await quests.create(draft(name: '  Buy milk ', note: 'oat'));
      expect(quest.name, 'Buy milk');
      expect(quest.note, 'oat');
      expect(quest.difficulty, Difficulty.normal);
      expect(quest.missionId, isNull);
      expect(quest.isDone, isFalse);
      expect(quest.awardedXp, isNull);
      expect(quest.createdAt, DateTime(2026, 11, 15, 10));
    });

    test('stores a Quest inside an open Mission', () async {
      final missionId = await seedMission(db);
      final quest = await quests.create(draft(missionId: missionId));
      expect(quest.missionId, missionId);
    });

    test('name boundaries: empty, whitespace only, 80 and 81 characters', () async {
      await expectLater(quests.create(draft(name: '')), throwsA(validationOn('name')));
      await expectLater(quests.create(draft(name: '   \t ')), throwsA(validationOn('name')));
      await expectLater(quests.create(draft(name: 'a' * 81)), throwsA(validationOn('name')));
      final ok = await quests.create(draft(name: 'a' * 80));
      expect(ok.name.length, 80);
      expect(await db.select(db.quests).get(), hasLength(1), reason: 'rejected creates wrote nothing');
    });

    test('note boundaries: 500 accepted, 501 rejected', () async {
      final ok = await quests.create(draft(note: 'n' * 500));
      expect(ok.note, hasLength(500));
      await expectLater(quests.create(draft(note: 'n' * 501)), throwsA(validationOn('note')));
    });

    test('an unknown Mission is an invalid-state error', () async {
      await expectLater(quests.create(draft(missionId: 999)), throwsA(isA<InvalidStateError>()));
    });

    test('a completed or closed Mission is an invalid-state error', () async {
      final completed = await seedMission(db, status: MissionStatus.completed);
      final closed = await seedMission(db, status: MissionStatus.closed);
      await expectLater(quests.create(draft(missionId: completed)), throwsA(isA<InvalidStateError>()));
      await expectLater(quests.create(draft(missionId: closed)), throwsA(isA<InvalidStateError>()));
      expect(await db.select(db.quests).get(), isEmpty);
    });

    test('a SQLite failure surfaces as StorageError', () async {
      await db.customStatement('DROP TABLE quests');
      await expectLater(quests.create(draft()), throwsA(isA<StorageError>()));
    });
  });

  group('update', () {
    test('an open Quest takes name, Difficulty, note and Mission', () async {
      final missionId = await seedMission(db);
      final quest = await quests.create(draft());
      final updated = await quests.update(
        quest.id,
        draft(name: 'Renamed', note: 'new', difficulty: Difficulty.hard, missionId: missionId),
      );
      expect(updated.name, 'Renamed');
      expect(updated.note, 'new');
      expect(updated.difficulty, Difficulty.hard);
      expect(updated.missionId, missionId);
      expect(updated.sortOrder, quest.sortOrder);
      expect(updated.createdAt, quest.createdAt);
    });

    test('an open Quest can be moved out of its Mission and have its note cleared', () async {
      final missionId = await seedMission(db);
      final quest = await quests.create(draft(note: 'x', missionId: missionId));
      final updated = await quests.update(quest.id, draft());
      expect(updated.missionId, isNull);
      expect(updated.note, isNull);
    });

    test('moving an open Quest into a non-open Mission is rejected', () async {
      final closed = await seedMission(db, status: MissionStatus.closed);
      final quest = await quests.create(draft());
      await expectLater(
        quests.update(quest.id, draft(missionId: closed)),
        throwsA(isA<InvalidStateError>()),
      );
      expect((await db.select(db.quests).getSingle()).missionId, isNull);
    });

    test('a done Quest changes only name and note, ignoring Difficulty and Mission', () async {
      final missionId = await seedMission(db);
      final otherMission = await seedMission(db);
      final quest = await quests.create(draft(difficulty: Difficulty.easy, missionId: missionId));
      await (db.update(db.quests)).write(
        QuestsCompanion(
          completedAt: Value(DateTime(2026, 11, 15, 9)),
          awardedXp: const Value(10),
        ),
      );
      final updated = await quests.update(
        quest.id,
        draft(
          name: 'Edited',
          note: 'after',
          difficulty: Difficulty.hard,
          missionId: otherMission,
        ),
      );
      expect(updated.name, 'Edited');
      expect(updated.note, 'after');
      expect(updated.difficulty, Difficulty.easy);
      expect(updated.missionId, missionId);
      expect(updated.awardedXp, 10);
      expect(updated.isDone, isTrue);
    });

    test('validates name and note, and a missing Quest is not found', () async {
      final quest = await quests.create(draft());
      await expectLater(quests.update(quest.id, draft(name: ' ')), throwsA(validationOn('name')));
      await expectLater(quests.update(quest.id, draft(note: 'n' * 501)), throwsA(validationOn('note')));
      await expectLater(quests.update(999, draft()), throwsA(isA<NotFoundError>()));
    });
  });

  group('delete', () {
    test('removes the Quest and leaves Total_XP unchanged', () async {
      final quest = await quests.create(draft());
      await db.update(db.quests).write(
            QuestsCompanion(
              completedAt: Value(DateTime(2026, 11, 15, 9)),
              awardedXp: const Value(25),
            ),
          );
      await xp.apply(25);

      await quests.delete(quest.id);

      expect(await db.select(db.quests).get(), isEmpty);
      expect(await xp.readTotal(), 25);
    });

    test('a missing Quest is not found', () async {
      await expectLater(quests.delete(42), throwsA(isA<NotFoundError>()));
    });
  });

  group('ordering of new Quests', () {
    test('a new Quest is placed after all existing Quests', () async {
      final a = await quests.create(draft(name: 'A'));
      final b = await quests.create(draft(name: 'B'));
      await quests.delete(a.id);
      final c = await quests.create(draft(name: 'C'));
      expect(b.sortOrder, greaterThan(a.sortOrder));
      expect(c.sortOrder, greaterThan(b.sortOrder));
    });
  });
}
