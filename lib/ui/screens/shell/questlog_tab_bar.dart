import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// The two tabs of the shell. There is deliberately no third one.
enum ShellTab { quests, missions }

/// Bottom bar with exactly the two tabs Questy and Mise; the active one is
/// brass, the other faint (see `.tabbar` in the design).
class QuestlogTabBar extends StatelessWidget {
  const QuestlogTabBar({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final ShellTab current;
  final ValueChanged<ShellTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.boardRaised,
        border: Border(
          top: BorderSide(color: p.boardLine, width: Metrics.hairline),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s4),
            child: Row(
              children: <Widget>[
                for (final ShellTab tab in ShellTab.values)
                  Expanded(
                    child: _TabItem(
                      key: ValueKey<ShellTab>(tab),
                      icon: tab == ShellTab.quests
                          ? IconAsset.quests
                          : IconAsset.missions,
                      label: tab == ShellTab.quests
                          ? l10n.app_tabQuests
                          : l10n.app_tabMissions,
                      selected: tab == current,
                      onTap: () => onSelected(tab),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Color color = selected ? p.brass : p.textFaint;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.control),
        // The design marks the active tab by colour alone; a pointer resting
        // on a tab (desktop, iPad) or a leftover focus must not paint a pill.
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppIcon(icon, color: color),
              const SizedBox(height: Space.s4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyText.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
