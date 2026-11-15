import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../sheets/quest_sheet.dart';
import '../../state/board_day.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton_list.dart';
import '../../widgets/hero/hero_bar.dart';
import 'quest_list.dart';

/// The Quest board: hero bar, title, the open Quests and those done today,
/// plus the add button.
class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key, required this.onOpenSettings});

  /// Called when the gear in the hero bar is tapped.
  final VoidCallback onOpenSettings;

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
    final AsyncValue<List<BoardQuest>> openAsync = ref.watch(openBoardProvider);
    final AsyncValue<List<BoardQuest>> doneAsync = ref.watch(
      doneTodayProvider(today),
    );
    if (doneAsync.hasValue) _doneSeen = true;

    final List<BoardQuest>? open = openAsync.value;
    final List<BoardQuest> done = doneAsync.value ?? const <BoardQuest>[];
    final bool loading = open == null || (!_doneSeen && !doneAsync.hasValue);
    final bool empty =
        !loading && open.isEmpty && done.isEmpty && !doneAsync.isLoading;

    final Widget body;
    if (loading) {
      body = const Align(alignment: Alignment.topCenter, child: SkeletonList());
    } else if (empty) {
      body = EmptyState(title: l.board_emptyTitle, body: l.board_emptyBody);
    } else {
      body = QuestList(open: open, done: done, today: today);
    }

    return Scaffold(
      backgroundColor: p.board,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        tooltip: l.a11y_addQuest,
        backgroundColor: p.brass,
        foregroundColor: p.inkOnBrass,
        shape: const CircleBorder(),
        onPressed: () => showQuestSheet(context),
        child: AppIcon(IconAsset.plus, color: p.inkOnBrass),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.s20,
                Space.s8,
                Space.s20,
                Space.s16,
              ),
              child: HeroBar(onOpenSettings: widget.onOpenSettings),
            ),
            _TitleRow(openCount: open?.length, today: today),
            const SizedBox(height: Space.s12),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
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
    final String date = DateFormat.MMMMEEEEd(l.localeName).format(today);
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyText.bodySmall!.copyWith(color: p.textDim),
              ),
            ),
        ],
      ),
    );
  }
}
