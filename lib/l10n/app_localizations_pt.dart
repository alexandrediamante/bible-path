// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Bible Path';

  @override
  String get startupFailureTitle => 'Não foi possível iniciar o Bible Path.';

  @override
  String startupFailureDetails(String error) {
    return 'Detalhes: $error';
  }

  @override
  String get navHome => 'Início';

  @override
  String get navBible => 'Bíblia';

  @override
  String get navAi => 'IA';

  @override
  String get navDaily => 'Diário';

  @override
  String get navPrayer => 'Oração';

  @override
  String get navStudy => 'Estudo';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navMore => 'Mais';

  @override
  String get homeTagline =>
      'Um espaço tranquilo para as Escrituras, a oração e a prática diária.';

  @override
  String get dailyVerse => 'Versículo do dia';

  @override
  String get openBiblePrompt => 'Abra a Bíblia para começar a ler.';

  @override
  String get openBible => 'Abrir a Bíblia';

  @override
  String get todaysPlan => 'Plano de hoje';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência de $count dias',
      one: 'Sequência de $count dia',
    );
    return '$_temp0';
  }

  @override
  String get noPlanAvailable => 'Nenhum plano disponível.';

  @override
  String planStepsComplete(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$completed de $total etapas concluídas',
      one: '$completed de $total etapa concluída',
    );
    return '$_temp0';
  }

  @override
  String get continueAction => 'Continuar';

  @override
  String get continueJourney => 'Continue sua jornada';

  @override
  String get bibleAi => 'IA bíblica';

  @override
  String questionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perguntas',
      one: '$count pergunta',
    );
    return '$_temp0';
  }

  @override
  String get studyTitle => 'Estudo';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planos ativos',
      one: '$count plano ativo',
    );
    return '$_temp0';
  }

  @override
  String get prayerJournal => 'Diário de oração';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count registros',
      one: '$count registro',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Favoritos';

  @override
  String verseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos',
      one: '$count versículo',
    );
    return '$_temp0';
  }

  @override
  String get translationUnavailable => 'Esta tradução não está disponível.';

  @override
  String get searchBooksOrVerses => 'Buscar livros ou versículos…';

  @override
  String get books => 'Livros';

  @override
  String chapterTitle(String book, int chapter) {
    return '$book $chapter';
  }

  @override
  String get previousChapter => 'Capítulo anterior';

  @override
  String chapterProgress(int chapter, int chapterCount) {
    return '$chapter/$chapterCount';
  }

  @override
  String get nextChapter => 'Próximo capítulo';

  @override
  String get chapterNotAvailable => 'Capítulo não disponível.';

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
  String get verseActions => 'Ações do versículo';

  @override
  String get removeFavorite => 'Remover dos favoritos';

  @override
  String get addFavorite => 'Adicionar aos favoritos';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartilhar';

  @override
  String get verseCopied => 'Versículo copiado para a área de transferência.';

  @override
  String get noResults => 'Nenhum resultado.';

  @override
  String verseReference(String book, int chapter, String verse) {
    return '$book $chapter:$verse';
  }

  @override
  String get bibleContentUnavailable =>
      'Não foi possível carregar o conteúdo da Bíblia.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get chatHistory => 'Histórico de conversas';

  @override
  String get chatSecureStatus =>
      'As perguntas são enviadas com segurança pelo seu Worker.';

  @override
  String get aiEndpointNotConfigured =>
      'O endpoint de IA não está configurado para esta compilação.';

  @override
  String get newChat => 'Nova conversa';

  @override
  String newChatNumber(int number) {
    return 'Nova conversa $number';
  }

  @override
  String get askBibleHint => 'Pergunte sobre a Bíblia ou a fé…';

  @override
  String get send => 'Enviar';

  @override
  String get noMessages => 'Nenhuma mensagem';

  @override
  String get deleteChat => 'Excluir conversa';

  @override
  String get suggestionPrayerFocus => 'Como posso orar com mais concentração?';

  @override
  String get suggestionJohnContext => 'Explique João 3:16 no contexto.';

  @override
  String get suggestionAnxiety => 'Quais passagens falam sobre ansiedade?';

  @override
  String get suggestionDevotional => 'Prepare um breve devocional para hoje.';

  @override
  String get chatPrivacyIntro =>
      'Faça uma pergunta. As mensagens recentes da conversa e o contexto bíblico selecionado podem ser enviados à Cloudflare e à Anthropic.';

  @override
  String responseTruncated(String response) {
    return '$response\n\n[Resposta truncada]';
  }

  @override
  String get aiNotConfigured =>
      'A IA não está configurada para esta compilação.';

  @override
  String get aiMissingToken =>
      'Insira seu token pessoal de acesso à IA em Configurações.';

  @override
  String get aiUnavailableLater =>
      'A IA bíblica não está disponível. Tente novamente mais tarde.';

  @override
  String get aiInvalidResponse =>
      'A IA bíblica retornou uma resposta inválida.';

  @override
  String get aiUnavailableConnection =>
      'A IA bíblica não está disponível. Verifique sua conexão e tente novamente.';

  @override
  String get dailyPlan => 'Plano diário';

  @override
  String bestStreak(int count) {
    return 'Melhor: $count';
  }

  @override
  String get today => 'Hoje';

  @override
  String get history => 'Histórico';

  @override
  String get completeTodaysPlan => 'Conclua o plano de hoje';

  @override
  String get dailyHistoryEmpty =>
      'Conclua seu primeiro plano diário para começar um histórico.';

  @override
  String get todaysVerse => 'Versículo de hoje';

  @override
  String get dailyDevotional => 'Devocional diário';

  @override
  String get reading => 'Leitura';

  @override
  String get listening => 'Escuta';

  @override
  String get reflection => 'Reflexão';

  @override
  String get dailyPrayer => 'Oração diária';

  @override
  String get themeTrustGuidance => 'Confiança e orientação';

  @override
  String get themePeaceRest => 'Paz e descanso';

  @override
  String get themeStrengthCourage => 'Força e coragem';

  @override
  String get themeHopeFuture => 'Esperança e futuro';

  @override
  String get themeLoveGrace => 'Amor e graça';

  @override
  String get themeFaithTrust => 'Fé e confiança';

  @override
  String get themeWisdomUnderstanding => 'Sabedoria e entendimento';

  @override
  String get prayerPrivateDescription =>
      'Registros privados armazenados neste dispositivo.';

  @override
  String get newPrayer => 'Nova oração';

  @override
  String get active => 'Ativas';

  @override
  String get archived => 'Arquivadas';

  @override
  String get categoryPersonal => 'Pessoal';

  @override
  String get categoryGratitude => 'Gratidão';

  @override
  String get categoryGuidance => 'Orientação';

  @override
  String get categoryHealing => 'Cura';

  @override
  String get categoryFamily => 'Família';

  @override
  String get restore => 'Restaurar';

  @override
  String get archive => 'Arquivar';

  @override
  String get delete => 'Excluir';

  @override
  String get prayerComposerHint => 'Escreva sua oração ou reflexão…';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get deleteEntryTitle => 'Excluir registro?';

  @override
  String get cannotUndo => 'Esta ação não pode ser desfeita.';

  @override
  String get noArchivedPrayers => 'Nenhuma oração arquivada.';

  @override
  String get emptyPrayerJournal =>
      'Seu diário de oração está vazio. Adicione seu primeiro registro.';

  @override
  String get studyPlans => 'Planos de estudo';

  @override
  String get available => 'Disponíveis';

  @override
  String get myPlans => 'Meus planos';

  @override
  String studyDurationAndTopics(int days, String topics) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias • $topics',
      one: '$days dia • $topics',
    );
    return '$_temp0';
  }

  @override
  String get started => 'Iniciado';

  @override
  String get startPlan => 'Iniciar plano';

  @override
  String get studyMyPlansEmpty =>
      'Inicie um plano para acompanhar seu progresso aqui.';

  @override
  String studyProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String studyDay(int day) {
    return 'Dia $day';
  }

  @override
  String get removePlan => 'Remover plano';

  @override
  String studyLessonTitle(int day, String title) {
    return 'Dia $day: $title';
  }

  @override
  String get completed => 'Concluído';

  @override
  String get markComplete => 'Marcar como concluído';

  @override
  String profileCurrentStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência atual',
      one: 'Sequência atual',
    );
    return '$_temp0';
  }

  @override
  String profileLongestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Maior sequência',
      one: 'Maior sequência',
    );
    return '$_temp0';
  }

  @override
  String profileDailyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Planos diários',
      one: 'Plano diário',
    );
    return '$_temp0';
  }

  @override
  String profileStudyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Planos de estudo',
      one: 'Plano de estudo',
    );
    return '$_temp0';
  }

  @override
  String profileFavoriteVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Versículos favoritos',
      one: 'Versículo favorito',
    );
    return '$_temp0';
  }

  @override
  String profilePrayerEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Registros de oração',
      one: 'Registro de oração',
    );
    return '$_temp0';
  }

  @override
  String profileAiMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mensagens de IA',
      one: 'Mensagem de IA',
    );
    return '$_temp0';
  }

  @override
  String get yourJourney => 'Sua jornada';

  @override
  String get dataStoredOnly =>
      'Os dados são armazenados somente neste dispositivo.';

  @override
  String get privacy => 'Privacidade';

  @override
  String get profilePrivacyDescription =>
      'Os favoritos, o progresso, as orações e o histórico de conversas permanecem neste navegador. As perguntas à IA e o contexto bíblico selecionado só saem do dispositivo quando você envia uma solicitação à IA bíblica.';

  @override
  String get settings => 'Configurações';

  @override
  String get appearanceAndLanguage => 'Aparência e idioma';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get language => 'Idioma';

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
  String get translation => 'Tradução';

  @override
  String get inAppReminder => 'Lembrete no app';

  @override
  String get dailyReminder => 'Lembrete diário';

  @override
  String get reminderVisibility =>
      'Exibido somente quando o app está aberto ou é retomado.';

  @override
  String get reminderTime => 'Horário do lembrete';

  @override
  String get personalWorkerToken => 'Token pessoal de acesso ao Worker';

  @override
  String get enterToken => 'Insira o token';

  @override
  String get tokenAlreadySaved => 'Já existe um token salvo';

  @override
  String get hideToken => 'Ocultar token';

  @override
  String get showToken => 'Mostrar token';

  @override
  String get removeToken => 'Remover token';

  @override
  String get tokenSaved => 'Token salvo.';

  @override
  String get saveToken => 'Salvar token';

  @override
  String get aiPrivacyDescription =>
      'As perguntas à IA, as mensagens recentes da conversa e as passagens bíblicas selecionadas são enviadas à Cloudflare e à Anthropic. A chave da Anthropic nunca é armazenada neste app.';

  @override
  String get localData => 'Dados locais';

  @override
  String get requestDurableStorage => 'Solicitar armazenamento persistente';

  @override
  String get durableStorageWarning =>
      'O iOS ainda pode remover os dados do site. Exporte regularmente os registros importantes.';

  @override
  String get exportMyData => 'Exportar meus dados';

  @override
  String get tokenExcluded => 'O token de acesso à IA não está incluído.';

  @override
  String get resetLocalData => 'Redefinir dados locais';

  @override
  String get about => 'Sobre';

  @override
  String aboutDescription(String version) {
    return 'PWA pessoal com prioridade para uso offline • $version';
  }

  @override
  String get notifications => 'Notificações';

  @override
  String get webPushUnavailable => 'O Web Push não está incluído nesta versão.';

  @override
  String get durableStorageGranted =>
      'O armazenamento persistente foi concedido.';

  @override
  String get durableStorageNotGranted =>
      'O armazenamento persistente não foi concedido. Faça exportações regularmente.';

  @override
  String get exportUnavailable =>
      'A exportação de dados não está disponível nesta plataforma.';

  @override
  String get resetAllDataTitle => 'Redefinir todos os dados locais?';

  @override
  String get resetAllDataDescription =>
      'Os favoritos, os planos, as orações, as conversas, as configurações e o token de IA serão excluídos deste dispositivo.';

  @override
  String get reset => 'Redefinir';

  @override
  String get reminderBanner => 'Seu plano diário está pronto.';

  @override
  String get dismiss => 'Dispensar';

  @override
  String get edit => 'Editar';
}
