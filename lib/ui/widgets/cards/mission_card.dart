import 'package:flutter/material.dart';

import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';
import 'progress_ring.dart';

/// One Mission: progress ring, name, what is left and the completion bonus.
///
/// An open Mission shows the remaining XP, or "Ready to complete" once every
/// Quest is done. A completed Mission (shown under "Completed today") shows a
/// full ring with a tick, the Quest count and the awarded bonus.
class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.mission,
    this.onTap,
    this.completedTime,
  });

  final MissionSummary mission;
  final VoidCallback? onTap;

  /// Already localized completion time of a completed Mission ("7:52").
  final String? completedTime;

  /// True when the Mission is open and every one of its Quests is done.
  bool get isReady =>
      mission.status == MissionStatus.open &&
      mission.total > 0 &&
      mission.done >= mission.total;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final bool completed = mission.status == MissionStatus.completed;
    final int bonus = completed
        ? (mission.awardedBonus ?? mission.bonus.xp)
        : mission.bonus.xp;

    final TextStyle sub = context.bodyText.bodySmall!.copyWith(
      color: p.textDim,
    );
    final String subText;
    if (completed) {
      subText = completedTime == null
          ? l.common_questCount(mission.total)
          : l.missions_completedLine(mission.total, completedTime!);
    } else if (isReady) {
      subText = l.missions_readyToComplete;
    } else {
      subText = l.missions_remaining(mission.remainingXp);
    }

    final BorderRadius radius = BorderRadius.circular(Radii.card);
    final Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: p.boardRaised,
        borderRadius: radius,
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Space.s16),
            child: Row(
              children: <Widget>[
                ProgressRing(
                  done: completed ? mission.total : mission.done,
                  total: mission.total,
                  center: completed
                      ? AppIcon(
                          IconAsset.tick,
                          size: Metrics.iconSize,
                          color: p.brass,
                        )
                      : null,
                ),
                const SizedBox(width: Space.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        mission.name,
                        style: context.bodyText.titleMedium!.copyWith(
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: Space.s4),
                      Text(
                        subText,
                        style: isReady
                            ? sub.copyWith(
                                color: p.brassText,
                                fontWeight: FontWeight.w600,
                              )
                            : sub,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Space.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '+$bonus',
                      style: context.displayText.titleMedium!.copyWith(
                        fontSize: 15,
                        color: p.brassText,
                      ),
                    ),
                    const SizedBox(height: Space.s2),
                    Text(
                      (completed
                              ? l.missions_earnedCaption
                              : l.missions_bonusCaption)
                          .toUpperCase(),
                      style: context.bodyText.labelSmall!.copyWith(
                        fontSize: 10,
                        letterSpacing: 1,
                        color: p.textFaint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      button: onTap != null,
      label: l.a11y_openMission(mission.name),
      child: completed ? Opacity(opacity: 0.72, child: card) : card,
    );
  }
}
