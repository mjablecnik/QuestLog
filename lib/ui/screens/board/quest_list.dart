import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../state/quest_actions.dart';
import '../../state/reorder.dart';
import '../../sheets/quest_sheet.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/quest_card.dart';
import '../../widgets/common/haptics.dart';
import '../../widgets/sheet/confirm_destructive.dart';
import 'quest_row.dart';
import 'section_header.dart';

/// The open Quests in manual order (reorderable on long press) followed by the
/// Quests done on the current Board_Day.
///
/// Only the open rows live in the reorderable sliver: done rows are neither
/// draggable nor drop targets. A drop shows the new order at once; it is kept
/// until the stream confirms it, and dropped again when the service fails.
class QuestList extends ConsumerStatefulWidget {
  const QuestList({
    super.key,
    required this.open,
    required this.done,
    required this.today,
  });

  final List<BoardQuest> open;
  final List<BoardQuest> done;

  /// Calendar date of the current Board_Day, for the completion labels.
  final DateTime today;

  @override
  ConsumerState<QuestList> createState() => _QuestListState();
}

class _QuestListState extends ConsumerState<QuestList> {
  /// Optimistic order of the open Quest ids while a reorder is unconfirmed.
  List<int>? _pending;

  /// Identifies the latest reorder call; older failures must not undo it.
  int _reorderToken = 0;

  /// Quests with a toggle call in flight, so a double tap cannot complete twice.
  final Set<int> _toggling = <int>{};

  List<int> _ids(List<BoardQuest> items) => <int>[
    for (final BoardQuest item in items) item.quest.id,
  ];

  /// The open Quests as displayed: the optimistic order wins over the stream.
  List<BoardQuest> get _shownOpen {
    final List<int>? pending = _pending;
    if (pending == null) return widget.open;
    final Map<int, BoardQuest> byId = <int, BoardQuest>{
      for (final BoardQuest item in widget.open) item.quest.id: item,
    };
    return <BoardQuest>[
      for (final int id in pending)
        if (byId.remove(id) case final BoardQuest item) item,
      ...byId.values,
    ];
  }

  bool get _pendingConfirmed {
    final List<int>? pending = _pending;
    if (pending == null) return false;
    final Set<int> present = _ids(widget.open).toSet();
    final List<int> expected = <int>[
      for (final int id in pending)
        if (present.contains(id)) id,
    ];
    return listEquals(expected, _ids(widget.open));
  }

  @override
  void didUpdateWidget(QuestList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pendingConfirmed) _pending = null;
  }

  /// [newIndex] is the index after the dragged row is removed
  /// (`onReorderItem`); `moveWithinSubset` takes the pre-removal index.
  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final List<int> shown = _ids(_shownOpen);
    final List<int> next = moveWithinSubset(
      shown,
      oldIndex,
      newIndex > oldIndex ? newIndex + 1 : newIndex,
    );
    if (listEquals(next, shown)) return;
    setState(() => _pending = next);
    final int token = ++_reorderToken;
    try {
      await ref.read(questServiceProvider).reorder(next);
    } catch (error) {
      if (!mounted || token != _reorderToken) return;
      setState(() => _pending = null);
      showDomainError(context, error);
      return;
    }
    if (mounted && token == _reorderToken && _pendingConfirmed) {
      setState(() => _pending = null);
    }
  }

  Future<void> _toggle(Quest quest) async {
    if (!_toggling.add(quest.id)) return;
    try {
      await toggleQuest(context, ref, quest);
    } finally {
      _toggling.remove(quest.id);
    }
  }

  Future<void> _edit(Quest quest) => showQuestSheet(context, editing: quest);

  Future<void> _delete(Quest quest) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool confirmed = await confirmDestructive(
      context,
      title: l.quest_deleteTitle,
      body: quest.isDone
          ? l.quest_deleteDoneBody(quest.name)
          : l.quest_deleteBody(quest.name),
      confirmLabel: l.common_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(questServiceProvider).delete(quest.id);
    } catch (error) {
      if (mounted) showDomainError(context, error);
    }
  }

  Widget _row(BoardQuest item, AppLocalizations l) {
    final Quest quest = item.quest;
    final DateTime? completedAt = quest.completedAt;
    return QuestRow(
      item: item,
      completedLabel: completedAt == null
          ? null
          : questCompletedLabel(l, completedAt, widget.today),
      onToggle: () => _toggle(quest),
      onEdit: () => _edit(quest),
      onDelete: () => _delete(quest),
    );
  }

  Widget _liftProxy(Widget child, int index, Animation<double> animation) {
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    return Material(
      type: MaterialType.transparency,
      child: reduced
          ? child
          : ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.02).animate(animation),
              child: child,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final p = context.palette;
    final List<BoardQuest> open = _shownOpen;
    final List<BoardQuest> done = widget.done;
    final int openXp = open.fold<int>(
      0,
      (int sum, BoardQuest i) => sum + i.quest.difficulty.xp,
    );
    final int doneXp = done.fold<int>(
      0,
      (int sum, BoardQuest i) => sum + (i.quest.awardedXp ?? 0),
    );

    return SlidableAutoCloseBehavior(
      child: CustomScrollView(
        slivers: <Widget>[
          if (open.isNotEmpty)
            SliverToBoxAdapter(
              child: BoardSectionHeader(
                label: l.board_openSection,
                figure: l.common_plusXp(openXp),
                figureColor: p.brass,
              ),
            ),
          SliverReorderableList(
            itemCount: open.length,
            proxyDecorator: _liftProxy,
            onReorderStart: (_) => Haptics.light(),
            onReorderItem: _onReorder,
            itemBuilder: (BuildContext context, int index) {
              final BoardQuest item = open[index];
              return ReorderableDelayedDragStartListener(
                key: ValueKey<int>(item.quest.id),
                index: index,
                child: Semantics(hint: l.a11y_dragHint, child: _row(item, l)),
              );
            },
          ),
          if (open.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.s20,
                  vertical: Space.s4,
                ),
                child: Text(
                  l.board_swipeHint,
                  textAlign: TextAlign.center,
                  style: context.bodyText.bodySmall!.copyWith(
                    color: p.textFaint,
                  ),
                ),
              ),
            ),
          if (done.isNotEmpty) ...<Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: Space.s8),
                child: BoardSectionHeader(
                  label: l.board_doneSection,
                  figure: l.board_doneSummary(done.length, doneXp),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: done.length,
              itemBuilder: (BuildContext context, int index) {
                final BoardQuest item = done[index];
                return KeyedSubtree(
                  key: ValueKey<int>(item.quest.id),
                  child: _row(item, l),
                );
              },
            ),
          ],
          // Room so the last card can scroll clear of the add button.
          const SliverToBoxAdapter(
            child: SizedBox(height: Space.s64 + Space.s32),
          ),
        ],
      ),
    );
  }
}
