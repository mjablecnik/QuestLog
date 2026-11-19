import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/clock.dart';
import 'core/font_licenses.dart';
import 'data/calendar/calendar_filter_store.dart';
import 'data/database.dart';
import 'data/palette_choice_store.dart';
import 'services/calendar/calendar_providers.dart';
import 'services/providers.dart';
import 'ui/state/palette_choice.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  // Opens the on-device file database lazily on first query.
  final database = QuestlogDatabase();
  final directory = await getApplicationDocumentsDirectory();
  final paletteStore = FilePaletteChoiceStore(
    File(p.join(directory.path, 'palette_choice.txt')),
  );
  final paletteChoice = await paletteStore.load();
  final calendarFilterStore = FileCalendarFilterStore(
    File(p.join(directory.path, 'calendar_filter.txt')),
  );
  final calendarFilter = await calendarFilterStore.load();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(const SystemClock()),
        paletteChoiceStoreProvider.overrideWithValue(paletteStore),
        initialPaletteChoiceProvider.overrideWithValue(paletteChoice),
        calendarFilterStoreProvider.overrideWithValue(calendarFilterStore),
        initialCalendarFilterProvider.overrideWithValue(calendarFilter),
      ],
      child: const QuestlogApp(),
    ),
  );
}
