import 'dart:io';

/// Temporary palette switch: which colour set the app is drawn with. Removed
/// together with the switch once Martin has chosen.
enum PaletteChoice { original, highContrast, blue, green }

/// Keeps the [PaletteChoice] between launches. Deliberately outside the
/// database, so the temporary switch leaves no schema migration behind.
abstract interface class PaletteChoiceStore {
  Future<PaletteChoice> load();
  Future<void> save(PaletteChoice choice);
}

/// Stores the choice as one word in a small text file.
class FilePaletteChoiceStore implements PaletteChoiceStore {
  const FilePaletteChoiceStore(this._file);

  final File _file;

  @override
  Future<PaletteChoice> load() async {
    try {
      final String raw = (await _file.readAsString()).trim();
      return PaletteChoice.values.firstWhere(
        (PaletteChoice c) => c.name == raw,
        orElse: () => PaletteChoice.original,
      );
    } on FileSystemException {
      return PaletteChoice.original;
    }
  }

  @override
  Future<void> save(PaletteChoice choice) async {
    try {
      await _file.writeAsString(choice.name, flush: true);
    } on FileSystemException {
      // A temporary preference: failing to remember it is not worth a dialog.
    }
  }
}

/// Keeps the choice in memory only; the default in tests.
class MemoryPaletteChoiceStore implements PaletteChoiceStore {
  MemoryPaletteChoiceStore([this.value = PaletteChoice.original]);

  PaletteChoice value;

  @override
  Future<PaletteChoice> load() async => value;

  @override
  Future<void> save(PaletteChoice choice) async => value = choice;
}
