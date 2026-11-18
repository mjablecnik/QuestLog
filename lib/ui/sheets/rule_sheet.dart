import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/board_day.dart';
import '../../core/cadence.dart';
import '../../core/errors.dart';
import '../../core/xp_rules.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/providers.dart';
import '../forms/error_text.dart';
import '../forms/posting_day.dart';
import '../forms/validators.dart';
import '../theme/questlog_theme.dart';
import '../theme/tokens.dart';
import '../widgets/cards/difficulty_pips.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/common/questlog_segmented.dart';
import '../widgets/sheet/confirm_destructive.dart';
import '../widgets/sheet/questlog_sheet.dart';

/// Opens the Rule_Sheet: create mode, or edit mode (with "Smazat pravidlo")
/// when [editing] is given.
Future<void> showRuleSheet(BuildContext context, {RuleSummary? editing}) {
  return showQuestlogSheet<void>(
    context,
    builder: (BuildContext context) => RuleSheet(editing: editing),
  );
}

/// Localized name of a Cadence (chip label).
String ruleCadenceLabel(AppLocalizations l10n, Cadence cadence) {
  return switch (cadence) {
    Cadence.daily => l10n.rule_cadenceDaily,
    Cadence.weekly => l10n.rule_cadenceWeekly,
    Cadence.biweekly => l10n.rule_cadenceBiweekly,
    Cadence.monthly => l10n.rule_cadenceMonthly,
    Cadence.quarterly => l10n.rule_cadenceQuarterly,
    Cadence.yearly => l10n.rule_cadenceYearly,
  };
}

/// Localized weekday name; [weekday] is [DateTime.monday] to [DateTime.sunday].
String ruleWeekdayName(AppLocalizations l10n, int weekday) {
  // 2024-01-01 was a Monday.
  return DateFormat.EEEE(l10n.localeName).format(DateTime(2024, 1, weekday));
}

/// Day and month, plus the year when [withYear] is set.
String ruleDateText(
  AppLocalizations l10n,
  DateTime date, {
  bool withYear = false,
}) {
  final DateFormat format = withYear
      ? DateFormat.yMd(l10n.localeName)
      : DateFormat.Md(l10n.localeName);
  return format.format(date);
}

/// Form of the Rule_Sheet (requirements 12.5-12.12). Use [showRuleSheet] to
/// open it.
class RuleSheet extends ConsumerStatefulWidget {
  const RuleSheet({super.key, this.editing});

  /// The rule being edited, or null to create a new one.
  final RuleSummary? editing;

  @override
  ConsumerState<RuleSheet> createState() => _RuleSheetState();
}

/// One quest template row. Controllers are disposed with the sheet.
class _TemplateRow {
  _TemplateRow(this.id, {String name = '', this.difficulty = Difficulty.normal})
    : controller = TextEditingController(text: name);

  final int id;
  final TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  Difficulty difficulty;
  FieldError? error;

  bool get isEmpty => controller.text.trim().isEmpty;
}

class _RuleSheetState extends ConsumerState<RuleSheet> {
  static const Cadence _defaultCadence = Cadence.monthly;
  static const MissionBonus _defaultBonus = MissionBonus.medium;

  final TextEditingController _nameController = TextEditingController();
  final List<_TemplateRow> _rows = <_TemplateRow>[];
  final Map<Cadence, PostingDay> _remembered = <Cadence, PostingDay>{};
  late final DateTime _today;
  late Cadence _cadence;
  late PostingDay _day;
  late MissionBonus _bonus;
  late final PostingDay _initialDay;
  late final List<(String, Difficulty)> _initialTemplates;
  FieldError? _nameError;
  FieldError? _templatesError;
  String? _submitError;
  int _nextRowId = 0;

  bool get _isEdit => widget.editing != null;

  Cadence get _initialCadence => widget.editing?.cadence ?? _defaultCadence;

  MissionBonus get _initialBonus => widget.editing?.bonus ?? _defaultBonus;

