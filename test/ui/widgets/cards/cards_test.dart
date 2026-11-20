import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:questlog/ui/widgets/cards/check_circle.dart';
import 'package:questlog/ui/widgets/cards/difficulty_pips.dart';
import 'package:questlog/ui/widgets/cards/mission_card.dart';
import 'package:questlog/ui/widgets/cards/quest_card.dart';

import '_cards_harness.dart';

const Locale cs = Locale('cs');
const Locale en = Locale('en');

Finder get _filledPips => find.byKey(const ValueKey<String>('pip-on'));
Finder get _emptyPips => find.byKey(const ValueKey<String>('pip-off'));

TextDecoration? _decorationOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.decoration;

void main() {
  group('DifficultyPips', () {
    test('pip count follows the difficulty', () {
      expect(pipCount(Difficulty.easy), 1);
      expect(pipCount(Difficulty.normal), 2);
      expect(pipCount(Difficulty.hard), 3);
      expect(pipCount(Difficulty.fullDay), 4);
    });

    test('there are four pips in total', () {
      expect(DifficultyPips.total, 4);
    });

    for (final Difficulty d in Difficulty.values) {
      testWidgets('${d.name}: ${pipCount(d)} filled of 4', (tester) async {
        await pumpCards(tester, DifficultyPips(d));
        expect(_filledPips, findsNWidgets(pipCount(d)));
        expect(_emptyPips, findsNWidgets(4 - pipCount(d)));
      });
    }
  });

  group('CheckCircle', () {
    testWidgets('hit area is at least 44x44 and the corner is tappable', (
      tester,
    ) async {
      int taps = 0;
      await pumpCards(
        tester,
        CheckCircle(
          checked: false,
          semanticLabel: 'Complete quest X',
          onTap: () => taps++,
        ),
      );

      final Size size = tester.getSize(find.byType(CheckCircle));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));

      // A point inside the hit area but outside the 28px painted circle.
      final Rect rect = tester.getRect(find.byType(CheckCircle));
      await tester.tapAt(rect.topLeft + const Offset(2, 2));
      expect(taps, 1);
    });

    testWidgets('exposes label, checked state and a tap action', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpCards(
        tester,
        CheckCircle(
          checked: true,
          semanticLabel: 'Reopen quest X',
          onTap: () {},
        ),
      );
      expect(
        tester.getSemantics(find.byType(CheckCircle)),
        matchesSemantics(
          label: 'Reopen quest X',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasCheckedState: true,
          isChecked: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    for (final bool reduced in <bool>[false, true]) {
      testWidgets('toggles without errors (reduced motion: $reduced)', (
        tester,
      ) async {
        bool checked = false;
        await pumpCards(
          tester,
          StatefulBuilder(
            builder: (BuildContext context, StateSetter set) => CheckCircle(
              checked: checked,
              semanticLabel: 'x',
              onTap: () => set(() => checked = !checked),
            ),
          ),
          disableAnimations: reduced,
        );
        await tester.tap(find.byType(CheckCircle));
        await tester.pumpAndSettle();
        expect(checked, isTrue);
        final AnimatedOpacity tick = tester.widget(
          find.byType(AnimatedOpacity),
        );
        expect(tick.opacity, 1);
        if (reduced) {
          expect(tick.duration.inMilliseconds, lessThanOrEqualTo(150));
        }
      });
    }
  });

  group('QuestCard', () {
    for (final Locale locale in <Locale>[en, cs]) {
      final bool isCs = locale == cs;

      testWidgets('open shows name, pips and XP, no mission text ($locale)', (
        tester,
      ) async {
        await pumpCards(
          tester,
          QuestCard(
            quest: boardQuest(name: 'Sweep', difficulty: Difficulty.normal),
            onToggle: () {},
          ),
          locale: locale,
        );
        expect(find.text('Sweep'), findsOneWidget);
        expect(find.text(isCs ? 'bez mise' : 'no mission'), findsNothing);
        expect(_filledPips, findsNWidgets(2));
        expect(_emptyPips, findsNWidgets(2));
        expect(find.text('+25'), findsOneWidget);
        expect(
          _decorationOf(tester, 'Sweep'),
          isNot(TextDecoration.lineThrough),
        );
      });

      testWidgets('open full-day quest fills all four pips ($locale)', (
        tester,
      ) async {
        await pumpCards(
          tester,
          QuestCard(
            quest: boardQuest(difficulty: Difficulty.fullDay),
            onToggle: () {},
          ),
          locale: locale,
        );
        expect(_filledPips, findsNWidgets(4));
        expect(find.text('+100'), findsOneWidget);
      });

      testWidgets(
        'done: strike-through, completion time, recorded XP ($locale)',
        (tester) async {
          final DateTime at = DateTime(2026, 11, 15, 8, 52);
          await pumpCards(
            tester,
            Builder(
              builder: (BuildContext context) {
                final String label = questCompletedLabel(
                  AppLocalizations.of(context),
                  at,
                  DateTime(2026, 11, 15),
                );
                return QuestCard(
                  quest: boardQuest(
                    name: 'Dishes',
                    difficulty: Difficulty.easy,
                    completedAt: at,
                    awardedXp: 10,
                  ),
                  completedLabel: label,
                  onToggle: () {},
                );
              },
            ),
            locale: locale,
          );
          expect(_decorationOf(tester, 'Dishes'), TextDecoration.lineThrough);
          expect(find.text(isCs ? 'dnes 8:52' : 'today 08:52'), findsOneWidget);
          expect(find.text('+10'), findsOneWidget);
          expect(
            tester.widget<CheckCircle>(find.byType(CheckCircle)).checked,
            isTrue,
          );
        },
      );
    }

    testWidgets('semantic label of the check follows the state', (
      tester,
    ) async {
      await pumpCards(
        tester,
        Column(
          children: <Widget>[
            QuestCard(
              quest: boardQuest(name: 'Open one'),
              onToggle: () {},
            ),
            QuestCard(
              quest: boardQuest(
                id: 2,
                name: 'Done one',
                completedAt: DateTime(2026, 11, 15, 9),
                awardedXp: 25,
              ),
              onToggle: () {},
            ),
          ],
        ),
      );
      final List<CheckCircle> checks = tester
          .widgetList<CheckCircle>(find.byType(CheckCircle))
          .toList();
      expect(checks[0].semanticLabel, 'Complete quest Open one');
      expect(checks[1].semanticLabel, 'Reopen quest Done one');
    });

    testWidgets('check calls onToggle, body calls onTap, trailing is shown', (
      tester,
    ) async {
      int toggled = 0;
      int tapped = 0;
      await pumpCards(
        tester,
        QuestCard(
          quest: boardQuest(name: 'Sweep'),
          onToggle: () => toggled++,
          onTap: () => tapped++,
          trailing: const SizedBox(key: ValueKey<String>('handle'), width: 20),
        ),
      );
      expect(find.byKey(const ValueKey<String>('handle')), findsOneWidget);

      await tester.tap(find.byType(CheckCircle));
      expect(toggled, 1);
      expect(tapped, 0);

      await tester.tap(find.text('Sweep'));
      expect(tapped, 1);
      expect(toggled, 1);
    });

    testWidgets('light theme draws the parchment-edge outline', (tester) async {
      await pumpCards(
        tester,
        QuestCard(quest: boardQuest(), onToggle: () {}),
        palette: QuestlogPalette.daylight,
      );
      final DecoratedBox box = tester.widget(
        find
            .descendant(
              of: find.byType(QuestCard),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final BoxDecoration d = box.decoration as BoxDecoration;
      expect(d.border, isNotNull);
      expect(
        (d.border! as Border).top.color,
        QuestlogPalette.daylight.parchmentEdge,
      );
    });

    final List<QuestlogPalette> darkPalettes = <QuestlogPalette>[
      QuestlogPalette.guildBoard,
    ];
    for (int i = 0; i < darkPalettes.length; i++) {
      final QuestlogPalette p = darkPalettes[i];
      testWidgets('dark theme: an open card is a raised dark card '
          '(palette #$i)', (tester) async {
        await pumpCards(
          tester,
          QuestCard(quest: boardQuest(), onToggle: () {}),
          palette: p,
        );
        final BoxDecoration d = _cardDecoration(tester);
        expect(d.color, p.boardRaised);
        expect((d.border! as Border).top.color, p.boardLine);
        expect(d.boxShadow, isNull);
        expect(
          tester.widget<Text>(find.text('Take out the trash')).style!.color,
          p.text,
        );
        expect(tester.widget<Text>(find.text('+25')).style!.color, p.brass);
      });

      testWidgets('dark theme: a done card is outlined, not filled '
          '(palette #$i)', (tester) async {
        await pumpCards(
          tester,
          QuestCard(
            quest: boardQuest(completedAt: DateTime(2026, 11, 15, 9)),
            onToggle: () {},
          ),
          palette: p,
        );
        final BoxDecoration d = _cardDecoration(tester);
        expect(d.color, const Color(0x00000000));
        expect((d.border! as Border).top.color, p.boardLine);
        final Text name = tester.widget(find.text('Take out the trash'));
        expect(name.style!.decoration, TextDecoration.lineThrough);
        expect(name.style!.color, p.textDim);
      });
    }

    testWidgets('light theme: an open card keeps the parchment slip', (
      tester,
    ) async {
      final QuestlogPalette p = QuestlogPalette.daylight;
      await pumpCards(
        tester,
        QuestCard(quest: boardQuest(), onToggle: () {}),
        palette: p,
      );
      final BoxDecoration d = _cardDecoration(tester);
      expect(d.color, p.parchment);
      expect(d.boxShadow, isNotNull);
      expect(
        tester.widget<Text>(find.text('Take out the trash')).style!.color,
        p.ink,
      );
    });

    testWidgets('long names and 130% text do not overflow at 320 wide', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpCards(
        tester,
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: SizedBox(
            width: 288,
            child: QuestCard(
              quest: boardQuest(
                name: 'A very long quest name that has to wrap onto lines',
                difficulty: Difficulty.hard,
              ),
              onToggle: () {},
              trailing: const SizedBox(width: 24),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('questCompletedLabel', () {
    testWidgets('today, yesterday and older dates', (tester) async {
      late String today, yesterday, older;
      await pumpCards(
        tester,
        Builder(
          builder: (BuildContext context) {
            final l = AppLocalizations.of(context);
            final DateTime day = DateTime(2026, 11, 15);
            today = questCompletedLabel(l, DateTime(2026, 11, 15, 9, 5), day);
            yesterday = questCompletedLabel(l, DateTime(2026, 11, 14, 12), day);
            older = questCompletedLabel(l, DateTime(2026, 11, 2, 12), day);
            return const SizedBox();
          },
        ),
      );
      expect(today, 'today 09:05');
      expect(yesterday, 'yesterday');
      expect(older, contains('11'));
    });
  });

  group('MissionCard', () {
    for (final Locale locale in <Locale>[en, cs]) {
      final bool isCs = locale == cs;

      testWidgets('open shows ring text, remaining XP and bonus ($locale)', (
        tester,
      ) async {
        await pumpCards(
          tester,
          MissionCard(
            mission: missionSummary(done: 2, total: 5, remainingXp: 75),
          ),
          locale: locale,
        );
        expect(find.text('Clean-up'), findsOneWidget);
        expect(
          find.text(isCs ? 'Zbývá: 75 XP' : 'Remaining: 75 XP'),
          findsOneWidget,
        );
        expect(find.text('+50'), findsOneWidget);
        expect(
          find.text(isCs ? 'ZA DOKONČENÍ' : 'ON COMPLETION'),
          findsOneWidget,
        );
        // 2 of 5 quests are done, so the ring shows the 3 still open.
        expect(find.text('3'), findsOneWidget);
        expect(
          find.text(isCs ? 'Připraveno k dokončení' : 'Ready to complete'),
          findsNothing,
        );
      });

      testWidgets('all quests done shows the ready caption ($locale)', (
        tester,
      ) async {
        await pumpCards(
          tester,
          MissionCard(
            mission: missionSummary(done: 3, total: 3, remainingXp: 0),
          ),
          locale: locale,
        );
        expect(
          find.text(isCs ? 'Připraveno k dokončení' : 'Ready to complete'),
          findsOneWidget,
        );
        expect(find.textContaining('XP'), findsNothing);
      });
    }

    testWidgets('completed shows earned bonus, caption and quest count', (
      tester,
    ) async {
      await pumpCards(
        tester,
        MissionCard(
          mission: missionSummary(
            name: 'Holiday prep',
            done: 6,
            total: 6,
            remainingXp: 0,
            bonus: MissionBonus.medium,
            status: MissionStatus.completed,
            completedAt: DateTime(2026, 11, 15, 7, 52),
            awardedBonus: 150,
          ),
          completedTime: '7:52',
        ),
      );
      expect(find.text('+150'), findsOneWidget);
      expect(find.text('EARNED'), findsOneWidget);
      expect(find.text('6 quests · completed today at 7:52'), findsOneWidget);
    });

    testWidgets('tap calls the callback; ring at zero draws no arc', (
      tester,
    ) async {
      int taps = 0;
      await pumpCards(
        tester,
        MissionCard(
          mission: missionSummary(done: 0, total: 4, remainingXp: 100),
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('Clean-up'));
      expect(taps, 1);
      final RenderBox paint = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey<String>('progress-ring-paint')),
      );
      expect(paint, paintsExactlyCountTimes(#drawArc, 0));
    });
  });

  group('QuestCard deadline', () {
    final DateTime today = DateTime(2026, 11, 20);

    testWidgets(
      'an open Quest shows its Deadline, and "Overdue" once it has passed',
      (tester) async {
        await pumpCards(
          tester,
          QuestCard(
            quest: boardQuest(),
            onToggle: () {},
            deadline: DateTime(2026, 11, 25),
            today: today,
          ),
        );
        expect(find.text('Due 11/25/2026'), findsOneWidget);
        await pumpCards(
          tester,
          QuestCard(
            quest: boardQuest(),
            onToggle: () {},
            deadline: DateTime(2026, 11, 19),
            today: today,
          ),
        );
        expect(find.text('Overdue: 11/19/2026'), findsOneWidget);
        final Text text = tester.widget<Text>(
          find.byKey(const ValueKey<String>('quest-deadline')),
        );
        expect(text.style!.color, QuestlogPalette.guildBoard.destructiveText);
        await pumpCards(
          tester,
          QuestCard(
            quest: boardQuest(),
            onToggle: () {},
            deadline: today,
            today: today,
          ),
        );
        expect(find.text('Due 11/20/2026'), findsOneWidget);
      },
    );

    testWidgets(
      'a done Quest is never shown as overdue and shows no Deadline',
      (tester) async {
        await pumpCards(
          tester,
          QuestCard(
            quest: boardQuest(
              completedAt: DateTime(2026, 11, 20, 8),
              awardedXp: 25,
            ),
            onToggle: () {},
            deadline: DateTime(2026, 11, 1),
            today: today,
          ),
        );
        expect(
          find.byKey(const ValueKey<String>('quest-deadline')),
          findsNothing,
        );
      },
    );
  });
}

BoxDecoration _cardDecoration(WidgetTester tester) {
  final DecoratedBox box = tester.widget(
    find
        .descendant(
          of: find.byType(QuestCard),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return box.decoration as BoxDecoration;
}
