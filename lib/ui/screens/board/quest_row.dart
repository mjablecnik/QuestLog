import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/cards/quest_card.dart';
import '../../widgets/common/app_icon.dart';

/// One Quest_Card with the swipe actions "Upravit" and "Smazat" behind it.
///
/// A horizontal drag slides the card; the long-press reorder gesture is
/// attached by the list around this widget, so the two never compete (a
/// long press that does not move is not a swipe).
class QuestRow extends StatelessWidget {
  const QuestRow({
    super.key,
    required this.quest,
    required this.completedLabel,
    this.missionName,
    this.deadline,
    this.today,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Quest quest;

  /// Completion time of a done Quest, already localized.
  final String? completedLabel;

  /// Name of the Mission the Quest belongs to, shown on its card.
  final String? missionName;
  /// The Quest's Deadline and the Board_Day date, for the card.
  final DateTime? deadline;
  final DateTime? today;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final String name = quest.name;
    final BorderRadius deleteRadius = const BorderRadius.horizontal(
      right: Radius.circular(Radii.card),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s20, 0, Space.s20, Space.s10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Two actions of Metrics.swipeAction each, as a share of the card.
          final double ratio = constraints.maxWidth.isFinite
              ? (2 * Metrics.swipeAction / constraints.maxWidth).clamp(0.1, 1.0)
              : 0.5;
          return Slidable(
            endActionPane: ActionPane(
              motion: const BehindMotion(),
              extentRatio: ratio,
              children: <Widget>[
                _Action(
                  label: l.common_edit,
                  semanticLabel: l.a11y_editQuest(name),
                  icon: IconAsset.edit,
                  background: p.boardRaised,
                  foreground: p.text,
                  onPressed: onEdit,
                ),
                _Action(
                  label: l.common_delete,
                  semanticLabel: l.a11y_deleteQuest(name),
                  icon: IconAsset.trash,
                  background: p.destructive,
                  foreground: p.inkOnDestructive,
                  radius: deleteRadius,
                  onPressed: onDelete,
                ),
              ],
            ),
            child: QuestCard(
              quest: quest,
              completedLabel: completedLabel,
              missionName: missionName,
              deadline: deadline,
              today: today,
              onToggle: onToggle,
              onTap: onEdit,
            ),
          );
        },
      ),
    );
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
    this.radius = BorderRadius.zero,
  });

  final String label;
  final String semanticLabel;
  final String icon;
  final Color background;
  final Color foreground;
  final BorderRadius radius;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomSlidableAction(
      backgroundColor: background,
      foregroundColor: foreground,
      borderRadius: radius,
      onPressed: (_) => onPressed(),
      child: Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AppIcon(icon, size: Metrics.iconSmall, color: foreground),
            const SizedBox(height: Space.s4),
            Text(
              label,
              style: context.bodyText.bodySmall!.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
