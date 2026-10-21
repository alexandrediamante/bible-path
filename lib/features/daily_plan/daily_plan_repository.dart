import 'package:flutter/material.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/content/content_repository.dart';

enum PlanStepType { devotional, prayer, connection, verse, reading, listening }

class PlanStep {
  PlanStep({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.verseReference,
    this.audioUrl,
    required this.order,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final PlanStepType type;
  final String title;
  final String content;
  final String? verseReference;
  final String? audioUrl;
  final int order;
  bool isCompleted;
  DateTime? completedAt;

  factory PlanStep.fromJson(Map<dynamic, dynamic> json) {
    return PlanStep(
      id: json['id'] as String,
      type: PlanStepType.values.byName(json['type'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      verseReference: json['verseReference'] as String?,
      audioUrl: json['audioUrl'] as String?,
      order: (json['order'] as num).toInt(),
      isCompleted: json['isCompleted'] == true,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'content': content,
    'verseReference': verseReference,
    'audioUrl': audioUrl,
    'order': order,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };
}

class DailyPlan {
  DailyPlan({
    required this.id,
    required this.date,
    required this.steps,
    this.theme,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final DateTime date;
  final List<PlanStep> steps;
  final String? theme;
  bool isCompleted;
  DateTime? completedAt;

  int get completedSteps => steps.where((step) => step.isCompleted).length;
  int get totalSteps => steps.length;
  double get progress => totalSteps == 0 ? 0 : completedSteps / totalSteps;

  factory DailyPlan.fromJson(Map<dynamic, dynamic> json) {
    return DailyPlan(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      steps: (json['steps'] as List)
          .map((step) => PlanStep.fromJson(step as Map))
          .toList(),
      theme: json['theme'] as String?,
      isCompleted: json['isCompleted'] == true,
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'steps': steps.map((step) => step.toJson()).toList(),
    'theme': theme,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };
}

class DailyPlanRepository extends ChangeNotifier {
  DailyPlanRepository(this._storage, this._content, this._bible) {
    _content.addListener(_refreshLocalizedPlans);
    _bible.addListener(_refreshLocalizedPlans);
  }

  static const _plansKey = 'dailyPlans';
  static const _completedDatesKey = 'completedPlanDates';

  final StorageService _storage;
  final ContentRepository _content;
  final BibleRepository _bible;
  final Map<String, DailyPlan> _plans = {};
  final List<String> _completedPlanDates = [];
  DailyPlan? _todaysPlan;
  int _currentStreak = 0;
  int _longestStreak = 0;

  DailyPlan? get todaysPlan => _todaysPlan;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<String> get completedPlanDates => List.unmodifiable(_completedPlanDates);

  Future<void> init() async {
    final storedPlans = _storage.read<List<dynamic>>(_plansKey) ?? const [];
    for (final item in storedPlans.whereType<Map>()) {
      final plan = DailyPlan.fromJson(item);
      _plans[plan.id] = plan;
    }

    final storedDates =
        _storage.read<List<dynamic>>(_completedDatesKey) ?? const [];
    _completedPlanDates
      ..clear()
      ..addAll(storedDates.whereType<String>());

    _rebuildPlansForCurrentContent();
    _calculateStreaks();
    await _save();
    notifyListeners();
  }

  Future<void> completeStep(String planId, String stepId) async {
    final plan = _plans[planId];
    if (plan == null) return;
    final step = plan.steps.where((item) => item.id == stepId).firstOrNull;
    if (step == null || step.isCompleted) return;

    step
      ..isCompleted = true
      ..completedAt = DateTime.now();
    _updatePlanCompletion(plan);
    await _save();
    notifyListeners();
  }

  Future<void> uncompleteStep(String planId, String stepId) async {
    final plan = _plans[planId];
    if (plan == null) return;
    final step = plan.steps.where((item) => item.id == stepId).firstOrNull;
    if (step == null || !step.isCompleted) return;

    step
      ..isCompleted = false
      ..completedAt = null;
    plan
      ..isCompleted = false
      ..completedAt = null;
    _completedPlanDates.remove(plan.id);
    _calculateStreaks();
    await _save();
    notifyListeners();
  }

  DailyPlan? getPlanForDate(DateTime date) => _plans[_dateKey(date)];

  List<DailyPlan> getRecentPlans({int limit = 30}) {
    final plans = _plans.values.toList()
      ..sort((left, right) => right.date.compareTo(left.date));
    return plans.take(limit).toList();
  }

  void _rebuildPlansForCurrentContent() {
    final devotional = _content.devotional;
    if (devotional == null) {
      throw StateError(_content.error ?? 'Localized content is unavailable.');
    }

    final previous = Map<String, DailyPlan>.from(_plans);
    _plans.clear();
    for (final oldPlan in previous.values) {
      final plan = _createPlan(oldPlan.date, devotional);
      _copyCompletion(oldPlan, plan);
      _plans[plan.id] = plan;
    }

    final now = DateTime.now();
    final todayKey = _dateKey(now);
    _todaysPlan = _plans.putIfAbsent(
      todayKey,
      () => _createPlan(now, devotional),
    );
  }

  DailyPlan _createPlan(DateTime sourceDate, DevotionalCollection devotional) {
    final date = DateTime(sourceDate.year, sourceDate.month, sourceDate.day);
    final dateKey = _dateKey(date);
    final day = devotional.days[_dayOfYear(date) % devotional.days.length];
    final verse = _bible.verseByCanonicalReference(day.reference);

    return DailyPlan(
      id: dateKey,
      date: date,
      theme: day.title,
      steps: [
        PlanStep(
          id: '$dateKey:verse',
          type: PlanStepType.verse,
          title: 'verse',
          content: verse?.text ?? '',
          verseReference: verse?.reference ?? day.reference,
          order: 1,
        ),
        PlanStep(
          id: '$dateKey:devotional',
          type: PlanStepType.devotional,
          title: 'devotional',
          content: day.reflection,
          verseReference: verse?.reference ?? day.reference,
          order: 2,
        ),
        PlanStep(
          id: '$dateKey:connection',
          type: PlanStepType.connection,
          title: 'practice',
          content: day.practice,
          order: 3,
        ),
        PlanStep(
          id: '$dateKey:prayer',
          type: PlanStepType.prayer,
          title: 'prayer',
          content: day.prayer,
          order: 4,
        ),
      ],
    );
  }

  static void _copyCompletion(DailyPlan oldPlan, DailyPlan newPlan) {
    for (final step in newPlan.steps) {
      final previous = oldPlan.steps
          .where((item) => item.id == step.id)
          .firstOrNull;
      if (previous == null) continue;
      step
        ..isCompleted = previous.isCompleted
        ..completedAt = previous.completedAt;
    }
    newPlan
      ..isCompleted =
          oldPlan.isCompleted || newPlan.completedSteps == newPlan.totalSteps
      ..completedAt = oldPlan.completedAt;
  }

  void _updatePlanCompletion(DailyPlan plan) {
    if (plan.completedSteps != plan.totalSteps) return;
    plan
      ..isCompleted = true
      ..completedAt = DateTime.now();
    if (!_completedPlanDates.contains(plan.id)) {
      _completedPlanDates.add(plan.id);
    }
    _calculateStreaks();
  }

  void _calculateStreaks() {
    final ordinals =
        _completedPlanDates
            .map(DateTime.tryParse)
            .whereType<DateTime>()
            .map((date) => DateTime.utc(date.year, date.month, date.day))
            .toSet()
            .toList()
          ..sort();
    if (ordinals.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      return;
    }

    var run = 1;
    var longest = 1;
    for (var index = 1; index < ordinals.length; index++) {
      run = ordinals[index].difference(ordinals[index - 1]).inDays == 1
          ? run + 1
          : 1;
      if (run > longest) longest = run;
    }
    _longestStreak = longest;

    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    if (today.difference(ordinals.last).inDays > 1) {
      _currentStreak = 0;
      return;
    }

    var current = 1;
    for (var index = ordinals.length - 1; index > 0; index--) {
      if (ordinals[index].difference(ordinals[index - 1]).inDays != 1) break;
      current++;
    }
    _currentStreak = current;
  }

  void _refreshLocalizedPlans() {
    if (_content.devotional == null) return;
    _rebuildPlansForCurrentContent();
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.write(
      _plansKey,
      _plans.values.map((plan) => plan.toJson()).toList(),
    );
    await _storage.write(_completedDatesKey, _completedPlanDates);
  }

  @override
  void dispose() {
    _content.removeListener(_refreshLocalizedPlans);
    _bible.removeListener(_refreshLocalizedPlans);
    super.dispose();
  }

  static int _dayOfYear(DateTime date) => DateTime(
    date.year,
    date.month,
    date.day,
  ).difference(DateTime(date.year)).inDays;

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
