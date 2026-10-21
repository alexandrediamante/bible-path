import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bible_path/core/models/user_preferences.dart';

class StorageService extends ChangeNotifier {
  static const _boxName = 'bible_path_web_v1';
  static const _preferencesKey = 'preferences';

  late Box<dynamic> _box;
  UserPreferences _userPreferences = const UserPreferences();

  UserPreferences get userPreferences => _userPreferences;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
    final stored = _box.get(_preferencesKey);
    if (stored is Map) {
      _userPreferences = UserPreferences.fromJson(stored);
    } else {
      await _box.put(_preferencesKey, _userPreferences.toJson());
    }
    notifyListeners();
  }

  T? read<T>(String key) => _box.get(key) as T?;

  Future<void> write(String key, Object? value) async {
    await _box.put(key, value);
    notifyListeners();
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
    notifyListeners();
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    _userPreferences = preferences;
    await _box.put(_preferencesKey, preferences.toJson());
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) =>
      updatePreferences(_userPreferences.copyWith(isDarkMode: isDark));

  Future<void> setLocale(String locale) =>
      updatePreferences(_userPreferences.copyWith(locale: locale));

  Future<void> setTextScale(double scale) =>
      updatePreferences(_userPreferences.copyWith(textScale: scale));

  Future<void> setDailyReminder(String time, bool enabled) => updatePreferences(
    _userPreferences.copyWith(
      dailyReminderTime: time,
      dailyReminderEnabled: enabled,
    ),
  );

  Future<void> dismissReminderForDate(String date) =>
      updatePreferences(_userPreferences.copyWith(lastReminderDate: date));

  Future<void> addFavoriteVerse(String verseKey) async {
    if (_userPreferences.favoriteVerses.contains(verseKey)) return;
    await updatePreferences(
      _userPreferences.copyWith(
        favoriteVerses: [..._userPreferences.favoriteVerses, verseKey],
      ),
    );
  }

  Future<void> removeFavoriteVerse(String verseKey) => updatePreferences(
    _userPreferences.copyWith(
      favoriteVerses: _userPreferences.favoriteVerses
          .where((key) => key != verseKey)
          .toList(),
    ),
  );

  Future<void> setPreferredBibleVersion(String version) => updatePreferences(
    _userPreferences.copyWith(preferredBibleVersion: version),
  );

  Future<void> setAiAuthToken(String token) =>
      updatePreferences(_userPreferences.copyWith(aiAuthToken: token.trim()));

  Future<void> clearAiAuthToken() =>
      updatePreferences(_userPreferences.copyWith(clearAiAuthToken: true));

  Map<String, dynamic> exportData() {
    final data = <String, dynamic>{'schemaVersion': 1};
    for (final key in _box.keys.whereType<String>()) {
      if (key == _preferencesKey) {
        data[key] = _userPreferences.toJson(includeSecrets: false);
      } else {
        data[key] = _box.get(key);
      }
    }
    return data;
  }

  Future<void> reset() async {
    await _box.clear();
    _userPreferences = const UserPreferences();
    await _box.put(_preferencesKey, _userPreferences.toJson());
    notifyListeners();
  }
}
