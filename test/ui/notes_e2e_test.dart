import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/notes/note_tree.dart';
import 'package:questlog/services/notes/notes_providers.dart';
import 'package:questlog/services/providers.dart';
import 'package:questlog/ui/screens/note_editor/note_editor_screen.dart';
import 'package:questlog/ui/screens/notes/folder_row.dart';
import 'package:questlog/ui/screens/notes/note_row.dart';
import 'package:questlog/ui/screens/notes/trash_row.dart';
import 'package:questlog/ui/screens/shell/questlog_tab_bar.dart';
import 'package:super_editor/super_editor.dart';

import 'a11y/_a11y_harness.dart';

/// A day with the notes: a folder and a sub-folder, a formatted note, moving it,
/// deleting a folder with its content, restoring it from the Trash and deleting
/// a note for good, with Total_XP never changing.
void main() {
  a11yTest('folders, a formatted note, move, trash, restore and delete for good', (tester, track) async {
    final A11yEnv env = await A11yEnv.pump(tester, Subject.shell);
    track(env);
    final ProviderContainer container = ProviderScope.containerOf(tester.element(find.byType(QuestlogTabBar)));
    final int? xpBefore = await tester.runAsync(() => container.read(xpEngineProvider).readTotal());

    Future<void> tap(Finder finder) async {
      await tester.tap(finder);
      for (int i = 0; i < 5; i++) {
        await env.settle();
      }
    }

    Future<NoteTree> tree() async =>
        NoteTree((await tester.runAsync(() => container.read(notesServiceProvider).watchAll().first))!);

    Editor editor() => tester.widget<SuperEditor>(find.byType(SuperEditor)).editor;

    Future<void> typeIntoEditor(String text, {bool bold = false}) async {
      final MutableDocument doc = editor().context.document;
      final TextNode last = doc.last as TextNode;
      final DocumentPosition end = DocumentPosition(
        nodeId: last.id,
        nodePosition: TextNodePosition(offset: last.text.length),
      );
      editor().execute(<EditRequest>[
        ChangeSelectionRequest(
          DocumentSelection.collapsed(position: end),
          SelectionChangeType.placeCaret,
          SelectionReason.userInteraction,
        ),
        InsertTextRequest(documentPosition: end, textToInsert: text, attributions: const <Attribution>{}),
      ]);
      await tester.pump();
    }

    // The Notes tab shows the seeded folder and the root note; the trashed note is not listed.
    await tap(find.byKey(const ValueKey<ShellTab>(ShellTab.notes)));
    expect(find.byType(FolderRow), findsOneWidget);
    expect(find.byType(NoteRow), findsOneWidget);

    // A new folder "Ideas" through the add sheet.
    await tap(find.byKey(const ValueKey<String>('add-fab')).last);
    await tap(find.byKey(const ValueKey<String>('add-folder')));
    await tester.enterText(find.byKey(const ValueKey<String>('name-field')), 'Ideas');
    await tester.pump();
    await tap(find.text('Create folder'));
    expect(find.text('Ideas'), findsOneWidget);

    // Open it and write a formatted note there.
    await tap(find.text('Ideas'));
    expect(find.text('Nothing here yet'), findsOneWidget);
    await tap(find.byKey(const ValueKey<String>('add-fab')).last);
    await tap(find.byKey(const ValueKey<String>('add-note')));
    expect(find.byType(NoteEditorScreen), findsOneWidget);
    await typeIntoEditor('Weekend plan');
    await tap(find.byKey(const ValueKey<String>('fmt-heading')));
    await typeIntoEditor('');
    await tap(find.byKey(const ValueKey<String>('editor-done')));
    expect(find.byType(NoteEditorScreen), findsNothing);
    NoteTree t = await tree();
    final NoteNode ideas = t.all.firstWhere((n) => n.name == 'Ideas');
    final NoteNode plan = t.children(ideas.id).single;
    expect(plan.name, 'Weekend plan');
    expect(plan.body, '# Weekend plan');
    expect(find.byType(NoteRow), findsOneWidget);

    // Reopen it: the heading is shown as a heading, and the menu moves it to the top level.
    await tap(find.byType(NoteRow));
    final MutableDocument doc = editor().context.document;
    expect(doc.first.getMetadataValue('blockType'), header1Attribution);
    await tap(find.byKey(const ValueKey<String>('node-menu')));
    await tap(find.text('Move').last);
    await tap(find.byKey(const ValueKey<String>('move-root')));
    await tap(find.text('Move to Notes'));
    expect((await tree()).byId(plan.id)!.parentId, isNull);
    await tap(find.byKey(const ValueKey<String>('editor-done')));

    // Put a second note into Ideas, then delete the folder: the warning counts what is inside.
    await tap(find.byKey(const ValueKey<String>('add-fab')).last);
    await tap(find.byKey(const ValueKey<String>('add-note')));
    await typeIntoEditor('Sailing trip');
    await tap(find.byKey(const ValueKey<String>('editor-done')));
    expect((await tree()).children(ideas.id).single.name, 'Sailing trip');

    // Back at the top level, swipe the folder: the warning counts what is inside it.
    await tap(find.byKey(const ValueKey<String>('notes-back')));
    expect(find.byType(FolderRow), findsNWidgets(2));
    await tester.drag(
      find.ancestor(of: find.text('Ideas'), matching: find.byType(FolderRow)),
      const Offset(-320, 0),
    );
    await env.settle();
    await tap(find.byKey(const ValueKey<String>('node-swipe-delete')));
    expect(find.text('Move Ideas to the Trash?'), findsOneWidget);
    await tap(find.text('Move to Trash').last);
    expect((await tree()).byId(ideas.id)!.deletedAt, isNotNull);

    // The Trash holds the folder with its note; restore it.
    await tap(find.byKey(const ValueKey<String>('notes-trash')));
    expect(find.text('Trash'), findsWidgets);
    expect(find.text('folder, 1 note · from Notes · deleted in 30 days'), findsOneWidget);
    await tap(find.byKey(const ValueKey<String>('trash-restore')).last);
    expect((await tree()).byId(ideas.id)!.deletedAt, isNull);
    expect((await tree()).noteCountDeep(ideas.id), 1);

    // The seeded trashed note is still there: delete it for good.
    await tap(find.byKey(const ValueKey<String>('trash-back')));
    await tap(find.byKey(const ValueKey<String>('notes-trash')));
    await tester.drag(find.byType(TrashRow).first, const Offset(-320, 0));
    await env.settle();
    await tap(find.byKey(const ValueKey<String>('trash-swipe-forever')));
    await tap(find.text('Delete for good').last);
    expect((await tree()).trashEntries(), isEmpty);

    final int? xpAfter = await tester.runAsync(() => container.read(xpEngineProvider).readTotal());
    expect(xpAfter, xpBefore, reason: 'notes award no XP');
  });
}
