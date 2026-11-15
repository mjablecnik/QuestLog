import 'package:flutter/material.dart';

import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// Shows a transient message in a floating snackbar styled from the palette.
///
/// A new message replaces the one on screen. The snackbar dismisses itself
/// after [Motion.snack]. [bottomClearance] keeps it above the tab bar and the
/// add button; pass a smaller value where there are neither.
///
/// [message] and [actionLabel] must already be localized.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showQuestlogSnack(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  double bottomClearance = Metrics.snackClearance,
}) {
  assert(
    (actionLabel == null) == (onAction == null),
    'actionLabel and onAction go together',
  );
  final messenger = ScaffoldMessenger.of(context);
  final p = context.palette;
  messenger.clearSnackBars();
  return messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: context.bodyText.bodyMedium),
      duration: Motion.snack,
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.boardRaised,
      elevation: 0,
      margin: EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, bottomClearance),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.control),
        side: BorderSide(color: p.boardLine, width: Metrics.hairline),
      ),
      action: actionLabel == null
          ? null
          : SnackBarAction(
              label: actionLabel,
              textColor: p.brass,
              onPressed: onAction!,
            ),
    ),
  );
}
