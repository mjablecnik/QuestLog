import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../services/providers.dart';
import '../../state/reward_queue.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/announce.dart';
import '../common/haptics.dart';
import 'reward_card.dart';

/// Shows the head of the [RewardQueue] as a [RewardCard] over a scrim.
///
/// A plain widget for the shell to put in a `Stack` above the tabs; it draws
/// nothing while the queue is empty. Rewards appear one after another and
/// never stack. [onCompleteMission] receives the id of the Mission offered by
/// the card; the overlay dismisses the card after the callback returns.
class RewardOverlay extends ConsumerWidget {
  const RewardOverlay({super.key, required this.onCompleteMission});

  final ValueChanged<int> onCompleteMission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RewardEvent? event = ref.watch(currentRewardProvider);
    if (event == null) return const SizedBox.shrink();
    return _RewardPresenter(
      key: ObjectKey(event),
      event: event,
      onCompleteMission: onCompleteMission,
    );
  }
}

/// One reward on screen: entry and exit animation, the auto-dismiss timer,
/// haptics and the screen-reader announcement.
class _RewardPresenter extends ConsumerStatefulWidget {
  const _RewardPresenter({
    super.key,
    required this.event,
    required this.onCompleteMission,
  });

  final RewardEvent event;
  final ValueChanged<int> onCompleteMission;

  @override
  ConsumerState<_RewardPresenter> createState() => _RewardPresenterState();
}

class _RewardPresenterState extends ConsumerState<_RewardPresenter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  Timer? _autoDismiss;
  bool _started = false;
  bool _dismissing = false;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_started) return;
    _started = true;
    _controller.duration = _reduced ? Motion.reducedFade : Motion.panel;
    _controller.forward();
    if (!RewardCard.offersMissionComplete(widget.event)) {
      _autoDismiss = Timer(Motion.rewardDismiss, _dismiss);
    }
    Haptics.success();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _announceReward();
    });
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _announceReward() {
    final l10n = AppLocalizations.of(context);
    final RewardEvent e = widget.event;
    final String text = switch (e) {
      QuestReward() => l10n.a11y_questCompleted(e.questName, e.xp),
      MissionReward() => l10n.a11y_missionCompleted(e.missionName, e.bonus),
    };
    final (bool levelUp, int level) = switch (e) {
      QuestReward() => (e.levelUp, e.level),
      MissionReward() => (e.levelUp, e.level),
    };
    announce(context, levelUp ? '$text. ${l10n.a11y_levelUp(level)}' : text);
  }

  /// Fades the card out, then pops it from the queue so the next one shows.
  Future<void> _dismiss() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    _autoDismiss?.cancel();
    final RewardQueue queue = ref.read(rewardQueueProvider.notifier);
    await _controller.reverse();
    if (!mounted) return;
    queue.dismissCurrent();
  }

  void _completeMission(int missionId) {
    if (_dismissing) return;
    widget.onCompleteMission(missionId);
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final RewardEvent e = widget.event;
    final int? missionId = e is QuestReward && e.mission != null
        ? e.missionId
        : null;
    final Mission? mission = missionId == null
        ? null
        : ref.watch(missionDetailProvider(missionId)).value?.mission;
    final int? offeredMissionId = RewardCard.offersMissionComplete(e)
        ? (e as QuestReward).missionId
        : null;

    final Animation<double> curved = CurvedAnimation(
      parent: _controller,
      curve: Motion.curve,
    );
    Widget card = RewardCard(
      event: e,
      missionName: mission?.name,
      missionBonus: mission?.bonus.xp,
      onContinue: _dismiss,
      onCompleteMission: offeredMissionId == null
          ? null
          : () => _completeMission(offeredMissionId),
      rays: _reduced ? null : curved,
    );
    card = _reduced
        ? card
        : ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: card,
          );

    // The scrim tap sits above the scroll view: a Scrollable swallows taps on
    // its empty area, so a detector underneath would never fire.
    return FadeTransition(
      opacity: curved,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Semantics(
              button: true,
              label: AppLocalizations.of(context).a11y_dismissReward,
              excludeSemantics: true,
              onTap: _dismiss,
              child: ColoredBox(color: context.palette.scrim),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) =>
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(Space.s24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(0, box.maxHeight - 2 * Space.s24),
                        ),
                        child: Center(
                          // Swallows taps on the card so they never reach the
                          // scrim.
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            child: card,
                          ),
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
