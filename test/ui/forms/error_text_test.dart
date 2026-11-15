import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/l10n/app_localizations.dart';
import 'package:questlog/ui/forms/error_text.dart';
import 'package:questlog/ui/forms/validators.dart';

void main() {
  final locales = {
    'cs': lookupAppLocalizations(const Locale('cs')),
    'en': lookupAppLocalizations(const Locale('en')),
  };

  group('fieldErrorText', () {
    for (final entry in locales.entries) {
      test('covers every FieldError in ${entry.key}', () {
        final texts = <String>{};
        for (final error in FieldError.values) {
          final text = fieldErrorText(entry.value, error);
          expect(text.trim(), isNotEmpty, reason: '$error');
          expect(text, isNot(contains('{')), reason: '$error');
          texts.add(text);
        }
        expect(
          texts.length,
          FieldError.values.length,
          reason: 'each error has its own message',
        );
      });
    }

    test('limits are named in the messages', () {
      final l = locales['cs']!;
      expect(fieldErrorText(l, FieldError.tooLong), contains('80'));
      expect(fieldErrorText(l, FieldError.noteTooLong), contains('500'));
      expect(fieldErrorText(l, FieldError.heroNameTooLong), contains('40'));
    });
  });

  group('domainErrorText', () {
    const secret = 'SECRET-entity-4711-cause';
    final errors = <DomainError>[
      const ValidationError(secret, 'detail-$secret'),
      const NotFoundError(secret, 4711),
      const InvalidStateError('reason-$secret'),
      const StorageError('cause-$secret'),
    ];

    for (final entry in locales.entries) {
      test('never leaks exception text in ${entry.key}', () {
        for (final error in errors) {
          final text = domainErrorText(entry.value, error);
          expect(text.trim(), isNotEmpty, reason: '$error');
          expect(text, isNot(contains(secret)), reason: '$error');
          expect(text, isNot(contains('4711')), reason: '$error');
          expect(text, isNot(contains(error.message)), reason: '$error');
          expect(text, isNot(contains(error.runtimeType.toString())));
        }
      });
    }

    test(
      'not-found and invalid-state say the item changed, storage differs',
      () {
        final l = locales['en']!;
        expect(domainErrorText(l, errors[1]), domainErrorText(l, errors[2]));
        expect(
          domainErrorText(l, errors[3]),
          isNot(domainErrorText(l, errors[1])),
        );
      },
    );
  });
}
