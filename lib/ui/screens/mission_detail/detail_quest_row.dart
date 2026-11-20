import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/check_circle.dart';
import '../../widgets/cards/deadline_label.dart';
import '../../widgets/cards/difficulty_pips.dart';
import '../../widgets/common/app_icon.dart';

/// Group tag that makes an open swipe pane close when another row is swiped.
const String _swipeGroup = 'mission-detail-quests';

/// One Quest of the Mission detail: a parchment slip while open (light theme)
/// or a dark raised card (dark theme), a dimmed card once done, with the swipe actions "Upravit" and "Smazat".
///
/// An open Quest shows its effort pips (never a tier name), a done one when it was
/// completed. The Mission is not repeated on the row, the screen is its page.
class DetailQuestRow extends StatelessWidget {
  const DetailQuestRow({
    super.key,
    required this.quest,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.completedLabel,
    this.deadline,
    this.today,
  });

  /// The Deadline of an open Quest and the Board_Day date.
  final DateTime? deadline;
  final DateTime? today;

  final Quest quest;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Already localized completion time, shown on a done Quest.
  final String? completedLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final bool done = quest.isDone;
    final int xp = quest.awardedXp ?? quest.difficulty.xp;
    final TextStyle meta = context.bodyText.bodySmall!.copyWith(
      color: done ? p.textFaint : p.slipTextDim,
    );
    final TextStyle xpStyle = context.displayText.titleMedium!.copyWith(
      color: p.brass,
    );

    final BorderRadius radius = BorderRadius.circular(Radii.card);
    final Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: done ? p.slipDone : p.slip,
        borderRadius: radius,
        border: Border.all(
          color: done ? p.boardLine : p.slipEdge,
          width: Metrics.hairline,
        ),
        boxShadow: done || !p.isLight
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: p.ink.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, Space.s6),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.s6,
              Space.s8,
              Space.s16,
              Space.s8,
            ),
            child: Row(
              children: <Widget>[
                CheckCircle(
                  checked: done,
                  onTap: onToggle,
                  semanticLabel: done
                      ? l.a11y_reopenQuest(quest.name)
                      : l.a11y_completeQuest(quest.name),
                ),
                const SizedBox(width: Space.s6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Space.s4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          quest.name,
                          style: context.bodyText.titleMedium!.copyWith(
                            color: done ? p.textDim : p.slipText,
                            decoration: done
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: p.textFaint,
                          ),
                        ),
                        const SizedBox(height: Space.s4),
                        if (done)
                          if (completedLabel != null)
                            Text(completedLabel!, style: meta)
                          else
                            const SizedBox.shrink()
                        else
                          Wrap(
                            spacing: Space.s8,
                            runSpacing: Space.s4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              DifficultyPips(quest.difficulty),
                              if (deadline != null && today != null)
                                DeadlineLabel(deadline: deadline!, today: today!, style: meta),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Space.s8),
                done
                    ? Opacity(opacity: 0.7, child: Text('+$xp', style: xpStyle))
                    : Text('+$xp', style: xpStyle),
              ],
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s12),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double ratio = constraints.hasBoundedWidth
              ? (2 * Metrics.swipeAction / constraints.maxWidth).clamp(0.2, 0.9)
              : 0.5;
          return Slidable(
            groupTag: _swipeGroup,
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: ratio,
              children: <Widget>[
                _SwipeAction(
                  label: l.common_edit,
                  semanticLabel: l.a11y_editQuest(quest.name),
                  icon: IconAsset.edit,
                  background: p.boardRaised,
                  foreground: p.text,
                  onPressed: onEdit,
                ),
                _SwipeAction(
                  label: l.common_delete,
                  semanticLabel: l.a11y_deleteQuest(quest.name),
                  icon: IconAsset.trash,
                  background: p.destructive,
                  foreground: p.inkOnDestructive,
                  onPressed: onDelete,
                  radius: BorderRadius.horizontal(
                    right: Radius.circular(Radii.card),
                  ),
                ),
              ],
            ),
            child: card,
          );
        },
      ),
    );
  }
}

class _SwipeAction extends StatelessWidget {
  const _SwipeAction({
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.radius,
  });

  final String label;
  final String semanticLabel;
  final String icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (BuildContext _) => onPressed(),
      backgroundColor: background,
      foregroundColor: foreground,
      borderRadius: radius ?? BorderRadius.zero,
      padding: EdgeInsets.zero,
      child: Semantics(
        button: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppIcon(icon, size: Metrics.iconSmall, color: foreground),
            const SizedBox(height: Space.s4),
            Text(
              label,
              style: context.bodyText.labelMedium!.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
