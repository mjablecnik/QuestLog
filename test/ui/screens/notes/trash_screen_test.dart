import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/notes/note_tree.dart';
import 'package:questlog/services/notes/notes_service.dart';
import 'package:questlog/ui/screens/note_editor/note_editor_screen.dart';
import 'package:questlog/ui/screens/notes/trash_preview_screen.dart';
import 'package:questlog/ui/screens/notes/trash_row.dart';
import 'package:questlog/ui/screens/notes/trash_screen.dart';
import 'package:questlog/ui/theme/tokens.dart';
import 'package:super_editor/super_editor.dart';

import '../../../helpers/fixed_clock.dart';
import '_notes_harness.dart';

void main() {
  final NotesUiHarness h = NotesUiHarness();
  final DateTime t0 = DateTime(2026, 11, 1, 10);

  Future<void> open(WidgetTester tester, {DateTime? now}) =>
      h.pump(tester, home: const TrashScreen(), now: now ?? t0);

  Future<NoteTree> tree(WidgetTester tester) async =>
      NoteTree(await tester.runAsync(() => h.service.watchAll().first) ?? <NoteNode>[]);

  Future<void> swipe(WidgetTester tester, Finder row) async {
    await tester.drag(row, const Offset(-320, 0));
    await h.settle(tester);
  }

  notesTest(h, 'an empty trash shows the empty state and no empty button', (tester) async {
    await open(tester);
    expect(find.text('The Trash is empty'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('trash-empty')), findsNothing);
    expect(find.text('Trash'), findsOneWidget);
  });

  notesTest(h, 'rows, order and wording', (tester) async {
    await open(tester);
    final NoteNode folder = await h.folder(tester, 'ABAP');
    final NoteNode a = await h.note(tester, 'Old note', parent: folder.id);
    final NoteNode b = await h.note(tester, 'New note');
    final NoteNode f = await h.folder(tester, 'Projects');
    await h.note(tester, 'in a folder', parent: f.id);
    await h.note(tester, 'in a folder two', parent: f.id);
    await h.run(tester, () => h.service.moveToTrash(a.id));
    h.clock.advance(const Duration(days: 20));
    await h.run(tester, () => h.service.moveToTrash(b.id));
    h.clock.advance(const Duration(days: 1));
    await h.run(tester, () => h.service.moveToTrash(f.id));
    h.clock.advance(const Duration(days: 8));
    await tester.pump(const Duration(seconds: 1));
    // The screen reads the clock when it builds: trigger a rebuild with a data change.
    await h.run(tester, () => h.service.rename(folder.id, 'ABAP'));
    final List<String> names = tester.widgetList<TrashRow>(find.byType(TrashRow)).map((r) => r.name).toList();
    expect(names, <String>['Old note', 'New note', 'Projects']);
    expect(find.text('from ABAP · deleted in 1 day'), findsOneWidget);
    expect(find.text('from Notes · deleted in 21 days'), findsOneWidget);
    expect(find.text('folder, 2 notes · from Notes · deleted in 22 days'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
  });

  notesTest(h, 'the remaining time is red at one day or less', (tester) async {
    await open(tester);
    final NoteNode a = await h.note(tester, 'soon');
    final NoteNode b = await h.note(tester, 'later');
    await h.run(tester, () => h.service.moveToTrash(a.id));
    h.clock.advance(const Duration(days: 10));
    await h.run(tester, () => h.service.moveToTrash(b.id));
    h.clock.advance(const Duration(days: 19, hours: 12));
    await h.note(tester, 'a change that rebuilds the list');
    final Color red = QuestlogPalette.guildBoard.destructive;
    Color colorOf(String text) => tester.widget<Text>(find.text(text)).style!.color!;
    expect(colorOf('from Notes · deleted in 1 day'), red);
    expect(colorOf('from Notes · deleted in 11 days'), isNot(red));
  });

  notesTest(h, 'Restore returns a note to its folder, and to the root when the folder is trashed', (tester) async {
    await open(tester);
    final NoteNode folder = await h.folder(tester, 'ABAP');
    final NoteNode a = await h.note(tester, 'alpha', parent: folder.id);
    final NoteNode b = await h.note(tester, 'beta', parent: folder.id);
    await h.run(tester, () => h.service.moveToTrash(a.id));
    await tester.tap(find.byKey(const ValueKey<String>('trash-restore')));
    await h.settle(tester);
    expect((await tree(tester)).byId(a.id)!.parentId, folder.id);
    expect(find.text('Restored'), findsOneWidget);
    expect(find.text('The Trash is empty'), findsOneWidget);

    await h.run(tester, () => h.service.moveToTrash(b.id));
    h.clock.advance(const Duration(minutes: 1));
    await h.run(tester, () => h.service.moveToTrash(folder.id));
    // The note was trashed first, so its row is the first one.
    await tester.tap(find.byKey(const ValueKey<String>('trash-restore')).first);
    await h.settle(tester);
    final NoteTree t = await tree(tester);
    expect(t.byId(b.id)!.parentId, isNull);
    expect(t.isVisible(b.id), isTrue);
  });

  notesTest(h, 'swipe shows Restore and Forever; Forever asks first and cancel keeps the item', (tester) async {
    await open(tester);
    final NoteNode n = await h.note(tester, 'alpha');
    await h.run(tester, () => h.service.moveToTrash(n.id));
    await swipe(tester, find.byType(TrashRow));
    expect(find.byKey(const ValueKey<String>('trash-swipe-restore')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('trash-swipe-forever')));
    await h.settle(tester);
    expect(find.text('Delete for good?'), findsOneWidget);
    expect(find.textContaining('cannot be restored'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await h.settle(tester);
    expect((await tree(tester)).byId(n.id), isNotNull);
    await swipe(tester, find.byType(TrashRow));
    await tester.tap(find.byKey(const ValueKey<String>('trash-swipe-forever')));
    await h.settle(tester);
    await tester.tap(find.text('Delete for good').last);
    await h.settle(tester);
    expect((await tree(tester)).byId(n.id), isNull);
    expect(find.text('Deleted for good'), findsOneWidget);
  });

  notesTest(h, 'Empty Trash asks with the count and deletes everything', (tester) async {
    await open(tester);
    final NoteNode a = await h.note(tester, 'a');
    final NoteNode b = await h.note(tester, 'b');
    final NoteNode keep = await h.note(tester, 'keep');
    await h.run(tester, () => h.service.moveToTrash(a.id));
    await h.run(tester, () => h.service.moveToTrash(b.id));
    await tester.tap(find.byKey(const ValueKey<String>('trash-empty')));
    await h.settle(tester);
    expect(find.text('Empty the Trash?'), findsOneWidget);
    expect(find.textContaining('2 items will be deleted for good'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await h.settle(tester);
    expect((await tree(tester)).trashEntries(), hasLength(2));
    await tester.tap(find.byKey(const ValueKey<String>('trash-empty')));
    await h.settle(tester);
    await tester.tap(find.text('Empty Trash').last);
    await h.settle(tester);
    expect((await tree(tester)).trashEntries(), isEmpty);
    expect((await tree(tester)).byId(keep.id), isNotNull);
    expect(find.text('The Trash was emptied'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('trash-empty')), findsNothing);
  });

  notesTest(h, 'opening the screen purges what expired', (tester) async {
    late int oldId;
    late int freshId;
    await h.pump(
      tester,
      home: const TrashScreen(),
      now: t0,
      seed: (NotesService service, FixedClock clock) async {
        final NoteNode old = (await service.saveBody(body: 'old', untitledName: 'u'))!;
        final NoteNode fresh = (await service.saveBody(body: 'fresh', untitledName: 'u'))!;
        oldId = old.id;
        freshId = fresh.id;
        await service.moveToTrash(old.id);
        clock.advance(const Duration(days: 29));
        await service.moveToTrash(fresh.id);
        clock.advance(const Duration(days: 2));
      },
    );
    await h.settle(tester);
    final NoteTree t = await tree(tester);
    expect(t.byId(oldId), isNull);
    expect(t.byId(freshId), isNotNull);
    expect(find.byType(TrashRow), findsOneWidget);
  });

  notesTest(h, 'tapping a trashed note row never opens the editor', (tester) async {
    await open(tester);
    final NoteNode n = await h.note(tester, 'alpha');
    await h.run(tester, () => h.service.moveToTrash(n.id));
    await tester.tap(find.byType(TrashRow));
    await h.settle(tester);
    expect(find.byType(NoteEditorScreen), findsNothing);
  });

  group('preview of a trashed note', () {
    Future<NoteNode> trashedNote(WidgetTester tester, String body, {String? title}) async {
      NoteNode? node;
      await tester.runAsync(() async {
        node = await h.service.saveBody(body: body, untitledName: 'u', title: title);
      });
      await h.settle(tester);
      await h.run(tester, () => h.service.moveToTrash(node!.id));
      return node!;
    }

    Future<void> openPreview(WidgetTester tester, String rowText) async {
      await tester.tap(find.text(rowText));
      await h.settle(tester);
    }

    Document previewDocument(WidgetTester tester) =>
        tester.widget<SuperReader>(find.byType(SuperReader)).editor.context.document;

    notesTest(h, 'opens read-only, with the name and the formatted text', (tester) async {
      await open(tester);
      await trashedNote(tester, '# Shopping\n\nmilk and **bread**\n\n- [ ] eggs');
      await openPreview(tester, 'Shopping');
      expect(find.byType(TrashPreviewScreen), findsOneWidget);
      expect(find.byType(SuperReader), findsOneWidget);
      expect(find.byType(SuperEditor), findsNothing);
      expect(find.byType(TextField), findsNothing, reason: 'no field to type in');
      expect(find.byKey(const ValueKey<String>('fmt-bold')), findsNothing, reason: 'no toolbar');
      final List<String> texts = <String>[
        for (final DocumentNode n in previewDocument(tester)) (n as TextNode).text.toPlainText(),
      ];
      expect(texts, <String>['Shopping', 'milk and bread', 'eggs'], reason: 'formatted, without Markdown markers');
      expect(find.byKey(const ValueKey<String>('preview-restore')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('preview-back')), findsOneWidget);
    });

    notesTest(h, 'a tap on a checklist item changes nothing', (tester) async {
      await open(tester);
      final NoteNode n = await trashedNote(tester, 'Tasks\n\n- [ ] eggs');
      await openPreview(tester, 'Tasks');
      await tester.tap(find.byKey(const ValueKey<String>('task-check')));
      await h.settle(tester);
      final TaskNode task = previewDocument(tester).last as TaskNode;
      expect(task.isComplete, isFalse);
      expect((await tree(tester)).byId(n.id)!.body, 'Tasks\n\n- [ ] eggs');
    });

    notesTest(h, 'a note with no text says so', (tester) async {
      await open(tester);
      await trashedNote(tester, '', title: 'Only a title');
      await openPreview(tester, 'Only a title');
      expect(find.text('Empty note'), findsOneWidget);
      expect(find.byType(SuperReader), findsNothing);
    });

    notesTest(h, 'Restore brings the note back, closes the preview and confirms', (tester) async {
      await open(tester);
      final NoteNode n = await trashedNote(tester, 'Come back');
      await openPreview(tester, 'Come back');
      await tester.tap(find.byKey(const ValueKey<String>('preview-restore')));
      await h.settle(tester);
      expect(find.byType(TrashPreviewScreen), findsNothing);
      expect(find.text('Restored'), findsOneWidget);
      expect((await tree(tester)).byId(n.id)!.deletedAt, isNull);
    });

    notesTest(h, 'back closes it and leaves the note in the Trash with its dates', (tester) async {
      await open(tester);
      final NoteNode n = await trashedNote(tester, 'Stay here');
      final NoteNode before = (await tree(tester)).byId(n.id)!;
      h.clock.advance(const Duration(days: 3));
      await openPreview(tester, 'Stay here');
      await tester.tap(find.byKey(const ValueKey<String>('preview-back')));
      await h.settle(tester);
      expect(find.byType(TrashPreviewScreen), findsNothing);
      final NoteNode after = (await tree(tester)).byId(n.id)!;
      expect(after.deletedAt, before.deletedAt);
      expect(after.updatedAt, before.updatedAt);
      expect(find.byType(TrashRow), findsOneWidget);
    });

    notesTest(h, 'it closes when the note is deleted for good meanwhile', (tester) async {
      await open(tester);
      final NoteNode n = await trashedNote(tester, 'Doomed');
      await openPreview(tester, 'Doomed');
      expect(find.byType(TrashPreviewScreen), findsOneWidget);
      await h.run(tester, () => h.service.deleteForever(n.id));
      await h.settle(tester);
      expect(find.byType(TrashPreviewScreen), findsNothing);
    });

    notesTest(h, 'a folder row opens no preview', (tester) async {
      await open(tester);
      final NoteNode f = await h.folder(tester, 'Projects');
      await h.note(tester, 'inside', parent: f.id);
      await h.run(tester, () => h.service.moveToTrash(f.id));
      await tester.tap(find.text('Projects'));
      await h.settle(tester);
      expect(find.byType(TrashPreviewScreen), findsNothing);
    });
  });
}
