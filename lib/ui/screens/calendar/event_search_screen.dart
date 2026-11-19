import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/calendar/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/calendar/calendar_providers.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/calendar/calendar_fields.dart';
import '../../widgets/common/app_icon.dart';
import 'calendar_labels.dart';
import 'event_detail_screen.dart';

/// Opens the event search.
Future<void> showEventSearch(BuildContext context) =>
    Navigator.of(context).push(CupertinoPageRoute<void>(builder: (_) => const EventSearchScreen()));

/// Finds events by name, details or location, ignoring case and diacritics.
/// The Type_Filter does not apply here.
class EventSearchScreen extends ConsumerStatefulWidget {
  const EventSearchScreen({super.key});

  @override
  ConsumerState<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends ConsumerState<EventSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<SearchResult> _results = const <SearchResult>[];
  String _query = '';
  int _token = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String text) async {
    final int token = ++_token;
    setState(() => _query = text);
    final List<SearchResult> found = await ref.read(calendarServiceProvider).search(text);
    if (!mounted || token != _token) return;
    setState(() => _results = found);
  }

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final String locale = l.localeName;
    final bool empty = _query.trim().isEmpty;
    return Scaffold(
      backgroundColor: p.board,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.s8, Space.s4, Space.s16, Space.s8),
              child: Row(
                children: <Widget>[
                  Semantics(
                    button: true,
                    label: l.common_close,
                    excludeSemantics: true,
                    onTap: () => Navigator.of(context).maybePop(),
                    child: InkWell(
                      key: const ValueKey<String>('search-back'),
                      onTap: () => Navigator.of(context).maybePop(),
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: Metrics.touchTarget,
                        height: Metrics.touchTarget,
                        child: Center(child: AppIcon(IconAsset.chevronLeft, size: Metrics.iconSmall, color: p.text)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CalendarTextField(
                      key: const ValueKey<String>('search-field'),
                      controller: _controller,
                      hint: l.calendar_search,
                      autofocus: true,
                      onChanged: _search,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: empty
                  ? Padding(
                      padding: const EdgeInsets.all(Space.s20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          l.calendar_searchPrompt,
                          style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
                        ),
                      ),
                    )
                  : _results.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(Space.s20),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            l.calendar_searchNone,
                            style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s24),
                      itemCount: _results.length,
                      itemBuilder: (BuildContext context, int i) {
                        final SearchResult r = _results[i];
                        final String date = shortDateLabel(r.occurrenceDate, locale);
                        return Semantics(
                          button: true,
                          label: '${r.event.name}, ${eventTypeName(l, r.event.type)}, $date',
                          excludeSemantics: true,
                          onTap: () => showEventDetail(context, r.event.id, r.occurrenceDate),
                          child: InkWell(
                            key: ValueKey<String>('search-result-${r.event.id}'),
                            onTap: () => showEventDetail(context, r.event.id, r.occurrenceDate),
                            borderRadius: BorderRadius.circular(Radii.control),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: Metrics.touchTarget + Space.s16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Space.s4, vertical: Space.s8),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: Space.s12,
                                      height: Space.s12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: p.eventColor(r.event.type),
                                      ),
                                    ),
                                    const SizedBox(width: Space.s12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(r.event.name, style: context.bodyText.titleMedium),
                                          Text(
                                            '${eventTypeName(l, r.event.type)} · $date',
                                            style: context.bodyText.bodySmall!.copyWith(color: p.textDim),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
