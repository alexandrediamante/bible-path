import 'package:flutter/material.dart';
import 'package:bible_path/l10n/app_localizations.dart';

/// Liturgical tradition types
enum LiturgicalTradition { catholic, orthodox, protestant }

/// Represents a single day in the Holy Calendar
class HolyCalendarDay {
  const HolyCalendarDay({
    required this.date,
    required this.season,
    required this.week,
    required this.dayName,
    required this.rank,
    required this.color,
    required this.readings,
    this.fastingRules,
    this.notes,
    this.saints,
    this.isHolyDayOfObligation = false,
  });

  /// Date in ISO format (YYYY-MM-DD)
  final String date;

  /// Liturgical season (Advent, Christmas, Lent, Easter, Ordinary Time, etc.)
  final String season;

  /// Week within the season (e.g., "1st Week of Advent")
  final String week;

  /// Name of the day (e.g., "Christmas Day", "Ash Wednesday", "Friday of the 2nd Week of Lent")
  final String dayName;

  /// Rank of the celebration (Solemnity, Feast, Memorial, Optional Memorial, Weekday)
  final CelebrationRank rank;

  /// Liturgical color for the day
  final LiturgicalColor color;

  /// Scripture readings for the day
  final List<ScriptureReading> readings;

  /// Fasting/abstinence rules if applicable
  final String? fastingRules;

  /// Additional notes
  final String? notes;

  /// Saints commemorated on this day
  final List<String>? saints;

  /// Whether this is a Holy Day of Obligation (Catholic)
  final bool isHolyDayOfObligation;

