import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/lent/models/lent_day.dart';

class LentRepository extends ChangeNotifier {
  LentRepository(this._storage);

  static const _storageKey = 'lentProgress';
  final StorageService _storage;
  LentCollection? _collection;
  Map<int, bool> _dayProgress = {};
  DateTime? _startedAt;
  DateTime? _completedAt;
  String? _error;

  LentCollection? get collection => _collection;
  Map<int, bool> get dayProgress => Map.unmodifiable(_dayProgress);
  DateTime? get startedAt => _startedAt;
  DateTime? get completedAt => _completedAt;
  bool get isStarted => _startedAt != null;
  bool get isCompleted => _completedAt != null;
  int get totalDays => _collection?.days.length ?? 0;
  int get completedDays => _dayProgress.values.where((done) => done).length;
  double get progress => totalDays == 0 ? 0 : completedDays / totalDays;
  String? get error => _error;

  Future<void> init() async {
    if (!await loadLocale(_storage.userPreferences.locale)) {
      throw StateError(_error ?? 'Lent content is unavailable.');
    }
  }

  Future<bool> loadLocale(String locale) async {
    try {
      final raw = await rootBundle.loadString('assets/lent/$locale.json');
      final decoded = jsonDecode(raw);
      final Map<String, dynamic> normalized;
      if (decoded is List) {
        normalized = {
          'locale': locale,
          'title': 'Lent',
          'days': [
            for (var index = 0; index < decoded.length; index++)
              {
                ...Map<String, dynamic>.from(decoded[index] as Map),
                'id': index + 1,
                'dailyVerse': decoded[index]['daily_verse'],
                'dailyVerseQuote': decoded[index]['daily_verse_quote'],
                'dailyPrayer': decoded[index]['daily_prayer'],
                'roundedMinutes': decoded[index]['rounded_minutes'],
              },
          ],
        };
      } else {
        normalized = Map<String, dynamic>.from(decoded as Map);
      }
      final content = LentCollection.fromJson(normalized);
      if (content.locale != locale) {
        throw FormatException(
          'Expected locale $locale, found ${content.locale}.',
        );
      }
      _collection = content;

      // Load saved progress
      final progress =
          _storage.read<Map<dynamic, dynamic>>(_storageKey) ?? const {};
      _dayProgress = {};
      _startedAt = null;
      _completedAt = null;
      _restoreProgress(progress['journey'] ?? progress[locale]);

      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _error = 'Lent content could not be loaded: $error';
      notifyListeners();
      return false;
    }
  }

  void _restoreProgress(Object? raw) {
    if (raw is! Map) return;
    _dayProgress = <int, bool>{};
    final rawDays = raw['days'];
    if (rawDays is Map) {
      for (final entry in rawDays.entries) {
        final day = int.tryParse(entry.key.toString());
        if (day != null && entry.value == true) _dayProgress[day] = true;
      }
    }
    _startedAt = DateTime.tryParse(raw['startedAt'] as String? ?? '');
    _completedAt = DateTime.tryParse(raw['completedAt'] as String? ?? '');
  }

  Future<void> completeDay(int day) async {
    if (_collection == null || day < 1 || day > totalDays) return;
    if (!isStarted) {
      _startedAt = DateTime.now();
    }

    _dayProgress[day] = true;
    if (_dayProgress.length == totalDays) {
      _completedAt = DateTime.now();
    }
    await _save();
  }

  Future<void> uncompleteDay(int day) async {
    if (_collection == null || day < 1 || day > totalDays) return;
    _dayProgress.remove(day);
    _completedAt = null;
    await _save();
  }

  Future<void> resetProgress() async {
    _dayProgress = {};
    _startedAt = null;
    _completedAt = null;
    await _storage.delete(_storageKey);
    notifyListeners();
  }

  LentDay? getDay(int day) {
    if (_collection == null || day < 1 || day > totalDays) return null;
    return _collection!.days.firstWhere((d) => d.id == day);
  }

  Future<void> _save() async {
    await _storage.write(_storageKey, {
      'journey': {
        'startedAt': _startedAt?.toIso8601String(),
        'completedAt': _completedAt?.toIso8601String(),
        'days': {
          for (final entry in _dayProgress.entries)
            entry.key.toString(): entry.value,
        },
      },
    });
    notifyListeners();
  }
}
