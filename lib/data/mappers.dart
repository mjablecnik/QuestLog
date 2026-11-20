import 'database.dart';
import 'models.dart';

extension QuestRowMapping on QuestRow {
  Quest toModel() => Quest(
        id: id,
        name: name,
        note: note,
        difficulty: difficulty,
        missionId: missionId,
        board: board,
        sortOrder: sortOrder,
        createdAt: createdAt,
        completedAt: completedAt,
        awardedXp: awardedXp,
        eventId: eventId,
      );
}

extension MissionRowMapping on MissionRow {
  Mission toModel() => Mission(
        id: id,
        name: name,
        bonus: bonus,
        status: status,
        ruleId: ruleId,
        createdAt: createdAt,
        completedAt: completedAt,
        awardedBonus: awardedBonus,
      );
}
