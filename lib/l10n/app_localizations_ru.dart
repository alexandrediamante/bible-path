// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Библейский путь';

  @override
  String get startupFailureTitle =>
      'Не удалось запустить приложение «Библейский путь».';

  @override
  String startupFailureDetails(String error) {
    return 'Подробности: $error';
  }

  @override
  String get navHome => 'Главная';

  @override
  String get navBible => 'Библия';

  @override
  String get navAi => 'ИИ';

  @override
  String get navDaily => 'На каждый день';

  @override
  String get navAdvent => 'Рождественский пост';

  @override
  String get navPrayer => 'Молитва';

  @override
  String get navStudy => 'Изучение';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navMore => 'Ещё';

  @override
  String get navListen => 'Слушать';

  @override
  String get homeTagline =>
      'Тихое место для чтения Писания, молитвы и ежедневной духовной практики.';

  @override
  String get dailyVerse => 'Стих дня';

  @override
  String get openBiblePrompt => 'Откройте Библию, чтобы начать чтение.';

  @override
  String get openBible => 'Открыть Библию';

  @override
  String get todaysPlan => 'План на сегодня';

  @override
  String dayStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня подряд',
      many: '$count дней подряд',
      few: '$count дня подряд',
      one: '$count день подряд',
    );
    return '$_temp0';
  }

  @override
  String get noPlanAvailable => 'Нет доступных планов.';

  @override
  String planStepsComplete(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Выполнено: $completed из $total шага',
      many: 'Выполнено: $completed из $total шагов',
      few: 'Выполнено: $completed из $total шагов',
      one: 'Выполнено: $completed из $total шага',
    );
    return '$_temp0';
  }

  @override
  String get continueAction => 'Продолжить';

  @override
  String get continueJourney => 'Продолжить свой путь';

  @override
  String get bibleAi => 'Библейский ИИ';

  @override
  String questionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вопроса',
      many: '$count вопросов',
      few: '$count вопроса',
      one: '$count вопрос',
    );
    return '$_temp0';
  }

  @override
  String get studyTitle => 'Изучение';

  @override
  String activePlanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активного плана',
      many: '$count активных планов',
      few: '$count активных плана',
      one: '$count активный план',
    );
    return '$_temp0';
  }

  @override
  String get prayerJournal => 'Молитвенный дневник';

  @override
  String entryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
  }

  @override
  String get favorites => 'Избранное';

  @override
  String verseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count стиха',
      many: '$count стихов',
      few: '$count стиха',
      one: '$count стих',
    );
    return '$_temp0';
  }

  @override
  String get translationUnavailable => 'Этот перевод недоступен.';

  @override
  String get searchBooksOrVerses => 'Поиск книг или стихов…';

  @override
  String get books => 'Книги';

  @override
  String chapterTitle(String book, int chapter) {
    return '$book $chapter';
  }

  @override
  String get previousChapter => 'Предыдущая глава';

  @override
  String chapterProgress(int chapter, int chapterCount) {
    return '$chapter/$chapterCount';
  }

  @override
  String get nextChapter => 'Следующая глава';

  @override
  String get chapterNotAvailable => 'Глава недоступна.';

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
  String get verseActions => 'Действия со стихом';

  @override
  String get removeFavorite => 'Удалить из избранного';

  @override
  String get addFavorite => 'Добавить в избранное';

  @override
  String get copy => 'Копировать';

  @override
  String get share => 'Поделиться';

  @override
  String get verseCopied => 'Стих скопирован в буфер обмена.';

  @override
  String get noResults => 'Ничего не найдено.';

  @override
  String verseReference(String book, int chapter, String verse) {
    return '$book $chapter:$verse';
  }

  @override
  String get bibleContentUnavailable => 'Не удалось загрузить текст Библии.';

  @override
  String get retry => 'Повторить';

  @override
  String get chatHistory => 'История чатов';

  @override
  String get chatSecureStatus =>
      'Вопросы безопасно отправляются через ваш Worker.';

  @override
  String get aiEndpointNotConfigured =>
      'Адрес сервиса ИИ не настроен для этой сборки.';

  @override
  String get newChat => 'Новый чат';

  @override
  String newChatNumber(int number) {
    return 'Новый чат $number';
  }

  @override
  String get askBibleHint => 'Задайте вопрос о Библии или вере…';

  @override
  String get send => 'Отправить';

  @override
  String get noMessages => 'Нет сообщений';

  @override
  String get deleteChat => 'Удалить чат';

  @override
  String get suggestionPrayerFocus => 'Как молиться более сосредоточенно?';

  @override
  String get suggestionJohnContext => 'Объясни стих Иоанна 3:16 в контексте.';

  @override
  String get suggestionAnxiety => 'В каких отрывках говорится о тревоге?';

  @override
  String get suggestionDevotional =>
      'Предложи короткое духовное размышление на сегодня.';

  @override
  String get chatPrivacyIntro =>
      'Задайте вопрос. Недавние сообщения чата и контекст выбранных отрывков Писания отправляются в Cloudflare Workers AI.';

  @override
  String responseTruncated(String response) {
    return '$response\n\n[Ответ сокращён]';
  }

  @override
  String get aiNotConfigured => 'ИИ не настроен для этой сборки.';

  @override
  String get aiMissingToken =>
      'Введите личный токен доступа к ИИ в настройках.';

  @override
  String get aiUnavailableLater =>
      'Библейский ИИ недоступен. Повторите попытку позже.';

  @override
  String get aiInvalidResponse => 'Библейский ИИ вернул недопустимый ответ.';

  @override
  String get aiUnavailableConnection =>
      'Библейский ИИ недоступен. Проверьте подключение и повторите попытку.';

  @override
  String get dailyPlan => 'Ежедневный план';

  @override
  String bestStreak(int count) {
    return 'Рекорд: $count';
  }

  @override
  String get today => 'Сегодня';

  @override
  String get history => 'История';

  @override
  String get completeTodaysPlan => 'Выполнить план на сегодня';

  @override
  String get dailyHistoryEmpty =>
      'Выполните первый ежедневный план, чтобы появилась история.';

  @override
  String get todaysVerse => 'Стих на сегодня';

  @override
  String get dailyDevotional => 'Ежедневное духовное размышление';

  @override
  String get reading => 'Чтение';

  @override
  String get listening => 'Прослушивание';

  @override
  String get reflection => 'Размышление';

  @override
  String get dailyPrayer => 'Ежедневная молитва';

  @override
  String get themeTrustGuidance => 'Доверие и наставление';

  @override
  String get themePeaceRest => 'Мир и покой';

  @override
  String get themeStrengthCourage => 'Сила и мужество';

  @override
  String get themeHopeFuture => 'Надежда и будущее';

  @override
  String get themeLoveGrace => 'Любовь и благодать';

  @override
  String get themeFaithTrust => 'Вера и доверие';

  @override
  String get themeWisdomUnderstanding => 'Мудрость и понимание';

  @override
  String get prayerPrivateDescription =>
      'Личные записи хранятся на этом устройстве.';

  @override
  String get newPrayer => 'Новая молитва';

  @override
  String get active => 'Активные';

  @override
  String get archived => 'В архиве';

  @override
  String get categoryPersonal => 'Личное';

  @override
  String get categoryGratitude => 'Благодарность';

  @override
  String get categoryGuidance => 'Наставление';

  @override
  String get categoryHealing => 'Исцеление';

  @override
  String get categoryFamily => 'Семья';

  @override
  String get restore => 'Восстановить';

  @override
  String get archive => 'В архив';

  @override
  String get delete => 'Удалить';

  @override
  String get prayerComposerHint => 'Запишите свою молитву или размышление…';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get deleteEntryTitle => 'Удалить запись?';

  @override
  String get cannotUndo => 'Это действие нельзя отменить.';

  @override
  String get noArchivedPrayers => 'В архиве нет молитв.';

  @override
  String get emptyPrayerJournal =>
      'Ваш молитвенный дневник пуст. Добавьте первую запись.';

  @override
  String get studyPlans => 'Планы изучения';

  @override
  String get available => 'Доступные';

  @override
  String get myPlans => 'Мои планы';

  @override
  String studyDurationAndTopics(int days, String topics) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня • $topics',
      many: '$days дней • $topics',
      few: '$days дня • $topics',
      one: '$days день • $topics',
    );
    return '$_temp0';
  }

  @override
  String get started => 'Начат';

  @override
  String get startPlan => 'Начать план';

  @override
  String get studyMyPlansEmpty =>
      'Начните план, чтобы следить здесь за своим прогрессом.';

  @override
  String studyProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String studyDay(int day) {
    return 'День $day';
  }

  @override
  String get removePlan => 'Удалить план';

  @override
  String studyLessonTitle(int day, String title) {
    return 'День $day: $title';
  }

  @override
  String get completed => 'Завершён';

  @override
  String get markComplete => 'Отметить как выполненное';

  @override
  String profileCurrentStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Текущая серия',
      many: 'Текущая серия',
      few: 'Текущая серия',
      one: 'Текущая серия',
    );
    return '$_temp0';
  }

  @override
  String profileLongestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Самая длинная серия',
      many: 'Самая длинная серия',
      few: 'Самая длинная серия',
      one: 'Самая длинная серия',
    );
    return '$_temp0';
  }

  @override
  String profileDailyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ежедневного плана',
      many: 'Ежедневных планов',
      few: 'Ежедневных плана',
      one: 'Ежедневный план',
    );
    return '$_temp0';
  }

  @override
  String profileStudyPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Плана изучения',
      many: 'Планов изучения',
      few: 'Плана изучения',
      one: 'План изучения',
    );
    return '$_temp0';
  }

  @override
  String profileFavoriteVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Избранного стиха',
      many: 'Избранных стихов',
      few: 'Избранных стиха',
      one: 'Избранный стих',
    );
    return '$_temp0';
  }

  @override
  String profilePrayerEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Молитвенной записи',
      many: 'Молитвенных записей',
      few: 'Молитвенные записи',
      one: 'Молитвенная запись',
    );
    return '$_temp0';
  }

  @override
  String profileAiMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сообщения ИИ',
      many: 'Сообщений ИИ',
      few: 'Сообщения ИИ',
      one: 'Сообщение ИИ',
    );
    return '$_temp0';
  }

  @override
  String get yourJourney => 'Ваш путь';

  @override
  String get dataStoredOnly => 'Данные хранятся только на этом устройстве.';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get profilePrivacyDescription =>
      'Избранное, прогресс, молитвы и история чатов остаются в этом браузере. Вопросы к ИИ и контекст выбранных отрывков Писания покидают устройство только при отправке запроса Библейскому ИИ.';

  @override
  String get settings => 'Настройки';

  @override
  String get appearanceAndLanguage => 'Оформление и язык';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get textSize => 'Размер текста';

  @override
  String get language => 'Язык';

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
  String get translation => 'Перевод';

  @override
  String get inAppReminder => 'Напоминание в приложении';

  @override
  String get dailyReminder => 'Ежедневное напоминание';

  @override
  String get reminderVisibility =>
      'Показывается только при открытии приложения или возвращении к нему.';

  @override
  String get reminderTime => 'Время напоминания';

  @override
  String get personalWorkerToken => 'Личный токен доступа к Worker';

  @override
  String get enterToken => 'Введите токен';

  @override
  String get tokenAlreadySaved => 'Токен уже сохранён';

  @override
  String get hideToken => 'Скрыть токен';

  @override
  String get showToken => 'Показать токен';

  @override
  String get removeToken => 'Удалить токен';

  @override
  String get tokenSaved => 'Токен сохранён.';

  @override
  String get saveToken => 'Сохранить токен';

  @override
  String get aiPrivacyDescription =>
      'Вопросы к ИИ, недавние сообщения чата и выбранные отрывки Библии обрабатываются Cloudflare Workers AI. В приложении не хранится внешний ключ API ИИ.';

  @override
  String get localData => 'Локальные данные';

  @override
  String get requestDurableStorage => 'Запросить постоянное хранилище';

  @override
  String get durableStorageWarning =>
      'iOS всё равно может удалить данные сайта. Регулярно экспортируйте важные записи.';

  @override
  String get exportMyData => 'Экспортировать мои данные';

  @override
  String get tokenExcluded => 'Токен доступа к ИИ не включается.';

  @override
  String get resetLocalData => 'Сбросить локальные данные';

  @override
  String get about => 'О приложении';

  @override
  String aboutDescription(String version) {
    return 'Персональное PWA-приложение для работы прежде всего офлайн • $version';
  }

  @override
  String get notifications => 'Уведомления';

  @override
  String get webPushUnavailable =>
      'Веб-push-уведомления не включены в эту версию.';

  @override
  String get durableStorageGranted => 'Постоянное хранилище предоставлено.';

  @override
  String get durableStorageNotGranted =>
      'Постоянное хранилище не предоставлено. Регулярно экспортируйте данные.';

  @override
  String get exportUnavailable =>
      'Экспорт данных недоступен на этой платформе.';

  @override
  String get resetAllDataTitle => 'Сбросить все локальные данные?';

  @override
  String get resetAllDataDescription =>
      'Избранное, планы, молитвы, чаты, настройки и токен ИИ будут удалены с этого устройства.';

  @override
  String get reset => 'Сбросить';

  @override
  String get reminderBanner => 'Ваш план на сегодня готов.';

  @override
  String get dismiss => 'Закрыть';

  @override
  String get edit => 'Изменить';

  @override
  String get listenPlans => 'Планы прослушивания';

  @override
  String get readingPlans => 'Планы чтения';

  @override
  String activePlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активного плана',
      many: '$count активных планов',
      few: '$count активных плана',
      one: '$count активный план',
    );
    return '$_temp0';
  }

  @override
  String get myPlansEmpty => 'Пока нет активных планов чтения.';

  @override
  String get startPlanToSeeProgress =>
      'Начните план, чтобы видеть здесь свой прогресс.';

  @override
  String planDuration(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня',
      many: '$days дней',
      few: '$days дня',
      one: '$days день',
    );
    return '$_temp0';
  }

  @override
  String planBook(String book) {
    return 'Книга: $book';
  }

  @override
  String planReadings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count чтения',
      many: '$count чтений',
      few: '$count чтения',
      one: '$count чтение',
    );
    return '$_temp0';
  }

  @override
  String get planSchedule => 'Расписание';

  @override
  String planProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String get inProgress => 'В процессе';

  @override
  String get completePlan => 'Завершить план';

  @override
  String completePlanConfirmation(Object title) {
    return 'Отметить все чтения в \'$title\' как выполненные?';
  }

  @override
  String get planNotFound => 'План не найден.';

  @override
  String get noReadingsAvailable => 'Нет доступных чтений для этого плана.';

  @override
  String get readingPlansUnavailable => 'Планы чтения сейчас недоступны.';

  @override
  String listenDurationAndDays(int minutes, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes минуты • $days дня',
      many: '$minutes минут • $days дней',
      few: '$minutes минуты • $days дня',
      one: '$minutes минута • $days день',
    );
    return '$_temp0';
  }

  @override
  String get listenMyPlansEmpty =>
      'Начните план прослушивания, чтобы отслеживать прогресс здесь.';

  @override
  String listenProgress(int completed, int total) {
    return '$completed/$total';
  }

  @override
  String listenDay(int day) {
    return 'День $day';
  }

  @override
  String listenDayTitle(int day, String title) {
    return 'День $day: $title';
  }

  @override
  String get listenAudioPlaceholder =>
      'Воспроизведение аудио будет реализовано в будущем обновлении.';

  @override
  String get lentTitle => 'Великий пост';

  @override
  String get lentLoading => 'Загрузка пути Великого Поста...';

  @override
  String lentProgress(int completed, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      completed,
      locale: localeName,
      other: '$completed из $total дня пройдено',
      many: '$completed из $total дней пройдено',
      few: '$completed из $total дня пройдено',
      one: '$completed из $total день пройден',
    );
    return '$_temp0';
  }

  @override
  String lentDayNumber(int day) {
    return 'День $day';
  }

  @override
  String get lentDailyVerse => 'Стих дня';

  @override
  String get lentDailyPrayer => 'Молитва дня';

  @override
  String get lentAudioPlaceholder =>
      'Воспроизведение аудио будет реализовано в будущем обновлении.';

  @override
  String get loadingTranslations => 'Загрузка переводов…';

  @override
  String get selectTranslation => 'Выбрать перевод';

  @override
  String get close => 'Закрыть';

  @override
  String get complete => 'Завершить';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в Bible Path';

  @override
  String get onboardingWelcomeDescription =>
      'Давайте настроим приложение под вас. Мы зададим несколько быстрых вопросов, чтобы подобрать лучший перевод Библии и контент для вас.';

  @override
  String get onboardingLanguage => 'Язык';

  @override
  String get onboardingTranslationStyle => 'Стиль перевода';

  @override
  String get onboardingDenomination => 'Конфессия';

  @override
  String get onboardingStyleFormal => 'Формальный (синодальный стиль)';

  @override
  String get onboardingStyleContemporary => 'Современный (современный перевод)';

  @override
  String get onboardingStyleSimple => 'Простой (перевод для изучающих)';

  @override
  String get onboardingStyleLiterary => 'Литературный (художественный стиль)';

  @override
  String get onboardingDenominationCatholic => 'Католическая';

  @override
  String get onboardingDenominationOrthodox => 'Православная';

  @override
  String get onboardingDenominationProtestant => 'Протестантская';

  @override
  String get onboardingDenominationNonDenominational => 'Неконфессиональная';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingComplete => 'Завершить';

  @override
  String get adventTitle => 'Рождественский пост';

  @override
  String get adventDay => 'День';

  @override
  String get adventScripture => 'Писание';

  @override
  String get adventReflection => 'Размышление';

  @override
  String get adventPrayer => 'Молитва';

  @override
  String get adventWeekHope => 'Надежда';

  @override
  String get adventWeekPeace => 'Мир';

  @override
  String get adventWeekJoy => 'Радость';

  @override
  String get adventWeekLove => 'Любовь';

  @override
  String adventComingSoon(int days) {
    return 'Рождественский пост начнется через $days дней';
  }

  @override
  String get adventNotInSeason => 'Рождественский пост начинается 1 декабря';

  @override
  String get adventCountdownTitle => 'Ожидание Рождественского поста';

  @override
  String adventCountdownSubtitle(int days) {
    return 'Рождественский пост начнется через $days дней. Приготовьте сердце к пришествию Христа.';
  }

  @override
  String get adventErrorTitle =>
      'Не удалось загрузить календарь Рождественского поста';

  @override
  String get adventRetry => 'Попробовать снова';

  @override
  String get adventRefresh => 'Обновить';

  @override
  String get adventNoData =>
      'Данные календаря Рождественского поста недоступны';

  @override
  String get adventDayLocked => 'Этот день заблокирован';

  @override
  String adventDayLockedSubtitle(int day) {
    return 'День $day откроется $day декабря';
  }

  @override
  String get adventSeasonActive => 'Рождественский пост активен';

  @override
  String get holyCalendarTitle => 'Священный календарь';

  @override
  String get holyCalendarNoEvents =>
      'На этот месяц нет доступных празднований.';

  @override
  String get holyCalendarLoadError =>
      'Не удалось загрузить календарь. Повторите позже.';

  @override
  String get holyCalendarRetry => 'Повторить';

  @override
  String get holyCalendarReadings => 'Чтения';

  @override
  String get holyCalendarFasting => 'Пост';

  @override
  String get holyCalendarSaints => 'Святые';

  @override
  String get holyCalendarObligation => 'Обязательный святой день';

  @override
  String get readAloud => 'Читать вслух';

  @override
  String get speechNotice =>
      'Выберите голос устройства. Автоматический выбор учитывает язык чтения. Онлайн-голосам и некоторым голосам устройства нужен интернет. Фоновое воспроизведение не гарантируется.';

  @override
  String get speechUnavailable =>
      'Чтение вслух недоступно или текст отсутствует.';

  @override
  String get speechError =>
      'Ошибка голоса. Повторите попытку или проверьте голоса устройства.';

  @override
  String get speechPlay => 'Воспроизвести';

  @override
  String get speechPause => 'Пауза';

  @override
  String get speechStop => 'Стоп';

  @override
  String get speechRate => 'Скорость чтения';

  @override
  String get speechVoice => 'Голос';

  @override
  String get speechDefaultVoice => 'Автоматически (язык текста)';

  @override
  String get speechNoVoices =>
      'Совместимый голос не загружен. Установите голос для этого языка в настройках устройства и снова откройте браузер.';

  @override
  String get speechContinueChapters => 'Продолжить следующую главу';
}
