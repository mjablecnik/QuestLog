import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/notes/node_tiles.dart';

/// One Note in the list: name, the date of its last edit and a two-line preview.
class NoteRow extends StatelessWidget {
  const NoteRow({
    super.key,
    required this.name,
    required this.date,
    required this.preview,
    required this.onTap,
  });

  final String name;

  /// Already localized last-edited date ("dnes", "včera", "17. 11.").
  final String date;

  /// The Note_Preview; may be empty.
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: '${l.a11y_openNote(name)}. $date. $preview',
      excludeSemantics: true,
      onTap: onTap,
      child: NodeCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.s16, Space.s12, Space.s16, Space.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyText.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: Space.s12),
                  Text(
                    date,
                    maxLines: 1,
                    style: context.bodyText.bodySmall!.copyWith(color: p.textFaint),
                  ),
                ],
              ),
              if (preview.isNotEmpty) ...<Widget>[
                const SizedBox(height: Space.s4),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyText.bodyMedium!.copyWith(color: p.textDim),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
