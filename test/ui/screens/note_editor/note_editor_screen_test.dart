import 'dart:ui' show CheckedState;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/notes/note_tree.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/services/notes/notes_service.dart';
import 'package:questlog/ui/screens/note_editor/note_editor_screen.dart';
import 'package:super_editor/super_editor.dart';

import '../../../helpers/fixed_clock.dart';
import '../notes/_notes_harness.dart';

/// A service whose first [failures] saves fail.
class FlakyNotesService extends NotesService {
  FlakyNotesService(super.db, super.clock, this.failures);

  int failures;

  @override
  Future<NoteNode?> saveBody({
    int? id,
    int? parentId,
    required String body,
    required String untitledName,
    String? title,
  }) {
    if (failures > 0) {
      failures--;
      throw StorageError(Exception('disk'));
    }
    return super.saveBody(id: id, parentId: parentId, body: body, untitledName: untitledName, title: title);
  }
}

void main() {
  final NotesUiHarness h = NotesUiHarness();

  /// Opens the editor on [noteId] (a note made by [seedBody] before the app is built).
  Future<void> open(
    WidgetTester tester, {
    String? seedBody,
    String? seedTitle,
    int? parentId,
    NotesService Function(QuestlogDatabase, FixedClock)? serviceBuilder,
  }) async {
    int? noteId;
    await h.pump(
      tester,
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const ValueKey<String>('go'),
              onPressed: () => openNoteEditor(context, noteId: noteId, parentId: parentId),
              child: const Text('go'),
            ),
          ),
        ),
      ),
      seed: seedBody == null
          ? null
          : (NotesService service, FixedClock clock) async {
              noteId = (await service.saveBody(body: seedBody, untitledName: 'u', title: seedTitle))!.id;
            },
      serviceBuilder: serviceBuilder,
    );
    await tester.tap(find.byKey(const ValueKey<String>('go')));
    await h.settle(tester);
    // An existing note is read from the database first: wait until the editor is built.
    for (int i = 0; i < 40 && find.byType(SuperEditor).evaluate().isEmpty; i++) {
      await h.settle(tester);
    }
  }

  Editor editorOf(WidgetTester tester) => tester.widget<SuperEditor>(find.byType(SuperEditor)).editor;
  MutableDocument docOf(WidgetTester tester) => editorOf(tester).context.document;

  Future<NoteTree> tree(WidgetTester tester) async =>
      NoteTree(await tester.runAsync(() => h.service.watchAll().first) ?? <NoteNode>[]);

  /// Puts the caret at the end of the last text node and types [text].
  Future<void> type(WidgetTester tester, String text) async {
    final MutableDocument doc = docOf(tester);
    final TextNode last = doc.last as TextNode;
    final DocumentPosition end = DocumentPosition(
      nodeId: last.id,
      nodePosition: TextNodePosition(offset: last.text.length),
    );
    editorOf(tester).execute(<EditRequest>[
      ChangeSelectionRequest(
        DocumentSelection.collapsed(position: end),
        SelectionChangeType.placeCaret,
        SelectionReason.userInteraction,
      ),
      InsertTextRequest(documentPosition: end, textToInsert: text, attributions: const <Attribution>{}),
    ]);
    await tester.pump();
  }

  Future<void> selectAll(WidgetTester tester) async {
    final MutableDocument doc = docOf(tester);
    final TextNode first = doc.first as TextNode;
    final TextNode last = doc.last as TextNode;
    editorOf(tester).execute(<EditRequest>[
      ChangeSelectionRequest(
        DocumentSelection(
          base: DocumentPosition(nodeId: first.id, nodePosition: const TextNodePosition(offset: 0)),
          extent: DocumentPosition(nodeId: last.id, nodePosition: TextNodePosition(offset: last.text.length)),
        ),
        SelectionChangeType.expandSelection,
        SelectionReason.userInteraction,
      ),
    ]);
    await tester.pump();
  }

  Future<void> tapFormat(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(ValueKey<String>('fmt-$key')));
    await tester.pump();
  }

  /// Lets the autosave timer fire and the write finish.
  Future<void> afterAutosave(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 600));
    await h.settle(tester);
  }

  Finder titleField() => find.byKey(const ValueKey<String>('note-title'));
  TextField titleWidget(WidgetTester tester) => tester.widget<TextField>(titleField());
  Future<NoteNode> theNote(WidgetTester tester) async => (await tree(tester)).all.firstWhere((n) => !n.isFolder);

  group('title field', () {
    notesTest(h, 'a new note shows a focused title field with a hint, above the text', (tester) async {
      await open(tester);
      expect(titleField(), findsOneWidget);
      expect(titleWidget(tester).focusNode!.hasFocus, isTrue);
      expect(find.text('Title'), findsOneWidget);
      expect(tester.getTopLeft(titleField()).dy, lessThan(tester.getTopLeft(find.byType(SuperEditor)).dy));
    });

    notesTest(h, 'the title is one line of at most 80 characters', (tester) async {
      await open(tester);
      expect(titleWidget(tester).maxLines, 1);
      await tester.enterText(titleField(), 'x' * 100);
      await tester.pump();
      expect(titleWidget(tester).controller!.text.length, 80);
    });

    notesTest(h, 'a typed title becomes the name, the text stays the text', (tester) async {
      await open(tester);
      await tester.enterText(titleField(), 'My note');
      await type(tester, 'Body text');
      await afterAutosave(tester);
      final NoteNode saved = await theNote(tester);
      expect(saved.name, 'My note');
      expect(saved.body, 'Body text');
      expect(saved.autoName, isFalse);
    });

    notesTest(h, 'a title alone creates the note', (tester) async {
      await open(tester);
      await tester.enterText(titleField(), 'Only a title');
      await afterAutosave(tester);
      final NoteNode saved = await theNote(tester);
      expect(saved.name, 'Only a title');
      expect(saved.body, isEmpty);
    });

    notesTest(h, 'return moves the focus to the text', (tester) async {
      await open(tester);
      await tester.enterText(titleField(), 'Name');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(titleWidget(tester).focusNode!.hasFocus, isFalse);
      expect(tester.widget<SuperEditor>(find.byType(SuperEditor)).focusNode!.hasFocus, isTrue);
      expect(editorOf(tester).composer.selection, isNotNull, reason: 'the caret is placed');
    });

    notesTest(h, 'opens with the chosen name, and empty while the name follows the text', (tester) async {
      await open(tester, seedBody: 'First line', seedTitle: 'Chosen');
      expect(titleWidget(tester).controller!.text, 'Chosen');
    });

    notesTest(h, 'an automatically named note opens with an empty title', (tester) async {
      await open(tester, seedBody: 'First line');
      expect(titleWidget(tester).controller!.text, isEmpty);
      expect(find.text('Title'), findsOneWidget);
    });

    notesTest(h, 'clearing the title gives the name back to the text', (tester) async {
      await open(tester, seedBody: 'First line', seedTitle: 'Chosen');
      await tester.enterText(titleField(), '');
      await afterAutosave(tester);
      final NoteNode saved = await theNote(tester);
      expect(saved.name, 'First line');
      expect(saved.autoName, isTrue);
    });

    notesTest(h, 'editing only the text keeps a chosen name', (tester) async {
      await open(tester, seedBody: 'First line', seedTitle: 'Chosen');
      await type(tester, ' more');
      await afterAutosave(tester);
      final NoteNode saved = await theNote(tester);
      expect(saved.name, 'Chosen');
      expect(saved.body, 'First line more');
    });

    notesTest(h, 'the text overlays keep the iOS caret, handles and toolbar anchor', (tester) async {
      await open(tester);
      final List<SuperEditorLayerBuilder> overlays = tester.widget<SuperEditor>(find.byType(SuperEditor)).documentOverlayBuilders;
      expect(overlays.whereType<SuperEditorIosHandlesDocumentLayerBuilder>(), isNotEmpty);
      expect(overlays.whereType<SuperEditorIosToolbarFocalPointDocumentLayerBuilder>(), isNotEmpty);
      expect(overlays.whereType<DefaultCaretOverlayBuilder>(), isNotEmpty);
    });
  });

  group('opening', () {
    notesTest(h, 'shows the stored Markdown formatted, without markers', (tester) async {
      await open(tester, seedBody: '# Title\n\nSome **bold** text\n\n- one\n- two\n\n- [ ] task');
      final MutableDocument doc = docOf(tester);
      final List<String> texts = <String>[for (final DocumentNode n in doc) (n as TextNode).text.toPlainText()];
      expect(texts, <String>['Title', 'Some bold text', 'one', 'two', 'task'], reason: 'no Markdown markers in the text');
      expect(doc.getNodeAt(0)!.getMetadataValue('blockType'), header1Attribution);
      expect(doc.getNodeAt(2), isA<ListItemNode>());
      expect(doc.getNodeAt(4), isA<TaskNode>());
      expect(find.byType(SuperEditor), findsOneWidget);
    });

    notesTest(h, 'is a full screen with back, menu and Done, and a hint while empty', (tester) async {
      await open(tester);
      expect(find.byKey(const ValueKey<String>('editor-back')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('node-menu')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('editor-done')), findsOneWidget);
      expect(find.text('Start writing…'), findsOneWidget);
    });
  });

  group('autosave', () {
    notesTest(h, 'saves after 500 ms of quiet, not before, and names the new note', (tester) async {
      await open(tester);
      await type(tester, 'Hello world');
      await tester.pump(const Duration(milliseconds: 400));
      expect((await tree(tester)).children(null), isEmpty, reason: 'not yet');
      await type(tester, '!');
      await tester.pump(const Duration(milliseconds: 400));
      expect((await tree(tester)).children(null), isEmpty, reason: 'the pause restarted');
      await afterAutosave(tester);
      final NoteNode saved = (await tree(tester)).children(null).single;
      expect(saved.body, 'Hello world!');
      expect(saved.name, 'Hello world!');
    });

    notesTest(h, 'Done saves at once and closes', (tester) async {
      await open(tester);
      await type(tester, 'Quick');
      await tester.tap(find.byKey(const ValueKey<String>('editor-done')));
      await h.settle(tester);
      expect((await tree(tester)).children(null).single.body, 'Quick');
    });

    notesTest(h, 'an empty new note creates nothing when it is left', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const ValueKey<String>('editor-back')));
      await h.settle(tester);
      expect(await tree(tester).then((t) => t.all), isEmpty);
    });

    notesTest(h, 'going to the background saves a pending change', (tester) async {
      await open(tester);
      await type(tester, 'Pending');
      // The text field checks the order of the lifecycle states, so walk them one by one.
      for (final AppLifecycleState state in <AppLifecycleState>[
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await h.settle(tester);
      expect((await tree(tester)).children(null).single.body, 'Pending');
      for (final AppLifecycleState state in <AppLifecycleState>[
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
    });

    notesTest(h, 'a second edit updates the same note', (tester) async {
      await open(tester);
      await type(tester, 'one');
      await afterAutosave(tester);
      await type(tester, ' two');
      await afterAutosave(tester);
      final NoteTree t = await tree(tester);
      expect(t.all, hasLength(1));
      expect(t.children(null).single.body, 'one two');
    });

    notesTest(h, 'a failed save keeps the text, shows the banner and the retry saves it', (tester) async {
      await open(
        tester,
        serviceBuilder: (QuestlogDatabase db, FixedClock clock) => FlakyNotesService(db, clock, 1),
      );
      await type(tester, 'Keep me');
      await afterAutosave(tester);
      expect(find.text('The note could not be saved.'), findsOneWidget);
      expect(find.text('Keep me', findRichText: true), findsOneWidget);
      expect((await tree(tester)).all, isEmpty);
      await tester.tap(find.byKey(const ValueKey<String>('editor-retry')));
      await h.settle(tester);
      expect(find.text('The note could not be saved.'), findsNothing);
      expect((await tree(tester)).children(null).single.body, 'Keep me');
    });

    notesTest(h, 'a note over 100 000 characters is not saved and the message appears', (tester) async {
      await open(tester);
      await type(tester, 'x' * 100001);
      await afterAutosave(tester);
      expect(find.text('The note is too long, at most 100,000 characters.'), findsOneWidget);
      expect((await tree(tester)).all, isEmpty);
    });
  });

  group('toolbar', () {
    notesTest(h, 'bold on a selection and on the next typed text', (tester) async {
      await open(tester);
      await type(tester, 'plain');
      await selectAll(tester);
      await tapFormat(tester, 'bold');
      await afterAutosave(tester);
      expect((await tree(tester)).children(null).single.body, '**plain**');
      await tapFormat(tester, 'bold');
      await afterAutosave(tester);
      expect((await tree(tester)).children(null).single.body, 'plain');
    });

    notesTest(h, 'italic, quote, list, checklist and code block toggle on and off', (tester) async {
      await open(tester);
      await type(tester, 'item');
      final Map<String, String> expected = <String, String>{
        'quote': '> item',
        'list': '- item',
        'checklist': '- [ ] item',
        'code': '```\nitem\n```',
      };
      for (final MapEntry<String, String> e in expected.entries) {
        await tapFormat(tester, e.key);
        await afterAutosave(tester);
        expect((await tree(tester)).children(null).single.body, e.value, reason: e.key);
        await tapFormat(tester, e.key);
        await afterAutosave(tester);
        expect((await tree(tester)).children(null).single.body, 'item', reason: '${e.key} off');
      }
      await selectAll(tester);
      await tapFormat(tester, 'italic');
      await afterAutosave(tester);
      expect((await tree(tester)).children(null).single.body, '*item*');
    });

    notesTest(h, 'the heading button cycles H1, H2, H3 and back to a paragraph', (tester) async {
      await open(tester);
      await type(tester, 'Title');
      final List<String> steps = <String>['# Title', '## Title', '### Title', 'Title'];
      for (final String step in steps) {
        await tapFormat(tester, 'heading');
        await afterAutosave(tester);
        expect((await tree(tester)).children(null).single.body, step);
      }
    });

    notesTest(h, 'a selection makes the code button inline', (tester) async {
      await open(tester);
      await type(tester, 'use x');
      await selectAll(tester);
      await tapFormat(tester, 'code');
      await afterAutosave(tester);
      expect((await tree(tester)).children(null).single.body, '`use x`');
    });

    notesTest(h, 'the link sheet applies a link to the selection', (tester) async {
      await open(tester);
      await type(tester, 'docs');
      await selectAll(tester);
      await tapFormat(tester, 'link');
      await h.settle(tester);
      await tester.enterText(find.byKey(const ValueKey<String>('link-field')), 'example.com/a');
      await tester.pump();
      await tester.tap(find.text('Apply link'));
      await h.settle(tester);
      await afterAutosave(tester);
      expect((await tree(tester)).children(null).single.body, '[docs](https://example.com/a)');
    });

    notesTest(h, 'the pressed state follows the caret', (tester) async {
      await open(tester);
      await type(tester, 'text');
      await selectAll(tester);
      await tapFormat(tester, 'bold');
      final Finder button = find.byKey(const ValueKey<String>('fmt-bold'));
      Semantics semantics() => tester.widget<Semantics>(find.ancestor(of: button, matching: find.byType(Semantics)).first);
      expect(semantics().properties.selected, isTrue);
      await tapFormat(tester, 'bold');
      expect(semantics().properties.selected, isFalse);
    });
  });

  group('checklist', () {
    notesTest(h, 'tapping the round check toggles the item and the Markdown follows', (tester) async {
      await open(tester, seedBody: '- [ ] first\n- [x] second');
      expect(find.byKey(const ValueKey<String>('task-check')), findsNWidgets(2));
      await tester.tap(find.byKey(const ValueKey<String>('task-check')).first);
      await tester.pump();
      await afterAutosave(tester);
      final NoteNode saved = (await tree(tester)).all.firstWhere((n) => !n.isFolder);
      expect(saved.body, '- [x] first\n- [x] second');
      final SemanticsHandle handle = tester.ensureSemantics();
      final SemanticsNode node = tester.getSemantics(find.byKey(const ValueKey<String>('task-check')).first);
      expect(node.label, 'Toggle done');
      expect(node.getSemanticsData().flagsCollection.isChecked, isNot(CheckedState.none));
      handle.dispose();
    });
  });

  group('menu', () {
    notesTest(h, 'is disabled until the note exists', (tester) async {
      await open(tester);
      final PopupMenuButton<dynamic> menu = tester.widget(find.byKey(const ValueKey<String>('node-menu')));
      expect(menu.enabled, isFalse);
      await type(tester, 'Saved');
      await afterAutosave(tester);
      final PopupMenuButton<dynamic> after = tester.widget(find.byKey(const ValueKey<String>('node-menu')));
      expect(after.enabled, isTrue);
    });

    notesTest(h, 'rename, move and trash work on the open note; trash closes the editor', (tester) async {
      await open(tester, seedBody: 'Menu note');
      final NoteNode target = await h.folder(tester, 'Target');
      Future<void> choose(String label) async {
        await tester.tap(find.byKey(const ValueKey<String>('node-menu')));
        await h.settle(tester);
        await tester.tap(find.text(label).last);
        await h.settle(tester);
      }

      await choose('Rename');
      await tester.enterText(find.byKey(const ValueKey<String>('name-field')), 'Renamed');
      await tester.pump();
      await tester.tap(find.text('Save'));
      await h.settle(tester);
      NoteNode note = (await tree(tester)).all.firstWhere((n) => !n.isFolder);
      expect(note.name, 'Renamed');
      expect(titleWidget(tester).controller!.text, 'Renamed', reason: 'the title field follows the rename');

      await choose('Move');
      await tester.tap(find.byKey(ValueKey<String>('move-${target.id}')));
      await tester.pump();
      await tester.tap(find.text('Move to Target'));
      await h.settle(tester);
      note = (await tree(tester)).all.firstWhere((n) => !n.isFolder);
      expect(note.parentId, target.id);
      expect(find.text('Target'), findsWidgets, reason: 'the back button names the new folder');

      await choose('Move to Trash');
      expect(find.byType(NoteEditorScreen), findsNothing);
      note = (await tree(tester)).all.firstWhere((n) => !n.isFolder);
      expect(note.deletedAt, isNotNull);
    });
  });
}
