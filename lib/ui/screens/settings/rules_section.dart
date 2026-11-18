import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../forms/error_text.dart';
import '../../sheets/rule_sheet.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/haptics.dart';
import '../../widgets/common/snackbar_host.dart';
import 'rule_row.dart';

/// Recurring rules group of the Settings_Screen (requirement 12): the header
/// with the active count, one row per rule, the add row and its hint. Draws
/// its own group header.
class RulesSection extends ConsumerWidget {
  const RulesSection({super.key});

  Future<void> _postNow(
    BuildContext context,
    WidgetRef ref,
    RuleSummary rule,
  ) async {
    final l = AppLocalizations.of(context);
    unawaited(Haptics.light());
    try {
      final result = await ref.read(recurrenceServiceProvider).postNow(rule.id);
      if (!context.mounted) return;
      final notes = <String>[
        l.rule_postedMessage(result.mission.name),
        if (result.skippedNextPosting) l.rule_postedSkippedNote,
        if (result.closedPreviousInstance) l.rule_postedClosedNote,
      ];
      showQuestlogSnack(context, notes.join(' '));
    } on DomainError catch (error) {
      if (!context.mounted) return;
      showQuestlogSnack(context, domainErrorText(l, error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final l = AppLocalizations.of(context);
    final rules = ref.watch(rulesProvider).value ?? const <RuleSummary>[];
    final labelStyle = context.bodyText.labelSmall!.copyWith(
      color: p.textFaint,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l.settings_groupRules.toUpperCase(),
                  style: labelStyle,
                ),
              ),
            ),
            Text(
              l.settings_rulesActive(rules.length).toUpperCase(),
              style: labelStyle.copyWith(color: p.textDim),
            ),
          ],
        ),
        const SizedBox(height: Space.s8),
        for (final rule in rules) ...<Widget>[
          RuleRow(
            key: ValueKey<int>(rule.id),
            rule: rule,
            onEdit: () => showRuleSheet(context, editing: rule),
            onPostNow: () => _postNow(context, ref, rule),
          ),
          const SizedBox(height: Space.s8),
        ],
        AddRuleRow(onTap: () => showRuleSheet(context)),
        const SizedBox(height: Space.s8),
        Text(
          l.rule_addHint,
          style: context.bodyText.bodySmall!.copyWith(color: p.textFaint),
        ),
      ],
    );
  }
}
