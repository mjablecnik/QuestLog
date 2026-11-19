import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/calendar/repeat_rule.dart';
import '../../../data/calendar/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/calendar/calendar_providers.dart';
import '../../../services/calendar/calendar_service.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/snackbar_host.dart';
import '../../widgets/sheet/confirm_destructive.dart';
import '../../widgets/sheet/questlog_sheet.dart';

/// Deletes the occurrence of [event] that starts on [occurrenceDate], after
/// asking: one confirmation for an event without a repeat, a sheet with the
/// three scopes for a repeating one.
///
/// On success it shows a snackbar with "Zpět" that restores everything the
/// deletion removed, and resolves to true; the caller then closes its screens.
/// A failure shows a message, keeps the event and resolves to false.
Future<bool> deleteEventFlow(
  BuildContext context,
  WidgetRef ref,
  CalendarEvent event,
  DateTime occurrenceDate,
) async {
  final AppLocalizations l = AppLocalizations.of(context);
  final CalendarService service = ref.read(calendarServiceProvider);
  DeleteScope? scope;
  if (event.repeat is NoRepeat) {
    final bool ok = await confirmDestructive(
      context,
      title: l.calendar_deleteTitle,
      body: l.calendar_deleteBody(event.name),
      confirmLabel: l.common_delete,
    );
    if (ok) scope = DeleteScope.all;
  } else {
    scope = await showQuestlogSheet<DeleteScope>(
      context,
      builder: (BuildContext _) => _DeleteScopeSheet(name: event.name),
    );
  }
  if (scope == null || !context.mounted) return false;
  try {
    final DeletedEventSnapshot snapshot = await service.deleteOccurrence(event.id, occurrenceDate, scope);
    if (!context.mounted) return true;
    showQuestlogSnack(
      context,
      l.calendar_deleted(event.name),
      actionLabel: l.calendar_undo,
      onAction: () => service.restore(snapshot),
    );
    return true;
  } catch (_) {
    if (context.mounted) showQuestlogSnack(context, l.calendar_deleteFailed);
    return false;
  }
}

class _DeleteScopeSheet extends StatelessWidget {
  const _DeleteScopeSheet({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.control),
    );
    Widget choice(DeleteScope scope, String label) => Padding(
      padding: const EdgeInsets.only(bottom: Space.s8),
      child: FilledButton(
        key: ValueKey<String>('delete-${scope.name}'),
        onPressed: () => Navigator.of(context).pop(scope),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, Metrics.touchTarget + Space.s4),
          backgroundColor: p.destructive,
          foregroundColor: p.inkOnDestructive,
          shape: shape,
        ),
        child: Text(label, textAlign: TextAlign.center, style: context.bodyText.labelLarge),
      ),
    );
    return Material(
      color: p.sheet,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(Space.s20, Space.s20, Space.s20, Space.s12 + media.padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              header: true,
              namesRoute: true,
              child: Text(l.calendar_deleteTitle, style: context.displayText.headlineMedium),
            ),
            const SizedBox(height: Space.s8),
            Text(
              l.calendar_deleteRepeatBody(name),
              style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
            ),
            const SizedBox(height: Space.s16),
            choice(DeleteScope.onlyThis, l.calendar_deleteOnlyThis),
            choice(DeleteScope.thisAndFollowing, l.calendar_deleteThisAndFollowing),
            choice(DeleteScope.all, l.calendar_deleteAll),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, Metrics.touchTarget),
                foregroundColor: p.text,
                shape: shape,
              ),
              child: Text(l.common_cancel, style: context.bodyText.labelLarge),
            ),
          ],
        ),
      ),
    );
  }
}
