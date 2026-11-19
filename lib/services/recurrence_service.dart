import 'package:drift/drift.dart';

import '../core/board_day.dart';
import '../core/cadence.dart';
import '../core/clock.dart';
import '../core/errors.dart';
import '../core/validation.dart';
import '../data/database.dart';
import '../data/mappers.dart';
import '../data/models.dart';
import '../data/quest_writes.dart';

/// Manages Recurring_Rules and posts their Instances, either when the caller
/// asks for Reconciliation or on demand.
///
/// Nothing here runs on a timer: the UI calls [reconcile] at launch and when
/// the app resumes.
class RecurrenceService {
  RecurrenceService(this._db, this._clock);

  final QuestlogDatabase _db;
  final Clock _clock;

  /// Stores a rule and its quest templates. The Anchor_Date becomes the first
  /// Occurrence of the requested series on or after Today.
  Future<RecurringRule> create(RuleDraft draft) async {
    final name = _validate(draft);
    return _db.runTransaction(() async {
      final now = _clock.now();
      final anchor = firstAnchor(
        draft.cadence,
        draft.requestedAnchor,
        today: todayOf(now),
      );
      final id = await _db.into(_db.recurringRules).insert(
            RecurringRulesCompanion.insert(
              name: name,
              cadence: draft.cadence,
              anchorDate: anchor,
              bonus: draft.bonus,
              createdAt: now,
            ),
          );
      await _insertTemplates(id, draft.quests);
      return _loadRule(id);
    });
  }

  /// Replaces the rule's settings and quest templates. Existing Instances are
  /// not touched.
  ///
  /// The Anchor_Date is reset, together with the Next_Occurrence index, only when
  /// the Cadence or the posting day changes. The posting day is the weekday for
  /// Weekly and Biweekly, the day of the month for Monthly, the month of the
  /// quarter and day for Quarterly, and the month and day for Yearly; Daily has
  /// none. Otherwise a rule that was posted early keeps skipping its next
  /// automatic Posting.
  Future<RecurringRule> update(int id, RuleDraft draft) async {
    final name = _validate(draft);
    return _db.runTransaction(() async {
      final rule = await _load(id);
      final changed = rule.cadence != draft.cadence ||
          _postingDayChanged(draft.cadence, rule.anchorDate, draft.requestedAnchor);
      var companion = RecurringRulesCompanion(
        name: Value(name),
        cadence: Value(draft.cadence),
        bonus: Value(draft.bonus),
      );
      if (changed) {
        final anchor = firstAnchor(
          draft.cadence,
          draft.requestedAnchor,
          today: todayOf(_clock.now()),
          lastPosted: rule.lastPostedOn,
        );
        companion = companion.copyWith(anchorDate: Value(anchor), nextIndex: const Value(0));
      }
      await (_db.update(_db.recurringRules)..where((r) => r.id.equals(id))).write(companion);
      await (_db.delete(_db.ruleQuests)..where((t) => t.ruleId.equals(id))).go();
      await _insertTemplates(id, draft.quests);
      return _loadRule(id);
    });
  }

  /// Deletes the rule and its templates. Its `open` Instance stays as an
  /// ordinary Mission.
  Future<void> delete(int id) {
    return _db.runTransaction(() async {
      await _load(id);
      await (_db.delete(_db.recurringRules)..where((r) => r.id.equals(id))).go();
    });
  }

