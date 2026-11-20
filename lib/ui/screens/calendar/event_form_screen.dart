import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cadence.dart';
import '../../../core/calendar/event_type.dart';
import '../../../core/calendar/event_xp.dart';
import '../../../core/calendar/repeat_rule.dart';
import '../../../core/errors.dart';
import '../../../data/calendar/calendar_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/calendar/calendar_providers.dart';
import '../../../services/providers.dart';
import '../../sheets/calendar/delete_event_sheet.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/calendar/address_suggestions.dart';
import '../../widgets/calendar/calendar_fields.dart';
import '../../widgets/calendar/event_type_picker.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/sheet/confirm_destructive.dart';
import 'calendar_labels.dart';

/// Opens the event form: a new event ([presetDate]), an existing one
/// ([editing], for the occurrence that starts on [occurrenceDate]) or a copy
/// ([prefill]).
Future<void> showEventForm(
  BuildContext context, {
  DateTime? presetDate,
  CalendarEvent? editing,
  DateTime? occurrenceDate,
  EventDraft? prefill,
}) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(
      builder: (_) => EventFormScreen(
        presetDate: presetDate,
        editing: editing,
        occurrenceDate: occurrenceDate,
        prefill: prefill,
      ),
    ),
  );
}

/// What the repeat picker offers; `keep` is a built-in Easter or n-th weekday
/// rule of an existing event, which is kept until the user picks another.
enum RepeatChoice { never, daily, weekly, monthly, yearly, keep }

DateTime _dateOnly(DateTime v) => DateTime(v.year, v.month, v.day);

