import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/models/user_preferences.dart';

class StorageService extends ChangeNotifier {
  final SharedPreferences _prefs;
  late Box<UserPreferences> _preferencesBox;
  UserPreferences? _userPreferences;

  StorageService(this._prefs);

  UserPreferences? get userPreferences => _userPreferences;

  Future<void> init() async {
    _preferencesBox = await Hive.openBox<UserPreferences>('user_preferences');
    _userPreferences = _preferencesBox.get('user_preferences') ?? UserPreferences();
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    _userPreferences = preferences;
    await _preferencesBox.put('user_preferences', preferences);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(isDarkMode: isDark);
      await updatePreferences(updated);
    }
  }

  Future<void> setLocale(String locale) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(locale: locale);
      await updatePreferences(updated);
    }
  }

  Future<void> setTextScale(double scale) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(textScale: scale);
      await updatePreferences(updated);
    }
  }

  Future<void> setFontFamily(String fontFamily) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(fontFamily: fontFamily);
      await updatePreferences(updated);
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(notificationsEnabled: enabled);
      await updatePreferences(updated);
    }
  }

  Future<void> setDailyReminder(String time, bool enabled) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(
        dailyReminderTime: time,
        dailyReminderEnabled: enabled,
      );
      await updatePreferences(updated);
    }
  }

  Future<void> addFavoriteVerse(String verseKey) async {
    if (_userPreferences != null) {
      final favorites = List<String>.from(_userPreferences!.favoriteVerses);
      if (!favorites.contains(verseKey)) {
        favorites.add(verseKey);
        final updated = _userPreferences!.copyWith(favoriteVerses: favorites);
        await updatePreferences(updated);
      }
    }
  }

  Future<void> removeFavoriteVerse(String verseKey) async {
    if (_userPreferences != null) {
      final favorites = List<String>.from(_userPreferences!.favoriteVerses);
      favorites.remove(verseKey);
      final updated = _userPreferences!.copyWith(favoriteVerses: favorites);
      await updatePreferences(updated);
    }
  }

  Future<void> updateStreak(int current, int longest) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(
        currentStreak: current,
        longestStreak: longest > current ? longest : current,
      );
      await updatePreferences(updated);
    }
  }

  Future<void> updatePlanProgress(String planId, dynamic progress) async {
    if (_userPreferences != null) {
      final progressMap = Map<String, dynamic>.from(_userPreferences!.planProgress);
      progressMap[planId] = progress;
      final updated = _userPreferences!.copyWith(planProgress: progressMap);
      await updatePreferences(updated);
    }
  }

  Future<void> setPreferredBibleVersion(String version) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(preferredBibleVersion: version);
      await updatePreferences(updated);
    }
  }

  Future<void> setAudioSettings({bool? autoPlay, double? speed}) async {
    if (_userPreferences != null) {
      final updated = _userPreferences!.copyWith(
        autoPlayAudio: autoPlay ?? _userPreferences!.autoPlayAudio,
        audioPlaybackSpeed: speed ?? _userPreferences!.audioPlaybackSpeed,
      );
      await updatePreferences(updated);
    }
  }

  // In this version, user is always Pro - no license validation needed!
  bool get isProUser => _userPreferences?.isProUser ?? true;
}