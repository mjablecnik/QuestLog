import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../sheets/mission_sheet.dart';
import '../../state/board_day.dart';
import '../../state/quest_actions.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/mission_card.dart';
import '../../widgets/common/add_fab.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton_list.dart';
import '../../widgets/hero/hero_bar.dart';
import '../../widgets/sheet/confirm_destructive.dart';
import '../mission_detail/mission_detail_screen.dart';
import '../settings/settings_screen.dart';
import 'mission_swipe_row.dart';

/// The "Mise" tab: open Missions with their progress, the Missions completed
/// on the current Board_Day, and the entry points to create, edit and delete.
class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key, this.onOpenSettings});

  /// Called when the Hero_Bar gear is tapped; defaults to pushing the
  /// Settings_Screen.
  final VoidCallback? onOpenSettings;

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> {
  /// Ids of Missions whose removal transition is running.
  final Set<int> _leaving = <int>{};

  void _openSettings() {
    final VoidCallback? callback = widget.onOpenSettings;
    if (callback != null) {
      callback();
      return;
    }
    Navigator.of(context)
        .push(CupertinoPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  void _openDetail(MissionSummary mission) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => MissionDetailScreen(missionId: mission.id),
      ),
    );
  }

  Future<void> _delete(MissionSummary mission) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool confirmed = await confirmDestructive(
      context,
      title: l.mission_deleteTitle,
      body: l.mission_deleteBody(mission.name, mission.total),
      confirmLabel: l.common_delete,
    );
    if (!confirmed || !mounted) return;

    setState(() => _leaving.add(mission.id));
    final Duration transition = MediaQuery.disableAnimationsOf(context)
        ? Motion.reducedFade
        : Motion.panel;
    await Future<void>.delayed(transition);
    if (!mounted) return;
    try {
      await ref.read(missionServiceProvider).delete(mission.id);
    } catch (error) {
      if (!mounted) return;
      setState(() => _leaving.remove(mission.id));
      showDomainError(context, error);
      return;
    }
    if (mounted) setState(() => _leaving.remove(mission.id));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final DateTime today = ref.watch(boardDayProvider);
    final AsyncValue<List<MissionSummary>> open = ref.watch(
      openMissionsProvider,
    );
    final AsyncValue<List<MissionSummary>> done = ref.watch(
      completedMissionsTodayProvider(today),
    );

    final List<MissionSummary>? openList = open.value;
    final List<MissionSummary>? doneList = done.value;

    final Widget body;
    if (open.hasError || done.hasError) {
      body = _LoadError(
        onRetry: () {
          ref.invalidate(openMissionsProvider);
          ref.invalidate(completedMissionsTodayProvider(today));
        },
      );
    } else if (openList == null || doneList == null) {
      body = const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SkeletonList(
          count: 3,
          padding: EdgeInsets.symmetric(horizontal: Space.s20),
        ),
      );
    } else if (openList.isEmpty && doneList.isEmpty) {
      body = EmptyState(
        title: l.missions_emptyTitle,
        body: l.missions_emptyBody,
        actionLabel: l.missions_emptyAction,
        onAction: () => showMissionSheet(context),
      );
    } else {
      body = _MissionList(
        open: openList,
        doneToday: doneList,
        leaving: _leaving,
        onOpen: _openDetail,
        onEdit: (MissionSummary m) => showMissionSheet(context, editing: m),
        onDelete: _delete,
      );
    }

    return Scaffold(
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
                  child: HeroBar(onOpenSettings: _openSettings),
                ),
                _TitleRow(
                  openCount: openList?.length ?? 0,
                  doneCount: doneList?.length ?? 0,
                ),
                const SizedBox(height: Space.s10),
                Expanded(child: body),
              ],
            ),
            Positioned(
              right: Space.s20,
              bottom: Space.s20,
              child: AddFab(
                label: l.a11y_addMission,
                onPressed: () => showMissionSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.openCount, required this.doneCount});

  final int openCount;
  final int doneCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final List<String> parts = <String>[
      if (openCount > 0) l.missions_openCount(openCount),
      if (doneCount > 0) l.missions_doneCount(doneCount),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              l.missions_title,
              style: context.displayText.headlineLarge,
            ),
          ),
          const SizedBox(width: Space.s12),
          Expanded(
            child: Text(
              parts.join(' · '),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodyText.bodySmall!.copyWith(
                color: context.palette.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionList extends StatelessWidget {
  const _MissionList({
    required this.open,
    required this.doneToday,
    required this.leaving,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final List<MissionSummary> open;
  final List<MissionSummary> doneToday;
  final Set<int> leaving;
  final ValueChanged<MissionSummary> onOpen;
  final ValueChanged<MissionSummary> onEdit;
  final ValueChanged<MissionSummary> onDelete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final String locale = l.localeName;

    Widget row(MissionSummary m, {String? time}) => Padding(
      key: ValueKey<int>(m.id),
      padding: const EdgeInsets.only(bottom: Space.s10),
      child: MissionSwipeRow(
        missionName: m.name,
        leaving: leaving.contains(m.id),
        onEdit: () => onEdit(m),
        onDelete: () => onDelete(m),
        child: MissionCard(
          mission: m,
          completedTime: time,
          onTap: () => onOpen(m),
        ),
      ),
    );

    return SlidableAutoCloseBehavior(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.s20,
          0,
          Space.s20,
          Metrics.fab + 2 * Space.s20 + Space.s12,
        ),
        children: <Widget>[
          if (open.isNotEmpty) ...<Widget>[
            _SectionLabel(l.missions_sectionOpen),
            for (final MissionSummary m in open) row(m),
          ],
          if (doneToday.isNotEmpty) ...<Widget>[
            if (open.isNotEmpty) const SizedBox(height: Space.s6),
            _SectionLabel(l.missions_sectionDoneToday),
            for (final MissionSummary m in doneToday)
              row(
                m,
                time: m.completedAt == null
                    ? null
                    : DateFormat.Hm(locale).format(m.completedAt!),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s10),
        child: Text(
          text.toUpperCase(),
          style: context.bodyText.labelSmall!.copyWith(
            color: context.palette.textFaint,
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l.error_unknown, style: context.bodyText.bodyLarge),
          const SizedBox(height: Space.s12),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(Metrics.touchTarget, Metrics.touchTarget),
            ),
            onPressed: onRetry,
            child: Text(l.common_retry),
          ),
        ],
      ),
    );
  }
}
