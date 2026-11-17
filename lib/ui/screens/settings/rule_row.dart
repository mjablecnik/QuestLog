import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../sheets/rule_sheet.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';

/// One rule in the Settings list: tinted icon tile, name, a line with the
/// Cadence, quest count and Next_Occurrence, and the "Post now" pill.
///
/// Tapping the left part opens the rule for editing; the pill posts the rule
/// by hand. While an Instance is open the pill reads "Posted" and is dimmed,
/// but stays active: posting again closes the open Instance (requirement 12.4).
class RuleRow extends StatelessWidget {
  const RuleRow({
    super.key,
    required this.rule,
    required this.onEdit,
    required this.onPostNow,
  });

  final RuleSummary rule;
  final VoidCallback onEdit;
  final VoidCallback onPostNow;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final body = context.bodyText;
    final line = l.rule_line(
      ruleCadenceLabel(l, rule.cadence),
      rule.quests.length,
      DateFormat.MMMd(l.localeName).format(rule.nextOccurrence),
    );

    return Material(
      color: p.field,
      borderRadius: BorderRadius.circular(Radii.control),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              button: true,
              label: '${rule.name}, $line',
              excludeSemantics: true,
              onTap: onEdit,
              child: InkWell(
                onTap: onEdit,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: Metrics.ruleIcon + Space.s24,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.s12,
                      Space.s12,
                      Space.s4,
                      Space.s12,
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: Metrics.ruleIcon,
                          height: Metrics.ruleIcon,
                          decoration: BoxDecoration(
                            color: p.brassSoft,
                            borderRadius: BorderRadius.circular(Radii.control),
                          ),
                          alignment: Alignment.center,
                          child: AppIcon(
                            IconAsset.repeat,
                            size: Metrics.iconSize,
                            color: p.brass,
                          ),
                        ),
                        const SizedBox(width: Space.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                rule.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: body.titleMedium,
                              ),
                              const SizedBox(height: Space.s2),
                              Text(
                                line,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: body.bodySmall!.copyWith(
                                  color: p.textDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _PostPill(
            posted: rule.hasOpenInstance,
            semanticLabel: '${l.rule_postNow}: ${rule.name}',
            onTap: onPostNow,
          ),
          const SizedBox(width: Space.s8),
        ],
      ),
    );
  }
}

/// "Post now" / "Posted" pill, 30 px painted inside a 44 px hit area.
class _PostPill extends StatelessWidget {
  const _PostPill({
    required this.posted,
    required this.semanticLabel,
    required this.onTap,
  });

  final bool posted;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final Color color = posted ? p.textFaint : p.brassText;
    return Semantics(
      button: true,
      label: semanticLabel,
      value: posted ? l.rule_posted : null,
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: Metrics.touchTarget / 2 + Space.s8,
        highlightShape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: Metrics.touchTarget,
            minHeight: Metrics.touchTarget,
          ),
          child: Center(
            widthFactor: 1,
            child: Container(
              height: Metrics.postPill,
              padding: const EdgeInsets.symmetric(horizontal: Space.s12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.pill),
                border: Border.all(color: color, width: Metrics.hairline),
              ),
              child: Text(
                posted ? l.rule_posted : l.rule_postNow,
                style: context.bodyText.labelLarge!.copyWith(color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed "Add a recurring mission" row below the rules.
class AddRuleRow extends StatelessWidget {
  const AddRuleRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.rule_addRow,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.control),
        onTap: onTap,
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: p.textFaint,
            radius: Radii.control,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: Metrics.touchTarget + Space.s12,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: Metrics.addPlus,
                    height: Metrics.addPlus,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.brassSoft,
                    ),
                    alignment: Alignment.center,
                    child: AppIcon(
                      IconAsset.plus,
                      size: Metrics.iconSmall,
                      color: p.brass,
                    ),
                  ),
                  const SizedBox(width: Space.s12),
                  Expanded(
                    child: Text(
                      l.rule_addRow,
                      style: context.bodyText.bodyLarge!.copyWith(
                        color: p.textDim,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
