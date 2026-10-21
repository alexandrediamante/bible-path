import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:bible_path/core/services/storage_service.dart';

class DevotionalDay {
  const DevotionalDay({
    required this.number,
    required this.title,
    required this.reference,
    required this.reflection,
    required this.practice,
    required this.prayer,
  });

  final int number;
  final String title;
  final String reference;
  final String reflection;
  final String practice;
  final String prayer;

  factory DevotionalDay.fromJson(Map<String, dynamic> json) {
    return DevotionalDay(
      number: (json['number'] as num).toInt(),
      title: json['title'] as String,
      reference: json['reference'] as String,
      reflection: json['reflection'] as String,
      practice: json['practice'] as String,
      prayer: json['prayer'] as String,
    );
  }
}

class DevotionalCollection {
  const DevotionalCollection({
    required this.id,
    required this.locale,
    required this.title,
    required this.days,
  });

  final String id;
  final String locale;
  final String title;
  final List<DevotionalDay> days;

  factory DevotionalCollection.fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List)
        .whereType<Map>()
        .map((item) => DevotionalDay.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    if (days.length != 7) {
      throw const FormatException('A devotional must contain seven days.');
    }
    return DevotionalCollection(
      id: json['id'] as String,
      locale: json['locale'] as String,
      title: json['title'] as String,
      days: days,
    );
  }
}

class ContentRepository extends ChangeNotifier {
  ContentRepository(this._storage);

  final StorageService _storage;
  DevotionalCollection? _devotional;
  String? _error;

  DevotionalCollection? get devotional => _devotional;
  String? get error => _error;

  Future<void> init() async {
    if (!await loadLocale(_storage.userPreferences.locale)) {
      throw StateError(_error ?? 'Localized content is unavailable.');
    }
  }

  Future<bool> loadLocale(String locale) async {
    try {
      final raw = await rootBundle.loadString(
        'assets/content/devotional-$locale.json',
      );
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final content = DevotionalCollection.fromJson(decoded);
      if (content.locale != locale) {
        throw FormatException(
          'Expected locale $locale, found ${content.locale}.',
        );
      }
      _devotional = content;
      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _error = 'Localized devotional content could not be loaded: $error';
      notifyListeners();
      return false;
    }
  }
}
