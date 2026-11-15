import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/core/cadence.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/mission_service.dart';
import 'package:questlog/services/quest_service.dart';
import 'package:questlog/services/recurrence_service.dart';
import 'package:questlog/services/settings_service.dart';
import 'package:questlog/services/xp_engine.dart';
import 'package:questlog/ui/forms/validators.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

/// Strings that straddle the limits: padding with whitespace, emoji (surrogate
/// pairs) and lengths around 40, 80 and 500.
Generator<String> get anyFormText => any.combine3(
      any.intInRange(0, 3),
      any.intInRange(0, 520),
      any.choose(['a', '😀', ' ', 'ž', '\t']),
      (pad, length, unit) =>
          '${' ' * pad}${unit * length}${pad == 2 ? '\n' : ''}',
    );

Future<bool> _accepts(Future<Object?> Function() call) async {
  try {
    await call();
    return true;
  } on Object {
    return false;
  }
}

void main() {
  late QuestlogDatabase db;
  late QuestService quests;
  late MissionService missions;
  late SettingsService settings;
  late RecurrenceService rules;

  setUp(() {
    db = createTestDatabase();
    final xp = XpEngine(db);
    final clock = FixedClock(DateTime(2026, 11, 15, 10));
    quests = QuestService(db, xp, clock);
    missions = MissionService(db, xp, clock);
    settings = SettingsService(db);
    rules = RecurrenceService(db, clock);
  });
  tearDown(() => db.close());

  group('examples', () {
    test('validateName boundaries', () {
      expect(validateName(''), FieldError.required);
      expect(validateName('  \t '), FieldError.required);
      expect(validateName('a' * 80), isNull);
      expect(validateName('a' * 81), FieldError.tooLong);
      expect(validateName('  ${'a' * 80}  '), isNull);
      expect(validateName('😀' * 80), isNull);
      expect(validateName('😀' * 81), FieldError.tooLong);
    });

    test('validateNote boundaries', () {
      expect(validateNote(''), isNull);
      expect(validateNote('a' * 500), isNull);
      expect(validateNote('a' * 501), FieldError.noteTooLong);
    });

    test('validateHeroName boundaries', () {
      expect(validateHeroName(''), isNull);
      expect(validateHeroName('   '), isNull);
      expect(validateHeroName('a' * 40), isNull);
      expect(validateHeroName(' ${'a' * 40} '), isNull);
      expect(validateHeroName('a' * 41), FieldError.heroNameTooLong);
    });

    test('validateQuestRowName ignores empty rows', () {
      expect(validateQuestRowName(''), isNull);
      expect(validateQuestRowName('  '), isNull);
      expect(validateQuestRowName('a' * 80), isNull);
      expect(validateQuestRowName('a' * 81), FieldError.tooLong);
    });

    test('validateRuleQuests needs one named template and reports the first error', () {
      expect(validateRuleQuests([]), FieldError.noQuestTemplate);
      expect(validateRuleQuests(['', '  ']), FieldError.noQuestTemplate);
      expect(validateRuleQuests(['', 'Dust']), isNull);
      expect(validateRuleQuests(['Dust', 'a' * 81]), FieldError.tooLong);
      expect(validateRuleQuests(['', 'a' * 81]), FieldError.tooLong);
    });
  });

  group('Property 2: client validation agrees with the domain', () {
    Glados(anyFormText, ExploreConfig(numRuns: 80)).test(
      'validateName matches Quest_Service and Mission_Service',
      (text) async {
        final expected = validateName(text) == null;
        expect(
          await _accepts(
            () => quests.create(
              QuestDraft(name: text, difficulty: Difficulty.normal),
            ),
          ),
          expected,
          reason: 'quest name "$text"',
        );
        expect(
          await _accepts(
            () => missions.create(
              MissionDraft(name: text, bonus: MissionBonus.small),
            ),
          ),
          expected,
          reason: 'mission name "$text"',
        );
      },
    );

    Glados(anyFormText, ExploreConfig(numRuns: 80)).test(
      'validateNote matches Quest_Service',
      (text) async {
        expect(
          await _accepts(
            () => quests.create(
              QuestDraft(name: 'Quest', note: text, difficulty: Difficulty.easy),
            ),
          ),
          validateNote(text) == null,
          reason: 'note of ${text.runes.length} characters',
        );
      },
    );

    Glados(anyFormText, ExploreConfig(numRuns: 80)).test(
      'validateHeroName matches Settings_Service',
      (text) async {
        expect(
          await _accepts(() => settings.setHeroName(text)),
          validateHeroName(text) == null,
          reason: 'hero name "$text"',
        );
      },
    );

    Glados2(anyFormText, anyFormText, ExploreConfig(numRuns: 60)).test(
      'rule name and quest templates match Recurrence_Service',
      (name, template) async {
        final templates = [template, ''];
        final clientOk = validateName(name) == null &&
            validateRuleQuests(templates) == null;
        // Empty rows are dropped by the sheet before the service is called.
        final submitted = [
          for (final t in templates)
            if (t.trim().isNotEmpty)
              RuleQuestDraft(name: t, difficulty: Difficulty.normal),
        ];
        final draft = RuleDraft(
          name: name,
          cadence: Cadence.weekly,
          requestedAnchor: DateTime(2026, 11, 16),
          bonus: MissionBonus.medium,
          quests: submitted,
        );
        expect(
          await _accepts(() => rules.create(draft)),
          clientOk,
          reason: 'name "$name", template "$template"',
        );
      },
    );
  });
}
