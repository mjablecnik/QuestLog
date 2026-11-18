import 'package:glados/glados.dart';
import 'package:questlog/core/xp_rules.dart';

void main() {
  group('XP values', () {
    test('Difficulty XP', () {
      expect(Difficulty.easy.xp, 10);
      expect(Difficulty.normal.xp, 25);
      expect(Difficulty.hard.xp, 50);
      expect(Difficulty.fullDay.xp, 100);
    });

    test('there are four effort tiers and their XP strictly grows', () {
      expect(Difficulty.values, hasLength(4));
      final xp = [for (final d in Difficulty.values) d.xp];
      expect(xp, [10, 25, 50, 100]);
    });

    test('the stored enum names of the first three tiers did not change', () {
      expect([for (final d in Difficulty.values) d.name], ['easy', 'normal', 'hard', 'fullDay']);
    });

    test('Mission_Bonus XP', () {
      expect(MissionBonus.small.xp, 50);
      expect(MissionBonus.medium.xp, 100);
      expect(MissionBonus.large.xp, 200);
    });
  });

  group('levels unit cases', () {
    test('0 XP is Level 1', () => expect(levelFor(0), 1));
    test('99 XP is Level 1', () => expect(levelFor(99), 1));
    test('100 XP is Level 2', () => expect(levelFor(100), 2));
    test('249 XP is Level 2', () => expect(levelFor(249), 2));
    test('250 XP is Level 3', () => expect(levelFor(250), 3));

    test('thresholds and cumulative XP follow the table', () {
      expect([for (var l = 1; l <= 4; l++) levelThreshold(l)], [100, 150, 200, 250]);
      expect([for (var l = 1; l <= 4; l++) xpToReachLevel(l)], [0, 100, 250, 450]);
    });

    test('progressFor reports XP inside the level', () {
      expect(
        progressFor(120),
        const LevelProgress(level: 2, xpIntoLevel: 20, threshold: 150),
      );
      expect(
        progressFor(0),
        const LevelProgress(level: 1, xpIntoLevel: 0, threshold: 100),
      );
    });

    test('there is no upper level limit', () {
      expect(levelFor(xpToReachLevel(5000)), 5000);
      expect(levelFor(xpToReachLevel(5000) - 1), 4999);
    });
  });

  group('a whole-day Quest (+100 XP) against the unchanged level curve', () {
    test('exactly fills Level 1', () {
      expect(progressFor(Difficulty.fullDay.xp),
          const LevelProgress(level: 2, xpIntoLevel: 0, threshold: 150));
    });

    test('from 90 XP it lands inside Level 2', () {
      expect(progressFor(90 + Difficulty.fullDay.xp),
          const LevelProgress(level: 2, xpIntoLevel: 90, threshold: 150));
    });

    test('from 249 XP it crosses into Level 3', () {
      // Level 3 starts at 250 XP; 249 + 100 = 349 is 99 of 200 into Level 3.
      expect(progressFor(249 + Difficulty.fullDay.xp),
          const LevelProgress(level: 3, xpIntoLevel: 99, threshold: 200));
    });

    test('with a large Mission bonus it can skip a whole level', () {
      // 0 XP + 100 + 200 = 300: Level 1 -> Level 3, bar 50 of 200.
      final total = Difficulty.fullDay.xp + MissionBonus.large.xp;
      expect(levelFor(0), 1);
      expect(progressFor(total),
          const LevelProgress(level: 3, xpIntoLevel: 50, threshold: 200));
    });

    Glados(any.intInRange(0, 200000)).test('the bar never overflows after +100', (xp) {
      final p = progressFor(xp + Difficulty.fullDay.xp);
      expect(p.xpIntoLevel, inInclusiveRange(0, p.threshold - 1));
      // One whole-day Quest alone can skip at most one level while the
      // threshold is at least 100 (level thresholds are 100, 150, 200, ...).
      expect(levelFor(xp + Difficulty.fullDay.xp) - levelFor(xp), lessThanOrEqualTo(1));
    });
  });

  // Feature: questlog-domain, Property 1: Level derivation is consistent with thresholds
  group('Property 1: Level derivation is consistent with thresholds', () {
    final anyXp = any.intInRange(0, 5000000);

    Glados(anyXp).test('levelFor is the largest level whose cumulative XP is reached', (xp) {
      final level = levelFor(xp);
      expect(xpToReachLevel(level) <= xp, isTrue);
      expect(xpToReachLevel(level + 1) > xp, isTrue);
    });

    Glados(anyXp).test('xpIntoLevel is within [0, threshold)', (xp) {
      final p = progressFor(xp);
      expect(p.xpIntoLevel, greaterThanOrEqualTo(0));
      expect(p.xpIntoLevel, lessThan(p.threshold));
      expect(p.threshold, levelThreshold(p.level));
      expect(xpToReachLevel(p.level) + p.xpIntoLevel, xp);
    });

    Glados2(anyXp, any.intInRange(0, 100000)).test('levelFor never decreases as XP grows', (xp, extra) {
      expect(levelFor(xp + extra) >= levelFor(xp), isTrue);
    });
  });
}
