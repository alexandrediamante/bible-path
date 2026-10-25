class LentDay {
  const LentDay({
    required this.id,
    required this.title,
    required this.description,
    required this.dailyVerse,
    required this.dailyVerseQuote,
    required this.dailyPrayer,
    required this.seconds,
    required this.roundedMinutes,
  });

  final int id;
  final String title;
  final String description;
  final String dailyVerse;
  final String dailyVerseQuote;
  final String dailyPrayer;
  final int seconds;
  final int roundedMinutes;

  String get durationDisplay {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0 && remainingSeconds > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${remainingSeconds}s';
    }
  }

  factory LentDay.fromJson(Map<String, dynamic> json) {
    return LentDay(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      dailyVerse: json['dailyVerse'] as String,
      dailyVerseQuote: json['dailyVerseQuote'] as String,
      dailyPrayer: json['dailyPrayer'] as String,
      seconds: (json['seconds'] as num).toInt(),
      roundedMinutes: (json['roundedMinutes'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dailyVerse': dailyVerse,
    'dailyVerseQuote': dailyVerseQuote,
    'dailyPrayer': dailyPrayer,
    'seconds': seconds,
    'roundedMinutes': roundedMinutes,
  };
}

class LentCollection {
  const LentCollection({
    required this.locale,
    required this.title,
    required this.days,
  });

  final String locale;
  final String title;
  final List<LentDay> days;

  factory LentCollection.fromJson(Map<String, dynamic> json) {
    final days =
        (json['days'] as List)
            .whereType<Map>()
            .map((item) => LentDay.fromJson(Map<String, dynamic>.from(item)))
            .toList();
    if (days.length < 40) {
      throw const FormatException(
        'A Lent collection must contain at least 40 days.',
      );
    }
    return LentCollection(
      locale: json['locale'] as String,
      title: json['title'] as String,
      days: days,
    );
  }
}