/// A wall-clock instant, in UTC so that daylight saving cannot shift it.
DateTime _wall(DateTime date, int minute) => DateTime.utc(date.year, date.month, date.day, 0, minute);

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, this.presetDate, this.editing, this.occurrenceDate, this.prefill});

  final DateTime? presetDate;
  final CalendarEvent? editing;
  final DateTime? occurrenceDate;
  final EventDraft? prefill;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  late final TextEditingController _name;
  late final TextEditingController _note;
  late final TextEditingController _location;

  late EventType _type;
  late DateTime _startDate;
  late DateTime _endDate;
  int? _startMinute;
  int? _endMinute;
  late bool _allDay;
  late RepeatChoice _repeat;
  DateTime? _repeatEnd;
  RepeatRule? _keptRule;
  late bool _onBoard;
  bool _onBoardTouched = false;
  bool _typeTouched = false;

  bool _submitted = false;
  bool _saving = false;
  bool _closing = false;
  String? _serviceError;
  String? _errorName;
  String? _errorNote;
  String? _errorLocation;

  /// Remembered addresses that match the Address field while it has focus.
  List<String> _addresses = const <String>[];
  bool _locationFocused = false;
  int _addressRequest = 0;

  late String _initialKey;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final CalendarEvent? editing = widget.editing;
    final EventDraft? source = editing != null ? EventDraft.fromEvent(editing) : widget.prefill;
    if (source != null) {
      _name = TextEditingController(text: source.name);
      _note = TextEditingController(text: source.note ?? '');
      _location = TextEditingController(text: source.location ?? '');
      _type = source.type;
      _startDate = source.startDate;
      _endDate = source.endDate;
      _startMinute = source.startMinute;
      _endMinute = source.endMinute;
      _allDay = source.allDay;
      _onBoard = source.onBoard;
      _onBoardTouched = true;
      _typeTouched = true;
      switch (source.repeat) {
        case NoRepeat():
          _repeat = RepeatChoice.never;
        case CadenceRepeat(:final Cadence cadence):
          _repeat = switch (cadence) {
            Cadence.daily => RepeatChoice.daily,
            Cadence.weekly => RepeatChoice.weekly,
            Cadence.monthly => RepeatChoice.monthly,
            _ => RepeatChoice.yearly,
          };
        case EasterRelative() || NthWeekday():
          _repeat = RepeatChoice.keep;
          _keptRule = source.repeat;
      }
      _repeatEnd = source.repeat.end;
    } else {
      final DateTime now = ref.read(clockProvider).now();
      final DateTime today = _dateOnly(now);
      final DateTime date = _dateOnly(widget.presetDate ?? today);
      int start = date == today ? (now.hour + 1 > 23 ? 23 : now.hour + 1) * 60 : 9 * 60;
      _name = TextEditingController();
      _note = TextEditingController();
      _location = TextEditingController();
      _type = EventType.meeting;
      _startDate = date;
      _startMinute = start;
      final int end = start + 60;
      _endDate = end > 1439 ? DateTime(date.year, date.month, date.day + 1) : date;
      _endMinute = end > 1439 ? end - 1440 : end;
      _allDay = false;
      _repeat = RepeatChoice.never;
      _onBoard = _type.onBoardByDefault;
      _loadLastType();
    }
    _initialKey = _key();
  }

  Future<void> _loadLastType() async {
    final EventType last = await ref.read(calendarServiceProvider).lastUsedType();
    if (!mounted || _typeTouched || last == _type) return;
    setState(() {
      _type = last;
      if (!_onBoardTouched) _onBoard = last.onBoardByDefault;
      _initialKey = _key();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    _location.dispose();
    super.dispose();
  }

  String _key() => <Object?>[
    _name.text,
    _note.text,
    _location.text,
    _type.key,
    _startDate,
    _endDate,
    _allDay ? null : _startMinute,
    _allDay ? null : _endMinute,
    _repeat,
    _repeat == RepeatChoice.never ? null : _repeatEnd,
    _onBoard,
  ].join('|');

  bool get _dirty => _key() != _initialKey;

  RepeatRule _rule() {
    final DateTime? end = _repeat == RepeatChoice.never ? null : _repeatEnd;
    return switch (_repeat) {
      RepeatChoice.never => const NoRepeat(),
      RepeatChoice.daily => CadenceRepeat(Cadence.daily, end: end),
      RepeatChoice.weekly => CadenceRepeat(Cadence.weekly, end: end),
      RepeatChoice.monthly => CadenceRepeat(Cadence.monthly, end: end),
      RepeatChoice.yearly => CadenceRepeat(Cadence.yearly, end: end),
      RepeatChoice.keep => (_keptRule ?? const NoRepeat()).withEnd(end),
    };
  }

  EventDraft _draft() => EventDraft(
    name: _name.text,
    note: _note.text,
    location: _location.text,
    type: _type,
    startDate: _startDate,
    endDate: _endDate,
    startMinute: _allDay ? null : _startMinute,
    endMinute: _allDay ? null : _endMinute,
    repeat: _rule(),
    onBoard: _onBoard,
  );

  bool get _endBeforeStart {
    if (_endDate.isBefore(_startDate)) return true;
    if (_allDay) return false;
    return _endDate == _startDate && (_endMinute ?? 0) < (_startMinute ?? 0);
  }

  bool get _repeatEndBeforeStart =>
      _repeat != RepeatChoice.never && _repeatEnd != null && _repeatEnd!.isBefore(_startDate);

  bool get _canSave => _name.text.trim().isNotEmpty && !_saving;

  int get _xp => eventXp(
    type: _type,
    allDay: _allDay,
    duration: _allDay
        ? Duration(days: _endDate.difference(_startDate).inDays + 1)
        : _wall(_endDate, _endMinute ?? 0).difference(_wall(_startDate, _startMinute ?? 0)),
  );

  /// Looks up the Address_Suggestions for the text now in the Address field; a
  /// newer request makes an older answer obsolete. A failure shows none.
  Future<void> _refreshAddresses() async {
    final int request = ++_addressRequest;
    List<String> found;
    try {
      found = _locationFocused ? await ref.read(calendarServiceProvider).suggestAddresses(_location.text) : const <String>[];
    } catch (_) {
      found = const <String>[];
    }
    if (!mounted || request != _addressRequest) return;
    setState(() => _addresses = found);
  }

  void _pickAddress(String address) {
    _location.value = TextEditingValue(text: address, selection: TextSelection.collapsed(offset: address.length));
    _changed(() => _addresses = const <String>[]);
    _addressRequest++;
  }

  void _changed(VoidCallback change) {
    setState(() {
      change();
      _serviceError = null;
    });
  }

  /// Moves the start and carries the end along, so the duration is kept.
  void _moveStart(DateTime date, int? minute) {
    _changed(() {
      if (_allDay) {
        final int days = _endDate.difference(_startDate).inDays;
        _startDate = date;
        _endDate = DateTime(date.year, date.month, date.day + days);
        return;
      }
      final DateTime oldStart = _wall(_startDate, _startMinute ?? 0);
      final DateTime oldEnd = _wall(_endDate, _endMinute ?? 0);
      final int newMinute = minute ?? _startMinute ?? 0;
      final DateTime newStart = _wall(date, newMinute);
      final DateTime newEnd = oldEnd.add(newStart.difference(oldStart));
      _startDate = _dateOnly(DateTime(newStart.year, newStart.month, newStart.day));
      _startMinute = newMinute;
      _endDate = DateTime(newEnd.year, newEnd.month, newEnd.day);
      _endMinute = newEnd.hour * 60 + newEnd.minute;
    });
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial.isBefore(DateTime(2000)) ? DateTime(2000) : initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
  }

  Future<int?> _pickTime(int minute) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    return picked == null ? null : picked.hour * 60 + picked.minute;
  }

  Future<void> _save() async {
    setState(() {
      _submitted = true;
      _serviceError = null;
      _errorName = _errorNote = _errorLocation = null;
    });
    if (_name.text.trim().isEmpty || _endBeforeStart || _repeatEndBeforeStart) return;
    final AppLocalizations l = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final service = ref.read(calendarServiceProvider);
      if (widget.editing != null) {
        await service.update(widget.editing!.id, _draft());
      } else {
        await service.create(_draft());
      }
      if (!mounted) return;
      _closing = true;
      Navigator.of(context).pop();
    } on ValidationError catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        switch (error.field) {
          case 'name':
            _errorName = _name.text.trim().isEmpty ? l.calendar_errorName : l.calendar_errorNameLong;
          case 'note':
            _errorNote = l.calendar_errorNoteLong;
          case 'location':
            _errorLocation = l.calendar_errorLocationLong;
          default:
            _serviceError = l.calendar_saveFailed;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _serviceError = l.calendar_saveFailed;
      });
    }
  }

  Future<void> _confirmDiscard() async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool discard = await confirmDestructive(
      context,
      title: l.sheet_discardTitle,
      body: l.sheet_discardBody,
      confirmLabel: l.common_discard,
      cancelLabel: l.sheet_keepEditing,
    );
    if (discard && mounted) {
      _closing = true;
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final CalendarEvent event = widget.editing!;
    final bool deleted = await deleteEventFlow(
      context,
      ref,
      event,
      widget.occurrenceDate ?? event.startDate,
    );
    if (deleted && mounted) {
      _closing = true;
      Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final String locale = l.localeName;
    final bool nameError = _submitted && _name.text.trim().isEmpty;

    return PopScope<Object?>(
      canPop: _closing || !_dirty,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        backgroundColor: p.board,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _FormTopBar(
                title: _isEdit ? l.calendar_formEditTitle : l.calendar_formCreateTitle,
                saveEnabled: _canSave,
                onBack: () => Navigator.of(context).maybePop(),
                onSave: _save,
              ),
              Expanded(
                child: ListView(
                  // The form is short: build every row so none is skipped off screen.
                  scrollCacheExtent: const ScrollCacheExtent.pixels(Space.s64 * 40),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Space.s32),
                  children: <Widget>[
                    if (_serviceError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.s12),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _serviceError!,
                            style: context.bodyText.bodyMedium!.copyWith(color: p.destructive),
                          ),
                        ),
                      ),
                    CalendarCard(
                      children: <Widget>[
                        CalendarTextField(
                          key: const ValueKey<String>('form-name'),
                          controller: _name,
                          hint: l.calendar_formNameHint,
                          title: true,
                          autofocus: !_isEdit && widget.prefill == null,
                          errorText: nameError ? l.calendar_errorName : _errorName,
                          onChanged: (_) => _changed(() {}),
                        ),
                        CalendarTextField(
                          key: const ValueKey<String>('form-note'),
                          controller: _note,
                          hint: l.calendar_formNoteHint,
                          multiline: true,
                          errorText: _errorNote,
                          onChanged: (_) => _changed(() {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.s12),
                    CalendarCard(
                      children: <Widget>[
                        Semantics(
                          header: true,
                          child: Text(
                            l.calendar_formType.toUpperCase(),
                            style: context.bodyText.labelSmall!.copyWith(color: p.textFaint),
                          ),
                        ),
                        EventTypePicker(
                          selected: _type,
                          onSelected: (EventType type) => _changed(() {
                            _type = type;
                            _typeTouched = true;
                            if (!_onBoardTouched) _onBoard = type.onBoardByDefault;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.s12),
                    CalendarCard(
                      children: <Widget>[
                        CalendarSwitchRow(
                          label: l.calendar_allDay,
                          value: _allDay,
                          onChanged: (bool value) => _changed(() {
                            _allDay = value;
                            if (!value) {
                              _startMinute ??= 9 * 60;
                              _endMinute ??= (_startMinute! + 60).clamp(0, 1439);
                            }
                          }),
                        ),
                        _MomentRow(
                          key: const ValueKey<String>('form-start'),
                          label: l.calendar_start,
                          date: shortDateLabel(_startDate, locale),
                          time: _allDay ? null : minuteLabel(_startMinute ?? 0),
                          onDate: () async {
                            final DateTime? d = await _pickDate(_startDate);
                            if (d != null) _moveStart(d, null);
                          },
                          onTime: () async {
                            final int? m = await _pickTime(_startMinute ?? 0);
                            if (m != null) _moveStart(_startDate, m);
                          },
                        ),
                        _MomentRow(
                          key: const ValueKey<String>('form-end'),
                          label: l.calendar_end,
                          date: shortDateLabel(_endDate, locale),
                          time: _allDay ? null : minuteLabel(_endMinute ?? 0),
                          error: _endBeforeStart ? l.calendar_errorEnd : null,
                          onDate: () async {
                            final DateTime? d = await _pickDate(_endDate);
                            if (d != null) _changed(() => _endDate = d);
                          },
                          onTime: () async {
                            final int? m = await _pickTime(_endMinute ?? 0);
                            if (m != null) _changed(() => _endMinute = m);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.s12),
                    CalendarCard(
                      children: <Widget>[
                        _RepeatPicker(
                          value: _repeat,
                          keptRule: _keptRule,
                          onChanged: (RepeatChoice c) => _changed(() => _repeat = c),
                        ),
                        if (_repeat != RepeatChoice.never)
                          CalendarValueRow(
                            key: const ValueKey<String>('form-repeat-end'),
                            label: l.calendar_repeatEnds,
                            value: _repeatEnd == null
                                ? l.calendar_repeatNoEnd
                                : shortDateLabel(_repeatEnd!, locale),
                            onTap: () async {
                              final DateTime? d = await _pickDate(_repeatEnd ?? _startDate);
                              if (d != null) _changed(() => _repeatEnd = d);
                            },
                            trailing: _repeatEnd == null
                                ? null
                                : Semantics(
                                    button: true,
                                    label: l.calendar_clearRepeatEnd,
                                    excludeSemantics: true,
                                    onTap: () => _changed(() => _repeatEnd = null),
                                    child: InkWell(
                                      onTap: () => _changed(() => _repeatEnd = null),
                                      customBorder: const CircleBorder(),
                                      child: SizedBox(
                                        width: Metrics.touchTarget,
                                        height: Metrics.touchTarget,
                                        child: Center(
                                          child: AppIcon(IconAsset.close, size: Metrics.iconSmall, color: p.textDim),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        if (_repeatEndBeforeStart)
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              l.calendar_errorRepeatEnd,
                              style: context.bodyText.bodySmall!.copyWith(color: p.destructive),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.s12),
                    CalendarCard(
                      children: <Widget>[
                        CalendarTextField(
                          key: const ValueKey<String>('form-location'),
                          controller: _location,
                          hint: l.calendar_formLocationHint,
                          errorText: _errorLocation,
                          onChanged: (_) {
                            _changed(() {});
                            _refreshAddresses();
                          },
                          onFocusChange: (bool focused) {
                            _locationFocused = focused;
                            _refreshAddresses();
                          },
                        ),
                        if (_addresses.isNotEmpty) AddressSuggestions(addresses: _addresses, onPick: _pickAddress),
                      ],
                    ),
                    const SizedBox(height: Space.s12),
                    CalendarCard(
                      children: <Widget>[
                        CalendarSwitchRow(
                          label: l.calendar_onBoard,
                          value: _onBoard,
                          onChanged: (bool value) => _changed(() {
                            _onBoard = value;
                            _onBoardTouched = true;
                          }),
                        ),
                        if (_onBoard)
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              l.calendar_onBoardXp(_xp),
                              key: const ValueKey<String>('form-xp'),
                              style: context.bodyText.bodyMedium!.copyWith(color: p.brassText),
                            ),
                          ),
                      ],
                    ),
                    if (_isEdit) ...<Widget>[
                      const SizedBox(height: Space.s16),
                      TextButton.icon(
                        key: const ValueKey<String>('form-delete'),
                        onPressed: _delete,
                        icon: AppIcon(IconAsset.trash, size: Metrics.iconSmall, color: p.destructive),
                        label: Text(l.common_delete),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, Metrics.touchTarget + Space.s4),
                          foregroundColor: p.destructive,
                          textStyle: context.bodyText.labelLarge,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormTopBar extends StatelessWidget {
  const _FormTopBar({
    required this.title,
    required this.saveEnabled,
    required this.onBack,
    required this.onSave,
  });

  final String title;
  final bool saveEnabled;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s8, Space.s4, Space.s12, Space.s8),
      child: Row(
        children: <Widget>[
          Semantics(
            button: true,
            label: l.common_close,
            excludeSemantics: true,
            onTap: onBack,
            child: InkWell(
              key: const ValueKey<String>('form-back'),
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: Metrics.touchTarget,
                height: Metrics.touchTarget,
                child: Center(child: AppIcon(IconAsset.chevronLeft, size: Metrics.iconSmall, color: p.text)),
              ),
            ),
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.displayText.titleLarge,
              ),
            ),
          ),
          FilledButton(
            key: const ValueKey<String>('form-save'),
            onPressed: saveEnabled ? onSave : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(Metrics.fab + Space.s16, Metrics.touchTarget),
              backgroundColor: p.brass,
              foregroundColor: p.inkOnBrass,
              disabledBackgroundColor: p.field,
              disabledForegroundColor: p.textFaint,
              shape: const StadiumBorder(),
              textStyle: context.bodyText.labelLarge,
            ),
            child: Text(l.common_save),
          ),
        ],
      ),
    );
  }
}

class _MomentRow extends StatelessWidget {
  const _MomentRow({
    super.key,
    required this.label,
    required this.date,
    required this.time,
    required this.onDate,
    required this.onTime,
    this.error,
  });

  final String label;
  final String date;
  final String? time;
  final VoidCallback onDate;
  final VoidCallback onTime;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    Widget chip(String text, VoidCallback onTap, {bool expand = false}) => Semantics(
      button: true,
      label: '$label, $text',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.control),
        child: Container(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget, minWidth: Metrics.touchTarget),
          alignment: expand ? Alignment.centerLeft : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: Space.s12),
          decoration: BoxDecoration(
            color: p.field,
            borderRadius: BorderRadius.circular(Radii.control),
            border: error == null ? null : Border.all(color: p.destructive, width: Metrics.hairline),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.bodyText.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: context.bodyText.titleMedium),
        const SizedBox(height: Space.s4),
        Row(
          children: <Widget>[
            Expanded(child: chip(date, onDate, expand: true)),
            if (time != null) ...<Widget>[
              const SizedBox(width: Space.s8),
              chip(time!, onTime),
            ],
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: Space.s4),
            child: Semantics(
              liveRegion: true,
              child: Text(error!, style: context.bodyText.bodySmall!.copyWith(color: p.destructive)),
            ),
          ),
      ],
    );
  }
}

class _RepeatPicker extends StatelessWidget {
  const _RepeatPicker({required this.value, required this.keptRule, required this.onChanged});

  final RepeatChoice value;
  final RepeatRule? keptRule;
  final ValueChanged<RepeatChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    String name(RepeatChoice c) => switch (c) {
      RepeatChoice.never => l.calendar_repeatNever,
      RepeatChoice.daily => l.calendar_repeatDaily,
      RepeatChoice.weekly => l.calendar_repeatWeekly,
      RepeatChoice.monthly => l.calendar_repeatMonthly,
      RepeatChoice.yearly => l.calendar_repeatYearly,
      RepeatChoice.keep => keptRule is NthWeekday ? l.calendar_repeatNth : l.calendar_repeatEaster,
    };
    final List<RepeatChoice> choices = <RepeatChoice>[
      for (final RepeatChoice c in RepeatChoice.values)
        if (c != RepeatChoice.keep || keptRule != null) c,
    ];
    return Semantics(
      container: true,
      label: '${l.calendar_repeat}, ${name(value)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(l.calendar_repeat, style: context.bodyText.titleMedium),
          const SizedBox(height: Space.s4),
          Container(
            constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
            padding: const EdgeInsets.symmetric(horizontal: Space.s12),
            decoration: BoxDecoration(
              color: p.field,
              borderRadius: BorderRadius.circular(Radii.control),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<RepeatChoice>(
                key: const ValueKey<String>('form-repeat'),
                value: value,
                isExpanded: true,
                dropdownColor: p.sheet,
                borderRadius: BorderRadius.circular(Radii.control),
                style: context.bodyText.bodyLarge!.copyWith(color: p.text, fontWeight: FontWeight.w600),
                iconEnabledColor: p.textDim,
                onChanged: (RepeatChoice? c) {
                  if (c != null) onChanged(c);
                },
                items: <DropdownMenuItem<RepeatChoice>>[
                  for (final RepeatChoice c in choices)
                    DropdownMenuItem<RepeatChoice>(
                      value: c,
                      child: Text(name(c), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
