import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/errors.dart';
import '../../core/xp_rules.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/providers.dart';
import '../../services/quest_service.dart';
import '../forms/error_text.dart';
import '../forms/validators.dart';
import '../state/ui_providers.dart';
import '../theme/questlog_theme.dart';
import '../theme/tokens.dart';
import '../widgets/common/effort_picker.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/sheet/confirm_destructive.dart';
import '../widgets/sheet/questlog_sheet.dart';

/// Opens the Quest_Sheet: create mode by default, edit mode when [editing] is
/// given. [presetMissionId] preselects a Mission in create mode (the Mission
/// detail screen passes the Mission it shows).
///
/// Completes when the sheet is closed, whether it saved, deleted or was
/// dismissed.
Future<void> showQuestSheet(
  BuildContext context, {
  Quest? editing,
  int? presetMissionId,
}) async {
  await showQuestlogSheet<Quest>(
    context,
    builder: (BuildContext context) =>
        QuestSheet(editing: editing, presetMissionId: presetMissionId),
  );
}

/// Form for posting a Quest or changing one (requirement 5).
///
/// Field values live in local state; validation uses `forms/validators.dart`
/// and runs when the primary button is pressed, then live while an error is
/// shown. Business rules stay in `QuestService`.
class QuestSheet extends ConsumerStatefulWidget {
  const QuestSheet({super.key, this.editing, this.presetMissionId});

  /// The Quest to change, or null to post a new one.
  final Quest? editing;

  /// Mission selected when the sheet opens in create mode.
  final int? presetMissionId;

  @override
  ConsumerState<QuestSheet> createState() => _QuestSheetState();
}

class _QuestSheetState extends ConsumerState<QuestSheet> {
  late final TextEditingController _name;
  late final TextEditingController _note;
  late Difficulty _difficulty;
  late int? _missionId;
  late BoardSection? _board;
  late DateTime? _deadline;
  late final DateTime? _initialDeadline;

  FieldError? _nameError;
  FieldError? _noteError;

  /// Set when the service reports that the chosen Mission is no longer open.
  bool _missionNotOpen = false;

  /// Any other service failure, already mapped to text by [domainErrorText].
  DomainError? _serviceError;

  bool _deleting = false;

  Quest? get _editing => widget.editing;
  bool get _isEditing => _editing != null;
  bool get _isDone => _editing?.isDone ?? false;

