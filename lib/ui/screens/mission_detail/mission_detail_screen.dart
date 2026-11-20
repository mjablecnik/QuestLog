import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../sheets/mission_sheet.dart';
import '../../sheets/quest_sheet.dart';
import '../../state/board_day.dart';
import '../../state/quest_actions.dart';
import '../../state/ui_providers.dart';
import '../../state/reorder.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/quest_card.dart';
import '../../widgets/common/announce.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/haptics.dart';
import '../../widgets/common/skeleton_list.dart';
import 'detail_quest_row.dart';
import 'detail_sections.dart';
import 'mission_actions.dart';
import 'mission_header.dart';
import 'mission_menu.dart';

/// One Mission with all of its Quests (requirement 10): progress, bonus, the
/// reorderable open Quests, the done Quests of every day, the "···" menu and
/// the "Complete mission" step.
///
/// Everything shown comes from the `missionDetailProvider` stream, so a change
/// made anywhere shows here at once. The screen closes itself when the Mission
/// disappears (deleted or closed).
class MissionDetailScreen extends ConsumerStatefulWidget {
  const MissionDetailScreen({super.key, required this.missionId});

  final int missionId;

  @override
  ConsumerState<MissionDetailScreen> createState() =>
      _MissionDetailScreenState();
}

class _MissionDetailScreenState extends ConsumerState<MissionDetailScreen> {
  bool _closing = false;

  /// Whether the Mission was ever shown. A detail that closes without ever
  /// having loaded was opened from a stale row.
  bool _loaded = false;
  bool _completing = false;
  bool _bonusWithdrawn = false;

  /// Order of the open Quests right after a drop, until the stream confirms it.
  List<int>? _localOrder;

  int get _id => widget.missionId;

