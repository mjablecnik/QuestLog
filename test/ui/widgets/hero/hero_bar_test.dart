import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/hero/hero_bar.dart';
import 'package:questlog/ui/widgets/hero/level_badge.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/test_database.dart';
import '../common/_harness.dart';

class _Fixture {
  _Fixture(this.db, this.container);

  final QuestlogDatabase db;
  final ProviderContainer container;
}

/// Pumps a [HeroBar] over an in-memory database seeded with [startXp] and
/// waits for the first data.
Future<_Fixture> _pumpHero(
  WidgetTester tester, {
  int startXp = 0,
  bool disableAnimations = false,
}) async {
  final db = createTestDatabase();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 15, 12))),
    ],
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
  if (startXp > 0) await container.read(xpEngineProvider).apply(startXp);
  await pumpCommon(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: const HeroBar(),
    ),
    disableAnimations: disableAnimations,
  );
  await tester.pumpAndSettle();
  return _Fixture(db, container);
}

double _fill(WidgetTester tester) => tester
    .widget<FractionallySizedBox>(find.byKey(heroBarFillKey))
    .widthFactor!;

/// Lets a Drift stream deliver its next event.
Future<void> _deliver(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump();
  }
}

/// Completes a fresh quest of [difficulty] through the real service.
Future<void> _earn(_Fixture f, Difficulty difficulty) async {
  final quests = f.container.read(questServiceProvider);
  final quest = await quests.create(
    QuestDraft(name: 'Quest', difficulty: difficulty),
  );
  await quests.complete(quest.id);
}

/// Samples the bar width every [step] for [total].
Future<List<double>> _sample(
  WidgetTester tester, {
  Duration step = const Duration(milliseconds: 50),
  Duration total = const Duration(milliseconds: 2000),
}) async {
  final values = <double>[_fill(tester)];
  for (var t = Duration.zero; t < total; t += step) {
    await tester.pump(step);
    values.add(_fill(tester));
  }
  return values;
}

void main() {
  group('texts', () {
    testWidgets('without a hero name only the Level line is shown', (
      tester,
    ) async {
      await _pumpHero(tester);

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.textContaining('·'), findsNothing);
      expect(find.text('0 / 100 XP'), findsOneWidget);
      expect(find.text('100 XP to level 2'), findsOneWidget);
      expect(_fill(tester), 0);
    });

    testWidgets('a hero name is shown before the Level and can be cleared', (
      tester,
    ) async {
      final f = await _pumpHero(tester);
      final settings = f.container.read(settingsServiceProvider);

      await settings.setHeroName('Martin');
      await tester.pumpAndSettle();
      expect(find.text('Martin · Level 1'), findsOneWidget);
      expect(find.text('Level 1'), findsNothing);

      await settings.setHeroName('   ');
      await tester.pumpAndSettle();
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.textContaining('Martin'), findsNothing);
    });

    testWidgets('shows XP inside the Level, the threshold and the remainder', (
      tester,
    ) async {
      await _pumpHero(tester, startXp: 40);

      expect(find.text('40 / 100 XP'), findsOneWidget);
      expect(find.text('60 XP to level 2'), findsOneWidget);
      expect(_fill(tester), closeTo(0.4, 1e-9));
      // The badge carries the Level.
      expect(
        find.descendant(of: find.byType(LevelBadge), matching: find.text('1')),
        findsOneWidget,
      );
    });

    testWidgets('figures use locale grouping and tabular numerals', (
      tester,
    ) async {
      // Deep into the Levels the threshold passes 1 000 XP.
      const total = 12000;
      final expected = progressFor(total);
      await _pumpHero(tester, startXp: total);

      final threshold = expected.threshold;
      expect(threshold, greaterThanOrEqualTo(1000));
      expect(find.text('Level ${expected.level}'), findsOneWidget);
      final progressText = find.textContaining(' / 1,');
      expect(progressText, findsOneWidget);
      final style = tester.widget<Text>(progressText).style!;
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    });
  });

  group('progress animation', () {
    testWidgets('moves smoothly to the new value within one Level', (
      tester,
    ) async {
      final f = await _pumpHero(tester, startXp: 40);

      await _earn(f, Difficulty.normal); // +25 -> 65 / 100
      await _deliver(tester);
      await tester.pump(Motion.progress ~/ 2);

      final mid = _fill(tester);
      expect(mid, greaterThan(0.4));
      expect(mid, lessThan(0.65));
      expect(find.text('40 / 100 XP'), findsNothing);
      expect(find.text('65 / 100 XP'), findsOneWidget);

      await tester.pump(Motion.progress);
      expect(_fill(tester), closeTo(0.65, 1e-9));
    });

    testWidgets('a Level-up fills the bar to its end, then wraps', (
      tester,
    ) async {
      final f = await _pumpHero(tester, startXp: 90);
      expect(_fill(tester), closeTo(0.9, 1e-9));

      await _earn(f, Difficulty.hard); // +50 -> level 2, 40 / 150
      await _deliver(tester);

      // The badge and texts update at once.
      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text('40 / 150 XP'), findsOneWidget);

      final values = await _sample(tester);

      // Fills up first: no value below the old fraction before the end.
      final end = values.indexWhere((v) => v >= 1 - 1e-9);
      expect(end, greaterThan(0));
      expect(values.sublist(0, end + 1).every((v) => v >= 0.9 - 1e-9), isTrue);
      // Then restarts at empty and settles on the new Level's fraction.
      final wrapped = values.sublist(end + 1);
      expect(wrapped.first, lessThan(0.5));
      expect(wrapped.last, closeTo(40 / 150, 1e-9));
      var drops = 0;
      for (var i = 1; i < values.length; i++) {
        if (values[i] < values[i - 1] - 1e-9) drops++;
      }
      expect(drops, 1, reason: 'exactly one wrap from full to empty');
    });

    testWidgets('reduced motion jumps within the fade time and never wraps', (
      tester,
    ) async {
      final f = await _pumpHero(tester, startXp: 90, disableAnimations: true);

      await _earn(f, Difficulty.hard);
      await _deliver(tester);
      expect(find.text('Level 2'), findsOneWidget);

      final values = await _sample(
        tester,
        step: const Duration(milliseconds: 25),
        total: Motion.reducedFade + const Duration(milliseconds: 25),
      );
      expect(values.last, closeTo(40 / 150, 1e-9));
      expect(values.every((v) => v < 1 - 1e-9), isTrue);
    });

    testWidgets(
      'a second update during the wrap still ends on the latest value',
      (tester) async {
        final f = await _pumpHero(tester, startXp: 90);

        await _earn(f, Difficulty.hard); // level 2, 40 / 150
        await _deliver(tester);
        await tester.pump(Motion.progress ~/ 2);

        await _earn(f, Difficulty.hard); // 90 / 150
        await _deliver(tester);
        final values = await _sample(tester);

        expect(values.last, closeTo(90 / 150, 1e-9));
        expect(values.any((v) => v >= 1 - 1e-9), isTrue);
      },
    );
  });

  group('LevelBadge', () {
    testWidgets('is a 52px circle showing the Level', (tester) async {
      await pumpCommon(tester, const Center(child: LevelBadge(level: 12)));

      expect(find.text('12'), findsOneWidget);
      expect(
        tester.getSize(find.byType(LevelBadge)),
        const Size.square(Metrics.levelBadge),
      );
      expect(find.bySemanticsLabel('Level 12'), findsOneWidget);
    });
  });
}
