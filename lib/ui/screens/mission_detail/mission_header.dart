import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// Top of the Mission detail: kicker, name, recurrence caption, progress with
/// the bonus, the completed seal or the "complete mission" button, and the
/// bonus-withdrawn notice.
class MissionHeader extends StatelessWidget {
  const MissionHeader({
    super.key,
    required this.detail,
    required this.bonusWithdrawn,
    required this.completing,
    required this.onComplete,
  });

  final MissionDetail detail;

  /// A completed Mission was reopened by reopening one of its Quests.
  final bool bonusWithdrawn;

  /// The completion call is running; the button is disabled meanwhile.
  final bool completing;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final Mission mission = detail.mission;
    final int total = detail.quests.length;
    final int done = detail.quests.where((Quest q) => q.isDone).length;
    final bool completed = mission.status == MissionStatus.completed;
    final bool ready =
        mission.status == MissionStatus.open && total > 0 && done == total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l.mission_detailKicker.toUpperCase(),
          style: context.bodyText.labelSmall!.copyWith(color: p.textFaint),
        ),
        const SizedBox(height: Space.s8),
        Semantics(
          header: true,
          child: Text(mission.name, style: context.displayText.headlineLarge),
        ),
        if (mission.ruleId != null) ...<Widget>[
          const SizedBox(height: Space.s8),
          _RecurringCaption(label: l.missions_recurringCaption),
        ],
        const SizedBox(height: Space.s12),
        Text(
          l.mission_progressText(done, total),
          style: context.bodyText.bodyMedium!.copyWith(color: p.text),
        ),
        if (!completed) ...<Widget>[
          const SizedBox(height: Space.s4),
          Text(
            l.mission_bonusOnCompletion(mission.bonus.xp),
            style: context.bodyText.bodyMedium!.copyWith(
              color: p.brassText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: Space.s12),
        _ProgressBar(done: done, total: total),
        if (bonusWithdrawn && !completed) ...<Widget>[
          const SizedBox(height: Space.s16),
          _Notice(text: l.mission_bonusWithdrawn),
        ],
        if (completed) ...<Widget>[
          const SizedBox(height: Space.s16),
          _CompletedBlock(mission: mission),
        ],
        if (ready) ...<Widget>[
          const SizedBox(height: Space.s16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: completing ? null : onComplete,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(Metrics.touchTarget),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.control),
                ),
              ),
              child: Text(l.mission_completeAction),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecurringCaption extends StatelessWidget {
  const _RecurringCaption({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AppIcon(IconAsset.repeat, size: Metrics.iconSmall, color: p.brass),
        const SizedBox(width: Space.s6),
        Text(
          label,
          style: context.bodyText.bodySmall!.copyWith(color: p.textDim),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    final double fraction = total <= 0 ? 0 : (done / total).clamp(0.0, 1.0);
    return Semantics(
      label: l.a11y_missionProgress(done, total),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.pill),
        child: SizedBox(
          height: Metrics.detailBar,
          child: ColoredBox(
            color: p.boardLine,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: fraction),
              duration: reduced ? Motion.reducedFade : Motion.progress,
              curve: Motion.curve,
              builder: (BuildContext context, double value, Widget? child) =>
                  Align(
                    alignment: Alignment.centerLeft,
                    // heightFactor 1: a child-less ColoredBox takes the smallest
                    // size, which is zero high under loose constraints.
                    child: FractionallySizedBox(
                      widthFactor: value,
                      heightFactor: 1,
                      child: child,
                    ),
                  ),
              child: ColoredBox(color: p.brass),
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Space.s12),
        decoration: BoxDecoration(
          color: p.brassSoft,
          borderRadius: BorderRadius.circular(Radii.control),
        ),
        child: Text(
          text,
          style: context.bodyText.bodyMedium!.copyWith(color: p.text),
        ),
      ),
    );
  }
}

/// Seal, earned bonus and completion date of a `completed` Mission.
class _CompletedBlock extends StatelessWidget {
  const _CompletedBlock({required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final DateTime? at = mission.completedAt;
    final int bonus = mission.awardedBonus ?? mission.bonus.xp;
    return Semantics(
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Space.s16),
        decoration: BoxDecoration(
          color: p.boardRaised,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: p.brass, width: Metrics.hairline),
        ),
        child: Row(
          children: <Widget>[
            ExcludeSemantics(
              child: Container(
                width: Metrics.detailSeal,
                height: Metrics.detailSeal,
                decoration: BoxDecoration(
                  color: p.brass,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(
                    IconAsset.sealCheck,
                    size: Metrics.iconSize + Space.s4,
                    color: p.inkOnBrass,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Space.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l.mission_completedTitle,
                    style: context.displayText.titleMedium,
                  ),
                  const SizedBox(height: Space.s2),
                  Text(
                    l.mission_completedBonus(bonus),
                    style: context.bodyText.bodyMedium!.copyWith(
                      color: p.brassText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (at != null)
                    Text(
                      l.mission_completedOn(
                        DateFormat.yMMMd(l.localeName).format(at),
                      ),
                      style: context.bodyText.bodySmall!.copyWith(
                        color: p.textDim,
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
