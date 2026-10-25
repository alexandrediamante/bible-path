import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bible Path'**
  String get appTitle;

  /// No description provided for @startupFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Bible Path could not start.'**
  String get startupFailureTitle;

  /// No description provided for @startupFailureDetails.
  ///
  /// In en, this message translates to:
  /// **'Details: {error}'**
  String startupFailureDetails(String error);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBible.
  ///
  /// In en, this message translates to:
  /// **'Bible'**
  String get navBible;

  /// No description provided for @navAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAi;

  /// No description provided for @navDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get navDaily;

  /// No description provided for @navAdvent.
  ///
  /// In en, this message translates to:
  /// **'Advent'**
  String get navAdvent;

  /// No description provided for @navPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get navPrayer;

  /// No description provided for @navStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get navStudy;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get navListen;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'A quiet place for scripture, prayer, and daily practice.'**
  String get homeTagline;

  /// No description provided for @dailyVerse.
  ///
  /// In en, this message translates to:
  /// **'Daily verse'**
  String get dailyVerse;

  /// No description provided for @openBiblePrompt.
  ///
  /// In en, this message translates to:
  /// **'Open the Bible to begin reading.'**
  String get openBiblePrompt;

  /// No description provided for @openBible.
  ///
  /// In en, this message translates to:
  /// **'Open Bible'**
  String get openBible;

  /// No description provided for @todaysPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s plan'**
  String get todaysPlan;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day streak} other{{count} day streak}}'**
  String dayStreak(int count);

  /// No description provided for @noPlanAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plan available.'**
  String get noPlanAvailable;

  /// No description provided for @planStepsComplete.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, one{{completed} of {total} step complete} other{{completed} of {total} steps complete}}'**
  String planStepsComplete(int completed, int total);

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @continueJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue your journey'**
  String get continueJourney;

  /// No description provided for @bibleAi.
  ///
  /// In en, this message translates to:
  /// **'Bible AI'**
  String get bibleAi;

  /// No description provided for @questionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} question} other{{count} questions}}'**
  String questionCount(int count);

  /// No description provided for @studyTitle.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyTitle;

  /// No description provided for @activePlanCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} active plan} other{{count} active plans}}'**
  String activePlanCount(int count);

  /// No description provided for @prayerJournal.
  ///
  /// In en, this message translates to:
  /// **'Prayer journal'**
  String get prayerJournal;

  /// No description provided for @entryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry} other{{count} entries}}'**
  String entryCount(int count);

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @verseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} verse} other{{count} verses}}'**
  String verseCount(int count);

  /// No description provided for @translationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This translation is unavailable.'**
  String get translationUnavailable;

  /// No description provided for @searchBooksOrVerses.
  ///
  /// In en, this message translates to:
  /// **'Search books or verses…'**
  String get searchBooksOrVerses;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @chapterTitle.
  ///
  /// In en, this message translates to:
  /// **'{book} {chapter}'**
  String chapterTitle(String book, int chapter);

  /// No description provided for @previousChapter.
  ///
  /// In en, this message translates to:
  /// **'Previous chapter'**
  String get previousChapter;

  /// No description provided for @chapterProgress.
  ///
  /// In en, this message translates to:
  /// **'{chapter}/{chapterCount}'**
  String chapterProgress(int chapter, int chapterCount);

  /// No description provided for @nextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next chapter'**
  String get nextChapter;

  /// No description provided for @chapterNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Chapter not available.'**
  String get chapterNotAvailable;

  /// No description provided for @verseShareText.
  ///
  /// In en, this message translates to:
  /// **'{book} {chapter}:{verse} — {text} ({version})'**
  String verseShareText(
    String book,
    int chapter,
    int verse,
    String text,
    String version,
  );

  /// No description provided for @verseActions.
  ///
  /// In en, this message translates to:
  /// **'Verse actions'**
  String get verseActions;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavorite;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get addFavorite;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @verseCopied.
  ///
  /// In en, this message translates to:
  /// **'Verse copied to the clipboard.'**
  String get verseCopied;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @verseReference.
  ///
  /// In en, this message translates to:
  /// **'{book} {chapter}:{verse}'**
  String verseReference(String book, int chapter, String verse);

  /// No description provided for @bibleContentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bible content could not be loaded.'**
  String get bibleContentUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get chatHistory;

  /// No description provided for @chatSecureStatus.
  ///
  /// In en, this message translates to:
  /// **'Questions are sent securely through your Worker.'**
  String get chatSecureStatus;

  /// No description provided for @aiEndpointNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI endpoint not configured for this build.'**
  String get aiEndpointNotConfigured;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @newChatNumber.
  ///
  /// In en, this message translates to:
  /// **'New chat {number}'**
  String newChatNumber(int number);

  /// No description provided for @askBibleHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about the Bible or faith…'**
  String get askBibleHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteChat;

  /// No description provided for @suggestionPrayerFocus.
  ///
  /// In en, this message translates to:
  /// **'How can I pray with more focus?'**
  String get suggestionPrayerFocus;

  /// No description provided for @suggestionJohnContext.
  ///
  /// In en, this message translates to:
  /// **'Explain John 3:16 in context.'**
  String get suggestionJohnContext;

  /// No description provided for @suggestionAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Which passages speak about anxiety?'**
  String get suggestionAnxiety;

  /// No description provided for @suggestionDevotional.
  ///
  /// In en, this message translates to:
  /// **'Give me a short devotional for today.'**
  String get suggestionDevotional;

  /// No description provided for @chatPrivacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Ask a question. Recent chat turns and selected scripture context are sent to Cloudflare Workers AI.'**
  String get chatPrivacyIntro;

  /// No description provided for @responseTruncated.
  ///
  /// In en, this message translates to:
  /// **'{response}\n\n[Response truncated]'**
  String responseTruncated(String response);

  /// No description provided for @aiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI is not configured for this build.'**
  String get aiNotConfigured;

  /// No description provided for @aiMissingToken.
  ///
  /// In en, this message translates to:
  /// **'Enter your personal AI access token in Settings.'**
  String get aiMissingToken;

  /// No description provided for @aiUnavailableLater.
  ///
  /// In en, this message translates to:
  /// **'Bible AI is unavailable. Try again later.'**
  String get aiUnavailableLater;

  /// No description provided for @aiInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Bible AI returned an invalid response.'**
  String get aiInvalidResponse;

  /// No description provided for @aiUnavailableConnection.
  ///
  /// In en, this message translates to:
  /// **'Bible AI is unavailable. Check your connection and try again.'**
  String get aiUnavailableConnection;

  /// No description provided for @dailyPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily plan'**
  String get dailyPlan;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best {count}'**
  String bestStreak(int count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @completeTodaysPlan.
  ///
  /// In en, this message translates to:
  /// **'Complete today\'s plan'**
  String get completeTodaysPlan;

  /// No description provided for @dailyHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete your first daily plan to start a history.'**
  String get dailyHistoryEmpty;

  /// No description provided for @todaysVerse.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Verse'**
  String get todaysVerse;

  /// No description provided for @dailyDevotional.
  ///
  /// In en, this message translates to:
  /// **'Daily Devotional'**
  String get dailyDevotional;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get listening;

  /// No description provided for @reflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflection;

  /// No description provided for @dailyPrayer.
  ///
  /// In en, this message translates to:
  /// **'Daily Prayer'**
  String get dailyPrayer;

  /// No description provided for @themeTrustGuidance.
  ///
  /// In en, this message translates to:
  /// **'Trust & Guidance'**
  String get themeTrustGuidance;

  /// No description provided for @themePeaceRest.
  ///
  /// In en, this message translates to:
  /// **'Peace & Rest'**
  String get themePeaceRest;

  /// No description provided for @themeStrengthCourage.
  ///
  /// In en, this message translates to:
  /// **'Strength & Courage'**
  String get themeStrengthCourage;

  /// No description provided for @themeHopeFuture.
  ///
  /// In en, this message translates to:
  /// **'Hope & Future'**
  String get themeHopeFuture;

  /// No description provided for @themeLoveGrace.
  ///
  /// In en, this message translates to:
  /// **'Love & Grace'**
  String get themeLoveGrace;

  /// No description provided for @themeFaithTrust.
  ///
  /// In en, this message translates to:
  /// **'Faith & Trust'**
  String get themeFaithTrust;

  /// No description provided for @themeWisdomUnderstanding.
  ///
  /// In en, this message translates to:
  /// **'Wisdom & Understanding'**
  String get themeWisdomUnderstanding;

  /// No description provided for @prayerPrivateDescription.
  ///
  /// In en, this message translates to:
  /// **'Private entries stored on this device.'**
  String get prayerPrivateDescription;

  /// No description provided for @newPrayer.
  ///
  /// In en, this message translates to:
  /// **'New prayer'**
  String get newPrayer;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @categoryPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get categoryPersonal;

  /// No description provided for @categoryGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get categoryGratitude;

  /// No description provided for @categoryGuidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get categoryGuidance;

  /// No description provided for @categoryHealing.
  ///
  /// In en, this message translates to:
  /// **'Healing'**
  String get categoryHealing;

  /// No description provided for @categoryFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get categoryFamily;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @prayerComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Write your prayer or reflection…'**
  String get prayerComposerHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntryTitle;

  /// No description provided for @cannotUndo.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotUndo;

  /// No description provided for @noArchivedPrayers.
  ///
  /// In en, this message translates to:
  /// **'No archived prayers.'**
  String get noArchivedPrayers;

  /// No description provided for @emptyPrayerJournal.
  ///
  /// In en, this message translates to:
  /// **'Your prayer journal is empty. Add your first entry.'**
  String get emptyPrayerJournal;

  /// No description provided for @studyPlans.
  ///
  /// In en, this message translates to:
  /// **'Study plans'**
  String get studyPlans;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @myPlans.
  ///
  /// In en, this message translates to:
  /// **'My Plans'**
  String get myPlans;

  /// No description provided for @studyDurationAndTopics.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day • {topics}} other{{days} days • {topics}}}'**
  String studyDurationAndTopics(int days, String topics);

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @startPlan.
  ///
  /// In en, this message translates to:
  /// **'Start Plan'**
  String get startPlan;

  /// No description provided for @studyMyPlansEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start a plan to see your progress here.'**
  String get studyMyPlansEmpty;

  /// No description provided for @studyProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total}'**
  String studyProgress(int completed, int total);

  /// No description provided for @studyDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String studyDay(int day);

  /// No description provided for @removePlan.
  ///
  /// In en, this message translates to:
  /// **'Remove plan'**
  String get removePlan;

  /// No description provided for @studyLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day}: {title}'**
  String studyLessonTitle(int day, String title);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark Complete'**
  String get markComplete;

  /// No description provided for @profileCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Current streak} other{Current streak}}'**
  String profileCurrentStreak(int count);

  /// No description provided for @profileLongestStreak.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Longest streak} other{Longest streak}}'**
  String profileLongestStreak(int count);

  /// No description provided for @profileDailyPlans.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Daily plan} other{Daily plans}}'**
  String profileDailyPlans(int count);

  /// No description provided for @profileStudyPlans.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Study plan} other{Study plans}}'**
  String profileStudyPlans(int count);

  /// No description provided for @profileFavoriteVerses.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Favorite verse} other{Favorite verses}}'**
  String profileFavoriteVerses(int count);

  /// No description provided for @profilePrayerEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Prayer entry} other{Prayer entries}}'**
  String profilePrayerEntries(int count);

  /// No description provided for @profileAiMessages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{AI message} other{AI messages}}'**
  String profileAiMessages(int count);

  /// No description provided for @yourJourney.
  ///
  /// In en, this message translates to:
  /// **'Your journey'**
  String get yourJourney;

  /// No description provided for @dataStoredOnly.
  ///
  /// In en, this message translates to:
  /// **'Data is stored only on this device.'**
  String get dataStoredOnly;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @profilePrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Favorites, progress, prayers, and chat history stay in this browser. AI questions and selected scripture context leave the device only when you send a Bible AI request.'**
  String get profilePrivacyDescription;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In en, this message translates to:
  /// **'Appearance and language'**
  String get appearanceAndLanguage;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @inAppReminder.
  ///
  /// In en, this message translates to:
  /// **'In-app reminder'**
  String get inAppReminder;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminder;

  /// No description provided for @reminderVisibility.
  ///
  /// In en, this message translates to:
  /// **'Shown only when the app is open or resumed.'**
  String get reminderVisibility;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @personalWorkerToken.
  ///
  /// In en, this message translates to:
  /// **'Personal Worker access token'**
  String get personalWorkerToken;

  /// No description provided for @enterToken.
  ///
  /// In en, this message translates to:
  /// **'Enter token'**
  String get enterToken;

  /// No description provided for @tokenAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'A token is already saved'**
  String get tokenAlreadySaved;

  /// No description provided for @hideToken.
  ///
  /// In en, this message translates to:
  /// **'Hide token'**
  String get hideToken;

  /// No description provided for @showToken.
  ///
  /// In en, this message translates to:
  /// **'Show token'**
  String get showToken;

  /// No description provided for @removeToken.
  ///
  /// In en, this message translates to:
  /// **'Remove token'**
  String get removeToken;

  /// No description provided for @tokenSaved.
  ///
  /// In en, this message translates to:
  /// **'Token saved.'**
  String get tokenSaved;

  /// No description provided for @saveToken.
  ///
  /// In en, this message translates to:
  /// **'Save token'**
  String get saveToken;

  /// No description provided for @aiPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'AI questions, recent chat turns, and selected Bible passages are processed by Cloudflare Workers AI. No external AI API key is stored in this app.'**
  String get aiPrivacyDescription;

  /// No description provided for @localData.
  ///
  /// In en, this message translates to:
  /// **'Local data'**
  String get localData;

  /// No description provided for @requestDurableStorage.
  ///
  /// In en, this message translates to:
  /// **'Request durable storage'**
  String get requestDurableStorage;

  /// No description provided for @durableStorageWarning.
  ///
  /// In en, this message translates to:
  /// **'iOS may still remove website data. Export important entries regularly.'**
  String get durableStorageWarning;

  /// No description provided for @exportMyData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportMyData;

  /// No description provided for @tokenExcluded.
  ///
  /// In en, this message translates to:
  /// **'The AI access token is excluded.'**
  String get tokenExcluded;

  /// No description provided for @resetLocalData.
  ///
  /// In en, this message translates to:
  /// **'Reset local data'**
  String get resetLocalData;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Personal offline-first PWA • {version}'**
  String aboutDescription(String version);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @webPushUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Web Push is not included in this release.'**
  String get webPushUnavailable;

  /// No description provided for @durableStorageGranted.
  ///
  /// In en, this message translates to:
  /// **'Durable storage was granted.'**
  String get durableStorageGranted;

  /// No description provided for @durableStorageNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Durable storage was not granted. Keep regular exports.'**
  String get durableStorageNotGranted;

  /// No description provided for @exportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Data export is not available on this platform.'**
  String get exportUnavailable;

  /// No description provided for @resetAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all local data?'**
  String get resetAllDataTitle;

  /// No description provided for @resetAllDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Favorites, plans, prayers, chats, settings, and the AI token will be deleted from this device.'**
  String get resetAllDataDescription;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @reminderBanner.
  ///
  /// In en, this message translates to:
  /// **'Your daily plan is ready.'**
  String get reminderBanner;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @listenPlans.
  ///
  /// In en, this message translates to:
  /// **'Listen plans'**
  String get listenPlans;

  /// No description provided for @readingPlans.
  ///
  /// In en, this message translates to:
  /// **'Reading Plans'**
  String get readingPlans;

  /// No description provided for @activePlans.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} active plan} other{{count} active plans}}'**
  String activePlans(int count);

  /// No description provided for @myPlansEmpty.
  ///
  /// In en, this message translates to:
  /// **'No active reading plans yet.'**
  String get myPlansEmpty;

  /// No description provided for @startPlanToSeeProgress.
  ///
  /// In en, this message translates to:
  /// **'Start a plan to see your progress here.'**
  String get startPlanToSeeProgress;

  /// No description provided for @planDuration.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day} other{{days} days}}'**
  String planDuration(int days);

  /// No description provided for @planBook.
  ///
  /// In en, this message translates to:
  /// **'Book: {book}'**
  String planBook(String book);

  /// No description provided for @planReadings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} reading} other{{count} readings}}'**
  String planReadings(int count);

  /// No description provided for @planSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get planSchedule;

  /// No description provided for @planProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total}'**
  String planProgress(int completed, int total);

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completePlan.
  ///
  /// In en, this message translates to:
  /// **'Complete Plan'**
  String get completePlan;

  /// No description provided for @completePlanConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Mark all readings in \'{title}\' as complete?'**
  String completePlanConfirmation(Object title);

  /// No description provided for @planNotFound.
  ///
  /// In en, this message translates to:
  /// **'Plan not found.'**
  String get planNotFound;

  /// No description provided for @noReadingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No readings available for this plan.'**
  String get noReadingsAvailable;

  /// No description provided for @readingPlansUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Reading plans are currently unavailable.'**
  String get readingPlansUnavailable;

  /// No description provided for @listenDurationAndDays.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, one{{minutes} minute • {days} day} other{{minutes} minutes • {days} days}}'**
  String listenDurationAndDays(int minutes, int days);

  /// No description provided for @listenMyPlansEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start a listen plan to see your progress here.'**
  String get listenMyPlansEmpty;

  /// No description provided for @listenProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total}'**
  String listenProgress(int completed, int total);

  /// No description provided for @listenDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String listenDay(int day);

  /// No description provided for @listenDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day}: {title}'**
  String listenDayTitle(int day, String title);

  /// No description provided for @listenAudioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Audio playback will be implemented in a future update.'**
  String get listenAudioPlaceholder;

  /// No description provided for @lentTitle.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get lentTitle;

  /// No description provided for @lentLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading Lent journey...'**
  String get lentLoading;

  /// No description provided for @lentProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed, plural, one{{completed} of {total} day complete} other{{completed} of {total} days complete}}'**
  String lentProgress(int completed, int total);

  /// No description provided for @lentDayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String lentDayNumber(int day);

  /// No description provided for @lentDailyVerse.
  ///
  /// In en, this message translates to:
  /// **'Daily Verse'**
  String get lentDailyVerse;

  /// No description provided for @lentDailyPrayer.
  ///
  /// In en, this message translates to:
  /// **'Daily Prayer'**
  String get lentDailyPrayer;

  /// No description provided for @lentAudioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Audio playback will be implemented in a future update.'**
  String get lentAudioPlaceholder;

  /// No description provided for @loadingTranslations.
  ///
  /// In en, this message translates to:
  /// **'Loading translations…'**
  String get loadingTranslations;

  /// No description provided for @selectTranslation.
  ///
  /// In en, this message translates to:
  /// **'Select Translation'**
  String get selectTranslation;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Bible Path'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Let\'s personalize your experience. We\'ll ask a few quick questions to set up the best Bible version and content for you.'**
  String get onboardingWelcomeDescription;

  /// No description provided for @onboardingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingLanguage;

  /// No description provided for @onboardingTranslationStyle.
  ///
  /// In en, this message translates to:
  /// **'Translation style'**
  String get onboardingTranslationStyle;

  /// No description provided for @onboardingDenomination.
  ///
  /// In en, this message translates to:
  /// **'Denomination'**
  String get onboardingDenomination;

  /// No description provided for @onboardingStyleFormal.
  ///
  /// In en, this message translates to:
  /// **'Formal (KJV-style)'**
  String get onboardingStyleFormal;

  /// No description provided for @onboardingStyleContemporary.
  ///
  /// In en, this message translates to:
  /// **'Contemporary (NIV-style)'**
  String get onboardingStyleContemporary;

  /// No description provided for @onboardingStyleSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple (NLT-style)'**
  String get onboardingStyleSimple;

  /// No description provided for @onboardingStyleLiterary.
  ///
  /// In en, this message translates to:
  /// **'Literary (ESV-style)'**
  String get onboardingStyleLiterary;

  /// No description provided for @onboardingDenominationCatholic.
  ///
  /// In en, this message translates to:
  /// **'Catholic'**
  String get onboardingDenominationCatholic;

  /// No description provided for @onboardingDenominationOrthodox.
  ///
  /// In en, this message translates to:
  /// **'Orthodox'**
  String get onboardingDenominationOrthodox;

  /// No description provided for @onboardingDenominationProtestant.
  ///
  /// In en, this message translates to:
  /// **'Protestant'**
  String get onboardingDenominationProtestant;

  /// No description provided for @onboardingDenominationNonDenominational.
  ///
  /// In en, this message translates to:
  /// **'Non-denominational'**
  String get onboardingDenominationNonDenominational;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get onboardingComplete;

  /// No description provided for @adventTitle.
  ///
  /// In en, this message translates to:
  /// **'Advent'**
  String get adventTitle;

  /// No description provided for @adventDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get adventDay;

  /// No description provided for @adventScripture.
  ///
  /// In en, this message translates to:
  /// **'Scripture'**
  String get adventScripture;

  /// No description provided for @adventReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get adventReflection;

  /// No description provided for @adventPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get adventPrayer;

  /// No description provided for @adventWeekHope.
  ///
  /// In en, this message translates to:
  /// **'Hope'**
  String get adventWeekHope;

  /// No description provided for @adventWeekPeace.
  ///
  /// In en, this message translates to:
  /// **'Peace'**
  String get adventWeekPeace;

  /// No description provided for @adventWeekJoy.
  ///
  /// In en, this message translates to:
  /// **'Joy'**
  String get adventWeekJoy;

  /// No description provided for @adventWeekLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get adventWeekLove;

  /// No description provided for @adventComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Advent begins in {days} days'**
  String adventComingSoon(int days);

  /// No description provided for @adventNotInSeason.
  ///
  /// In en, this message translates to:
  /// **'Advent season begins December 1'**
  String get adventNotInSeason;

  /// No description provided for @adventCountdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Advent'**
  String get adventCountdownTitle;

  /// No description provided for @adventCountdownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Advent begins in {days} days. Prepare your heart for the coming of Christ.'**
  String adventCountdownSubtitle(int days);

  /// No description provided for @adventErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load Advent calendar'**
  String get adventErrorTitle;

  /// No description provided for @adventRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get adventRetry;

  /// No description provided for @adventRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adventRefresh;

  /// No description provided for @adventNoData.
  ///
  /// In en, this message translates to:
  /// **'Advent calendar data not available'**
  String get adventNoData;

  /// No description provided for @adventDayLocked.
  ///
  /// In en, this message translates to:
  /// **'This day is locked'**
  String get adventDayLocked;

  /// No description provided for @adventDayLockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Day {day} will unlock on December {day}'**
  String adventDayLockedSubtitle(int day);

  /// No description provided for @adventSeasonActive.
  ///
  /// In en, this message translates to:
  /// **'Advent season is active'**
  String get adventSeasonActive;

  /// No description provided for @holyCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Holy Calendar'**
  String get holyCalendarTitle;

  /// No description provided for @holyCalendarNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No celebrations are available for this month.'**
  String get holyCalendarNoEvents;

  /// No description provided for @holyCalendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'The calendar could not be loaded. Please try again.'**
  String get holyCalendarLoadError;

  /// No description provided for @holyCalendarRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get holyCalendarRetry;

  /// No description provided for @holyCalendarReadings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get holyCalendarReadings;

  /// No description provided for @holyCalendarFasting.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get holyCalendarFasting;

  /// No description provided for @holyCalendarSaints.
  ///
  /// In en, this message translates to:
  /// **'Saints'**
  String get holyCalendarSaints;

  /// No description provided for @holyCalendarObligation.
  ///
  /// In en, this message translates to:
  /// **'Holy day of obligation'**
  String get holyCalendarObligation;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @speechNotice.
  ///
  /// In en, this message translates to:
  /// **'Browser voice, not recorded audio. Voices may need internet. Changing speed restarts reading; background playback is not guaranteed.'**
  String get speechNotice;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Read-aloud is unavailable here or this passage has no text.'**
  String get speechUnavailable;

  /// No description provided for @speechError.
  ///
  /// In en, this message translates to:
  /// **'Voice playback failed. Retry or check device voices.'**
  String get speechError;

  /// No description provided for @speechPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get speechPlay;

  /// No description provided for @speechPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get speechPause;

  /// No description provided for @speechStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get speechStop;

  /// No description provided for @speechRate.
  ///
  /// In en, this message translates to:
  /// **'Reading speed'**
  String get speechRate;

  /// No description provided for @speechVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get speechVoice;

  /// No description provided for @speechDefaultVoice.
  ///
  /// In en, this message translates to:
  /// **'Automatic (reading language)'**
  String get speechDefaultVoice;

  /// No description provided for @speechNoVoices.
  ///
  /// In en, this message translates to:
  /// **'Device voices are still loading. Try again shortly.'**
  String get speechNoVoices;

  /// No description provided for @speechContinueChapters.
  ///
  /// In en, this message translates to:
  /// **'Continue to the next chapter'**
  String get speechContinueChapters;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
