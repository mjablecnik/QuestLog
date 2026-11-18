// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Questlog';

  @override
  String get app_splashLoading => 'Preparing your board…';

  @override
  String get app_tabQuests => 'Quests';

  @override
  String get app_tabMissions => 'Missions';

  @override
  String get app_tabSettings => 'Settings';

  @override
  String app_postedMissions(String names) {
    return 'Posted: $names';
  }

  @override
  String get app_reconcileFailed => 'Recurring missions could not be checked.';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_save => 'Save';

  @override
  String get common_retry => 'Try again';

  @override
  String get common_ok => 'OK';

  @override
  String get common_close => 'Close';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_back => 'Back';

  @override
  String get common_discard => 'Discard';

  @override
  String get common_remove => 'Remove';

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
      other: '$count quests',
      one: '$count quest',
    );
    return '$_temp0';
  }

  @override
  String get common_loading => 'Loading…';

  @override
  String get common_today => 'today';

  @override
  String get common_yesterday => 'yesterday';

  @override
  String hero_level(int level) {
    return 'Level $level';
  }

  @override
  String hero_nameAndLevel(String name, int level) {
    return '$name · Level $level';
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

    return '$xpString XP to level $level';
  }

  @override
  String hero_levelBadgeLabel(int level) {
    return 'Level $level';
  }

  @override
  String hero_progressLabel(int current, int threshold) {
    final intl.NumberFormat currentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String currentString = currentNumberFormat.format(current);
    final intl.NumberFormat thresholdNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String thresholdString = thresholdNumberFormat.format(threshold);

    return 'Level progress: $currentString of $thresholdString XP';
  }

  @override
  String get board_title => 'Board';

  @override
  String board_subtitle(int count, String date) {
    return '$count open · $date';
  }

  @override
  String get board_openSection => 'Posted quests';

  @override
  String get board_doneSection => 'Done today';

  @override
  String board_doneSummary(int count, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$_temp0 · $xpString XP';
  }

  @override
  String get board_emptyTitle => 'The board is empty';

  @override
  String get board_emptyBody =>
      'Tap the + button to post your first quest — maybe something you meant to do today anyway. Every one you finish earns XP.';

  @override
  String get board_noMission => 'no mission';

  @override
  String get board_swipeHint =>
      'Swipe left to edit or delete · tap the circle to complete';

  @override
  String board_rewardWithdrawn(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP withdrawn';
  }

  @override
  String board_rewardWithdrawnMissionReopened(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP withdrawn · mission reopened';
  }

  @override
  String quest_completedTodayAt(String time) {
    return 'today $time';
  }

  @override
  String get quest_completedYesterday => 'yesterday';

  @override
  String quest_completedOn(String date) {
    return '$date';
  }

  @override
  String get quest_difficultyEasy => 'Easy';

  @override
  String get quest_difficultyNormal => 'Normal';

  @override
  String get quest_difficultyHard => 'Hard';

  @override
  String get a11y_openSettings => 'Open settings';

  @override
  String get a11y_addQuest => 'Post a quest';

  @override
  String get a11y_addMission => 'Start a mission';

  @override
  String a11y_completeQuest(String name) {
    return 'Complete quest $name';
  }

  @override
  String a11y_reopenQuest(String name) {
    return 'Reopen quest $name';
  }

  @override
  String a11y_dragHandle(String name) {
    return 'Reorder quest $name';
  }

  @override
  String get a11y_dragHint => 'Press and hold, then drag';

  @override
  String a11y_editQuest(String name) {
    return 'Edit quest $name';
  }

  @override
  String a11y_deleteQuest(String name) {
    return 'Delete quest $name';
  }

  @override
  String a11y_editMission(String name) {
    return 'Edit mission $name';
  }

  @override
  String a11y_deleteMission(String name) {
    return 'Delete mission $name';
  }

  @override
  String a11y_openMission(String name) {
    return 'Open mission $name';
  }

  @override
  String get a11y_missionMenu => 'Mission menu';

  @override
  String a11y_questMission(String name) {
    return 'Mission $name';
  }

  @override
  String a11y_difficulty(String name) {
    return 'Difficulty: $name';
  }

  @override
  String a11y_missionProgress(int done, int total) {
    return '$done of $total quests done';
  }

  @override
  String a11y_questCompleted(String name, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Quest $name completed, +$xpString XP';
  }

  @override
  String a11y_questReopened(String name) {
    return 'Quest $name reopened';
  }

  @override
  String a11y_missionCompleted(String name, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Mission $name completed, bonus +$xpString XP';
  }

  @override
  String a11y_missionReopened(String name) {
    return 'Mission $name reopened';
  }

  @override
  String a11y_levelUp(int level) {
    return 'Level up, level $level';
  }

  @override
  String a11y_selectedOption(String label) {
    return '$label, selected';
  }

  @override
  String get a11y_dismissReward => 'Dismiss reward';

  @override
  String get a11y_closeSheet => 'Close form';

  @override
  String get a11y_removeRow => 'Remove row';

  @override
  String get a11y_pickPostingDay => 'Pick the posting day';

  @override
  String get a11y_currentChoice => 'current choice';

  @override
  String get quest_sheetCreateTitle => 'New quest';

  @override
  String get quest_sheetEditTitle => 'Edit quest';

  @override
  String get quest_nameLabel => 'What needs doing';

  @override
  String get quest_namePlaceholder => 'Hang the laundry';

  @override
  String get quest_difficultyLabel => 'Difficulty';

  @override
  String get quest_missionLabel => 'Part of a mission';

  @override
  String get quest_missionNone => 'No mission';

  @override
  String get quest_noteLabel => 'Note';

  @override
  String get quest_notePlaceholder =>
      'Optional — where, how, what not to forget…';

  @override
  String get quest_createAction => 'Post quest';

  @override
  String get quest_doneLockedHint =>
      'Only the name and note of a done quest can be changed.';

  @override
  String get quest_deleteTitle => 'Delete quest?';

  @override
  String quest_deleteBody(String name) {
    return 'Quest “$name” will be deleted.';
  }

  @override
  String quest_deleteDoneBody(String name) {
    return 'Quest “$name” will be deleted. The XP already earned is kept.';
  }

  @override
  String get sheet_discardTitle => 'Discard changes?';

  @override
  String get sheet_discardBody => 'What you entered will not be saved.';

  @override
  String get sheet_keepEditing => 'Keep editing';

  @override
  String get reward_questComplete => 'QUEST COMPLETE';

  @override
  String get reward_levelUp => 'LEVEL UP';

  @override
  String get reward_missionComplete => 'MISSION COMPLETE';

  @override
  String reward_levelUpBody(int level) {
    return 'You reached level $level';
  }

  @override
  String reward_levelNumber(int level) {
    return '$level';
  }

  @override
  String reward_missionLine(String name) {
    return 'Mission · $name';
  }

  @override
  String reward_missionProgress(int done, int total) {
    return '$done of $total quests';
  }

  @override
  String reward_missionRemaining(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '$xpString XP remaining';
  }

  @override
  String reward_missionBonusHint(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Completing the mission brings another +$xpString XP';
  }

  @override
  String get reward_missionReady =>
      'All quests are done — complete the mission to claim the bonus.';

  @override
  String get reward_completeMission => 'Complete mission';

  @override
  String get reward_missionBonusLabel => 'Mission bonus';

  @override
  String get missions_title => 'Missions';

  @override
  String missions_openCount(int count) {
    return '$count in progress';
  }

  @override
  String missions_doneCount(int count) {
    return '$count completed';
  }

  @override
  String get missions_sectionOpen => 'In progress';

  @override
  String get missions_sectionDoneToday => 'Completed today';

  @override
  String missions_remaining(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Remaining: $xpString XP';
  }

  @override
  String get missions_bonusCaption => 'on completion';

  @override
  String get missions_earnedCaption => 'earned';

  @override
  String get missions_readyToComplete => 'Ready to complete';

  @override
  String missions_completedLine(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$_temp0 · completed today at $time';
  }

  @override
  String get missions_emptyTitle => 'No missions yet';

  @override
  String get missions_emptyBody =>
      'A mission is a bigger goal made of quests. Completing it earns bonus XP.';

  @override
  String get missions_emptyAction => 'Start a mission';

  @override
  String get missions_recurringCaption => 'Recurring mission';

  @override
  String get mission_sheetCreateTitle => 'New mission';

  @override
  String get mission_sheetEditTitle => 'Edit mission';

  @override
  String get mission_nameLabel => 'Mission name';

  @override
  String get mission_namePlaceholder => 'Big autumn clean-up';

  @override
  String get mission_bonusLabel => 'Completion reward';

  @override
  String get mission_bonusSmall => 'Small';

  @override
  String get mission_bonusMedium => 'Medium';

  @override
  String get mission_bonusLarge => 'Large';

  @override
  String get mission_bonusHelp => 'On top of the XP for each quest.';

  @override
  String mission_questsLabel(int count) {
    return 'Quests in mission · $count';
  }

  @override
  String get mission_questNamePlaceholder => 'Quest name';

  @override
  String get mission_addQuest => 'Add quest';

  @override
  String get mission_createAction => 'Start mission';

  @override
  String get mission_editBonusNote =>
      'The bonus already earned does not change.';

  @override
  String get mission_editQuestsNote =>
      'Quests are edited on the mission screen.';

  @override
  String get mission_detailKicker => 'Mission';

  @override
  String mission_progressText(int done, int total) {
    return '$done of $total quests done';
  }

  @override
  String mission_bonusOnCompletion(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return '+$xpString XP for completing the mission';
  }

  @override
  String get mission_sectionRemaining => 'Remaining';

  @override
  String get mission_sectionDone => 'Done';

  @override
  String mission_sectionSummary(int count, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$_temp0 · $xpString XP';
  }

  @override
  String get mission_menuEdit => 'Edit mission';

  @override
  String get mission_menuAddQuest => 'Add quest';

  @override
  String get mission_menuDelete => 'Delete mission';

  @override
  String get mission_addQuestToMission => 'Add quest to mission';

  @override
  String get mission_completeAction => 'Complete mission';

  @override
  String get mission_completedTitle => 'Mission complete';

  @override
  String mission_completedBonus(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Bonus earned +$xpString XP';
  }

  @override
  String mission_completedOn(String date) {
    return 'Completed $date';
  }

  @override
  String get mission_bonusWithdrawn =>
      'The bonus was withdrawn and the mission is open again.';

  @override
  String get mission_emptyTitle => 'This mission has no quests yet';

  @override
  String get mission_emptyBody => 'Tap “Add quest” to post the first step.';

  @override
  String get mission_deleteTitle => 'Delete mission?';

  @override
  String mission_deleteBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Mission “$name” will be deleted along with its $count quests. The XP already earned is kept.',
      one:
          'Mission “$name” will be deleted along with its $count quest. The XP already earned is kept.',
      zero: 'Mission “$name” will be deleted. The XP already earned is kept.',
    );
    return '$_temp0';
  }

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_groupProfile => 'Profile';

  @override
  String get settings_groupLanguage => 'Language';

  @override
  String get settings_groupAppearance => 'Appearance';

  @override
  String get settings_groupRules => 'Recurring missions';

  @override
  String get settings_groupTemporary => 'Temporary';

  @override
  String get settings_temporaryHint => 'removed once you choose';

  @override
  String get settings_paletteLabel => 'Palette';

  @override
  String get settings_paletteOriginal => 'Original';

  @override
  String get settings_paletteHighContrast => 'Higher contrast';

  @override
  String get settings_licenses => 'Licenses';

  @override
  String get settings_groupAbout => 'About';

  @override
  String get settings_heroNameLabel => 'Hero name';

  @override
  String get settings_heroNamePlaceholder => 'What should we call you?';

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

    return '$xpString XP in total';
  }

  @override
  String get settings_languageCs => 'Čeština';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_themeSystem => 'System';

  @override
  String settings_version(String version) {
    return 'version $version';
  }

  @override
  String settings_rulesActive(int count) {
    return '$count active';
  }

  @override
  String get rule_addRow => 'Add a recurring mission';

  @override
  String get rule_addHint =>
      'A mission posted by hand replaces the nearest automatic one.';

  @override
  String get rule_postNow => 'Post now';

  @override
  String get rule_posted => 'Posted';

  @override
  String get rule_cadenceDaily => 'Daily';

  @override
  String get rule_cadenceWeekly => 'Weekly';

  @override
  String get rule_cadenceBiweekly => 'Every 2 weeks';

  @override
  String get rule_cadenceMonthly => 'Monthly';

  @override
  String get rule_cadenceQuarterly => 'Quarterly';

  @override
  String get rule_cadenceYearly => 'Yearly';

  @override
  String get rule_detailDaily => 'Daily';

  @override
  String rule_detailWeekly(String weekday) {
    return 'Weekly, $weekday';
  }

  @override
  String rule_detailBiweekly(String weekday) {
    return 'Every 2 weeks, $weekday';
  }

  @override
  String rule_detailMonthly(int day) {
    return 'Monthly, day $day';
  }

  @override
  String rule_detailQuarterly(String date) {
    return 'Quarterly, $date';
  }

  @override
  String rule_detailYearly(String date) {
    return 'Yearly, $date';
  }

  @override
  String rule_line(String cadence, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$cadence · $_temp0 · next $date';
  }

  @override
  String rule_lineManual(String cadence, int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '$count quest',
    );
    return '$cadence · $_temp0 · by hand, next $date';
  }

  @override
  String rule_postedMessage(String name) {
    return 'Mission “$name” posted.';
  }

  @override
  String get rule_postedSkippedNote =>
      'The nearest scheduled posting is skipped.';

  @override
  String get rule_postedClosedNote =>
      'The unfinished previous mission was closed without a bonus.';

  @override
  String get rule_sheetTitle => 'Recurring mission';

  @override
  String get rule_sheetEditTitle => 'Edit rule';

  @override
  String get rule_nameLabel => 'Mission name';

  @override
  String get rule_cadenceLabel => 'Repeat';

  @override
  String get rule_postingDayLabel => 'Always post on';

  @override
  String rule_postingMonthDay(int day) {
    return 'Day $day of the month';
  }

  @override
  String get rule_postingDayWeekdayTitle => 'Day of the week';

  @override
  String get rule_postingDayMonthTitle => 'Day of the month';

  @override
  String get rule_postingDayDateTitle => 'Date';

  @override
  String get rule_helpNoCarryOver =>
      'Unfinished quests from the previous period do not carry over. Posting by hand (in Settings) replaces the nearest automatic posting.';

  @override
  String get rule_editNote => 'Changes apply to the next posted mission only.';

  @override
  String get rule_saveAction => 'Save rule';

  @override
  String get rule_deleteAction => 'Delete rule';

  @override
  String get rule_deleteTitle => 'Delete rule?';

  @override
  String rule_deleteBody(String name) {
    return 'The mission currently posted stays, but no further missions will be posted from “$name”.';
  }

  @override
  String get font_rowLabel => 'Title font';

  @override
  String get font_sample => 'Board · +25';

  @override
  String get font_help =>
      'Changes only titles and numbers — text and controls stay in Figtree. The choice applies instantly across the app.';

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
  String get font_noteFigtree => 'Calm, universal';

  @override
  String get font_noteBricolage => 'Quirky grotesque';

  @override
  String get font_noteSora => 'Geometric, technical';

  @override
  String get font_noteOutfit => 'Soft geometric';

  @override
  String get font_noteUnbounded => 'Wide, playful';

  @override
  String get font_noteCinzel => 'Carved capitals';

  @override
  String get error_nameRequired => 'Enter a name.';

  @override
  String get error_nameTooLong => 'The name can be at most 80 characters.';

  @override
  String get error_noteTooLong => 'The note can be at most 500 characters.';

  @override
  String get error_heroNameTooLong => 'The name can be at most 40 characters.';

  @override
  String get error_noQuestTemplate => 'Add at least one quest with a name.';

  @override
  String get error_missionNotOpen =>
      'This mission is no longer open. Pick another one, or none.';

  @override
  String get error_validation => 'That value is not valid.';

  @override
  String get error_itemChanged =>
      'That item has changed in the meantime. The list was refreshed.';

  @override
  String get error_storage =>
      'The data could not be saved. Nothing was changed.';

  @override
  String get error_unknown => 'Something went wrong.';
}