  @override
  void initState() {
    super.initState();
    _today = todayOf(ref.read(clockProvider).now());
    final RuleSummary? editing = widget.editing;
    if (editing != null) {
      _nameController.text = editing.name;
      _cadence = editing.cadence;
      _day = postingDayOf(editing.cadence, editing.anchorDate);
      _bonus = editing.bonus;
      for (final RuleQuest quest in editing.quests) {
        _rows.add(
          _TemplateRow(
            _nextRowId++,
            name: quest.name,
            difficulty: quest.difficulty,
          ),
        );
      }
    } else {
      _cadence = _defaultCadence;
      _day = defaultPostingDay(_cadence, _today);
      _bonus = _defaultBonus;
    }
    if (_rows.isEmpty) _rows.add(_TemplateRow(_nextRowId++));
    _initialDay = _day;
    _remembered[_cadence] = _day;
    _initialTemplates = _snapshotTemplates();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final _TemplateRow row in _rows) {
      row.controller.dispose();
      row.focusNode.dispose();
    }
    super.dispose();
  }

  List<(String, Difficulty)> _snapshotTemplates() => <(String, Difficulty)>[
    for (final _TemplateRow row in _rows)
      if (!row.isEmpty) (row.controller.text.trim(), row.difficulty),
  ];

  bool get _isDirty {
    final RuleSummary? editing = widget.editing;
    final List<(String, Difficulty)> templates = _snapshotTemplates();
    if (_nameController.text.trim() != (editing?.name ?? '') ||
        _cadence != _initialCadence ||
        _day != _initialDay ||
        _bonus != _initialBonus ||
        templates.length != _initialTemplates.length) {
      return true;
    }
    for (int i = 0; i < templates.length; i++) {
      if (templates[i] != _initialTemplates[i]) return true;
    }
    return false;
  }

  /// Switches the Cadence and replaces the posting day with one that suits it,
  /// keeping the name and the templates (requirement 12.8).
  void _selectCadence(Cadence cadence) {
    if (cadence == _cadence) return;
    _remembered[_cadence] = _day;
    PostingDay? next = _remembered[cadence];
    if (next == null) {
      final PostingDay fallback = defaultPostingDay(cadence, _today);
      // Weekly <-> Biweekly and Quarterly <-> Yearly share their kind of day.
      next = _day.runtimeType == fallback.runtimeType ? _day : fallback;
    }
    setState(() {
      _cadence = cadence;
      _day = next!;
      _submitError = null;
    });
  }

  void _addRow() {
    final _TemplateRow row = _TemplateRow(_nextRowId++);
    setState(() {
      _rows.add(row);
      _templatesError = null;
      _submitError = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && row.focusNode.canRequestFocus) {
        row.focusNode.requestFocus();
      }
    });
  }

  void _removeRow(_TemplateRow row) {
    setState(() {
      _rows.remove(row);
      _templatesError = null;
    });
    // The controller may still be read by the leaving frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      row.controller.dispose();
      row.focusNode.dispose();
    });
  }

  Future<void> _pickPostingDay() async {
    final PostingDay current = _day;
    final PostingDay? picked = switch (current) {
      NoPostingDay() => null,
      WeekdayPostingDay() => await _pickWeekday(current),
      MonthDayPostingDay() => await _pickMonthDay(current),
      DatePostingDay() => await _pickDate(current),
    };
    if (picked != null && mounted) {
      setState(() {
        _day = picked;
        _submitError = null;
      });
    }
  }

  Future<PostingDay?> _pickWeekday(WeekdayPostingDay current) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _showChoiceDialog<PostingDay>(
      context,
      title: l10n.rule_postingDayWeekdayTitle,
      children: <Widget>[
        for (
          int weekday = DateTime.monday;
          weekday <= DateTime.sunday;
          weekday++
        )
          _ChoiceTile(
            label: ruleWeekdayName(l10n, weekday),
            selected: current.weekday == weekday,
            wide: true,
            onTap: (BuildContext context) =>
                Navigator.of(context).pop(WeekdayPostingDay(weekday)),
          ),
      ],
    );
  }

  Future<PostingDay?> _pickMonthDay(MonthDayPostingDay current) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _showChoiceDialog<PostingDay>(
      context,
      title: l10n.rule_postingDayMonthTitle,
      children: <Widget>[
        for (int day = 1; day <= MonthDayPostingDay.maxDay; day++)
          _ChoiceTile(
            label: '$day',
            selected: current.day == day,
            wide: false,
            onTap: (BuildContext context) =>
                Navigator.of(context).pop(MonthDayPostingDay(day)),
          ),
      ],
    );
  }

  Future<PostingDay?> _pickDate(DatePostingDay current) async {
    final DateTime date = current.date;
    final DateTime first = date.isBefore(_today) ? date : _today;
    final DateTime last = DateTime(
      (date.isAfter(_today) ? date : _today).year + 3,
      12,
      31,
    );
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: first,
      lastDate: last,
      helpText: AppLocalizations.of(context).rule_postingDayDateTitle,
    );
    return picked == null ? null : DatePostingDay(picked);
  }

  String _postingDayText(AppLocalizations l10n) {
    return switch (_day) {
      NoPostingDay() => '',
      WeekdayPostingDay(:final int weekday) => ruleWeekdayName(l10n, weekday),
      MonthDayPostingDay(:final int day) => l10n.rule_postingMonthDay(day),
      DatePostingDay(:final DateTime date) => ruleDateText(
        l10n,
        date,
        withYear: _cadence == Cadence.yearly || _cadence == Cadence.quarterly,
      ),
    };
  }

  Future<void> _submit() async {
    final FieldError? nameError = validateName(_nameController.text);
    bool rowsValid = true;
    for (final _TemplateRow row in _rows) {
      row.error = validateQuestRowName(row.controller.text);
      if (row.error != null) rowsValid = false;
    }
    final FieldError? templatesError = rowsValid
        ? validateRuleQuests(<String>[
            for (final _TemplateRow row in _rows) row.controller.text,
          ])
        : null;
    setState(() {
      _nameError = nameError;
      _templatesError = templatesError;
      _submitError = null;
    });
    if (nameError != null || !rowsValid || templatesError != null) return;

    final AppLocalizations l10n = AppLocalizations.of(context);
    final RuleDraft draft = RuleDraft(
      name: _nameController.text,
      cadence: _cadence,
      requestedAnchor: requestedAnchor(_cadence, _day, _today),
      bonus: _bonus,
      quests: <RuleQuestDraft>[
        for (final _TemplateRow row in _rows)
          if (!row.isEmpty)
            RuleQuestDraft(
              name: row.controller.text,
              difficulty: row.difficulty,
            ),
      ],
    );
    try {
      final service = ref.read(recurrenceServiceProvider);
      final RuleSummary? editing = widget.editing;
      if (editing != null) {
        await service.update(editing.id, draft);
      } else {
        await service.create(draft);
      }
    } on DomainError catch (error) {
      if (mounted) {
        setState(() => _submitError = domainErrorText(l10n, error));
      }
      return;
    }
    if (mounted) QuestlogSheet.close<void>(context);
  }

  Future<void> _delete() async {
    final RuleSummary? editing = widget.editing;
    if (editing == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await confirmDestructive(
      context,
      title: l10n.rule_deleteTitle,
      body: l10n.rule_deleteBody(editing.name),
      confirmLabel: l10n.rule_deleteAction,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(recurrenceServiceProvider).delete(editing.id);
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final QuestlogPalette palette = context.palette;
    final TextTheme body = context.bodyText;
    final int filledCount = _rows.where((_TemplateRow r) => !r.isEmpty).length;

    return QuestlogSheet(
      title: _isEdit ? l10n.rule_sheetEditTitle : l10n.rule_sheetTitle,
      primaryLabel: l10n.rule_saveAction,
      isDirty: _isDirty,
      onPrimary: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _FieldLabel(l10n.rule_nameLabel),
          _TextBox(
            fieldKey: const ValueKey<String>('rule-name-field'),
            controller: _nameController,
            hint: l10n.mission_namePlaceholder,
            semanticLabel: l10n.rule_nameLabel,
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
          _FieldLabel(l10n.rule_cadenceLabel),
          Wrap(
            spacing: Space.s8,
            runSpacing: Space.s8,
            children: <Widget>[
              for (final Cadence cadence in Cadence.values)
                _CadenceChip(
                  label: ruleCadenceLabel(l10n, cadence),
                  selected: cadence == _cadence,
                  onTap: () => _selectCadence(cadence),
                ),
            ],
          ),
          if (_day is! NoPostingDay) ...<Widget>[
            const SizedBox(height: Space.s12),
            _PostingDayRow(
              label: l10n.rule_postingDayLabel,
              value: _postingDayText(l10n),
              hint: l10n.a11y_pickPostingDay,
              onTap: _pickPostingDay,
            ),
          ],
          const SizedBox(height: Space.s8),
          Text(
            l10n.rule_helpNoCarryOver,
            style: body.bodySmall!.copyWith(color: palette.textFaint),
          ),
          if (_isEdit) ...<Widget>[
            const SizedBox(height: Space.s8),
            Text(
              l10n.rule_editNote,
              style: body.bodySmall!.copyWith(color: palette.textDim),
            ),
          ],
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
          const SizedBox(height: Space.s20),
          _FieldLabel(l10n.mission_questsLabel(filledCount)),
          for (final _TemplateRow row in _rows)
            _TemplateTile(
              key: ValueKey<int>(row.id),
              row: row,
              onChanged: () => setState(() {
                row.error = null;
                _templatesError = null;
                _submitError = null;
              }),
              onDifficultyChanged: (Difficulty difficulty) =>
                  setState(() => row.difficulty = difficulty),
              onRemove: () => _removeRow(row),
            ),
          if (_templatesError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.s8),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  fieldErrorText(l10n, _templatesError!),
                  style: body.bodySmall!.copyWith(color: palette.destructive),
                ),
              ),
            ),
          _AddRow(label: l10n.mission_addQuest, onTap: _addRow),
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
          if (_isEdit) ...<Widget>[
            const SizedBox(height: Space.s24),
            _DeleteButton(label: l10n.rule_deleteAction, onPressed: _delete),
          ],
        ],
      ),
    );
  }
}

