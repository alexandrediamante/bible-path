import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/reading_plan/models/reading_plan.dart';

class ReadingPlanRepository extends ChangeNotifier {
  ReadingPlanRepository(this._storage) {
    _content.addListener(_refreshCatalog);
  }

  static const _storageKey = 'readingPlanProgress';
  final StorageService _storage;
  late final ContentRepository _content = ContentRepository(_storage);
  ReadingPlansData? _data;
  String? _error;

  ReadingPlansData? get data => _data;
  List<ReadingPlanCategoryData> get categories => _data?.categories ?? [];
  List<ReadingPlan> get allPlans =>
      _data?.categories.expand((cat) => cat.plans).toList(growable: false) ??
      [];
  List<ReadingPlan> get myPlans =>
      allPlans.where((plan) => plan.isStarted).toList(growable: false);
  String? get error => _error;
  bool get isLoading => _data == null;

  String get currentLocale => _storage.userPreferences.locale;

  Future<void> init() async {
    if (!await loadLocale(_storage.userPreferences.locale)) {
      throw StateError(_error ?? 'Reading plans content is unavailable.');
    }
  }

  Future<bool> loadLocale(String locale) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/json/read/read-$locale.json',
      );
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final content = _parsePlans(decoded);
      if (content.locale != locale) {
        throw FormatException(
          'Expected locale $locale, found ${content.locale}.',
        );
      }

      // Load saved progress
      final progress =
          _storage.read<Map<dynamic, dynamic>>(_storageKey) ?? const {};
      _restoreProgress(content, progress[content.id] ?? progress);

      _data = content;
      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _error = 'Reading plans content could not be loaded: $error';
      notifyListeners();
      return false;
    }
  }

  void _restoreProgress(ReadingPlansData data, Object? raw) {
    if (raw is! Map) return;
    for (final category in data.categories) {
      for (final plan in category.plans) {
        final planProgress = raw[plan.id];
        if (planProgress is Map) {
          final days = <int, bool>{};
          final rawDays = planProgress['days'];
          if (rawDays is Map) {
            for (final entry in rawDays.entries) {
              final day = int.tryParse(entry.key.toString());
              if (day != null && entry.value == true) days[day] = true;
            }
          }
          final index = category.plans.indexWhere((p) => p.id == plan.id);
          if (index >= 0) {
            category.plans[index] = plan.copyWith(
              startedAt: DateTime.tryParse(
                planProgress['startedAt'] as String? ?? '',
              ),
              completedAt: DateTime.tryParse(
                planProgress['completedAt'] as String? ?? '',
              ),
              dayProgress: days,
            );
          }
        }
      }
    }
  }

  Future<void> startPlan(String planId) async {
    for (final category in categories) {
      final index = category.plans.indexWhere((plan) => plan.id == planId);
      if (index >= 0) {
        final plan = category.plans[index];
        if (plan.isStarted) return;
        category.plans[index] = plan.copyWith(startedAt: DateTime.now());
        await _save();
        return;
      }
    }
  }

  Future<void> completeDay(String planId, int day) async {
    for (final category in categories) {
      final index = category.plans.indexWhere((plan) => plan.id == planId);
      if (index >= 0) {
        var plan = category.plans[index];
        if (!plan.isStarted || day < 1 || day > plan.totalDays) return;

        final progress = {...plan.dayProgress, day: true};
        plan = plan.copyWith(
          dayProgress: progress,
          completedAt:
              progress.length == plan.totalDays ? DateTime.now() : null,
        );
        category.plans[index] = plan;
        await _save();
        return;
      }
    }
  }

  Future<void> uncompleteDay(String planId, int day) async {
    for (final category in categories) {
      final index = category.plans.indexWhere((plan) => plan.id == planId);
      if (index >= 0) {
        var plan = category.plans[index];
        if (!plan.isStarted || day < 1 || day > plan.totalDays) return;

        final progress = {...plan.dayProgress};
        progress.remove(day);
        plan = plan.copyWith(dayProgress: progress, clearCompletedAt: true);
        category.plans[index] = plan;
        await _save();
        return;
      }
    }
  }

  Future<void> removePlan(String planId) async {
    for (final category in categories) {
      final index = category.plans.indexWhere((plan) => plan.id == planId);
      if (index >= 0) {
        final plan = category.plans[index];
        category.plans[index] = ReadingPlan(
          id: plan.id,
          locale: plan.locale,
          title: plan.title,
          description: plan.description,
          durationDays: plan.durationDays,
          book: plan.book,
          startChapter: plan.startChapter,
          endChapter: plan.endChapter,
          chapters: plan.chapters,
          readings: plan.readings,
        );
        await _save();
        return;
      }
    }
  }

  ReadingPlan? getPlan(String id) {
    for (final category in categories) {
      for (final plan in category.plans) {
        if (plan.id == id) return plan;
      }
    }
    return null;
  }

  ReadingDay? getDay(String planId, int day) {
    final plan = getPlan(planId);
    if (plan == null) return null;
    if (plan.readings != null) {
      for (final d in plan.readings!) {
        if (d.day == day) return d;
      }
    }
    return null;
  }

  ReadingPlansData _parsePlans(Map<String, dynamic> json) {
    final categories =
        (json['categories'] as List)
            .whereType<Map>()
            .map(
              (cat) => _parseCategory(
                Map<String, dynamic>.from(cat),
                json['locale'] as String,
              ),
            )
            .toList();

    return ReadingPlansData(
      id: json['id'] as String,
      locale: json['locale'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      categories: categories,
    );
  }

  ReadingPlanCategoryData _parseCategory(
    Map<String, dynamic> json,
    String locale,
  ) {
    final plans =
        (json['plans'] as List)
            .whereType<Map>()
            .map((item) => _parsePlan(Map<String, dynamic>.from(item), locale))
            .toList();

    return ReadingPlanCategoryData(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      plans: plans,
    );
  }

  ReadingPlan _parsePlan(Map<String, dynamic> json, String locale) {
    final readings =
        (json['readings'] as List?)
            ?.whereType<Map>()
            .map((item) => ReadingDay.fromJson(Map<String, dynamic>.from(item)))
            .toList();

    return ReadingPlan(
      id: json['id'] as String,
      locale: json['locale'] as String? ?? locale,
      title: json['title'] as String,
      description: json['description'] as String,
      durationDays: (json['durationDays'] as num).toInt(),
      book: json['book'] as String?,
      startChapter: (json['startChapter'] as num?)?.toInt(),
      endChapter: (json['endChapter'] as num?)?.toInt(),
      chapters:
          (json['chapters'] as List?)?.map((e) => (e as num).toInt()).toList(),
      readings: readings,
    );
  }

  void _refreshCatalog() {
    _loadPlanForLocale(_storage.userPreferences.locale);
  }

  Future<void> _loadPlanForLocale(String locale) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/json/read/read-$locale.json',
      );
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final content = _parsePlans(decoded);

      final progress =
          _storage.read<Map<dynamic, dynamic>>(_storageKey) ?? const {};
      _restoreProgress(content, progress[content.id] ?? progress);

      _data = content;
      _error = null;
      notifyListeners();
    } catch (error) {
      debugPrint('Failed to load reading plan for locale $locale: $error');
      _error = 'Reading plans content could not be loaded: $error';
      notifyListeners();
    }
  }

  Future<void> _save() async {
    await _storage.write(_storageKey, {
      for (final category in categories)
        for (final plan in category.plans.where((item) => item.isStarted))
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
