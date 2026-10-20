import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum StudyType {
  readingPlan,
  listeningPlan,
  studyPlan,
  challenge,
}

enum StudyDifficulty {
  beginner,
  intermediate,
  advanced,
}

class StudyPlan {
  final String id;
  final String title;
  final String description;
  final StudyType type;
  final StudyDifficulty difficulty;
  final int durationDays;
  final List<String> topics;
  final String? imageUrl;
  final String? audioUrl;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<int, bool> dayProgress; // day -> completed

  StudyPlan({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.durationDays,
    required this.topics,
    this.imageUrl,
    this.audioUrl,
    this.isCompleted = false,
    this.startedAt,
    this.completedAt,
    Map<int, bool>? dayProgress,
  }) : id = id ?? const Uuid().v4(),
       dayProgress = dayProgress ?? {};

  int get completedDays => dayProgress.values.where((v) => v).length;
  double get progress => durationDays > 0 ? completedDays / durationDays : 0;
  bool get isStarted => startedAt != null;
}

class StudyRepository extends ChangeNotifier {
  final List<StudyPlan> _availablePlans = [];
  final List<StudyPlan> _myPlans = [];
  bool _isLoading = false;

  List<StudyPlan> get availablePlans => _availablePlans;
  List<StudyPlan> get myPlans => _myPlans;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _generateSamplePlans();

    _isLoading = false;
    notifyListeners();
  }

  void _generateSamplePlans() {
    _availablePlans.addAll([
      StudyPlan(
        title: '30 Days of Psalms',
        description: 'Journey through the Psalms with daily readings and reflections to deepen your prayer life.',
        type: StudyType.readingPlan,
        difficulty: StudyDifficulty.beginner,
        durationDays: 30,
        topics: ['Prayer', 'Worship', 'Trust', 'Lament', 'Praise'],
        imageUrl: 'assets/images/psalms_plan.jpg',
      ),
      StudyPlan(
        title: 'The Life of Jesus',
        description: 'Walk through the Gospels and discover the life, teachings, and miracles of Jesus Christ.',
        type: StudyType.readingPlan,
        difficulty: StudyDifficulty.beginner,
        durationDays: 40,
        topics: ['Birth', 'Ministry', 'Parables', 'Miracles', 'Crucifixion', 'Resurrection'],
        imageUrl: 'assets/images/jesus_life.jpg',
      ),
      StudyPlan(
        title: 'Overcoming Anxiety',
        description: 'A 14-day plan to find peace in God\'s promises when anxiety feels overwhelming.',
        type: StudyType.studyPlan,
        difficulty: StudyDifficulty.intermediate,
        durationDays: 14,
        topics: ['Trust', 'Peace', 'Prayer', 'Scripture', 'Community'],
        imageUrl: 'assets/images/anxiety_plan.jpg',
      ),
      StudyPlan(
        title: 'Bible in a Year',
        description: 'Read through the entire Bible in 365 days with daily guided readings.',
        type: StudyType.readingPlan,
        difficulty: StudyDifficulty.advanced,
        durationDays: 365,
        topics: ['Old Testament', 'New Testament', 'History', 'Prophecy', 'Letters'],
        imageUrl: 'assets/images/bible_year.jpg',
      ),
      StudyPlan(
        title: 'Tales of the Bible',
        description: 'Listen to captivating Bible stories retold for modern ears.',
        type: StudyType.listeningPlan,
        difficulty: StudyDifficulty.beginner,
        durationDays: 30,
        topics: ['Creation', 'Patriarchs', 'Exodus', 'Judges', 'Kings', 'Jesus', 'Early Church'],
        audioUrl: 'assets/audio/tales_intro.mp3',
      ),
      StudyPlan(
        title: '7-Day Freedom Challenge',
        description: 'Break free from spiritual strongholds with this intensive 7-day challenge.',
        type: StudyType.challenge,
        difficulty: StudyDifficulty.intermediate,
        durationDays: 7,
        topics: ['Identity', 'Freedom', 'Victory', 'Authority', 'Prayer', 'Worship', 'Testimony'],
        imageUrl: 'assets/images/freedom_challenge.jpg',
      ),
      StudyPlan(
        title: 'Proverbs: Wisdom for Daily Living',
        description: '31 days of practical wisdom from Proverbs for work, relationships, and decisions.',
        type: StudyType.readingPlan,
        difficulty: StudyDifficulty.beginner,
        durationDays: 31,
        topics: ['Wisdom', 'Work', 'Relationships', 'Money', 'Speech', 'Character'],
        imageUrl: 'assets/images/proverbs.jpg',
      ),
      StudyPlan(
        title: 'The Lord\'s Prayer Deep Dive',
        description: 'Explore each phrase of the Lord\'s Prayer over 7 days with Jesus\' model for prayer.',
        type: StudyType.studyPlan,
        difficulty: StudyDifficulty.beginner,
        durationDays: 7,
        topics: ['Father', 'Kingdom', 'Daily Bread', 'Forgiveness', 'Temptation', 'Deliverance', 'Glory'],
        imageUrl: 'assets/images/lords_prayer.jpg',
      ),
    ]);
  }

  Future<void> startPlan(String planId) async {
    final plan = _availablePlans.firstWhere((p) => p.id == planId);
    final myPlan = plan.copyWith(
      isCompleted: false,
      startedAt: DateTime.now(),
      dayProgress: {},
    );
    _myPlans.insert(0, myPlan);
    notifyListeners();
  }

  Future<void> completeDay(String planId, int day) async {
    final index = _myPlans.indexWhere((p) => p.id == planId);
    if (index == -1) return;

    final plan = _myPlans[index];
    final newProgress = Map<int, bool>.from(plan.dayProgress);
    newProgress[day] = true;

    var updatedPlan = plan.copyWith(dayProgress: newProgress);

    if (newProgress.values.where((v) => v).length >= plan.durationDays) {
      updatedPlan = updatedPlan.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
    }

    _myPlans[index] = updatedPlan;
    notifyListeners();
  }

  Future<void> removePlan(String planId) async {
    _myPlans.removeWhere((p) => p.id == planId);
    notifyListeners();
  }

  StudyPlan? getPlan(String id) {
    return _myPlans.firstWhere(
      (p) => p.id == id,
      orElse: () => _availablePlans.firstWhere(
        (p) => p.id == id,
        orElse: () => throw StateError('Plan not found'),
      ),
    );
  }
}

extension StudyPlanCopy on StudyPlan {
  StudyPlan copyWith({
    String? title,
    String? description,
    StudyType? type,
    StudyDifficulty? difficulty,
    int? durationDays,
    List<String>? topics,
    String? imageUrl,
    String? audioUrl,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<int, bool>? dayProgress,
  }) {
    return StudyPlan(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      durationDays: durationDays ?? this.durationDays,
      topics: topics ?? this.topics,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      dayProgress: dayProgress ?? this.dayProgress,
    );
  }
}