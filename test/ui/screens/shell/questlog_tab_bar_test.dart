import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../widgets/common/_harness.dart';

void main() {
  for (final (String, Locale) entry in <(String, Locale)>[
    ('en', const Locale('en')),
    ('cs', const Locale('cs')),
  ]) {
    for (final double scale in <double>[1, 2]) {
      testWidgets('five equal tabs fit 390 px without overflow '
          '(${entry.$1}, text x$scale)', (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildTheme(
              palette: QuestlogPalette.guildBoard,
            ),
            locale: entry.$2,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (BuildContext context, Widget? app) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: app!,
            ),
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: QuestlogTabBar(
                  current: ShellTab.settings,
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        final List<Size> sizes = <Size>[
          for (final ShellTab tab in ShellTab.values)
            tester.getSize(find.byKey(ValueKey<ShellTab>(tab))),
        ];
        expect(sizes, hasLength(5));
        for (final Size size in sizes) {
          expect(size.width, closeTo(390 / 5, 0.01));
          expect(size.height, greaterThanOrEqualTo(Metrics.touchTarget));
        }
        final AppLocalizations l = AppLocalizations.of(
          tester.element(find.byType(QuestlogTabBar)),
        );
        for (final String label in <String>[
          l.app_tabQuests,
          l.app_tabMissions,
          l.app_tabCalendar,
          l.app_tabNotes,
          l.app_tabSettings,
        ]) {
          expect(find.text(label), findsOneWidget);
        }
      });
    }
  }

  for (final (String, QuestlogPalette) entry in <(String, QuestlogPalette)>[
    ('dark', QuestlogPalette.guildBoard),
    ('light', QuestlogPalette.daylight),
  ]) {
    testWidgets('tabs paint no touch, hover or focus highlight (${entry.$1})', (
      tester,
    ) async {
      await pumpCommon(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: QuestlogTabBar(current: ShellTab.missions, onSelected: (_) {}),
        ),
        palette: entry.$2,
      );

      final Iterable<InkWell> tabs = tester.widgetList<InkWell>(
        find.descendant(
          of: find.byType(QuestlogTabBar),
          matching: find.byType(InkWell),
        ),
      );
      expect(tabs, hasLength(ShellTab.values.length));
      for (final InkWell tab in tabs) {
        expect(tab.hoverColor, Colors.transparent);
        expect(tab.focusColor, Colors.transparent);
        expect(tab.highlightColor, Colors.transparent);
        expect(tab.splashColor, Colors.transparent);
        expect(tab.splashFactory, NoSplash.splashFactory);
        for (final WidgetState state in <WidgetState>[
          WidgetState.pressed,
          WidgetState.hovered,
          WidgetState.focused,
        ]) {
          expect(
            tab.overlayColor!.resolve(<WidgetState>{state}),
            Colors.transparent,
          );
        }
      }
    });

    testWidgets('a held tab leaves no ink behind (${entry.$1})', (
      tester,
    ) async {
      await pumpCommon(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: QuestlogTabBar(current: ShellTab.quests, onSelected: (_) {}),
        ),
        palette: entry.$2,
      );

      final TestGesture hold = await tester.startGesture(
        tester.getCenter(
          find.byKey(const ValueKey<ShellTab>(ShellTab.missions)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final RenderObject material = tester.renderObject(
        find.descendant(
          of: find.byType(QuestlogTabBar),
          matching: find.byType(Material),
        ),
      );
      expect(material, isNot(paints..circle()));
      expect(material, isNot(paints..rect(color: entry.$2.brassSoft)));
      await hold.up();
    });
  }
}