/// Dialog with a title and a wrapping set of choices, on the sheet surface.
Future<T?> _showChoiceDialog<T>(
  BuildContext context, {
  required String title,
  required List<Widget> children,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: context.palette.scrim,
    barrierLabel: AppLocalizations.of(context).common_close,
    builder: (BuildContext dialogContext) {
      final QuestlogPalette palette = dialogContext.palette;
      return Dialog(
        backgroundColor: palette.sheet,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.s16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(
                header: true,
                namesRoute: true,
                child: Text(
                  title,
                  style: dialogContext.displayText.titleMedium,
                ),
              ),
              const SizedBox(height: Space.s12),
              Wrap(spacing: Space.s4, runSpacing: Space.s4, children: children),
            ],
          ),
        ),
      );
    },
  );
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.wide,
    required this.onTap,
  });

  final String label;
  final bool selected;

  /// Spans the full dialog width (weekday list) instead of a 44 px square.
  final bool wide;
  final void Function(BuildContext context) onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    final Widget tile = Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: () => onTap(context),
      child: Material(
        color: selected ? palette.brassSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(Radii.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.control),
          onTap: () => onTap(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: Metrics.touchTarget,
              minHeight: Metrics.touchTarget,
            ),
            child: Align(
              alignment: wide ? Alignment.centerLeft : Alignment.center,
              widthFactor: wide ? null : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Space.s12),
                child: Text(
                  label,
                  style: context.bodyText.bodyLarge!.copyWith(
                    color: selected ? palette.brassText : palette.text,
                    fontWeight: selected ? FontWeight.w700 : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return wide ? SizedBox(width: double.infinity, child: tile) : tile;
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

/// A Cadence chip: brass outline when selected, at least 44 px tall.
class _CadenceChip extends StatelessWidget {
  const _CadenceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? palette.brassSoft : palette.field,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? palette.brass : palette.boardLine,
            width: Metrics.hairline,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s16),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: context.bodyText.bodyMedium!.copyWith(
                    color: selected ? palette.brassText : palette.textDim,
                    fontWeight: FontWeight.w600,
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

/// The "Vyvěsit vždy · value ›" picker row.
class _PostingDayRow extends StatelessWidget {
  const _PostingDayRow({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final String value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    final TextTheme body = context.bodyText;
    return Semantics(
      button: true,
      label: '$label, $value',
      hint: hint,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: palette.field,
        borderRadius: BorderRadius.circular(Radii.control),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.control),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: Metrics.touchTarget + Space.s8,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s16),
              child: Row(
                children: <Widget>[
                  Text(label, style: body.bodyLarge),
                  const SizedBox(width: Space.s12),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: body.bodyLarge!.copyWith(
                        color: palette.brass,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.s8),
                  AppIcon(
                    IconAsset.chevronRight,
                    size: Metrics.iconSmall,
                    color: palette.textFaint,
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

/// One quest template row: name field, effort chip (tap to cycle) and a
/// remove button.
class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    super.key,
    required this.row,
    required this.onChanged,
    required this.onDifficultyChanged,
    required this.onRemove,
  });

  final _TemplateRow row;
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

/// The dashed "add quest" row below the template rows.
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
          painter: DashedBorderPainter(
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

/// Dashed rounded outline of the "add" rows.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = Metrics.dashStroke;
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
        canvas.drawPath(
          metric.extractPath(distance, distance + Metrics.dashLength),
          paint,
        );
        distance += Metrics.dashLength + Metrics.dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// Outlined destructive button ("Smazat pravidlo").
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette palette = context.palette;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          Metrics.touchTarget + Space.s8,
        ),
        foregroundColor: palette.destructive,
        side: BorderSide(color: palette.destructive, width: Metrics.hairline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.control),
        ),
        textStyle: context.bodyText.titleMedium,
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
