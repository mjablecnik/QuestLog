import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calendar/event_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../screens/calendar/calendar_labels.dart';
import '../../state/calendar_state.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/sheet/questlog_sheet.dart';

/// Opens the Type_Filter sheet: one switch per event type.
Future<void> showTypeFilter(BuildContext context) =>
    showQuestlogSheet<void>(context, builder: (BuildContext _) => const _TypeFilterSheet());

class _TypeFilterSheet extends ConsumerWidget {
  const _TypeFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final Set<EventType> shown = ref.watch(typeFilterProvider);
    final TypeFilterNotifier notifier = ref.read(typeFilterProvider.notifier);
    return QuestlogSheet(
      title: l.calendar_filterTitle,
      primaryLabel: l.calendar_filterDone,
      onPrimary: () async => QuestlogSheet.close<void>(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (shown.length < EventType.values.length)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: notifier.showAll,
                style: TextButton.styleFrom(
                  minimumSize: const Size(Metrics.touchTarget, Metrics.touchTarget),
                  foregroundColor: p.brassText,
                  padding: EdgeInsets.zero,
                ),
                child: Text(l.calendar_filterShowAll, style: context.bodyText.labelLarge),
              ),
            ),
          for (final EventType type in EventType.values)
            MergeSemantics(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: Space.s12,
                      height: Space.s12,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: p.eventColor(type)),
                    ),
                    const SizedBox(width: Space.s12),
                    Expanded(child: Text(eventTypeName(l, type), style: context.bodyText.titleMedium)),
                    Switch(
                      key: ValueKey<String>('filter-${type.key}'),
                      value: shown.contains(type),
                      onChanged: (_) => notifier.toggle(type),
                      activeThumbColor: p.inkOnBrass,
                      activeTrackColor: p.brass,
                      inactiveThumbColor: p.textFaint,
                      inactiveTrackColor: p.field,
                      trackOutlineColor: WidgetStatePropertyAll<Color>(p.boardLine),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
