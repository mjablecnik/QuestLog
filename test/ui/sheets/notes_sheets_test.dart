import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/notes/note_tree.dart';
import 'package:questlog/ui/sheets/notes/add_sheet.dart';
import 'package:questlog/ui/sheets/notes/link_sheet.dart';
import 'package:questlog/ui/sheets/notes/move_sheet.dart';
import 'package:questlog/ui/sheets/notes/name_sheet.dart';

import '../screens/notes/_notes_harness.dart';

/// Widget tests of AddSheet, NameSheet, MoveSheet and LinkSheet over the
/// in-memory database of the notes harness.
void main() {
  final NotesUiHarness h = NotesUiHarness();

  /// Mounts a button that opens a sheet and keeps what the sheet resolved to.
  Future<void> openSheet<T>(
    WidgetTester tester,
    Future<T?> Function(BuildContext context) show,
    void Function(T? result) onResult,
  ) async {
    await h.pump(
      tester,
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const ValueKey<String>('open'),
              onPressed: () async => onResult(await show(context)),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey<String>('open')));
    await h.settle(tester);
  }

  group('AddSheet', () {
    notesTest(h, 'names the place and returns the chosen kind', (tester) async {
      NewNodeKind? result;
      await openSheet<NewNodeKind>(
        tester,
        (BuildContext c) => showAddSheet(c, placeName: 'ABAP'),
        (NewNodeKind? r) => result = r,
      );
      expect(find.text('It will be created in ABAP'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('add-folder')));
      await h.settle(tester);
      expect(result, NewNodeKind.folder);
    });

    notesTest(h, 'the note choice returns note, Cancel returns nothing', (tester) async {
      NewNodeKind? result = NewNodeKind.note;
      bool answered = false;
      await openSheet<NewNodeKind>(
        tester,
        (BuildContext c) => showAddSheet(c, placeName: 'Notes'),
        (NewNodeKind? r) {
          result = r;
          answered = true;
        },
      );
      await tester.tap(find.text('Cancel'));
      await h.settle(tester);
      expect(answered, isTrue);
      expect(result, isNull);
      await tester.tap(find.byKey(const ValueKey<String>('open')));
      await h.settle(tester);
      await tester.tap(find.byKey(const ValueKey<String>('add-note')));
      await h.settle(tester);
      expect(result, NewNodeKind.note);
    });
  });

  group('NameSheet', () {
    notesTest(h, 'the button waits for a name, trims it, and Enter submits', (tester) async {
      String? result;
      await openSheet<String>(
        tester,
        (BuildContext c) => showNameSheet(c, title: 'New folder', primaryLabel: 'Create folder'),
        (String? r) => result = r,
      );
      await tester.tap(find.text('Create folder'));
      await h.settle(tester);
      expect(result, isNull, reason: 'disabled while empty');
      expect(find.text('Create folder'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), '  Ideas  ');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await h.settle(tester);
      expect(result, 'Ideas');
    });

    notesTest(h, 'a rename needs a different name', (tester) async {
      String? result;
      await openSheet<String>(
        tester,
        (BuildContext c) => showNameSheet(c, title: 'Rename', primaryLabel: 'Save', initial: 'Old'),
        (String? r) => result = r,
      );
      await tester.tap(find.text('Save'));
      await h.settle(tester);
      expect(result, isNull);
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), 'Old');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await h.settle(tester);
      expect(result, isNull, reason: 'the same name after trimming is still unchanged');
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), 'New');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await h.settle(tester);
      expect(result, 'New');
    });
  });

  group('MoveSheet', () {
    notesTest(h, 'returns the Root_Folder as a null target, told apart from a dismissed sheet', (tester) async {
      ({int? target})? result;
      bool answered = false;
      late NoteNode node;
      late NoteTree tree;
      await h.pump(
        tester,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: TextButton(
              key: const ValueKey<String>('open'),
              onPressed: () async {
                result = await showMoveSheet(context, tree: tree, node: node);
                answered = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
        seed: (service, clock) async {
          final NoteNode folder = await service.createFolder(name: 'Home');
          node = (await service.saveBody(parentId: folder.id, body: 'x', untitledName: 'u'))!;
          tree = NoteTree(await service.watchAll().first);
        },
      );
      await tester.tap(find.byKey(const ValueKey<String>('open')));
      await h.settle(tester);
      await tester.tap(find.byKey(const ValueKey<String>('move-root')));
      await tester.pump();
      await tester.tap(find.text('Move to Notes'));
      await h.settle(tester);
      expect(answered, isTrue);
      expect(result, isNotNull);
      expect(result!.target, isNull);
    });
  });

  group('LinkSheet', () {
    test('adds https:// only when there is no scheme', () {
      expect(normalizeLinkAddress('example.com/a'), 'https://example.com/a');
      expect(normalizeLinkAddress('  http://x.cz '), 'http://x.cz');
      expect(normalizeLinkAddress('mailto:me@example.com'), 'mailto:me@example.com');
    });

    notesTest(h, 'the button needs an address and returns it normalised', (tester) async {
      String? result;
      await openSheet<String>(
        tester,
        (BuildContext c) => showLinkSheet(c),
        (String? r) => result = r,
      );
      await tester.tap(find.text('Apply link'));
      await h.settle(tester);
      expect(result, isNull);
      await tester.enterText(find.byKey(const ValueKey<String>('link-field')), 'example.com');
      await tester.pump();
      await tester.tap(find.text('Apply link'));
      await h.settle(tester);
      expect(result, 'https://example.com');
    });
  });
}
