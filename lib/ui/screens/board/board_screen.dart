import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/calendar/calendar_models.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../sheets/quest_sheet.dart';
import '../../state/board_day.dart';
import '../../state/calendar_state.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/add_fab.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton_list.dart';
import '../../widgets/hero/hero_bar.dart';
import 'quest_list.dart';

/// The Quest board: hero bar, title, the open Quests and those done today,
/// plus the add button.
class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  /// True once the done list has loaded for any Board_Day. After a day change
  /// the new window is briefly without data; that is not a first load.
  bool _doneSeen = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final p = context.palette;

    // The done window follows the Board_Day, so it re-queries at 04:00.
    final DateTime today = ref.watch(boardDayProvider);
    final AsyncValue<List<Quest>> openAsync = ref.watch(openBoardProvider);
    final AsyncValue<List<Quest>> doneAsync = ref.watch(
      doneTodayProvider(today),
    );
    final List<EventOccurrence> eventTasks =
        ref.watch(eventTasksProvider).value ?? const <EventOccurrence>[];
    if (doneAsync.hasValue) _doneSeen = true;

    final List<Quest>? open = openAsync.value;
    final List<Quest> done = doneAsync.value ?? const <Quest>[];
    final bool loading = open == null || (!_doneSeen && !doneAsync.hasValue);
    final bool empty =
        !loading &&
        open.isEmpty &&
        done.isEmpty &&
        eventTasks.isEmpty &&
        !doneAsync.isLoading;

    final Widget body;
    if (loading) {
      body = const Align(alignment: Alignment.topCenter, child: SkeletonList());
    } else if (empty) {
      body = EmptyState(title: l.board_emptyTitle, body: l.board_emptyBody);
    } else {
      final List<MissionSummary> missions =
          ref.watch(openMissionsProvider).value ?? const <MissionSummary>[];
      body = QuestList(
        open: open,
        done: done,
        today: today,
        missionNames: <int, String>{for (final m in missions) m.id: m.name},
        eventTasks: eventTasks,
      );
    }

    return Scaffold(
      backgroundColor: p.board,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.s20,
                    Space.s4,
                    Space.s20,
                    Space.s18,
                  ),
                  child: const HeroBar(),
                ),
                _TitleRow(
                  openCount: open == null
                      ? null
                      : open.length + eventTasks.where((EventOccurrence o) => !o.isCompleted).length,
                  today: today,
                ),
                const SizedBox(height: Space.s10),
                Expanded(child: body),
              ],
            ),
            Positioned(
              right: Space.s20,
              bottom: Space.s20,
              child: AddFab(
                label: l.a11y_addQuest,
                onPressed: () => showQuestSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The date beside the Board title: "sobota 15. 11." in Czech, as drawn in the
/// artboards, and the spelled-out weekday and month in other languages.
String boardDateLabel(DateTime date, String locale) {
  if (locale == 'cs') return DateFormat('EEEE d. M.', 'cs').format(date);
  return DateFormat.MMMMEEEEd(locale).format(date);
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.openCount, required this.today});

  /// Null while the first load is pending.
  final int? openCount;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final String date = boardDateLabel(today, l.localeName);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              l.board_title,
              style: context.displayText.headlineLarge,
            ),
          ),
          const SizedBox(width: Space.s12),
          if (openCount != null)
            Expanded(
              child: Text(
                l.board_subtitle(openCount!, date),
                textAlign: TextAlign.end,
                // Two lines: with a two-digit count the Czech line is wider
                // than the space beside the title and must not lose the date.
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.bodyText.bodySmall!.copyWith(color: p.textDim),
              ),
            ),
        ],
      ),
    );
  }
}
