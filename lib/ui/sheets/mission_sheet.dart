import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors.dart';
import '../../core/xp_rules.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/providers.dart';
import '../forms/error_text.dart';
import '../forms/validators.dart';
import '../theme/questlog_theme.dart';
import '../theme/tokens.dart';
import '../widgets/cards/difficulty_pips.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/common/questlog_segmented.dart';
import '../widgets/sheet/questlog_sheet.dart';

/// Opens the Mission_Sheet: create mode (name, bonus and the first quest rows)
/// or, when [editing] is given, edit mode (name and bonus only).
Future<void> showMissionSheet(BuildContext context, {MissionSummary? editing}) {
  return showQuestlogSheet<void>(
    context,
    builder: (BuildContext context) => MissionSheet(editing: editing),
  );
}

/// Form of the Mission_Sheet (requirements 9.1-9.9). Use [showMissionSheet] to
/// open it.
class MissionSheet extends ConsumerStatefulWidget {
  const MissionSheet({super.key, this.editing});

  /// The Mission being edited, or null to create a new one.
  final MissionSummary? editing;

  @override
  ConsumerState<MissionSheet> createState() => _MissionSheetState();
}

/// One quest row of the create form. Controllers outlive the row's removal
/// animation, so they are disposed together with the sheet.
class _QuestRow {
  _QuestRow(this.id) : controller = TextEditingController();

  final int id;
  final TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  Difficulty difficulty = Difficulty.normal;
  FieldError? error;

  bool get isEmpty => controller.text.trim().isEmpty;
}

