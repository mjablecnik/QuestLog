import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/xp_rules.dart';
import '../../../data/calendar/calendar_models.dart';
import '../../../data/models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/providers.dart';
import '../../state/event_task_actions.dart';
import '../../state/quest_actions.dart';
import '../../sheets/quest_sheet.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../calendar/event_detail_screen.dart';
import '../../widgets/calendar/event_task_card.dart';
import '../../widgets/cards/quest_card.dart';
import '../../widgets/common/haptics.dart';
import '../../widgets/sheet/confirm_destructive.dart';
import 'quest_row.dart';
import 'section_header.dart';

/// One entry of the flat reorderable list: a section header, the hint shown in
/// an empty section, or a Quest.
sealed class _Entry {
  const _Entry();
  Key get key;
}

class _HeaderEntry extends _Entry {
  const _HeaderEntry(this.section);
  final BoardSection section;
  @override
  Key get key => ValueKey<String>('header-${section.name}');
}

class _EmptyEntry extends _Entry {
  const _EmptyEntry(this.section);
  final BoardSection section;
  @override
  Key get key => ValueKey<String>('empty-${section.name}');
}

/// An Event_Task: a calendar event to do today. It sits above the Quests of
/// the Today section and cannot be dragged.
class _EventEntry extends _Entry {
  const _EventEntry(this.occurrence);
  final EventOccurrence occurrence;
  @override
  Key get key => ValueKey<String>(
    'event-${occurrence.event.id}-${occurrence.start.year}-${occurrence.start.month}-${occurrence.start.day}',
  );
}

class _QuestEntry extends _Entry {
  const _QuestEntry(this.quest);
  final Quest quest;
  @override
  Key get key => ValueKey<int>(quest.id);
}

/// The Quest ids of both sections as the user arranged them.
class _Arrangement {
  const _Arrangement({required this.today, required this.todo});
  final List<int> today;
  final List<int> todo;
}

/// The Board: a Today section and a Todo section of open Quests in manual
/// order, followed by the Quests done on the current Board_Day.
///
/// Both sections live in one reorderable list, the section headers being
/// entries that cannot be dragged. A long press lifts a Quest; dropping it
/// before the Todo header puts it in Today, after it in Todo. Done rows are
/// neither draggable nor drop targets.
///
/// A drop shows the new arrangement at once; it is kept until the stream
/// confirms it, and dropped again when the service fails.
class QuestList extends ConsumerStatefulWidget {
  const QuestList({
    super.key,
    required this.open,
    required this.done,
    required this.today,
    this.missionNames = const <int, String>{},
    this.eventTasks = const <EventOccurrence>[],
  });

  /// Every open Quest on the Board, in the manual order, both sections.
  final List<Quest> open;
  final List<Quest> done;

  /// Calendar date of the current Board_Day, for the completion labels.
  final DateTime today;

  /// Names of the Missions, to label a Quest that belongs to one.
  final Map<int, String> missionNames;

  /// The Event_Tasks of the current Board_Day, all-day first, then by time.
  final List<EventOccurrence> eventTasks;

  @override
  ConsumerState<QuestList> createState() => _QuestListState();
}

class _QuestListState extends ConsumerState<QuestList> {
  /// The arrangement of a drop the stream has not confirmed yet.
  _Arrangement? _pending;

  /// Identifies the latest reorder call; older failures must not undo it.
  int _reorderToken = 0;

  /// Quests with a toggle call in flight, so a double tap cannot complete twice.
  final Set<int> _toggling = <int>{};

  List<int> _ids(Iterable<Quest> items) => <int>[
    for (final Quest quest in items) quest.id,
  ];

  Iterable<Quest> _actual(BoardSection section) =>
      widget.open.where((Quest q) => q.board == section);

  /// The open Quests as displayed: the unconfirmed arrangement wins over the
  /// stream; Quests it does not mention (new ones) go to their own section.
  ({List<Quest> today, List<Quest> todo}) get _shown {
    final _Arrangement? pending = _pending;
    if (pending == null) {
      return (
        today: _actual(BoardSection.today).toList(),
        todo: _actual(BoardSection.todo).toList(),
      );
    }
    final Map<int, Quest> byId = <int, Quest>{
      for (final Quest quest in widget.open) quest.id: quest,
    };
    final List<Quest> today = <Quest>[
      for (final int id in pending.today)
        if (byId.remove(id) case final Quest quest) quest,
    ];
    final List<Quest> todo = <Quest>[
      for (final int id in pending.todo)
        if (byId.remove(id) case final Quest quest) quest,
    ];
    for (final Quest quest in byId.values) {
      (quest.board == BoardSection.today ? today : todo).add(quest);
    }
    return (today: today, todo: todo);
  }

