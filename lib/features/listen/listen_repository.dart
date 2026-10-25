import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/listen/models/listen_day.dart';
import 'package:bible_path/features/listen/models/listen_plan.dart';

class ListenRepository extends ChangeNotifier {
  ListenRepository(this._storage, this._content) {
    _content.addListener(_refreshCatalog);
  }

  static const _storageKey = 'listenProgress';
  final StorageService _storage;
  final ContentRepository _content;
  List<ListenPlan> _plans = [];

  List<ListenPlan> get availablePlans => List.unmodifiable(_plans);
  List<ListenPlan> get myPlans =>
      _plans.where((plan) => plan.isStarted).toList(growable: false);
  bool get isLoading => false;

  Future<void> init() async {
    await _loadPlanForLocale(_content.devotional?.locale ?? 'en');
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
    if (!plan.isStarted || day < 1 || day > plan.totalDays) return;

    final progress = {...plan.dayProgress, day: true};
    plan = plan.copyWith(
      dayProgress: progress,
      completedAt: progress.length == plan.totalDays ? DateTime.now() : null,
    );
    _plans[index] = plan;
    await _save();
  }

  Future<void> uncompleteDay(String planId, int day) async {
    final index = _plans.indexWhere((plan) => plan.id == planId);
    if (index < 0) return;
    var plan = _plans[index];
    if (!plan.isStarted || day < 1 || day > plan.totalDays) return;

    final progress = {...plan.dayProgress};
    progress.remove(day);
    plan = plan.copyWith(dayProgress: progress, clearCompletedAt: true);
    _plans[index] = plan;
    await _save();
  }

  Future<void> removePlan(String planId) async {
    final index = _plans.indexWhere((plan) => plan.id == planId);
    if (index < 0) return;
    final plan = _plans[index];
    _plans[index] = ListenPlan(
      id: plan.id,
      locale: plan.locale,
      title: plan.title,
      description: plan.description,
      days: plan.days,
    );
    await _save();
  }

  ListenPlan? getPlan(String id) {
    for (final plan in _plans) {
      if (plan.id == id) return plan;
    }
    return null;
  }

  ListenDay? getDay(String planId, int day) {
    final plan = getPlan(planId);
    if (plan == null) return null;
    for (final d in plan.days) {
      if (d.day == day) return d;
    }
    return null;
  }

  Future<void> _loadPlanForLocale(String locale) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/json/listen/listen-$locale.json',
      );
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final plan = ListenPlan(
          id: 'listen-scripture',
          locale: locale,
          title: decoded['title'] as String,
          description: decoded['description'] as String,
          days:
              (decoded['days'] as List)
                  .map(
                    (item) => ListenDay.fromJson(
                      Map<String, dynamic>.from(item as Map),
                    ),
                  )
                  .toList(),
        );
        final progress =
            _storage.read<Map<dynamic, dynamic>>(_storageKey) ?? const {};
        _plans = [_restore(plan, progress[plan.id])];
        notifyListeners();
        return;
      }
      final List<ListenPlan> plans = [];

      // Group by category
      final Map<String, List<dynamic>> grouped = {};
      for (final item in decoded) {
        final category = item['category'] as String? ?? 'uncategorized';
        grouped.putIfAbsent(category, () => []).add(item);
      }

      // Create a plan for each category
      for (final entry in grouped.entries) {
        final category = entry.key;
        final items = entry.value;

        final days =
            items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListenDay(
                day: index + 1,
                title: item['title'] as String,
                passage: item['key'] as String,
                durationSeconds: _parseDuration(item['duration'] as Map?),
                description: item['description'] as String?,
              );
            }).toList();

        final plan = ListenPlan(
          id: 'listen_${category}_$locale',
          locale: locale,
          title: _categoryTitle(category),
          description: _categoryDescription(category),
          days: days,
        );
        plans.add(plan);
      }

      final progress =
          _storage.read<Map<dynamic, dynamic>>(_storageKey) ?? const {};
      _plans = plans.map((plan) => _restore(plan, progress[plan.id])).toList();
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to load listen plans for locale $locale: $error');
      _plans = [];
      notifyListeners();
    }
  }

  int _parseDuration(Map? duration) {
    if (duration == null) return 0;
    final minutes = (duration['minutes'] as num?)?.toInt() ?? 0;
    final seconds = (duration['seconds'] as num?)?.toInt() ?? 0;
    return minutes * 60 + seconds;
  }

  String _categoryTitle(String category) {
    switch (category) {
      case 'tales_of_bible':
        return 'Tales of the Bible';
      case 'bible_retold':
        return 'Bible Retold';
      case 'bible_for_kids':
        return 'Bible for Kids';
      case 'real_life_lessons':
        return 'Real Life Lessons';
      case 'guided_reflection':
        return 'Guided Reflection';
      case 'sleeptime_reflection':
        return 'Sleeptime Reflection';
      default:
        return category
            .split('_')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' ');
    }
  }

  String _categoryDescription(String category) {
    switch (category) {
      case 'tales_of_bible':
        return 'Classic Bible stories narrated for reflection';
      case 'bible_retold':
        return 'Familiar Bible narratives retold for today';
      case 'bible_for_kids':
        return 'Bible stories adapted for children';
      case 'real_life_lessons':
        return 'Modern stories inspired by biblical principles';
      case 'guided_reflection':
        return 'Guided meditations for spiritual growth';
      case 'sleeptime_reflection':
        return 'Peaceful bedtime reflections for restful sleep';
      default:
        return 'Audio content for your listening journey';
    }
  }

  ListenPlan _restore(ListenPlan plan, Object? raw) {
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
    _loadPlanForLocale(_content.devotional?.locale ?? 'en');
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
