import '../../core/cadence.dart';
import '../../core/calendar/event_type.dart';
import '../../core/calendar/repeat_rule.dart';

/// One built-in all-day event: a Czech public holiday, notable or folk day, or
/// name day. The names are stored in Czech whatever the app language.
class SeedEvent {
  const SeedEvent(this.name, this.type, this.start, this.repeat, {required this.onBoard});

  /// Repeats every year on [month] and [day], from January [startYear].
  SeedEvent.yearly(
    this.name,
    this.type,
    int month,
    int day, {
    int startYear = 2000,
    required this.onBoard,
  }) : start = DateTime(startYear, month, day),
       repeat = const CadenceRepeat(Cadence.yearly);

  /// Repeats every year [offsetDays] from Easter Sunday, from January [startYear].
  SeedEvent.easter(this.name, this.type, int offsetDays, {int startYear = 2000})
    : start = DateTime(startYear, 1, 1),
      repeat = EasterRelative(offsetDays),
      onBoard = false;

  /// Repeats every year on the [ordinal]-th [weekday] of [month], from 2000.
  SeedEvent.nth(this.name, this.type, int month, int weekday, int ordinal)
    : start = DateTime(2000, 1, 1),
      repeat = NthWeekday(month: month, weekday: weekday, ordinal: ordinal),
      onBoard = false;

  final String name;
  final EventType type;
  final DateTime start;
  final RepeatRule repeat;
  final bool onBoard;
}

/// The 13 Czech public holidays (days off), all off the Board.
final List<SeedEvent> czechPublicHolidays = <SeedEvent>[
  SeedEvent.yearly('Nový rok', EventType.publicHoliday, 1, 1, onBoard: false),
  SeedEvent.easter('Velký pátek', EventType.publicHoliday, -2, startYear: 2016),
  SeedEvent.easter('Velikonoční pondělí', EventType.publicHoliday, 1),
  SeedEvent.yearly('Svátek práce', EventType.publicHoliday, 5, 1, onBoard: false),
  SeedEvent.yearly('Den vítězství', EventType.publicHoliday, 5, 8, onBoard: false),
  SeedEvent.yearly('Den slovanských věrozvěstů Cyrila a Metoděje', EventType.publicHoliday, 7, 5, onBoard: false),
  SeedEvent.yearly('Den upálení mistra Jana Husa', EventType.publicHoliday, 7, 6, onBoard: false),
  SeedEvent.yearly('Den české státnosti', EventType.publicHoliday, 9, 28, onBoard: false),
  SeedEvent.yearly('Den vzniku samostatného československého státu', EventType.publicHoliday, 10, 28, onBoard: false),
  SeedEvent.yearly('Den boje za svobodu a demokracii', EventType.publicHoliday, 11, 17, onBoard: false),
  SeedEvent.yearly('Štědrý den', EventType.publicHoliday, 12, 24, onBoard: false),
  SeedEvent.yearly('1. svátek vánoční', EventType.publicHoliday, 12, 25, onBoard: false),
  SeedEvent.yearly('2. svátek vánoční', EventType.publicHoliday, 12, 26, onBoard: false),
];

/// The 16 notable and folk days, all off the Board.
final List<SeedEvent> czechNotableDays = <SeedEvent>[
  SeedEvent.yearly('Valentýn', EventType.notableDay, 2, 14, onBoard: false),
  SeedEvent.yearly('Mezinárodní den žen', EventType.notableDay, 3, 8, onBoard: false),
  SeedEvent.yearly('Apríl', EventType.notableDay, 4, 1, onBoard: false),
  SeedEvent.yearly('Den Země', EventType.notableDay, 4, 22, onBoard: false),
  SeedEvent.yearly('Pálení čarodějnic', EventType.notableDay, 4, 30, onBoard: false),
  SeedEvent.yearly('Den dětí', EventType.notableDay, 6, 1, onBoard: false),
  SeedEvent.yearly('Halloween', EventType.notableDay, 10, 31, onBoard: false),
  SeedEvent.yearly('Dušičky', EventType.notableDay, 11, 2, onBoard: false),
  SeedEvent.yearly('Svatý Martin', EventType.notableDay, 11, 11, onBoard: false),
  SeedEvent.yearly('Mikuláš', EventType.notableDay, 12, 5, onBoard: false),
  SeedEvent.yearly('Silvestr', EventType.notableDay, 12, 31, onBoard: false),
  SeedEvent.easter('Zelený čtvrtek', EventType.notableDay, -3),
  SeedEvent.easter('Bílá sobota', EventType.notableDay, -1),
  SeedEvent.easter('Velikonoční neděle', EventType.notableDay, 0),
  SeedEvent.nth('Den matek', EventType.notableDay, 5, DateTime.sunday, 2),
  SeedEvent.nth('Den otců', EventType.notableDay, 6, DateTime.sunday, 3),
];

/// The 6 name days, on the Board (to wish someone happy name day).
final List<SeedEvent> czechNameDays = <SeedEvent>[
  SeedEvent.yearly('Veronika', EventType.nameDay, 2, 7, onBoard: true),
  SeedEvent.yearly('Iveta', EventType.nameDay, 6, 7, onBoard: true),
  SeedEvent.yearly('Jindřich', EventType.nameDay, 7, 15, onBoard: true),
  SeedEvent.yearly('Luboš', EventType.nameDay, 7, 16, onBoard: true),
  SeedEvent.yearly('Michala', EventType.nameDay, 10, 19, onBoard: true),
  SeedEvent.yearly('Jitka', EventType.nameDay, 12, 5, onBoard: true),
];

/// Everything the seed inserts: 13 + 16 + 6 = 35 events.
List<SeedEvent> get calendarSeedEvents => <SeedEvent>[
  ...czechPublicHolidays,
  ...czechNotableDays,
  ...czechNameDays,
];