class _MissionSheetState extends ConsumerState<MissionSheet> {
  static const MissionBonus _defaultBonus = MissionBonus.medium;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _nameController = TextEditingController();
  final List<_QuestRow> _rows = <_QuestRow>[];
  final List<_QuestRow> _allRows = <_QuestRow>[];
  late MissionBonus _bonus;
  FieldError? _nameError;
  String? _submitError;
  int _nextRowId = 0;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final MissionSummary? editing = widget.editing;
    if (editing != null) {
      _nameController.text = editing.name;
      _bonus = editing.bonus;
    } else {
      _bonus = _defaultBonus;
      _rows.add(_newRow());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final _QuestRow row in _allRows) {
      row.controller.dispose();
      row.focusNode.dispose();
    }
    super.dispose();
  }

  _QuestRow _newRow() {
    final _QuestRow row = _QuestRow(_nextRowId++);
    _allRows.add(row);
    return row;
  }

  /// True when the sheet holds something that dismissal would lose.
  bool get _isDirty {
    final MissionSummary? editing = widget.editing;
    if (editing != null) {
      return _nameController.text.trim() != editing.name ||
          _bonus != editing.bonus;
    }
    return _nameController.text.trim().isNotEmpty ||
        _bonus != _defaultBonus ||
        _rows.any((_QuestRow row) => !row.isEmpty);
  }

  Duration _duration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context)
      ? Motion.reducedFade
      : Motion.panel;

  void _addRow() {
    final _QuestRow row = _newRow();
    setState(() {
      _rows.add(row);
      _submitError = null;
    });
    _listKey.currentState?.insertItem(
      _rows.length - 1,
      duration: _duration(context),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && row.focusNode.canRequestFocus) {
        row.focusNode.requestFocus();
      }
    });
  }

  void _removeRow(_QuestRow row) {
    final int index = _rows.indexOf(row);
    if (index < 0) return;
    setState(() => _rows.removeAt(index));
    _listKey.currentState?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) => _Transition(
        animation: animation,
        reduced: MediaQuery.disableAnimationsOf(context),
        child: IgnorePointer(child: _rowWidget(context, row)),
      ),
      duration: _duration(context),
    );
  }

  Future<void> _submit() async {
    final FieldError? nameError = validateName(_nameController.text);
    bool rowsValid = true;
    final List<_QuestRow> filled = <_QuestRow>[];
    if (!_isEdit) {
      for (final _QuestRow row in _rows) {
        row.error = validateQuestRowName(row.controller.text);
        if (row.error != null) rowsValid = false;
        if (!row.isEmpty) filled.add(row);
      }
    }
    setState(() {
      _nameError = nameError;
      _submitError = null;
    });
    if (nameError != null || !rowsValid) return;

    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      final service = ref.read(missionServiceProvider);
      final MissionSummary? editing = widget.editing;
      if (editing != null) {
        await service.update(editing.id, _nameController.text, _bonus);
      } else {
        await service.create(
          MissionDraft(
            name: _nameController.text,
            bonus: _bonus,
            quests: <QuestDraft>[
              for (final _QuestRow row in filled)
                QuestDraft(
                  name: row.controller.text,
                  difficulty: row.difficulty,
                ),
            ],
          ),
        );
      }
    } on DomainError catch (error) {
      if (mounted) {
        setState(() => _submitError = domainErrorText(l10n, error));
      }
      return;
    }
    if (mounted) QuestlogSheet.close<void>(context);
  }

  String _bonusLabel(AppLocalizations l10n, MissionBonus bonus) {
    return switch (bonus) {
      MissionBonus.small => l10n.mission_bonusSmall,
      MissionBonus.medium => l10n.mission_bonusMedium,
      MissionBonus.large => l10n.mission_bonusLarge,
    };
  }

  Widget _rowWidget(BuildContext context, _QuestRow row) {
    return _QuestRowTile(
      key: ValueKey<int>(row.id),
      row: row,
      onChanged: () => setState(() {
        row.error = null;
        _submitError = null;
      }),
      onDifficultyChanged: (Difficulty difficulty) =>
          setState(() => row.difficulty = difficulty),
      onRemove: () => _removeRow(row),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QuestlogPalette palette = context.palette;
    final TextTheme body = context.bodyText;
    final MissionSummary? editing = widget.editing;
    final bool completed = editing?.status == MissionStatus.completed;
    final int filledCount = _rows.where((_QuestRow r) => !r.isEmpty).length;

    return QuestlogSheet(
      title: _isEdit
          ? l10n.mission_sheetEditTitle
          : l10n.mission_sheetCreateTitle,
      primaryLabel: _isEdit ? l10n.common_save : l10n.mission_createAction,
      primaryIcon: _isEdit ? null : IconAsset.missions,
      isDirty: _isDirty,
      onPrimary: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _FieldLabel(l10n.mission_nameLabel),
          _TextBox(
            fieldKey: const ValueKey<String>('mission-name-field'),
            controller: _nameController,
            hint: l10n.mission_namePlaceholder,
            semanticLabel: l10n.mission_nameLabel,
            error: _nameError == null
                ? null
                : fieldErrorText(l10n, _nameError!),
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {
              _nameError = null;
              _submitError = null;
            }),
          ),
          const SizedBox(height: Space.s20),
          _FieldLabel(l10n.mission_bonusLabel),
          QuestlogSegmented<MissionBonus>(
            options: <SegmentedOption<MissionBonus>>[
              for (final MissionBonus bonus in MissionBonus.values)
                SegmentedOption<MissionBonus>(
                  value: bonus,
                  label: _bonusLabel(l10n, bonus),
                  caption: l10n.common_plusXp(bonus.xp),
                ),
            ],
            selected: _bonus,
            onChanged: (MissionBonus value) => setState(() => _bonus = value),
          ),
          const SizedBox(height: Space.s8),
          Text(
            completed ? l10n.mission_editBonusNote : l10n.mission_bonusHelp,
            style: body.bodySmall!.copyWith(color: palette.textFaint),
          ),
          const SizedBox(height: Space.s20),
          if (_isEdit)
            Text(
              l10n.mission_editQuestsNote,
              style: body.bodySmall!.copyWith(color: palette.textFaint),
            )
          else ...<Widget>[
            _FieldLabel(l10n.mission_questsLabel(filledCount)),
            AnimatedList(
              key: _listKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              initialItemCount: _rows.length,
              itemBuilder:
                  (
                    BuildContext context,
                    int index,
                    Animation<double> animation,
                  ) => _Transition(
                    animation: animation,
                    reduced: MediaQuery.disableAnimationsOf(context),
                    child: _rowWidget(context, _rows[index]),
                  ),
            ),
            _AddRow(label: l10n.mission_addQuest, onTap: _addRow),
          ],
          if (_submitError != null) ...<Widget>[
            const SizedBox(height: Space.s12),
            Semantics(
              liveRegion: true,
              child: Text(
                _submitError!,
                style: body.bodyMedium!.copyWith(color: palette.destructive),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Size-and-fade transition of a quest row entering or leaving the list; a
/// plain fade under reduced motion.
class _Transition extends StatelessWidget {
  const _Transition({
    required this.animation,
    required this.reduced,
    required this.child,
  });

  final Animation<double> animation;
  final bool reduced;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Widget faded = FadeTransition(opacity: animation, child: child);
    if (reduced) return faded;
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Motion.curve),
      child: faded,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s8),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: context.bodyText.labelSmall!.copyWith(
            color: context.palette.textDim,
          ),
        ),
      ),
    );
  }
}

