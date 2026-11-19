import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calendar/event_type.dart';
import '../../../data/calendar/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/calendar_state.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/sheet/questlog_sheet.dart';
import 'calendar_labels.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';
import 'month_grid.dart';

/// Opens the Day_Sheet of [date]: its events, all-day first, then by time.
Future<void> showDaySheet(BuildContext context, DateTime date) =>
    showQuestlogSheet<void>(context, builder: (BuildContext _) => DaySheet(date: date));

class DaySheet extends ConsumerWidget {
  const DaySheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    final List<EventOccurrence> events = MonthPage.forDate(
      ref.watch(dayOccurrencesProvider(date)).value ?? const <EventOccurrence>[],
      date,
    );
    return Material(
      color: p.sheet,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.78),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: (DragEndDetails d) {
                if ((d.primaryVelocity ?? 0) > 700) Navigator.of(context).maybePop();
              },
              child: Column(
                children: <Widget>[
                  ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s8),
                      child: Container(
                        width: Metrics.grabberWidth,
                        height: Metrics.grabberHeight,
                        decoration: BoxDecoration(
                          color: p.textFaint,
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Space.s20, 0, Space.s8, Space.s8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Semantics(
                                header: true,
                                namesRoute: true,
                                child: Text(
                                  dayHeading(date, l.localeName),
                                  style: context.displayText.headlineMedium,
                                ),
                              ),
                              Text(
                                l.calendar_dayEvents(events.length),
                                style: context.bodyText.bodySmall!.copyWith(color: p.textDim),
                              ),
                            ],
                          ),
                        ),
                        _RoundButton(
                          key: const ValueKey<String>('day-add'),
                          icon: IconAsset.plus,
                          label: l.calendar_add,
                          filled: true,
                          onTap: () => showEventForm(context, presetDate: date),
                        ),
                        _RoundButton(
                          key: const ValueKey<String>('day-close'),
                          icon: IconAsset.close,
                          label: l.common_close,
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: events.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(Space.s20, Space.s16, Space.s20, Space.s24),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          l.calendar_dayEmpty,
                          style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(Space.s20, 0, Space.s20, Space.s16 + media.padding.bottom),
                      itemCount: events.length,
                      itemBuilder: (BuildContext context, int i) => _EventRow(
                        occurrence: events[i],
                        date: date,
                        first: i == 0,
                      ),
                    ),
            ),
            if (events.isEmpty) SizedBox(height: media.padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: Metrics.touchTarget,
          height: Metrics.touchTarget,
          child: Center(
            child: Container(
              width: Metrics.iconButton + Space.s4,
              height: Metrics.iconButton + Space.s4,
              decoration: BoxDecoration(shape: BoxShape.circle, color: filled ? p.brass : null),
              child: Center(
                child: AppIcon(
                  icon,
                  size: Metrics.iconSmall,
                  color: filled ? p.inkOnBrass : p.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.occurrence, required this.date, required this.first});

  final EventOccurrence occurrence;
  final DateTime date;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final CalendarEvent event = occurrence.event;
    final EventType type = event.type;
    final Color color = p.eventColor(type);
    final ({String start, String end})? times = timesOn(event, occurrence.start, date);
    final TextStyle timeStyle = context.bodyText.bodySmall!.copyWith(color: p.textDim);
    final String time = times == null ? l.calendar_allDay : '${times.start} – ${times.end}';
    return Semantics(
      button: true,
      label: '${event.name}, ${eventTypeName(l, type)}, $time',
      excludeSemantics: true,
      onTap: () => showEventDetail(context, event.id, occurrence.start),
      child: InkWell(
        key: ValueKey<String>('day-event-${event.id}-${occurrence.start.day}'),
        onTap: () => showEventDetail(context, event.id, occurrence.start),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: first
                ? null
                : Border(top: BorderSide(color: p.boardLine, width: Metrics.hairline)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Metrics.touchTarget + Space.s16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.s10),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      width: Space.s48 + Space.s8,
                      child: times == null
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                l.calendar_allDay,
                                textAlign: TextAlign.right,
                                style: context.bodyText.labelSmall!.copyWith(
                                  color: p.textFaint,
                                  letterSpacing: 0,
                                  fontSize: 10.5,
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(times.start, style: timeStyle),
                                Text(times.end, style: timeStyle),
                              ],
                            ),
                    ),
                    const SizedBox(width: Space.s12),
                    Container(
                      width: Space.s4,
                      decoration: BoxDecoration(
                        color: type.isSoft ? color.withValues(alpha: 0.6) : color,
                        borderRadius: BorderRadius.circular(Space.s2),
                      ),
                    ),
                    const SizedBox(width: Space.s12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            event.name,
                            style: context.bodyText.titleMedium!.copyWith(
                              decoration: occurrence.isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: p.textFaint,
                            ),
                          ),
                          Text(
                            eventTypeName(l, type),
                            style: context.bodyText.bodySmall!.copyWith(
                              color: p.textDim,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
