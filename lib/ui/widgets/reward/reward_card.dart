import 'package:flutter/material.dart';

import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../state/reward_queue.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

/// Diameter of the brass seal and of the ray burst around it.
const double _sealSize = 88;
const double _raysSize = 160;
const double _cardMaxWidth = 360;

/// The "turned in" moment: a parchment card with a brass seal, the awarded XP,
/// a caption, the name and, for Quests of a Mission, a progress block.
///
/// Pure presentation: the queue, the timers and the scrim live in
/// `RewardOverlay`. The Mission name and bonus are not part of a
/// [QuestReward], so the caller passes them when it knows them.
class RewardCard extends StatelessWidget {
  const RewardCard({
    super.key,
    required this.event,
    this.missionName,
    this.missionBonus,
    this.onContinue,
    this.onCompleteMission,
    this.rays,
  });

  final RewardEvent event;

  /// Name of the Mission a rewarded Quest belongs to.
  final String? missionName;

  /// XP the Mission will pay on completion.
  final int? missionBonus;

  /// "Pokračovat".
  final VoidCallback? onContinue;

  /// "Dokončit misi"; the button shows only for a [QuestReward] that offers
  /// the Mission completion and when this callback is set.
  final VoidCallback? onCompleteMission;

  /// Drives the entry of the rays (scale and fade). Null draws them at rest,
  /// which is what reduced motion asks for.
  final Animation<double>? rays;

  /// Whether [event] offers to complete its Mission.
  static bool offersMissionComplete(RewardEvent event) =>
      event is QuestReward &&
      event.offerMissionComplete &&
      event.missionId != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final display = context.displayText;
    final body = context.bodyText;

    final RewardEvent e = event;
    final bool levelUp = switch (e) {
      QuestReward() => e.levelUp,
      MissionReward() => e.levelUp,
    };
    final int level = switch (e) {
      QuestReward() => e.level,
      MissionReward() => e.level,
    };
    final int xp = switch (e) {
      QuestReward() => e.xp,
      MissionReward() => e.bonus,
    };
    final String name = switch (e) {
      QuestReward() => e.questName,
      MissionReward() => e.missionName,
    };
    final String caption = levelUp
        ? l10n.reward_levelUp
        : switch (e) {
            QuestReward() => l10n.reward_questComplete,
            MissionReward() => l10n.reward_missionComplete,
          };
    final bool offer = offersMissionComplete(e) && onCompleteMission != null;
    final MissionProgress? mission = e is QuestReward ? e.mission : null;

