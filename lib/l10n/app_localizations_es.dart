// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Bible Path';

  @override
  String get startupFailureTitle => 'Bible Path no pudo iniciarse.';

  @override
  String startupFailureDetails(String error) {
    return 'Detalles: $error';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navBible => 'Biblia';

  @override
  String get navAi => 'IA';

  @override
  String get navDaily => 'Diario';

  @override
  String get navPrayer => 'Oración';

  @override
  String get navStudy => 'Estudio';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navMore => 'Más';

  @override
  String get homeTagline =>
      'Un espacio tranquilo para las Escrituras, la oración y la práctica diaria.';

  @override
  String get dailyVerse => 'Versículo diario';

  @override
  String get openBiblePrompt => 'Abre la Biblia para comenzar a leer.';

  @override
  String get openBible => 'Abrir la Biblia';

  @override
  String get todaysPlan => 'Plan de hoy';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de $count días',
      one: 'Racha de $count día',
    );
    return '$_temp0';
  }

  @override
  String get noPlanAvailable => 'No hay ningún plan disponible.';

  @override
  String planStepsComplete(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$completed de $total pasos completados',
      one: '$completed de $total paso completado',
    );
    return '$_temp0';
  }

  @override
  String get continueAction => 'Continuar';

  @override
  String get continueJourney => 'Continúa tu camino';

  @override
  String get bibleAi => 'IA bíblica';

  @override
  String questionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas',
      one: '$count pregunta',
    );
    return '$_temp0';
  }

  @override
  String get studyTitle => 'Estudio';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planes activos',
      one: '$count plan activo',
    );
    return '$_temp0';
  }

  @override
  String get prayerJournal => 'Diario de oración';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '$count entrada',
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
  String get translationUnavailable => 'Esta traducción no está disponible.';

  @override
  String get searchBooksOrVerses => 'Buscar libros o versículos…';

  @override
  String get books => 'Libros';

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
  String get nextChapter => 'Capítulo siguiente';

  @override
  String get chapterNotAvailable => 'El capítulo no está disponible.';

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
  String get verseActions => 'Acciones del versículo';

  @override
  String get removeFavorite => 'Quitar de favoritos';

  @override
  String get addFavorite => 'Añadir a favoritos';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartir';

  @override
  String get verseCopied => 'Versículo copiado al portapapeles.';

  @override
  String get noResults => 'No hay resultados.';

  @override
  String verseReference(String book, int chapter, String verse) {
    return '$book $chapter:$verse';
  }

  @override
  String get bibleContentUnavailable =>
      'No se pudo cargar el contenido de la Biblia.';

  @override
  String get retry => 'Reintentar';

  @override
  String get chatHistory => 'Historial de chats';

  @override
  String get chatSecureStatus =>
      'Las preguntas se envían de forma segura a través de tu Worker.';

  @override
  String get aiEndpointNotConfigured =>
      'El punto de conexión de IA no está configurado para esta compilación.';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String newChatNumber(int number) {
    return 'Nuevo chat $number';
  }

  @override
  String get askBibleHint => 'Pregunta sobre la Biblia o la fe…';

  @override
  String get send => 'Enviar';

  @override
  String get noMessages => 'No hay mensajes';

  @override
  String get deleteChat => 'Eliminar chat';

  @override
  String get suggestionPrayerFocus => '¿Cómo puedo orar con más concentración?';

  @override
  String get suggestionJohnContext => 'Explica Juan 3:16 en su contexto.';

  @override
  String get suggestionAnxiety => '¿Qué pasajes hablan sobre la ansiedad?';

  @override
  String get suggestionDevotional => 'Dame un breve devocional para hoy.';

  @override
  String get chatPrivacyIntro =>
      'Haz una pregunta. Los turnos recientes del chat y el contexto bíblico seleccionado se envían a Cloudflare Workers AI.';

  @override
  String responseTruncated(String response) {
    return '$response\n\n[Respuesta truncada]';
  }

  @override
  String get aiNotConfigured =>
      'La IA no está configurada para esta compilación.';

  @override
  String get aiMissingToken =>
      'Introduce tu token personal de acceso a la IA en Ajustes.';

  @override
  String get aiUnavailableLater =>
      'La IA bíblica no está disponible. Vuelve a intentarlo más tarde.';

  @override
  String get aiInvalidResponse =>
      'La IA bíblica devolvió una respuesta no válida.';

  @override
  String get aiUnavailableConnection =>
      'La IA bíblica no está disponible. Comprueba tu conexión y vuelve a intentarlo.';

  @override
  String get dailyPlan => 'Plan diario';

  @override
  String bestStreak(int count) {
    return 'Mejor: $count';
  }

  @override
  String get today => 'Hoy';

  @override
  String get history => 'Historial';

  @override
  String get completeTodaysPlan => 'Completa el plan de hoy';

  @override
  String get dailyHistoryEmpty =>
      'Completa tu primer plan diario para comenzar un historial.';

  @override
  String get todaysVerse => 'Versículo de hoy';

  @override
  String get dailyDevotional => 'Devocional diario';

  @override
  String get reading => 'Lectura';

  @override
  String get listening => 'Escucha';

  @override
  String get reflection => 'Reflexión';

  @override
  String get dailyPrayer => 'Oración diaria';

  @override
  String get themeTrustGuidance => 'Confianza y guía';

  @override
  String get themePeaceRest => 'Paz y descanso';

  @override
  String get themeStrengthCourage => 'Fortaleza y valor';

  @override
  String get themeHopeFuture => 'Esperanza y futuro';

  @override
  String get themeLoveGrace => 'Amor y gracia';

  @override
  String get themeFaithTrust => 'Fe y confianza';

  @override
  String get themeWisdomUnderstanding => 'Sabiduría y entendimiento';

  @override
  String get prayerPrivateDescription =>
      'Entradas privadas almacenadas en este dispositivo.';

  @override
  String get newPrayer => 'Nueva oración';

  @override
  String get active => 'Activas';

  @override
  String get archived => 'Archivadas';

  @override
  String get categoryPersonal => 'Personal';

  @override
  String get categoryGratitude => 'Gratitud';

  @override
  String get categoryGuidance => 'Guía';

  @override
  String get categoryHealing => 'Sanación';

  @override
  String get categoryFamily => 'Familia';

  @override
  String get restore => 'Restaurar';

  @override
  String get archive => 'Archivar';

  @override
  String get delete => 'Eliminar';

  @override
  String get prayerComposerHint => 'Escribe tu oración o reflexión…';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get deleteEntryTitle => '¿Eliminar entrada?';

  @override
  String get cannotUndo => 'Esta acción no se puede deshacer.';

  @override
  String get noArchivedPrayers => 'No hay oraciones archivadas.';

  @override
  String get emptyPrayerJournal =>
      'Tu diario de oración está vacío. Añade tu primera entrada.';

  @override
  String get studyPlans => 'Planes de estudio';

  @override
  String get available => 'Disponibles';

  @override
  String get myPlans => 'Mis planes';

  @override
  String studyDurationAndTopics(int days, String topics) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días • $topics',
      one: '$days día • $topics',
    );
    return '$_temp0';
  }

  @override
  String get started => 'Iniciado';

  @override
  String get startPlan => 'Iniciar plan';

  @override
  String get studyMyPlansEmpty => 'Inicia un plan para ver aquí tu progreso.';

  @override
  String studyProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String studyDay(int day) {
    return 'Día $day';
  }

  @override
  String get removePlan => 'Eliminar plan';

  @override
  String studyLessonTitle(int day, String title) {
    return 'Día $day: $title';
  }

  @override
  String get completed => 'Completado';

  @override
  String get markComplete => 'Marcar como completado';

  @override
  String profileCurrentStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha actual',
      one: 'Racha actual',
    );
    return '$_temp0';
  }

  @override
  String profileLongestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha más larga',
      one: 'Racha más larga',
    );
    return '$_temp0';
  }

  @override
  String profileDailyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Planes diarios',
      one: 'Plan diario',
    );
    return '$_temp0';
  }

  @override
  String profileStudyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Planes de estudio',
      one: 'Plan de estudio',
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
      other: 'Entradas de oración',
      one: 'Entrada de oración',
    );
    return '$_temp0';
  }

  @override
  String profileAiMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mensajes de IA',
      one: 'Mensaje de IA',
    );
    return '$_temp0';
  }

  @override
  String get yourJourney => 'Tu camino';

  @override
  String get dataStoredOnly =>
      'Los datos se almacenan únicamente en este dispositivo.';

  @override
  String get privacy => 'Privacidad';

  @override
  String get profilePrivacyDescription =>
      'Los favoritos, el progreso, las oraciones y el historial de chats permanecen en este navegador. Las preguntas a la IA y el contexto bíblico seleccionado solo salen del dispositivo cuando envías una solicitud a la IA bíblica.';

  @override
  String get settings => 'Ajustes';

  @override
  String get appearanceAndLanguage => 'Apariencia e idioma';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get textSize => 'Tamaño del texto';

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
  String get translation => 'Traducción';

  @override
  String get inAppReminder => 'Recordatorio en la app';

  @override
  String get dailyReminder => 'Recordatorio diario';

  @override
  String get reminderVisibility =>
      'Solo se muestra cuando la app está abierta o se reanuda.';

  @override
  String get reminderTime => 'Hora del recordatorio';

  @override
  String get personalWorkerToken => 'Token personal de acceso al Worker';

  @override
  String get enterToken => 'Introduce el token';

  @override
  String get tokenAlreadySaved => 'Ya hay un token guardado';

  @override
  String get hideToken => 'Ocultar token';

  @override
  String get showToken => 'Mostrar token';

  @override
  String get removeToken => 'Eliminar token';

  @override
  String get tokenSaved => 'Token guardado.';

  @override
  String get saveToken => 'Guardar token';

  @override
  String get aiPrivacyDescription =>
      'Las preguntas a la IA, los turnos recientes del chat y los pasajes bíblicos seleccionados son procesados por Cloudflare Workers AI. No se almacena ninguna clave externa de API de IA en esta app.';

  @override
  String get localData => 'Datos locales';

  @override
  String get requestDurableStorage => 'Solicitar almacenamiento persistente';

  @override
  String get durableStorageWarning =>
      'Es posible que iOS elimine los datos del sitio web. Exporta periódicamente las entradas importantes.';

  @override
  String get exportMyData => 'Exportar mis datos';

  @override
  String get tokenExcluded => 'El token de acceso a la IA no se incluye.';

  @override
  String get resetLocalData => 'Restablecer datos locales';

  @override
  String get about => 'Acerca de';

  @override
  String aboutDescription(String version) {
    return 'PWA personal que prioriza el uso sin conexión • $version';
  }

  @override
  String get notifications => 'Notificaciones';

  @override
  String get webPushUnavailable => 'Web Push no está incluido en esta versión.';

  @override
  String get durableStorageGranted =>
      'Se concedió el almacenamiento persistente.';

  @override
  String get durableStorageNotGranted =>
      'No se concedió el almacenamiento persistente. Realiza exportaciones periódicas.';

  @override
  String get exportUnavailable =>
      'La exportación de datos no está disponible en esta plataforma.';

  @override
  String get resetAllDataTitle => '¿Restablecer todos los datos locales?';

  @override
  String get resetAllDataDescription =>
      'Los favoritos, los planes, las oraciones, los chats, los ajustes y el token de IA se eliminarán de este dispositivo.';

  @override
  String get reset => 'Restablecer';

  @override
  String get reminderBanner => 'Tu plan diario está listo.';

  @override
  String get dismiss => 'Descartar';

  @override
  String get edit => 'Editar';
}
