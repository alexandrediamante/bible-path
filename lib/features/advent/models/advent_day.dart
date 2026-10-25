class AdventDay {
  const AdventDay({
    required this.day,
    required this.reference,
    required this.text,
  });

  final int day;
  final String reference;
  final String text;

  factory AdventDay.fromJson(Map<String, dynamic> json) {
    return AdventDay(
      day: (json['day'] as num).toInt(),
      reference: json['reference'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'reference': reference,
    'text': text,
  };
}

class AdventCollection {
  const AdventCollection({
    required this.locale,
    required this.title,
    required this.days,
  });

  final String locale;
  final String title;
  final List<AdventDay> days;

  factory AdventCollection.fromJson(Map<String, dynamic> json) {
    final days =
        (json['days'] as List)
            .whereType<Map>()
            .map((item) => AdventDay.fromJson(Map<String, dynamic>.from(item)))
            .toList();
    if (days.length != 25) {
      throw const FormatException('An Advent collection must contain 25 days.');
    }
    return AdventCollection(
      locale: json['locale'] as String,
      title: json['title'] as String,
      days: days,
    );
  }
}
