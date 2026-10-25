import 'package:flutter/foundation.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/content/content_repository.dart';

enum StudyType { readingPlan, listeningPlan, studyPlan, challenge }

enum StudyDifficulty { beginner, intermediate, advanced }

class StudyLesson {
  const StudyLesson({
    required this.day,
    required this.title,
    required this.reading,
    required this.reflection,
    this.verses,
  });
  final int day;
  final String title;
  final String reading;
  final String reflection;
  final List<String>? verses;

  factory StudyLesson.fromJson(Map<String, dynamic> json) => StudyLesson(
    day: (json['day'] as num).toInt(),
    title: json['title'] as String,
    reading: json['reading'] as String,
    reflection: json['reflection'] as String,
    verses: (json['verses'] as List?)?.cast<String>(),
  );
  Map<String, dynamic> toJson() => {
    'day': day,
    'title': title,
    'reading': reading,
    'reflection': reflection,
    'verses': verses,
  };
}

class StudyPlan {
  const StudyPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.topics,
    required this.lessons,
    this.imageKey,
    this.tags,
    this.startedAt,
    this.completedAt,
    this.dayProgress = const {},
  });
  final String id;
  final String title;
  final String description;
  final StudyType type;
  final StudyDifficulty difficulty;
  final List<String> topics;
  final List<StudyLesson> lessons;
  final String? imageKey;
  final List<String>? tags;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<int, bool> dayProgress;
  int get durationDays => lessons.length;
  int get completedDays =>
      lessons.where((day) => dayProgress[day.day] == true).length;
  double get progress => durationDays == 0 ? 0 : completedDays / durationDays;
  bool get isStarted => startedAt != null;
  bool get isCompleted => completedAt != null;

  StudyPlan copyWith({
    DateTime? startedAt,
    DateTime? completedAt,
    Map<int, bool>? dayProgress,
  }) => StudyPlan(
    id: id,
    title: title,
    description: description,
    type: type,
    difficulty: difficulty,
    topics: topics,
    lessons: lessons,
    imageKey: imageKey,
    tags: tags,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    dayProgress: dayProgress ?? this.dayProgress,
  );
}

class StudyRepository extends ChangeNotifier {
  StudyRepository(this._storage, this._content) {
    _content.addListener(_refreshCatalog);
  }
  static const _storageKey = 'studyProgress';
  final StorageService _storage;
  final ContentRepository _content;
  final List<StudyPlan> _plans = [];
  List<StudyPlan> get availablePlans => List.unmodifiable(_plans);
  List<StudyPlan> get myPlans =>
      _plans.where((plan) => plan.isStarted).toList(growable: false);
  bool get isLoading => false;

  Future<void> init() async => _refreshCatalog();

  void _refreshCatalog() {
    final devotional = _content.devotional;
    if (devotional == null) return;
    // Original, localized lessons from the independently authored CC0 collection.
    // The ID deliberately does not contain the locale: progress survives language changes.
    final plan = StudyPlan(
      id: devotional.id,
      title: devotional.title,
      description: devotional.days.first.reflection,
      type: StudyType.studyPlan,
      difficulty: StudyDifficulty.beginner,
      topics: const [],
      lessons:
          devotional.days
              .map(
                (day) => StudyLesson(
                  day: day.number,
                  title: day.title,
                  reading: day.reference,
                  reflection: [
                    day.reflection,
                    day.practice,
                    day.prayer,
                  ].join('\n\n'),
                ),
              )
              .toList(),
    );
    final progress =
        _storage.read<Map<dynamic, dynamic>>(_storageKey) ?? const {};
    _plans
      ..clear()
      ..add(_restore(plan, progress[plan.id]));
    notifyListeners();
  }

  Future<void> startPlan(String planId) async {
    final index = _plans.indexWhere((plan) => plan.id == planId);
    if (index < 0 || _plans[index].isStarted) return;
    _plans[index] = _plans[index].copyWith(startedAt: DateTime.now());
    await _save();
  }

  Future<void> completeDay(String planId, int day) async {
    final index = _plans.indexWhere((plan) => plan.id == planId);
    if (index < 0) return;
    final plan = _plans[index];
    if (!plan.isStarted || !plan.lessons.any((lesson) => lesson.day == day)) {
      return;
    }
    final progress = {...plan.dayProgress, day: true};
    _plans[index] = plan.copyWith(
      dayProgress: progress,
      completedAt:
          plan.lessons.every((lesson) => progress[lesson.day] == true)
              ? DateTime.now()
              : null,
    );
    await _save();
  }

  Future<void> removePlan(String planId) async {
    final index = _plans.indexWhere((plan) => plan.id == planId);
    if (index < 0) return;
    final plan = _plans[index];
    _plans[index] = StudyPlan(
      id: plan.id,
      title: plan.title,
      description: plan.description,
      type: plan.type,
      difficulty: plan.difficulty,
      topics: plan.topics,
      lessons: plan.lessons,
      imageKey: plan.imageKey,
      tags: plan.tags,
    );
    await _save();
  }

  StudyPlan? getPlan(String id) {
    for (final plan in _plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  StudyLesson? getLesson(String planId, int day) {
    for (final lesson in getPlan(planId)?.lessons ?? <StudyLesson>[]) {
      if (lesson.day == day) return lesson;
    }
    return null;
  }

  StudyPlan _restore(StudyPlan plan, Object? raw) {
    if (raw is! Map) return plan;
    final days = <int, bool>{};
    if (raw['days'] is Map) {
      for (final entry in (raw['days'] as Map).entries) {
        final day = int.tryParse(entry.key.toString());
        if (day != null &&
            entry.value == true &&
            plan.lessons.any((lesson) => lesson.day == day)) {
          days[day] = true;
        }
      }
    }
    return plan.copyWith(
      startedAt: DateTime.tryParse(raw['startedAt'] as String? ?? ''),
      completedAt:
          days.length == plan.durationDays
              ? DateTime.tryParse(raw['completedAt'] as String? ?? '')
              : null,
      dayProgress: days,
    );
  }

  Future<void> _save() async {
    await _storage.write(_storageKey, {
      for (final plan in myPlans)
        plan.id: {
          'startedAt': plan.startedAt?.toIso8601String(),
          'completedAt': plan.completedAt?.toIso8601String(),
          'days': {
            for (final entry in plan.dayProgress.entries)
              entry.key.toString(): entry.value,
          },
        },
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _content.removeListener(_refreshCatalog);
    super.dispose();
  }
}
