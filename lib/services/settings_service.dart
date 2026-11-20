import 'package:drift/drift.dart' show Value;

import '../core/validation.dart';
import '../data/database.dart';
import '../data/models.dart';
import '../data/preferences.dart';

/// Stores and exposes the hero name, language, theme and display font.
class SettingsService {
  SettingsService(this._db);

  final QuestlogDatabase _db;

  /// The current settings, re-emitted whenever one of them changes.
  Stream<AppSettings> watch() {
    return _db
        .select(_db.appState)
        .watchSingle()
        .map(
          (row) => AppSettings(
            heroName: row.heroName,
            language: row.language,
            theme: row.theme,
          ),
        )
        .distinct();
  }

  /// Stores the trimmed [name]; an empty or whitespace-only name clears it.
  Future<void> setHeroName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      validatedName(trimmed, 'heroName', maxLength: maxHeroNameLength);
    }
    await _write(AppStateCompanion(heroName: Value(trimmed)));
  }

  Future<void> setLanguage(AppLanguage language) =>
      _write(AppStateCompanion(language: Value(language)));

  Future<void> setTheme(AppTheme theme) => _write(AppStateCompanion(theme: Value(theme)));

  /// The language the app is shown in: an explicit choice wins, `system`
  /// resolves to Czech or English by the device language and to English for any
  /// other device language.
  AppLocaleCode resolveLanguage(AppLanguage setting, String deviceLanguageCode) {
    switch (setting) {
      case AppLanguage.cs:
        return AppLocaleCode.cs;
      case AppLanguage.en:
        return AppLocaleCode.en;
      case AppLanguage.system:
        final code = deviceLanguageCode.toLowerCase().split(RegExp('[-_]')).first;
        return code == 'cs' ? AppLocaleCode.cs : AppLocaleCode.en;
    }
  }

  Future<void> _write(AppStateCompanion change) async {
    await _db.runTransaction(() => _db.update(_db.appState).write(change));
  }
}
