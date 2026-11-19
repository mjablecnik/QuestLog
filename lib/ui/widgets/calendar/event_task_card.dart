import 'package:flutter/material.dart';

import '../../../core/calendar/event_xp.dart';
import '../../../core/xp_rules.dart';
import '../../../data/calendar/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/calendar/calendar_labels.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../cards/check_circle.dart';
import '../cards/difficulty_pips.dart';
import '../common/app_icon.dart';

/// The Difficulty tier whose XP an Event_XP value is.
Difficulty difficultyForXp(int xp) => switch (xp) {
  <= 10 => Difficulty.easy,
  <= 25 => Difficulty.normal,
  <= 50 => Difficulty.hard,
  _ => Difficulty.fullDay,
};

/// The XP an occurrence awards, or awarded when it is completed.
int eventTaskXp(EventOccurrence o) =>
    o.completion?.awardedXp ??
    eventXp(type: o.event.type, allDay: o.event.allDay, duration: o.event.duration);

/// One Event_Task on the Board: a calendar event the user has to do today.
///
/// It looks like a Quest card with the colour dot and name of its type, the
/// time, the effort pips and a calendar mark. It cannot be dragged or swiped.
class EventTaskCard extends StatelessWidget {
  const EventTaskCard({
    super.key,
    required this.occurrence,
    required this.onToggle,
    required this.onTap,
  });

  final EventOccurrence occurrence;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final CalendarEvent event = occurrence.event;
    final bool done = occurrence.isCompleted;
    final int xp = eventTaskXp(occurrence);
    final Color nameColor = done ? p.textDim : p.slipText;
    final Color metaColor = done ? p.textFaint : p.slipTextDim;
    final TextStyle meta = context.bodyText.bodySmall!.copyWith(color: metaColor);
    final String time = event.allDay
        ? l.calendar_taskAllDay
        : '${minuteLabel(event.startMinute!)}–${minuteLabel(event.endMinute!)}';
    final BorderRadius radius = BorderRadius.circular(Radii.card);

    final Widget xpText = Text(
      '+$xp',
      style: context.displayText.titleMedium!.copyWith(color: p.brass),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: done ? p.slipDone : p.slip,
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
            padding: const EdgeInsets.fromLTRB(Space.s6, Space.s8, Space.s16, Space.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CheckCircle(
                  checked: done,
                  onTap: onToggle,
                  semanticLabel: done ? l.a11y_reopenEvent(event.name) : l.a11y_completeEvent(event.name),
                ),
                const SizedBox(width: Space.s6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.s6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          event.name,
                          style: context.bodyText.titleMedium!.copyWith(
                            color: nameColor,
                            decoration: done ? TextDecoration.lineThrough : null,
                            decorationColor: p.textFaint,
                          ),
                        ),
                        const SizedBox(height: Space.s4),
                        Wrap(
                          spacing: Space.s8,
                          runSpacing: Space.s4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: Space.s8,
                                  height: Space.s8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: p.eventColor(event.type),
                                  ),
                                ),
                                const SizedBox(width: Space.s6),
                                Text(
                                  eventTypeName(l, event.type),
                                  style: meta.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(time, style: meta),
                            DifficultyPips(
                              difficultyForXp(xp),
                              emptyColor: done ? p.textFaint : p.slipTextFaint,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Space.s8),
                ExcludeSemantics(
                  child: AppIcon(IconAsset.calendar, size: Metrics.iconSmall, color: metaColor),
                ),
                const SizedBox(width: Space.s8),
                done ? Opacity(opacity: 0.7, child: xpText) : xpText,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
