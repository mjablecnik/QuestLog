import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/calendar/repeat_rule.dart';
import '../../../data/calendar/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../sheets/calendar/delete_event_sheet.dart';
import '../../state/calendar_state.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/calendar/calendar_fields.dart';
import '../../widgets/calendar/event_chip.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/snackbar_host.dart';
import 'calendar_labels.dart';
import 'event_form_screen.dart';

/// Opens the detail of the occurrence of event [eventId] that starts on [date].
Future<void> showEventDetail(BuildContext context, int eventId, DateTime date) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(
      builder: (_) => EventDetailScreen(
        eventId: eventId,
        occurrenceDate: DateTime(date.year, date.month, date.day),
      ),
    ),
  );
}

enum _Menu { edit, duplicate, delete }

/// The read-only view of one event occurrence: name, type, start and end, note,
/// repeat, location and, once completed, when and for how much XP.
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId, required this.occurrenceDate});

  final int eventId;
  final DateTime occurrenceDate;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _closing = false;
  bool _loaded = false;

  (int, DateTime) get _key => (widget.eventId, widget.occurrenceDate);

  void _closeGone() {
    if (_closing) return;
    _closing = true;
    final bool wasLoaded = _loaded;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final AppLocalizations l = AppLocalizations.of(context);
      Navigator.of(context).maybePop();
      if (!wasLoaded) showQuestlogSnack(context, l.calendar_eventGone);
    });
  }

  Future<void> _onMenu(_Menu action, EventOccurrence occurrence) async {
    switch (action) {
      case _Menu.edit:
        await showEventForm(context, editing: occurrence.event, occurrenceDate: occurrence.start);
      case _Menu.duplicate:
        await showEventForm(
          context,
          prefill: EventDraft.fromEvent(occurrence.event).copyWith(
            startDate: occurrence.start,
            endDate: occurrence.end,
            repeat: const NoRepeat(),
          ),
        );
      case _Menu.delete:
        final bool deleted = await deleteEventFlow(context, ref, occurrence.event, occurrence.start);
        if (deleted && mounted) {
          _closing = true;
          Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<EventOccurrence?> async = ref.watch(occurrenceProvider(_key));
    final EventOccurrence? occurrence = async.value;
    if (occurrence != null) _loaded = true;
    if (async is AsyncData<EventOccurrence?> && occurrence == null) _closeGone();

    return Scaffold(
      backgroundColor: p.board,
      body: SafeArea(
        child: occurrence == null
            ? const SizedBox.expand()
            : Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _TopBar(occurrence: occurrence, onMenu: (_Menu a) => _onMenu(a, occurrence)),
                      Expanded(child: _Body(occurrence: occurrence)),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: Space.s20,
                    child: Center(
                      child: FilledButton.icon(
                        key: const ValueKey<String>('detail-edit'),
                        onPressed: () => _onMenu(_Menu.edit, occurrence),
                        icon: AppIcon(IconAsset.edit, size: Metrics.iconSmall, color: p.inkOnBrass),
                        label: Text(l.calendar_edit),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(Metrics.fab * 3, Metrics.touchTarget + Space.s8),
                          backgroundColor: p.brass,
                          foregroundColor: p.inkOnBrass,
                          shape: const StadiumBorder(),
                          textStyle: context.bodyText.titleMedium,
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.occurrence, required this.onMenu});

  final EventOccurrence occurrence;
  final ValueChanged<_Menu> onMenu;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    PopupMenuItem<_Menu> item(_Menu action, String label, String icon, {Color? color}) {
      final Color tint = color ?? p.text;
      return PopupMenuItem<_Menu>(
        value: action,
        height: Metrics.menuItem,
        padding: const EdgeInsets.symmetric(horizontal: Space.s16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: context.bodyText.bodyLarge!.copyWith(color: tint, fontWeight: FontWeight.w500),
              ),
            ),
            AppIcon(icon, size: Metrics.iconSmall, color: tint),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s8, Space.s4, Space.s8, Space.s8),
      child: Row(
        children: <Widget>[
          Semantics(
            button: true,
            label: l.common_close,
            excludeSemantics: true,
            onTap: () => Navigator.of(context).maybePop(),
            child: InkWell(
              key: const ValueKey<String>('detail-close'),
              onTap: () => Navigator.of(context).maybePop(),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: Metrics.touchTarget,
                height: Metrics.touchTarget,
                child: Center(child: AppIcon(IconAsset.close, size: Metrics.iconSmall, color: p.text)),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                occurrence.event.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.displayText.titleLarge,
              ),
            ),
          ),
          PopupMenuButton<_Menu>(
            key: const ValueKey<String>('detail-menu'),
            tooltip: l.calendar_menu,
            position: PopupMenuPosition.under,
            color: p.sheet,
            surfaceTintColor: p.sheet.withValues(alpha: 0),
            shadowColor: p.scrim,
            elevation: Space.s8,
            constraints: const BoxConstraints.tightFor(width: Metrics.menuWidth),
            padding: EdgeInsets.zero,
            icon: AppIcon(IconAsset.more, size: Metrics.iconSize, color: p.text),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.card),
              side: BorderSide(color: p.boardLine, width: Metrics.hairline),
            ),
            onSelected: onMenu,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<_Menu>>[
              item(_Menu.edit, l.calendar_edit, IconAsset.edit),
              const PopupMenuDivider(height: Metrics.hairline),
              item(_Menu.duplicate, l.calendar_duplicate, IconAsset.plus),
              const PopupMenuDivider(height: Metrics.hairline),
              item(_Menu.delete, l.common_delete, IconAsset.trash, color: p.destructive),
            ],
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.occurrence});

  final EventOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final String locale = l.localeName;
    final CalendarEvent event = occurrence.event;
    final EventCompletion? completion = occurrence.completion;

    String when(DateTime date, int? minute) {
      final String d = shortDateLabel(date, locale);
      return minute == null ? d : d;
    }

    Widget moment(String label, DateTime date, int? minute, {required bool start}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: context.bodyText.titleMedium!.copyWith(color: p.brassText),
            ),
            Text(when(date, minute), style: context.bodyText.titleMedium),
            if (minute != null)
              Text(
                minuteLabel(minute),
                style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
              ),
          ],
        ),
      );
    }

    Widget infoRow(String icon, String label, String value, {VoidCallback? onTap}) {
      final Widget content = Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: Space.s2),
              child: AppIcon(icon, size: Metrics.iconSize - Space.s2, color: p.brassText),
            ),
            const SizedBox(width: Space.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: context.bodyText.titleMedium),
                  Text(value, style: context.bodyText.bodyLarge!.copyWith(color: p.textDim)),
                ],
              ),
            ),
          ],
        ),
      );
      if (onTap == null) return MergeSemantics(child: content);
      return Semantics(
        button: true,
        label: '$label, $value',
        excludeSemantics: true,
        onTap: onTap,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(Radii.control), child: content),
      );
    }

    final String repeat = repeatDescription(l, event.repeat, occurrence.start);
    final String? location = event.location;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s64 + Space.s48),
      children: <Widget>[
        CalendarCard(
          children: <Widget>[
            Text(event.name, style: context.displayText.headlineMedium),
            Align(
              alignment: Alignment.centerLeft,
              child: EventTypeBadge(type: event.type, label: eventTypeName(l, event.type)),
            ),
            if (event.allDay)
              Row(
                children: <Widget>[
                  moment(l.calendar_start, occurrence.start, null, start: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s8),
                    child: AppIcon(IconAsset.chevronRight, size: Metrics.iconSmall, color: p.textFaint),
                  ),
                  moment(l.calendar_end, occurrence.end, null, start: false),
                ],
              )
            else
              Row(
                children: <Widget>[
                  moment(l.calendar_start, occurrence.start, event.startMinute, start: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Space.s8),
                    child: AppIcon(IconAsset.chevronRight, size: Metrics.iconSmall, color: p.textFaint),
                  ),
                  moment(l.calendar_end, occurrence.end, event.endMinute, start: false),
                ],
              ),
            if (event.allDay)
              Text(
                l.calendar_allDay,
                style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
              ),
          ],
        ),
        const SizedBox(height: Space.s12),
        if (completion != null) ...<Widget>[
          CalendarCard(
            children: <Widget>[
              Semantics(
                liveRegion: true,
                child: Row(
                  children: <Widget>[
                    AppIcon(IconAsset.sealCheck, size: Metrics.iconSize, color: p.brassText),
                    const SizedBox(width: Space.s12),
                    Expanded(
                      child: Text(
                        l.calendar_completedAt(
                          DateFormat.Hm(locale).format(completion.completedAt),
                          completion.awardedXp,
                        ),
                        style: context.bodyText.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.s12),
        ],
        CalendarCard(
          gap: Space.s12,
          children: <Widget>[
            infoRow(
              IconAsset.note,
              l.calendar_notes,
              (event.note == null || event.note!.isEmpty) ? l.calendar_notSet : event.note!,
            ),
            infoRow(IconAsset.repeat, l.calendar_repeat, repeat),
            infoRow(
              IconAsset.location,
              l.calendar_location,
              (location == null || location.isEmpty) ? l.calendar_notSet : location,
              onTap: (location == null || location.isEmpty)
                  ? null
                  : () async {
                      await Clipboard.setData(ClipboardData(text: location));
                      if (context.mounted) showQuestlogSnack(context, l.calendar_locationCopied);
                    },
            ),
          ],
        ),
      ],
    );
  }
}
