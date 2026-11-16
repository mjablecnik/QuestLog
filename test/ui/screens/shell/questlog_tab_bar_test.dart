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
    testWidgets('tabs paint no hover or focus highlight (${entry.$1})', (
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
      }
    });
  }
}
