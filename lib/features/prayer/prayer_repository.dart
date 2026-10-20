import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Prayer {
  final String id;
  final String text;
  final String authorName;
  final DateTime createdAt;
  final int amenCount;
  final bool isOwn;
  final String? category;
  bool hasAmened;

  Prayer({
    String? id,
    required this.text,
    required this.authorName,
    DateTime? createdAt,
    this.amenCount = 0,
    this.isOwn = false,
    this.category,
    this.hasAmened = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
}

class PrayerRepository extends ChangeNotifier {
  final List<Prayer> _prayerWall = [];
  final List<Prayer> _myPrayers = [];
  final List<Prayer> _upcomingPrayers = [];
  bool _isLoading = false;

  List<Prayer> get prayerWall => _prayerWall;
  List<Prayer> get myPrayers => _myPrayers;
  List<Prayer> get upcomingPrayers => _upcomingPrayers;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _generateSamplePrayers();

    _isLoading = false;
    notifyListeners();
  }

  void _generateSamplePrayers() {
    final samplePrayers = [
      Prayer(
        text: 'Lord, guide us with Your wisdom, fill our hearts with peace, and strengthen us to face this day with faith and love. Amen.',
        authorName: 'Sarah M.',
        category: 'Guidance',
        amenCount: 42,
      ),
      Prayer(
        text: 'Heavenly Father, thank You for the gift of this new day. Help me to see Your beauty in every moment and to be a blessing to others.',
        authorName: 'James K.',
        category: 'Gratitude',
        amenCount: 28,
      ),
      Prayer(
        text: 'Dear God, I pray for healing for my mother who is struggling with illness. Please grant her comfort and strength.',
        authorName: 'Anonymous',
        category: 'Healing',
        amenCount: 56,
      ),
      Prayer(
        text: 'Lord, give me the courage to forgive those who have hurt me, just as You have forgiven me. Soften my heart.',
        authorName: 'Michael R.',
        category: 'Forgiveness',
        amenCount: 31,
      ),
      Prayer(
        text: 'Father, I lift up all those who are feeling lonely today. May they feel Your presence and know they are never alone.',
        authorName: 'Emily T.',
        category: 'Comfort',
        amenCount: 39,
      ),
    ];

    _prayerWall.addAll(samplePrayers);
  }

  Future<void> addPrayer(String text, {String authorName = 'Me', String? category}) async {
    final prayer = Prayer(
      text: text,
      authorName: authorName,
      category: category,
      isOwn: true,
    );

    _myPrayers.insert(0, prayer);
    _upcomingPrayers.insert(0, prayer);
    notifyListeners();

    // Simulate publishing after a delay
    Future.delayed(const Duration(minutes: 5), () {
      _upcomingPrayers.removeWhere((p) => p.id == prayer.id);
      _prayerWall.insert(0, prayer.copyWith(isOwn: true));
      notifyListeners();
    });
  }

  Future<void> amenPrayer(String prayerId) async {
    final index = _prayerWall.indexWhere((p) => p.id == prayerId);
    if (index == -1) return;

    final prayer = _prayerWall[index];
    if (prayer.hasAmened) return;

    _prayerWall[index] = prayer.copyWith(
      amenCount: prayer.amenCount + 1,
      hasAmened: true,
    );
    notifyListeners();
  }

  Future<void> removePrayer(String prayerId) async {
    _myPrayers.removeWhere((p) => p.id == prayerId);
    _upcomingPrayers.removeWhere((p) => p.id == prayerId);
    _prayerWall.removeWhere((p) => p.id == prayerId);
    notifyListeners();
  }

  Prayer? getPrayer(String id) {
    return _prayerWall.firstWhere(
      (p) => p.id == id,
      orElse: () => _myPrayers.firstWhere(
        (p) => p.id == id,
        orElse: () => _upcomingPrayers.firstWhere(
          (p) => p.id == id,
          orElse: () => throw StateError('Prayer not found'),
        ),
      ),
    );
  }
}

extension PrayerCopy on Prayer {
  Prayer copyWith({
    String? text,
    String? authorName,
    int? amenCount,
    bool? hasAmened,
    String? category,
  }) {
    return Prayer(
      id: id,
      text: text ?? this.text,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt,
      amenCount: amenCount ?? this.amenCount,
      isOwn: isOwn,
      category: category ?? this.category,
      hasAmened: hasAmened ?? this.hasAmened,
    );
  }
}