import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import 'level_badge.dart';

/// Key of the filled part of the progress bar; tests read its width factor.
const Key heroBarFillKey = ValueKey<String>('hero-bar-fill');

/// Level badge, hero name and Level, "current / threshold XP", XP remaining and
/// the progress bar.
class HeroBar extends ConsumerWidget {
  const HeroBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LevelProgress? progress = ref.watch(levelProgressProvider).value;
    final AppSettings? settings = ref.watch(settingsProvider).value;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QuestlogPalette p = context.palette;

    final TextStyle nameStyle = context.bodyText.titleMedium!.copyWith(
      fontSize: 17,
    );
    final TextStyle xpStyle = context.bodyText.bodySmall!.copyWith(
      color: p.textDim,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

    final List<Widget> lines = <Widget>[];
    if (progress != null) {
      final String? heroName = settings?.displayName;
      final String title = heroName == null
          ? l10n.hero_level(progress.level)
          : l10n.hero_nameAndLevel(heroName, progress.level);
      lines
        ..add(
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: nameStyle,
          ),
        )
        ..add(const SizedBox(height: Space.s2))
        ..add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                l10n.hero_xpProgress(progress.xpIntoLevel, progress.threshold),
                maxLines: 1,
                style: xpStyle,
              ),
              const SizedBox(width: Space.s8),
              // The remaining XP wraps instead of losing the next level to an
              // ellipsis when big figures leave too little room on one line.
              Flexible(
                child: Text(
                  l10n.hero_xpRemaining(
                    progress.threshold - progress.xpIntoLevel,
                    progress.level + 1,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: xpStyle,
                ),
              ),
            ],
          ),
        )
        ..add(const SizedBox(height: Space.s6));
    }

    Widget bar = _XpBar(
      level: progress?.level ?? 0,
      fraction: progress == null
          ? 0
          : progress.xpIntoLevel / progress.threshold,
    );
    if (progress != null) {
      bar = Semantics(
        label: l10n.hero_progressLabel(
          progress.xpIntoLevel,
          progress.threshold,
        ),
        child: ExcludeSemantics(child: bar),
      );
    }

    return Row(
      children: <Widget>[
        LevelBadge(level: progress?.level),
        const SizedBox(width: Space.s12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[...lines, bar],
          ),
        ),
      ],
    );
  }
}

/// The 6px bar. Follows [fraction]; when [level] rises it first fills to the end
/// and then restarts at the new fraction. Under reduced motion it only fades
/// to the new value within `Motion.reducedFade`.
class _XpBar extends StatefulWidget {
  const _XpBar({required this.level, required this.fraction});

  /// 0 while no data has arrived yet.
  final int level;
  final double fraction;

  @override
  State<_XpBar> createState() => _XpBarState();
}

class _XpBarState extends State<_XpBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.fraction,
  );

  /// Bumped for every run so that a superseded run stops at its next await.
  int _run = 0;

  /// A Level-up is still waiting for the bar to reach its end.
  bool _wrapPending = false;

  @override
  void didUpdateWidget(_XpBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level == widget.level &&
        oldWidget.fraction == widget.fraction) {
      return;
    }
    if (oldWidget.level == 0) {
      // First data: show it without animating from empty.
      _run++;
      _controller.value = widget.fraction;
      return;
    }
    if (widget.level > oldWidget.level) _wrapPending = true;
    _animate();
  }

  Future<void> _animate() async {
    final int run = ++_run;
    if (MediaQuery.disableAnimationsOf(context)) {
      _wrapPending = false;
      await _controller.animateTo(
        widget.fraction,
        duration: Motion.reducedFade,
      );
      return;
    }
    if (_wrapPending) {
      await _controller.animateTo(
        1,
        duration: Motion.progress,
        curve: Motion.curve,
      );
      if (!mounted || run != _run) return;
      _wrapPending = false;
      _controller.value = 0;
    }
    await _controller.animateTo(
      widget.fraction,
      duration: Motion.progress,
      curve: Motion.curve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    const double radius = Metrics.heroBar / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: Metrics.heroBar,
        color: p.boardLine,
        alignment: AlignmentDirectional.centerStart,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) =>
              FractionallySizedBox(
                key: heroBarFillKey,
                widthFactor: _controller.value.clamp(0.0, 1.0),
                child: child,
              ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: p.brass,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
