import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/holy_calendar/holy_calendar_landmarks.dart';
import 'package:bible_path/features/holy_calendar/holy_calendar_models.dart';

class HolyCalendarRepository extends ChangeNotifier {
  static const _boxName = 'holy_calendar_cache';
  static const _cacheExpiryDays = 30;

  final StorageService _storage;
  Box<dynamic>? _box;
  HolyCalendar? _calendar;
  LiturgicalTradition _selectedTradition = LiturgicalTradition.catholic;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastLoaded;

  HolyCalendarRepository(this._storage);

  HolyCalendar? get calendar => _calendar;
  LiturgicalTradition get selectedTradition => _selectedTradition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _calendar != null;
  DateTime? get lastLoaded => _lastLoaded;

  Future<void> init({LiturgicalTradition? tradition, String? locale}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _box ??= await Hive.openBox<dynamic>(_boxName);

      final targetTradition = tradition ?? _selectedTradition;
      final targetLocale = locale ?? _storage.userPreferences.locale;

      // Try to load from cache first
      final cached = await _loadFromCache(targetTradition, targetLocale);
      if (cached != null) {
        _calendar = cached;
        _selectedTradition = targetTradition;
        _isLoading = false;
        _lastLoaded = DateTime.now();
        notifyListeners();
        return;
      }

      _calendar = buildHolyCalendarLandmarks(
        year: DateTime.now().year,
        tradition: targetTradition,
        locale: targetLocale,
      );
      await _saveToCache(targetTradition, targetLocale);
      _selectedTradition = targetTradition;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<HolyCalendar?> _loadFromCache(
    LiturgicalTradition tradition,
    String locale,
  ) async {
    if (_box == null) return null;

    final cacheKey = _cacheKey(tradition, locale);
    final cachedData = _box!.get(cacheKey);
    final cachedTimestamp = _box!.get('${cacheKey}_timestamp');

    if (cachedData != null && cachedTimestamp != null) {
      final timestamp = DateTime.parse(cachedTimestamp as String);
      if (DateTime.now().difference(timestamp).inDays < _cacheExpiryDays) {
        return HolyCalendar.fromJson(
          cachedData as Map<String, dynamic>,
          tradition,
          locale,
        );
      }
    }
    return null;
  }

  Future<void> _saveToCache(
    LiturgicalTradition tradition,
    String locale,
  ) async {
    if (_box == null || _calendar == null) return;

    final cacheKey = _cacheKey(tradition, locale);
    await _box!.put(cacheKey, _calendar!.toJson());
    await _box!.put('${cacheKey}_timestamp', DateTime.now().toIso8601String());
    _lastLoaded = DateTime.now();
  }

  Future<void> changeTradition(
    LiturgicalTradition tradition, {
    String? locale,
  }) async {
    if (tradition == _selectedTradition && locale == null) return;
    await init(tradition: tradition, locale: locale);
  }

  HolyCalendarDay? getDay(String date) => _calendar?.getDay(date);

  HolyCalendarDay? getToday() => _calendar?.getToday();

  List<HolyCalendarDay> getDaysForSeason(String season) =>
      _calendar?.getDaysForSeason(season) ?? [];

  List<HolyCalendarDay> getDaysForMonth(int month) =>
      _calendar?.getDaysForMonth(month) ?? [];

  List<HolyCalendarDay> getUpcomingDays(int count) {
    if (_calendar == null) return [];
    final today = DateTime.now();
    final todayStr = _dateToString(today);
    final futureDays =
        _calendar!.days
            .where((d) => d.date.compareTo(todayStr) >= 0)
            .take(count)
            .toList();
    return futureDays;
  }

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<String> getSeasons() {
    if (_calendar == null) return [];
    return _calendar!.days.map((d) => d.season).toSet().toList();
  }

  Future<void> refresh({String? locale}) async {
    final targetLocale = locale ?? _storage.userPreferences.locale;
    final cacheKey = _cacheKey(_selectedTradition, targetLocale);
    await _box?.delete(cacheKey);
    await _box?.delete('${cacheKey}_timestamp');
    _lastLoaded = null;
    await init(tradition: _selectedTradition, locale: targetLocale);
  }

  String _cacheKey(LiturgicalTradition tradition, String locale) =>
      '${tradition.name}_${locale}_${DateTime.now().year}';

  void clearCache() {
    _box?.clear();
    _calendar = null;
    _lastLoaded = null;
  }

  @override
  void dispose() {
    _box = null;
    _calendar = null;
    super.dispose();
  }
}