  bool get _pendingConfirmed {
    final _Arrangement? pending = _pending;
    if (pending == null) return false;
    final Set<int> mentioned = <int>{...pending.today, ...pending.todo};
    final Set<int> present = _ids(widget.open).toSet();
    bool matches(List<int> expected, BoardSection section) => listEquals(
      <int>[
        for (final int id in expected)
          if (present.contains(id)) id,
      ],
      <int>[
        for (final int id in _ids(_actual(section)))
          if (mentioned.contains(id)) id,
      ],
    );
    return matches(pending.today, BoardSection.today) &&
        matches(pending.todo, BoardSection.todo);
  }

  @override
  void didUpdateWidget(QuestList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pendingConfirmed) _pending = null;
  }

  List<_Entry> _entries(List<Quest> today, List<Quest> todo) => <_Entry>[
    const _HeaderEntry(BoardSection.today),
    for (final EventOccurrence task in widget.eventTasks) _EventEntry(task),
    if (today.isEmpty && widget.eventTasks.isEmpty) const _EmptyEntry(BoardSection.today),
    for (final Quest quest in today) _QuestEntry(quest),
    const _HeaderEntry(BoardSection.todo),
    if (todo.isEmpty) const _EmptyEntry(BoardSection.todo),
    for (final Quest quest in todo) _QuestEntry(quest),
  ];

  /// [newIndex] is the index after the dragged row is removed
  /// (`onReorderItem`).
  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final shown = _shown;
    final List<_Entry> entries = _entries(shown.today, shown.todo);
    final _QuestEntry moved = entries[oldIndex] as _QuestEntry;
    final BoardSection before = shown.today.any((Quest q) => q.id == moved.quest.id)
        ? BoardSection.today
        : BoardSection.todo;
    entries
      ..removeAt(oldIndex)
      ..insert(newIndex, moved);

    // Whatever lies before the Todo header (also above the Today one) is Today.
    final List<int> today = <int>[];
    final List<int> todo = <int>[];
    BoardSection current = BoardSection.today;
    for (final _Entry entry in entries) {
      switch (entry) {
        case _HeaderEntry(:final BoardSection section):
          current = section;
        case _QuestEntry(:final Quest quest):
          (current == BoardSection.today ? today : todo).add(quest.id);
        case _EmptyEntry() || _EventEntry():
          break;
      }
    }
    final BoardSection after = today.contains(moved.quest.id)
        ? BoardSection.today
        : BoardSection.todo;
    if (before == after &&
        listEquals(today, _ids(shown.today)) &&
        listEquals(todo, _ids(shown.todo))) {
      return;
    }

    setState(() => _pending = _Arrangement(today: today, todo: todo));
    final int token = ++_reorderToken;
    final service = ref.read(questServiceProvider);
    try {
      if (before == after) {
        await service.reorder(after == BoardSection.today ? today : todo);
      } else {
        await service.moveOnBoard(
          moved.quest.id,
          after,
          after == BoardSection.today ? today : todo,
        );
      }
    } catch (error) {
      if (!mounted || token != _reorderToken) return;
      setState(() => _pending = null);
      showDomainError(context, error);
      return;
    }
    if (mounted && token == _reorderToken && _pendingConfirmed) {
      setState(() => _pending = null);
    }
  }

  Future<void> _toggle(Quest quest) async {
    if (!_toggling.add(quest.id)) return;
    try {
      await toggleQuest(context, ref, quest);
    } finally {
      _toggling.remove(quest.id);
    }
  }

  Future<void> _edit(Quest quest) => showQuestSheet(context, editing: quest);

  Future<void> _delete(Quest quest) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool confirmed = await confirmDestructive(
      context,
      title: l.quest_deleteTitle,
      body: quest.isDone
          ? l.quest_deleteDoneBody(quest.name)
          : l.quest_deleteBody(quest.name),
      confirmLabel: l.common_delete,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(questServiceProvider).delete(quest.id);
    } catch (error) {
      if (mounted) showDomainError(context, error);
    }
  }

  Widget _row(Quest quest, AppLocalizations l) {
    final DateTime? completedAt = quest.completedAt;
    return QuestRow(
      quest: quest,
      deadline: ref.watch(questDeadlinesProvider).value?[quest.id],
      today: widget.today,
      completedLabel: completedAt == null
          ? null
          : questCompletedLabel(l, completedAt, widget.today),
      missionName: switch (quest.missionId) {
        final int id => widget.missionNames[id],
        null => null,
      },
      onToggle: () => _toggle(quest),
      onEdit: () => _edit(quest),
      onDelete: () => _delete(quest),
    );
  }

  Widget _liftProxy(Widget child, int index, Animation<double> animation) {
    final bool reduced = MediaQuery.disableAnimationsOf(context);
    final p = context.palette;
    // A dark card has no resting shadow, so the lifted one gets its own.
    final Widget lifted = p.isLight
        ? child
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.card),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: p.scrim,
                  blurRadius: 24,
                  offset: const Offset(0, Space.s12),
                ),
              ],
            ),
            child: child,
          );
    return Material(
      type: MaterialType.transparency,
      child: reduced
          ? lifted
          : ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.02).animate(animation),
              child: lifted,
            ),
    );
  }

  Widget _entry(_Entry entry, int index, AppLocalizations l) {
    final p = context.palette;
    final ({List<Quest> today, List<Quest> todo}) shown = _shown;
    switch (entry) {
      case _HeaderEntry(:final BoardSection section):
        final List<Quest> quests = section == BoardSection.today
            ? shown.today
            : shown.todo;
        int xp = quests.fold<int>(
          0,
          (int sum, Quest q) => sum + q.difficulty.xp,
        );
        if (section == BoardSection.today) {
          xp += widget.eventTasks
              .where((EventOccurrence o) => !o.isCompleted)
              .fold<int>(0, (int sum, EventOccurrence o) => sum + eventTaskXp(o));
        }
        return KeyedSubtree(
          key: entry.key,
          child: BoardSectionHeader(
            label: section == BoardSection.today
                ? l.board_todaySection
                : l.board_todoSection,
            figure: l.common_plusXp(xp),
            figureColor: p.brass,
          ),
        );
      case _EmptyEntry(:final BoardSection section):
        return Padding(
          key: entry.key,
          padding: const EdgeInsets.fromLTRB(
            Space.s20,
            0,
            Space.s20,
            Space.s10,
          ),
          child: Text(
            section == BoardSection.today
                ? l.board_todayEmpty
                : l.board_todoEmpty,
            style: context.bodyText.bodySmall!.copyWith(color: p.textFaint),
          ),
        );
      case _EventEntry(:final EventOccurrence occurrence):
        return Padding(
          key: entry.key,
          padding: const EdgeInsets.fromLTRB(Space.s20, 0, Space.s20, Space.s10),
          child: EventTaskCard(
            occurrence: occurrence,
            onToggle: () => toggleEventTask(context, ref, occurrence),
            onTap: () => showEventDetail(context, occurrence.event.id, occurrence.start),
          ),
        );
      case _QuestEntry(:final Quest quest):
        return ReorderableDelayedDragStartListener(
          key: entry.key,
          index: index,
          child: Semantics(hint: l.a11y_dragHint, child: _row(quest, l)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final p = context.palette;
    final shown = _shown;
    final List<_Entry> entries = _entries(shown.today, shown.todo);
    final List<Quest> done = widget.done;
    final int doneXp = done.fold<int>(
      0,
      (int sum, Quest i) => sum + (i.awardedXp ?? 0),
    );

    return SlidableAutoCloseBehavior(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverReorderableList(
            itemCount: entries.length,
            proxyDecorator: _liftProxy,
            onReorderStart: (_) => Haptics.light(),
            onReorderItem: _onReorder,
            findChildIndexCallback: (Key key) {
              final int index = entries.indexWhere((_Entry e) => e.key == key);
              return index < 0 ? null : index;
            },
            itemBuilder: (BuildContext context, int index) =>
                _entry(entries[index], index, l),
          ),
          if (shown.today.isNotEmpty || shown.todo.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.s20,
                  vertical: Space.s4,
                ),
                child: Text(
                  l.board_swipeHint,
                  textAlign: TextAlign.center,
                  style: context.bodyText.bodySmall!.copyWith(
                    color: p.textFaint,
                  ),
                ),
              ),
            ),
          if (done.isNotEmpty) ...<Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: Space.s8),
                child: BoardSectionHeader(
                  label: l.board_doneSection,
                  figure: l.board_doneSummary(done.length, doneXp),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: done.length,
              itemBuilder: (BuildContext context, int index) {
                final Quest quest = done[index];
                return KeyedSubtree(
                  key: ValueKey<int>(quest.id),
                  child: _row(quest, l),
                );
              },
            ),
          ],
          // Room so the last card can scroll clear of the add button.
          const SliverToBoxAdapter(
            child: SizedBox(height: Space.s64 + Space.s32),
          ),
        ],
      ),
    );
  }
}
