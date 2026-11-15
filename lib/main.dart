import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/clock.dart';
import 'data/database.dart';
import 'services/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens the on-device file database lazily on first query.
  final database = QuestlogDatabase();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(const SystemClock()),
      ],
      child: const QuestlogApp(),
    ),
  );
}
