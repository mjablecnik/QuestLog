// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get app_name => 'Questlog';

  @override
  String get app_splashLoading => 'Nástěnka se připravuje…';

  @override
  String get app_tabQuests => 'Questy';

  @override
  String get app_tabMissions => 'Mise';

  @override
  String app_postedMissions(String names) {
    return 'Vyvěšeno: $names';
  }

  @override
  String get app_reconcileFailed =>
      'Pravidelné mise se nepodařilo zkontrolovat.';

  @override
  String get common_cancel => 'Zrušit';

  @override
  String get common_delete => 'Smazat';

  @override
  String get common_edit => 'Upravit';

  @override
  String get common_save => 'Uložit';

  @override
  String get common_retry => 'Zkusit znovu';

  @override
  String get common_ok => 'OK';

  @override
  String get common_close => 'Zavřít';

  @override
  String get common_continue => 'Pokračovat';

  @override
  String get common_back => 'Zpět';

  @override
  String get common_discard => 'Zahodit';

  @override
  String get common_remove => 'Odebrat';

  @override
  String common_plusXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '+$xpString XP';
  }

  @override
  String common_xp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP';
  }

  @override
  String common_questCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questů',
      few: '$count questy',
      one: '$count quest',
    );
    return '$_temp0';
  }

  @override
  String get common_loading => 'Načítání…';

  @override
  String get common_today => 'dnes';

  @override
  String get common_yesterday => 'včera';

  @override
  String hero_level(int level) {
    return 'Úroveň $level';
  }

  @override
  String hero_nameAndLevel(String name, int level) {
    return '$name · Úroveň $level';
  }

  @override
  String hero_xpProgress(int current, int threshold) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat thresholdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String thresholdString = thresholdNumberFormat.format(threshold);

    return '$currentString / $thresholdString XP';
  }

  @override
  String hero_xpRemaining(int xp, int level) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP do úrovně $level';
  }

  @override
  String get hero_settingsLabel => 'Nastavení';

  @override
  String hero_levelBadgeLabel(int level) {
    return 'Úroveň $level';
  }

  @override
  String hero_progressLabel(int current, int threshold) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat thresholdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String thresholdString = thresholdNumberFormat.format(threshold);

    return 'Postup úrovně: $currentString z $thresholdString XP';
  }

  @override
  String get board_title => 'Nástěnka';

  @override
  String board_subtitle(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count otevřených',
      few: '$count otevřené',
      one: '$count otevřený',
    );
    return '$_temp0 · $date';
  }

  @override
  String get board_openSection => 'Vyvěšené questy';

  @override
  String get board_doneSection => 'Splněno dnes';

  @override
  String board_doneSummary(int count, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questů',
      few: '$count questy',
      one: '$count quest',
    );
    return '$_temp0 · $xpString XP';
  }

  @override
  String get board_emptyTitle => 'Nástěnka je prázdná';

  @override
  String get board_emptyBody =>
      'Klepni na tlačítko + a vyvěs první quest — třeba něco, co jsi dnes stejně chtěl udělat. Za každý splněný získáš XP.';

  @override
  String get board_noMission => 'bez mise';

  @override
  String get board_swipeHint =>
      'Tažením doleva upravíš nebo smažeš · klepnutím na kroužek splníš';

  @override
  String board_rewardWithdrawn(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Vráceno $xpString XP';
  }

  @override
  String board_rewardWithdrawnMissionReopened(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Vráceno $xpString XP · mise je znovu otevřená';
  }

  @override
  String quest_completedTodayAt(String time) {
    return 'dnes $time';
  }

  @override
  String get quest_completedYesterday => 'včera';

  @override
  String quest_completedOn(String date) {
    return '$date';
  }

  @override
  String get quest_difficultyEasy => 'Snadný';

  @override
  String get quest_difficultyNormal => 'Běžný';

  @override
  String get quest_difficultyHard => 'Těžký';

  @override
  String get a11y_openSettings => 'Otevřít nastavení';

  @override
  String get a11y_addQuest => 'Vyvěsit quest';

  @override
  String get a11y_addMission => 'Zahájit misi';

  @override
  String a11y_completeQuest(String name) {
    return 'Splnit quest $name';
  }

  @override
  String a11y_reopenQuest(String name) {
    return 'Znovu otevřít quest $name';
  }

  @override
  String a11y_dragHandle(String name) {
    return 'Změnit pořadí questu $name';
  }

  @override
  String get a11y_dragHint => 'Podrž a táhni';

  @override
  String a11y_editQuest(String name) {
    return 'Upravit quest $name';
  }

  @override
  String a11y_deleteQuest(String name) {
    return 'Smazat quest $name';
  }

  @override
  String a11y_editMission(String name) {
    return 'Upravit misi $name';
  }

  @override
  String a11y_deleteMission(String name) {
    return 'Smazat misi $name';
  }

  @override
  String a11y_openMission(String name) {
    return 'Otevřít misi $name';
  }

  @override
  String get a11y_missionMenu => 'Nabídka mise';

  @override
  String a11y_questMission(String name) {
    return 'Mise $name';
  }

  @override
  String a11y_difficulty(String name) {
    return 'Obtížnost: $name';
  }

  @override
  String a11y_missionProgress(int done, int total) {
    return 'Splněno $done z $total questů';
  }

  @override
  String a11y_questCompleted(String name, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Quest $name splněn, +$xpString XP';
  }

  @override
  String a11y_questReopened(String name) {
    return 'Quest $name je znovu otevřený';
  }

  @override
  String a11y_missionCompleted(String name, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Mise $name splněna, bonus +$xpString XP';
  }

  @override
  String a11y_missionReopened(String name) {
    return 'Mise $name je znovu otevřená';
  }

  @override
  String a11y_levelUp(int level) {
    return 'Nová úroveň $level';
  }

  @override
  String a11y_selectedOption(String label) {
    return '$label, vybráno';
  }

  @override
  String get a11y_dismissReward => 'Zavřít odměnu';

  @override
  String get a11y_closeSheet => 'Zavřít formulář';

  @override
  String get a11y_removeRow => 'Odebrat řádek';

  @override
  String get a11y_pickPostingDay => 'Vybrat den vyvěšení';

  @override
  String get a11y_currentChoice => 'aktuální volba';

  @override
  String get quest_sheetCreateTitle => 'Nový quest';

  @override
  String get quest_sheetEditTitle => 'Upravit quest';

  @override
  String get quest_nameLabel => 'Co je třeba vykonat';

  @override
  String get quest_namePlaceholder => 'Pověsit prádlo';

  @override
  String get quest_difficultyLabel => 'Obtížnost';

  @override
  String get quest_missionLabel => 'Součást mise';

  @override
  String get quest_missionNone => 'Bez mise';

  @override
  String get quest_noteLabel => 'Poznámka';

  @override
  String get quest_notePlaceholder =>
      'Nepovinné — kde, jak, na co nezapomenout…';

  @override
  String get quest_createAction => 'Vyvěsit quest';

  @override
  String get quest_doneLockedHint =>
      'U splněného questu jde změnit jen název a poznámku.';

  @override
  String get quest_deleteTitle => 'Smazat quest?';

  @override
  String quest_deleteBody(String name) {
    return 'Quest „$name“ bude smazán.';
  }

  @override
  String quest_deleteDoneBody(String name) {
    return 'Quest „$name“ bude smazán. Už získané XP ti zůstanou.';
  }

  @override
  String get sheet_discardTitle => 'Zahodit změny?';

  @override
  String get sheet_discardBody => 'Co jsi zadal, se neuloží.';

  @override
  String get sheet_keepEditing => 'Pokračovat v úpravách';

  @override
  String get reward_questComplete => 'QUEST SPLNĚNO';

  @override
  String get reward_levelUp => 'NOVÁ ÚROVEŇ';

  @override
  String get reward_missionComplete => 'MISE SPLNĚNA';

  @override
  String reward_levelUpBody(int level) {
    return 'Dosáhl jsi úrovně $level';
  }

  @override
  String reward_levelNumber(int level) {
    return '$level';
  }

  @override
  String reward_missionLine(String name) {
    return 'Mise · $name';
  }

  @override
  String reward_missionProgress(int done, int total) {
    return '$done z $total questů';
  }

  @override
  String reward_missionRemaining(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Zbývá $xpString XP';
  }

  @override
  String reward_missionBonusHint(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Dokončení mise přinese dalších +$xpString XP';
  }

  @override
  String get reward_missionReady =>
      'Všechny questy jsou splněné — dokonči misi a získej bonus.';

  @override
  String get reward_completeMission => 'Dokončit misi';

  @override
  String get reward_missionBonusLabel => 'Bonus za misi';

  @override
  String get missions_title => 'Mise';

  @override
  String missions_openCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rozehraných',
      few: '$count rozehrané',
      one: '$count rozehraná',
    );
    return '$_temp0';
  }

  @override
  String missions_doneCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dokončených',
      few: '$count dokončené',
      one: '$count dokončená',
    );
    return '$_temp0';
  }

  @override
  String get missions_sectionOpen => 'Rozehrané';

  @override
  String get missions_sectionDoneToday => 'Dokončeno dnes';

  @override
  String missions_remaining(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Zbývá: $xpString XP';
  }

  @override
  String get missions_bonusCaption => 'za dokončení';

  @override
  String get missions_earnedCaption => 'získáno';

  @override
  String get missions_readyToComplete => 'Připraveno k dokončení';

  @override
  String missions_completedLine(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questů',
      few: '$count questy',
      one: '$count quest',
    );
    return '$_temp0 · dokončeno dnes v $time';
  }

  @override
  String get missions_emptyTitle => 'Zatím žádné mise';

  @override
  String get missions_emptyBody =>
      'Mise je větší cíl složený z questů. Za její dokončení získáš bonusové XP.';

  @override
  String get missions_emptyAction => 'Zahájit misi';

  @override
  String get missions_recurringCaption => 'Pravidelná mise';

  @override
  String get mission_sheetCreateTitle => 'Nová mise';

  @override
  String get mission_sheetEditTitle => 'Upravit misi';

  @override
  String get mission_nameLabel => 'Název mise';

  @override
  String get mission_namePlaceholder => 'Velký podzimní úklid';

  @override
  String get mission_bonusLabel => 'Odměna za dokončení';

  @override
  String get mission_bonusSmall => 'Malá';

  @override
  String get mission_bonusMedium => 'Střední';

  @override
  String get mission_bonusLarge => 'Velká';

  @override
  String get mission_bonusHelp => 'Navíc k XP za jednotlivé questy.';

  @override
  String mission_questsLabel(int count) {
    return 'Questy v misi · $count';
  }

  @override
  String get mission_questNamePlaceholder => 'Název questu';

  @override
  String get mission_addQuest => 'Přidat quest';

  @override
  String get mission_createAction => 'Zahájit misi';

  @override
  String get mission_editBonusNote => 'Už získaný bonus se nezmění.';

  @override
  String get mission_editQuestsNote =>
      'Questy mise se upravují na jejím detailu.';

  @override
  String get mission_detailKicker => 'Mise';

  @override
  String mission_progressText(int done, int total) {
    return '$done z $total questů splněno';
  }

  @override
  String mission_bonusOnCompletion(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '+$xpString XP za dokončení mise';
  }

  @override
  String get mission_sectionRemaining => 'Zbývá';

  @override
  String get mission_sectionDone => 'Splněno';

  @override
  String mission_sectionSummary(int count, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questů',
      few: '$count questy',
      one: '$count quest',
    );
    return '$_temp0 · $xpString XP';
  }

  @override
  String get mission_menuEdit => 'Upravit misi';

  @override
  String get mission_menuAddQuest => 'Přidat quest';

  @override
  String get mission_menuDelete => 'Smazat misi';

  @override
  String get mission_addQuestToMission => 'Přidat quest do mise';

  @override
  String get mission_completeAction => 'Dokončit misi';

  @override
  String get mission_completedTitle => 'Mise splněna';

  @override
  String mission_completedBonus(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Získán bonus +$xpString XP';
  }

  @override
  String mission_completedOn(String date) {
    return 'Dokončeno $date';
  }

  @override
  String get mission_bonusWithdrawn =>
      'Bonus byl odebrán, mise je znovu otevřená.';

  @override
  String get mission_emptyTitle => 'Mise zatím nemá žádné questy';

  @override
  String get mission_emptyBody =>
      'Klepni na „Přidat quest“ a vyvěs první krok.';

  @override
  String get mission_deleteTitle => 'Smazat misi?';

  @override
  String mission_deleteBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Mise „$name“ bude smazána včetně $count questů. Už získané XP ti zůstanou.',
      one:
          'Mise „$name“ bude smazána včetně $count questu. Už získané XP ti zůstanou.',
      zero: 'Mise „$name“ bude smazána. Už získané XP ti zůstanou.',
    );
    return '$_temp0';
  }

  @override
  String get settings_title => 'Nastavení';

  @override
  String get settings_groupProfile => 'Profil';

  @override
  String get settings_groupLanguage => 'Jazyk';

  @override
  String get settings_groupAppearance => 'Vzhled';

  @override
  String get settings_groupRules => 'Pravidelné mise';

  @override
  String get settings_groupTemporary => 'Dočasné';

  @override
  String get settings_temporaryHint => 'zmizí po výběru';

  @override
  String get settings_groupAbout => 'O aplikaci';

  @override
  String get settings_heroNameLabel => 'Jméno hrdiny';

  @override
  String get settings_heroNamePlaceholder => 'Jak ti máme říkat?';

  @override
  String settings_heroNameCounter(int current, int max) {
    return '$current / $max';
  }

  @override
  String settings_totalXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Celkem $xpString XP';
  }

  @override
  String get settings_languageCs => 'Čeština';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_themeLight => 'Světlý';

  @override
  String get settings_themeDark => 'Tmavý';

  @override
  String get settings_themeSystem => 'Systém';

  @override
  String settings_version(String version) {
    return 'verze $version';
  }

  @override
  String settings_rulesActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktivních',
      few: '$count aktivní',
      one: '$count aktivní',
    );
    return '$_temp0';
  }

  @override
  String get rule_addRow => 'Přidat pravidelnou misi';

  @override
  String get rule_addHint =>
      'Ručně vyvěšená mise nahradí nejbližší automatickou.';

  @override
  String get rule_postNow => 'Vyvěsit teď';

  @override
  String get rule_posted => 'Vyvěšeno';

  @override
  String get rule_cadenceDaily => 'Denně';

  @override
  String get rule_cadenceWeekly => 'Týdně';

  @override
  String get rule_cadenceBiweekly => 'Každé 2 týdny';

  @override
  String get rule_cadenceMonthly => 'Měsíčně';

  @override
  String get rule_cadenceQuarterly => 'Čtvrtletně';

  @override
  String get rule_cadenceYearly => 'Ročně';

  @override
  String get rule_detailDaily => 'Denně';

  @override
  String rule_detailWeekly(String weekday) {
    return 'Týdně, $weekday';
  }

  @override
  String rule_detailBiweekly(String weekday) {
    return 'Každé 2 týdny, $weekday';
  }

  @override
  String rule_detailMonthly(int day) {
    return 'Měsíčně, $day. den';
  }

  @override
  String rule_detailQuarterly(String date) {
    return 'Čtvrtletně, $date';
  }

  @override
  String rule_detailYearly(String date) {
    return 'Ročně, $date';
  }

  @override
  String rule_line(String cadence, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questů',
      few: '$count questy',
      one: '$count quest',
    );
    return '$cadence · $_temp0 · příště $date';
  }

  @override
  String rule_lineManual(String cadence, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questů',
      few: '$count questy',
      one: '$count quest',
    );
    return '$cadence · $_temp0 · ručně, příště $date';
  }

  @override
  String rule_postedMessage(String name) {
    return 'Mise „$name“ vyvěšena.';
  }

  @override
  String get rule_postedSkippedNote =>
      'Nejbližší plánované vyvěšení se přeskočí.';

  @override
  String get rule_postedClosedNote =>
      'Nedokončená předchozí mise byla uzavřena bez bonusu.';

  @override
  String get rule_sheetTitle => 'Pravidelná mise';

  @override
  String get rule_sheetEditTitle => 'Upravit pravidlo';

  @override
  String get rule_nameLabel => 'Název mise';

  @override
  String get rule_cadenceLabel => 'Opakování';

  @override
  String get rule_postingDayLabel => 'Vyvěsit vždy';

  @override
  String rule_postingMonthDay(int day) {
    return '$day. den v měsíci';
  }

  @override
  String get rule_postingDayWeekdayTitle => 'Den v týdnu';

  @override
  String get rule_postingDayMonthTitle => 'Den v měsíci';

  @override
  String get rule_postingDayDateTitle => 'Datum';

  @override
  String get rule_helpNoCarryOver =>
      'Nedokončené questy z minulého období se nepřenášejí. Ruční vyvěšení (v Nastavení) nahradí nejbližší automatické.';

  @override
  String get rule_editNote => 'Změny se projeví až u příště vyvěšené mise.';

  @override
  String get rule_saveAction => 'Uložit pravidlo';

  @override
  String get rule_deleteAction => 'Smazat pravidlo';

  @override
  String get rule_deleteTitle => 'Smazat pravidlo?';

  @override
  String rule_deleteBody(String name) {
    return 'Právě vyvěšená mise zůstane, ale podle pravidla „$name“ se už další mise vyvěšovat nebudou.';
  }

  @override
  String get font_rowLabel => 'Písmo titulků';

  @override
  String get font_sample => 'Nástěnka · +25';

  @override
  String get font_help =>
      'Mění jen titulky a čísla — text a ovládání zůstávají ve Figtree. Volba se projeví okamžitě v celé aplikaci.';

  @override
  String get font_nameFigtree => 'Figtree';

  @override
  String get font_nameBricolage => 'Bricolage Grotesque';

  @override
  String get font_nameSora => 'Sora';

  @override
  String get font_nameOutfit => 'Outfit';

  @override
  String get font_nameUnbounded => 'Unbounded';

  @override
  String get font_nameCinzel => 'Cinzel';

  @override
  String get font_noteFigtree => 'Klidné, univerzální';

  @override
  String get font_noteBricolage => 'Osobitý grotesk';

  @override
  String get font_noteSora => 'Geometrický, technický';

  @override
  String get font_noteOutfit => 'Měkký geometrický';

  @override
  String get font_noteUnbounded => 'Široký, herní';

  @override
  String get font_noteCinzel => 'Tesané kapitálky';

  @override
  String get error_nameRequired => 'Zadej název.';

  @override
  String get error_nameTooLong => 'Název může mít nejvýše 80 znaků.';

  @override
  String get error_noteTooLong => 'Poznámka může mít nejvýše 500 znaků.';

  @override
  String get error_heroNameTooLong => 'Jméno může mít nejvýše 40 znaků.';

  @override
  String get error_noQuestTemplate => 'Přidej alespoň jeden quest s názvem.';

  @override
  String get error_missionNotOpen =>
      'Tato mise už není otevřená. Vyber jinou, nebo žádnou.';

  @override
  String get error_validation => 'Zadaná hodnota není platná.';

  @override
  String get error_itemChanged =>
      'Položka se mezitím změnila. Seznam jsme obnovili.';

  @override
  String get error_storage => 'Data se nepodařilo uložit. Nic se nezměnilo.';

  @override
  String get error_unknown => 'Něco se pokazilo.';
}
