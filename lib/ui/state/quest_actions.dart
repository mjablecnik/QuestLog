import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/providers.dart';
import '../forms/error_text.dart';
import '../widgets/common/announce.dart';
import '../widgets/common/haptics.dart';
import '../widgets/common/snackbar_host.dart';
import 'reward_queue.dart';

/// Shows the message for a failed service call.
///
/// A not-found, invalid-state or validation error (a rejected reorder) means
/// the list was stale. The streams normally refresh it by themselves; every
/// table is marked as updated as well so that every list queries again, even
/// after a change the watchers were not told about, as the message "the list
/// was refreshed" promises.
void showDomainError(BuildContext context, Object error, {double? clearance}) {
  final l10n = AppLocalizations.of(context);
  if (error is NotFoundError ||
      error is InvalidStateError ||
      error is ValidationError) {
    final db = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(databaseProvider);
    db.markTablesUpdated(db.allTables);
  }
  final String text = error is DomainError
      ? domainErrorText(l10n, error)
      : l10n.error_unknown;
  if (clearance == null) {
    showQuestlogSnack(context, text);
  } else {
    showQuestlogSnack(context, text, bottomClearance: clearance);
  }
}

/// Completes or reopens [quest] (the check tap), shared by the Board and the
/// Mission detail so both behave the same.
///
/// Completion shows no popup or animation: the Quest simply moves to the done
/// list, with a haptic tap and a screen-reader announcement. Reopening shows the
/// withdrawal message (with the Mission-reopened note when it applies). A failure leaves the card
/// as it was and shows an error message.
Future<void> toggleQuest(
  BuildContext context,
  WidgetRef ref,
  Quest quest, {
  double? clearance,
}) async {
  final l10n = AppLocalizations.of(context);
  final service = ref.read(questServiceProvider);
  try {
    if (quest.completedAt == null) {
      final result = await service.complete(quest.id);
      if (!context.mounted) return;
      Haptics.success();
      final String text = l10n.a11y_questCompleted(quest.name, result.awardedXp);
      announce(
        context,
        result.levelAfter > result.levelBefore
            ? '$text. ${l10n.a11y_levelUp(result.levelAfter)}'
            : text,
      );
    } else {
      final result = await service.reopen(quest.id);
      if (!context.mounted) return;
      Haptics.light();
      announceQuestReopened(context, l10n, quest.name);
      final String text = result.missionReopened
          ? l10n.board_rewardWithdrawnMissionReopened(
              result.revokedXp + result.revokedBonus,
            )
          : l10n.board_rewardWithdrawn(result.revokedXp);
      if (clearance == null) {
        showQuestlogSnack(context, text);
      } else {
        showQuestlogSnack(context, text, bottomClearance: clearance);
      }
    }
  } catch (error) {
    if (context.mounted) showDomainError(context, error, clearance: clearance);
  }
}

/// Completes the Mission [missionId] and pushes its reward.
Future<void> completeMission(
  BuildContext context,
  WidgetRef ref,
  int missionId,
) async {
  final queue = ref.read(rewardQueueProvider.notifier);
  try {
    final detail = await ref.read(missionDetailProvider(missionId).future);
    final result = await ref.read(missionServiceProvider).complete(missionId);
    if (detail != null) {
      queue.push(rewardForMission(detail.mission, result));
    }
  } catch (error) {
    if (context.mounted) showDomainError(context, error);
  }
}
