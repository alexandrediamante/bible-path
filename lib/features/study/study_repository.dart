import 'package:flutter/material.dart';

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
  });

  final int day;
  final String title;
  final String reading;
  final String reflection;
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
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<int, bool> dayProgress;

  int get durationDays => lessons.length;
  int get completedDays => dayProgress.values.where((done) => done).length;
  double get progress => durationDays == 0 ? 0 : completedDays / durationDays;
  bool get isStarted => startedAt != null;
  bool get isCompleted => completedAt != null;

  StudyPlan copyWith({
    DateTime? startedAt,
    DateTime? completedAt,
    Map<int, bool>? dayProgress,
  }) {
    return StudyPlan(
      id: id,
      title: title,
      description: description,
      type: type,
      difficulty: difficulty,
      topics: topics,
      lessons: lessons,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      dayProgress: dayProgress ?? this.dayProgress,
    );
  }
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

  Future<void> init() async {
    _rebuildCatalog();
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
    var plan = _plans[index];
    if (!plan.isStarted || day < 1 || day > plan.durationDays) return;

    final progress = {...plan.dayProgress, day: true};
    plan = plan.copyWith(
      dayProgress: progress,
      completedAt: progress.length == plan.durationDays ? DateTime.now() : null,
    );
    _plans[index] = plan;
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
    final plan = getPlan(planId);
    if (plan == null) return null;
    for (final lesson in plan.lessons) {
      if (lesson.day == day) return lesson;
    }
    return null;
  }

  void _rebuildCatalog() {
    final devotional = _content.devotional;
    if (devotional == null) {
      throw StateError(_content.error ?? 'Localized content is unavailable.');
    }

    final progress =
        _storage.read<Map<dynamic, dynamic>>(_storageKey) ?? const {};
    final plan = StudyPlan(
      id: devotional.id,
      title: devotional.title,
      description: devotional.days.first.reflection,
      type: StudyType.studyPlan,
      difficulty: StudyDifficulty.beginner,
      topics: [devotional.days.first.title],
      lessons: [
        for (final day in devotional.days)
          StudyLesson(
            day: day.number,
            title: day.title,
            reading: day.reference,
            reflection: '${day.reflection}\n\n${day.practice}\n\n${day.prayer}',
          ),
      ],
    );

    _plans
      ..clear()
      ..add(_restore(plan, progress[plan.id]));
  }

  StudyPlan _restore(StudyPlan plan, Object? raw) {
    if (raw is! Map) return plan;
    final days = <int, bool>{};
    final rawDays = raw['days'];
    if (rawDays is Map) {
      for (final entry in rawDays.entries) {
        final day = int.tryParse(entry.key.toString());
        if (day != null && entry.value == true) days[day] = true;
      }
    }
    return plan.copyWith(
      startedAt: DateTime.tryParse(raw['startedAt'] as String? ?? ''),
      completedAt: DateTime.tryParse(raw['completedAt'] as String? ?? ''),
      dayProgress: days,
    );
  }

  void _refreshCatalog() {
    if (_content.devotional == null) return;
    _rebuildCatalog();
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.write(_storageKey, {
      for (final plan in _plans.where((item) => item.isStarted))
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
