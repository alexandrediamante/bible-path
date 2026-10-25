import 'package:flutter/foundation.dart';

import 'listen_day.dart';

class ListenPlan {
  const ListenPlan({
    required this.id,
    required this.locale,
    required this.title,
    required this.description,
    required this.days,
    this.startedAt,
    this.completedAt,
    this.dayProgress = const {},
  });

  final String id;
  final String locale;
  final String title;
  final String description;
  final List<ListenDay> days;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<int, bool> dayProgress;

  int get totalDays => days.length;
  int get completedDays => dayProgress.values.where((done) => done).length;
  double get progress => totalDays == 0 ? 0 : completedDays / totalDays;
  bool get isStarted => startedAt != null;
  bool get isCompleted => completedAt != null;
  int get totalDurationSeconds =>
      days.fold(0, (sum, day) => sum + day.durationSeconds);
  int get totalRoundedMinutes =>
      days.fold(0, (sum, day) => sum + day.roundedMinutes);

  ListenPlan copyWith({
    DateTime? startedAt,
    DateTime? completedAt,
    Map<int, bool>? dayProgress,
    bool clearCompletedAt = false,
  }) {
    return ListenPlan(
      id: id,
      locale: locale,
      title: title,
      description: description,
      days: days,
      startedAt: startedAt ?? this.startedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
      dayProgress: dayProgress ?? this.dayProgress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListenPlan &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          locale == other.locale &&
          title == other.title &&
          description == other.description &&
          listEquals(days, other.days) &&
          startedAt == other.startedAt &&
          completedAt == other.completedAt &&
          mapEquals(dayProgress, other.dayProgress);

  @override
  int get hashCode => Object.hash(
    id,
    locale,
    title,
    description,
    days,
    startedAt,
    completedAt,
    dayProgress,
  );
}
