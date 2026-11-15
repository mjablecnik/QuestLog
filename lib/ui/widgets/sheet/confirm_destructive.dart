import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../common/haptics.dart';

/// Asks the user to confirm a destructive action (delete a Quest or Mission,
/// discard a non-empty sheet) and resolves to `true` only when the
/// destructive button was pressed.
///
/// All texts are passed in already localized:
/// * [title] and [body] explain what is about to happen;
/// * [confirmLabel] names the destructive action ("Smazat", "Zahodit");
/// * [cancelLabel] defaults to the shared "Zrušit" (`common_cancel`); pass a
///   more specific label when "cancel" would be ambiguous (the discard dialog
///   uses "Pokračovat v úpravách").
///
/// Dismissing the dialog through the scrim or the back gesture counts as "no"
/// and resolves to `false`. Pressing the destructive button gives a medium
/// haptic tap. Both buttons are at least 44x44 and stack vertically when the
/// labels do not fit side by side (long labels, large text).
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? cancelLabel,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierColor: context.palette.scrim,
    barrierLabel: AppLocalizations.of(context).common_close,
    builder: (BuildContext dialogContext) => _ConfirmDialog(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
      cancelLabel:
          cancelLabel ?? AppLocalizations.of(dialogContext).common_cancel,
    ),
  );
  return confirmed ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const Size target = Size(Metrics.touchTarget, Metrics.touchTarget);
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.control),
    );

    return AlertDialog(
      scrollable: true,
      title: Text(title),
      content: Text(body, style: context.bodyText.bodyLarge),
      actionsOverflowDirection: VerticalDirection.down,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: target,
            foregroundColor: palette.text,
            shape: shape,
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: target,
            backgroundColor: palette.destructive,
            foregroundColor: palette.inkOnDestructive,
            shape: shape,
          ),
          onPressed: () {
            Haptics.medium();
            Navigator.of(context).pop(true);
          },
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
