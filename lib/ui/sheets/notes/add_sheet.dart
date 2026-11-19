import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../theme/questlog_theme.dart';
import '../../theme/tokens.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/notes/node_tiles.dart';
import '../../widgets/sheet/questlog_sheet.dart';

/// What the Add_Sheet creates.
enum NewNodeKind { note, folder }

/// Opens the Add_Sheet: Nová poznámka or Nová složka, with a line naming
/// [placeName], the place where the new Node will be created.
Future<NewNodeKind?> showAddSheet(BuildContext context, {required String placeName}) {
  return showQuestlogSheet<NewNodeKind>(
    context,
    builder: (BuildContext context) => _AddSheet(placeName: placeName),
  );
}

class _AddSheet extends StatelessWidget {
  const _AddSheet({required this.placeName});

  final String placeName;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final QuestlogPalette p = context.palette;
    return QuestlogSheet(
      title: l.notes_addTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Choice(
            choiceKey: const ValueKey<String>('add-note'),
            icon: IconAsset.notePlus,
            title: l.notes_addNote,
            hint: l.notes_addNoteHint,
            onTap: () => QuestlogSheet.close<NewNodeKind>(context, NewNodeKind.note),
          ),
          const SizedBox(height: Space.s12),
          _Choice(
            choiceKey: const ValueKey<String>('add-folder'),
            icon: IconAsset.folderPlus,
            title: l.notes_addFolder,
            hint: l.notes_addFolderHint,
            onTap: () => QuestlogSheet.close<NewNodeKind>(context, NewNodeKind.folder),
          ),
          const SizedBox(height: Space.s16),
          Text(
            l.notes_addWhere(placeName),
            textAlign: TextAlign.center,
            style: context.bodyText.bodySmall!.copyWith(color: p.textFaint),
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.choiceKey,
    required this.icon,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final Key choiceKey;
  final String icon;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final QuestlogPalette p = context.palette;
    return Semantics(
      button: true,
      label: '$title. $hint',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: p.field,
        borderRadius: BorderRadius.circular(Radii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: choiceKey,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(Space.s12),
            child: Row(
              children: <Widget>[
                NodeIconTile(icon: icon),
                const SizedBox(width: Space.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: context.bodyText.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        hint,
                        style: context.bodyText.bodySmall!.copyWith(color: p.textDim),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
