import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:questlog/ui/theme/tokens.dart';

import '../../widgets/common/_harness.dart';

void main() {
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
