import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/core/notes/note_node.dart';
import 'package:questlog/core/notes/note_tree.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/services/notes/notes_service.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

void main() {
  late QuestlogDatabase db;
  late FixedClock clock;
  late NotesService service;
  final DateTime t0 = DateTime(2026, 11, 19, 10);

  setUp(() {
    db = createTestDatabase();
    clock = FixedClock(t0);
    service = NotesService(db, clock);
  });
  tearDown(() => db.close());

  Future<NoteTree> tree() async => NoteTree((await service.watchAll().first));
  Future<NoteNode> note(String body, {int? parent}) async =>
      (await service.saveBody(parentId: parent, body: body, untitledName: 'Bez názvu'))!;

  group('folders', () {
    test('createFolder trims the name and stores it in the parent', () async {
      final NoteNode a = await service.createFolder(name: '  ABAP ');
      final NoteNode b = await service.createFolder(parentId: a.id, name: 'Syntaxe');
      expect(a.name, 'ABAP');
      expect(a.isFolder, isTrue);
      expect(a.parentId, isNull);
      expect(b.parentId, a.id);
      expect(a.createdAt, t0);
    });

    test('invalid names are rejected, the same name twice is allowed', () async {
      expect(service.createFolder(name: '   '), throwsA(isA<ValidationError>()));
      expect(service.createFolder(name: 'x' * 81), throwsA(isA<ValidationError>()));
      await service.createFolder(name: 'Same');
      await service.createFolder(name: 'Same');
      expect((await tree()).children(null), hasLength(2));
    });

    test('a parent must be a visible folder', () async {
      final NoteNode n = await note('hello');
      final NoteNode f = await service.createFolder(name: 'F');
      await service.moveToTrash(f.id);
      expect(service.createFolder(parentId: n.id, name: 'x'), throwsA(isA<InvalidStateError>()));
      expect(service.createFolder(parentId: f.id, name: 'x'), throwsA(isA<InvalidStateError>()));
      expect(service.createFolder(parentId: 999, name: 'x'), throwsA(isA<NotFoundError>()));
    });
  });

  group('saveBody and names', () {
    test('the first save creates the note named after the first line', () async {
      final NoteNode n = await note('# Inline deklarace\n\nText');
      expect(n.name, 'Inline deklarace');
      expect(n.autoName, isTrue);
      expect(n.isFolder, isFalse);
      expect(n.createdAt, t0);
      expect(n.updatedAt, t0);
    });

    test('a blank new body creates nothing', () async {
      expect(await service.saveBody(body: '', untitledName: 'Bez názvu'), isNull);
      expect(await service.saveBody(body: ' \n\t ', untitledName: 'Bez názvu'), isNull);
      expect(await service.watchAll().first, isEmpty);
    });

    test('a body with no usable line gets the untitled name', () async {
      final NoteNode n = await note('---');
      expect(n.name, 'Bez názvu');
    });

    test('while autoName is on the name follows the text, rename ends it', () async {
      final NoteNode n = await note('First');
      clock.advance(const Duration(minutes: 5));
      final NoteNode edited = (await service.saveBody(id: n.id, body: '# Second', untitledName: 'Bez názvu'))!;
      expect(edited.name, 'Second');
      expect(edited.updatedAt, t0.add(const Duration(minutes: 5)));
      await service.rename(n.id, 'My name');
      final NoteNode again = (await service.saveBody(id: n.id, body: '# Third', untitledName: 'Bez názvu'))!;
      expect(again.name, 'My name');
      expect(again.autoName, isFalse);
      expect(again.body, '# Third');
    });

    test('an unchanged body changes nothing, a rename keeps updatedAt', () async {
      final NoteNode n = await note('Text');
      clock.advance(const Duration(hours: 1));
      final NoteNode same = (await service.saveBody(id: n.id, body: 'Text', untitledName: 'x'))!;
      expect(same.updatedAt, t0);
      await service.rename(n.id, 'Renamed');
      expect((await tree()).byId(n.id)!.updatedAt, t0);
    });

    test('a typed title becomes the name and ends the automatic name', () async {
      final NoteNode n = await note('First line\n\nText');
      clock.advance(const Duration(minutes: 1));
      final NoteNode titled =
          (await service.saveBody(id: n.id, body: 'First line\n\nText', untitledName: 'u', title: '  Moje poznámka  '))!;
      expect(titled.name, 'Moje poznámka');
      expect(titled.autoName, isFalse);
      expect(titled.updatedAt, t0.add(const Duration(minutes: 1)));
      // The text changes, the chosen name stays.
      final NoteNode edited =
          (await service.saveBody(id: n.id, body: '# Other', untitledName: 'u', title: 'Moje poznámka'))!;
      expect(edited.name, 'Moje poznámka');
      expect(edited.autoName, isFalse);
    });

    test('a null title leaves a chosen name alone', () async {
      final NoteNode n = await note('First');
      await service.saveBody(id: n.id, body: 'First', untitledName: 'u', title: 'Chosen');
      final NoteNode edited = (await service.saveBody(id: n.id, body: 'Second', untitledName: 'u'))!;
      expect(edited.name, 'Chosen');
      expect(edited.autoName, isFalse);
    });

    test('a cleared title restores the automatic name', () async {
      final NoteNode n = await note('First');
      await service.saveBody(id: n.id, body: 'Second line', untitledName: 'u', title: 'Chosen');
      final NoteNode cleared =
          (await service.saveBody(id: n.id, body: 'Second line', untitledName: 'Bez názvu', title: '   '))!;
      expect(cleared.name, 'Second line');
      expect(cleared.autoName, isTrue);
      final NoteNode blank =
          (await service.saveBody(id: n.id, body: '', untitledName: 'Bez názvu', title: ''))!;
      expect(blank.name, 'Bez názvu');
      expect(blank.autoName, isTrue);
    });

    test('a new note with only a title is created, one with nothing is not', () async {
      final NoteNode n = (await service.saveBody(body: '', untitledName: 'u', title: 'Jen název'))!;
      expect(n.name, 'Jen název');
      expect(n.body, '');
      expect(n.autoName, isFalse);
      expect(await service.saveBody(body: ' ', untitledName: 'u', title: '  '), isNull);
      expect(await service.watchAll().first, hasLength(1));
    });

    test('a title over 80 characters is rejected and nothing is written', () async {
      final NoteNode n = await note('Text');
      expect(
        service.saveBody(id: n.id, body: 'Changed', untitledName: 'u', title: 'x' * 81),
        throwsA(isA<ValidationError>()),
      );
      expect((await tree()).byId(n.id)!.body, 'Text');
      expect(service.saveBody(body: 'x', untitledName: 'u', title: 'x' * 81), throwsA(isA<ValidationError>()));
    });

    test('saving the same body and title twice writes nothing', () async {
      final NoteNode n = (await service.saveBody(body: 'Text', untitledName: 'u', title: 'Name'))!;
      clock.advance(const Duration(hours: 1));
      final NoteNode same = (await service.saveBody(id: n.id, body: 'Text', untitledName: 'u', title: 'Name'))!;
      expect(same.updatedAt, t0);
      expect(same, n);
    });

    test('a body over 100 000 characters is rejected, exactly 100 000 is kept', () async {
      expect(service.saveBody(body: 'x' * 100001, untitledName: 'u'), throwsA(isA<ValidationError>()));
      final NoteNode n = await note('a' * 100000);
      expect(n.body.length, 100000);
      expect(
        service.saveBody(id: n.id, body: 'ž' * 100001, untitledName: 'u'),
        throwsA(isA<ValidationError>()),
      );
    });

    test('saveBody rejects folders, trashed notes and unknown ids; a clean state is kept on error', () async {
      final NoteNode f = await service.createFolder(name: 'F');
      final NoteNode n = await note('x');
      await service.moveToTrash(n.id);
      expect(service.saveBody(id: f.id, body: 'x', untitledName: 'u'), throwsA(isA<InvalidStateError>()));
      expect(service.saveBody(id: n.id, body: 'y', untitledName: 'u'), throwsA(isA<InvalidStateError>()));
      expect(service.saveBody(id: 99, body: 'y', untitledName: 'u'), throwsA(isA<NotFoundError>()));
      expect((await tree()).byId(n.id)!.body, 'x');
    });
  });

  group('rename and move', () {
    test('rename validates and trims', () async {
      final NoteNode f = await service.createFolder(name: 'F');
      await service.rename(f.id, '  New ');
      expect((await tree()).byId(f.id)!.name, 'New');
      expect(service.rename(f.id, ' '), throwsA(isA<ValidationError>()));
      expect(service.rename(99, 'x'), throwsA(isA<NotFoundError>()));
    });

    test('move changes the parent only and keeps updatedAt', () async {
      final NoteNode a = await service.createFolder(name: 'A');
      final NoteNode b = await service.createFolder(name: 'B');
      final NoteNode n = await note('x', parent: a.id);
      clock.advance(const Duration(days: 2));
      await service.move(n.id, b.id);
      final NoteNode moved = (await tree()).byId(n.id)!;
      expect(moved.parentId, b.id);
      expect(moved.updatedAt, t0);
      await service.move(n.id, null);
      expect((await tree()).byId(n.id)!.parentId, isNull);
    });

    test('moves into itself, its subtree, a note, the current parent or the trash are rejected', () async {
      final NoteNode a = await service.createFolder(name: 'A');
      final NoteNode b = await service.createFolder(parentId: a.id, name: 'B');
      final NoteNode n = await note('x');
      final NoteNode trashed = await service.createFolder(name: 'T');
      await service.moveToTrash(trashed.id);
      for (final int? target in <int?>[a.id, b.id, n.id, trashed.id, 999]) {
        expect(service.move(a.id, target), throwsA(isA<InvalidStateError>()), reason: '$target');
      }
      expect(service.move(b.id, a.id), throwsA(isA<InvalidStateError>()));
      expect(service.move(999, null), throwsA(isA<NotFoundError>()));
      expect((await tree()).byId(a.id)!.parentId, isNull);
    });
  });

  group('trash', () {
    test('trashing a folder is one Trashed_Node, its content is hidden but not trashed', () async {
      final NoteNode f = await service.createFolder(name: 'F');
      final NoteNode g = await service.createFolder(parentId: f.id, name: 'G');
      final NoteNode n = await note('x', parent: g.id);
      clock.advance(const Duration(hours: 3));
      await service.moveToTrash(f.id);
      final NoteTree t = await tree();
      expect(t.trashEntries().map((e) => e.id), <int>[f.id]);
      expect(t.byId(f.id)!.deletedAt, t0.add(const Duration(hours: 3)));
      expect(t.isVisible(n.id), isFalse);
      expect(t.children(null), isEmpty);
    });

    test('moveToTrash rejects unknown, already trashed and hidden nodes', () async {
      final NoteNode f = await service.createFolder(name: 'F');
      final NoteNode n = await note('x', parent: f.id);
      await service.moveToTrash(f.id);
      expect(service.moveToTrash(f.id), throwsA(isA<NotFoundError>()));
      expect(service.moveToTrash(n.id), throwsA(isA<NotFoundError>()));
      expect(service.moveToTrash(99), throwsA(isA<NotFoundError>()));
    });

    test('restore goes to the old parent, or to the root when it is trashed or gone', () async {
      final NoteNode f = await service.createFolder(name: 'F');
      final NoteNode n = await note('x', parent: f.id);
      await service.moveToTrash(n.id);
      await service.restore(n.id);
      expect((await tree()).byId(n.id)!.parentId, f.id);
      expect((await tree()).byId(n.id)!.deletedAt, isNull);

      await service.moveToTrash(n.id);
      await service.moveToTrash(f.id);
      await service.restore(n.id);
      expect((await tree()).byId(n.id)!.parentId, isNull, reason: 'the old parent is trashed');
      expect((await tree()).isVisible(n.id), isTrue);

      final NoteNode g = await service.createFolder(name: 'G');
      final NoteNode m = await note('y', parent: g.id);
      await service.moveToTrash(m.id);
      await service.moveToTrash(g.id);
      await service.deleteForever(g.id);
      expect(await tree().then((t) => t.byId(m.id)), isNull, reason: 'cascade removed the inner trashed note');
    });

    test('a restored folder returns with its content', () async {
      final NoteNode f = await service.createFolder(name: 'F');
      await note('x', parent: f.id);
      await service.moveToTrash(f.id);
      await service.restore(f.id);
      expect((await tree()).noteCountDeep(f.id), 1);
      expect(service.restore(f.id), throwsA(isA<InvalidStateError>()));
    });

    test('deleteForever works only in the trash and removes the content', () async {
      final NoteNode f = await service.createFolder(name: 'F');
      await note('x', parent: f.id);
      expect(service.deleteForever(f.id), throwsA(isA<InvalidStateError>()));
      await service.moveToTrash(f.id);
      await service.deleteForever(f.id);
      expect(await service.watchAll().first, isEmpty);
      expect(service.deleteForever(f.id), throwsA(isA<NotFoundError>()));
    });

    test('emptyTrash removes every trashed node and reports how many', () async {
      final NoteNode a = await service.createFolder(name: 'A');
      await note('x', parent: a.id);
      final NoteNode b = await note('y');
      final NoteNode keep = await note('z');
      await service.moveToTrash(a.id);
      await service.moveToTrash(b.id);
      expect(await service.emptyTrash(), 2);
      expect((await service.watchAll().first).map((n) => n.id), <int>[keep.id]);
      expect(await service.emptyTrash(), 0);
    });
  });

  group('purge', () {
    test('removes a trashed node only once 30 days have passed', () async {
      final NoteNode n = await note('x');
      await service.moveToTrash(n.id);
      clock.advance(const Duration(days: 29, hours: 23));
      expect(await service.purgeExpired(), 0);
      expect(await service.watchAll().first, hasLength(1));
      clock.advance(const Duration(hours: 1));
      expect(await service.purgeExpired(), 1);
      expect(await service.watchAll().first, isEmpty);
    });

    test('a node trashed earlier than its folder is purged first, the rest later', () async {
      final NoteNode f = await service.createFolder(name: 'F');
      final NoteNode a = await note('a', parent: f.id);
      final NoteNode b = await note('b', parent: f.id);
      await service.moveToTrash(a.id);
      clock.advance(const Duration(days: 10));
      await service.moveToTrash(f.id);
      clock.advance(const Duration(days: 21));
      expect(await service.purgeExpired(), 1);
      expect((await service.watchAll().first).map((n) => n.id).toSet(), <int>{f.id, b.id});
      clock.advance(const Duration(days: 10));
      expect(await service.purgeExpired(), 1);
      expect(await service.watchAll().first, isEmpty);
    });

    test('never touches a visible node', () async {
      final NoteNode keep = await note('keep');
      final NoteNode gone = await note('gone');
      await service.moveToTrash(gone.id);
      clock.advance(const Duration(days: 400));
      await service.purgeExpired();
      expect((await service.watchAll().first).map((n) => n.id), <int>[keep.id]);
    });
  });

  test('no scenario changes Total_XP or the XP-bearing tables', () async {
    final AppStateRow before = await db.select(db.appState).getSingle();
    final NoteNode f = await service.createFolder(name: 'F');
    final NoteNode n = await note('# x', parent: f.id);
    await service.rename(n.id, 'y');
    await service.move(n.id, null);
    await service.moveToTrash(n.id);
    await service.restore(n.id);
    await service.moveToTrash(f.id);
    await service.emptyTrash();
    expect(await db.select(db.appState).getSingle(), before);
    expect(await db.select(db.quests).get(), isEmpty);
    expect(await db.select(db.missions).get(), isEmpty);
  });
}
