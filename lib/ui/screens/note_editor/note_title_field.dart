import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/notes/note_title.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';

/// The single-line field in which the name of a Note is typed, above the text.
/// Empty means the Note is named after its first line; return moves on to the
/// text through [onSubmitted].
class NoteTitleField extends StatelessWidget {
  const NoteTitleField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final TextStyle style = context.displayText.headlineMedium!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.s20, Space.s8, Space.s20, Space.s4),
      child: TextField(
        key: const ValueKey<String>('note-title'),
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        style: style,
        cursorColor: p.brass,
        maxLength: maxNodeNameLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        maxLines: 1,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.sentences,
        onChanged: onChanged,
        // Return hands the focus over (instead of the default), so the keyboard stays up for the text.
        onEditingComplete: onSubmitted,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).editor_titleHint,
          hintStyle: style.copyWith(color: p.textFaint),
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: Space.s8),
        ),
      ),
    );
  }
}
