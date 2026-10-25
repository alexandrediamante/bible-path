// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Cammino Biblico';

  @override
  String get startupFailureTitle => 'Impossibile avviare Cammino Biblico.';

  @override
  String startupFailureDetails(String error) {
    return 'Dettagli: $error';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navBible => 'Bibbia';

  @override
  String get navAi => 'IA';

  @override
  String get navDaily => 'Ogni giorno';

  @override
  String get navAdvent => 'Avvento';

  @override
  String get navPrayer => 'Preghiera';

  @override
  String get navStudy => 'Studio';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get navMore => 'Altro';

  @override
  String get navListen => 'Ascolta';

  @override
  String get homeTagline => 'Un luogo tranquillo per la Scrittura, la preghiera e la pratica quotidiana.';

  @override
  String get dailyVerse => 'Versetto del giorno';

  @override
  String get openBiblePrompt => 'Apri la Bibbia per iniziare a leggere.';

  @override
  String get openBible => 'Apri la Bibbia';

  @override
  String get todaysPlan => 'Piano di oggi';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie di $count giorni',
      one: 'Serie di $count giorno',
    );
    return '$_temp0';
  }

  @override
  String get noPlanAvailable => 'Nessun piano disponibile.';

  @override
  String planStepsComplete(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$completed di $total passaggi completati',
      one: '$completed di $total passaggio completato',
    );
    return '$_temp0';
  }

  @override
  String get continueAction => 'Continua';

  @override
  String get continueJourney => 'Continua il tuo cammino';

  @override
  String get bibleAi => 'IA biblica';

  @override
  String questionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count domande',
      one: '$count domanda',
    );
    return '$_temp0';
  }

  @override
  String get studyTitle => 'Studio';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piani attivi',
      one: '$count piano attivo',
    );
    return '$_temp0';
  }

  @override
  String get prayerJournal => 'Diario di preghiera';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci',
      one: '$count voce',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Preferiti';

  @override
  String verseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versetti',
      one: '$count versetto',
    );
    return '$_temp0';
  }

  @override
  String get translationUnavailable => 'Questa traduzione non è disponibile.';

  @override
  String get searchBooksOrVerses => 'Cerca libri o versetti…';

  @override
  String get books => 'Libri';

  @override
  String chapterTitle(String book, int chapter) {
    return '$book $chapter';
  }

  @override
  String get previousChapter => 'Capitolo precedente';

  @override
  String chapterProgress(int chapter, int chapterCount) {
    return '$chapter/$chapterCount';
  }

  @override
  String get nextChapter => 'Capitolo successivo';

  @override
  String get chapterNotAvailable => 'Capitolo non disponibile.';

  @override
  String verseShareText(String book, int chapter, int verse, String text, String version) {
    return '$book $chapter:$verse — $text ($version)';
  }

  @override
  String get verseActions => 'Azioni per il versetto';

  @override
  String get removeFavorite => 'Rimuovi dai preferiti';

  @override
  String get addFavorite => 'Aggiungi ai preferiti';

  @override
  String get copy => 'Copia';

  @override
  String get share => 'Condividi';

  @override
  String get verseCopied => 'Versetto copiato negli appunti.';

  @override
  String get noResults => 'Nessun risultato.';

  @override
  String verseReference(String book, int chapter, String verse) {
    return '$book $chapter:$verse';
  }

  @override
  String get bibleContentUnavailable => 'Impossibile caricare il contenuto della Bibbia.';

  @override
  String get retry => 'Riprova';

  @override
  String get chatHistory => 'Cronologia delle chat';

  @override
  String get chatSecureStatus => 'Le domande vengono inviate in modo sicuro tramite il tuo Worker.';

  @override
  String get aiEndpointNotConfigured => 'L\'endpoint dell\'IA non è configurato per questa build.';

  @override
  String get newChat => 'Nuova chat';

  @override
  String newChatNumber(int number) {
    return 'Nuova chat $number';
  }

  @override
  String get askBibleHint => 'Chiedi informazioni sulla Bibbia o sulla fede…';

  @override
  String get send => 'Invia';

  @override
  String get noMessages => 'Nessun messaggio';

  @override
  String get deleteChat => 'Elimina chat';

  @override
  String get suggestionPrayerFocus => 'Come posso pregare con maggiore concentrazione?';

  @override
  String get suggestionJohnContext => 'Spiegami Giovanni 3:16 nel suo contesto.';

  @override
  String get suggestionAnxiety => 'Quali passi parlano dell\'ansia?';

  @override
  String get suggestionDevotional => 'Proponimi una breve meditazione per oggi.';

  @override
  String get chatPrivacyIntro => 'Fai una domanda. I messaggi recenti della chat e il contesto biblico selezionato vengono inviati a Cloudflare Workers AI.';

  @override
  String responseTruncated(String response) {
    return '$response\n\n[Risposta troncata]';
  }

  @override
  String get aiNotConfigured => 'L\'IA non è configurata per questa build.';

  @override
  String get aiMissingToken => 'Inserisci nelle Impostazioni il tuo token personale di accesso all\'IA.';

  @override
  String get aiUnavailableLater => 'L\'IA biblica non è disponibile. Riprova più tardi.';

  @override
  String get aiInvalidResponse => 'L\'IA biblica ha restituito una risposta non valida.';

  @override
  String get aiUnavailableConnection => 'L\'IA biblica non è disponibile. Controlla la connessione e riprova.';

  @override
  String get dailyPlan => 'Piano giornaliero';

  @override
  String bestStreak(int count) {
    return 'Record: $count';
  }

  @override
  String get today => 'Oggi';

  @override
  String get history => 'Cronologia';

  @override
  String get completeTodaysPlan => 'Completa il piano di oggi';

  @override
  String get dailyHistoryEmpty => 'Completa il tuo primo piano giornaliero per iniziare la cronologia.';

  @override
  String get todaysVerse => 'Versetto di oggi';

  @override
  String get dailyDevotional => 'Meditazione quotidiana';

  @override
  String get reading => 'Lettura';

  @override
  String get listening => 'Ascolto';

  @override
  String get reflection => 'Riflessione';

  @override
  String get dailyPrayer => 'Preghiera quotidiana';

  @override
  String get themeTrustGuidance => 'Fiducia e guida';

  @override
  String get themePeaceRest => 'Pace e riposo';

  @override
  String get themeStrengthCourage => 'Forza e coraggio';

  @override
  String get themeHopeFuture => 'Speranza e futuro';

  @override
  String get themeLoveGrace => 'Amore e grazia';

  @override
  String get themeFaithTrust => 'Fede e fiducia';

  @override
  String get themeWisdomUnderstanding => 'Saggezza e comprensione';

  @override
  String get prayerPrivateDescription => 'Voci private archiviate su questo dispositivo.';

  @override
  String get newPrayer => 'Nuova preghiera';

  @override
  String get active => 'Attive';

  @override
  String get archived => 'Archiviate';

  @override
  String get categoryPersonal => 'Personale';

  @override
  String get categoryGratitude => 'Gratitudine';

  @override
  String get categoryGuidance => 'Guida';

  @override
  String get categoryHealing => 'Guarigione';

  @override
  String get categoryFamily => 'Famiglia';

  @override
  String get restore => 'Ripristina';

  @override
  String get archive => 'Archivia';

  @override
  String get delete => 'Elimina';

  @override
  String get prayerComposerHint => 'Scrivi la tua preghiera o riflessione…';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get deleteEntryTitle => 'Eliminare la voce?';

  @override
  String get cannotUndo => 'Questa azione non può essere annullata.';

  @override
  String get noArchivedPrayers => 'Nessuna preghiera archiviata.';

  @override
  String get emptyPrayerJournal => 'Il tuo diario di preghiera è vuoto. Aggiungi la tua prima voce.';

  @override
  String get studyPlans => 'Piani di studio';

  @override
  String get available => 'Disponibili';

  @override
  String get myPlans => 'I Miei Piani';

  @override
  String studyDurationAndTopics(int days, String topics) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni • $topics',
      one: '$days giorno • $topics',
    );
    return '$_temp0';
  }

  @override
  String get started => 'Iniziato';

  @override
  String get startPlan => 'Inizia Piano';

  @override
  String get studyMyPlansEmpty => 'Inizia un piano per vedere qui i tuoi progressi.';

  @override
  String studyProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String studyDay(int day) {
    return 'Giorno $day';
  }

  @override
  String get removePlan => 'Rimuovi il piano';

  @override
  String studyLessonTitle(int day, String title) {
    return 'Giorno $day: $title';
  }

  @override
  String get completed => 'Completato';

  @override
  String get markComplete => 'Segna Come Completato';

  @override
  String profileCurrentStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie attuale',
      one: 'Serie attuale',
    );
    return '$_temp0';
  }

  @override
  String profileLongestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serie più lunga',
      one: 'Serie più lunga',
    );
    return '$_temp0';
  }

  @override
  String profileDailyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piani giornalieri',
      one: 'Piano giornaliero',
    );
    return '$_temp0';
  }

  @override
  String profileStudyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Piani di studio',
      one: 'Piano di studio',
    );
    return '$_temp0';
  }

  @override
  String profileFavoriteVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Versetti preferiti',
      one: 'Versetto preferito',
    );
    return '$_temp0';
  }

  @override
  String profilePrayerEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Voci di preghiera',
      one: 'Voce di preghiera',
    );
    return '$_temp0';
  }

  @override
  String profileAiMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Messaggi dell\'IA',
      one: 'Messaggio dell\'IA',
    );
    return '$_temp0';
  }

  @override
  String get yourJourney => 'Il tuo cammino';

  @override
  String get dataStoredOnly => 'I dati vengono archiviati solo su questo dispositivo.';

  @override
  String get privacy => 'Privacy';

  @override
  String get profilePrivacyDescription => 'Preferiti, progressi, preghiere e cronologia delle chat rimangono in questo browser. Le domande all\'IA e il contesto delle Scritture selezionato lasciano il dispositivo solo quando invii una richiesta all\'IA biblica.';

  @override
  String get settings => 'Impostazioni';

  @override
  String get appearanceAndLanguage => 'Aspetto e lingua';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get textSize => 'Dimensione del testo';

  @override
  String get language => 'Lingua';

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
  String get translation => 'Traduzione';

  @override
  String get inAppReminder => 'Promemoria nell\'app';

  @override
  String get dailyReminder => 'Promemoria giornaliero';

  @override
  String get reminderVisibility => 'Visibile solo quando l\'app è aperta o viene riattivata.';

  @override
  String get reminderTime => 'Ora del promemoria';

  @override
  String get personalWorkerToken => 'Token personale di accesso al Worker';

  @override
  String get enterToken => 'Inserisci il token';

  @override
  String get tokenAlreadySaved => 'È già stato salvato un token';

  @override
  String get hideToken => 'Nascondi token';

  @override
  String get showToken => 'Mostra token';

  @override
  String get removeToken => 'Rimuovi token';

  @override
  String get tokenSaved => 'Token salvato.';

  @override
  String get saveToken => 'Salva token';

  @override
  String get aiPrivacyDescription => 'Le domande all’IA, i messaggi recenti della chat e i passi biblici selezionati vengono elaborati da Cloudflare Workers AI. In questa app non viene archiviata alcuna chiave API IA esterna.';

  @override
  String get localData => 'Dati locali';

  @override
  String get requestDurableStorage => 'Richiedi archiviazione permanente';

  @override
  String get durableStorageWarning => 'iOS potrebbe comunque rimuovere i dati del sito web. Esporta regolarmente le voci importanti.';

  @override
  String get exportMyData => 'Esporta i miei dati';

  @override
  String get tokenExcluded => 'Il token di accesso all\'IA è escluso.';

  @override
  String get resetLocalData => 'Reimposta i dati locali';

  @override
  String get about => 'Informazioni';

  @override
  String aboutDescription(String version) {
    return 'PWA personale pensata per funzionare offline • $version';
  }

  @override
  String get notifications => 'Notifiche';

  @override
  String get webPushUnavailable => 'Le notifiche push web non sono incluse in questa versione.';

  @override
  String get durableStorageGranted => 'L\'archiviazione permanente è stata concessa.';

  @override
  String get durableStorageNotGranted => 'L\'archiviazione permanente non è stata concessa. Esegui esportazioni regolari.';

  @override
  String get exportUnavailable => 'L\'esportazione dei dati non è disponibile su questa piattaforma.';

  @override
  String get resetAllDataTitle => 'Reimpostare tutti i dati locali?';

  @override
  String get resetAllDataDescription => 'Preferiti, piani, preghiere, chat, impostazioni e token dell\'IA verranno eliminati da questo dispositivo.';

  @override
  String get reset => 'Reimposta';

  @override
  String get reminderBanner => 'Il tuo piano quotidiano è pronto.';

  @override
  String get dismiss => 'Chiudi';

  @override
  String get edit => 'Modifica';

  @override
  String get listenPlans => 'Piani di ascolto';

  @override
  String get readingPlans => 'Piani di Lettura';

  @override
  String activePlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piani attivi',
      one: '$count piano attivo',
    );
    return '$_temp0';
  }

  @override
  String get myPlansEmpty => 'Nessun piano di lettura attivo al momento.';

  @override
  String get startPlanToSeeProgress => 'Inizia un piano per vedere i tuoi progressi qui.';

  @override
  String planDuration(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '$days giorno',
    );
    return '$_temp0';
  }

  @override
  String planBook(String book) {
    return 'Libro: $book';
  }

  @override
  String planReadings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count letture',
      one: '$count lettura',
    );
    return '$_temp0';
  }

  @override
  String get planSchedule => 'Calendario';

  @override
  String planProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String get inProgress => 'In Corso';

  @override
  String get completePlan => 'Completa Piano';

  @override
  String completePlanConfirmation(Object title) {
    return 'Segnare tutte le letture di \'$title\' come completate?';
  }

  @override
  String get planNotFound => 'Piano non trovato.';

  @override
  String get noReadingsAvailable => 'Nessuna lettura disponibile per questo piano.';

  @override
  String get readingPlansUnavailable => 'I piani di lettura non sono al momento disponibili.';

  @override
  String listenDurationAndDays(int minutes, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minuti • $days giorni',
      one: '$minutes minuto • $days giorno',
    );
    return '$_temp0';
  }

  @override
  String get listenMyPlansEmpty => 'Inizia un piano di ascolto per vedere qui i tuoi progressi.';

  @override
  String listenProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String listenDay(int day) {
    return 'Giorno $day';
  }

  @override
  String listenDayTitle(int day, String title) {
    return 'Giorno $day: $title';
  }

  @override
  String get listenAudioPlaceholder => 'La riproduzione audio sarà implementata in un futuro aggiornamento.';

  @override
  String get lentTitle => 'Quaresima';

  @override
  String get lentLoading => 'Caricamento cammino quaresimale...';

  @override
  String lentProgress(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      completed,
      locale: localeName,
      other: '$completed di $total giorni completati',
      one: '$completed di $total giorno completato',
    );
    return '$_temp0';
  }

  @override
  String lentDayNumber(int day) {
    return 'Giorno $day';
  }

  @override
  String get lentDailyVerse => 'Versetto del giorno';

  @override
  String get lentDailyPrayer => 'Preghiera del giorno';

  @override
  String get lentAudioPlaceholder => 'La riproduzione audio sarà implementata in un futuro aggiornamento.';

  @override
  String get loadingTranslations => 'Caricamento traduzioni…';

  @override
  String get selectTranslation => 'Seleziona traduzione';

  @override
  String get close => 'Chiudi';

  @override
  String get complete => 'Completa';

  @override
  String get onboardingWelcomeTitle => 'Benvenuto in Bible Path';

  @override
  String get onboardingWelcomeDescription => 'Personalizziamo la tua esperienza. Ti faremo qualche domanda rapida per configurare la migliore versione della Bibbia e i contenuti per te.';

  @override
  String get onboardingLanguage => 'Lingua';

  @override
  String get onboardingTranslationStyle => 'Stile di traduzione';

  @override
  String get onboardingDenomination => 'Denominazione';

  @override
  String get onboardingStyleFormal => 'Formale (stile CEI)';

  @override
  String get onboardingStyleContemporary => 'Contemporaneo (stile TILC)';

  @override
  String get onboardingStyleSimple => 'Semplice (stile Nuovissima)';

  @override
  String get onboardingStyleLiterary => 'Letterario (stile Luzzi)';

  @override
  String get onboardingDenominationCatholic => 'Cattolica';

  @override
  String get onboardingDenominationOrthodox => 'Ortodossa';

  @override
  String get onboardingDenominationProtestant => 'Protestante';

  @override
  String get onboardingDenominationNonDenominational => 'Non confessionale';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingComplete => 'Completa';

  @override
  String get adventTitle => 'Avvento';

  @override
  String get adventDay => 'Giorno';

  @override
  String get adventScripture => 'Scrittura';

  @override
  String get adventReflection => 'Riflessione';

  @override
  String get adventPrayer => 'Preghiera';

  @override
  String get adventWeekHope => 'Speranza';

  @override
  String get adventWeekPeace => 'Pace';

  @override
  String get adventWeekJoy => 'Gioia';

  @override
  String get adventWeekLove => 'Amore';

  @override
  String adventComingSoon(int days) {
    return 'L\'Avvento inizia tra $days giorni';
  }

  @override
  String get adventNotInSeason => 'La stagione d\'Avvento inizia il 1° dicembre';

  @override
  String get adventCountdownTitle => 'In attesa dell\'Avvento';

  @override
  String adventCountdownSubtitle(int days) {
    return 'L\'Avvento inizia tra $days giorni. Prepara il tuo cuore per la venuta di Cristo.';
  }

  @override
  String get adventErrorTitle => 'Impossibile caricare il calendario d\'Avvento';

  @override
  String get adventRetry => 'Riprova';

  @override
  String get adventRefresh => 'Aggiorna';

  @override
  String get adventNoData => 'Dati del calendario d\'Avvento non disponibili';

  @override
  String get adventDayLocked => 'Questo giorno è bloccato';

  @override
  String adventDayLockedSubtitle(int day) {
    return 'Il giorno $day si sbloccherà il $day dicembre';
  }

  @override
  String get adventSeasonActive => 'La stagione d\'Avvento è attiva';

  @override
  String get holyCalendarTitle => 'Calendario Sacro';

  @override
  String get holyCalendarNoEvents => 'Nessuna celebrazione disponibile per questo mese.';

  @override
  String get holyCalendarLoadError => 'Impossibile caricare il calendario. Riprova.';

  @override
  String get holyCalendarRetry => 'Riprova';

  @override
  String get holyCalendarReadings => 'Letture';

  @override
  String get holyCalendarFasting => 'Digiuno';

  @override
  String get holyCalendarSaints => 'Santi';

  @override
  String get holyCalendarObligation => 'Festa di precetto';

  @override
  String get readAloud => 'Leggi ad alta voce';

  @override
  String get speechNotice => 'Voce del browser, non una registrazione. Potrebbe richiedere internet. Cambiare velocità riavvia la lettura; il background non è garantito.';

  @override
  String get speechUnavailable => 'Lettura vocale non disponibile o brano senza testo.';

  @override
  String get speechError => 'Errore vocale. Riprova o controlla le voci del dispositivo.';

  @override
  String get speechPlay => 'Riproduci';

  @override
  String get speechPause => 'Pausa';

  @override
  String get speechStop => 'Ferma';

  @override
  String get speechRate => 'Velocità di lettura';

  @override
  String get speechVoice => 'Voce';

  @override
  String get speechDefaultVoice => 'Automatica (lingua del testo)';

  @override
  String get speechNoVoices => 'Le voci del dispositivo si stanno caricando.';

  @override
  String get speechContinueChapters => 'Continua al capitolo successivo';
}
