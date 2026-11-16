import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// Wraps a Mission card with the "Upravit" / "Smazat" swipe actions and the
/// collapse transition used when the Mission is deleted.
///
/// Only one row of the surrounding `SlidableAutoCloseBehavior` stays open at a
/// time; pressing either action closes the row again.
class MissionSwipeRow extends StatelessWidget {
  const MissionSwipeRow({
    super.key,
    required this.missionName,
    required this.onEdit,
    required this.onDelete,
    required this.child,
    this.leaving = false,
  });

  final String missionName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Widget child;

  /// True while the row plays its removal transition.
  final bool leaving;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final BorderRadius radius = BorderRadius.circular(Radii.card);

    final Widget row = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double ratio = (2 * Metrics.swipeAction / constraints.maxWidth)
            .clamp(0.0, 1.0);
        return ClipRRect(
          borderRadius: radius,
          child: Slidable(
            groupTag: 'missions',
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: ratio,
              children: <Widget>[
                _Action(
                  label: l.common_edit,
                  semanticLabel: l.a11y_editMission(missionName),
                  icon: IconAsset.edit,
                  background: p.boardRaised,
                  foreground: p.text,
                  onPressed: onEdit,
                  actionKey: const ValueKey<String>('mission-swipe-edit'),
                ),
                _Action(
                  label: l.common_delete,
                  semanticLabel: l.a11y_deleteMission(missionName),
                  icon: IconAsset.trash,
                  background: p.destructive,
                  foreground: p.inkOnDestructive,
                  onPressed: onDelete,
                  actionKey: const ValueKey<String>('mission-swipe-delete'),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );

    return _Collapse(collapsed: leaving, child: row);
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
    required this.actionKey,
  });

  final String label;
  final String semanticLabel;
  final String icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
  final Key actionKey;

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      key: actionKey,
      onPressed: (BuildContext _) => onPressed(),
      backgroundColor: background,
      foregroundColor: foreground,
      padding: EdgeInsets.zero,
      child: Semantics(
        button: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: Metrics.touchTarget,
            minHeight: Metrics.touchTarget,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppIcon(icon, size: Metrics.iconSmall, color: foreground),
              const SizedBox(height: Space.s4),
              Text(
                label,
                style: context.bodyText.labelSmall!.copyWith(
                  letterSpacing: 0,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades the row out and, unless reduced motion is requested, collapses its
/// height; reduced motion uses the short plain fade only.
class _Collapse extends StatelessWidget {
  const _Collapse({required this.collapsed, required this.child});

  final bool collapsed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    final Duration duration = reduced ? Motion.reducedFade : Motion.panel;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1, end: collapsed ? 0 : 1),
      duration: duration,
      curve: Motion.curve,
      child: child,
      builder: (BuildContext context, double t, Widget? child) {
        // Same tree at every value so the Slidable keeps its state.
        return Opacity(
          opacity: t,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: reduced ? 1 : t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