  @override
  void initState() {
    super.initState();
    final Quest? quest = _editing;
    _name = TextEditingController(text: quest?.name ?? '');
    _note = TextEditingController(text: quest?.note ?? '');
    _difficulty = quest?.difficulty ?? Difficulty.normal;
    _missionId = quest != null ? quest.missionId : widget.presetMissionId;
    _initialDeadline = quest == null ? null : ref.read(questDeadlinesProvider).value?[quest.id];
    _deadline = _initialDeadline;
    // A new Quest of a Mission starts off the Board, any other one in Todo.
    _board = quest != null
        ? quest.board
        : (_missionId == null ? BoardSection.todo : null);
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  /// True when the user changed anything compared with what the sheet opened
  /// with, so dismissal has to ask first.
  bool get _isDirty {
    final Quest? quest = _editing;
    final String initialName = quest?.name ?? '';
    final String initialNote = quest?.note ?? '';
    final Difficulty initialDifficulty = quest?.difficulty ?? Difficulty.normal;
    final int? initialMission = quest != null
        ? quest.missionId
        : widget.presetMissionId;
    return _name.text != initialName ||
        _note.text != initialNote ||
        _difficulty != initialDifficulty ||
        _missionId != initialMission ||
        _board != (quest != null ? quest.board : _initialNewBoard) ||
        _deadline != _initialDeadline;
  }

  BoardSection? get _initialNewBoard =>
      widget.presetMissionId == null ? BoardSection.todo : null;

  void _onNameChanged(String value) {
    setState(() {
      if (_nameError != null) _nameError = validateName(value);
      _serviceError = null;
    });
  }

  void _onNoteChanged(String value) {
    setState(() {
      if (_noteError != null) _noteError = validateNote(value);
      _serviceError = null;
    });
  }

  /// Opens the date picker for the Deadline; a cancelled picker changes nothing.
  Future<void> _pickDeadline() async {
    final DateTime now = ref.read(clockProvider).now();
    final DateTime initial = _deadline ?? DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 1),
      lastDate: DateTime(initial.year + 10),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _deadline = DateTime(picked.year, picked.month, picked.day);
      _serviceError = null;
    });
  }

  void _selectMission(int? id) {
    setState(() {
      // Joining a Mission takes a Quest off the Board; leaving it puts the
      // Quest back (a Quest without a Mission is always on the Board).
      if (id != null && _missionId == null) _board = null;
      if (id == null) _board ??= BoardSection.todo;
      _missionId = id;
      _missionNotOpen = false;
      _serviceError = null;
    });
  }

  Future<void> _save() async {
    final FieldError? nameError = validateName(_name.text);
    final FieldError? noteError = validateNote(_note.text);
    setState(() {
      _nameError = nameError;
      _noteError = noteError;
      _missionNotOpen = false;
      _serviceError = null;
    });
    if (nameError != null || noteError != null) return;

    final QuestService service = ref.read(questServiceProvider);
    final QuestDraft draft = QuestDraft(
      name: _name.text,
      note: _note.text.isEmpty ? null : _note.text,
      difficulty: _difficulty,
      missionId: _missionId,
      board: _board,
      deadline: _deadline,
    );
    try {
      final Quest saved = _isEditing
          ? await service.update(_editing!.id, draft)
          : await service.create(draft);
      if (!mounted) return;
      _announceMissionMove(saved);
      QuestlogSheet.close<Quest>(context, saved);
    } on InvalidStateError {
      if (!mounted) return;
      // Only the Mission assignment can be rejected as invalid state here.
      setState(() => _missionNotOpen = true);
    } on DomainError catch (error) {
      if (mounted) setState(() => _serviceError = error);
    }
  }

  /// A Quest assigned to a Mission from outside that Mission's detail screen
  /// leaves the Board; say where it went.
  void _announceMissionMove(Quest saved) {
    final int? missionId = saved.missionId;
    if (missionId == null ||
        saved.board != null ||
        missionId == _editing?.missionId ||
        widget.presetMissionId != null) {
      return;
    }
    final List<MissionSummary> missions =
        ref.read(openMissionsProvider).value ?? const <MissionSummary>[];
    for (final MissionSummary mission in missions) {
      if (mission.id != missionId) continue;
      ref
          .read(snackbarProvider.notifier)
          .show(
            SnackMessage(
              AppLocalizations.of(context).quest_addedToMission(mission.name),
            ),
          );
      return;
    }
  }

  Future<void> _delete() async {
    final Quest quest = _editing!;
    if (_deleting) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _deleting = true);
    try {
      final bool confirmed = await confirmDestructive(
        context,
        title: l10n.quest_deleteTitle,
        body: quest.isDone
            ? l10n.quest_deleteDoneBody(quest.name)
            : l10n.quest_deleteBody(quest.name),
        confirmLabel: l10n.common_delete,
      );
      if (!confirmed || !mounted) return;
      await ref.read(questServiceProvider).delete(quest.id);
      if (mounted) QuestlogSheet.close<Quest>(context);
    } on DomainError catch (error) {
      if (mounted) setState(() => _serviceError = error);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QuestlogPalette palette = context.palette;
    final List<MissionSummary> openMissions =
        ref.watch(openMissionsProvider).value ?? const <MissionSummary>[];

    return QuestlogSheet(
      title: _isEditing
          ? l10n.quest_sheetEditTitle
          : l10n.quest_sheetCreateTitle,
      primaryLabel: _isEditing ? l10n.common_save : l10n.quest_createAction,
      primaryIcon: _isEditing ? null : IconAsset.arrowUp,
      isDirty: _isDirty,
      onPrimary: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _FieldGroup(
            label: l10n.quest_nameLabel,
            error: _nameError == null
                ? null
                : fieldErrorText(l10n, _nameError!),
            child: _TextInput(
              controller: _name,
              placeholder: l10n.quest_namePlaceholder,
              label: l10n.quest_nameLabel,
              autofocus: !_isEditing,
              hasError: _nameError != null,
              onChanged: _onNameChanged,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(height: Space.s20),
          _FieldGroup(
            label: l10n.quest_effortLabel,
            help: l10n.quest_effortHint,
            child: EffortPicker(
              enabled: !_isDone,
              selected: _difficulty,
              onChanged: (Difficulty value) =>
                  setState(() => _difficulty = value),
            ),
          ),
          const SizedBox(height: Space.s20),
          _FieldGroup(
            label: l10n.quest_missionLabel,
            error: _missionNotOpen
                ? fieldErrorText(l10n, FieldError.missionNotOpen)
                : null,
            help: _isDone ? l10n.quest_doneLockedHint : null,
            child: _MissionPicker(
              enabled: !_isDone,
              selectedId: _missionId,
              missions: openMissions,
              noneLabel: l10n.quest_missionNone,
              onSelected: _selectMission,
              hasError: _missionNotOpen,
            ),
          ),
          const SizedBox(height: Space.s20),
          _FieldGroup(
            label: l10n.quest_boardLabel,
            child: _BoardPicker(
              enabled: !_isDone,
              selected: _board,
              allowOff: _missionId != null,
              onSelected: (BoardSection? value) =>
                  setState(() => _board = value),
            ),
          ),
          const SizedBox(height: Space.s20),
          _FieldGroup(
            label: l10n.quest_deadlineLabel,
            help: _deadline != null ? l10n.quest_deadlineLinkedHint : null,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) => Wrap(
                spacing: Space.s8,
                runSpacing: Space.s8,
                children: <Widget>[
                  _PickChip(
                    label: l10n.quest_deadlineNone,
                    selected: _deadline == null,
                    enabled: !_isDone,
                    maxWidth: constraints.maxWidth,
                    onTap: () => setState(() => _deadline = null),
                  ),
                  _PickChip(
                    key: const ValueKey<String>('quest-deadline-pick'),
                    label: _deadline == null
                        ? l10n.quest_deadlineLabel
                        : DateFormat.yMd(l10n.localeName).format(_deadline!),
                    selected: _deadline != null,
                    enabled: !_isDone,
                    maxWidth: constraints.maxWidth,
                    onTap: _pickDeadline,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.s20),
          _FieldGroup(
            label: l10n.quest_noteLabel,
            error: _noteError == null
                ? null
                : fieldErrorText(l10n, _noteError!),
            child: _TextInput(
              controller: _note,
              placeholder: l10n.quest_notePlaceholder,
              label: l10n.quest_noteLabel,
              multiline: true,
              hasError: _noteError != null,
              onChanged: _onNoteChanged,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          if (_serviceError != null) ...<Widget>[
            const SizedBox(height: Space.s16),
            _ErrorText(domainErrorText(l10n, _serviceError!)),
          ],
          if (_isEditing) ...<Widget>[
            const SizedBox(height: Space.s16),
            Align(
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    Metrics.touchTarget,
                    Metrics.touchTarget,
                  ),
                  foregroundColor: palette.destructive,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.control),
                  ),
                ),
                onPressed: _deleting ? null : _delete,
                child: Text(
                  l10n.common_delete,
                  style: context.bodyText.titleMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small upper-case label above a control, with an optional error or help
/// line below it.
class _FieldGroup extends StatelessWidget {
  const _FieldGroup({
    required this.label,
    required this.child,
    this.error,
    this.help,
  });

  final String label;
  final Widget child;
  final String? error;
  final String? help;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ExcludeSemantics(
          child: Text(
            label.toUpperCase(),
            style: context.bodyText.labelSmall!.copyWith(
              color: palette.textFaint,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: Space.s8),
        child,
        if (error != null) ...<Widget>[
          const SizedBox(height: Space.s6),
          _ErrorText(error!),
        ],
        if (help != null) ...<Widget>[
          const SizedBox(height: Space.s6),
          Text(
            help!,
            style: context.bodyText.bodySmall!.copyWith(
              color: palette.textFaint,
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: context.bodyText.bodySmall!.copyWith(
          color: context.palette.destructive,
        ),
      ),
    );
  }
}

/// Filled text field in the design's field style: brass outline and tint while
/// focused, destructive outline while invalid.
class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.placeholder,
    required this.label,
    required this.onChanged,
    required this.hasError,
    this.autofocus = false,
    this.multiline = false,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String placeholder;
  final String label;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final bool autofocus;
  final bool multiline;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    final BorderRadius radius = BorderRadius.circular(Radii.control);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: Metrics.hairline),
    );
    final OutlineInputBorder none = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    );
    return Semantics(
      label: label,
      child: _FocusFill(
        builder: (bool focused) => TextField(
          controller: controller,
          autofocus: autofocus,
          onChanged: onChanged,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          keyboardType: multiline
              ? TextInputType.multiline
              : TextInputType.text,
          minLines: multiline ? 2 : 1,
          maxLines: multiline ? 5 : 1,
          cursorColor: palette.brass,
          style: context.bodyText.bodyLarge!.copyWith(color: palette.text),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: context.bodyText.bodyLarge!.copyWith(
              color: palette.textFaint,
            ),
            filled: true,
            fillColor: focused ? palette.fieldActive : palette.field,
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Space.s16,
              vertical: Space.s12,
            ),
            border: none,
            enabledBorder: hasError ? border(palette.destructive) : none,
            focusedBorder: border(
              hasError ? palette.destructive : palette.brass,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tells its builder whether a descendant has focus, to tint the field.
class _FocusFill extends StatefulWidget {
  const _FocusFill({required this.builder});

  final Widget Function(bool focused) builder;

  @override
  State<_FocusFill> createState() => _FocusFillState();
}

class _FocusFillState extends State<_FocusFill> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (bool value) => setState(() => _focused = value),
      child: widget.builder(_focused),
    );
  }
}

/// Pill choices for where the Quest is on the Board: Today, Todo and, for a
/// Quest of a Mission, off the Board.
class _BoardPicker extends StatelessWidget {
  const _BoardPicker({
    required this.enabled,
    required this.selected,
    required this.allowOff,
    required this.onSelected,
  });

  final bool enabled;
  final BoardSection? selected;
  final bool allowOff;
  final ValueChanged<BoardSection?> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Wrap(
          spacing: Space.s8,
          runSpacing: Space.s8,
          children: <Widget>[
            _PickChip(
              label: l10n.board_todaySection,
              selected: selected == BoardSection.today,
              enabled: enabled,
              maxWidth: constraints.maxWidth,
              onTap: () => onSelected(BoardSection.today),
            ),
            _PickChip(
              label: l10n.board_todoSection,
              selected: selected == BoardSection.todo,
              enabled: enabled,
              maxWidth: constraints.maxWidth,
              onTap: () => onSelected(BoardSection.todo),
            ),
            if (allowOff)
              _PickChip(
                label: l10n.quest_boardNone,
                selected: selected == null,
                enabled: enabled,
                maxWidth: constraints.maxWidth,
                onTap: () => onSelected(null),
              ),
          ],
        );
      },
    );
  }
}

/// Wrap of pill choices: "bez mise" first, then the open Missions.
class _MissionPicker extends ConsumerWidget {
  const _MissionPicker({
    required this.enabled,
    required this.selectedId,
    required this.missions,
    required this.noneLabel,
    required this.onSelected,
    required this.hasError,
  });

  final bool enabled;
  final int? selectedId;
  final List<MissionSummary> missions;
  final String noneLabel;
  final ValueChanged<int?> onSelected;
  final bool hasError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The selected Mission may not be open any more (a done Quest of a
    // completed Mission); keep it visible so the locked picker is truthful.
    final int? orphanId =
        selectedId != null && !missions.any((m) => m.id == selectedId)
        ? selectedId
        : null;
    final String? orphanName = orphanId == null
        ? null
        : ref.watch(missionDetailProvider(orphanId)).value?.mission.name;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Wrap(
          spacing: Space.s8,
          runSpacing: Space.s8,
          children: <Widget>[
            _PickChip(
              label: noneLabel,
              selected: selectedId == null,
              enabled: enabled,
              maxWidth: constraints.maxWidth,
              onTap: () => onSelected(null),
            ),
            for (final MissionSummary mission in missions)
              _PickChip(
                label: mission.name,
                selected: mission.id == selectedId,
                enabled: enabled,
                maxWidth: constraints.maxWidth,
                onTap: () => onSelected(mission.id),
              ),
            if (orphanName != null)
              _PickChip(
                label: orphanName,
                selected: true,
                enabled: enabled,
                maxWidth: constraints.maxWidth,
                onTap: () => onSelected(orphanId),
              ),
          ],
        );
      },
    );
  }
}

class _PickChip extends StatelessWidget {
  const _PickChip({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.maxWidth,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final double maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    final BorderRadius radius = BorderRadius.circular(Radii.pill);
    final Color foreground = selected ? palette.brassText : palette.textDim;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: Metrics.touchTarget,
        maxWidth: maxWidth,
      ),
      child: Semantics(
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        enabled: enabled,
        label: label,
        excludeSemantics: true,
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Material(
            color: selected ? palette.brassSoft : palette.field,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: selected ? palette.brass : palette.boardLine,
                width: Metrics.hairline,
              ),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(borderRadius: radius),
              onTap: enabled ? onTap : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.s16,
                  vertical: Space.s8,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyText.bodyMedium!.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
