import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../widgets/calendar/calendar_fields.dart';
import '../../widgets/sheet/questlog_sheet.dart';

/// Opens the sheet that asks for the address of a link and resolves to it
/// (with `https://` added when no scheme was typed), or null when dismissed.
Future<String?> showLinkSheet(BuildContext context, {String initial = ''}) {
  return showQuestlogSheet<String>(
    context,
    builder: (BuildContext context) => _LinkSheet(initial: initial),
  );
}

/// The address with `https://` in front when it has no scheme.
String normalizeLinkAddress(String raw) {
  final String text = raw.trim();
  return RegExp(r'^[A-Za-z][A-Za-z0-9+.-]*:').hasMatch(text) ? text : 'https://$text';
}

class _LinkSheet extends StatefulWidget {
  const _LinkSheet({required this.initial});

  final String initial;

  @override
  State<_LinkSheet> createState() => _LinkSheetState();
}

class _LinkSheetState extends State<_LinkSheet> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => _controller.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_valid) return;
    QuestlogSheet.close<String>(context, normalizeLinkAddress(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return QuestlogSheet(
      title: l.editor_fmtLink,
      primaryLabel: l.editor_linkApply,
      primaryEnabled: _valid,
      isDirty: false,
      onPrimary: _submit,
      child: CalendarTextField(
        fieldKey: const ValueKey<String>('link-field'),
        controller: _controller,
        hint: l.editor_linkLabel,
        autofocus: true,
        keyboardType: TextInputType.url,
        textCapitalization: TextCapitalization.none,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}
