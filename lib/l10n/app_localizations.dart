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

  /// Label of the Settings tab in the bottom tab bar.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get app_tabSettings;

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

  /// XP figure with a plus sign, e.g. on cards and effort options.
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

  /// Board section for the Quests to focus on today.
  ///
  /// In cs, this message translates to:
  /// **'Dnes'**
  String get board_todaySection;

  /// Board section where new Quests land.
  ///
  /// In cs, this message translates to:
  /// **'Todo'**
  String get board_todoSection;

  /// Hint in the empty Today section.
  ///
  /// In cs, this message translates to:
  /// **'Přetáhni sem quest, na který se dnes chceš soustředit.'**
  String get board_todayEmpty;

  /// Hint in the empty Todo section.
  ///
  /// In cs, this message translates to:
  /// **'Nové questy se vyvěsí sem.'**
  String get board_todoEmpty;

  /// Label of the Board section picker in the Quest sheet.
  ///
  /// In cs, this message translates to:
  /// **'Nástěnka'**
  String get quest_boardLabel;

  /// Option that keeps a Mission Quest off the Board.
  ///
  /// In cs, this message translates to:
  /// **'Mimo nástěnku'**
  String get quest_boardNone;

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
  /// **'Questy, které patří do mise, najdeš v záložce Mise. Klepni na tlačítko + a vyvěs vlastní quest — třeba něco, co jsi dnes stejně chtěl udělat. Za každý splněný získáš XP.'**
  String get board_emptyBody;

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

  /// Label of the Deadline field of the Quest sheet, and of its date chip before a date is chosen.
  ///
  /// In cs, this message translates to:
  /// **'Termín'**
  String get quest_deadlineLabel;

  /// Chip that clears the Deadline of a Quest.
  ///
  /// In cs, this message translates to:
  /// **'Bez termínu'**
  String get quest_deadlineNone;

  /// Help under the Deadline field: the Quest shows in the calendar as an event.
  ///
  /// In cs, this message translates to:
  /// **'Quest se zobrazí v kalendáři jako událost.'**
  String get quest_deadlineLinkedHint;

  /// Deadline of an open Quest on its card; date is formatted in the locale.
  ///
  /// In cs, this message translates to:
  /// **'Termín {date}'**
  String quest_dueOn(String date);

  /// Overdue Deadline of an open Quest on its card; date is formatted in the locale.
  ///
  /// In cs, this message translates to:
  /// **'Po termínu: {date}'**
  String quest_overdueOn(String date);

  /// Effort step 1 name; shown only while creating or editing a quest, never in a list.
  ///
  /// In cs, this message translates to:
  /// **'Chvilka'**
  String get quest_effortMoment;

  /// Effort step 2 name.
  ///
  /// In cs, this message translates to:
  /// **'Hodinka'**
  String get quest_effortHour;

  /// Effort step 3 name.
  ///
  /// In cs, this message translates to:
  /// **'Část dne'**
  String get quest_effortPart;

  /// Effort step 4 name.
  ///
  /// In cs, this message translates to:
  /// **'Celý den'**
  String get quest_effortDay;

  /// Time description of effort step 1.
  ///
  /// In cs, this message translates to:
  /// **'do ~30 min'**
  String get quest_effortMomentTime;

  /// Time description of effort step 2.
  ///
  /// In cs, this message translates to:
  /// **'do ~2 h'**
  String get quest_effortHourTime;

  /// Time description of effort step 3.
  ///
  /// In cs, this message translates to:
  /// **'2–4 h'**
  String get quest_effortPartTime;

  /// Time description of effort step 4.
  ///
  /// In cs, this message translates to:
  /// **'celý den'**
  String get quest_effortDayTime;

  /// Hint under the effort picker: choose by time, go one step up for trips, waiting or unpleasant tasks.
  ///
  /// In cs, this message translates to:
  /// **'Zvol podle toho, kolik času ti to zabere. Cesta, čekání nebo něco nepříjemného? Klidně o stupeň výš — za námahu patří víc XP.'**
  String get quest_effortHint;

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

  /// Semantic label of the effort pips; never names the step.
  ///
  /// In cs, this message translates to:
  /// **'Námaha {step} ze {total}'**
  String a11y_effort(int step, int total);

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

  /// Label of the effort picker.
  ///
  /// In cs, this message translates to:
  /// **'Námaha'**
  String get quest_effortLabel;

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

  /// Snackbar after a Quest saved from the Board was assigned to a Mission, so it left the Board.
  ///
  /// In cs, this message translates to:
  /// **'Přidáno do mise {name}'**
  String quest_addedToMission(String name);

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

  /// Hint under the disabled effort picker and Mission picker when a done Quest is edited.
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

  /// Row in the About group that opens the open-source licences page.
  ///
  /// In cs, this message translates to:
  /// **'Licence'**
  String get settings_licenses;

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

  /// Label of the Calendar tab in the bottom tab bar.
  ///
  /// In cs, this message translates to:
  /// **'Kalendář'**
  String get app_tabCalendar;

  /// Button that jumps the month view to the current month.
  ///
  /// In cs, this message translates to:
  /// **'Dnes'**
  String get calendar_today;

  /// Accessibility label of the previous-month arrow.
  ///
  /// In cs, this message translates to:
  /// **'Předchozí měsíc'**
  String get calendar_prevMonth;

  /// Accessibility label of the next-month arrow.
  ///
  /// In cs, this message translates to:
  /// **'Další měsíc'**
  String get calendar_nextMonth;

  /// Accessibility label of the month title that opens the month picker.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat měsíc a rok'**
  String get calendar_pickMonth;

  /// Accessibility label of the search button and hint of the search field.
  ///
  /// In cs, this message translates to:
  /// **'Hledat události'**
  String get calendar_search;

  /// Accessibility label of the type filter button.
  ///
  /// In cs, this message translates to:
  /// **'Filtrovat podle typu'**
  String get calendar_filter;

  /// Accessibility label of the add buttons of the calendar.
  ///
  /// In cs, this message translates to:
  /// **'Přidat událost'**
  String get calendar_add;

  /// Accessibility label of one day cell: the date and the number of events.
  ///
  /// In cs, this message translates to:
  /// **'{date}, {count, plural, =0{žádné události} one{1 událost} few{{count} události} other{{count} událostí}}'**
  String calendar_cellLabel(String date, int count);

  /// Label in a day cell for the events that do not fit.
  ///
  /// In cs, this message translates to:
  /// **'+{count}'**
  String calendar_moreEvents(int count);

  /// Title of the month picker sheet.
  ///
  /// In cs, this message translates to:
  /// **'Měsíc a rok'**
  String get calendar_monthPickerTitle;

  /// Accessibility label of the previous-year button in the month picker.
  ///
  /// In cs, this message translates to:
  /// **'Předchozí rok'**
  String get calendar_prevYear;

  /// Accessibility label of the next-year button in the month picker.
  ///
  /// In cs, this message translates to:
  /// **'Další rok'**
  String get calendar_nextYear;

  /// Title of the type filter sheet.
  ///
  /// In cs, this message translates to:
  /// **'Typy událostí'**
  String get calendar_filterTitle;

  /// Primary button of the type filter sheet.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo'**
  String get calendar_filterDone;

  /// Button that turns every event type on again.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit všechny typy'**
  String get calendar_filterShowAll;

  /// Message over an empty month when no event type is selected in the filter.
  ///
  /// In cs, this message translates to:
  /// **'Filtr schovává všechny události.'**
  String get calendar_filterHidesAll;

  /// Name of the event type dance.
  ///
  /// In cs, this message translates to:
  /// **'Tanec'**
  String get calendar_typeDance;

  /// Name of the event type work.
  ///
  /// In cs, this message translates to:
  /// **'Práce'**
  String get calendar_typeWork;

  /// Name of the event type birthday.
  ///
  /// In cs, this message translates to:
  /// **'Narozeniny'**
  String get calendar_typeBirthday;

  /// Name of the event type nameDay.
  ///
  /// In cs, this message translates to:
  /// **'Jmeniny'**
  String get calendar_typeNameDay;

  /// Name of the event type publicHoliday.
  ///
  /// In cs, this message translates to:
  /// **'Státní svátek'**
  String get calendar_typePublicHoliday;

  /// Name of the event type notableDay.
  ///
  /// In cs, this message translates to:
  /// **'Významný den'**
  String get calendar_typeNotableDay;

  /// Name of the event type date.
  ///
  /// In cs, this message translates to:
  /// **'Rande'**
  String get calendar_typeDate;

  /// Name of the event type meeting.
  ///
  /// In cs, this message translates to:
  /// **'Meeting'**
  String get calendar_typeMeeting;

  /// Name of the event type seminar.
  ///
  /// In cs, this message translates to:
  /// **'Seminář'**
  String get calendar_typeSeminar;

  /// Name of the event type lesson.
  ///
  /// In cs, this message translates to:
  /// **'Lekce'**
  String get calendar_typeLesson;

  /// Name of the event type of a Quest's Deadline.
  ///
  /// In cs, this message translates to:
  /// **'Quest'**
  String get calendar_typeQuest;

  /// Label of an all-day event and of the all-day switch.
  ///
  /// In cs, this message translates to:
  /// **'Celý den'**
  String get calendar_allDay;

  /// Number of events under the date in the day sheet.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, =0{Žádné události} one{1 událost} few{{count} události} other{{count} událostí}}'**
  String calendar_dayEvents(int count);

  /// Text in the day sheet when the day has no events.
  ///
  /// In cs, this message translates to:
  /// **'Žádné události'**
  String get calendar_dayEmpty;

  /// Label of the start of an event.
  ///
  /// In cs, this message translates to:
  /// **'Začátek'**
  String get calendar_start;

  /// Label of the end of an event.
  ///
  /// In cs, this message translates to:
  /// **'Konec'**
  String get calendar_end;

  /// Label of the note row of an event.
  ///
  /// In cs, this message translates to:
  /// **'Podrobnosti'**
  String get calendar_notes;

  /// Label of the repeat row of an event.
  ///
  /// In cs, this message translates to:
  /// **'Opakovat'**
  String get calendar_repeat;

  /// Label of the location row of an event.
  ///
  /// In cs, this message translates to:
  /// **'Adresa'**
  String get calendar_location;

  /// Shown for an empty note or location.
  ///
  /// In cs, this message translates to:
  /// **'Nenastaveno'**
  String get calendar_notSet;

  /// Status line of a completed event.
  ///
  /// In cs, this message translates to:
  /// **'Splněno v {time} · +{xp} XP'**
  String calendar_completedAt(String time, int xp);

  /// Edit button and menu entry of an event.
  ///
  /// In cs, this message translates to:
  /// **'Upravit'**
  String get calendar_edit;

  /// Menu entry that copies an event into a new one.
  ///
  /// In cs, this message translates to:
  /// **'Duplikovat'**
  String get calendar_duplicate;

  /// Accessibility label of the event menu button.
  ///
  /// In cs, this message translates to:
  /// **'Další akce'**
  String get calendar_menu;

  /// Snackbar after tapping the location of an event.
  ///
  /// In cs, this message translates to:
  /// **'Adresa zkopírována'**
  String get calendar_locationCopied;

  /// Message when an open event was deleted.
  ///
  /// In cs, this message translates to:
  /// **'Událost už neexistuje.'**
  String get calendar_eventGone;

  /// Repeat choice: no repeat.
  ///
  /// In cs, this message translates to:
  /// **'Nikdy'**
  String get calendar_repeatNever;

  /// Repeat choice: daily.
  ///
  /// In cs, this message translates to:
  /// **'Každý den'**
  String get calendar_repeatDaily;

  /// Repeat choice: weekly.
  ///
  /// In cs, this message translates to:
  /// **'Každý týden'**
  String get calendar_repeatWeekly;

  /// Repeat choice: monthly.
  ///
  /// In cs, this message translates to:
  /// **'Každý měsíc'**
  String get calendar_repeatMonthly;

  /// Repeat choice: yearly.
  ///
  /// In cs, this message translates to:
  /// **'Každý rok'**
  String get calendar_repeatYearly;

  /// Shown for a built-in event that follows Easter.
  ///
  /// In cs, this message translates to:
  /// **'Každý rok podle Velikonoc'**
  String get calendar_repeatEaster;

  /// Shown for a built-in event on the n-th weekday of a month.
  ///
  /// In cs, this message translates to:
  /// **'Každý rok podle dne v týdnu'**
  String get calendar_repeatNth;

  /// Repeat in words, daily.
  ///
  /// In cs, this message translates to:
  /// **'každý den'**
  String get calendar_repeatDescDaily;

  /// Repeat in words, weekly.
  ///
  /// In cs, this message translates to:
  /// **'{weekday} každý týden'**
  String calendar_repeatDescWeekly(String weekday);

  /// Repeat in words, monthly.
  ///
  /// In cs, this message translates to:
  /// **'každý měsíc {day}.'**
  String calendar_repeatDescMonthly(int day);

  /// Repeat in words, yearly.
  ///
  /// In cs, this message translates to:
  /// **'každý rok {date}'**
  String calendar_repeatDescYearly(String date);

  /// Repeat in words, relative to Easter.
  ///
  /// In cs, this message translates to:
  /// **'každý rok podle Velikonoc'**
  String get calendar_repeatDescEaster;

  /// Repeat in words, n-th weekday of a month.
  ///
  /// In cs, this message translates to:
  /// **'každý rok, {ordinal} {weekday} ({month})'**
  String calendar_repeatDescNth(String ordinal, String weekday, String month);

  /// Repeat in words with its end date.
  ///
  /// In cs, this message translates to:
  /// **'{repeat}, do {date}'**
  String calendar_repeatUntil(String repeat, String date);

  /// Label of the repeat end row in the form.
  ///
  /// In cs, this message translates to:
  /// **'Konec opakování'**
  String get calendar_repeatEnds;

  /// Value of the repeat end row when there is none.
  ///
  /// In cs, this message translates to:
  /// **'Bez konce'**
  String get calendar_repeatNoEnd;

  /// Title of the form for a new event.
  ///
  /// In cs, this message translates to:
  /// **'Nová událost'**
  String get calendar_formCreateTitle;

  /// Title of the form for an existing event.
  ///
  /// In cs, this message translates to:
  /// **'Upravit událost'**
  String get calendar_formEditTitle;

  /// Hint of the name field.
  ///
  /// In cs, this message translates to:
  /// **'Název události'**
  String get calendar_formNameHint;

  /// Hint of the note field.
  ///
  /// In cs, this message translates to:
  /// **'Přidat podrobnosti'**
  String get calendar_formNoteHint;

  /// Hint of the location field.
  ///
  /// In cs, this message translates to:
  /// **'Adresa'**
  String get calendar_formLocationHint;

  /// Label above the type picker.
  ///
  /// In cs, this message translates to:
  /// **'Typ události'**
  String get calendar_formType;

  /// Label of the switch that puts the event on the Board.
  ///
  /// In cs, this message translates to:
  /// **'Na nástěnku'**
  String get calendar_onBoard;

  /// XP the event would award, under the board switch.
  ///
  /// In cs, this message translates to:
  /// **'Za splnění: +{xp} XP'**
  String calendar_onBoardXp(int xp);

  /// Screen reader label of a suggested address under the address field.
  ///
  /// In cs, this message translates to:
  /// **'Použít adresu {address}'**
  String calendar_addressSuggestion(String address);

  /// Inline error of an empty name.
  ///
  /// In cs, this message translates to:
  /// **'Zadej název události.'**
  String get calendar_errorName;

  /// Inline error of a name over 80 characters.
  ///
  /// In cs, this message translates to:
  /// **'Název je příliš dlouhý.'**
  String get calendar_errorNameLong;

  /// Inline error when the end is before the start.
  ///
  /// In cs, this message translates to:
  /// **'Konec nemůže být před začátkem.'**
  String get calendar_errorEnd;

  /// Inline error when the repeat end is before the start.
  ///
  /// In cs, this message translates to:
  /// **'Konec opakování nemůže být před začátkem.'**
  String get calendar_errorRepeatEnd;

  /// Inline error of a note over 500 characters.
  ///
  /// In cs, this message translates to:
  /// **'Podrobnosti jsou příliš dlouhé.'**
  String get calendar_errorNoteLong;

  /// Inline error of a location over 120 characters.
  ///
  /// In cs, this message translates to:
  /// **'Adresa je příliš dlouhá.'**
  String get calendar_errorLocationLong;

  /// Inline error when saving an event fails.
  ///
  /// In cs, this message translates to:
  /// **'Uložení se nepovedlo. Zkus to znovu.'**
  String get calendar_saveFailed;

  /// Title of the delete confirmation of a single event.
  ///
  /// In cs, this message translates to:
  /// **'Smazat událost?'**
  String get calendar_deleteTitle;

  /// Body of the delete confirmation of a single event.
  ///
  /// In cs, this message translates to:
  /// **'Událost „{name}“ se smaže.'**
  String calendar_deleteBody(String name);

  /// Body of the delete sheet of a repeating event.
  ///
  /// In cs, this message translates to:
  /// **'Událost „{name}“ se opakuje. Co chceš smazat?'**
  String calendar_deleteRepeatBody(String name);

  /// Delete choice for a repeating event.
  ///
  /// In cs, this message translates to:
  /// **'Jen tuto událost'**
  String get calendar_deleteOnlyThis;

  /// Delete choice for a repeating event.
  ///
  /// In cs, this message translates to:
  /// **'Tuto a všechny další'**
  String get calendar_deleteThisAndFollowing;

  /// Delete choice for a repeating event.
  ///
  /// In cs, this message translates to:
  /// **'Všechny události v sérii'**
  String get calendar_deleteAll;

  /// Snackbar after deleting an event.
  ///
  /// In cs, this message translates to:
  /// **'Událost „{name}“ smazána'**
  String calendar_deleted(String name);

  /// Snackbar action that restores a deleted event.
  ///
  /// In cs, this message translates to:
  /// **'Zpět'**
  String get calendar_undo;

  /// Snackbar when deleting an event fails.
  ///
  /// In cs, this message translates to:
  /// **'Smazání se nepovedlo.'**
  String get calendar_deleteFailed;

  /// Hint under the empty search field.
  ///
  /// In cs, this message translates to:
  /// **'Napiš název, podrobnosti nebo místo.'**
  String get calendar_searchPrompt;

  /// Text when the search finds nothing.
  ///
  /// In cs, this message translates to:
  /// **'Nic nenalezeno'**
  String get calendar_searchNone;

  /// Accessibility label of the check circle of an open Event_Task.
  ///
  /// In cs, this message translates to:
  /// **'Splnit událost {name}'**
  String a11y_completeEvent(String name);

  /// Accessibility label of the check circle of a completed Event_Task.
  ///
  /// In cs, this message translates to:
  /// **'Vrátit událost {name}'**
  String a11y_reopenEvent(String name);

  /// Announcement after completing an Event_Task.
  ///
  /// In cs, this message translates to:
  /// **'Událost {name} splněna, +{xp} XP'**
  String a11y_eventCompleted(String name, int xp);

  /// Time label of an all-day Event_Task on the Board.
  ///
  /// In cs, this message translates to:
  /// **'Celý den'**
  String get calendar_taskAllDay;

  /// Accessibility label of the button that removes the repeat end date.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit konec opakování'**
  String get calendar_clearRepeatEnd;

  /// Label of the Notes tab in the bottom tab bar.
  ///
  /// In cs, this message translates to:
  /// **'Poznámky'**
  String get app_tabNotes;

  /// Title of the Notes_Screen at the Root_Folder.
  ///
  /// In cs, this message translates to:
  /// **'Poznámky'**
  String get notes_title;

  /// Number of Folders with a correctly pluralised noun.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} složka} few{{count} složky} other{{count} složek}}'**
  String notes_folderCount(int count);

  /// Number of Notes with a correctly pluralised noun.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} poznámka} few{{count} poznámky} other{{count} poznámek}}'**
  String notes_noteCount(int count);

  /// Summary of a Folder_Row that holds nothing.
  ///
  /// In cs, this message translates to:
  /// **'Prázdná složka'**
  String get notes_folderEmpty;

  /// Heading of the Folder section of the Notes_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Složky'**
  String get notes_sectionFolders;

  /// Heading of the Note section of the Notes_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Poznámky'**
  String get notes_sectionNotes;

  /// Title of the empty state of a Folder.
  ///
  /// In cs, this message translates to:
  /// **'Zatím tu nic není'**
  String get notes_emptyTitle;

  /// Body of the empty state of a Folder.
  ///
  /// In cs, this message translates to:
  /// **'Přidej poznámku nebo složku tlačítkem plus.'**
  String get notes_emptyBody;

  /// Title of the Add_Sheet and label of the add button.
  ///
  /// In cs, this message translates to:
  /// **'Přidat'**
  String get notes_addTitle;

  /// Choice in the Add_Sheet that creates a Note.
  ///
  /// In cs, this message translates to:
  /// **'Nová poznámka'**
  String get notes_addNote;

  /// Hint under the new-note choice.
  ///
  /// In cs, this message translates to:
  /// **'Prázdná stránka s editorem'**
  String get notes_addNoteHint;

  /// Choice in the Add_Sheet that creates a Folder, and the title of its Name_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Nová složka'**
  String get notes_addFolder;

  /// Hint under the new-folder choice.
  ///
  /// In cs, this message translates to:
  /// **'Pro třídění poznámek a dalších složek'**
  String get notes_addFolderHint;

  /// Line of the Add_Sheet naming the Current_Folder.
  ///
  /// In cs, this message translates to:
  /// **'Vytvoří se ve složce {place}'**
  String notes_addWhere(String place);

  /// Primary button of the Name_Sheet that creates a Folder.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit složku'**
  String get notes_createFolder;

  /// Label of the name field of the Name_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get notes_nameLabel;

  /// Title of the Name_Sheet that renames a Node.
  ///
  /// In cs, this message translates to:
  /// **'Přejmenovat'**
  String get notes_renameTitle;

  /// Title of the Move_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout'**
  String get notes_moveTitle;

  /// Line under the Move_Sheet title naming the Note that is moved.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka „{name}“'**
  String notes_moveNote(String name);

  /// Line under the Move_Sheet title naming the Folder that is moved.
  ///
  /// In cs, this message translates to:
  /// **'Složka „{name}“'**
  String notes_moveFolder(String name);

  /// Tag of the Root_Folder row in the Move_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'nejvyšší úroveň'**
  String get notes_moveRootTag;

  /// Tag of the row of the current parent in the Move_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'současné umístění'**
  String get notes_moveCurrentTag;

  /// Primary button of the Move_Sheet.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout do složky {name}'**
  String notes_moveConfirm(String name);

  /// Swipe action and menu entry that renames a Node.
  ///
  /// In cs, this message translates to:
  /// **'Přejmenovat'**
  String get notes_actionRename;

  /// Swipe action and menu entry that moves a Node.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout'**
  String get notes_actionMove;

  /// Swipe action that moves a Node to the Trash.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get notes_actionDelete;

  /// Menu entry that moves a Node to the Trash.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout do koše'**
  String get notes_actionTrash;

  /// Title of the warning dialog for a Folder with content.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout složku {name} do koše?'**
  String notes_deleteFolderTitle(String name);

  /// Body of the warning dialog; contents is the counts of Folders and Notes.
  ///
  /// In cs, this message translates to:
  /// **'Složka obsahuje {contents}. Přesunou se do koše i s celým obsahem a po 30 dnech se smažou navždy.'**
  String notes_deleteFolderBody(String contents);

  /// Joins two counts into one phrase.
  ///
  /// In cs, this message translates to:
  /// **'{first} a {second}'**
  String notes_joinAnd(String first, String second);

  /// Destructive button of the warning dialog.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout do koše'**
  String get notes_deleteConfirm;

  /// Snackbar after a Node was moved to the Trash.
  ///
  /// In cs, this message translates to:
  /// **'Přesunuto do koše'**
  String get notes_movedToTrash;

  /// Name of a Note whose text has no line to name it after.
  ///
  /// In cs, this message translates to:
  /// **'Bez názvu'**
  String get notes_untitled;

  /// Snackbar after a notes action failed.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se to provést.'**
  String get notes_errorGeneric;

  /// Snackbar when the Node was removed meanwhile.
  ///
  /// In cs, this message translates to:
  /// **'Tato položka už neexistuje.'**
  String get notes_errorGone;

  /// Semantic label of the Trash button of the Notes_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Koš'**
  String get notes_trashButton;

  /// Title of the Trash_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Koš'**
  String get trash_title;

  /// Number of Trashed_Nodes with a correctly pluralised noun.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} položka} few{{count} položky} other{{count} položek}}'**
  String trash_count(int count);

  /// Information line at the top of the Trash_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Položky zůstávají v koši 30 dní a pak se smažou navždy. Složka se obnoví i s obsahem.'**
  String get trash_info;

  /// Heading of the list of the Trash_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Smazané'**
  String get trash_section;

  /// Second line of a trashed Note: where it came from and when it is purged.
  ///
  /// In cs, this message translates to:
  /// **'z {from} · {when}'**
  String trash_noteLine(String from, String when);

  /// Second line of a trashed Folder.
  ///
  /// In cs, this message translates to:
  /// **'složka, {notes} · z {from} · {when}'**
  String trash_folderLine(String notes, String from, String when);

  /// Time left until the Purge.
  ///
  /// In cs, this message translates to:
  /// **'smaže se za {days, plural, one{1 den} few{{days} dny} other{{days} dní}}'**
  String trash_daysLeft(int days);

  /// Button and swipe action that restores a Trashed_Node.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit'**
  String get trash_restore;

  /// Swipe action that deletes a Trashed_Node permanently.
  ///
  /// In cs, this message translates to:
  /// **'Navždy'**
  String get trash_forever;

  /// Button that deletes every Trashed_Node permanently.
  ///
  /// In cs, this message translates to:
  /// **'Vysypat koš'**
  String get trash_emptyAction;

  /// Title of the empty state of the Trash_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Koš je prázdný'**
  String get trash_emptyStateTitle;

  /// Body of the empty state of the Trash_Screen.
  ///
  /// In cs, this message translates to:
  /// **'Smazané poznámky a složky tu zůstanou 30 dní.'**
  String get trash_emptyStateBody;

  /// Title of the confirmation dialog of the swipe action Navždy.
  ///
  /// In cs, this message translates to:
  /// **'Smazat navždy?'**
  String get trash_foreverTitle;

  /// Body of that dialog.
  ///
  /// In cs, this message translates to:
  /// **'{name} se smaže natrvalo i s obsahem a nepůjde vrátit.'**
  String trash_foreverBody(String name);

  /// Destructive button of that dialog.
  ///
  /// In cs, this message translates to:
  /// **'Smazat navždy'**
  String get trash_foreverConfirm;

  /// Title of the confirmation dialog of Vysypat koš.
  ///
  /// In cs, this message translates to:
  /// **'Vysypat koš?'**
  String get trash_emptyTitle;

  /// Body of that dialog.
  ///
  /// In cs, this message translates to:
  /// **'{count, plural, one{{count} položka se smaže} few{{count} položky se smažou} other{{count} položek se smaže}} natrvalo i s obsahem a nepůjde vrátit.'**
  String trash_emptyBody(int count);

  /// Snackbar after a Trashed_Node was restored.
  ///
  /// In cs, this message translates to:
  /// **'Obnoveno'**
  String get trash_restored;

  /// Screen reader hint of a trashed Note that can be opened.
  ///
  /// In cs, this message translates to:
  /// **'Klepnutím otevřete náhled'**
  String get trash_openHint;

  /// Shown in the preview of a trashed Note that has no text.
  ///
  /// In cs, this message translates to:
  /// **'Prázdná poznámka'**
  String get trash_previewEmpty;

  /// Snackbar after a Trashed_Node was deleted permanently.
  ///
  /// In cs, this message translates to:
  /// **'Smazáno navždy'**
  String get trash_deleted;

  /// Snackbar after the Trash was emptied.
  ///
  /// In cs, this message translates to:
  /// **'Koš je vysypaný'**
  String get trash_emptied;

  /// Button that closes the Note_Editor.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo'**
  String get editor_done;

  /// Hint of an empty Note.
  ///
  /// In cs, this message translates to:
  /// **'Začni psát…'**
  String get editor_hint;

  /// Hint of the empty title field of the Note_Editor.
  ///
  /// In cs, this message translates to:
  /// **'Název'**
  String get editor_titleHint;

  /// Message of the Note_Editor when a save failed.
  ///
  /// In cs, this message translates to:
  /// **'Poznámku se nepodařilo uložit.'**
  String get editor_saveFailed;

  /// Message of the Note_Editor when the text is over the limit.
  ///
  /// In cs, this message translates to:
  /// **'Poznámka je příliš dlouhá, nejvýše 100 000 znaků.'**
  String get editor_tooLong;

  /// Semantic label of the bold button.
  ///
  /// In cs, this message translates to:
  /// **'Tučně'**
  String get editor_fmtBold;

  /// Semantic label of the italic button.
  ///
  /// In cs, this message translates to:
  /// **'Kurzíva'**
  String get editor_fmtItalic;

  /// Semantic label of the heading button.
  ///
  /// In cs, this message translates to:
  /// **'Nadpis'**
  String get editor_fmtHeading;

  /// Semantic label of the bulleted list button.
  ///
  /// In cs, this message translates to:
  /// **'Odrážky'**
  String get editor_fmtList;

  /// Semantic label of the checklist button.
  ///
  /// In cs, this message translates to:
  /// **'Úkoly'**
  String get editor_fmtChecklist;

  /// Semantic label of the quote button.
  ///
  /// In cs, this message translates to:
  /// **'Citace'**
  String get editor_fmtQuote;

  /// Semantic label of the code button.
  ///
  /// In cs, this message translates to:
  /// **'Kód'**
  String get editor_fmtCode;

  /// Semantic label of the link button and title of the link sheet.
  ///
  /// In cs, this message translates to:
  /// **'Odkaz'**
  String get editor_fmtLink;

  /// Label of the address field of the link sheet.
  ///
  /// In cs, this message translates to:
  /// **'Adresa'**
  String get editor_linkLabel;

  /// Primary button of the link sheet.
  ///
  /// In cs, this message translates to:
  /// **'Použít odkaz'**
  String get editor_linkApply;

  /// Semantic label of the Node_Menu button.
  ///
  /// In cs, this message translates to:
  /// **'Nabídka položky'**
  String get a11y_nodeMenu;

  /// Semantic label of a Folder_Row.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít složku {name}'**
  String a11y_openFolder(String name);

  /// Semantic label of a Note_Row.
  ///
  /// In cs, this message translates to:
  /// **'Otevřít poznámku {name}'**
  String a11y_openNote(String name);

  /// Semantic label of the rename action of a row.
  ///
  /// In cs, this message translates to:
  /// **'Přejmenovat {name}'**
  String a11y_renameNode(String name);

  /// Semantic label of the move action of a row.
  ///
  /// In cs, this message translates to:
  /// **'Přesunout {name}'**
  String a11y_moveNode(String name);

  /// Semantic label of the delete action of a row.
  ///
  /// In cs, this message translates to:
  /// **'Smazat {name}'**
  String a11y_trashNode(String name);

  /// Semantic label of the restore action of a Trash row.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit {name}'**
  String a11y_restoreNode(String name);

  /// Semantic label of the permanent delete action of a Trash row.
  ///
  /// In cs, this message translates to:
  /// **'Smazat {name} navždy'**
  String a11y_foreverNode(String name);

  /// Semantic label of a Breadcrumb segment.
  ///
  /// In cs, this message translates to:
  /// **'Přejít na {name}'**
  String a11y_breadcrumbTo(String name);

  /// Semantic label of the check of a checklist item in the Note_Editor.
  ///
  /// In cs, this message translates to:
  /// **'Přepnout splněno'**
  String get a11y_taskToggle;

  /// Title of the Home Screen shortcut guide in Settings.
  ///
  /// In cs, this message translates to:
  /// **'Zkratka na ploše'**
  String get settings_shortcutTitle;

  /// Hint under the guide title.
  ///
  /// In cs, this message translates to:
  /// **'Otevři QuestLog jedním klepnutím rovnou na vybrané obrazovce.'**
  String get settings_shortcutSubtitle;

  /// Label above the choice of the screen the shortcut opens.
  ///
  /// In cs, this message translates to:
  /// **'Kam má ikona otevřít aplikaci?'**
  String get settings_shortcutPickLabel;

  /// Button that copies the questlog:// link.
  ///
  /// In cs, this message translates to:
  /// **'Zkopírovat odkaz'**
  String get settings_shortcutCopyLink;

  /// Snackbar after the link was copied.
  ///
  /// In cs, this message translates to:
  /// **'Odkaz zkopírován'**
  String get settings_shortcutCopied;

  /// Guide step 1.
  ///
  /// In cs, this message translates to:
  /// **'Zkopíruj odkaz výše.'**
  String get settings_shortcutStep1;

  /// Guide step 2; Zkratky is the Czech name of the iOS Shortcuts app.
  ///
  /// In cs, this message translates to:
  /// **'Otevři na iPhonu aplikaci Zkratky a klepni na +.'**
  String get settings_shortcutStep2;

  /// Guide step 3.
  ///
  /// In cs, this message translates to:
  /// **'Klepni na Přidat akci, vyhledej Otevřít URL a vyber ji.'**
  String get settings_shortcutStep3;

  /// Guide step 4.
  ///
  /// In cs, this message translates to:
  /// **'Do pole s adresou vlož zkopírovaný odkaz.'**
  String get settings_shortcutStep4;

  /// Guide step 5.
  ///
  /// In cs, this message translates to:
  /// **'Klepni na ikonu sdílení a zvol Přidat na plochu.'**
  String get settings_shortcutStep5;

  /// Guide step 6.
  ///
  /// In cs, this message translates to:
  /// **'Pojmenuj zkratku, případně změň ikonu, a potvrď tlačítkem Přidat.'**
  String get settings_shortcutStep6;

  /// Closing note of the guide.
  ///
  /// In cs, this message translates to:
  /// **'Funguje jen na iPhonu. Hotovou ikonu pak můžeš přesunout i do složky.'**
  String get settings_shortcutNote;

  /// Group label.
  ///
  /// In cs, this message translates to:
  /// **'Data'**
  String get settings_groupData;

  /// Row that saves all app data into one file and opens the share sheet.
  ///
  /// In cs, this message translates to:
  /// **'Exportovat data'**
  String get settings_exportTitle;

  /// Explains the export row.
  ///
  /// In cs, this message translates to:
  /// **'Uloží všechna data do jednoho souboru, který přeneseš jinam.'**
  String get settings_exportSubtitle;

  /// Snackbar shown when the export could not be written or shared.
  ///
  /// In cs, this message translates to:
  /// **'Export se nepodařil. Zkus to prosím znovu.'**
  String get settings_exportFailed;
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
