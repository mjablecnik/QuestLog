import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glados/glados.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/providers.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/test_database.dart';

void main() {
  test('providers wire the services onto one database and clock', () async {
    final db = createTestDatabase();
    final clock = FixedClock(DateTime(2026, 11, 15, 10));
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    // Riverpod pauses a provider nobody listens to, so keep the streams alive.
    for (final provider in [
      totalXpProvider,
      settingsProvider,
      openBoardProvider,
      rulesProvider,
      openMissionsProvider,
    ]) {
      container.listen(provider, (_, _) {});
    }
    final doneToday = doneTodayProvider(DateTime(2026, 11, 15));
    container.listen(doneToday, (_, _) {});

    final quest = await container
        .read(questServiceProvider)
        .create(const QuestDraft(name: 'Wired', difficulty: Difficulty.hard));
    await container.read(questServiceProvider).complete(quest.id);

    await pumpEventQueue();
    expect(container.read(totalXpProvider).value, 50);
    expect((await container.read(settingsProvider.future)).heroName, '');
    expect(await container.read(openBoardProvider.future), isEmpty);
    expect(await container.read(rulesProvider.future), isEmpty);
    expect(await container.read(openMissionsProvider.future), isEmpty);
    expect((await container.read(doneToday.future)).single.name, 'Wired');
  });
}
