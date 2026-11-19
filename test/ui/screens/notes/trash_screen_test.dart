import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/notes/note_tree.dart';
import 'package:questlog/services/notes/notes_service.dart';
import 'package:questlog/ui/screens/note_editor/note_editor_screen.dart';
import 'package:questlog/ui/screens/notes/trash_row.dart';
import 'package:questlog/ui/screens/notes/trash_screen.dart';
import 'package:questlog/ui/theme/tokens.dart';

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

  notesTest(h, 'tapping a trashed note row opens nothing', (tester) async {
    await open(tester);
    final NoteNode n = await h.note(tester, 'alpha');
    await h.run(tester, () => h.service.moveToTrash(n.id));
    await tester.tap(find.byType(TrashRow));
    await h.settle(tester);
    expect(find.byType(NoteEditorScreen), findsNothing);
  });
}