/// Filled text field with the brass active state and an error line below.
class _TextBox extends StatelessWidget {
  const _TextBox({
    required this.controller,
    required this.hint,
    required this.semanticLabel,
    required this.onChanged,
    this.fieldKey,
    this.focusNode,
    this.error,
    this.textCapitalization = TextCapitalization.none,
    this.trailing,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final String semanticLabel;
  final String? error;
  final TextCapitalization textCapitalization;
  final ValueChanged<String> onChanged;

  /// Placed inside the box, after the text.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    final TextTheme body = context.bodyText;
    final BorderRadius radius = BorderRadius.circular(Radii.control);
    final bool hasError = error != null;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: width == 0
          ? BorderSide.none
          : BorderSide(color: color, width: width),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          label: semanticLabel,
          textField: true,
          child: TextField(
            key: fieldKey,
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            textCapitalization: textCapitalization,
            textInputAction: TextInputAction.next,
            style: body.bodyLarge!.copyWith(fontSize: 16),
            cursorColor: palette.brass,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: body.bodyLarge!.copyWith(
                fontSize: 16,
                color: palette.textFaint,
              ),
              filled: true,
              fillColor: palette.field,
              focusColor: palette.fieldActive,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Space.s16,
                vertical: Space.s12,
              ),
              suffixIcon: trailing,
              enabledBorder: hasError
                  ? border(palette.destructive, Metrics.hairline)
                  : border(palette.brass, 0),
              focusedBorder: border(
                hasError ? palette.destructive : palette.brass,
                Metrics.hairline,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: Space.s6),
            child: Semantics(
              liveRegion: true,
              child: Text(
                error!,
                style: body.bodySmall!.copyWith(color: palette.destructive),
              ),
            ),
          ),
      ],
    );
  }
}

/// One quest row: name field, effort chip (tap to cycle) and remove button.
class _QuestRowTile extends StatelessWidget {
  const _QuestRowTile({
    super.key,
    required this.row,
    required this.onChanged,
    required this.onDifficultyChanged,
    required this.onRemove,
  });

  final _QuestRow row;
  final VoidCallback onChanged;
  final ValueChanged<Difficulty> onDifficultyChanged;
  final VoidCallback onRemove;

  Difficulty get _nextDifficulty {
    final List<Difficulty> all = Difficulty.values;
    return all[(all.indexOf(row.difficulty) + 1) % all.length];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QuestlogPalette palette = context.palette;
    final FieldError? error = row.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.s8),
      child: _TextBox(
        controller: row.controller,
        focusNode: row.focusNode,
        hint: l10n.mission_questNamePlaceholder,
        semanticLabel: l10n.mission_questNamePlaceholder,
        error: error == null ? null : fieldErrorText(l10n, error),
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) => onChanged(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              button: true,
              label:
                  '${l10n.a11y_effort(pipCount(row.difficulty), DifficultyPips.total)}, '
                  '${l10n.common_plusXp(row.difficulty.xp)}',
              excludeSemantics: true,
              onTap: () => onDifficultyChanged(_nextDifficulty),
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.control),
                onTap: () => onDifficultyChanged(_nextDifficulty),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: Metrics.touchTarget,
                    minHeight: Metrics.touchTarget,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s8),
                      child: Text(
                        '+${row.difficulty.xp}',
                        style: context.displayText.titleMedium!.copyWith(
                          color: palette.brass,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: l10n.a11y_removeRow,
              excludeSemantics: true,
              onTap: onRemove,
              child: InkResponse(
                radius: Metrics.touchTarget / 2,
                onTap: onRemove,
                child: SizedBox(
                  width: Metrics.touchTarget,
                  height: Metrics.touchTarget,
                  child: Center(
                    child: AppIcon(
                      IconAsset.close,
                      size: Metrics.iconSmall,
                      color: palette.textFaint,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dashed "Přidat quest" row below the quest rows.
class _AddRow extends StatelessWidget {
  const _AddRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.control),
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: palette.textFaint,
            radius: Radii.control,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: Metrics.touchTarget + Space.s4,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s16),
              child: Row(
                children: <Widget>[
                  AppIcon(
                    IconAsset.plus,
                    size: Metrics.iconSmall,
                    color: palette.textFaint,
                  ),
                  const SizedBox(width: Space.s12),
                  Expanded(
                    child: Text(
                      label,
                      style: context.bodyText.bodyLarge!.copyWith(
                        color: palette.textFaint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  static const double _dash = 6;
  static const double _gap = 4;

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = Metrics.hairline * 1.5;
    final Path outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ).deflate(paint.strokeWidth / 2),
      );
    for (final PathMetric metric in outline.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
