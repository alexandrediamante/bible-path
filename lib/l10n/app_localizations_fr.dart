// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Bible Path';

  @override
  String get startupFailureTitle => 'Bible Path n’a pas pu démarrer.';

  @override
  String startupFailureDetails(String error) {
    return 'Détails : $error';
  }

  @override
  String get navHome => 'Accueil';

  @override
  String get navBible => 'Bible';

  @override
  String get navAi => 'IA';

  @override
  String get navDaily => 'Quotidien';

  @override
  String get navPrayer => 'Prière';

  @override
  String get navStudy => 'Étude';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navMore => 'Plus';

  @override
  String get homeTagline =>
      'Un espace paisible pour lire les Écritures, prier et pratiquer sa foi au quotidien.';

  @override
  String get dailyVerse => 'Verset du jour';

  @override
  String get openBiblePrompt => 'Ouvrez la Bible pour commencer votre lecture.';

  @override
  String get openBible => 'Ouvrir la Bible';

  @override
  String get todaysPlan => 'Programme du jour';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série de $count jours',
      one: 'Série de $count jour',
    );
    return '$_temp0';
  }

  @override
  String get noPlanAvailable => 'Aucun programme disponible.';

  @override
  String planStepsComplete(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$completed étapes terminées sur $total',
      one: '$completed étape terminée sur $total',
    );
    return '$_temp0';
  }

  @override
  String get continueAction => 'Continuer';

  @override
  String get continueJourney => 'Poursuivez votre parcours';

  @override
  String get bibleAi => 'IA biblique';

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
  String get studyTitle => 'Étude';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count programmes actifs',
      one: '$count programme actif',
    );
    return '$_temp0';
  }

  @override
  String get prayerJournal => 'Journal de prière';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '$count entrée',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favoris';

  @override
  String verseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versets',
      one: '$count verset',
    );
    return '$_temp0';
  }

  @override
  String get translationUnavailable => 'Cette traduction n’est pas disponible.';

  @override
  String get searchBooksOrVerses => 'Rechercher des livres ou des versets…';

  @override
  String get books => 'Livres';

  @override
  String chapterTitle(String book, int chapter) {
    return '$book $chapter';
  }

  @override
  String get previousChapter => 'Chapitre précédent';

  @override
  String chapterProgress(int chapter, int chapterCount) {
    return '$chapter/$chapterCount';
  }

  @override
  String get nextChapter => 'Chapitre suivant';

  @override
  String get chapterNotAvailable => 'Chapitre indisponible.';

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
  String get verseActions => 'Actions du verset';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get copy => 'Copier';

  @override
  String get share => 'Partager';

  @override
  String get verseCopied => 'Verset copié dans le presse-papiers.';

  @override
  String get noResults => 'Aucun résultat.';

  @override
  String verseReference(String book, int chapter, String verse) {
    return '$book $chapter:$verse';
  }

  @override
  String get bibleContentUnavailable =>
      'Le contenu de la Bible n’a pas pu être chargé.';

  @override
  String get retry => 'Réessayer';

  @override
  String get chatHistory => 'Historique des discussions';

  @override
  String get chatSecureStatus =>
      'Les questions sont envoyées de manière sécurisée via votre Worker.';

  @override
  String get aiEndpointNotConfigured =>
      'Le point de terminaison de l’IA n’est pas configuré pour cette version.';

  @override
  String get newChat => 'Nouvelle discussion';

  @override
  String newChatNumber(int number) {
    return 'Nouvelle discussion $number';
  }

  @override
  String get askBibleHint => 'Posez une question sur la Bible ou la foi…';

  @override
  String get send => 'Envoyer';

  @override
  String get noMessages => 'Aucun message';

  @override
  String get deleteChat => 'Supprimer la discussion';

  @override
  String get suggestionPrayerFocus =>
      'Comment puis-je prier avec plus de concentration ?';

  @override
  String get suggestionJohnContext => 'Expliquez Jean 3:16 dans son contexte.';

  @override
  String get suggestionAnxiety => 'Quels passages parlent de l’anxiété ?';

  @override
  String get suggestionDevotional =>
      'Proposez-moi une courte méditation pour aujourd’hui.';

  @override
  String get chatPrivacyIntro =>
      'Posez une question. Les échanges récents et le contexte biblique sélectionné sont envoyés à Cloudflare Workers AI.';

  @override
  String responseTruncated(String response) {
    return '$response\n\n[Réponse tronquée]';
  }

  @override
  String get aiNotConfigured => 'L’IA n’est pas configurée pour cette version.';

  @override
  String get aiMissingToken =>
      'Saisissez votre jeton d’accès personnel à l’IA dans les paramètres.';

  @override
  String get aiUnavailableLater =>
      'L’IA biblique est indisponible. Réessayez plus tard.';

  @override
  String get aiInvalidResponse =>
      'L’IA biblique a renvoyé une réponse non valide.';

  @override
  String get aiUnavailableConnection =>
      'L’IA biblique est indisponible. Vérifiez votre connexion et réessayez.';

  @override
  String get dailyPlan => 'Programme quotidien';

  @override
  String bestStreak(int count) {
    return 'Record : $count';
  }

  @override
  String get today => 'Aujourd’hui';

  @override
  String get history => 'Historique';

  @override
  String get completeTodaysPlan => 'Terminer le programme du jour';

  @override
  String get dailyHistoryEmpty =>
      'Terminez votre premier programme quotidien pour commencer votre historique.';

  @override
  String get todaysVerse => 'Verset du jour';

  @override
  String get dailyDevotional => 'Méditation du jour';

  @override
  String get reading => 'Lecture';

  @override
  String get listening => 'Écoute';

  @override
  String get reflection => 'Réflexion';

  @override
  String get dailyPrayer => 'Prière du jour';

  @override
  String get themeTrustGuidance => 'Confiance et orientation';

  @override
  String get themePeaceRest => 'Paix et repos';

  @override
  String get themeStrengthCourage => 'Force et courage';

  @override
  String get themeHopeFuture => 'Espoir et avenir';

  @override
  String get themeLoveGrace => 'Amour et grâce';

  @override
  String get themeFaithTrust => 'Foi et confiance';

  @override
  String get themeWisdomUnderstanding => 'Sagesse et compréhension';

  @override
  String get prayerPrivateDescription =>
      'Entrées privées enregistrées sur cet appareil.';

  @override
  String get newPrayer => 'Nouvelle prière';

  @override
  String get active => 'Actives';

  @override
  String get archived => 'Archivées';

  @override
  String get categoryPersonal => 'Personnel';

  @override
  String get categoryGratitude => 'Gratitude';

  @override
  String get categoryGuidance => 'Orientation';

  @override
  String get categoryHealing => 'Guérison';

  @override
  String get categoryFamily => 'Famille';

  @override
  String get restore => 'Restaurer';

  @override
  String get archive => 'Archiver';

  @override
  String get delete => 'Supprimer';

  @override
  String get prayerComposerHint => 'Écrivez votre prière ou votre réflexion…';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get deleteEntryTitle => 'Supprimer cette entrée ?';

  @override
  String get cannotUndo => 'Cette action est irréversible.';

  @override
  String get noArchivedPrayers => 'Aucune prière archivée.';

  @override
  String get emptyPrayerJournal =>
      'Votre journal de prière est vide. Ajoutez votre première entrée.';

  @override
  String get studyPlans => 'Programmes d’étude';

  @override
  String get available => 'Disponibles';

  @override
  String get myPlans => 'Mes programmes';

  @override
  String studyDurationAndTopics(int days, String topics) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours • $topics',
      one: '$days jour • $topics',
    );
    return '$_temp0';
  }

  @override
  String get started => 'Commencés';

  @override
  String get startPlan => 'Commencer le programme';

  @override
  String get studyMyPlansEmpty =>
      'Commencez un programme pour suivre votre progression ici.';

  @override
  String studyProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String studyDay(int day) {
    return 'Jour $day';
  }

  @override
  String get removePlan => 'Supprimer le programme';

  @override
  String studyLessonTitle(int day, String title) {
    return 'Jour $day : $title';
  }

  @override
  String get completed => 'Terminé';

  @override
  String get markComplete => 'Marquer comme terminé';

  @override
  String profileCurrentStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série en cours',
      one: 'Série en cours',
    );
    return '$_temp0';
  }

  @override
  String profileLongestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Plus longue série',
      one: 'Plus longue série',
    );
    return '$_temp0';
  }

  @override
  String profileDailyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Programmes quotidiens',
      one: 'Programme quotidien',
    );
    return '$_temp0';
  }

  @override
  String profileStudyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Programmes d’étude',
      one: 'Programme d’étude',
    );
    return '$_temp0';
  }

  @override
  String profileFavoriteVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Versets favoris',
      one: 'Verset favori',
    );
    return '$_temp0';
  }

  @override
  String profilePrayerEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entrées de prière',
      one: 'Entrée de prière',
    );
    return '$_temp0';
  }

  @override
  String profileAiMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Messages de l’IA',
      one: 'Message de l’IA',
    );
    return '$_temp0';
  }

  @override
  String get yourJourney => 'Votre parcours';

  @override
  String get dataStoredOnly =>
      'Les données sont stockées uniquement sur cet appareil.';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get profilePrivacyDescription =>
      'Les favoris, la progression, les prières et l’historique des discussions restent dans ce navigateur. Les questions à l’IA et le contexte biblique sélectionné ne quittent l’appareil que lorsque vous envoyez une demande à l’IA biblique.';

  @override
  String get settings => 'Paramètres';

  @override
  String get appearanceAndLanguage => 'Apparence et langue';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get language => 'Langue';

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
  String get translation => 'Traduction biblique';

  @override
  String get inAppReminder => 'Rappel dans l’application';

  @override
  String get dailyReminder => 'Rappel quotidien';

  @override
  String get reminderVisibility =>
      'Affiché uniquement lorsque l’application est ouverte ou reprise.';

  @override
  String get reminderTime => 'Heure du rappel';

  @override
  String get personalWorkerToken => 'Jeton d’accès personnel au Worker';

  @override
  String get enterToken => 'Saisir le jeton';

  @override
  String get tokenAlreadySaved => 'Un jeton est déjà enregistré';

  @override
  String get hideToken => 'Masquer le jeton';

  @override
  String get showToken => 'Afficher le jeton';

  @override
  String get removeToken => 'Supprimer le jeton';

  @override
  String get tokenSaved => 'Jeton enregistré.';

  @override
  String get saveToken => 'Enregistrer le jeton';

  @override
  String get aiPrivacyDescription =>
      'Les questions à l’IA, les échanges récents et les passages bibliques sélectionnés sont traités par Cloudflare Workers AI. Aucune clé API d’IA externe n’est stockée dans cette application.';

  @override
  String get localData => 'Données locales';

  @override
  String get requestDurableStorage => 'Demander un stockage persistant';

  @override
  String get durableStorageWarning =>
      'iOS peut tout de même supprimer les données du site. Exportez régulièrement les entrées importantes.';

  @override
  String get exportMyData => 'Exporter mes données';

  @override
  String get tokenExcluded => 'Le jeton d’accès à l’IA est exclu.';

  @override
  String get resetLocalData => 'Réinitialiser les données locales';

  @override
  String get about => 'À propos';

  @override
  String aboutDescription(String version) {
    return 'PWA personnelle conçue pour fonctionner hors ligne • $version';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get webPushUnavailable =>
      'Les notifications Web Push ne sont pas incluses dans cette version.';

  @override
  String get durableStorageGranted => 'Le stockage persistant a été accordé.';

  @override
  String get durableStorageNotGranted =>
      'Le stockage persistant n’a pas été accordé. Effectuez régulièrement des exportations.';

  @override
  String get exportUnavailable =>
      'L’exportation des données n’est pas disponible sur cette plateforme.';

  @override
  String get resetAllDataTitle => 'Réinitialiser toutes les données locales ?';

  @override
  String get resetAllDataDescription =>
      'Les favoris, les programmes, les prières, les discussions, les paramètres et le jeton d’IA seront supprimés de cet appareil.';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get reminderBanner => 'Votre programme du jour est prêt.';

  @override
  String get dismiss => 'Fermer';

  @override
  String get edit => 'Modifier';
}
