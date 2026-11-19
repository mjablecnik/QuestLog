import 'package:flutter/material.dart';

import '../../../core/notes/note_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/calendar/calendar_fields.dart';
import '../../widgets/sheet/questlog_sheet.dart';

/// Opens the Name_Sheet and resolves to the trimmed name, or null when it was
/// dismissed. The primary button stays disabled while the trimmed name is
/// empty or equal to [initial] (so a rename must change something).
Future<String?> showNameSheet(
  BuildContext context, {
  required String title,
  required String primaryLabel,
  String initial = '',
}) {
  return showQuestlogSheet<String>(
    context,
    builder: (BuildContext context) =>
        NameSheet(title: title, primaryLabel: primaryLabel, initial: initial),
  );
}

class NameSheet extends StatefulWidget {
  const NameSheet({
    super.key,
    required this.title,
    required this.primaryLabel,
    this.initial = '',
  });

  final String title;
  final String primaryLabel;
  final String initial;

  @override
  State<NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<NameSheet> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _name => _controller.text.trim();
  bool get _valid => _name.isNotEmpty && _name != widget.initial.trim();

  Future<void> _submit() async {
    if (!_valid) return;
    QuestlogSheet.close<String>(context, _name);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return QuestlogSheet(
      title: widget.title,
      primaryLabel: widget.primaryLabel,
      primaryEnabled: _valid,
      isDirty: _name != widget.initial.trim(),
      onPrimary: _submit,
      child: CalendarTextField(
        fieldKey: const ValueKey<String>('name-field'),
        controller: _controller,
        hint: l.notes_nameLabel,
        autofocus: true,
        maxLength: maxNodeNameLength,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}
