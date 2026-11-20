import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/board_day.dart';
import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import 'check_circle.dart';
import 'deadline_label.dart';
import 'difficulty_pips.dart';

/// Completion time label of a done Quest: "today 8:52", "yesterday" or a date.
///
/// [today] is the calendar date of the current Board_Day.
String questCompletedLabel(
  AppLocalizations l,
  DateTime completedAt,
  DateTime today,
) {
  final DateTime day = todayOf(completedAt);
  final String locale = l.localeName;
  if (day == today) {
    return l.quest_completedTodayAt(DateFormat.Hm(locale).format(completedAt));
  }
  if (day == DateTime(today.year, today.month, today.day - 1)) {
    return l.quest_completedYesterday;
  }
  return l.quest_completedOn(DateFormat.yMd(locale).format(completedAt));
}

/// One Quest on the board: a parchment slip while open (light theme) or a dark
/// raised card (dark theme), a dimmed card once done.
class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.quest,
    required this.onToggle,
    this.onTap,
    this.completedLabel,
    this.missionName,
    this.trailing,
    this.deadline,
    this.today,
  });

  final Quest quest;

  /// The Deadline of the Quest, shown while it is open, with the Board_Day date
  /// [today] that decides whether it is overdue.
  final DateTime? deadline;
  final DateTime? today;

  /// The check circle: completes an open Quest, reopens a done one.
  final VoidCallback onToggle;

  /// The card body, normally opens the edit sheet.
  final VoidCallback? onTap;

  /// Already localized completion time, shown in the meta row of a done Quest.
  final String? completedLabel;

  /// Name of the Mission the Quest belongs to, shown in the meta row.
  final String? missionName;

  /// Slot at the right end, for the drag handle of a reorderable list.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final bool done = quest.isDone;
    final int xp = quest.awardedXp ?? quest.difficulty.xp;

    final Color nameColor = done ? p.textDim : p.slipText;
    final Color metaColor = done ? p.textFaint : p.slipTextDim;
    final TextStyle meta = context.bodyText.bodySmall!.copyWith(
      color: metaColor,
    );

    final List<Widget> metaRow = <Widget>[
      DifficultyPips(
        quest.difficulty,
        emptyColor: done ? p.textFaint : p.slipTextFaint,
      ),
      if (missionName != null)
        Text(missionName!, style: meta.copyWith(fontWeight: FontWeight.w600)),
      if (done && completedLabel != null) Text(completedLabel!, style: meta),
      if (!done && deadline != null && today != null)
        DeadlineLabel(deadline: deadline!, today: today!, style: meta),
    ];

    final Widget xpText = Text(
      '+$xp',
      style: context.displayText.titleMedium!.copyWith(color: p.brass),
    );

    final BorderRadius radius = BorderRadius.circular(Radii.card);
    final Color ground = done ? p.slipDone : p.slip;
    // Daylight draws the parchment-edge outline and a soft shadow on every
    // Quest card, done ones included (the artboard does); the dark theme has
    // the faint board line and no shadow.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ground,
        borderRadius: radius,
        border: Border.all(color: p.slipEdge, width: Metrics.hairline),
        boxShadow: p.isLight
            ? <BoxShadow>[
                BoxShadow(
                  color: p.ink.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, Space.s6),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.s6,
              Space.s8,
              Space.s16,
              Space.s8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CheckCircle(
                  checked: done,
                  onTap: onToggle,
                  semanticLabel: done
                      ? l.a11y_reopenQuest(quest.name)
                      : l.a11y_completeQuest(quest.name),
                ),
                const SizedBox(width: Space.s6),
                Expanded(
                  child: Padding(
                    // With the card's own 8 this makes the artboard's 14 above and below.
                    padding: const EdgeInsets.symmetric(vertical: Space.s6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          quest.name,
                          style: context.bodyText.titleMedium!.copyWith(
                            color: nameColor,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: p.textFaint,
                          ),
                        ),
                        const SizedBox(height: Space.s4),
                        Wrap(
                          spacing: Space.s8,
                          runSpacing: Space.s4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: metaRow,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Space.s8),
                done ? Opacity(opacity: 0.7, child: xpText) : xpText,
                if (trailing != null) ...<Widget>[
                  const SizedBox(width: Space.s4),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
