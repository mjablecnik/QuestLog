import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/validation.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';

/// The Deadline of an open Quest: "Due 25. 11. 2026", or, once [today] is past
/// it, "Overdue: 25. 11. 2026" in the destructive colour. The words carry the
/// state, so it does not rely on colour alone.
class DeadlineLabel extends StatelessWidget {
  const DeadlineLabel({super.key, required this.deadline, required this.today, required this.style});

  final DateTime deadline;

  /// The calendar date of the current Board_Day.
  final DateTime today;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final String date = DateFormat.yMd(l.localeName).format(deadline);
    final bool overdue = isOverdue(deadline, today);
    return Text(
      overdue ? l.quest_overdueOn(date) : l.quest_dueOn(date),
      key: const ValueKey<String>('quest-deadline'),
      style: overdue
          ? style.copyWith(color: context.palette.destructiveText, fontWeight: FontWeight.w700)
          : style,
    );
  }
}
