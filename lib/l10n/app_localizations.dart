import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
  ];

  /// Application name shown on the splash and in the About group.
  ///
  /// In cs, this message translates to:
  /// **'Questlog'**
  String get app_name;

  /// Text under the logo on the splash screen while the database opens and Reconciliation runs.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka se připravuje…'**
  String get app_splashLoading;

  /// Label of the Quests tab in the bottom tab bar.
  ///
  /// In cs, this message translates to:
  /// **'Questy'**
  String get app_tabQuests;

  /// Label of the Missions tab in the bottom tab bar.
  ///
  /// In cs, this message translates to:
  /// **'Mise'**
  String get app_tabMissions;

  /// Snackbar after Reconciliation posted recurring missions. names is a comma-separated list of Mission names.
  ///
  /// In cs, this message translates to:
  /// **'Vyvěšeno: {names}'**
  String app_postedMissions(String names);

  /// Inline banner text when Reconciliation failed with a storage error; shown next to a retry button.
  ///
  /// In cs, this message translates to:
  /// **'Pravidelné mise se nepodařilo zkontrolovat.'**
  String get app_reconcileFailed;

  /// Generic cancel button.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get common_cancel;

  /// Generic delete button and swipe action.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get common_delete;

  /// Generic edit button and swipe action.
  ///
  /// In cs, this message translates to:
  /// **'Upravit'**
  String get common_edit;

  /// Primary button of sheets in edit mode.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get common_save;

  /// Retry button on banners and snackbars.
  ///
  /// In cs, this message translates to:
  /// **'Zkusit znovu'**
  String get common_retry;

  /// Generic acknowledge button.
  ///
  /// In cs, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// Generic close button.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get common_close;

  /// Secondary button of the Reward_Card; dismisses it.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat'**
  String get common_continue;

  /// Semantic label of back buttons.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get common_back;

  /// Destructive button of the discard-changes confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit'**
  String get common_discard;

  /// Generic remove button.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat'**
  String get common_remove;

  /// XP figure with a plus sign, e.g. on cards and difficulty options.
  ///
  /// In cs, this message translates to:
  /// **'+{xp} XP'**
  String common_plusXp(int xp);

  /// XP figure without a sign.
  ///
  /// In cs, this message translates to:
  /// **'{xp} XP'**
  String common_xp(int xp);

  /// Count of Quests with a correctly pluralised noun (Czech one/few/other). Property 6 of spec 002 tests this key.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} quest} few{{count} questy} other{{count} questů}}'**
  String common_questCount(int count);

  /// Semantic label of skeleton cards while data loads.
  ///
  /// In cs, this message translates to:
  /// **'Načítání…'**
  String get common_loading;

  /// Lower-case word for the current Board_Day.
  ///
  /// In cs, this message translates to:
  /// **'dnes'**
  String get common_today;

  /// Lower-case word for the previous day in meta rows.
  ///
  /// In cs, this message translates to:
  /// **'včera'**
  String get common_yesterday;

  /// Hero_Bar Level line.
  ///
  /// In cs, this message translates to:
  /// **'Úroveň {level}'**
  String hero_level(int level);

  /// Hero_Bar line when a hero name is set.
  ///
  /// In cs, this message translates to:
  /// **'{name} · Úroveň {level}'**
  String hero_nameAndLevel(String name, int level);

  /// XP earned inside the current Level over the Level threshold.
  ///
  /// In cs, this message translates to:
  /// **'{current} / {threshold} XP'**
  String hero_xpProgress(int current, int threshold);

  /// XP remaining until the next Level; level is the NEXT Level number.
  ///
  /// In cs, this message translates to:
  /// **'{xp} XP do úrovně {level}'**
  String hero_xpRemaining(int xp, int level);

  /// Semantic label of the gear button in the Hero_Bar.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get hero_settingsLabel;

  /// Semantic label of the Level badge.
  ///
  /// In cs, this message translates to:
  /// **'Úroveň {level}'**
  String hero_levelBadgeLabel(int level);

  /// Semantic label of the Hero_Bar progress bar.
  ///
  /// In cs, this message translates to:
  /// **'Postup úrovně: {current} z {threshold} XP'**
  String hero_progressLabel(int current, int threshold);

  /// Title of the Board_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka'**
  String get board_title;

  /// Subtitle under the board title; date is already formatted in the locale (e.g. 'sobota 15. 11.').
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} otevřený} few{{count} otevřené} other{{count} otevřených}} · {date}'**
  String board_subtitle(int count, String date);

  /// Section label above the open Quests.
  ///
  /// In cs, this message translates to:
  /// **'Vyvěšené questy'**
  String get board_openSection;

  /// Section label above the Quests done on the current Board_Day.
  ///
  /// In cs, this message translates to:
  /// **'Splněno dnes'**
  String get board_doneSection;

  /// Right-hand summary of a Quest section: number of Quests and their XP.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} quest} few{{count} questy} other{{count} questů}} · {xp} XP'**
  String board_doneSummary(int count, int xp);

  /// Empty-state heading of the Board_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka je prázdná'**
  String get board_emptyTitle;

  /// Empty-state guidance of the Board_Screen; points to the add button.
  ///
  /// In cs, this message translates to:
  /// **'Klepni na tlačítko + a vyvěs první quest — třeba něco, co jsi dnes stejně chtěl udělat. Za každý splněný získáš XP.'**
  String get board_emptyBody;

  /// Meta-row text of a Quest without a Mission.
  ///
  /// In cs, this message translates to:
  /// **'bez mise'**
  String get board_noMission;

  /// One-line hint under the open list.
  ///
  /// In cs, this message translates to:
  /// **'Tažením doleva upravíš nebo smažeš · klepnutím na kroužek splníš'**
  String get board_swipeHint;

  /// Snackbar after reopening a done Quest.
  ///
  /// In cs, this message translates to:
  /// **'Vráceno {xp} XP'**
  String board_rewardWithdrawn(int xp);

  /// Snackbar after reopening a Quest that also reopened its completed Mission.
  ///
  /// In cs, this message translates to:
  /// **'Vráceno {xp} XP · mise je znovu otevřená'**
  String board_rewardWithdrawnMissionReopened(int xp);

  /// Completion time of a Quest done today; time is formatted in the locale.
  ///
  /// In cs, this message translates to:
  /// **'dnes {time}'**
  String quest_completedTodayAt(String time);

  /// Completion label of a Quest done on the previous day.
  ///
  /// In cs, this message translates to:
  /// **'včera'**
  String get quest_completedYesterday;

  /// Completion date of a Quest done earlier; date is formatted in the locale.
  ///
  /// In cs, this message translates to:
  /// **'{date}'**
  String quest_completedOn(String date);

  /// Difficulty name.
  ///
  /// In cs, this message translates to:
  /// **'Snadný'**
  String get quest_difficultyEasy;

  /// Difficulty name.
  ///
  /// In cs, this message translates to:
  /// **'Běžný'**
  String get quest_difficultyNormal;

  /// Difficulty name.
  ///
  /// In cs, this message translates to:
  /// **'Těžký'**
  String get quest_difficultyHard;

  /// Semantic label of the gear.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít nastavení'**
  String get a11y_openSettings;

  /// Semantic label of the add button on the Board_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Vyvěsit quest'**
  String get a11y_addQuest;

  /// Semantic label of the add button on the Missions_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Zahájit misi'**
  String get a11y_addMission;

  /// Semantic label of the check circle of an open Quest.
  ///
  /// In cs, this message translates to:
  /// **'Splnit quest {name}'**
  String a11y_completeQuest(String name);

  /// Semantic label of the check circle of a done Quest.
  ///
  /// In cs, this message translates to:
  /// **'Znovu otevřít quest {name}'**
  String a11y_reopenQuest(String name);

  /// Semantic label of the drag handle.
  ///
  /// In cs, this message translates to:
  /// **'Změnit pořadí questu {name}'**
  String a11y_dragHandle(String name);

  /// Semantic hint of the drag handle.
  ///
  /// In cs, this message translates to:
  /// **'Podrž a táhni'**
  String get a11y_dragHint;

  /// Semantic label of the swipe action.
  ///
  /// In cs, this message translates to:
  /// **'Upravit quest {name}'**
  String a11y_editQuest(String name);

  /// Semantic label of the swipe action.
  ///
  /// In cs, this message translates to:
  /// **'Smazat quest {name}'**
  String a11y_deleteQuest(String name);

  /// Semantic label of the swipe action.
  ///
  /// In cs, this message translates to:
  /// **'Upravit misi {name}'**
  String a11y_editMission(String name);

  /// Semantic label of the swipe action.
  ///
  /// In cs, this message translates to:
  /// **'Smazat misi {name}'**
  String a11y_deleteMission(String name);

  /// Semantic label of a Mission_Card.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít misi {name}'**
  String a11y_openMission(String name);

  /// Semantic label of the three-dots button.
  ///
  /// In cs, this message translates to:
  /// **'Nabídka mise'**
  String get a11y_missionMenu;

  /// Semantic label of the Mission chip on a Quest_Card.
  ///
  /// In cs, this message translates to:
  /// **'Mise {name}'**
  String a11y_questMission(String name);

  /// Semantic label of the difficulty pips.
  ///
  /// In cs, this message translates to:
  /// **'Obtížnost: {name}'**
  String a11y_difficulty(String name);

  /// Semantic label of the progress ring or bar.
  ///
  /// In cs, this message translates to:
  /// **'Splněno {done} z {total} questů'**
  String a11y_missionProgress(int done, int total);

  /// Announcement after completing a Quest.
  ///
  /// In cs, this message translates to:
  /// **'Quest {name} splněn, +{xp} XP'**
  String a11y_questCompleted(String name, int xp);

  /// Announcement after reopening a Quest.
  ///
  /// In cs, this message translates to:
  /// **'Quest {name} je znovu otevřený'**
  String a11y_questReopened(String name);

  /// Announcement after completing a Mission.
  ///
  /// In cs, this message translates to:
  /// **'Mise {name} splněna, bonus +{xp} XP'**
  String a11y_missionCompleted(String name, int xp);

  /// Announcement after a Mission went back to open.
  ///
  /// In cs, this message translates to:
  /// **'Mise {name} je znovu otevřená'**
  String a11y_missionReopened(String name);

  /// Announcement of a Level-up.
  ///
  /// In cs, this message translates to:
  /// **'Nová úroveň {level}'**
  String a11y_levelUp(int level);

  /// Semantic label of a selected segment or chip.
  ///
  /// In cs, this message translates to:
  /// **'{label}, vybráno'**
  String a11y_selectedOption(String label);

  /// Semantic label of the scrim behind the Reward_Card.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít odměnu'**
  String get a11y_dismissReward;

  /// Semantic label of the sheet grabber.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít formulář'**
  String get a11y_closeSheet;

  /// Semantic label of the remove button of a quest row.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat řádek'**
  String get a11y_removeRow;

  /// Semantic label of the posting-day row.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat den vyvěšení'**
  String get a11y_pickPostingDay;

  /// Semantic suffix of the ticked font row.
  ///
  /// In cs, this message translates to:
  /// **'aktuální volba'**
  String get a11y_currentChoice;

  /// Quest_Sheet title in create mode.
  ///
  /// In cs, this message translates to:
  /// **'Nový quest'**
  String get quest_sheetCreateTitle;

  /// Quest_Sheet title in edit mode.
  ///
  /// In cs, this message translates to:
  /// **'Upravit quest'**
  String get quest_sheetEditTitle;

  /// Label of the Quest name field.
  ///
  /// In cs, this message translates to:
  /// **'Co je třeba vykonat'**
  String get quest_nameLabel;

  /// Placeholder example in the Quest name field.
  ///
  /// In cs, this message translates to:
  /// **'Pověsit prádlo'**
  String get quest_namePlaceholder;

  /// Label of the Difficulty selector.
  ///
  /// In cs, this message translates to:
  /// **'Obtížnost'**
  String get quest_difficultyLabel;

  /// Label of the Mission picker.
  ///
  /// In cs, this message translates to:
  /// **'Součást mise'**
  String get quest_missionLabel;

  /// First option of the Mission picker.
  ///
  /// In cs, this message translates to:
  /// **'Bez mise'**
  String get quest_missionNone;

  /// Label of the note field.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka'**
  String get quest_noteLabel;

  /// Placeholder of the note field.
  ///
  /// In cs, this message translates to:
  /// **'Nepovinné — kde, jak, na co nezapomenout…'**
  String get quest_notePlaceholder;

  /// Primary button of the Quest_Sheet in create mode.
  ///
  /// In cs, this message translates to:
  /// **'Vyvěsit quest'**
  String get quest_createAction;

  /// Hint under the disabled Difficulty selector and Mission picker when a done Quest is edited.
  ///
  /// In cs, this message translates to:
  /// **'U splněného questu jde změnit jen název a poznámku.'**
  String get quest_doneLockedHint;

  /// Title of the Quest deletion confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Smazat quest?'**
  String get quest_deleteTitle;

  /// Body of the Quest deletion confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Quest „{name}“ bude smazán.'**
  String quest_deleteBody(String name);

  /// Body of the deletion confirmation of a done Quest.
  ///
  /// In cs, this message translates to:
  /// **'Quest „{name}“ bude smazán. Už získané XP ti zůstanou.'**
  String quest_deleteDoneBody(String name);

  /// Title of the discard-changes confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit změny?'**
  String get sheet_discardTitle;

  /// Body of the discard-changes confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Co jsi zadal, se neuloží.'**
  String get sheet_discardBody;

  /// Cancel button of the discard-changes confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat v úpravách'**
  String get sheet_keepEditing;

  /// Caption of the Reward_Card for a Quest (upper case).
  ///
  /// In cs, this message translates to:
  /// **'QUEST SPLNĚNO'**
  String get reward_questComplete;

  /// Caption of the Level-up Reward_Card (upper case).
  ///
  /// In cs, this message translates to:
  /// **'NOVÁ ÚROVEŇ'**
  String get reward_levelUp;

  /// Caption of the Reward_Card for a Mission (upper case).
  ///
  /// In cs, this message translates to:
  /// **'MISE SPLNĚNA'**
  String get reward_missionComplete;

  /// Line on the Level-up Reward_Card.
  ///
  /// In cs, this message translates to:
  /// **'Dosáhl jsi úrovně {level}'**
  String reward_levelUpBody(int level);

  /// Big Level number on the Level-up Reward_Card.
  ///
  /// In cs, this message translates to:
  /// **'{level}'**
  String reward_levelNumber(int level);

  /// Line naming the Mission under a Quest reward.
  ///
  /// In cs, this message translates to:
  /// **'Mise · {name}'**
  String reward_missionLine(String name);

  /// Mission progress text on the Reward_Card.
  ///
  /// In cs, this message translates to:
  /// **'{done} z {total} questů'**
  String reward_missionProgress(int done, int total);

  /// Remaining XP of the Mission on the Reward_Card.
  ///
  /// In cs, this message translates to:
  /// **'Zbývá {xp} XP'**
  String reward_missionRemaining(int xp);

  /// Hint on the Quest Reward_Card about the Mission bonus.
  ///
  /// In cs, this message translates to:
  /// **'Dokončení mise přinese dalších +{xp} XP'**
  String reward_missionBonusHint(int xp);

  /// Text when the Mission is ready to be completed.
  ///
  /// In cs, this message translates to:
  /// **'Všechny questy jsou splněné — dokonči misi a získej bonus.'**
  String get reward_missionReady;

  /// Primary button of the Reward_Card and Mission_Detail_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Dokončit misi'**
  String get reward_completeMission;

  /// Label next to the bonus XP on the Mission Reward_Card.
  ///
  /// In cs, this message translates to:
  /// **'Bonus za misi'**
  String get reward_missionBonusLabel;

  /// Title of the Missions_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Mise'**
  String get missions_title;

  /// Count of open Missions.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} rozehraná} few{{count} rozehrané} other{{count} rozehraných}}'**
  String missions_openCount(int count);

  /// Count of Missions completed today.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} dokončená} few{{count} dokončené} other{{count} dokončených}}'**
  String missions_doneCount(int count);

  /// Section label above the open Missions.
  ///
  /// In cs, this message translates to:
  /// **'Rozehrané'**
  String get missions_sectionOpen;

  /// Section label of Missions completed on the current Board_Day.
  ///
  /// In cs, this message translates to:
  /// **'Dokončeno dnes'**
  String get missions_sectionDoneToday;

  /// Remaining XP on a Mission_Card.
  ///
  /// In cs, this message translates to:
  /// **'Zbývá: {xp} XP'**
  String missions_remaining(int xp);

  /// Caption under the bonus on an open Mission_Card.
  ///
  /// In cs, this message translates to:
  /// **'za dokončení'**
  String get missions_bonusCaption;

  /// Caption under the bonus of a Mission completed today.
  ///
  /// In cs, this message translates to:
  /// **'získáno'**
  String get missions_earnedCaption;

  /// Mission_Card text when all Quests are done.
  ///
  /// In cs, this message translates to:
  /// **'Připraveno k dokončení'**
  String get missions_readyToComplete;

  /// Meta line of a Mission completed today.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} quest} few{{count} questy} other{{count} questů}} · dokončeno dnes v {time}'**
  String missions_completedLine(int count, String time);

  /// Empty-state heading of the Missions_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné mise'**
  String get missions_emptyTitle;

  /// Empty-state guidance of the Missions_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Mise je větší cíl složený z questů. Za její dokončení získáš bonusové XP.'**
  String get missions_emptyBody;

  /// Button of the Missions_Screen empty state.
  ///
  /// In cs, this message translates to:
  /// **'Zahájit misi'**
  String get missions_emptyAction;

  /// Caption of a Mission that is an Instance of a rule.
  ///
  /// In cs, this message translates to:
  /// **'Pravidelná mise'**
  String get missions_recurringCaption;

  /// Mission_Sheet title in create mode.
  ///
  /// In cs, this message translates to:
  /// **'Nová mise'**
  String get mission_sheetCreateTitle;

  /// Mission_Sheet title in edit mode.
  ///
  /// In cs, this message translates to:
  /// **'Upravit misi'**
  String get mission_sheetEditTitle;

  /// Label of the Mission name field.
  ///
  /// In cs, this message translates to:
  /// **'Název mise'**
  String get mission_nameLabel;

  /// Placeholder example in the Mission name field.
  ///
  /// In cs, this message translates to:
  /// **'Velký podzimní úklid'**
  String get mission_namePlaceholder;

  /// Label of the Mission_Bonus selector.
  ///
  /// In cs, this message translates to:
  /// **'Odměna za dokončení'**
  String get mission_bonusLabel;

  /// Mission_Bonus name.
  ///
  /// In cs, this message translates to:
  /// **'Malá'**
  String get mission_bonusSmall;

  /// Mission_Bonus name.
  ///
  /// In cs, this message translates to:
  /// **'Střední'**
  String get mission_bonusMedium;

  /// Mission_Bonus name.
  ///
  /// In cs, this message translates to:
  /// **'Velká'**
  String get mission_bonusLarge;

  /// Help line under the Mission_Bonus selector.
  ///
  /// In cs, this message translates to:
  /// **'Navíc k XP za jednotlivé questy.'**
  String get mission_bonusHelp;

  /// Label above the quest rows of a Mission or rule.
  ///
  /// In cs, this message translates to:
  /// **'Questy v misi · {count}'**
  String mission_questsLabel(int count);

  /// Placeholder of a quest row name field.
  ///
  /// In cs, this message translates to:
  /// **'Název questu'**
  String get mission_questNamePlaceholder;

  /// Dashed row below the quest rows of the Mission_Sheet and Rule_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Přidat quest'**
  String get mission_addQuest;

  /// Primary button of the Mission_Sheet in create mode.
  ///
  /// In cs, this message translates to:
  /// **'Zahájit misi'**
  String get mission_createAction;

  /// Note in the Mission_Sheet when the bonus of a completed Mission is edited.
  ///
  /// In cs, this message translates to:
  /// **'Už získaný bonus se nezmění.'**
  String get mission_editBonusNote;

  /// Note in the Mission_Sheet edit mode, where quest rows are hidden.
  ///
  /// In cs, this message translates to:
  /// **'Questy mise se upravují na jejím detailu.'**
  String get mission_editQuestsNote;

  /// Small caps label above the Mission name on the detail screen.
  ///
  /// In cs, this message translates to:
  /// **'Mise'**
  String get mission_detailKicker;

  /// Progress line on the Mission_Detail_Screen.
  ///
  /// In cs, this message translates to:
  /// **'{done} z {total} questů splněno'**
  String mission_progressText(int done, int total);

  /// Bonus line on the Mission_Detail_Screen.
  ///
  /// In cs, this message translates to:
  /// **'+{xp} XP za dokončení mise'**
  String mission_bonusOnCompletion(int xp);

  /// Section label above the open Quests of a Mission.
  ///
  /// In cs, this message translates to:
  /// **'Zbývá'**
  String get mission_sectionRemaining;

  /// Section label above the done Quests of a Mission.
  ///
  /// In cs, this message translates to:
  /// **'Splněno'**
  String get mission_sectionDone;

  /// Right-hand summary of a Mission detail section.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} quest} few{{count} questy} other{{count} questů}} · {xp} XP'**
  String mission_sectionSummary(int count, int xp);

  /// Menu item.
  ///
  /// In cs, this message translates to:
  /// **'Upravit misi'**
  String get mission_menuEdit;

  /// Menu item.
  ///
  /// In cs, this message translates to:
  /// **'Přidat quest'**
  String get mission_menuAddQuest;

  /// Menu item, destructive.
  ///
  /// In cs, this message translates to:
  /// **'Smazat misi'**
  String get mission_menuDelete;

  /// Dashed row below the open Quests on the detail screen.
  ///
  /// In cs, this message translates to:
  /// **'Přidat quest do mise'**
  String get mission_addQuestToMission;

  /// Primary button when all Quests of the Mission are done.
  ///
  /// In cs, this message translates to:
  /// **'Dokončit misi'**
  String get mission_completeAction;

  /// Heading of the completed state.
  ///
  /// In cs, this message translates to:
  /// **'Mise splněna'**
  String get mission_completedTitle;

  /// Completed state: the bonus that was awarded.
  ///
  /// In cs, this message translates to:
  /// **'Získán bonus +{xp} XP'**
  String mission_completedBonus(int xp);

  /// Completed state: the completion date, formatted in the locale.
  ///
  /// In cs, this message translates to:
  /// **'Dokončeno {date}'**
  String mission_completedOn(String date);

  /// Notice shown after a Quest of a completed Mission was reopened.
  ///
  /// In cs, this message translates to:
  /// **'Bonus byl odebrán, mise je znovu otevřená.'**
  String get mission_bonusWithdrawn;

  /// Empty-state heading of the detail screen.
  ///
  /// In cs, this message translates to:
  /// **'Mise zatím nemá žádné questy'**
  String get mission_emptyTitle;

  /// Empty-state guidance of the detail screen.
  ///
  /// In cs, this message translates to:
  /// **'Klepni na „Přidat quest“ a vyvěs první krok.'**
  String get mission_emptyBody;

  /// Title of the Mission deletion confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Smazat misi?'**
  String get mission_deleteTitle;

  /// Body of the Mission deletion confirmation naming the Quest count.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{Mise „{name}“ bude smazána. Už získané XP ti zůstanou.} one{Mise „{name}“ bude smazána včetně {count} questu. Už získané XP ti zůstanou.} other{Mise „{name}“ bude smazána včetně {count} questů. Už získané XP ti zůstanou.}}'**
  String mission_deleteBody(String name, int count);

  /// Title of the Settings_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get settings_title;

  /// Group label.
  ///
  /// In cs, this message translates to:
  /// **'Profil'**
  String get settings_groupProfile;

  /// Group label.
  ///
  /// In cs, this message translates to:
  /// **'Jazyk'**
  String get settings_groupLanguage;

  /// Group label.
  ///
  /// In cs, this message translates to:
  /// **'Vzhled'**
  String get settings_groupAppearance;

  /// Group label.
  ///
  /// In cs, this message translates to:
  /// **'Pravidelné mise'**
  String get settings_groupRules;

  /// Group label of the temporary display-font picker.
  ///
  /// In cs, this message translates to:
  /// **'Dočasné'**
  String get settings_groupTemporary;

  /// Small text next to the Temporary group label.
  ///
  /// In cs, this message translates to:
  /// **'zmizí po výběru'**
  String get settings_temporaryHint;

  /// Group label.
  ///
  /// In cs, this message translates to:
  /// **'O aplikaci'**
  String get settings_groupAbout;

  /// Label of the hero name field.
  ///
  /// In cs, this message translates to:
  /// **'Jméno hrdiny'**
  String get settings_heroNameLabel;

  /// Placeholder of the hero name field.
  ///
  /// In cs, this message translates to:
  /// **'Jak ti máme říkat?'**
  String get settings_heroNamePlaceholder;

  /// Character counter of the hero name field.
  ///
  /// In cs, this message translates to:
  /// **'{current} / {max}'**
  String settings_heroNameCounter(int current, int max);

  /// Total_XP in small type next to the hero name.
  ///
  /// In cs, this message translates to:
  /// **'Celkem {xp} XP'**
  String settings_totalXp(int xp);

  /// Segment label; language names stay native in both languages.
  ///
  /// In cs, this message translates to:
  /// **'Čeština'**
  String get settings_languageCs;

  /// Segment label; language names stay native in both languages.
  ///
  /// In cs, this message translates to:
  /// **'English'**
  String get settings_languageEn;

  /// Theme segment.
  ///
  /// In cs, this message translates to:
  /// **'Světlý'**
  String get settings_themeLight;

  /// Theme segment.
  ///
  /// In cs, this message translates to:
  /// **'Tmavý'**
  String get settings_themeDark;

  /// Theme segment.
  ///
  /// In cs, this message translates to:
  /// **'Systém'**
  String get settings_themeSystem;

  /// Version line in the About group.
  ///
  /// In cs, this message translates to:
  /// **'verze {version}'**
  String settings_version(String version);

  /// Number of recurring rules next to the group label.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} aktivní} few{{count} aktivní} other{{count} aktivních}}'**
  String settings_rulesActive(int count);

  /// Dashed add row in the rules list.
  ///
  /// In cs, this message translates to:
  /// **'Přidat pravidelnou misi'**
  String get rule_addRow;

  /// Help line under the add row.
  ///
  /// In cs, this message translates to:
  /// **'Ručně vyvěšená mise nahradí nejbližší automatickou.'**
  String get rule_addHint;

  /// Pill on a rule row.
  ///
  /// In cs, this message translates to:
  /// **'Vyvěsit teď'**
  String get rule_postNow;

  /// Dimmed pill on a rule row that has an open Instance.
  ///
  /// In cs, this message translates to:
  /// **'Vyvěšeno'**
  String get rule_posted;

  /// Cadence chip.
  ///
  /// In cs, this message translates to:
  /// **'Denně'**
  String get rule_cadenceDaily;

  /// Cadence chip.
  ///
  /// In cs, this message translates to:
  /// **'Týdně'**
  String get rule_cadenceWeekly;

  /// Cadence chip.
  ///
  /// In cs, this message translates to:
  /// **'Každé 2 týdny'**
  String get rule_cadenceBiweekly;

  /// Cadence chip.
  ///
  /// In cs, this message translates to:
  /// **'Měsíčně'**
  String get rule_cadenceMonthly;

  /// Cadence chip.
  ///
  /// In cs, this message translates to:
  /// **'Čtvrtletně'**
  String get rule_cadenceQuarterly;

  /// Cadence chip.
  ///
  /// In cs, this message translates to:
  /// **'Ročně'**
  String get rule_cadenceYearly;

  /// Cadence part of a rule row line for Daily.
  ///
  /// In cs, this message translates to:
  /// **'Denně'**
  String get rule_detailDaily;

  /// Cadence part of a rule row line; weekday is a localized weekday name.
  ///
  /// In cs, this message translates to:
  /// **'Týdně, {weekday}'**
  String rule_detailWeekly(String weekday);

  /// Cadence part of a rule row line; weekday is a localized weekday name.
  ///
  /// In cs, this message translates to:
  /// **'Každé 2 týdny, {weekday}'**
  String rule_detailBiweekly(String weekday);

  /// Cadence part of a rule row line.
  ///
  /// In cs, this message translates to:
  /// **'Měsíčně, {day}. den'**
  String rule_detailMonthly(int day);

  /// Cadence part of a rule row line; date is formatted day and month.
  ///
  /// In cs, this message translates to:
  /// **'Čtvrtletně, {date}'**
  String rule_detailQuarterly(String date);

  /// Cadence part of a rule row line; date is formatted day and month.
  ///
  /// In cs, this message translates to:
  /// **'Ročně, {date}'**
  String rule_detailYearly(String date);

  /// Rule row line; cadence is the rule_detail* text, date the formatted Next_Occurrence.
  ///
  /// In cs, this message translates to:
  /// **'{cadence} · {count, plural, one{{count} quest} few{{count} questy} other{{count} questů}} · příště {date}'**
  String rule_line(String cadence, int count, String date);

  /// Rule row line after a manual posting skipped the nearest automatic one.
  ///
  /// In cs, this message translates to:
  /// **'{cadence} · {count, plural, one{{count} quest} few{{count} questy} other{{count} questů}} · ručně, příště {date}'**
  String rule_lineManual(String cadence, int count, String date);

  /// Snackbar after posting a rule by hand.
  ///
  /// In cs, this message translates to:
  /// **'Mise „{name}“ vyvěšena.'**
  String rule_postedMessage(String name);

  /// Sentence appended to the posted message when PostResult.skippedNextPosting.
  ///
  /// In cs, this message translates to:
  /// **'Nejbližší plánované vyvěšení se přeskočí.'**
  String get rule_postedSkippedNote;

  /// Sentence appended to the posted message when PostResult.closedPreviousInstance.
  ///
  /// In cs, this message translates to:
  /// **'Nedokončená předchozí mise byla uzavřena bez bonusu.'**
  String get rule_postedClosedNote;

  /// Rule_Sheet title in create mode.
  ///
  /// In cs, this message translates to:
  /// **'Pravidelná mise'**
  String get rule_sheetTitle;

  /// Rule_Sheet title in edit mode.
  ///
  /// In cs, this message translates to:
  /// **'Upravit pravidlo'**
  String get rule_sheetEditTitle;

  /// Label of the rule name field.
  ///
  /// In cs, this message translates to:
  /// **'Název mise'**
  String get rule_nameLabel;

  /// Label above the Cadence chips.
  ///
  /// In cs, this message translates to:
  /// **'Opakování'**
  String get rule_cadenceLabel;

  /// Label of the posting-day row.
  ///
  /// In cs, this message translates to:
  /// **'Vyvěsit vždy'**
  String get rule_postingDayLabel;

  /// Value of the posting-day row for Monthly.
  ///
  /// In cs, this message translates to:
  /// **'{day}. den v měsíci'**
  String rule_postingMonthDay(int day);

  /// Title of the weekday picker.
  ///
  /// In cs, this message translates to:
  /// **'Den v týdnu'**
  String get rule_postingDayWeekdayTitle;

  /// Title of the day-of-month picker (1 to 28).
  ///
  /// In cs, this message translates to:
  /// **'Den v měsíci'**
  String get rule_postingDayMonthTitle;

  /// Title of the date picker for Quarterly and Yearly.
  ///
  /// In cs, this message translates to:
  /// **'Datum'**
  String get rule_postingDayDateTitle;

  /// Help line in the Rule_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Nedokončené questy z minulého období se nepřenášejí. Ruční vyvěšení (v Nastavení) nahradí nejbližší automatické.'**
  String get rule_helpNoCarryOver;

  /// Note in the Rule_Sheet edit mode.
  ///
  /// In cs, this message translates to:
  /// **'Změny se projeví až u příště vyvěšené mise.'**
  String get rule_editNote;

  /// Primary button of the Rule_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Uložit pravidlo'**
  String get rule_saveAction;

  /// Destructive button of the Rule_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Smazat pravidlo'**
  String get rule_deleteAction;

  /// Title of the rule deletion confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Smazat pravidlo?'**
  String get rule_deleteTitle;

  /// Body of the rule deletion confirmation.
  ///
  /// In cs, this message translates to:
  /// **'Právě vyvěšená mise zůstane, ale podle pravidla „{name}“ se už další mise vyvěšovat nebudou.'**
  String rule_deleteBody(String name);

  /// Row label in the Temporary group and title of the Font_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Písmo titulků'**
  String get font_rowLabel;

  /// Sample text set in each font's own face.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka · +25'**
  String get font_sample;

  /// Help line of the Font_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Mění jen titulky a čísla — text a ovládání zůstávají ve Figtree. Volba se projeví okamžitě v celé aplikaci.'**
  String get font_help;

  /// Font name (proper noun).
  ///
  /// In cs, this message translates to:
  /// **'Figtree'**
  String get font_nameFigtree;

  /// Font name (proper noun).
  ///
  /// In cs, this message translates to:
  /// **'Bricolage Grotesque'**
  String get font_nameBricolage;

  /// Font name (proper noun).
  ///
  /// In cs, this message translates to:
  /// **'Sora'**
  String get font_nameSora;

  /// Font name (proper noun).
  ///
  /// In cs, this message translates to:
  /// **'Outfit'**
  String get font_nameOutfit;

  /// Font name (proper noun).
  ///
  /// In cs, this message translates to:
  /// **'Unbounded'**
  String get font_nameUnbounded;

  /// Font name (proper noun).
  ///
  /// In cs, this message translates to:
  /// **'Cinzel'**
  String get font_nameCinzel;

  /// Two-word character note.
  ///
  /// In cs, this message translates to:
  /// **'Klidné, univerzální'**
  String get font_noteFigtree;

  /// Two-word character note.
  ///
  /// In cs, this message translates to:
  /// **'Osobitý grotesk'**
  String get font_noteBricolage;

  /// Two-word character note.
  ///
  /// In cs, this message translates to:
  /// **'Geometrický, technický'**
  String get font_noteSora;

  /// Two-word character note.
  ///
  /// In cs, this message translates to:
  /// **'Měkký geometrický'**
  String get font_noteOutfit;

  /// Two-word character note.
  ///
  /// In cs, this message translates to:
  /// **'Široký, herní'**
  String get font_noteUnbounded;

  /// Two-word character note.
  ///
  /// In cs, this message translates to:
  /// **'Tesané kapitálky'**
  String get font_noteCinzel;

  /// FieldError.required.
  ///
  /// In cs, this message translates to:
  /// **'Zadej název.'**
  String get error_nameRequired;

  /// FieldError.tooLong.
  ///
  /// In cs, this message translates to:
  /// **'Název může mít nejvýše 80 znaků.'**
  String get error_nameTooLong;

  /// FieldError.noteTooLong.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka může mít nejvýše 500 znaků.'**
  String get error_noteTooLong;

  /// FieldError.heroNameTooLong.
  ///
  /// In cs, this message translates to:
  /// **'Jméno může mít nejvýše 40 znaků.'**
  String get error_heroNameTooLong;

  /// FieldError.noQuestTemplate.
  ///
  /// In cs, this message translates to:
  /// **'Přidej alespoň jeden quest s názvem.'**
  String get error_noQuestTemplate;

  /// FieldError.missionNotOpen.
  ///
  /// In cs, this message translates to:
  /// **'Tato mise už není otevřená. Vyber jinou, nebo žádnou.'**
  String get error_missionNotOpen;

  /// DomainError ValidationError.
  ///
  /// In cs, this message translates to:
  /// **'Zadaná hodnota není platná.'**
  String get error_validation;

  /// DomainError NotFoundError and InvalidStateError.
  ///
  /// In cs, this message translates to:
  /// **'Položka se mezitím změnila. Seznam jsme obnovili.'**
  String get error_itemChanged;

  /// DomainError StorageError; shown with a retry action.
  ///
  /// In cs, this message translates to:
  /// **'Data se nepodařilo uložit. Nic se nezměnilo.'**
  String get error_storage;

  /// Fallback for any unexpected error.
  ///
  /// In cs, this message translates to:
  /// **'Něco se pokazilo.'**
  String get error_unknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
