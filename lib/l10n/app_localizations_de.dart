// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Bible Path';

  @override
  String get startupFailureTitle => 'Bible Path konnte nicht gestartet werden.';

  @override
  String startupFailureDetails(String error) {
    return 'Details: $error';
  }

  @override
  String get navHome => 'Startseite';

  @override
  String get navBible => 'Bibel';

  @override
  String get navAi => 'KI';

  @override
  String get navDaily => 'Täglich';

  @override
  String get navPrayer => 'Gebet';

  @override
  String get navStudy => 'Bibelstudium';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navMore => 'Mehr';

  @override
  String get homeTagline =>
      'Ein ruhiger Ort für Bibellektüre, Gebet und die tägliche Glaubenspraxis.';

  @override
  String get dailyVerse => 'Tagesvers';

  @override
  String get openBiblePrompt =>
      'Öffne die Bibel, um mit dem Lesen zu beginnen.';

  @override
  String get openBible => 'Bibel öffnen';

  @override
  String get todaysPlan => 'Heutiger Plan';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie: $count Tage',
      one: 'Serie: $count Tag',
    );
    return '$_temp0';
  }

  @override
  String get noPlanAvailable => 'Kein Plan verfügbar.';

  @override
  String planStepsComplete(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$completed von $total Schritten abgeschlossen',
      one: '$completed von $total Schritt abgeschlossen',
    );
    return '$_temp0';
  }

  @override
  String get continueAction => 'Fortfahren';

  @override
  String get continueJourney => 'Setze deinen Weg fort';

  @override
  String get bibleAi => 'Bibel-KI';

  @override
  String questionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fragen',
      one: '$count Frage',
    );
    return '$_temp0';
  }

  @override
  String get studyTitle => 'Bibelstudium';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktive Pläne',
      one: '$count aktiver Plan',
    );
    return '$_temp0';
  }

  @override
  String get prayerJournal => 'Gebetstagebuch';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '$count Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favoriten';

  @override
  String verseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Verse',
      one: '$count Vers',
    );
    return '$_temp0';
  }

  @override
  String get translationUnavailable => 'Diese Übersetzung ist nicht verfügbar.';

  @override
  String get searchBooksOrVerses => 'Bücher oder Verse suchen…';

  @override
  String get books => 'Bücher';

  @override
  String chapterTitle(String book, int chapter) {
    return '$book $chapter';
  }

  @override
  String get previousChapter => 'Vorheriges Kapitel';

  @override
  String chapterProgress(int chapter, int chapterCount) {
    return '$chapter/$chapterCount';
  }

  @override
  String get nextChapter => 'Nächstes Kapitel';

  @override
  String get chapterNotAvailable => 'Kapitel nicht verfügbar.';

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
  String get verseActions => 'Versoptionen';

  @override
  String get removeFavorite => 'Aus Favoriten entfernen';

  @override
  String get addFavorite => 'Zu Favoriten hinzufügen';

  @override
  String get copy => 'Kopieren';

  @override
  String get share => 'Teilen';

  @override
  String get verseCopied => 'Vers wurde in die Zwischenablage kopiert.';

  @override
  String get noResults => 'Keine Ergebnisse.';

  @override
  String verseReference(String book, int chapter, String verse) {
    return '$book $chapter:$verse';
  }

  @override
  String get bibleContentUnavailable =>
      'Die Bibelinhalte konnten nicht geladen werden.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get chatHistory => 'Chatverlauf';

  @override
  String get chatSecureStatus =>
      'Fragen werden sicher über deinen Worker gesendet.';

  @override
  String get aiEndpointNotConfigured =>
      'Der KI-Endpunkt ist für diese Version nicht konfiguriert.';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String newChatNumber(int number) {
    return 'Neuer Chat $number';
  }

  @override
  String get askBibleHint => 'Stelle eine Frage zur Bibel oder zum Glauben…';

  @override
  String get send => 'Senden';

  @override
  String get noMessages => 'Keine Nachrichten';

  @override
  String get deleteChat => 'Chat löschen';

  @override
  String get suggestionPrayerFocus => 'Wie kann ich konzentrierter beten?';

  @override
  String get suggestionJohnContext => 'Erkläre Johannes 3,16 im Kontext.';

  @override
  String get suggestionAnxiety => 'Welche Bibelstellen sprechen über Angst?';

  @override
  String get suggestionDevotional => 'Gib mir eine kurze Andacht für heute.';

  @override
  String get chatPrivacyIntro =>
      'Stelle eine Frage. Die letzten Chatbeiträge und der ausgewählte Bibelkontext werden an Cloudflare Workers AI gesendet.';

  @override
  String responseTruncated(String response) {
    return '$response\n\n[Antwort gekürzt]';
  }

  @override
  String get aiNotConfigured =>
      'Die KI ist für diese Version nicht konfiguriert.';

  @override
  String get aiMissingToken =>
      'Gib deinen persönlichen KI-Zugriffstoken in den Einstellungen ein.';

  @override
  String get aiUnavailableLater =>
      'Die Bibel-KI ist nicht verfügbar. Versuche es später erneut.';

  @override
  String get aiInvalidResponse =>
      'Die Bibel-KI hat eine ungültige Antwort zurückgegeben.';

  @override
  String get aiUnavailableConnection =>
      'Die Bibel-KI ist nicht verfügbar. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get dailyPlan => 'Tagesplan';

  @override
  String bestStreak(int count) {
    return 'Bestwert: $count';
  }

  @override
  String get today => 'Heute';

  @override
  String get history => 'Verlauf';

  @override
  String get completeTodaysPlan => 'Heutigen Plan abschließen';

  @override
  String get dailyHistoryEmpty =>
      'Schließe deinen ersten Tagesplan ab, um einen Verlauf zu beginnen.';

  @override
  String get todaysVerse => 'Heutiger Vers';

  @override
  String get dailyDevotional => 'Andacht des Tages';

  @override
  String get reading => 'Lesen';

  @override
  String get listening => 'Hören';

  @override
  String get reflection => 'Reflexion';

  @override
  String get dailyPrayer => 'Gebet des Tages';

  @override
  String get themeTrustGuidance => 'Vertrauen und Führung';

  @override
  String get themePeaceRest => 'Frieden und Ruhe';

  @override
  String get themeStrengthCourage => 'Stärke und Mut';

  @override
  String get themeHopeFuture => 'Hoffnung und Zukunft';

  @override
  String get themeLoveGrace => 'Liebe und Gnade';

  @override
  String get themeFaithTrust => 'Glaube und Vertrauen';

  @override
  String get themeWisdomUnderstanding => 'Weisheit und Verständnis';

  @override
  String get prayerPrivateDescription =>
      'Private Einträge werden auf diesem Gerät gespeichert.';

  @override
  String get newPrayer => 'Neues Gebet';

  @override
  String get active => 'Aktiv';

  @override
  String get archived => 'Archiviert';

  @override
  String get categoryPersonal => 'Persönlich';

  @override
  String get categoryGratitude => 'Dankbarkeit';

  @override
  String get categoryGuidance => 'Führung';

  @override
  String get categoryHealing => 'Heilung';

  @override
  String get categoryFamily => 'Familie';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get archive => 'Archivieren';

  @override
  String get delete => 'Löschen';

  @override
  String get prayerComposerHint =>
      'Schreibe dein Gebet oder deine Gedanken auf…';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get deleteEntryTitle => 'Eintrag löschen?';

  @override
  String get cannotUndo => 'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get noArchivedPrayers => 'Keine archivierten Gebete.';

  @override
  String get emptyPrayerJournal =>
      'Dein Gebetstagebuch ist leer. Füge deinen ersten Eintrag hinzu.';

  @override
  String get studyPlans => 'Studienpläne';

  @override
  String get available => 'Verfügbar';

  @override
  String get myPlans => 'Meine Pläne';

  @override
  String studyDurationAndTopics(int days, String topics) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage • $topics',
      one: '$days Tag • $topics',
    );
    return '$_temp0';
  }

  @override
  String get started => 'Gestartet';

  @override
  String get startPlan => 'Plan starten';

  @override
  String get studyMyPlansEmpty =>
      'Starte einen Plan, um deinen Fortschritt hier zu sehen.';

  @override
  String studyProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String studyDay(int day) {
    return 'Tag $day';
  }

  @override
  String get removePlan => 'Plan entfernen';

  @override
  String studyLessonTitle(int day, String title) {
    return 'Tag $day: $title';
  }

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get markComplete => 'Als abgeschlossen markieren';

  @override
  String profileCurrentStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aktuelle Serie',
      one: 'Aktuelle Serie',
    );
    return '$_temp0';
  }

  @override
  String profileLongestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Längste Serie',
      one: 'Längste Serie',
    );
    return '$_temp0';
  }

  @override
  String profileDailyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tagespläne',
      one: 'Tagesplan',
    );
    return '$_temp0';
  }

  @override
  String profileStudyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Studienpläne',
      one: 'Studienplan',
    );
    return '$_temp0';
  }

  @override
  String profileFavoriteVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lieblingsverse',
      one: 'Lieblingsvers',
    );
    return '$_temp0';
  }

  @override
  String profilePrayerEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gebetseinträge',
      one: 'Gebetseintrag',
    );
    return '$_temp0';
  }

  @override
  String profileAiMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'KI-Nachrichten',
      one: 'KI-Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get yourJourney => 'Dein Weg';

  @override
  String get dataStoredOnly =>
      'Die Daten werden nur auf diesem Gerät gespeichert.';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get profilePrivacyDescription =>
      'Favoriten, Fortschritte, Gebete und der Chatverlauf bleiben in diesem Browser. KI-Fragen und ausgewählte Bibelstellen verlassen das Gerät nur, wenn du eine Anfrage an die Bibel-KI sendest.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get appearanceAndLanguage => 'Darstellung und Sprache';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get textSize => 'Schriftgröße';

  @override
  String get language => 'Sprache';

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
  String get translation => 'Bibelübersetzung';

  @override
  String get inAppReminder => 'App-interne Erinnerung';

  @override
  String get dailyReminder => 'Tägliche Erinnerung';

  @override
  String get reminderVisibility =>
      'Wird nur angezeigt, wenn die App geöffnet oder wieder in den Vordergrund geholt wird.';

  @override
  String get reminderTime => 'Erinnerungszeit';

  @override
  String get personalWorkerToken => 'Persönlicher Worker-Zugriffstoken';

  @override
  String get enterToken => 'Token eingeben';

  @override
  String get tokenAlreadySaved => 'Ein Token ist bereits gespeichert';

  @override
  String get hideToken => 'Token ausblenden';

  @override
  String get showToken => 'Token anzeigen';

  @override
  String get removeToken => 'Token entfernen';

  @override
  String get tokenSaved => 'Token gespeichert.';

  @override
  String get saveToken => 'Token speichern';

  @override
  String get aiPrivacyDescription =>
      'KI-Fragen, die letzten Chatbeiträge und ausgewählte Bibelstellen werden von Cloudflare Workers AI verarbeitet. In dieser App wird kein externer KI-API-Schlüssel gespeichert.';

  @override
  String get localData => 'Lokale Daten';

  @override
  String get requestDurableStorage => 'Dauerhaften Speicher anfordern';

  @override
  String get durableStorageWarning =>
      'iOS kann Websitedaten trotzdem entfernen. Exportiere wichtige Einträge regelmäßig.';

  @override
  String get exportMyData => 'Meine Daten exportieren';

  @override
  String get tokenExcluded => 'Der KI-Zugriffstoken ist ausgeschlossen.';

  @override
  String get resetLocalData => 'Lokale Daten zurücksetzen';

  @override
  String get about => 'Über die App';

  @override
  String aboutDescription(String version) {
    return 'Persönliche, offline nutzbare PWA • $version';
  }

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get webPushUnavailable =>
      'Web-Push-Benachrichtigungen sind in dieser Version nicht enthalten.';

  @override
  String get durableStorageGranted => 'Dauerhafter Speicher wurde gewährt.';

  @override
  String get durableStorageNotGranted =>
      'Dauerhafter Speicher wurde nicht gewährt. Erstelle regelmäßig Exporte.';

  @override
  String get exportUnavailable =>
      'Der Datenexport ist auf dieser Plattform nicht verfügbar.';

  @override
  String get resetAllDataTitle => 'Alle lokalen Daten zurücksetzen?';

  @override
  String get resetAllDataDescription =>
      'Favoriten, Pläne, Gebete, Chats, Einstellungen und der KI-Token werden von diesem Gerät gelöscht.';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get reminderBanner => 'Dein Tagesplan ist bereit.';

  @override
  String get dismiss => 'Schließen';

  @override
  String get edit => 'Bearbeiten';
}
