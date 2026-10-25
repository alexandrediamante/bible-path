// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bible Path';

  @override
  String get startupFailureTitle => 'Bible Path could not start.';

  @override
  String startupFailureDetails(String error) {
    return 'Details: $error';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navBible => 'Bible';

  @override
  String get navAi => 'AI';

  @override
  String get navDaily => 'Daily';

  @override
  String get navAdvent => 'Advent';

  @override
  String get navPrayer => 'Prayer';

  @override
  String get navStudy => 'Study';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get navListen => 'Listen';

  @override
  String get homeTagline =>
      'A quiet place for scripture, prayer, and daily practice.';

  @override
  String get dailyVerse => 'Daily verse';

  @override
  String get openBiblePrompt => 'Open the Bible to begin reading.';

  @override
  String get openBible => 'Open Bible';

  @override
  String get todaysPlan => 'Today\'s plan';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '$count day streak',
    );
    return '$_temp0';
  }

  @override
  String get noPlanAvailable => 'No plan available.';

  @override
  String planStepsComplete(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$completed of $total steps complete',
      one: '$completed of $total step complete',
    );
    return '$_temp0';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get continueJourney => 'Continue your journey';

  @override
  String get bibleAi => 'Bible AI';

  @override
  String questionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '$count question',
    );
    return '$_temp0';
  }

  @override
  String get studyTitle => 'Study';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active plans',
      one: '$count active plan',
    );
    return '$_temp0';
  }

  @override
  String get prayerJournal => 'Prayer journal';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '$count entry',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String verseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '$count verse',
    );
    return '$_temp0';
  }

  @override
  String get translationUnavailable => 'This translation is unavailable.';

  @override
  String get searchBooksOrVerses => 'Search books or verses…';

  @override
  String get books => 'Books';

  @override
  String chapterTitle(String book, int chapter) {
    return '$book $chapter';
  }

  @override
  String get previousChapter => 'Previous chapter';

  @override
  String chapterProgress(int chapter, int chapterCount) {
    return '$chapter/$chapterCount';
  }

  @override
  String get nextChapter => 'Next chapter';

  @override
  String get chapterNotAvailable => 'Chapter not available.';

  @override
  String verseShareText(
    String book,
    int chapter,
    int verse,
    String text,
    String version,
  ) {
    return '$book $chapter:$verse — $text ($version)';
  }

  @override
  String get verseActions => 'Verse actions';

  @override
  String get removeFavorite => 'Remove favorite';

  @override
  String get addFavorite => 'Add favorite';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get verseCopied => 'Verse copied to the clipboard.';

  @override
  String get noResults => 'No results.';

  @override
  String verseReference(String book, int chapter, String verse) {
    return '$book $chapter:$verse';
  }

  @override
  String get bibleContentUnavailable => 'Bible content could not be loaded.';

  @override
  String get retry => 'Retry';

  @override
  String get chatHistory => 'Chat history';

  @override
  String get chatSecureStatus =>
      'Questions are sent securely through your Worker.';

  @override
  String get aiEndpointNotConfigured =>
      'AI endpoint not configured for this build.';

  @override
  String get newChat => 'New chat';

  @override
  String newChatNumber(int number) {
    return 'New chat $number';
  }

  @override
  String get askBibleHint => 'Ask about the Bible or faith…';

  @override
  String get send => 'Send';

  @override
  String get noMessages => 'No messages';

  @override
  String get deleteChat => 'Delete chat';

  @override
  String get suggestionPrayerFocus => 'How can I pray with more focus?';

  @override
  String get suggestionJohnContext => 'Explain John 3:16 in context.';

  @override
  String get suggestionAnxiety => 'Which passages speak about anxiety?';

  @override
  String get suggestionDevotional => 'Give me a short devotional for today.';

  @override
  String get chatPrivacyIntro =>
      'Ask a question. Recent chat turns and selected scripture context are sent to Cloudflare Workers AI.';

  @override
  String responseTruncated(String response) {
    return '$response\n\n[Response truncated]';
  }

  @override
  String get aiNotConfigured => 'AI is not configured for this build.';

  @override
  String get aiMissingToken =>
      'Enter your personal AI access token in Settings.';

  @override
  String get aiUnavailableLater => 'Bible AI is unavailable. Try again later.';

  @override
  String get aiInvalidResponse => 'Bible AI returned an invalid response.';

  @override
  String get aiUnavailableConnection =>
      'Bible AI is unavailable. Check your connection and try again.';

  @override
  String get dailyPlan => 'Daily plan';

  @override
  String bestStreak(int count) {
    return 'Best $count';
  }

  @override
  String get today => 'Today';

  @override
  String get history => 'History';

  @override
  String get completeTodaysPlan => 'Complete today\'s plan';

  @override
  String get dailyHistoryEmpty =>
      'Complete your first daily plan to start a history.';

  @override
  String get todaysVerse => 'Today\'s Verse';

  @override
  String get dailyDevotional => 'Daily Devotional';

  @override
  String get reading => 'Reading';

  @override
  String get listening => 'Listening';

  @override
  String get reflection => 'Reflection';

  @override
  String get dailyPrayer => 'Daily Prayer';

  @override
  String get themeTrustGuidance => 'Trust & Guidance';

  @override
  String get themePeaceRest => 'Peace & Rest';

  @override
  String get themeStrengthCourage => 'Strength & Courage';

  @override
  String get themeHopeFuture => 'Hope & Future';

  @override
  String get themeLoveGrace => 'Love & Grace';

  @override
  String get themeFaithTrust => 'Faith & Trust';

  @override
  String get themeWisdomUnderstanding => 'Wisdom & Understanding';

  @override
  String get prayerPrivateDescription =>
      'Private entries stored on this device.';

  @override
  String get newPrayer => 'New prayer';

  @override
  String get active => 'Active';

  @override
  String get archived => 'Archived';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryGratitude => 'Gratitude';

  @override
  String get categoryGuidance => 'Guidance';

  @override
  String get categoryHealing => 'Healing';

  @override
  String get categoryFamily => 'Family';

  @override
  String get restore => 'Restore';

  @override
  String get archive => 'Archive';

  @override
  String get delete => 'Delete';

  @override
  String get prayerComposerHint => 'Write your prayer or reflection…';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteEntryTitle => 'Delete entry?';

  @override
  String get cannotUndo => 'This cannot be undone.';

  @override
  String get noArchivedPrayers => 'No archived prayers.';

  @override
  String get emptyPrayerJournal =>
      'Your prayer journal is empty. Add your first entry.';

  @override
  String get studyPlans => 'Study plans';

  @override
  String get available => 'Available';

  @override
  String get myPlans => 'My Plans';

  @override
  String studyDurationAndTopics(int days, String topics) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days • $topics',
      one: '$days day • $topics',
    );
    return '$_temp0';
  }

  @override
  String get started => 'Started';

  @override
  String get startPlan => 'Start Plan';

  @override
  String get studyMyPlansEmpty => 'Start a plan to see your progress here.';

  @override
  String studyProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String studyDay(int day) {
    return 'Day $day';
  }

  @override
  String get removePlan => 'Remove plan';

  @override
  String studyLessonTitle(int day, String title) {
    return 'Day $day: $title';
  }

  @override
  String get completed => 'Completed';

  @override
  String get markComplete => 'Mark Complete';

  @override
  String profileCurrentStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Current streak',
      one: 'Current streak',
    );
    return '$_temp0';
  }

  @override
  String profileLongestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Longest streak',
      one: 'Longest streak',
    );
    return '$_temp0';
  }

  @override
  String profileDailyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Daily plans',
      one: 'Daily plan',
    );
    return '$_temp0';
  }

  @override
  String profileStudyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Study plans',
      one: 'Study plan',
    );
    return '$_temp0';
  }

  @override
  String profileFavoriteVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Favorite verses',
      one: 'Favorite verse',
    );
    return '$_temp0';
  }

  @override
  String profilePrayerEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Prayer entries',
      one: 'Prayer entry',
    );
    return '$_temp0';
  }

  @override
  String profileAiMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'AI messages',
      one: 'AI message',
    );
    return '$_temp0';
  }

  @override
  String get yourJourney => 'Your journey';

  @override
  String get dataStoredOnly => 'Data is stored only on this device.';

  @override
  String get privacy => 'Privacy';

  @override
  String get profilePrivacyDescription =>
      'Favorites, progress, prayers, and chat history stay in this browser. AI questions and selected scripture context leave the device only when you send a Bible AI request.';

  @override
  String get settings => 'Settings';

  @override
  String get appearanceAndLanguage => 'Appearance and language';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get textSize => 'Text size';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageRussian => 'Русский';

  @override
  String get translation => 'Translation';

  @override
  String get inAppReminder => 'In-app reminder';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get reminderVisibility =>
      'Shown only when the app is open or resumed.';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get personalWorkerToken => 'Personal Worker access token';

  @override
  String get enterToken => 'Enter token';

  @override
  String get tokenAlreadySaved => 'A token is already saved';

  @override
  String get hideToken => 'Hide token';

  @override
  String get showToken => 'Show token';

  @override
  String get removeToken => 'Remove token';

  @override
  String get tokenSaved => 'Token saved.';

  @override
  String get saveToken => 'Save token';

  @override
  String get aiPrivacyDescription =>
      'AI questions, recent chat turns, and selected Bible passages are processed by Cloudflare Workers AI. No external AI API key is stored in this app.';

  @override
  String get localData => 'Local data';

  @override
  String get requestDurableStorage => 'Request durable storage';

  @override
  String get durableStorageWarning =>
      'iOS may still remove website data. Export important entries regularly.';

  @override
  String get exportMyData => 'Export my data';

  @override
  String get tokenExcluded => 'The AI access token is excluded.';

  @override
  String get resetLocalData => 'Reset local data';

  @override
  String get about => 'About';

  @override
  String aboutDescription(String version) {
    return 'Personal offline-first PWA • $version';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get webPushUnavailable => 'Web Push is not included in this release.';

  @override
  String get durableStorageGranted => 'Durable storage was granted.';

  @override
  String get durableStorageNotGranted =>
      'Durable storage was not granted. Keep regular exports.';

  @override
  String get exportUnavailable =>
      'Data export is not available on this platform.';

  @override
  String get resetAllDataTitle => 'Reset all local data?';

  @override
  String get resetAllDataDescription =>
      'Favorites, plans, prayers, chats, settings, and the AI token will be deleted from this device.';

  @override
  String get reset => 'Reset';

  @override
  String get reminderBanner => 'Your daily plan is ready.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get edit => 'Edit';

  @override
  String get listenPlans => 'Listen plans';

  @override
  String get readingPlans => 'Reading Plans';

  @override
  String activePlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active plans',
      one: '$count active plan',
    );
    return '$_temp0';
  }

  @override
  String get myPlansEmpty => 'No active reading plans yet.';

  @override
  String get startPlanToSeeProgress =>
      'Start a plan to see your progress here.';

  @override
  String planDuration(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '$days day',
    );
    return '$_temp0';
  }

  @override
  String planBook(String book) {
    return 'Book: $book';
  }

  @override
  String planReadings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings',
      one: '$count reading',
    );
    return '$_temp0';
  }

  @override
  String get planSchedule => 'Schedule';

  @override
  String planProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String get inProgress => 'In Progress';

  @override
  String get completePlan => 'Complete Plan';

  @override
  String completePlanConfirmation(Object title) {
    return 'Mark all readings in \'$title\' as complete?';
  }

  @override
  String get planNotFound => 'Plan not found.';

  @override
  String get noReadingsAvailable => 'No readings available for this plan.';

  @override
  String get readingPlansUnavailable =>
      'Reading plans are currently unavailable.';

  @override
  String listenDurationAndDays(int minutes, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes • $days days',
      one: '$minutes minute • $days day',
    );
    return '$_temp0';
  }

  @override
  String get listenMyPlansEmpty =>
      'Start a listen plan to see your progress here.';

  @override
  String listenProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String listenDay(int day) {
    return 'Day $day';
  }

  @override
  String listenDayTitle(int day, String title) {
    return 'Day $day: $title';
  }

  @override
  String get listenAudioPlaceholder =>
      'Audio playback will be implemented in a future update.';

  @override
  String get lentTitle => 'Lent';

  @override
  String get lentLoading => 'Loading Lent journey...';

  @override
  String lentProgress(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      completed,
      locale: localeName,
      other: '$completed of $total days complete',
      one: '$completed of $total day complete',
    );
    return '$_temp0';
  }

  @override
  String lentDayNumber(int day) {
    return 'Day $day';
  }

  @override
  String get lentDailyVerse => 'Daily Verse';

  @override
  String get lentDailyPrayer => 'Daily Prayer';

  @override
  String get lentAudioPlaceholder =>
      'Audio playback will be implemented in a future update.';

  @override
  String get loadingTranslations => 'Loading translations…';

  @override
  String get selectTranslation => 'Select Translation';

  @override
  String get close => 'Close';

  @override
  String get complete => 'Complete';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Bible Path';

  @override
  String get onboardingWelcomeDescription =>
      'Let\'s personalize your experience. We\'ll ask a few quick questions to set up the best Bible version and content for you.';

  @override
  String get onboardingLanguage => 'Language';

  @override
  String get onboardingTranslationStyle => 'Translation style';

  @override
  String get onboardingDenomination => 'Denomination';

  @override
  String get onboardingStyleFormal => 'Formal (KJV-style)';

  @override
  String get onboardingStyleContemporary => 'Contemporary (NIV-style)';

  @override
  String get onboardingStyleSimple => 'Simple (NLT-style)';

  @override
  String get onboardingStyleLiterary => 'Literary (ESV-style)';

  @override
  String get onboardingDenominationCatholic => 'Catholic';

  @override
  String get onboardingDenominationOrthodox => 'Orthodox';

  @override
  String get onboardingDenominationProtestant => 'Protestant';

  @override
  String get onboardingDenominationNonDenominational => 'Non-denominational';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingComplete => 'Complete';

  @override
  String get adventTitle => 'Advent';

  @override
  String get adventDay => 'Day';

  @override
  String get adventScripture => 'Scripture';

  @override
  String get adventReflection => 'Reflection';

  @override
  String get adventPrayer => 'Prayer';

  @override
  String get adventWeekHope => 'Hope';

  @override
  String get adventWeekPeace => 'Peace';

  @override
  String get adventWeekJoy => 'Joy';

  @override
  String get adventWeekLove => 'Love';

  @override
  String adventComingSoon(int days) {
    return 'Advent begins in $days days';
  }

  @override
  String get adventNotInSeason => 'Advent season begins December 1';

  @override
  String get adventCountdownTitle => 'Waiting for Advent';

  @override
  String adventCountdownSubtitle(int days) {
    return 'Advent begins in $days days. Prepare your heart for the coming of Christ.';
  }

  @override
  String get adventErrorTitle => 'Unable to load Advent calendar';

  @override
  String get adventRetry => 'Try again';

  @override
  String get adventRefresh => 'Refresh';

  @override
  String get adventNoData => 'Advent calendar data not available';

  @override
  String get adventDayLocked => 'This day is locked';

  @override
  String adventDayLockedSubtitle(int day) {
    return 'Day $day will unlock on December $day';
  }

  @override
  String get adventSeasonActive => 'Advent season is active';

  @override
  String get holyCalendarTitle => 'Holy Calendar';

  @override
  String get holyCalendarNoEvents =>
      'No celebrations are available for this month.';

  @override
  String get holyCalendarLoadError =>
      'The calendar could not be loaded. Please try again.';

  @override
  String get holyCalendarRetry => 'Try again';

  @override
  String get holyCalendarReadings => 'Readings';

  @override
  String get holyCalendarFasting => 'Fasting';

  @override
  String get holyCalendarSaints => 'Saints';

  @override
  String get holyCalendarObligation => 'Holy day of obligation';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get speechNotice =>
      'Browser voice, not recorded audio. Voices may need internet. Changing speed restarts reading; background playback is not guaranteed.';

  @override
  String get speechUnavailable =>
      'Read-aloud is unavailable here or this passage has no text.';

  @override
  String get speechError =>
      'Voice playback failed. Retry or check device voices.';

  @override
  String get speechPlay => 'Play';

  @override
  String get speechPause => 'Pause';

  @override
  String get speechStop => 'Stop';

  @override
  String get speechRate => 'Reading speed';

  @override
  String get speechVoice => 'Voice';

  @override
  String get speechDefaultVoice => 'Automatic (reading language)';

  @override
  String get speechNoVoices =>
      'Device voices are still loading. Try again shortly.';

  @override
  String get speechContinueChapters => 'Continue to the next chapter';
}
