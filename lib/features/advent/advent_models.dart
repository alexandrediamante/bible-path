import 'package:flutter/material.dart';

import 'package:bible_path/l10n/app_localizations.dart';

/// Represents a single day in the Advent calendar (1-25)
class AdventDay {
  const AdventDay({
    required this.day,
    required this.title,
    required this.scriptureReference,
    required this.scriptureText,
    required this.reflection,
    required this.prayer,
    this.imageUrl,
  });

  final int day;
  final String title;
  final String scriptureReference;
  final String scriptureText;
  final String reflection;
  final String prayer;
  final String? imageUrl;

  factory AdventDay.fromJson(Map<String, dynamic> json) {
    return AdventDay(
      day: json['day'] as int,
      title: json['title'] as String,
      scriptureReference: json['scriptureReference'] as String,
      scriptureText: json['scriptureText'] as String,
      reflection: json['reflection'] as String,
      prayer: json['prayer'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'scriptureReference': scriptureReference,
      'scriptureText': scriptureText,
      'reflection': reflection,
      'prayer': prayer,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  AdventDay copyWith({
    int? day,
    String? title,
    String? scriptureReference,
    String? scriptureText,
    String? reflection,
    String? prayer,
    String? imageUrl,
  }) {
    return AdventDay(
      day: day ?? this.day,
      title: title ?? this.title,
      scriptureReference: scriptureReference ?? this.scriptureReference,
      scriptureText: scriptureText ?? this.scriptureText,
      reflection: reflection ?? this.reflection,
      prayer: prayer ?? this.prayer,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  /// Returns the liturgical color for this day's week
  Color getLiturgicalColor(BuildContext context) {
    final theme = Theme.of(context);
    // Week 1 (Days 1-7): Hope - Purple
    // Week 2 (Days 8-14): Peace - Purple
    // Week 3 (Days 15-21): Joy - Rose (Gaudete Sunday ~Day 13)
    // Week 4 (Days 22-25): Love - Purple/White
    if (day <= 14) {
      return theme.colorScheme.secondary; // Purple
    } else if (day <= 21) {
      return const Color(0xFFE8A8B8); // Rose for Joy week
    } else {
      return theme.colorScheme.secondary; // Purple/White
    }
  }

  /// Returns the week theme for this day
  String getWeekTheme(AppLocalizations l10n) {
    if (day <= 7) return l10n.adventWeekHope;
    if (day <= 14) return l10n.adventWeekPeace;
    if (day <= 21) return l10n.adventWeekJoy;
    return l10n.adventWeekLove;
  }
}

/// Represents the full Advent calendar with 25 days
class AdventCalendar {
  const AdventCalendar({required this.days, required this.locale});

  final List<AdventDay> days;
  final String locale;

  factory AdventCalendar.fromJson(Map<String, dynamic> json, String locale) {
    final daysList =
        (json['days'] as List<dynamic>)
            .map((e) => AdventDay.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.day.compareTo(b.day));
    return AdventCalendar(days: daysList, locale: locale);
  }

  Map<String, dynamic> toJson() {
    return {'days': days.map((e) => e.toJson()).toList()};
  }

  AdventDay? getDay(int day) {
    try {
      return days.firstWhere((d) => d.day == day);
    } catch (_) {
      return null;
    }
  }

  List<AdventDay> getDaysUpTo(int maxDay) {
    return days.where((d) => d.day <= maxDay).toList();
  }

  AdventDay? getCurrentDay() {
    final now = DateTime.now();
    final currentDay = now.month == 12 ? now.day.clamp(1, 25) : 0;
    if (currentDay == 0) return null;
    return getDay(currentDay);
  }
}

/// Advent week themes (used for localization keys)
enum AdventWeekTheme {
  hope, // Days 1-7
  peace, // Days 8-14
  joy, // Days 15-21
  love, // Days 22-25
}

extension AdventWeekThemeExtension on AdventWeekTheme {
  String getLocalizationKey() {
    switch (this) {
      case AdventWeekTheme.hope:
        return 'adventWeekHope';
      case AdventWeekTheme.peace:
        return 'adventWeekPeace';
      case AdventWeekTheme.joy:
        return 'adventWeekJoy';
      case AdventWeekTheme.love:
        return 'adventWeekLove';
    }
  }

  Color getColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (this) {
      case AdventWeekTheme.hope:
      case AdventWeekTheme.peace:
      case AdventWeekTheme.love:
        return theme.colorScheme.secondary; // Purple
      case AdventWeekTheme.joy:
        return const Color(0xFFE8A8B8); // Rose
    }
  }
}

extension AdventDayExtension on AdventDay {
  AdventWeekTheme get weekTheme {
    if (day <= 7) return AdventWeekTheme.hope;
    if (day <= 14) return AdventWeekTheme.peace;
    if (day <= 21) return AdventWeekTheme.joy;
    return AdventWeekTheme.love;
  }
}
