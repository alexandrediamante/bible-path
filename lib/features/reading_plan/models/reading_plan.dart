import 'package:flutter/foundation.dart';

enum ReadingPlanCategory { bookBased, thematic, chronological }

class ReadingPlanCategoryInfo {
  const ReadingPlanCategoryInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final ReadingPlanCategory category;
}

class ReadingPlan {
  const ReadingPlan({
    required this.id,
    required this.locale,
    required this.title,
    required this.description,
    required this.durationDays,
    this.book,
    this.startChapter,
    this.endChapter,
    this.chapters,
    this.readings,
    this.startedAt,
    this.completedAt,
    this.dayProgress = const {},
  });

  final String id;
  final String locale;
  final String title;
  final String description;
  final int durationDays;
  final String? book;
  final int? startChapter;
  final int? endChapter;
  final List<int>? chapters;
  final List<ReadingDay>? readings;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<int, bool> dayProgress;

  int get totalDays => durationDays;
  int get completedDays => dayProgress.values.where((done) => done).length;
  double get progress => totalDays == 0 ? 0 : completedDays / totalDays;
  bool get isStarted => startedAt != null;
  bool get isCompleted => completedAt != null;

  ReadingPlan copyWith({
    DateTime? startedAt,
    DateTime? completedAt,
    Map<int, bool>? dayProgress,
    bool clearCompletedAt = false,
  }) {
    return ReadingPlan(
      id: id,
      locale: locale,
      title: title,
      description: description,
      durationDays: durationDays,
      book: book,
      startChapter: startChapter,
      endChapter: endChapter,
      chapters: chapters,
      readings: readings,
      startedAt: startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      dayProgress: dayProgress ?? this.dayProgress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          locale == other.locale &&
          title == other.title &&
          description == other.description &&
          durationDays == other.durationDays &&
          book == other.book &&
          startChapter == other.startChapter &&
          endChapter == other.endChapter &&
          listEquals(chapters, other.chapters) &&
          listEquals(readings, other.readings) &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt &&
          mapEquals(dayProgress, other.dayProgress);

  @override
  int get hashCode => Object.hash(
    id,
    locale,
    title,
    description,
    durationDays,
    book,
    startChapter,
    endChapter,
    chapters,
    readings,
    startedAt,
    completedAt,
    dayProgress,
  );
}

class ReadingDay {
  const ReadingDay({
    required this.day,
    required this.title,
    required this.passage,
    this.description,
  });

  final int day;
  final String title;
  final String passage;
  final String? description;

  factory ReadingDay.fromJson(Map<String, dynamic> json) {
    return ReadingDay(
      day: (json['day'] as num).toInt(),
      title: json['title'] as String,
      passage: json['passage'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'day': day,
    'title': title,
    'passage': passage,
    'description': description,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingDay &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          title == other.title &&
          passage == other.passage &&
          description == other.description;

  @override
  int get hashCode => Object.hash(day, title, passage, description);
}

class ReadingPlanCategoryData {
  const ReadingPlanCategoryData({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.plans,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final List<ReadingPlan> plans;
}

class ReadingPlansData {
  const ReadingPlansData({
    required this.id,
    required this.locale,
    required this.title,
    required this.description,
    required this.categories,
  });

  final String id;
  final String locale;
  final String title;
  final String description;
  final List<ReadingPlanCategoryData> categories;
}
