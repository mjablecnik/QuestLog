import 'database.dart';
import 'models.dart';

extension QuestRowMapping on QuestRow {
  Quest toModel() => Quest(
        id: id,
        name: name,
        note: note,
        difficulty: difficulty,
        missionId: missionId,
        sortOrder: sortOrder,
        createdAt: createdAt,
        completedAt: completedAt,
        awardedXp: awardedXp,
      );
}