  factory HolyCalendarDay.fromJson(Map<String, dynamic> json) {
    return HolyCalendarDay(
      date: json['date'] as String,
      season: json['season'] as String,
      week: json['week'] as String,
      dayName: json['dayName'] as String,
      rank: CelebrationRank.values.byName(json['rank'] as String),
      color: LiturgicalColor.values.byName(json['color'] as String),
      readings:
          (json['readings'] as List<dynamic>)
              .map((e) => ScriptureReading.fromJson(e as Map<String, dynamic>))
              .toList(),
      fastingRules: json['fastingRules'] as String?,
      notes: json['notes'] as String?,
      saints:
          (json['saints'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isHolyDayOfObligation: json['isHolyDayOfObligation'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'season': season,
      'week': week,
      'dayName': dayName,
      'rank': rank.name,
      'color': color.name,
      'readings': readings.map((e) => e.toJson()).toList(),
      if (fastingRules != null) 'fastingRules': fastingRules,
      if (notes != null) 'notes': notes,
      if (saints != null) 'saints': saints,
      'isHolyDayOfObligation': isHolyDayOfObligation,
    };
  }

  HolyCalendarDay copyWith({
    String? date,
    String? season,
    String? week,
    String? dayName,
    CelebrationRank? rank,
    LiturgicalColor? color,
    List<ScriptureReading>? readings,
    String? fastingRules,
    String? notes,
    List<String>? saints,
    bool? isHolyDayOfObligation,
  }) {
    return HolyCalendarDay(
      date: date ?? this.date,
      season: season ?? this.season,
      week: week ?? this.week,
      dayName: dayName ?? this.dayName,
      rank: rank ?? this.rank,
      color: color ?? this.color,
      readings: readings ?? this.readings,
      fastingRules: fastingRules ?? this.fastingRules,
      notes: notes ?? this.notes,
      saints: saints ?? this.saints,
      isHolyDayOfObligation:
          isHolyDayOfObligation ?? this.isHolyDayOfObligation,
    );
  }

  /// Returns the liturgical color as a Flutter Color
  Color getColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (color) {
      case LiturgicalColor.white:
        return theme.colorScheme.surface;
      case LiturgicalColor.red:
        return theme.colorScheme.error;
      case LiturgicalColor.green:
        return Colors.green.shade700;
      case LiturgicalColor.violet:
        return theme.colorScheme.secondary;
      case LiturgicalColor.rose:
        return const Color(0xFFE8A8B8);
      case LiturgicalColor.black:
        return theme.colorScheme.onSurface;
      case LiturgicalColor.gold:
        return Colors.amber.shade700;
      case LiturgicalColor.blue:
        return Colors.blue.shade700;
    }
  }
}

/// Represents a scripture reading for a liturgical day
class ScriptureReading {
  const ScriptureReading({
    required this.type,
    required this.citation,
    required this.text,
    this.response,
  });

  /// Type of reading (First Reading, Psalm, Second Reading, Gospel)
  final ReadingType type;

  /// Biblical citation (e.g., "Isaiah 9:1-6")
  final String citation;

  /// Full text of the reading
  final String text;

  /// Responsorial psalm response (for Psalm type)
  final String? response;

  factory ScriptureReading.fromJson(Map<String, dynamic> json) {
    return ScriptureReading(
      type: ReadingType.values.byName(json['type'] as String),
      citation: json['citation'] as String,
      text: json['text'] as String,
      response: json['response'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'citation': citation,
      'text': text,
      if (response != null) 'response': response,
    };
  }
}

/// Types of scripture readings in the liturgy
enum ReadingType {
  firstReading,
  psalm,
  secondReading,
  gospel,
  epistle,
  oldTestament,
  newTestament,
}

/// Rank of liturgical celebration
enum CelebrationRank {
  solemnity,
  feast,
  memorial,
  optionalMemorial,
  weekday,
  ferial,
}

/// Liturgical colors
enum LiturgicalColor { white, red, green, violet, rose, black, gold, blue }

/// Represents the full Holy Calendar for a year
class HolyCalendar {
  const HolyCalendar({
    required this.days,
    required this.tradition,
    required this.year,
    required this.locale,
  });

  final List<HolyCalendarDay> days;
  final LiturgicalTradition tradition;
  final int year;
  final String locale;

  factory HolyCalendar.fromJson(
    Map<String, dynamic> json,
    LiturgicalTradition tradition,
    String locale,
  ) {
    final daysList =
        (json['days'] as List<dynamic>)
            .map((e) => HolyCalendarDay.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return HolyCalendar(
      days: daysList,
      tradition: tradition,
      year: json['year'] as int? ?? DateTime.now().year,
      locale: locale,
    );
  }

  Map<String, dynamic> toJson() {
    return {'days': days.map((e) => e.toJson()).toList(), 'year': year};
  }

  HolyCalendarDay? getDay(String date) {
    try {
      return days.firstWhere((d) => d.date == date);
    } catch (_) {
      return null;
    }
  }

  List<HolyCalendarDay> getDaysForSeason(String season) {
    return days.where((d) => d.season == season).toList();
  }

  List<HolyCalendarDay> getDaysForDateRange(DateTime start, DateTime end) {
    final startStr = _dateToString(start);
    final endStr = _dateToString(end);
    return days
        .where(
          (d) =>
              d.date.compareTo(startStr) >= 0 && d.date.compareTo(endStr) <= 0,
        )
        .toList();
  }

  HolyCalendarDay? getToday() {
    final today = _dateToString(DateTime.now());
    return getDay(today);
  }

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get the current liturgical season
  String? getCurrentSeason() {
    final today = getToday();
    return today?.season;
  }

  /// Get days for a specific month
  List<HolyCalendarDay> getDaysForMonth(int month) {
    return days.where((d) {
      final dateParts = d.date.split('-');
      return int.parse(dateParts[1]) == month;
    }).toList();
  }
}

/// Extension for localized tradition names
extension LiturgicalTraditionExtension on LiturgicalTradition {
  String getLocalizationKey() {
    switch (this) {
      case LiturgicalTradition.catholic:
        return 'traditionCatholic';
      case LiturgicalTradition.orthodox:
        return 'traditionOrthodox';
      case LiturgicalTradition.protestant:
        return 'traditionProtestant';
    }
  }

  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case LiturgicalTradition.catholic:
        return l10n.onboardingDenominationCatholic;
      case LiturgicalTradition.orthodox:
        return l10n.onboardingDenominationOrthodox;
      case LiturgicalTradition.protestant:
        return l10n.onboardingDenominationProtestant;
    }
  }

  Color getColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (this) {
      case LiturgicalTradition.catholic:
        return theme.colorScheme.primary;
      case LiturgicalTradition.orthodox:
        return const Color(0xFF8B0000); // Deep red/byzantine
      case LiturgicalTradition.protestant:
        return Colors.blue.shade700;
    }
  }
}

/// Extension for localized rank names
extension CelebrationRankExtension on CelebrationRank {
  String getLocalizationKey() {
    switch (this) {
      case CelebrationRank.solemnity:
        return 'rankSolemnity';
      case CelebrationRank.feast:
        return 'rankFeast';
      case CelebrationRank.memorial:
        return 'rankMemorial';
      case CelebrationRank.optionalMemorial:
        return 'rankOptionalMemorial';
      case CelebrationRank.weekday:
        return 'rankWeekday';
      case CelebrationRank.ferial:
        return 'rankFerial';
    }
  }
}

/// Extension for localized reading type names
extension ReadingTypeExtension on ReadingType {
  String getLocalizationKey() {
    switch (this) {
      case ReadingType.firstReading:
        return 'readingFirstReading';
      case ReadingType.psalm:
        return 'readingPsalm';
      case ReadingType.secondReading:
        return 'readingSecondReading';
      case ReadingType.gospel:
        return 'readingGospel';
      case ReadingType.epistle:
        return 'readingEpistle';
      case ReadingType.oldTestament:
        return 'readingOldTestament';
      case ReadingType.newTestament:
        return 'readingNewTestament';
    }
  }
}

/// Extension for localized color names
extension LiturgicalColorExtension on LiturgicalColor {
  String getLocalizationKey() {
    switch (this) {
      case LiturgicalColor.white:
        return 'colorWhite';
      case LiturgicalColor.red:
        return 'colorRed';
      case LiturgicalColor.green:
        return 'colorGreen';
      case LiturgicalColor.violet:
        return 'colorViolet';
      case LiturgicalColor.rose:
        return 'colorRose';
      case LiturgicalColor.black:
        return 'colorBlack';
      case LiturgicalColor.gold:
        return 'colorGold';
      case LiturgicalColor.blue:
        return 'colorBlue';
    }
  }
}
