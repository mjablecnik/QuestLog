import 'dart:io';

import 'package:drift/native.dart';
import 'package:glados/glados.dart';
import 'package:questlog/core/errors.dart';
import 'package:questlog/data/database.dart';
import 'package:questlog/data/models.dart';
import 'package:questlog/data/preferences.dart';
import 'package:questlog/services/settings_service.dart';

import '../helpers/test_database.dart';

void main() {
  late QuestlogDatabase db;
  late SettingsService service;

  setUp(() {
    db = createTestDatabase();
    service = SettingsService(db);
  });
  tearDown(() => db.close());

  Future<AppSettings> current() => service.watch().first;

  test('defaults: language system, theme system, font Figtree, name empty', () async {
    final settings = await current();
    expect(settings.language, AppLanguage.system);
    expect(settings.theme, AppTheme.system);
    expect(settings.heroName, '');
    expect(settings.displayName, isNull);
  });

  group('hero name', () {
    test('is trimmed and stored', () async {
      await service.setHeroName('  Martin ');
      expect((await current()).heroName, 'Martin');
      expect((await current()).displayName, 'Martin');
    });

    test('40 characters are accepted, 41 throw ValidationError', () async {
      await service.setHeroName('a' * 40);
      expect((await current()).heroName, 'a' * 40);

      await expectLater(
        service.setHeroName('a' * 41),
        throwsA(isA<ValidationError>().having((e) => e.field, 'field', 'heroName')),
      );
      expect((await current()).heroName, 'a' * 40, reason: 'a rejected name changes nothing');
    });

    test('length is counted in characters, not UTF-16 units', () async {
      await service.setHeroName('😀' * 40);
      expect((await current()).heroName, '😀' * 40);
    });

    test('whitespace after trimming does not count towards the limit', () async {
      await service.setHeroName('   ${'a' * 40}   ');
      expect((await current()).heroName, 'a' * 40);
    });

    test('a whitespace-only name is stored as empty', () async {
      await service.setHeroName('Martin');
      await service.setHeroName('   ');
      expect((await current()).heroName, '');
      expect((await current()).displayName, isNull);
    });

    test('an empty name is allowed', () async {
      await service.setHeroName('');
      expect((await current()).heroName, '');
    });
  });

  group('resolveLanguage', () {
    test('system resolves an unsupported device language to en', () {
      expect(service.resolveLanguage(AppLanguage.system, 'de'), AppLocaleCode.en);
    });

    test('system resolves cs and en by the device language', () {
      expect(service.resolveLanguage(AppLanguage.system, 'cs'), AppLocaleCode.cs);
      expect(service.resolveLanguage(AppLanguage.system, 'cs_CZ'), AppLocaleCode.cs);
      expect(service.resolveLanguage(AppLanguage.system, 'en-GB'), AppLocaleCode.en);
    });

    test('an explicit language wins over the device language', () {
      expect(service.resolveLanguage(AppLanguage.cs, 'de'), AppLocaleCode.cs);
      expect(service.resolveLanguage(AppLanguage.en, 'cs'), AppLocaleCode.en);
    });
  });

  group('observers', () {
    test('each setter emits the new AppSettings on watch', () async {
      final emitted = <AppSettings>[];
      final sub = service.watch().listen(emitted.add);
      await pumpEventQueue();
      expect(emitted, hasLength(1));

      await service.setLanguage(AppLanguage.cs);
      await pumpEventQueue();
      expect(emitted.last.language, AppLanguage.cs);

      await service.setTheme(AppTheme.dark);
      await pumpEventQueue();
      expect(emitted.last.theme, AppTheme.dark);

      await service.setHeroName('Martin');
      await pumpEventQueue();
      expect(
        emitted.last,
        const AppSettings(
          heroName: 'Martin',
          language: AppLanguage.cs,
          theme: AppTheme.dark,
        ),
      );
      expect(emitted, hasLength(4));
      await sub.cancel();
    });
  });

  test('a settings write the database rejects is a StorageError', () async {
    final Directory dir = await Directory.systemTemp.createTemp('questlog_ro');
    final File file = File('${dir.path}/questlog.sqlite');
    final QuestlogDatabase seeded = QuestlogDatabase.forTesting(NativeDatabase(file));
    await seeded.customSelect('SELECT 1').get();
    await seeded.close();
    await Process.run('chmod', <String>['444', file.path]);
    final QuestlogDatabase readOnly = QuestlogDatabase.forTesting(
      NativeDatabase.createInBackground(file),
    );
    try {
      await expectLater(
        SettingsService(readOnly).setTheme(AppTheme.dark),
        throwsA(isA<StorageError>()),
      );
    } finally {
      await readOnly.close();
      await dir.delete(recursive: true);
    }
  });
}
