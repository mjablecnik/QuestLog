import 'dart:ui' show FlutterView;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../l10n/app_localizations.dart';

/// Sends [message] to the screen reader of the view [context] lives in.
///
/// Already localized text only. Does nothing when there is no [View].
Future<void> announce(BuildContext context, String message) async {
  final FlutterView? view = View.maybeOf(context);
  if (view == null) return;
  final TextDirection direction =
      Directionality.maybeOf(context) ?? TextDirection.ltr;
  await SemanticsService.sendAnnouncement(view, message, direction);
}

/// "Quest {name} completed, +{xp} XP".
Future<void> announceQuestCompleted(
  BuildContext context,
  AppLocalizations l10n,
  String questName,
  int xp,
) => announce(context, l10n.a11y_questCompleted(questName, xp));

/// "Quest {name} reopened".
Future<void> announceQuestReopened(
  BuildContext context,
  AppLocalizations l10n,
  String questName,
) => announce(context, l10n.a11y_questReopened(questName));

/// "Mission {name} completed, bonus +{xp} XP".
Future<void> announceMissionCompleted(
  BuildContext context,
  AppLocalizations l10n,
  String missionName,
  int bonusXp,
) => announce(context, l10n.a11y_missionCompleted(missionName, bonusXp));

/// "Mission {name} reopened".
Future<void> announceMissionReopened(
  BuildContext context,
  AppLocalizations l10n,
  String missionName,
) => announce(context, l10n.a11y_missionReopened(missionName));

/// "Level up, level {level}".
Future<void> announceLevelUp(
  BuildContext context,
  AppLocalizations l10n,
  int level,
) => announce(context, l10n.a11y_levelUp(level));
