import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/advent/advent_models.dart';

class AdventRepository extends ChangeNotifier {
  AdventRepository(this._storage);

  final StorageService _storage;
  static const String _boxName = 'advent_calendar';

  AdventCalendar? _calendar;
  bool _isLoading = false;
  String? _error;
  String _currentLocale = 'en';

  AdventCalendar? get calendar => _calendar;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentLocale => _currentLocale;

  /// Initialize the repository and load Advent calendar for the current locale
  Future<void> init({String? locale}) async {
    _currentLocale = locale ?? _storage.userPreferences.locale;
    await _loadCalendar();
  }

  /// Load calendar from assets, with Hive cache fallback
  Future<void> _loadCalendar() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load from Hive cache first
      final box = await Hive.openBox<String>(_boxName);
      final cachedJson = box.get(_currentLocale);

      if (cachedJson != null) {
        final Map<String, dynamic> json = jsonDecode(cachedJson);
        _calendar = AdventCalendar.fromJson(json, _currentLocale);
        _isLoading = false;
        notifyListeners();

        // Still try to fetch fresh from assets in background
        _fetchFromAssets(box);
        return;
      }

      // No cache, load from assets
      await _fetchFromAssets(box);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch calendar from assets and cache it
  Future<void> _fetchFromAssets(Box<String> box) async {
    try {
      final assetPath = 'assets/json/advent/advent_$_currentLocale.json';
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Cache in Hive
      await box.put(_currentLocale, jsonString);

      _calendar = AdventCalendar.fromJson(json, _currentLocale);
      _error = null;
    } catch (e) {
      _error = 'Failed to load Advent calendar: $e';
      if (kDebugMode) {
        print('AdventRepository error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change locale and reload calendar
  Future<void> changeLocale(String locale) async {
    if (locale == _currentLocale) return;
    _currentLocale = locale;
    await _loadCalendar();
  }

  /// Get a specific day
  AdventDay? getDay(int day) {
    return _calendar?.getDay(day);
  }

  /// Get all days up to a specific day (for unlocked days)
  List<AdventDay> getUnlockedDays() {
    if (_calendar == null) return [];
    final now = DateTime.now();
    if (now.month != 12) return []; // Only December
    final currentDay = now.day.clamp(1, 25);
    return _calendar!.getDaysUpTo(currentDay);
  }

  /// Get current day (if in Advent season)
  AdventDay? getCurrentDay() {
    return _calendar?.getCurrentDay();
  }

  /// Get all 25 days
  List<AdventDay> getAllDays() {
    return _calendar?.days ?? [];
  }

  /// Check if a day is unlocked (current or past day in December)
  bool isDayUnlocked(int day) {
    final now = DateTime.now();
    if (now.month != 12) return false;
    return day <= now.day && day <= 25;
  }

  /// Check if a day is today
  bool isToday(int day) {
    final now = DateTime.now();
    return now.month == 12 && now.day == day && day <= 25;
  }

  /// Check if Advent season has started
  bool get isAdventSeason {
    final now = DateTime.now();
    return now.month == 12 && now.day <= 25;
  }

  /// Get days remaining until Advent starts (if before Dec 1)
  int get daysUntilAdvent {
    final now = DateTime.now();
    final thisYearAdvent = DateTime(now.year, 12, 1);
    if (now.isBefore(thisYearAdvent)) {
      return thisYearAdvent.difference(now).inDays;
    }
    // If past Dec 25, calculate for next year
    final nextYearAdvent = DateTime(now.year + 1, 12, 1);
    return nextYearAdvent.difference(now).inDays;
  }
}
