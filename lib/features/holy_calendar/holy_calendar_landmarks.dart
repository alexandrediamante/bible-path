import 'package:bible_path/features/holy_calendar/holy_calendar_models.dart';

HolyCalendar buildHolyCalendarLandmarks({
  required int year,
  required LiturgicalTradition tradition,
  required String locale,
}) {
  final language = _labels.containsKey(locale) ? locale : 'en';
  final labels = _labels[language]!;
  final easter =
      tradition == LiturgicalTradition.orthodox
          ? _orthodoxEaster(year)
          : _westernEaster(year);
  final days = <HolyCalendarDay>[];

  void add(
    DateTime date,
    String name,
    String season,
    CelebrationRank rank,
    LiturgicalColor color,
  ) {
    days.add(
      HolyCalendarDay(
        date: _date(date),
        season: labels[season]!,
        week: labels[season]!,
        dayName: labels[name]!,
        rank: rank,
        color: color,
        readings: const [],
      ),
    );
  }

  if (tradition == LiturgicalTradition.orthodox) {
    add(
      DateTime(year, 12, 25),
      'nativity',
      'christmasSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.white,
    );
    add(
      DateTime(year, 1, 6),
      'theophany',
      'epiphanySeason',
      CelebrationRank.feast,
      LiturgicalColor.white,
    );
    add(
      easter.subtract(const Duration(days: 48)),
      'cleanMonday',
      'lentSeason',
      CelebrationRank.ferial,
      LiturgicalColor.violet,
    );
    add(
      easter.subtract(const Duration(days: 7)),
      'palmSunday',
      'holyWeek',
      CelebrationRank.feast,
      LiturgicalColor.red,
    );
    add(
      easter.subtract(const Duration(days: 2)),
      'goodFriday',
      'holyWeek',
      CelebrationRank.solemnity,
      LiturgicalColor.black,
    );
    add(
      easter,
      'pascha',
      'easterSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.white,
    );
    add(
      easter.add(const Duration(days: 39)),
      'ascension',
      'easterSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.white,
    );
    add(
      easter.add(const Duration(days: 49)),
      'pentecost',
      'easterSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.red,
    );
    add(
      DateTime(year, 8, 6),
      'transfiguration',
      'ordinarySeason',
      CelebrationRank.feast,
      LiturgicalColor.white,
    );
    add(
      DateTime(year, 8, 15),
      'dormition',
      'ordinarySeason',
      CelebrationRank.feast,
      LiturgicalColor.blue,
    );
    add(
      DateTime(year, 11, 15),
      'nativityFast',
      'adventSeason',
      CelebrationRank.ferial,
      LiturgicalColor.violet,
    );
  } else {
    add(
      DateTime(year, 1, 6),
      'epiphany',
      'epiphanySeason',
      CelebrationRank.feast,
      LiturgicalColor.white,
    );
    add(
      easter.subtract(const Duration(days: 46)),
      'ashWednesday',
      'lentSeason',
      CelebrationRank.ferial,
      LiturgicalColor.violet,
    );
    add(
      easter.subtract(const Duration(days: 7)),
      'palmSunday',
      'holyWeek',
      CelebrationRank.feast,
      LiturgicalColor.red,
    );
    add(
      easter.subtract(const Duration(days: 2)),
      'goodFriday',
      'holyWeek',
      CelebrationRank.solemnity,
      LiturgicalColor.black,
    );
    add(
      easter,
      'easter',
      'easterSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.white,
    );
    add(
      easter.add(const Duration(days: 39)),
      'ascension',
      'easterSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.white,
    );
    add(
      easter.add(const Duration(days: 49)),
      'pentecost',
      'easterSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.red,
    );
    add(
      DateTime(
        year,
        tradition == LiturgicalTradition.catholic ? 11 : 10,
        tradition == LiturgicalTradition.catholic ? 1 : 31,
      ),
      tradition == LiturgicalTradition.catholic ? 'allSaints' : 'reformation',
      'ordinarySeason',
      CelebrationRank.feast,
      LiturgicalColor.white,
    );
    add(
      _firstSundayOfAdvent(year),
      'firstAdvent',
      'adventSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.violet,
    );
    add(
      DateTime(year, 12, 25),
      'christmas',
      'christmasSeason',
      CelebrationRank.solemnity,
      LiturgicalColor.white,
    );
  }

  days.sort((left, right) => left.date.compareTo(right.date));
  return HolyCalendar(
    days: days,
    tradition: tradition,
    year: year,
    locale: language,
  );
}

