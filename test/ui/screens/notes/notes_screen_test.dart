import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/notes/note_tree.dart';
import 'package:questlog/services/notes/notes_providers.dart';
import 'package:questlog/ui/screens/notes/breadcrumb.dart';
import 'package:questlog/ui/screens/notes/folder_row.dart';
import 'package:questlog/ui/screens/notes/note_row.dart';
import 'package:questlog/ui/screens/notes/notes_screen.dart';
import 'package:questlog/ui/state/notes_state.dart';

import '_notes_harness.dart';

void main() {
  final NotesUiHarness h = NotesUiHarness();

  Future<void> open(
    WidgetTester tester, {
    DateTime? now,
    double? textScale,
    Brightness? brightness,
    Locale locale = const Locale('en'),
  }) => h.pump(
    tester,
    home: const NotesScreen(),
    now: now,
    textScale: textScale,
    brightness: brightness ?? Brightness.dark,
    locale: locale,
  );

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(NotesScreen)));

  Future<NoteTree> tree(WidgetTester tester) async =>
      NoteTree(await tester.runAsync(() => h.service.watchAll().first) ?? <NoteNode>[]);

  Future<void> addFolderThroughUi(WidgetTester tester, String name) async {
    await tester.tap(find.byKey(const ValueKey<String>('add-fab')));
    await h.settle(tester);
    await tester.tap(find.byKey(const ValueKey<String>('add-folder')));
    await h.settle(tester);
    await tester.enterText(find.byKey(const ValueKey<String>('name-field')), name);
    await tester.pump();
    await tester.tap(find.text('Create folder'));
    await h.settle(tester);
  }

  Future<void> swipe(WidgetTester tester, Finder row) async {
    await tester.drag(row, const Offset(-320, 0));
    await h.settle(tester);
  }

  group('title row', () {
    double lineCount(WidgetTester tester, String text, {double scale = 1}) {
      final RenderParagraph paragraph = tester.renderObject(find.text(text));
      return paragraph.size.height / (paragraph.text.style!.fontSize! * scale * paragraph.text.style!.height!);
    }

    /// The real Figtree: with the test font (Ahem) every letter is a full square and the widths are not the app's.
    Future<void> loadFigtree(WidgetTester tester) => tester.runAsync(() async {
      final FontLoader loader = FontLoader('Figtree');
      for (final int weight in <int>[400, 500, 600, 700, 800]) {
        loader.addFont(
          Future<ByteData>.value(ByteData.sublistView(File('assets/fonts/Figtree-$weight.ttf').readAsBytesSync())),
        );
      }
      await loader.load();
    });

    notesTest(h, 'Poznámky is never broken inside the word', (tester) async {
      await loadFigtree(tester);
      await h.pump(tester, home: const NotesScreen(), locale: const Locale('cs'));
      await h.folder(tester, 'ABAP');
      await h.note(tester, '# One');
      expect(find.text('Poznámky'), findsOneWidget);
      expect(lineCount(tester, 'Poznámky'), closeTo(1, 0.1), reason: 'no break inside the word');
      expect(tester.getTopLeft(find.byKey(const ValueKey<String>('notes-trash'))).dx, greaterThan(300));
    });

    notesTest(h, 'the counts go under the title when they do not fit beside it', (tester) async {
      await loadFigtree(tester);
      await h.pump(tester, home: const NotesScreen(), locale: const Locale('cs'), textScale: 1.3);
      await h.folder(tester, 'ABAP');
      await h.note(tester, '# One');
      expect(lineCount(tester, 'Poznámky', scale: 1.3), closeTo(1, 0.1), reason: 'the title keeps one line');
      expect(
        tester.getTopLeft(find.text('1 složka · 1 poznámka')).dy,
        greaterThan(tester.getBottomLeft(find.text('Poznámky')).dy - 1),
        reason: 'the counts sit under the title',
      );
      expect(tester.getTopLeft(find.byKey(const ValueKey<String>('notes-trash'))).dx, greaterThan(300));
    });

    notesTest(h, 'a short title keeps the counts beside it, at the right', (tester) async {
      await open(tester);
      await h.folder(tester, 'A');
      expect(find.text('Notes'), findsOneWidget);
      final Finder counts = find.text('1 folder');
      expect(tester.getCenter(counts).dy, closeTo(tester.getCenter(find.text('Notes')).dy, 2));
      expect(tester.getTopLeft(counts).dx, greaterThan(tester.getTopRight(find.text('Notes')).dx));
    });

    notesTest(h, 'no overflow at 320 points and a text scale of 130 %', (tester) async {
      await open(tester, textScale: 1.3, locale: const Locale('cs'));
      tester.view.physicalSize = const Size(320, 844);
      await h.folder(tester, 'ABAP');
      await h.note(tester, '# One');
      await h.settle(tester);
      expect(tester.takeException(), isNull);
      expect(lineCount(tester, 'Poznámky', scale: 1.3), closeTo(1, 0.1), reason: 'shrunk, not broken');
    });
  });

  group('browsing', () {
    notesTest(h, 'shows the empty state of an empty folder, no sections, no hero bar', (tester) async {
      await open(tester);
      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(find.text('FOLDERS'), findsNothing);
      expect(find.text('NOTES'), findsNothing);
      expect(find.text('Notes'), findsOneWidget, reason: 'the title');
    });

    notesTest(h, 'lists folders above notes with their counts and omits an empty section', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'ABAP');
      await h.folder(tester, 'Home', parent: null);
      await h.folder(tester, 'Syntax', parent: a.id);
      await h.note(tester, '# One\n\nbody', parent: a.id);
      await h.note(tester, '# Two', parent: a.id);
      expect(find.text('FOLDERS'), findsOneWidget);
      expect(find.text('NOTES'), findsNothing, reason: 'no notes at the top level');
      expect(find.text('2 folders'), findsOneWidget, reason: 'header counts');
      expect(find.text('1 folder · 2 notes'), findsOneWidget, reason: 'ABAP row');
      expect(find.text('Empty folder'), findsNWidgets(1), reason: 'Home');
      final List<String> names = tester.widgetList<FolderRow>(find.byType(FolderRow)).map((r) => r.name).toList();
      expect(names, <String>['ABAP', 'Home']);
    });

    notesTest(h, 'a note row shows name, preview and a date label', (tester) async {
      await open(tester, now: DateTime(2026, 11, 19, 10));
      await h.note(tester, '# Shopping\n\nmilk and bread');
      final NoteRow row = tester.widget<NoteRow>(find.byType(NoteRow));
      expect(row.name, 'Shopping');
      expect(row.preview, 'milk and bread', reason: 'the name line is not repeated');
      expect(row.date, 'today');
      expect(find.text('NOTES'), findsOneWidget);
    });

    notesTest(h, 'a folder opens, the breadcrumb and back button follow, the system back goes up', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'ABAP');
      final NoteNode s = await h.folder(tester, 'Syntax', parent: a.id);
      await h.note(tester, 'x', parent: s.id);
      await tester.tap(find.byType(FolderRow));
      await h.settle(tester);
      expect(find.text('ABAP'), findsWidgets);
      expect(find.byKey(const ValueKey<String>('notes-back')), findsOneWidget);
      await tester.tap(find.byType(FolderRow));
      await h.settle(tester);
      // Breadcrumb: Notes > ABAP > Syntax, title Syntax.
      expect(find.text('Syntax'), findsWidgets);
      expect(container(tester).read(visibleFolderProvider), s.id);
      final double crumbX = tester
          .getTopLeft(find.descendant(of: find.byType(Breadcrumb), matching: find.text('Notes')))
          .dx;
      expect(crumbX, lessThan(40), reason: 'a short breadcrumb starts at the left edge');
      await tester.tap(find.byKey(const ValueKey<String>('notes-back')));
      await h.settle(tester);
      expect(container(tester).read(visibleFolderProvider), a.id);
      await tester.tap(find.text('Notes').first);
      await h.settle(tester);
      expect(container(tester).read(visibleFolderProvider), isNull);
    });

    notesTest(h, 'falls back to the root when the current folder is trashed', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'ABAP');
      container(tester).read(currentFolderProvider.notifier).open(a.id);
      await h.settle(tester);
      expect(container(tester).read(visibleFolderProvider), a.id);
      await h.run(tester, () => h.service.moveToTrash(a.id));
      expect(container(tester).read(visibleFolderProvider), isNull);
      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    notesTest(h, 'long breadcrumbs keep the first segment and the last two', (tester) async {
      await open(tester);
      NoteNode? parent;
      for (final String name in <String>['One', 'Two', 'Three', 'Four', 'Five']) {
        parent = await h.folder(tester, name, parent: parent?.id);
      }
      container(tester).read(currentFolderProvider.notifier).open(parent!.id);
      await h.settle(tester);
      expect(find.text('…'), findsOneWidget);
      expect(find.text('Four'), findsWidgets);
      expect(find.text('Two'), findsNothing);
    });
  });

  group('creating', () {
    notesTest(h, 'the add button opens the sheet naming the current place', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const ValueKey<String>('add-fab')));
      await h.settle(tester);
      expect(find.text('New note'), findsOneWidget);
      expect(find.text('New folder'), findsOneWidget);
      expect(find.text('It will be created in Notes'), findsOneWidget);
    });

    notesTest(h, 'a folder is created from the name sheet; the button waits for a name', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const ValueKey<String>('add-fab')));
      await h.settle(tester);
      await tester.tap(find.byKey(const ValueKey<String>('add-folder')));
      await h.settle(tester);
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), '   ');
      await tester.pump();
      await tester.tap(find.text('Create folder'));
      await h.settle(tester);
      expect((await tree(tester)).children(null), isEmpty, reason: 'blank name creates nothing');
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), '  Projects ');
      await tester.pump();
      await tester.tap(find.text('Create folder'));
      await h.settle(tester);
      expect((await tree(tester)).children(null).single.name, 'Projects');
      expect(find.byType(FolderRow), findsOneWidget);
    });

    notesTest(h, 'the name field takes at most 80 characters', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const ValueKey<String>('add-fab')));
      await h.settle(tester);
      await tester.tap(find.byKey(const ValueKey<String>('add-folder')));
      await h.settle(tester);
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), 'x' * 95);
      await tester.pump();
      expect(tester.widget<TextField>(find.byKey(const ValueKey<String>('name-field'))).controller!.text.length, 80);
    });

    notesTest(h, 'a folder is created inside the current folder', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'ABAP');
      await tester.tap(find.byType(FolderRow));
      await h.settle(tester);
      await addFolderThroughUi(tester, 'Syntax');
      final NoteTree t = await tree(tester);
      expect(t.children(a.id).single.name, 'Syntax');
    });
  });

  group('swipe actions and menu', () {
    notesTest(h, 'swiping reveals rename, move and delete; only one row stays open', (tester) async {
      await open(tester);
      await h.folder(tester, 'ABAP');
      await h.note(tester, 'text');
      await swipe(tester, find.byType(FolderRow));
      expect(find.byKey(const ValueKey<String>('node-swipe-rename')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('node-swipe-move')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('node-swipe-delete')), findsOneWidget);
      await swipe(tester, find.byType(NoteRow));
      await h.settle(tester);
      final double folderX = tester.getTopLeft(find.byType(FolderRow)).dx;
      expect(folderX, greaterThanOrEqualTo(0), reason: 'the first row closed again');
    });

    notesTest(h, 'rename from the swipe changes the name and needs a different name', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'ABAP');
      await swipe(tester, find.byType(FolderRow));
      await tester.tap(find.byKey(const ValueKey<String>('node-swipe-rename')));
      await h.settle(tester);
      expect(find.text('Rename'), findsWidgets);
      final TextField field = tester.widget<TextField>(find.byKey(const ValueKey<String>('name-field')));
      expect(field.controller!.text, 'ABAP');
      await tester.tap(find.text('Save'));
      await h.settle(tester);
      expect((await tree(tester)).byId(a.id)!.name, 'ABAP', reason: 'unchanged name does nothing');
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), 'Learning');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await h.settle(tester);
      expect((await tree(tester)).byId(a.id)!.name, 'Learning');
    });

    notesTest(h, 'deleting a note moves it to the trash with a snackbar and no dialog', (tester) async {
      await open(tester);
      final NoteNode n = await h.note(tester, 'text');
      await swipe(tester, find.byType(NoteRow));
      await tester.tap(find.byKey(const ValueKey<String>('node-swipe-delete')));
      await h.settle(tester);
      expect(find.text('Moved to the Trash'), findsOneWidget);
      expect((await tree(tester)).byId(n.id)!.deletedAt, isNotNull);
      expect(find.byType(NoteRow), findsNothing);
    });

    notesTest(h, 'deleting a folder with content asks first, dismissing changes nothing', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'ABAP');
      final NoteNode s = await h.folder(tester, 'Syntax', parent: a.id);
      await h.note(tester, 'one', parent: a.id);
      await h.note(tester, 'two', parent: s.id);
      await swipe(tester, find.byType(FolderRow));
      await tester.tap(find.byKey(const ValueKey<String>('node-swipe-delete')));
      await h.settle(tester);
      expect(find.text('Move ABAP to the Trash?'), findsOneWidget);
      expect(find.textContaining('1 folder and 2 notes'), findsOneWidget);
      expect(find.textContaining('30 days'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await h.settle(tester);
      expect((await tree(tester)).byId(a.id)!.deletedAt, isNull);
      await swipe(tester, find.byType(FolderRow));
      await tester.tap(find.byKey(const ValueKey<String>('node-swipe-delete')));
      await h.settle(tester);
      await tester.tap(find.text('Move to Trash').last);
      await h.settle(tester);
      expect((await tree(tester)).byId(a.id)!.deletedAt, isNotNull);
      expect((await tree(tester)).trashEntries(), hasLength(1));
    });

    notesTest(h, 'an empty folder goes to the trash without a dialog', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'Empty');
      await swipe(tester, find.byType(FolderRow));
      await tester.tap(find.byKey(const ValueKey<String>('node-swipe-delete')));
      await h.settle(tester);
      expect(find.text('Moved to the Trash'), findsOneWidget);
      expect((await tree(tester)).byId(a.id)!.deletedAt, isNotNull);
    });

    notesTest(h, 'the menu of an open folder renames, moves and trashes it like the swipe does', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'ABAP');
      final NoteNode b = await h.folder(tester, 'Home');
      await tester.tap(find.byType(FolderRow).first);
      await h.settle(tester);
      // rename
      await tester.tap(find.byKey(const ValueKey<String>('node-menu')));
      await h.settle(tester);
      await tester.tap(find.text('Rename').last);
      await h.settle(tester);
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), 'ABAP 2');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await h.settle(tester);
      expect((await tree(tester)).byId(a.id)!.name, 'ABAP 2');
      // move into Home: the folder stays open with its breadcrumb
      await tester.tap(find.byKey(const ValueKey<String>('node-menu')));
      await h.settle(tester);
      await tester.tap(find.text('Move').last);
      await h.settle(tester);
      await tester.tap(find.byKey(ValueKey<String>('move-${b.id}')));
      await tester.pump();
      await tester.tap(find.text('Move to Home'));
      await h.settle(tester);
      expect((await tree(tester)).byId(a.id)!.parentId, b.id);
      expect(container(tester).read(visibleFolderProvider), a.id);
      // trash: the parent is shown afterwards
      await tester.tap(find.byKey(const ValueKey<String>('node-menu')));
      await h.settle(tester);
      await tester.tap(find.text('Move to Trash').last);
      await h.settle(tester);
      expect((await tree(tester)).byId(a.id)!.deletedAt, isNotNull);
      expect(container(tester).read(visibleFolderProvider), b.id);
    });
  });

  group('moving', () {
    notesTest(h, 'the move sheet marks the current location and blocks the folder itself and its subfolders', (tester) async {
      await open(tester);
      final NoteNode a = await h.folder(tester, 'ABAP');
      final NoteNode s = await h.folder(tester, 'Syntax', parent: a.id);
      final NoteNode b = await h.folder(tester, 'Home');
      await swipe(tester, find.byType(FolderRow).first);
      await tester.tap(find.byKey(const ValueKey<String>('node-swipe-move')));
      await h.settle(tester);
      expect(find.text('Folder “ABAP”'), findsOneWidget);
      expect(find.text('current location'), findsOneWidget);
      // the primary button is disabled while the current location is selected
      expect(find.text('Move to Notes'), findsOneWidget);
      await tester.tap(find.byKey(ValueKey<String>('move-${s.id}')));
      await tester.pump();
      expect(find.text('Move to Notes'), findsOneWidget, reason: 'a blocked row cannot be selected');
      await tester.tap(find.byKey(ValueKey<String>('move-${b.id}')));
      await tester.pump();
      expect(find.text('Move to Home'), findsOneWidget);
      await tester.tap(find.text('Move to Home'));
      await h.settle(tester);
      expect((await tree(tester)).byId(a.id)!.parentId, b.id);
      expect(find.byType(FolderRow), findsOneWidget, reason: 'the moved folder left the root list');
    });

    notesTest(h, 'a trashed folder is not offered as a destination', (tester) async {
      await open(tester);
      final NoteNode gone = await h.folder(tester, 'Gone');
      await h.folder(tester, 'Here');
      final NoteNode n = await h.note(tester, 'text');
      await h.run(tester, () => h.service.moveToTrash(gone.id));
      await swipe(tester, find.byType(NoteRow));
      await tester.tap(find.byKey(const ValueKey<String>('node-swipe-move')));
      await h.settle(tester);
      expect(find.byKey(ValueKey<String>('move-${gone.id}')), findsNothing);
      expect(find.text('Note “${n.name}”'), findsOneWidget);
    });
  });

  group('trash button', () {
    notesTest(h, 'shows the number of trashed nodes as a badge, none when empty', (tester) async {
      await open(tester);
      final NoteNode n = await h.note(tester, 'one');
      expect(find.descendant(of: find.byKey(const ValueKey<String>('notes-trash')), matching: find.text('1')), findsNothing);
      await h.run(tester, () => h.service.moveToTrash(n.id));
      expect(find.descendant(of: find.byKey(const ValueKey<String>('notes-trash')), matching: find.text('1')), findsOneWidget);
      expect(container(tester).read(trashCountProvider), 1);
    });
  });
}
