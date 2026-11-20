import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/ui/theme/questlog_theme.dart';
import 'package:questlog/ui/theme/tokens.dart';

/// Pumps [child] in a themed, localized app; width is generous unless set.
Future<void> pumpCards(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  bool disableAnimations = false,
  QuestlogPalette palette = QuestlogPalette.guildBoard,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(palette: palette),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: app!,
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(Space.s16),
          child: Align(alignment: Alignment.topCenter, child: child),
        ),
      ),
    ),
  );
}

Quest boardQuest({
  int id = 1,
  String name = 'Take out the trash',
  Difficulty difficulty = Difficulty.normal,
  DateTime? completedAt,
  int? awardedXp,
}) => Quest(
  id: id,
  name: name,
  note: null,
  difficulty: difficulty,
  missionId: null,
  sortOrder: 0,
  createdAt: DateTime(2026, 11, 15, 8),
  completedAt: completedAt,
  awardedXp: awardedXp,
);

MissionSummary missionSummary({
  String name = 'Clean-up',
  int done = 2,
  int total = 5,
  int remainingXp = 75,
  MissionBonus bonus = MissionBonus.small,
  MissionStatus status = MissionStatus.open,
  DateTime? completedAt,
  int? awardedBonus,
}) => MissionSummary(
  id: 1,
  name: name,
  bonus: bonus,
  status: status,
  done: done,
  total: total,
  remainingXp: remainingXp,
  ruleId: null,
  completedAt: completedAt,
  awardedBonus: awardedBonus,
);
