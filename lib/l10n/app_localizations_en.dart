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
  String get board_todaySection => 'Today';

  @override
  String get board_todoSection => 'Todo';

  @override
  String get board_todayEmpty => 'Drag a quest here to focus on it today.';

  @override
  String get board_todoEmpty => 'New quests are posted here.';

  @override
  String get quest_boardLabel => 'Board';

  @override
  String get quest_boardNone => 'Off the board';

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
      'Quests that belong to a mission live under Missions. Tap the + button to post a quest of your own — maybe something you meant to do today anyway. Every one you finish earns XP.';

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
  String get quest_deadlineLabel => 'Deadline';

  @override
  String get quest_deadlineNone => 'No deadline';

  @override
  String get quest_deadlineLinkedHint =>
      'The quest shows in the calendar as an event.';

  @override
  String quest_dueOn(String date) {
    return 'Due $date';
  }

  @override
  String quest_overdueOn(String date) {
    return 'Overdue: $date';
  }

  @override
  String get quest_effortMoment => 'Moment';

  @override
  String get quest_effortHour => 'Hour';

  @override
  String get quest_effortPart => 'Part of a day';

  @override
  String get quest_effortDay => 'Full day';

  @override
  String get quest_effortMomentTime => 'up to ~30 min';

  @override
  String get quest_effortHourTime => 'up to ~2 h';

  @override
  String get quest_effortPartTime => '2–4 h';

  @override
  String get quest_effortDayTime => 'the whole day';

  @override
  String get quest_effortHint =>
      'Pick by how much time it will take. A trip, waiting around or something unpleasant? Go one step up — effort earns more XP.';

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
  String a11y_effort(int step, int total) {
    return 'Effort $step of $total';
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
  String get quest_sheetCreateTitle => 'New quest';

  @override
  String get quest_sheetEditTitle => 'Edit quest';

  @override
  String get quest_nameLabel => 'What needs doing';

  @override
  String get quest_namePlaceholder => 'Hang the laundry';

  @override
  String get quest_effortLabel => 'Effort';

  @override
  String get quest_missionLabel => 'Part of a mission';

  @override
  String get quest_missionNone => 'No mission';

  @override
  String quest_addedToMission(String name) {
    return 'Added to mission $name';
  }

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

  @override
  String get app_tabCalendar => 'Calendar';

  @override
  String get calendar_today => 'Today';

  @override
  String get calendar_prevMonth => 'Previous month';

  @override
  String get calendar_nextMonth => 'Next month';

  @override
  String get calendar_pickMonth => 'Choose month and year';

  @override
  String get calendar_search => 'Search events';

  @override
  String get calendar_filter => 'Filter by type';

  @override
  String get calendar_add => 'Add event';

  @override
  String calendar_cellLabel(String date, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString events',
      one: '1 event',
      zero: 'no events',
    );
    return '$date, $_temp0';
  }

  @override
  String calendar_moreEvents(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '+$countString';
  }

  @override
  String get calendar_monthPickerTitle => 'Month and year';

  @override
  String get calendar_prevYear => 'Previous year';

  @override
  String get calendar_nextYear => 'Next year';

  @override
  String get calendar_filterTitle => 'Event types';

  @override
  String get calendar_filterDone => 'Done';

  @override
  String get calendar_filterShowAll => 'Show all types';

  @override
  String get calendar_filterHidesAll => 'The filter hides all events.';

  @override
  String get calendar_typeDance => 'Dance';

  @override
  String get calendar_typeWork => 'Work';

  @override
  String get calendar_typeBirthday => 'Birthday';

  @override
  String get calendar_typeNameDay => 'Name day';

  @override
  String get calendar_typePublicHoliday => 'Public holiday';

  @override
  String get calendar_typeNotableDay => 'Notable day';

  @override
  String get calendar_typeDate => 'Date';

  @override
  String get calendar_typeMeeting => 'Meeting';

  @override
  String get calendar_typeSeminar => 'Seminar';

  @override
  String get calendar_typeLesson => 'Lesson';

  @override
  String get calendar_typeQuest => 'Quest';

  @override
  String get calendar_allDay => 'All day';

  @override
  String calendar_dayEvents(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString events',
      one: '1 event',
      zero: 'No events',
    );
    return '$_temp0';
  }

  @override
  String get calendar_dayEmpty => 'No events';

  @override
  String get calendar_start => 'Start';

  @override
  String get calendar_end => 'End';

  @override
  String get calendar_notes => 'Details';

  @override
  String get calendar_repeat => 'Repeat';

  @override
  String get calendar_location => 'Address';

  @override
  String get calendar_notSet => 'Not set';

  @override
  String calendar_completedAt(String time, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Done at $time · +$xpString XP';
  }

  @override
  String get calendar_edit => 'Edit';

  @override
  String get calendar_duplicate => 'Duplicate';

  @override
  String get calendar_menu => 'More actions';

  @override
  String get calendar_locationCopied => 'Address copied';

  @override
  String get calendar_eventGone => 'This event no longer exists.';

  @override
  String get calendar_repeatNever => 'Never';

  @override
  String get calendar_repeatDaily => 'Every day';

  @override
  String get calendar_repeatWeekly => 'Every week';

  @override
  String get calendar_repeatMonthly => 'Every month';

  @override
  String get calendar_repeatYearly => 'Every year';

  @override
  String get calendar_repeatEaster => 'Every year, relative to Easter';

  @override
  String get calendar_repeatNth => 'Every year, by weekday';

  @override
  String get calendar_repeatDescDaily => 'every day';

  @override
  String calendar_repeatDescWeekly(String weekday) {
    return 'every week on $weekday';
  }

  @override
  String calendar_repeatDescMonthly(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String dayString = dayNumberFormat.format(day);

    return 'every month on day $dayString';
  }

  @override
  String calendar_repeatDescYearly(String date) {
    return 'every year on $date';
  }

  @override
  String get calendar_repeatDescEaster => 'every year, relative to Easter';

  @override
  String calendar_repeatDescNth(String ordinal, String weekday, String month) {
    return 'every year, $ordinal $weekday of $month';
  }

  @override
  String calendar_repeatUntil(String repeat, String date) {
    return '$repeat, until $date';
  }

  @override
  String get calendar_repeatEnds => 'Repeat until';

  @override
  String get calendar_repeatNoEnd => 'No end';

  @override
  String get calendar_formCreateTitle => 'New event';

  @override
  String get calendar_formEditTitle => 'Edit event';

  @override
  String get calendar_formNameHint => 'Event title';

  @override
  String get calendar_formNoteHint => 'Add details';

  @override
  String get calendar_formLocationHint => 'Address';

  @override
  String get calendar_formType => 'Event type';

  @override
  String get calendar_onBoard => 'On the board';

  @override
  String calendar_onBoardXp(int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'For completing: +$xpString XP';
  }

  @override
  String calendar_addressSuggestion(String address) {
    return 'Use address $address';
  }

  @override
  String get calendar_errorName => 'Enter an event title.';

  @override
  String get calendar_errorNameLong => 'The title is too long.';

  @override
  String get calendar_errorEnd => 'The end cannot be before the start.';

  @override
  String get calendar_errorRepeatEnd =>
      'The repeat end cannot be before the start.';

  @override
  String get calendar_errorNoteLong => 'The details are too long.';

  @override
  String get calendar_errorLocationLong => 'The address is too long.';

  @override
  String get calendar_saveFailed => 'Saving failed. Try again.';

  @override
  String get calendar_deleteTitle => 'Delete event?';

  @override
  String calendar_deleteBody(String name) {
    return 'The event “$name” will be deleted.';
  }

  @override
  String calendar_deleteRepeatBody(String name) {
    return 'The event “$name” repeats. What do you want to delete?';
  }

  @override
  String get calendar_deleteOnlyThis => 'Only this event';

  @override
  String get calendar_deleteThisAndFollowing => 'This and all following';

  @override
  String get calendar_deleteAll => 'All events in the series';

  @override
  String calendar_deleted(String name) {
    return 'Event “$name” deleted';
  }

  @override
  String get calendar_undo => 'Undo';

  @override
  String get calendar_deleteFailed => 'Deleting failed.';

  @override
  String get calendar_searchPrompt => 'Type a title, details or a place.';

  @override
  String get calendar_searchNone => 'Nothing found';

  @override
  String a11y_completeEvent(String name) {
    return 'Complete event $name';
  }

  @override
  String a11y_reopenEvent(String name) {
    return 'Reopen event $name';
  }

  @override
  String a11y_eventCompleted(String name, int xp) {
    final intl.NumberFormat xpNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String xpString = xpNumberFormat.format(xp);

    return 'Event $name completed, +$xpString XP';
  }

  @override
  String get calendar_taskAllDay => 'All day';

  @override
  String get calendar_clearRepeatEnd => 'Remove the repeat end';

  @override
  String get app_tabNotes => 'Notes';

  @override
  String get notes_title => 'Notes';

  @override
  String notes_folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folders',
      one: '$count folder',
    );
    return '$_temp0';
  }

  @override
  String notes_noteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '$count note',
    );
    return '$_temp0';
  }

  @override
  String get notes_folderEmpty => 'Empty folder';

  @override
  String get notes_sectionFolders => 'Folders';

  @override
  String get notes_sectionNotes => 'Notes';

  @override
  String get notes_emptyTitle => 'Nothing here yet';

  @override
  String get notes_emptyBody => 'Add a note or a folder with the plus button.';

  @override
  String get notes_addTitle => 'Add';

  @override
  String get notes_addNote => 'New note';

  @override
  String get notes_addNoteHint => 'A blank page with the editor';

  @override
  String get notes_addFolder => 'New folder';

  @override
  String get notes_addFolderHint => 'For organising notes and other folders';

  @override
  String notes_addWhere(String place) {
    return 'It will be created in $place';
  }

  @override
  String get notes_createFolder => 'Create folder';

  @override
  String get notes_nameLabel => 'Name';

  @override
  String get notes_renameTitle => 'Rename';

  @override
  String get notes_moveTitle => 'Move';

  @override
  String notes_moveNote(String name) {
    return 'Note “$name”';
  }

  @override
  String notes_moveFolder(String name) {
    return 'Folder “$name”';
  }

  @override
  String get notes_moveRootTag => 'top level';

  @override
  String get notes_moveCurrentTag => 'current location';

  @override
  String notes_moveConfirm(String name) {
    return 'Move to $name';
  }

  @override
  String get notes_actionRename => 'Rename';

  @override
  String get notes_actionMove => 'Move';

  @override
  String get notes_actionDelete => 'Delete';

  @override
  String get notes_actionTrash => 'Move to Trash';

  @override
  String notes_deleteFolderTitle(String name) {
    return 'Move $name to the Trash?';
  }

  @override
  String notes_deleteFolderBody(String contents) {
    return 'The folder holds $contents. They move to the Trash with it and are deleted for good after 30 days.';
  }

  @override
  String notes_joinAnd(String first, String second) {
    return '$first and $second';
  }

  @override
  String get notes_deleteConfirm => 'Move to Trash';

  @override
  String get notes_movedToTrash => 'Moved to the Trash';

  @override
  String get notes_untitled => 'Untitled';

  @override
  String get notes_errorGeneric => 'That did not work.';

  @override
  String get notes_errorGone => 'That item no longer exists.';

  @override
  String get notes_trashButton => 'Trash';

  @override
  String get trash_title => 'Trash';

  @override
  String trash_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String get trash_info =>
      'Items stay in the Trash for 30 days and are then deleted for good. A folder is restored with its content.';

  @override
  String get trash_section => 'Deleted';

  @override
  String trash_noteLine(String from, String when) {
    return 'from $from · $when';
  }

  @override
  String trash_folderLine(String notes, String from, String when) {
    return 'folder, $notes · from $from · $when';
  }

  @override
  String trash_daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'deleted in $_temp0';
  }

  @override
  String get trash_restore => 'Restore';

  @override
  String get trash_forever => 'Forever';

  @override
  String get trash_emptyAction => 'Empty Trash';

  @override
  String get trash_emptyStateTitle => 'The Trash is empty';

  @override
  String get trash_emptyStateBody =>
      'Deleted notes and folders stay here for 30 days.';

  @override
  String get trash_foreverTitle => 'Delete for good?';

  @override
  String trash_foreverBody(String name) {
    return '$name will be deleted for good with its content and cannot be restored.';
  }

  @override
  String get trash_foreverConfirm => 'Delete for good';

  @override
  String get trash_emptyTitle => 'Empty the Trash?';

  @override
  String trash_emptyBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items will be',
      one: '$count item will be',
    );
    return '$_temp0 deleted for good with their content and cannot be restored.';
  }

  @override
  String get trash_restored => 'Restored';

  @override
  String get trash_openHint => 'Double tap to preview';

  @override
  String get trash_previewEmpty => 'Empty note';

  @override
  String get trash_deleted => 'Deleted for good';

  @override
  String get trash_emptied => 'The Trash was emptied';

  @override
  String get editor_done => 'Done';

  @override
  String get editor_hint => 'Start writing…';

  @override
  String get editor_titleHint => 'Title';

  @override
  String get editor_saveFailed => 'The note could not be saved.';

  @override
  String get editor_tooLong =>
      'The note is too long, at most 100,000 characters.';

  @override
  String get editor_fmtBold => 'Bold';

  @override
  String get editor_fmtItalic => 'Italic';

  @override
  String get editor_fmtHeading => 'Heading';

  @override
  String get editor_fmtList => 'Bulleted list';

  @override
  String get editor_fmtChecklist => 'Checklist';

  @override
  String get editor_fmtQuote => 'Quote';

  @override
  String get editor_fmtCode => 'Code';

  @override
  String get editor_fmtLink => 'Link';

  @override
  String get editor_linkLabel => 'Address';

  @override
  String get editor_linkApply => 'Apply link';

  @override
  String get a11y_nodeMenu => 'Item menu';

  @override
  String a11y_openFolder(String name) {
    return 'Open folder $name';
  }

  @override
  String a11y_openNote(String name) {
    return 'Open note $name';
  }

  @override
  String a11y_renameNode(String name) {
    return 'Rename $name';
  }

  @override
  String a11y_moveNode(String name) {
    return 'Move $name';
  }

  @override
  String a11y_trashNode(String name) {
    return 'Delete $name';
  }

  @override
  String a11y_restoreNode(String name) {
    return 'Restore $name';
  }

  @override
  String a11y_foreverNode(String name) {
    return 'Delete $name for good';
  }

  @override
  String a11y_breadcrumbTo(String name) {
    return 'Go to $name';
  }

  @override
  String get a11y_taskToggle => 'Toggle done';

  @override
  String get settings_shortcutTitle => 'Home Screen shortcut';

  @override
  String get settings_shortcutSubtitle =>
      'Open QuestLog on the screen you choose with a single tap.';

  @override
  String get settings_shortcutPickLabel => 'Which screen should the icon open?';

  @override
  String get settings_shortcutCopyLink => 'Copy link';

  @override
  String get settings_shortcutCopied => 'Link copied';

  @override
  String get settings_shortcutStep1 => 'Copy the link above.';

  @override
  String get settings_shortcutStep2 =>
      'On your iPhone open the Shortcuts app and tap +.';

  @override
  String get settings_shortcutStep3 =>
      'Tap Add Action, search for Open URLs and pick it.';

  @override
  String get settings_shortcutStep4 =>
      'Paste the copied link into the URL field.';

  @override
  String get settings_shortcutStep5 =>
      'Tap the share icon and choose Add to Home Screen.';

  @override
  String get settings_shortcutStep6 =>
      'Name the shortcut, change the icon if you like, and tap Add.';

  @override
  String get settings_shortcutNote =>
      'Works on iPhone only. You can move the finished icon into a folder.';

  @override
  String get settings_groupData => 'Data';

  @override
  String get settings_exportTitle => 'Export data';

  @override
  String get settings_exportSubtitle =>
      'Saves all data into one file you can move elsewhere.';

  @override
  String get settings_exportFailed => 'The export failed. Please try again.';
}
