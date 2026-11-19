import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/calendar/calendar_dates.dart';
import '../../../l10n/app_localizations.dart';
import '../../sheets/calendar/month_picker_sheet.dart';
import '../../sheets/calendar/type_filter_sheet.dart';
import '../../state/calendar_state.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/add_fab.dart';
import '../../widgets/common/app_icon.dart';
import 'calendar_labels.dart';
import 'event_form_screen.dart';
import 'event_search_screen.dart';
import 'month_grid.dart';

/// The Kalendář tab: the Month_View with its header, and the add button.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final bool filterHidesAll = ref.watch(typeFilterProvider).isEmpty;
    return Scaffold(
      backgroundColor: p.board,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _Header(),
                const _WeekdayRow(),
                const Expanded(child: MonthPager()),
              ],
            ),
            if (filterHidesAll)
              Positioned(
                left: Space.s16,
                right: Space.s20 + Metrics.fab + Space.s8,
                bottom: Space.s20,
                child: const _FilterHidesAll(),
              ),
            Positioned(
              right: Space.s20,
              bottom: Space.s20,
              child: AddFab(
                label: l.calendar_add,
                onPressed: () => showEventForm(
                  context,
                  presetDate: ref.read(selectedDayProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final DateTime month = ref.watch(visibleMonthProvider);
    final bool filterActive = ref.watch(typeFilterActiveProvider);
    final VisibleMonthNotifier notifier = ref.read(visibleMonthProvider.notifier);
    final bool canPrevious = isNavigableMonth(DateTime(month.year, month.month - 1));
    final bool canNext = isNavigableMonth(DateTime(month.year, month.month + 1));

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s8, Space.s4, Space.s8, Space.s8),
      child: Row(
        children: <Widget>[
          _IconTap(
            icon: IconAsset.chevronLeft,
            label: l.calendar_prevMonth,
            onTap: canPrevious ? notifier.previous : null,
            size: Metrics.iconSmall,
          ),
          Expanded(
            child: Semantics(
              button: true,
              header: true,
              label: '${monthTitle(month, l.localeName)}. ${l.calendar_pickMonth}',
              excludeSemantics: true,
              onTap: () => showMonthPicker(context),
              child: InkWell(
                onTap: () => showMonthPicker(context),
                borderRadius: BorderRadius.circular(Radii.control),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        monthTitle(month, l.localeName),
                        maxLines: 1,
                        style: context.displayText.titleLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _IconTap(
            icon: IconAsset.chevronRight,
            label: l.calendar_nextMonth,
            onTap: canNext ? notifier.next : null,
            size: Metrics.iconSmall,
          ),
          const SizedBox(width: Space.s4),
          Semantics(
            button: true,
            label: l.calendar_today,
            excludeSemantics: true,
            onTap: notifier.goToToday,
            child: InkWell(
              key: const ValueKey<String>('calendar-today'),
              onTap: notifier.goToToday,
              borderRadius: BorderRadius.circular(Radii.pill),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.brassSoft,
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s6),
                      child: Text(
                        l.calendar_today,
                        style: context.bodyText.labelLarge!.copyWith(color: p.brassText),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _IconTap(
            icon: IconAsset.search,
            label: l.calendar_search,
            onTap: () => showEventSearch(context),
            size: Metrics.iconSmall,
          ),
          _IconTap(
            icon: IconAsset.filter,
            label: l.calendar_filter,
            onTap: () => showTypeFilter(context),
            size: Metrics.iconSmall,
            color: filterActive ? p.brassText : null,
          ),
        ],
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = Metrics.iconSize,
    this.color,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final Color tint = onTap == null ? p.textFaint : (color ?? p.text);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: Metrics.touchTarget,
          height: Metrics.touchTarget,
          child: Center(child: AppIcon(icon, size: size, color: tint)),
        ),
      ),
    );
  }
}

class _WeekdayRow extends StatelessWidget {
  const _WeekdayRow();

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final String locale = AppLocalizations.of(context).localeName;
    // 2 November 2026 is a Monday.
    final List<String> names = <String>[
      for (int i = 0; i < 7; i++) DateFormat.E(locale).format(DateTime(2026, 11, 2 + i)).toUpperCase(),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s8),
      child: ExcludeSemantics(
        child: Row(
          children: <Widget>[
            for (final String name in names)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Space.s6),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: context.bodyText.labelSmall!.copyWith(
                      color: p.textFaint,
                      letterSpacing: 0.5,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shown over the month while the Type_Filter has no type switched on.
class _FilterHidesAll extends ConsumerWidget {
  const _FilterHidesAll();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.boardRaised,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.s12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Semantics(
              liveRegion: true,
              child: Text(l.calendar_filterHidesAll, style: context.bodyText.bodyMedium),
            ),
            const SizedBox(height: Space.s8),
            TextButton(
              onPressed: () => ref.read(typeFilterProvider.notifier).showAll(),
              style: TextButton.styleFrom(
                minimumSize: const Size(Metrics.touchTarget, Metrics.touchTarget),
                foregroundColor: p.brassText,
                padding: EdgeInsets.zero,
              ),
              child: Text(l.calendar_filterShowAll, style: context.bodyText.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
}
