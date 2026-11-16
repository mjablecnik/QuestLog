import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/xp_rules.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../state/quest_actions.dart';
import '../../widgets/sheet/confirm_destructive.dart';

/// The Mission_Sheet edits a [MissionSummary]; builds one from the detail.
MissionSummary summaryOf(MissionDetail detail) {
  final Mission mission = detail.mission;
  final int done = detail.quests.where((Quest q) => q.isDone).length;
  final int remaining = detail.quests
      .where((Quest q) => !q.isDone)
      .fold(0, (int sum, Quest q) => sum + q.difficulty.xp);
  return MissionSummary(
    id: mission.id,
    name: mission.name,
    bonus: mission.bonus,
    status: mission.status,
    done: done,
    total: detail.quests.length,
    remainingXp: remaining,
    ruleId: mission.ruleId,
    completedAt: mission.completedAt,
    awardedBonus: mission.awardedBonus,
  );
}

/// Asks for confirmation and deletes [quest]; a done Quest's text says the
/// earned XP is kept.
Future<void> confirmAndDeleteQuest(
  BuildContext context,
  WidgetRef ref,
  Quest quest,
) async {
  final AppLocalizations l = AppLocalizations.of(context);
  final bool confirmed = await confirmDestructive(
    context,
    title: l.quest_deleteTitle,
    body: quest.isDone
        ? l.quest_deleteDoneBody(quest.name)
        : l.quest_deleteBody(quest.name),
    confirmLabel: l.common_delete,
  );
  if (!confirmed) return;
  try {
    await ref.read(questServiceProvider).delete(quest.id);
  } catch (error) {
    if (context.mounted) showDomainError(context, error);
  }
}

/// Asks for confirmation (naming the Mission and its Quest count) and deletes
/// the Mission. Resolves to true only when it was deleted.
Future<bool> confirmAndDeleteMission(
  BuildContext context,
  WidgetRef ref,
  MissionDetail detail,
) async {
  final AppLocalizations l = AppLocalizations.of(context);
  final bool confirmed = await confirmDestructive(
    context,
    title: l.mission_deleteTitle,
    body: l.mission_deleteBody(detail.mission.name, detail.quests.length),
    confirmLabel: l.common_delete,
  );
  if (!confirmed) return false;
  try {
    await ref.read(missionServiceProvider).delete(detail.mission.id);
    return true;
  } catch (error) {
    if (context.mounted) showDomainError(context, error);
    return false;
  }
}
