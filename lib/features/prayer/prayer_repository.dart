import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:bible_path/core/services/storage_service.dart';

class Prayer {
  Prayer({
    String? id,
    required this.text,
    DateTime? createdAt,
    this.category,
    this.isArchived = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String text;
  final DateTime createdAt;
  final String? category;
  final bool isArchived;

  // Compatibility while the dashboard is migrated to the private journal.
  String get authorName => 'You';
  int get amenCount => 0;
  bool get isOwn => true;
  bool get hasAmened => false;

  Prayer copyWith({String? text, String? category, bool? isArchived}) {
    return Prayer(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt,
      category: category ?? this.category,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  factory Prayer.fromJson(Map<dynamic, dynamic> json) {
    return Prayer(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] as String?,
      isArchived: json['isArchived'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'category': category,
    'isArchived': isArchived,
  };
}

class PrayerRepository extends ChangeNotifier {
  PrayerRepository(this._storage);

  static const _storageKey = 'prayers';
  final StorageService _storage;
  final List<Prayer> _prayers = [];

  List<Prayer> get prayers => List.unmodifiable(_prayers);
  List<Prayer> get prayerWall =>
      _prayers.where((prayer) => !prayer.isArchived).toList();
  List<Prayer> get myPrayers => List.unmodifiable(_prayers);
  List<Prayer> get upcomingPrayers => const [];
  bool get isLoading => false;

  Future<void> init() async {
    final stored = _storage.read<List<dynamic>>(_storageKey) ?? const [];
    _prayers
      ..clear()
      ..addAll(stored.whereType<Map>().map(Prayer.fromJson));
    _sort();
    notifyListeners();
  }

  Future<void> addPrayer(
    String text, {
    String authorName = 'Me',
    String? category,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    _prayers.add(Prayer(text: normalized, category: category));
    _sort();
    await _save();
  }

  Future<void> updatePrayer(
    String prayerId, {
    required String text,
    String? category,
  }) async {
    final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
    final normalized = text.trim();
    if (index < 0 || normalized.isEmpty) return;
    _prayers[index] = _prayers[index].copyWith(
      text: normalized,
      category: category,
    );
    await _save();
  }

  Future<void> setArchived(String prayerId, bool archived) async {
    final index = _prayers.indexWhere((prayer) => prayer.id == prayerId);
    if (index < 0) return;
    _prayers[index] = _prayers[index].copyWith(isArchived: archived);
    await _save();
  }

  Future<void> removePrayer(String prayerId) async {
    _prayers.removeWhere((prayer) => prayer.id == prayerId);
    await _save();
  }

  Future<void> amenPrayer(String prayerId) async {}

  Prayer? getPrayer(String id) {
    for (final prayer in _prayers) {
      if (prayer.id == id) return prayer;
    }
    return null;
  }

  void _sort() => _prayers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> _save() async {
    notifyListeners();
    await _storage.write(
      _storageKey,
      _prayers.map((prayer) => prayer.toJson()).toList(),
    );
  }
}
