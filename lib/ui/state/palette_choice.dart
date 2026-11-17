import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/palette_choice_store.dart';

/// Where the palette choice is remembered; `main` swaps in the file store.
final paletteChoiceStoreProvider = Provider<PaletteChoiceStore>(
  (ref) => MemoryPaletteChoiceStore(),
);

/// The choice read at startup, so the first frame already has the right colours.
final initialPaletteChoiceProvider = Provider<PaletteChoice>(
  (ref) => PaletteChoice.original,
);

/// The palette the app is drawn with right now (temporary switch).
final paletteChoiceProvider =
    NotifierProvider<PaletteChoiceNotifier, PaletteChoice>(
      PaletteChoiceNotifier.new,
    );

class PaletteChoiceNotifier extends Notifier<PaletteChoice> {
  @override
  PaletteChoice build() => ref.watch(initialPaletteChoiceProvider);

  /// Applies [choice] to the whole app immediately, then remembers it.
  Future<void> select(PaletteChoice choice) async {
    state = choice;
    await ref.read(paletteChoiceStoreProvider).save(choice);
  }
}
