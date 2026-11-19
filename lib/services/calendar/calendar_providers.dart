import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calendar/event_type.dart';
import '../../data/calendar/calendar_filter_store.dart';
import '../providers.dart';
import 'calendar_service.dart';

final calendarServiceProvider = Provider<CalendarService>(
  (ref) => CalendarService(
    ref.watch(databaseProvider),
    ref.watch(xpEngineProvider),
    ref.watch(clockProvider),
  ),
);

/// Where the Type_Filter is remembered; `main` swaps in the file store.
final calendarFilterStoreProvider = Provider<CalendarFilterStore>(
  (ref) => MemoryCalendarFilterStore(),
);

/// The filter read at startup, so the first frame already respects it.
final initialCalendarFilterProvider = Provider<Set<EventType>>(
  (ref) => EventType.values.toSet(),
);
