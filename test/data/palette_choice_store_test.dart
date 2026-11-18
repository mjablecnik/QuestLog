import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:questlog/data/palette_choice_store.dart';
import 'package:questlog/ui/state/palette_choice.dart';

void main() {
  late Directory directory;
  late File file;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('questlog_palette_');
    file = File(p.join(directory.path, 'palette_choice.txt'));
  });

  tearDown(() => directory.deleteSync(recursive: true));

  group('FilePaletteChoiceStore', () {
    test('defaults to the original palette when nothing is stored', () async {
      expect(await FilePaletteChoiceStore(file).load(), PaletteChoice.original);
    });

    test('round-trips every choice', () async {
      for (final PaletteChoice choice in PaletteChoice.values) {
        await FilePaletteChoiceStore(file).save(choice);
        expect(await FilePaletteChoiceStore(file).load(), choice);
      }
    });

    test('falls back to the original palette on unknown content', () async {
      file.writeAsStringSync('neon');
      expect(await FilePaletteChoiceStore(file).load(), PaletteChoice.original);
    });

    test('keeps reading the values stored by the two-palette switch', () async {
      file.writeAsStringSync('highContrast');
      expect(
        await FilePaletteChoiceStore(file).load(),
        PaletteChoice.highContrast,
      );
      file.writeAsStringSync('original\n');
      expect(await FilePaletteChoiceStore(file).load(), PaletteChoice.original);
    });

    test('reads the new palettes by name', () async {
      file.writeAsStringSync('blue');
      expect(await FilePaletteChoiceStore(file).load(), PaletteChoice.blue);
      file.writeAsStringSync('green');
      expect(await FilePaletteChoiceStore(file).load(), PaletteChoice.green);
    });

    test('does not throw when the file cannot be written', () async {
      final store = FilePaletteChoiceStore(
        File(p.join(directory.path, 'missing', 'palette_choice.txt')),
      );
      await store.save(PaletteChoice.highContrast);
      expect(await store.load(), PaletteChoice.original);
    });
  });

  group('paletteChoiceProvider', () {
    test('starts as the original palette', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(paletteChoiceProvider), PaletteChoice.original);
    });

    test('starts from the value loaded at launch', () {
      final container = ProviderContainer(
        overrides: [
          initialPaletteChoiceProvider.overrideWithValue(
            PaletteChoice.highContrast,
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(paletteChoiceProvider), PaletteChoice.highContrast);
    });

    test('select updates the state and stores the choice', () async {
      final store = MemoryPaletteChoiceStore();
      final container = ProviderContainer(
        overrides: [paletteChoiceStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      await container
          .read(paletteChoiceProvider.notifier)
          .select(PaletteChoice.highContrast);

      expect(container.read(paletteChoiceProvider), PaletteChoice.highContrast);
      expect(store.value, PaletteChoice.highContrast);
    });
  });
}
