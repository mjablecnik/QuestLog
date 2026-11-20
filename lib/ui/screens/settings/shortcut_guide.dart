import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/questlog_segmented.dart';
import '../../widgets/common/snackbar_host.dart';
import '../shell/questlog_tab_bar.dart';

/// Settings guide for a Home Screen icon that opens QuestLog on a chosen tab:
/// pick the tab, copy its `questlog://` link, follow the Shortcuts steps.
///
/// Collapsed to one row by default so it does not push the rest of Settings
/// down; the link itself is built from the same tab names the deep link
/// handler reads (`shellTabFromUri`).
class ShortcutGuide extends StatefulWidget {
  const ShortcutGuide({super.key});

  @override
  State<ShortcutGuide> createState() => _ShortcutGuideState();
}

class _ShortcutGuideState extends State<ShortcutGuide> {
  bool _open = false;
  ShellTab _target = ShellTab.calendar;

  /// The tabs offered as a target; Settings itself is pointless to open.
  static const List<ShellTab> _targets = <ShellTab>[
    ShellTab.calendar,
    ShellTab.quests,
    ShellTab.missions,
    ShellTab.notes,
  ];

  String get _link => 'questlog://${_target.name}';

  String _tabName(AppLocalizations l, ShellTab tab) => switch (tab) {
    ShellTab.quests => l.app_tabQuests,
    ShellTab.missions => l.app_tabMissions,
    ShellTab.calendar => l.app_tabCalendar,
    ShellTab.notes => l.app_tabNotes,
    ShellTab.settings => l.app_tabSettings,
  };

  Future<void> _copy(BuildContext context) async {
    final l = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: _link));
    if (!context.mounted) return;
    showQuestlogSnack(context, l.settings_shortcutCopied);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final TextStyle small = context.bodyText.bodySmall!.copyWith(
      color: p.textDim,
    );

    final List<String> steps = <String>[
      l.settings_shortcutStep1,
      l.settings_shortcutStep2,
      l.settings_shortcutStep3,
      l.settings_shortcutStep4,
      l.settings_shortcutStep5,
      l.settings_shortcutStep6,
    ];

    return Container(
      decoration: BoxDecoration(
        color: p.boardRaised,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            button: true,
            expanded: _open,
            label: l.settings_shortcutTitle,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.card),
              onTap: () => setState(() => _open = !_open),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Metrics.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Space.s16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l.settings_shortcutTitle,
                              style: context.bodyText.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: Space.s4),
                            Text(l.settings_shortcutSubtitle, style: small),
                          ],
                        ),
                      ),
                      const SizedBox(width: Space.s12),
                      AnimatedRotation(
                        turns: _open ? 0.25 : 0,
                        duration: Motion.hover,
                        child: AppIcon(
                          IconAsset.chevronRight,
                          size: Metrics.iconSmall,
                          color: p.textFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.s16,
                0,
                Space.s16,
                Space.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(l.settings_shortcutPickLabel, style: small),
                  const SizedBox(height: Space.s8),
                  QuestlogSegmented<ShellTab>(
                    options: <SegmentedOption<ShellTab>>[
                      for (final ShellTab tab in _targets)
                        SegmentedOption<ShellTab>(
                          value: tab,
                          label: _tabName(l, tab),
                        ),
                    ],
                    selected: _target,
                    onChanged: (ShellTab tab) => setState(() => _target = tab),
                  ),
                  const SizedBox(height: Space.s16),
                  _LinkBox(link: _link, onCopy: () => _copy(context)),
                  const SizedBox(height: Space.s16),
                  for (int i = 0; i < steps.length; i++)
                    _Step(number: i + 1, text: steps[i]),
                  const SizedBox(height: Space.s4),
                  Text(
                    l.settings_shortcutNote,
                    style: small.copyWith(color: p.textFaint),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The link in a field-coloured box with a copy button beside it.
class _LinkBox extends StatelessWidget {
  const _LinkBox({required this.link, required this.onCopy});

  final String link;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.only(left: Space.s16),
      decoration: BoxDecoration(
        color: p.field,
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SelectableText(
              link,
              style: context.bodyText.bodyMedium,
            ),
          ),
          Semantics(
            button: true,
            label: l.settings_shortcutCopyLink,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(Radii.control),
              onTap: onCopy,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Metrics.touchTarget + Space.s4,
                  minWidth: Metrics.touchTarget,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s16),
                  child: Center(
                    child: Text(
                      l.settings_shortcutCopyLink,
                      style: context.bodyText.bodyMedium!.copyWith(
                        color: p.brassText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One numbered step.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: Space.s24,
            height: Space.s24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.brassSoft,
              shape: BoxShape.circle,
            ),
            child: ExcludeSemantics(
              child: Text(
                '$number',
                style: context.bodyText.labelSmall!.copyWith(
                  color: p.brassText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: Space.s12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: Space.s2),
              child: Text(text, style: context.bodyText.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}