  /// Posts one Instance of every rule whose Next_Occurrence is Today or earlier,
  /// in one transaction, and returns the new Missions.
  ///
  /// However many Occurrences were missed, a rule posts once; running it again on
  /// the same Board_Day posts nothing.
  Future<List<Mission>> reconcile() {
    return _db.runTransaction(() async {
      final today = todayOf(_clock.now());
      final rules = await (_db.select(_db.recurringRules)
            ..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .get();
      final posted = <Mission>[];
      for (final rule in rules) {
        final due = occurrenceDate(rule.anchorDate, rule.cadence, rule.nextIndex);
        if (due.isAfter(today)) continue;
        final instance = await _postInstance(rule, today);
        await _advance(rule.id, today,
            firstIndexAfter(rule.anchorDate, rule.cadence, today));
        posted.add(instance.mission);
      }
      return posted;
    });
  }

  /// Posts the rule now. When its Next_Occurrence was still ahead, that Posting
  /// is skipped; otherwise the rule moves on to the first Occurrence after Today.
  Future<PostResult> postNow(int ruleId) {
    return _db.runTransaction(() async {
      final rule = await _load(ruleId);
      final today = todayOf(_clock.now());
      final next = occurrenceDate(rule.anchorDate, rule.cadence, rule.nextIndex);
      final skipped = next.isAfter(today);
      final instance = await _postInstance(rule, today);
      await _advance(
        ruleId,
        today,
        skipped
            ? rule.nextIndex + 1
            : firstIndexAfter(rule.anchorDate, rule.cadence, today),
      );
      return PostResult(
        mission: instance.mission,
        skippedNextPosting: skipped,
        closedPreviousInstance: instance.closedPrevious,
      );
    });
  }

  /// All rules with their templates, next date and whether an Instance is open.
  Stream<List<RuleSummary>> watchRules() {
    // A plain select would only see the rules table; this also reacts to the
    // templates and to Missions opening and closing.
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.recurringRules, _db.ruleQuests, _db.missions},
        )
        .watch()
        .asyncMap((_) => _loadSummaries());
  }

  Future<List<RuleSummary>> _loadSummaries() async {
    final rules = await (_db.select(_db.recurringRules)
          ..orderBy([(r) => OrderingTerm.asc(r.createdAt), (r) => OrderingTerm.asc(r.id)]))
        .get();
    final summaries = <RuleSummary>[];
    for (final rule in rules) {
      final openInstances = await (_db.select(_db.missions)
            ..where((m) => m.ruleId.equals(rule.id) & m.status.equalsValue(MissionStatus.open))
            ..limit(1))
          .get();
      summaries.add(
        RuleSummary(
          id: rule.id,
          name: rule.name,
          cadence: rule.cadence,
          anchorDate: rule.anchorDate,
          bonus: rule.bonus,
          quests: await _templates(rule.id),
          nextOccurrence: occurrenceDate(rule.anchorDate, rule.cadence, rule.nextIndex),
          hasOpenInstance: openInstances.isNotEmpty,
        ),
      );
    }
    return summaries;
  }

  /// Closes the rule's earlier `open` Instance and creates the new one.
  Future<({Mission mission, bool closedPrevious})> _postInstance(
    RecurringRuleRow rule,
    DateTime today,
  ) async {
    final earlier = await (_db.select(_db.missions)
          ..where((m) => m.ruleId.equals(rule.id) & m.status.equalsValue(MissionStatus.open)))
        .get();
    for (final mission in earlier) {
      // The open Quests go; the done ones stay, with the XP they already earned.
      await (_db.delete(_db.quests)
            ..where((q) => q.missionId.equals(mission.id) & q.completedAt.isNull()))
          .go();
      await (_db.update(_db.missions)..where((m) => m.id.equals(mission.id))).write(
        const MissionsCompanion(status: Value(MissionStatus.closed)),
      );
    }

    final now = _clock.now();
    final missionId = await _db.into(_db.missions).insert(
          MissionsCompanion.insert(
            name: rule.name,
            bonus: rule.bonus,
            createdAt: now,
            ruleId: Value(rule.id),
            sortOrder: Value(await nextMissionSortOrder(_db)),
          ),
        );
    for (final template in await _templates(rule.id)) {
      await insertQuestLast(
        _db,
        name: template.name,
        note: null,
        difficulty: template.difficulty,
        missionId: missionId,
        createdAt: now,
      );
    }
    final row =
        await (_db.select(_db.missions)..where((m) => m.id.equals(missionId))).getSingle();
    return (mission: row.toModel(), closedPrevious: earlier.isNotEmpty);
  }

  Future<void> _advance(int ruleId, DateTime today, int nextIndex) {
    return (_db.update(_db.recurringRules)..where((r) => r.id.equals(ruleId))).write(
      RecurringRulesCompanion(nextIndex: Value(nextIndex), lastPostedOn: Value(today)),
    );
  }

  String _validate(RuleDraft draft) {
    final name = validatedName(draft.name, 'name');
    if (draft.quests.isEmpty) {
      throw const ValidationError('quests', 'a rule needs at least one quest template');
    }
    for (final quest in draft.quests) {
      validatedName(quest.name, 'quests.name');
    }
    final day = draft.requestedAnchor.day;
    if (draft.cadence == Cadence.monthly && (day < 1 || day > 28)) {
      throw const ValidationError('postingDay', 'must be between 1 and 28 for a monthly rule');
    }
    return name;
  }

  bool _postingDayChanged(Cadence cadence, DateTime stored, DateTime requested) {
    return switch (cadence) {
      Cadence.daily => false,
      Cadence.weekly || Cadence.biweekly => stored.weekday != requested.weekday,
      Cadence.monthly => stored.day != requested.day,
      Cadence.quarterly =>
        stored.day != requested.day || stored.month % 3 != requested.month % 3,
      Cadence.yearly => stored.day != requested.day || stored.month != requested.month,
    };
  }

  Future<void> _insertTemplates(int ruleId, List<RuleQuestDraft> quests) async {
    for (var i = 0; i < quests.length; i++) {
      await _db.into(_db.ruleQuests).insert(
            RuleQuestsCompanion.insert(
              ruleId: ruleId,
              name: validatedName(quests[i].name, 'quests.name'),
              difficulty: quests[i].difficulty,
              sortOrder: i,
            ),
          );
    }
  }

  Future<List<RuleQuest>> _templates(int ruleId) async {
    final rows = await (_db.select(_db.ruleQuests)
          ..where((t) => t.ruleId.equals(ruleId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return [
      for (final row in rows)
        RuleQuest(name: row.name, difficulty: row.difficulty, sortOrder: row.sortOrder),
    ];
  }

  Future<RecurringRuleRow> _load(int id) async {
    final row =
        await (_db.select(_db.recurringRules)..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null) throw NotFoundError('rule', id);
    return row;
  }

  Future<RecurringRule> _loadRule(int id) async {
    final row = await _load(id);
    return RecurringRule(
      id: row.id,
      name: row.name,
      cadence: row.cadence,
      anchorDate: row.anchorDate,
      nextIndex: row.nextIndex,
      bonus: row.bonus,
      lastPostedOn: row.lastPostedOn,
      createdAt: row.createdAt,
      quests: await _templates(id),
    );
  }
}