DateTime _westernEaster(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = (h + l - 7 * m + 114) % 31 + 1;
  return DateTime(year, month, day);
}

DateTime _orthodoxEaster(int year) {
  final a = year % 4;
  final b = year % 7;
  final c = year % 19;
  final d = (19 * c + 15) % 30;
  final e = (2 * a + 4 * b - d + 34) % 7;
  final month = (d + e + 114) ~/ 31;
  final day = (d + e + 114) % 31 + 1;
  return DateTime(year, month, day).add(const Duration(days: 13));
}

DateTime _firstSundayOfAdvent(int year) {
  var date = DateTime(year, 11, 27);
  while (date.weekday != DateTime.sunday) {
    date = date.add(const Duration(days: 1));
  }
  return date;
}

String _date(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

const _labels = <String, Map<String, String>>{
  'en': {
    'nativity': 'Nativity of Christ',
    'theophany': 'Theophany',
    'cleanMonday': 'Clean Monday',
    'palmSunday': 'Palm Sunday',
    'goodFriday': 'Good Friday',
    'pascha': 'Pascha',
    'easter': 'Easter Sunday',
    'ascension': 'Ascension',
    'pentecost': 'Pentecost',
    'transfiguration': 'Transfiguration',
    'dormition': 'Dormition',
    'nativityFast': 'Beginning of the Nativity Fast',
    'epiphany': 'Epiphany',
    'ashWednesday': 'Ash Wednesday',
    'allSaints': 'All Saints Day',
    'reformation': 'Reformation Day',
    'firstAdvent': 'First Sunday of Advent',
    'christmas': 'Christmas Day',
    'christmasSeason': 'Christmas',
    'epiphanySeason': 'Epiphany',
    'lentSeason': 'Lent',
    'holyWeek': 'Holy Week',
    'easterSeason': 'Easter',
    'ordinarySeason': 'Ordinary Time',
    'adventSeason': 'Advent',
  },
  'pt': {
    'nativity': 'Natividade de Cristo',
    'theophany': 'Teofania',
    'cleanMonday': 'Segunda-feira Limpa',
    'palmSunday': 'Domingo de Ramos',
    'goodFriday': 'Sexta-feira Santa',
    'pascha': 'Páscoa Ortodoxa',
    'easter': 'Domingo de Páscoa',
    'ascension': 'Ascensão',
    'pentecost': 'Pentecostes',
    'transfiguration': 'Transfiguração',
    'dormition': 'Dormição',
    'nativityFast': 'Início do Jejum da Natividade',
    'epiphany': 'Epifania',
    'ashWednesday': 'Quarta-feira de Cinzas',
    'allSaints': 'Dia de Todos os Santos',
    'reformation': 'Dia da Reforma',
    'firstAdvent': 'Primeiro Domingo do Advento',
    'christmas': 'Natal',
    'christmasSeason': 'Natal',
    'epiphanySeason': 'Epifania',
    'lentSeason': 'Quaresma',
    'holyWeek': 'Semana Santa',
    'easterSeason': 'Páscoa',
    'ordinarySeason': 'Tempo Comum',
    'adventSeason': 'Advento',
  },
  'es': {
    'nativity': 'Natividad de Cristo',
    'theophany': 'Teofanía',
    'cleanMonday': 'Lunes Limpio',
    'palmSunday': 'Domingo de Ramos',
    'goodFriday': 'Viernes Santo',
    'pascha': 'Pascua Ortodoxa',
    'easter': 'Domingo de Pascua',
    'ascension': 'Ascensión',
    'pentecost': 'Pentecostés',
    'transfiguration': 'Transfiguración',
    'dormition': 'Dormición',
    'nativityFast': 'Inicio del Ayuno de la Natividad',
    'epiphany': 'Epifanía',
    'ashWednesday': 'Miércoles de Ceniza',
    'allSaints': 'Día de Todos los Santos',
    'reformation': 'Día de la Reforma',
    'firstAdvent': 'Primer Domingo de Adviento',
    'christmas': 'Navidad',
    'christmasSeason': 'Navidad',
    'epiphanySeason': 'Epifanía',
    'lentSeason': 'Cuaresma',
    'holyWeek': 'Semana Santa',
    'easterSeason': 'Pascua',
    'ordinarySeason': 'Tiempo Ordinario',
    'adventSeason': 'Adviento',
  },
  'fr': {
    'nativity': 'Nativité du Christ',
    'theophany': 'Théophanie',
    'cleanMonday': 'Lundi Pur',
    'palmSunday': 'Dimanche des Rameaux',
    'goodFriday': 'Vendredi Saint',
    'pascha': 'Pâques orthodoxe',
    'easter': 'Dimanche de Pâques',
    'ascension': 'Ascension',
    'pentecost': 'Pentecôte',
    'transfiguration': 'Transfiguration',
    'dormition': 'Dormition',
    'nativityFast': 'Début du jeûne de la Nativité',
    'epiphany': 'Épiphanie',
    'ashWednesday': 'Mercredi des Cendres',
    'allSaints': 'Toussaint',
    'reformation': 'Jour de la Réformation',
    'firstAdvent': 'Premier dimanche de l’Avent',
    'christmas': 'Noël',
    'christmasSeason': 'Noël',
    'epiphanySeason': 'Épiphanie',
    'lentSeason': 'Carême',
    'holyWeek': 'Semaine Sainte',
    'easterSeason': 'Pâques',
    'ordinarySeason': 'Temps Ordinaire',
    'adventSeason': 'Avent',
  },
  'de': {
    'nativity': 'Geburt Christi',
    'theophany': 'Theophanie',
    'cleanMonday': 'Reiner Montag',
    'palmSunday': 'Palmsonntag',
    'goodFriday': 'Karfreitag',
    'pascha': 'Orthodoxes Ostern',
    'easter': 'Ostersonntag',
    'ascension': 'Christi Himmelfahrt',
    'pentecost': 'Pfingsten',
    'transfiguration': 'Verklärung',
    'dormition': 'Entschlafung',
    'nativityFast': 'Beginn des Weihnachtsfastens',
    'epiphany': 'Erscheinung des Herrn',
    'ashWednesday': 'Aschermittwoch',
    'allSaints': 'Allerheiligen',
    'reformation': 'Reformationstag',
    'firstAdvent': 'Erster Adventssonntag',
    'christmas': 'Weihnachten',
    'christmasSeason': 'Weihnachten',
    'epiphanySeason': 'Epiphanie',
    'lentSeason': 'Fastenzeit',
    'holyWeek': 'Karwoche',
    'easterSeason': 'Ostern',
    'ordinarySeason': 'Zeit im Jahreskreis',
    'adventSeason': 'Advent',
  },
  'it': {
    'nativity': 'Natività di Cristo',
    'theophany': 'Teofania',
    'cleanMonday': 'Lunedì Puro',
    'palmSunday': 'Domenica delle Palme',
    'goodFriday': 'Venerdì Santo',
    'pascha': 'Pasqua ortodossa',
    'easter': 'Domenica di Pasqua',
    'ascension': 'Ascensione',
    'pentecost': 'Pentecoste',
    'transfiguration': 'Trasfigurazione',
    'dormition': 'Dormizione',
    'nativityFast': 'Inizio del digiuno della Natività',
    'epiphany': 'Epifania',
    'ashWednesday': 'Mercoledì delle Ceneri',
    'allSaints': 'Tutti i Santi',
    'reformation': 'Giorno della Riforma',
    'firstAdvent': 'Prima Domenica di Avvento',
    'christmas': 'Natale',
    'christmasSeason': 'Natale',
    'epiphanySeason': 'Epifania',
    'lentSeason': 'Quaresima',
    'holyWeek': 'Settimana Santa',
    'easterSeason': 'Pasqua',
    'ordinarySeason': 'Tempo Ordinario',
    'adventSeason': 'Avvento',
  },
  'ru': {
    'nativity': 'Рождество Христово',
    'theophany': 'Богоявление',
    'cleanMonday': 'Чистый понедельник',
    'palmSunday': 'Вербное воскресенье',
    'goodFriday': 'Страстная пятница',
    'pascha': 'Пасха',
    'easter': 'Пасхальное воскресенье',
    'ascension': 'Вознесение',
    'pentecost': 'Пятидесятница',
    'transfiguration': 'Преображение',
    'dormition': 'Успение',
    'nativityFast': 'Начало Рождественского поста',
    'epiphany': 'Богоявление',
    'ashWednesday': 'Пепельная среда',
    'allSaints': 'День всех святых',
    'reformation': 'День Реформации',
    'firstAdvent': 'Первое воскресенье Адвента',
    'christmas': 'Рождество',
    'christmasSeason': 'Рождество',
    'epiphanySeason': 'Богоявление',
    'lentSeason': 'Великий пост',
    'holyWeek': 'Страстная неделя',
    'easterSeason': 'Пасха',
    'ordinarySeason': 'Обычное время',
    'adventSeason': 'Адвент',
  },
};