    return Material(
      color: p.parchment,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.reward),
        side: BorderSide(color: p.parchmentEdge, width: Metrics.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.s24,
            Space.s16,
            Space.s24,
            Space.s24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: _Seal(levelNumber: levelUp ? level : null, rays: rays),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: _XpFigure(
                  text: l10n.common_plusXp(xp),
                  style: display.displayLarge!.copyWith(
                    color: p.brassOnParchment,
                  ),
                ),
              ),
              const SizedBox(height: Space.s8),
              Text(
                caption,
                textAlign: TextAlign.center,
                style: body.labelSmall!.copyWith(
                  color: p.inkDim,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (levelUp) ...<Widget>[
                const SizedBox(height: Space.s4),
                Text(
                  l10n.reward_levelUpBody(level),
                  textAlign: TextAlign.center,
                  style: body.bodyMedium!.copyWith(color: p.brassOnParchment),
                ),
              ],
              const SizedBox(height: Space.s8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: display.headlineMedium!.copyWith(color: p.ink),
              ),
              if (mission != null) ...<Widget>[
                const SizedBox(height: Space.s16),
                _MissionBlock(
                  progress: mission,
                  missionName: missionName,
                  missionBonus: missionBonus,
                  ready: offer,
                ),
              ],
              const SizedBox(height: Space.s20),
              if (offer) ...<Widget>[
                _RewardButton(
                  label: l10n.reward_completeMission,
                  primary: true,
                  onPressed: onCompleteMission,
                ),
                const SizedBox(height: Space.s8),
              ],
              _RewardButton(
                label: l10n.common_continue,
                primary: !offer,
                onPressed: onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The brass seal: a tick, or the new Level number in the level-up variant,
/// inside soft halos and a burst of rays.
/// "+25 XP" with the unit set smaller than the figure, as on the artboard.
class _XpFigure extends StatelessWidget {
  const _XpFigure({required this.text, required this.style});

  /// The localized "+N XP"; the unit is everything after the last space.
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final int split = text.lastIndexOf(' ');
    if (split < 0) {
      return Text(text, textAlign: TextAlign.center, style: style);
    }
    return Text.rich(
      TextSpan(
        text: text.substring(0, split),
        style: style,
        children: <InlineSpan>[
          TextSpan(
            text: text.substring(split),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Seal extends StatelessWidget {
  const _Seal({required this.levelNumber, required this.rays});

  final int? levelNumber;
  final Animation<double>? rays;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);

    Widget burst = AppIcon(
      IconAsset.rays,
      size: _raysSize,
      color: p.brass.withValues(alpha: 0.7),
    );
    final Animation<double>? a = rays;
    if (a != null) {
      burst = FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1).animate(a),
          child: burst,
        ),
      );
    }

    return ExcludeSemantics(
      child: SizedBox(
        width: _raysSize,
        height: _raysSize,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            burst,
            DecoratedBox(
              decoration: BoxDecoration(
                color: p.brass,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: p.brassSoft, spreadRadius: Space.s8),
                  BoxShadow(
                    color: p.brassSoft.withValues(alpha: p.brassSoft.a / 3),
                    spreadRadius: Space.s16,
                  ),
                ],
              ),
              child: SizedBox(
                width: _sealSize,
                height: _sealSize,
                child: Center(
                  child: levelNumber == null
                      ? AppIcon(
                          IconAsset.sealCheck,
                          size: Space.s48,
                          color: p.inkOnBrass,
                        )
                      : Text(
                          l10n.reward_levelNumber(levelNumber!),
                          style: context.displayText.displayLarge!.copyWith(
                            color: p.inkOnBrass,
                            fontSize: Space.s48 - Space.s4,
                          ),
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

/// Mission name, done/total, a progress bar and the remaining or bonus hint.
class _MissionBlock extends StatelessWidget {
  const _MissionBlock({
    required this.progress,
    required this.missionName,
    required this.missionBonus,
    required this.ready,
  });

  final MissionProgress progress;
  final String? missionName;
  final int? missionBonus;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final body = context.bodyText;
    final double fraction = progress.total == 0
        ? 0
        : (progress.done / progress.total).clamp(0.0, 1.0);
    final TextStyle hint = body.bodySmall!.copyWith(color: p.inkDim);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.parchmentEdge.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.s16 - Space.s2,
          vertical: Space.s12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (missionName != null)
                  Expanded(
                    child: Text(
                      l10n.reward_missionLine(missionName!),
                      style: body.bodyMedium!.copyWith(
                        color: p.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: Space.s8),
                Text(
                  l10n.reward_missionProgress(progress.done, progress.total),
                  style: body.bodyMedium!.copyWith(color: p.inkDim),
                ),
              ],
            ),
            const SizedBox(height: Space.s8),
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.pill),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: Metrics.heroBar,
                backgroundColor: p.ink.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation<Color>(p.brass),
              ),
            ),
            const SizedBox(height: Space.s8),
            if (ready)
              Text(l10n.reward_missionReady, style: hint)
            else ...<Widget>[
              if (progress.remainingXp > 0)
                Text(
                  l10n.reward_missionRemaining(progress.remainingXp),
                  style: hint,
                ),
              if (missionBonus != null)
                Text(l10n.reward_missionBonusHint(missionBonus!), style: hint),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-width button with a 44 px minimum hit area.
class _RewardButton extends StatelessWidget {
  const _RewardButton({
    required this.label,
    required this.primary,
    required this.onPressed,
  });

  final String label;
  final bool primary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final BorderRadius radius = BorderRadius.circular(Radii.control);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Material(
        color: primary ? p.brass : p.parchment,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: Metrics.touchTarget + Space.s8,
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.bodyText.labelLarge!.copyWith(
                  color: primary ? p.inkOnBrass : p.ink,
                  fontWeight: primary ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