  void _scheduleClose() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _close());
  }

  /// Leaves the screen once. Removes the route when something (a sheet) is on
  /// top of it, so that sheet is not popped instead.
  void _close() {
    if (_closing || !mounted) return;
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route == null) return;
    _closing = true;
    if (!_loaded) _reportStaleOpen();
    final NavigatorState navigator = Navigator.of(context);
    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
  }

  /// The Mission opened from the list is gone: say so and query every list
  /// again, so the stale row leaves the Missions screen.
  void _reportStaleOpen() {
    final db = ref.read(databaseProvider);
    db.markTablesUpdated(db.allTables);
    ref
        .read(snackbarProvider.notifier)
        .show(SnackMessage(AppLocalizations.of(context).error_itemChanged));
  }

  void _onDetail(
    AsyncValue<MissionDetail?>? previous,
    AsyncValue<MissionDetail?> next,
  ) {
    if (next is! AsyncData<MissionDetail?>) return;
    final MissionDetail? detail = next.value;
    if (detail == null) {
      _scheduleClose();
      return;
    }
    _loaded = true;
    final MissionStatus? before = previous?.value?.mission.status;
    final MissionStatus after = detail.mission.status;
    final bool reopened =
        before == MissionStatus.completed && after == MissionStatus.open;
    if (reopened) {
      announceMissionReopened(
        context,
        AppLocalizations.of(context),
        detail.mission.name,
      );
    }
    if (reopened != _bonusWithdrawn &&
        (reopened || after != MissionStatus.open)) {
      setState(() => _bonusWithdrawn = reopened);
    }
    if (_localOrder != null) setState(() => _localOrder = null);
  }

  Future<void> _complete() async {
    if (_completing) return;
    setState(() => _completing = true);
    try {
      await completeMission(context, ref, _id);
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _onMenu(MissionMenuAction action, MissionDetail detail) async {
    switch (action) {
      case MissionMenuAction.edit:
        await showMissionSheet(context, editing: summaryOf(detail));
      case MissionMenuAction.addQuest:
        await showQuestSheet(context, presetMissionId: _id);
      case MissionMenuAction.delete:
        final bool deleted = await confirmAndDeleteMission(
          context,
          ref,
          detail,
        );
        if (deleted) _close();
    }
  }

  Future<void> _reorder(List<Quest> open, int oldIndex, int newIndex) async {
    final List<int> ids = <int>[for (final Quest q in open) q.id];
    // onReorderItem reports the index after the dragged row is removed;
    // moveWithinSubset takes the index before.
    final List<int> next = moveWithinSubset(
      ids,
      oldIndex,
      newIndex > oldIndex ? newIndex + 1 : newIndex,
    );
    setState(() => _localOrder = next);
    try {
      await ref.read(questServiceProvider).reorder(next);
    } catch (error) {
      if (!mounted) return;
      setState(() => _localOrder = null);
      showDomainError(context, error, clearance: Space.s24);
    }
  }

  List<Quest> _openQuests(MissionDetail detail) {
    final List<Quest> open = <Quest>[
      for (final Quest q in detail.quests)
        if (!q.isDone) q,
    ];
    final List<int>? order = _localOrder;
    if (order == null || order.length != open.length) return open;
    final Map<int, Quest> byId = <int, Quest>{
      for (final Quest q in open) q.id: q,
    };
    if (!order.every(byId.containsKey)) return open;
    return <Quest>[for (final int id in order) byId[id]!];
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<MissionDetail?> async = ref.watch(
      missionDetailProvider(_id),
    );
    ref.listen<AsyncValue<MissionDetail?>>(
      missionDetailProvider(_id),
      _onDetail,
    );
    final MissionDetail? detail = async.value;
    if (detail != null) _loaded = true;
    if (async is AsyncData<MissionDetail?> && detail == null) _scheduleClose();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _TopBar(
              menu: detail == null
                  ? null
                  : MissionMenuButton(
                      canAddQuest: detail.mission.status == MissionStatus.open,
                      onSelected: (MissionMenuAction a) => _onMenu(a, detail),
                    ),
            ),
            Expanded(child: _body(context, async, detail)),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncValue<MissionDetail?> async,
    MissionDetail? detail,
  ) {
    final AppLocalizations l = AppLocalizations.of(context);
    if (detail == null) {
      if (async.hasError) {
        return EmptyState(title: l.error_unknown);
      }
      return const SkeletonList(
        padding: EdgeInsets.symmetric(horizontal: Space.s20),
      );
    }

    final bool open = detail.mission.status == MissionStatus.open;
    final List<Quest> openQuests = _openQuests(detail);
    final List<Quest> doneQuests = <Quest>[
      for (final Quest q in detail.quests)
        if (q.isDone) q,
    ]..sort((Quest a, Quest b) => b.completedAt!.compareTo(a.completedAt!));
    final DateTime today = ref.watch(boardDayProvider);

    final Map<int, DateTime> deadlines = ref.watch(questDeadlinesProvider).value ?? const <int, DateTime>{};

    Widget row(Quest quest) => DetailQuestRow(
      quest: quest,
      deadline: deadlines[quest.id],
      today: today,
      completedLabel: quest.completedAt == null
          ? null
          : questCompletedLabel(l, quest.completedAt!, today),
      onToggle: () => toggleQuest(context, ref, quest, clearance: Space.s24),
      onEdit: () => showQuestSheet(context, editing: quest),
      onDelete: () => confirmAndDeleteQuest(context, ref, quest),
    );

    final Widget header = MissionHeader(
      detail: detail,
      bonusWithdrawn: _bonusWithdrawn,
      completing: _completing,
      onComplete: _complete,
    );

    const EdgeInsets padding = EdgeInsets.symmetric(horizontal: Space.s20);

    if (detail.quests.isEmpty) {
      return CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(child: header),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: l.mission_emptyTitle,
              body: l.mission_emptyBody,
              actionLabel: open ? l.mission_menuAddQuest : null,
              onAction: open
                  ? () => showQuestSheet(context, presetMissionId: _id)
                  : null,
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(child: header),
        ),
        if (openQuests.isNotEmpty)
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(
              child: DetailSectionHead(
                label: l.mission_sectionRemaining,
                count: openQuests.length,
                xp: openQuests.fold(0, (int s, Quest q) => s + q.difficulty.xp),
              ),
            ),
          ),
        SliverPadding(
          padding: padding,
          sliver: SliverReorderableList(
            itemCount: openQuests.length,
            onReorderStart: (int _) => Haptics.light(),
            onReorderItem: (int from, int to) => _reorder(openQuests, from, to),
            itemBuilder: (BuildContext context, int index) {
              final Quest quest = openQuests[index];
              return ReorderableDelayedDragStartListener(
                key: ValueKey<String>('open-quest-${quest.id}'),
                index: index,
                child: row(quest),
              );
            },
          ),
        ),
        if (open)
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(
              child: AddQuestRow(
                onTap: () => showQuestSheet(context, presetMissionId: _id),
              ),
            ),
          ),
        if (doneQuests.isNotEmpty) ...<Widget>[
          SliverPadding(
            padding: padding,
            sliver: SliverToBoxAdapter(
              child: DetailSectionHead(
                label: l.mission_sectionDone,
                count: doneQuests.length,
                xp: doneQuests.fold(
                  0,
                  (int s, Quest q) => s + (q.awardedXp ?? q.difficulty.xp),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverList.builder(
              itemCount: doneQuests.length,
              itemBuilder: (BuildContext context, int index) => KeyedSubtree(
                key: ValueKey<String>('done-quest-${doneQuests[index].id}'),
                child: row(doneQuests[index]),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: Space.s48)),
      ],
    );
  }
}

/// Back button on the left, the "···" menu on the right.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.menu});

  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.s12,
        Space.s4,
        Space.s16,
        Space.s8,
      ),
      child: Row(
        children: <Widget>[
          Semantics(
            button: true,
            label: l.common_back,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.control),
              onTap: () => Navigator.of(context).maybePop(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Metrics.touchTarget,
                  minWidth: Metrics.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AppIcon(
                        IconAsset.chevronLeft,
                        size: Metrics.iconSize,
                        color: p.brass,
                      ),
                      const SizedBox(width: Space.s4),
                      Text(
                        l.missions_title,
                        style: context.bodyText.bodyLarge!.copyWith(
                          color: p.brass,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          ?menu,
        ],
      ),
    );
  }
}
