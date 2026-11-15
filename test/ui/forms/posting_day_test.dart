import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:questlog/core/cadence.dart';
import 'package:questlog/core/xp_rules.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/services/recurrence_service.dart';
import 'package:questlog/ui/forms/posting_day.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/generators.dart';
import '../../helpers/test_database.dart';

DateTime d(int year, int month, int day) => DateTime(year, month, day);

int lastDayOf(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

/// The posting day a user picks on [pick], valid for [cadence].
PostingDay postingDayFor(Cadence cadence, DateTime pick) => switch (cadence) {
  Cadence.daily => const NoPostingDay(),
  Cadence.weekly || Cadence.biweekly => WeekdayPostingDay(pick.weekday),
  Cadence.monthly => MonthDayPostingDay(pick.day % 28 + 1),
  Cadence.quarterly || Cadence.yearly => DatePostingDay(pick),
};

/// Whether [date] lies in the series [day] describes.
///
/// Date days match on the day of the month and the month class (month mod 3 for
/// Quarterly, the month for Yearly) only, so the date a user picked may differ
/// from the anchor by whole periods. A day past the end of the anchor's month is
/// clamped to the last day, like the domain does.
bool matches(Cadence cadence, PostingDay day, DateTime date) {
  switch (day) {
    case NoPostingDay():
      return cadence == Cadence.daily;
    case WeekdayPostingDay():
      return date.weekday == day.weekday;
    case MonthDayPostingDay():
      return date.day == day.day;
    case DatePostingDay():
      final sameMonthClass = cadence == Cadence.yearly
          ? date.month == day.date.month
          : date.month % 3 == day.date.month % 3;
      final clamped = day.date.day < lastDayOf(date)
          ? day.date.day
          : lastDayOf(date);
      return sameMonthClass && date.day == clamped;
  }
}

/// Whether [actual] and [expected] are the same posting day, where a Date day
/// may appear clamped to a shorter month (31 -> 30, 29 -> 28).
bool samePostingDay(Cadence cadence, PostingDay actual, PostingDay expected) {
  if (actual is DatePostingDay && expected is DatePostingDay) {
    return matches(cadence, expected, actual.date);
  }
  return actual == expected;
}

/// The date one period of [cadence] after [today], without clamping (a day that
/// does not exist rolls over), so "less than one period" is a strict bound.
DateTime periodAfter(Cadence cadence, DateTime today) => switch (cadence) {
  Cadence.daily => d(today.year, today.month, today.day + 1),
  Cadence.weekly => d(today.year, today.month, today.day + 7),
  Cadence.biweekly => d(today.year, today.month, today.day + 14),
  Cadence.monthly => d(today.year, today.month + 1, today.day),
  Cadence.quarterly => d(today.year, today.month + 3, today.day),
  Cadence.yearly => d(today.year + 1, today.month, today.day),
};

/// Everything Property 3 says about one (cadence, posting day, today) triple.
void expectValidRequestedAnchor(
  Cadence cadence,
  PostingDay day,
  DateTime today,
) {
  final context = '$cadence $day today=$today';
  final anchor = requestedAnchor(cadence, day, today);

  expect(
    anchor,
    d(anchor.year, anchor.month, anchor.day),
    reason: 'date only: $context',
  );
  expect(
    anchor.isBefore(d(today.year, today.month, today.day)),
    isFalse,
    reason: 'on or after today: $context',
  );
  expect(
    anchor.isBefore(periodAfter(cadence, today)),
    isTrue,
    reason: 'less than one period later: $context',
  );
  expect(
    matches(cadence, day, anchor),
    isTrue,
    reason: 'matches the posting day: $context',
  );
  expect(
    samePostingDay(cadence, postingDayOf(cadence, anchor), day),
    isTrue,
    reason: 'postingDayOf is the inverse: $context',
  );
  // Feeding the derived posting day back in lands on the same date.
  expect(
    requestedAnchor(cadence, postingDayOf(cadence, anchor), today),
    anchor,
    reason: 'idempotent: $context',
  );
}

void main() {
  final anyCadence = any.choose(Cadence.values);

  group('Property 3: posting day yields a valid requested anchor', () {
    Glados3(
      anyCadence,
      anyCalendarDate,
      anyCalendarDate,
      ExploreConfig(numRuns: 600),
    ).test('any cadence, valid posting day and today', (cadence, today, pick) {
      expectValidRequestedAnchor(cadence, postingDayFor(cadence, pick), today);
    });

    Glados3(
      anyCadence,
      anyCalendarDate,
      anyCalendarDate,
      ExploreConfig(numRuns: 300),
    ).test('a time of day on today changes nothing', (cadence, today, pick) {
      final day = postingDayFor(cadence, pick);
      expect(
        requestedAnchor(
          cadence,
          day,
          DateTime(today.year, today.month, today.day, 3, 59, 59),
        ),
        requestedAnchor(cadence, day, today),
      );
    });

    // The same posting day derived from any stored Anchor_Date (also one in the
    // past, after the rule has posted a few times) stays in its own series.
    Glados3(
      anyCadence,
      anyCalendarDate,
      anyCalendarDate,
      ExploreConfig(numRuns: 600),
    ).test('postingDayOf then requestedAnchor stays in the stored series', (
      cadence,
      today,
      stored,
    ) {
      final anchor = cadence == Cadence.monthly
          ? d(stored.year, stored.month, stored.day % 28 + 1)
          : stored;
      final day = postingDayOf(cadence, anchor);
      expectValidRequestedAnchor(cadence, day, today);
      expect(matches(cadence, day, anchor), isTrue);
    });

    test(
      'every day of a leap and a non-leap year, tricky dates, all cadences',
      () {
        final picks = [
          d(2024, 2, 29),
          d(2023, 2, 28),
          d(2026, 1, 31),
          d(2026, 3, 31),
          d(2026, 4, 30),
          d(2026, 12, 31),
          d(2026, 1, 1),
          d(2026, 11, 15),
          d(2027, 6, 28),
        ];
        for (final year in [2027, 2028]) {
          for (var offset = 0; offset < 366; offset++) {
            final today = d(year, 1, 1 + offset);
            for (final cadence in Cadence.values) {
              for (final pick in picks) {
                expectValidRequestedAnchor(
                  cadence,
                  postingDayFor(cadence, pick),
                  today,
                );
              }
            }
          }
        }
      },
    );
  });

  group('examples', () {
    test('Daily is today, whatever the time of day', () {
      expect(
        requestedAnchor(
          Cadence.daily,
          const NoPostingDay(),
          DateTime(2026, 11, 15, 22, 30),
        ),
        d(2026, 11, 15),
      );
    });

    test('a Weekly weekday equal to today gives today', () {
      final today = d(2026, 11, 15); // Sunday
      expect(today.weekday, DateTime.sunday);
      expect(
        requestedAnchor(
          Cadence.weekly,
          const WeekdayPostingDay(DateTime.sunday),
          today,
        ),
        today,
      );
      expect(
        requestedAnchor(
          Cadence.biweekly,
          const WeekdayPostingDay(DateTime.sunday),
          today,
        ),
        today,
      );
    });

    test('Weekly weekdays count forward, within seven days', () {
      final today = d(2026, 11, 15); // Sunday
      expect(
        requestedAnchor(
          Cadence.weekly,
          const WeekdayPostingDay(DateTime.monday),
          today,
        ),
        d(2026, 11, 16),
      );
      expect(
        requestedAnchor(
          Cadence.weekly,
          const WeekdayPostingDay(DateTime.saturday),
          today,
        ),
        d(2026, 11, 21),
      );
    });

    test('Weekly wraps over the end of the year', () {
      final today = d(2026, 12, 31); // Thursday
      expect(today.weekday, DateTime.thursday);
      expect(
        requestedAnchor(
          Cadence.weekly,
          const WeekdayPostingDay(DateTime.wednesday),
          today,
        ),
        d(2027, 1, 6),
      );
      expect(
        requestedAnchor(
          Cadence.biweekly,
          const WeekdayPostingDay(DateTime.friday),
          today,
        ),
        d(2027, 1, 1),
      );
    });

    test('Monthly day 28 works in every month, including February', () {
      const day = MonthDayPostingDay(28);
      expect(
        requestedAnchor(Cadence.monthly, day, d(2026, 11, 15)),
        d(2026, 11, 28),
      );
      expect(
        requestedAnchor(Cadence.monthly, day, d(2026, 11, 29)),
        d(2026, 12, 28),
      );
      expect(
        requestedAnchor(Cadence.monthly, day, d(2027, 1, 29)),
        d(2027, 2, 28),
      );
      expect(
        requestedAnchor(Cadence.monthly, day, d(2026, 12, 31)),
        d(2027, 1, 28),
      );
    });

    test('Monthly day equal to today gives today; an earlier day waits for next month', () {
      expect(
        requestedAnchor(
          Cadence.monthly,
          const MonthDayPostingDay(15),
          d(2026, 11, 15),
        ),
        d(2026, 11, 15),
      );
      expect(
        requestedAnchor(
          Cadence.monthly,
          const MonthDayPostingDay(1),
          d(2026, 11, 15),
        ),
        d(2026, 12, 1),
      );
      expect(
        requestedAnchor(
          Cadence.monthly,
          const MonthDayPostingDay(1),
          d(2026, 12, 15),
        ),
        d(2027, 1, 1),
      );
    });

    test('Yearly Feb 29 picked on a leap day: leap year today', () {
      final day = DatePostingDay(d(2028, 2, 29));
      expect(
        requestedAnchor(Cadence.yearly, day, d(2028, 1, 10)),
        d(2028, 2, 29),
      );
      expect(
        requestedAnchor(Cadence.yearly, day, d(2028, 2, 29)),
        d(2028, 2, 29),
      );
      // Past the leap day: next year has no Feb 29, the anchor lands on Feb 28.
      expect(
        requestedAnchor(Cadence.yearly, day, d(2028, 3, 1)),
        d(2029, 2, 28),
      );
    });

    test('Yearly Feb 29 picked on a leap day: non-leap year today', () {
      final day = DatePostingDay(d(2028, 2, 29));
      expect(
        requestedAnchor(Cadence.yearly, day, d(2027, 1, 10)),
        d(2027, 2, 28),
      );
      expect(
        requestedAnchor(Cadence.yearly, day, d(2027, 2, 28)),
        d(2027, 2, 28),
      );
      expect(
        requestedAnchor(Cadence.yearly, day, d(2027, 2, 27)),
        d(2027, 2, 28),
      );
      expect(
        requestedAnchor(Cadence.yearly, day, d(2027, 3, 1)),
        d(2028, 2, 29),
      );
    });

    test('Yearly uses the picked month and day from any year and wraps the year end', () {
      final day = DatePostingDay(d(1999, 1, 5));
      expect(
        requestedAnchor(Cadence.yearly, day, d(2026, 11, 15)),
        d(2027, 1, 5),
      );
      expect(
        requestedAnchor(Cadence.yearly, day, d(2027, 1, 5)),
        d(2027, 1, 5),
      );
      expect(
        requestedAnchor(
          Cadence.yearly,
          DatePostingDay(d(2040, 12, 31)),
          d(2026, 12, 31),
        ),
        d(2026, 12, 31),
      );
    });

    test(
      'Quarterly keeps the day and the month class, within three months',
      () {
        final day = DatePostingDay(d(2026, 2, 10)); // months 2, 5, 8, 11
        expect(
          requestedAnchor(Cadence.quarterly, day, d(2026, 11, 15)),
          d(2027, 2, 10),
        );
        expect(
          requestedAnchor(Cadence.quarterly, day, d(2026, 11, 10)),
          d(2026, 11, 10),
        );
        expect(
          requestedAnchor(Cadence.quarterly, day, d(2026, 11, 1)),
          d(2026, 11, 10),
        );
        expect(
          requestedAnchor(Cadence.quarterly, day, d(2026, 12, 1)),
          d(2027, 2, 10),
        );
        expect(
          requestedAnchor(Cadence.quarterly, day, d(2027, 2, 11)),
          d(2027, 5, 10),
        );
      },
    );

    test('Quarterly clamps a long day to the month length', () {
      final day = DatePostingDay(d(2026, 1, 31)); // months 1, 4, 7, 10
      expect(
        requestedAnchor(Cadence.quarterly, day, d(2026, 2, 1)),
        d(2026, 4, 30),
      );
      expect(
        requestedAnchor(Cadence.quarterly, day, d(2026, 5, 1)),
        d(2026, 7, 31),
      );
      expect(
        requestedAnchor(Cadence.quarterly, day, d(2026, 12, 1)),
        d(2027, 1, 31),
      );
    });

    test('a picked date in the future or the past works the same', () {
      expect(
        requestedAnchor(
          Cadence.yearly,
          DatePostingDay(d(2031, 11, 20)),
          d(2026, 11, 15),
        ),
        d(2026, 11, 20),
      );
      expect(
        requestedAnchor(
          Cadence.yearly,
          DatePostingDay(d(2001, 11, 20)),
          d(2026, 11, 15),
        ),
        d(2026, 11, 20),
      );
    });

    test('a posting day of the wrong kind or out of range is rejected', () {
      final today = d(2026, 11, 15);
      expect(
        () => requestedAnchor(Cadence.daily, const WeekdayPostingDay(1), today),
        throwsArgumentError,
      );
      expect(
        () => requestedAnchor(Cadence.weekly, const NoPostingDay(), today),
        throwsArgumentError,
      );
      expect(
        () => requestedAnchor(Cadence.monthly, DatePostingDay(today), today),
        throwsArgumentError,
      );
      expect(
        () =>
            requestedAnchor(Cadence.yearly, const MonthDayPostingDay(3), today),
        throwsArgumentError,
      );
    });

    test('postingDayOf', () {
      final anchor = d(2026, 11, 15); // Sunday
      expect(postingDayOf(Cadence.daily, anchor), const NoPostingDay());
      expect(
        postingDayOf(Cadence.weekly, anchor),
        const WeekdayPostingDay(DateTime.sunday),
      );
      expect(
        postingDayOf(Cadence.biweekly, anchor),
        const WeekdayPostingDay(DateTime.sunday),
      );
      expect(
        postingDayOf(Cadence.monthly, anchor),
        const MonthDayPostingDay(15),
      );
      expect(postingDayOf(Cadence.quarterly, anchor), DatePostingDay(anchor));
      expect(
        postingDayOf(Cadence.yearly, DateTime(2026, 11, 15, 13)),
        DatePostingDay(anchor),
      );
    });

    test('defaultPostingDay', () {
      final today = DateTime(2026, 11, 15, 9, 30); // Sunday
      expect(defaultPostingDay(Cadence.daily, today), const NoPostingDay());
      expect(
        defaultPostingDay(Cadence.weekly, today),
        const WeekdayPostingDay(DateTime.sunday),
      );
      expect(
        defaultPostingDay(Cadence.biweekly, today),
        const WeekdayPostingDay(DateTime.sunday),
      );
      expect(
        defaultPostingDay(Cadence.monthly, today),
        const MonthDayPostingDay(15),
      );
      expect(
        defaultPostingDay(Cadence.monthly, d(2026, 10, 31)),
        const MonthDayPostingDay(28),
      );
      expect(
        defaultPostingDay(Cadence.monthly, d(2026, 10, 28)),
        const MonthDayPostingDay(28),
      );
      expect(
        defaultPostingDay(Cadence.quarterly, today),
        DatePostingDay(d(2026, 11, 15)),
      );
      expect(
        defaultPostingDay(Cadence.yearly, today),
        DatePostingDay(d(2026, 11, 15)),
      );
    });

    test('a default posting day requests today for Daily, Weekly, Monthly (when <= 28) and dates', () {
      for (final today in [d(2026, 11, 15), d(2028, 2, 29), d(2026, 12, 31)]) {
        for (final cadence in Cadence.values) {
          final anchor = requestedAnchor(
            cadence,
            defaultPostingDay(cadence, today),
            today,
          );
          if (cadence == Cadence.monthly && today.day > 28) continue;
          expect(anchor, today, reason: '$cadence $today');
        }
      }
    });

    test('value equality, hashCode and toString', () {
      expect(const NoPostingDay(), const NoPostingDay());
      expect(const NoPostingDay().hashCode, const NoPostingDay().hashCode);
      expect(const WeekdayPostingDay(3), const WeekdayPostingDay(3));
      expect(
        const WeekdayPostingDay(3).hashCode,
        const WeekdayPostingDay(3).hashCode,
      );
      expect(const WeekdayPostingDay(3), isNot(const WeekdayPostingDay(4)));
      expect(const MonthDayPostingDay(3), isNot(const WeekdayPostingDay(3)));
      expect(const MonthDayPostingDay(3), const MonthDayPostingDay(3));
      expect(
        const MonthDayPostingDay(3).hashCode,
        const MonthDayPostingDay(3).hashCode,
      );
      expect(
        DatePostingDay(DateTime(2026, 11, 15, 8)),
        DatePostingDay(d(2026, 11, 15)),
      );
      expect(
        DatePostingDay(DateTime(2026, 11, 15, 8)).hashCode,
        DatePostingDay(d(2026, 11, 15)).hashCode,
      );
      expect(
        DatePostingDay(d(2026, 11, 15)),
        isNot(DatePostingDay(d(2026, 11, 16))),
      );
      expect(<PostingDay>{
        const WeekdayPostingDay(1),
        WeekdayPostingDay(int.parse('1')),
      }, hasLength(1));
      expect(const NoPostingDay().toString(), 'NoPostingDay()');
      expect(const WeekdayPostingDay(3).toString(), 'WeekdayPostingDay(3)');
      expect(const MonthDayPostingDay(28).toString(), 'MonthDayPostingDay(28)');
      expect(
        DatePostingDay(d(2026, 2, 9)).toString(),
        'DatePostingDay(2026-02-09)',
      );
    });
  });

  group('against the real RecurrenceService', () {
    late QuestlogDatabase db;
    late FixedClock clock;
    late RecurrenceService service;

    setUp(() {
      db = createTestDatabase();
      clock = FixedClock(DateTime(2026, 11, 15, 10));
      service = RecurrenceService(db, clock);
    });
    tearDown(() => db.close());

    RuleDraft draftFor(Cadence cadence, DateTime requested) => RuleDraft(
      name: 'Rule',
      cadence: cadence,
      requestedAnchor: requested,
      bonus: MissionBonus.small,
      quests: const [
        RuleQuestDraft(name: 'Quest', difficulty: Difficulty.easy),
      ],
    );

    test(
      'the stored Anchor_Date is the requested anchor, for every cadence',
      () async {
        final picks = [
          d(2026, 11, 15),
          d(2026, 11, 16),
          d(2026, 11, 14),
          d(2028, 2, 29),
          d(2026, 1, 31),
          d(2026, 12, 31),
          d(2031, 5, 1),
          d(2020, 8, 28),
        ];
        var checked = 0;
        for (final today in [
          d(2026, 11, 15),
          d(2026, 12, 31),
          d(2027, 3, 1),
          d(2028, 2, 28),
          d(2028, 3, 1),
        ]) {
          clock.set(DateTime(today.year, today.month, today.day, 10));
          for (final cadence in Cadence.values) {
            for (final pick in picks) {
              final day = postingDayFor(cadence, pick);
              final anchor = requestedAnchor(cadence, day, today);
              final rule = await service.create(draftFor(cadence, anchor));
              expect(
                rule.anchorDate,
                anchor,
                reason: '$cadence $day today=$today',
              );
              expect(matches(cadence, day, rule.anchorDate), isTrue);
              checked++;
            }
          }
        }
        expect(checked, 5 * 6 * 8);
      },
    );

    test('the default posting day is accepted and starts today', () async {
      for (final cadence in Cadence.values) {
        final today = d(2026, 11, 15);
        final anchor = requestedAnchor(
          cadence,
          defaultPostingDay(cadence, today),
          today,
        );
        final rule = await service.create(draftFor(cadence, anchor));
        expect(rule.anchorDate, today, reason: '$cadence');
      }
    });

    test('Monthly day 28 and Yearly Feb 29 are accepted', () async {
      clock.set(DateTime(2027, 1, 29, 10));
      final monthly = await service.create(
        draftFor(
          Cadence.monthly,
          requestedAnchor(
            Cadence.monthly,
            const MonthDayPostingDay(28),
            d(2027, 1, 29),
          ),
        ),
      );
      expect(monthly.anchorDate, d(2027, 2, 28));

      final yearly = await service.create(
        draftFor(
          Cadence.yearly,
          requestedAnchor(
            Cadence.yearly,
            DatePostingDay(d(2028, 2, 29)),
            d(2027, 1, 29),
          ),
        ),
      );
      expect(yearly.anchorDate, d(2027, 2, 28));
    });

    test(
      'an unchanged posting day from postingDayOf does not reset the rule',
      () async {
        for (final cadence in Cadence.values) {
          clock.set(DateTime(2026, 11, 15, 10));
          final today = d(2026, 11, 15);
          final created = await service.create(
            draftFor(
              cadence,
              requestedAnchor(
                cadence,
                defaultPostingDay(cadence, today),
                today,
              ),
            ),
          );
          // The rule moves on; the stored anchor is now in the past or ahead.
          await service.postNow(created.id);
          clock.set(DateTime(2026, 11, 20, 10));
          final edited = await service.update(
            created.id,
            draftFor(
              cadence,
              requestedAnchor(
                cadence,
                postingDayOf(cadence, created.anchorDate),
                d(2026, 11, 20),
              ),
            ),
          );
          expect(edited.anchorDate, created.anchorDate, reason: '$cadence');
        }
      },
    );
  });
}
