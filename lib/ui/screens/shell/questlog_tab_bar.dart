import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// The four tabs of the shell; Settings lives in the bar, not behind a button.
enum ShellTab { quests, missions, calendar, notes, settings }

/// Bottom bar with the tabs Questy, Mise, Kalendář, Poznámky and Nastavení; the active one is
/// brass, the others faint (see `.tabbar` in the design).
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
                      icon: switch (tab) {
                        ShellTab.quests => IconAsset.quests,
                        ShellTab.missions => IconAsset.missions,
                        ShellTab.calendar => IconAsset.calendar,
                        ShellTab.notes => IconAsset.notes,
                        ShellTab.settings => IconAsset.gear,
                      },
                      label: switch (tab) {
                        ShellTab.quests => l10n.app_tabQuests,
                        ShellTab.missions => l10n.app_tabMissions,
                        ShellTab.calendar => l10n.app_tabCalendar,
                        ShellTab.notes => l10n.app_tabNotes,
                        ShellTab.settings => l10n.app_tabSettings,
                      },
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
    final Color color = selected ? p.brassText : p.textFaint;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.control),
        // The design marks the active tab by colour alone: a touch, a pointer
        // resting on a tab (desktop, iPad) or a leftover focus must not paint
        // a pill behind it.
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
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
