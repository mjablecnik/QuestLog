import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

/// One action revealed by swiping a row to the left.
class SwipeActionSpec {
  const SwipeActionSpec({
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
}

/// A row that reveals [actions] when swiped to the left. Only one row of a
/// surrounding `SlidableAutoCloseBehavior` stays open at a time. The same
/// actions are offered to assistive technology as custom actions.
class SwipeRow extends StatelessWidget {
  const SwipeRow({
    super.key,
    required this.groupTag,
    required this.actions,
    required this.child,
  });

  final String groupTag;
  final List<SwipeActionSpec> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(Radii.card);
    final double actionWidth = actions.length > 2
        ? Metrics.swipeActionNarrow
        : Metrics.swipeAction;
    return Semantics(
      container: true,
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
        for (final SwipeActionSpec a in actions)
          CustomSemanticsAction(label: a.semanticLabel): a.onPressed,
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double ratio = (actions.length * actionWidth / constraints.maxWidth).clamp(0.0, 1.0);
          return ClipRRect(
            borderRadius: radius,
            child: Slidable(
              groupTag: groupTag,
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: ratio,
                children: <Widget>[for (final SwipeActionSpec a in actions) _Action(spec: a)],
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.spec});

  final SwipeActionSpec spec;

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      key: spec.actionKey,
      onPressed: (BuildContext _) => spec.onPressed(),
      backgroundColor: spec.background,
      foregroundColor: spec.foreground,
      padding: EdgeInsets.zero,
      child: Semantics(
        button: true,
        label: spec.semanticLabel,
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
              AppIcon(spec.icon, size: Metrics.iconSmall, color: spec.foreground),
              const SizedBox(height: Space.s4),
              Text(
                spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyText.labelSmall!.copyWith(
                  letterSpacing: 0,
                  color: spec.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
