import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/calendar/calendar_dates.dart';
import '../../../data/calendar/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/calendar_state.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/calendar/event_chip.dart';
import 'day_sheet.dart';

/// Months from January 2000 to December 2100, one page each.
const int _monthCount = 101 * 12;

int _pageOf(DateTime month) => (month.year - 2000) * 12 + (month.month - 1);

DateTime _monthOfPage(int page) => DateTime(2000 + page ~/ 12, page % 12 + 1);

/// The Month_View: the Visible_Month as a six-week grid in a pager, so a
/// horizontal swipe changes the month. Arrows, "Dnes" and the month picker move
/// the pager through [visibleMonthProvider].
class MonthPager extends ConsumerStatefulWidget {
  const MonthPager({super.key});

  @override
  ConsumerState<MonthPager> createState() => _MonthPagerState();
}

class _MonthPagerState extends ConsumerState<MonthPager> {
  late final PageController _controller = PageController(
    initialPage: _pageOf(ref.read(visibleMonthProvider)),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _follow(DateTime? previous, DateTime next) {
    final int target = _pageOf(next);
    final double current = _controller.hasClients ? (_controller.page ?? target.toDouble()) : target.toDouble();
    if (current.round() == target) return;
    if (!_controller.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context) || (current - target).abs() > 1.5) {
      _controller.jumpToPage(target);
    } else {
      _controller.animateToPage(target, duration: Motion.panel, curve: Motion.curve);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DateTime>(visibleMonthProvider, _follow);
    return PageView.builder(
      key: const ValueKey<String>('month-pager'),
      controller: _controller,
      itemCount: _monthCount,
      onPageChanged: (int page) => ref.read(visibleMonthProvider.notifier).show(_monthOfPage(page)),
      itemBuilder: (BuildContext context, int page) => MonthPage(month: _monthOfPage(page)),
    );
  }
}

/// One month: six rows of seven day cells.
class MonthPage extends ConsumerWidget {
  const MonthPage({super.key, required this.month});

  final DateTime month;

  /// Occurrences of a date, all-day (or continuing from an earlier day) first.
  static List<EventOccurrence> forDate(List<EventOccurrence> all, DateTime date) {
    final List<EventOccurrence> out = <EventOccurrence>[
      for (final EventOccurrence o in all)
        if (!date.isBefore(o.start) && !date.isAfter(o.end)) o,
    ];
    int rank(EventOccurrence o) => (o.event.allDay || date != o.start) ? 0 : 1;
    out.sort((EventOccurrence a, EventOccurrence b) {
      final int byRank = rank(a).compareTo(rank(b));
      if (byRank != 0) return byRank;
      final int byMinute = (a.event.startMinute ?? 0).compareTo(b.event.startMinute ?? 0);
      if (byMinute != 0) return byMinute;
      return a.event.name.compareTo(b.event.name);
    });
    return out;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuestlogPalette p = context.palette;
    final List<EventOccurrence> all = ref.watch(monthOccurrencesProvider(month)).value ?? const <EventOccurrence>[];
    final DateTime today = ref.watch(calendarTodayProvider);
    final List<DateTime> dates = monthGridDates(month);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.boardLine, width: Metrics.hairline)),
        ),
        child: Column(
          children: <Widget>[
            for (int row = 0; row < 6; row++)
              Expanded(
                child: Row(
                  children: <Widget>[
                    for (int col = 0; col < 7; col++)
                      Expanded(
                        child: DayCell(
                          date: dates[row * 7 + col],
                          inMonth: dates[row * 7 + col].month == month.month,
                          isToday: dates[row * 7 + col] == today,
                          occurrences: forDate(all, dates[row * 7 + col]),
                          leftEdge: col == 0,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One day of the grid: the date number and the Event_Chips of that day.
///
/// Up to three events show as chips, more show two chips and "+N"; fewer when
/// the cell is too small for them (large text), so nothing leaves the cell.
class DayCell extends ConsumerWidget {
  const DayCell({
    super.key,
    required this.date,
    required this.inMonth,
    required this.isToday,
    required this.occurrences,
    required this.leftEdge,
  });

  final DateTime date;
  final bool inMonth;
  final bool isToday;
  final List<EventOccurrence> occurrences;
  final bool leftEdge;

  /// How many chips are drawn and how many are left for the "+N" label.
  static ({int shown, int hidden}) split(int count, double room, double chipHeight) {
    final int capacity = room <= 0 ? 0 : (room / chipHeight).floor();
    int shown = count <= 3 ? count : 2;
    if (shown > capacity) shown = capacity;
    if (count - shown > 0 && shown >= capacity) shown = capacity > 0 ? capacity - 1 : 0;
    return (shown: shown, hidden: count - shown);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final TextScaler scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: EventChip.maxTextScale);
    final double numberHeight = scaler.scale(11) * 1.35 + Space.s2;
    final double chipHeight = EventChip.heightOf(context) + Space.s2;
    final String label = l.calendar_cellLabel(
      DateFormat.yMMMMEEEEd(l.localeName).format(date),
      occurrences.length,
    );
    final BorderSide line = BorderSide(color: p.boardLine, width: Metrics.hairline);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: () => _open(context, ref),
      child: InkWell(
        key: ValueKey<String>('day-${date.year}-${date.month}-${date.day}'),
        onTap: () => _open(context, ref),
        child: Container(
          decoration: BoxDecoration(
            color: isToday ? p.brassSoft : null,
            border: Border(
              right: line,
              bottom: line,
              left: leftEdge ? line : BorderSide.none,
            ),
          ),
          // The today mark: an outline in the accent colour, inside the cell.
          foregroundDecoration: isToday
              ? BoxDecoration(border: Border.all(color: p.brass, width: Metrics.badgeBorder))
              : null,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final ({int shown, int hidden}) split = DayCell.split(
                occurrences.length,
                box.maxHeight - numberHeight - Space.s2,
                chipHeight,
              );
              return ClipRect(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.s2, Space.s2, Space.s2, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: Space.s2),
                        child: Text(
                          '${date.day}',
                          textScaler: scaler,
                          style: context.bodyText.bodySmall!.copyWith(
                            fontSize: 11,
                            height: 1.35,
                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                            color: isToday
                                ? p.brassText
                                : (inMonth ? p.text : p.textFaint),
                          ),
                        ),
                      ),
                      const SizedBox(height: Space.s2),
                      for (int i = 0; i < split.shown; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Space.s2),
                          child: EventChip(
                            type: occurrences[i].event.type,
                            label: occurrences[i].event.name,
                          ),
                        ),
                      if (split.hidden > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: Space.s2),
                          child: Text(
                            l.calendar_moreEvents(split.hidden),
                            maxLines: 1,
                            textScaler: scaler,
                            style: context.bodyText.bodySmall!.copyWith(
                              fontSize: 9.5,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: p.textDim,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    ref.read(selectedDayProvider.notifier).select(date);
    showDaySheet(context, date);
  }
}
