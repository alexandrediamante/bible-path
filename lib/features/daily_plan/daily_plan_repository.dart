import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum PlanStepType {
  devotional,
  prayer,
  connection,
  verse,
  reading,
  listening,
}

class PlanStep {
  final String id;
  final PlanStepType type;
  final String title;
  final String content;
  final String? verseReference;
  final String? audioUrl;
  final int order;
  bool isCompleted;
  DateTime? completedAt;

  PlanStep({
    String? id,
    required this.type,
    required this.title,
    required this.content,
    this.verseReference,
    this.audioUrl,
    required this.order,
    this.isCompleted = false,
    this.completedAt,
  }) : id = id ?? const Uuid().v4();
}

class DailyPlan {
  final String id;
  final DateTime date;
  final List<PlanStep> steps;
  final String? theme;
  bool isCompleted;
  DateTime? completedAt;

  DailyPlan({
    String? id,
    required this.date,
    required this.steps,
    this.theme,
    this.isCompleted = false,
    this.completedAt,
  }) : id = id ?? const Uuid().v4();

  int get completedSteps => steps.where((s) => s.isCompleted).length;
  int get totalSteps => steps.length;
  double get progress => totalSteps > 0 ? completedSteps / totalSteps : 0;
}

class DailyPlanRepository extends ChangeNotifier {
  final Map<String, DailyPlan> _plans = {};
  DailyPlan? _todaysPlan;
  int _currentStreak = 0;
  int _longestStreak = 0;
  final List<String> _completedPlanDates = [];

  DailyPlan? get todaysPlan => _todaysPlan;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<String> get completedPlanDates => _completedPlanDates;

  Future<void> init() async {
    await _generateTodaysPlan();
    _calculateStreaks();
    notifyListeners();
  }

  Future<void> _generateTodaysPlan() async {
    final today = DateTime.now();
    final dateKey = _dateKey(today);

    if (_plans.containsKey(dateKey)) {
      _todaysPlan = _plans[dateKey]!;
      return;
    }

    final steps = _generateStepsForDate(today);
    final plan = DailyPlan(
      date: today,
      steps: steps,
      theme: _getThemeForDate(today),
    );

    _plans[dateKey] = plan;
    _todaysPlan = plan;
  }

  List<PlanStep> _generateStepsForDate(DateTime date) {
    final dayOfYear = _dayOfYear(date);
    final seed = dayOfYear % 7;

    final devotionalContent = [
      'Being a shepherd in ancient times was not a glamorous career choice. It was a hectic life, full of danger and stress. Even so, the life and rhythm of a shepherd were remarkable. In Psalm 23, we read about the shepherd\'s rod and staff.',
      'The Lord is my shepherd; I shall not want. He makes me lie down in green pastures. He leads me beside still waters. He restores my soul.',
      'Trust in the Lord with all your heart, and do not lean on your own understanding. In all your ways acknowledge him, and he will make straight your paths.',
      'Come to me, all who labor and are heavy laden, and I will give you rest. Take my yoke upon you, and learn from me, for I am gentle and lowly in heart.',
      'The steadfast love of the Lord never ceases; his mercies never come to an end; they are new every morning; great is your faithfulness.',
      'For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope.',
      'Be strong and courageous. Do not be frightened, and do not be dismayed, for the Lord your God is with you wherever you go.',
    ];

    final prayerContent = [
      'Lord, guide us with Your wisdom, fill our hearts with peace, and strengthen us to face this day with faith and love. Help us to trust in Your perfect plan.',
      'Heavenly Father, thank You for this new day. Grant me the wisdom to make good choices and the courage to follow Your will.',
      'Dear God, help me to be a light to those around me today. Let my words and actions reflect Your love and grace.',
    ];

    final connectionQuestions = [
      'How close do you feel to God today?',
      'What is one thing you\'re grateful for today?',
      'Where do you need God\'s guidance most right now?',
    ];

    return [
      PlanStep(
        type: PlanStepType.verse,
        title: 'Today\'s Verse',
        content: _getVerseForDay(dayOfYear),
        verseReference: _getVerseRefForDay(dayOfYear),
        order: 1,
      ),
      PlanStep(
        type: PlanStepType.devotional,
        title: 'Daily Devotional',
        content: devotionalContent[seed],
        verseReference: 'Psalm 23:1-3',
        order: 2,
      ),
      PlanStep(
        type: PlanStepType.connection,
        title: 'Connection with God',
        content: connectionQuestions[dayOfYear % connectionQuestions.length],
        order: 3,
      ),
      PlanStep(
        type: PlanStepType.prayer,
        title: 'Daily Prayer',
        content: prayerContent[dayOfYear % prayerContent.length],
        order: 4,
      ),
    ];
  }

  String _getVerseForDay(int dayOfYear) {
    final verses = [
      'The Lord is my shepherd; I shall not want.',
      'Be still, and know that I am God.',
      'Trust in the Lord with all your heart.',
      'I can do all things through Christ who strengthens me.',
      'The Lord is my light and my salvation.',
      'For God so loved the world, that he gave his only Son.',
      'Cast all your anxiety on him because he cares for you.',
    ];
    return verses[dayOfYear % verses.length];
  }

  String _getVerseRefForDay(int dayOfYear) {
    final refs = [
      'Psalm 23:1',
      'Psalm 46:10',
      'Proverbs 3:5',
      'Philippians 4:13',
      'Psalm 27:1',
      'John 3:16',
      '1 Peter 5:7',
    ];
    return refs[dayOfYear % refs.length];
  }

  String _getThemeForDate(DateTime date) {
    final themes = [
      'Trust & Guidance',
      'Peace & Rest',
      'Strength & Courage',
      'Hope & Future',
      'Love & Grace',
      'Faith & Trust',
      'Wisdom & Understanding',
    ];
    return themes[_dayOfYear(date) % themes.length];
  }

  int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _calculateStreaks() {
    final sortedDates = _completedPlanDates.toList()..sort();
    if (sortedDates.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      return;
    }

    _longestStreak = 1;
    _currentStreak = 1;
    var currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prev = DateTime.parse(sortedDates[i - 1]);
      final curr = DateTime.parse(sortedDates[i]);

      if (curr.difference(prev).inDays == 1) {
        currentStreak++;
        _longestStreak = _longestStreak > currentStreak ? _longestStreak : currentStreak;
      } else {
        currentStreak = 1;
      }
    }

    // Check if today or yesterday is completed for current streak
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (sortedDates.contains(today)) {
      _currentStreak = currentStreak;
    } else if (sortedDates.contains(yesterday)) {
      _currentStreak = currentStreak;
    } else {
      _currentStreak = 0;
    }
  }

  Future<void> completeStep(String planId, String stepId) async {
    final plan = _plans[planId];
    if (plan == null) return;

    final stepIndex = plan.steps.indexWhere((s) => s.id == stepId);
    if (stepIndex == -1) return;

    plan.steps[stepIndex] = PlanStep(
      id: plan.steps[stepIndex].id,
      type: plan.steps[stepIndex].type,
      title: plan.steps[stepIndex].title,
      content: plan.steps[stepIndex].content,
      verseReference: plan.steps[stepIndex].verseReference,
      audioUrl: plan.steps[stepIndex].audioUrl,
      order: plan.steps[stepIndex].order,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    if (plan.completedSteps == plan.totalSteps) {
      plan.isCompleted = true;
      plan.completedAt = DateTime.now();
      _completedPlanDates.add(planId);
      _calculateStreaks();
    }

    notifyListeners();
  }

  Future<void> uncompleteStep(String planId, String stepId) async {
    final plan = _plans[planId];
    if (plan == null) return;

    final stepIndex = plan.steps.indexWhere((s) => s.id == stepId);
    if (stepIndex == -1) return;

    plan.steps[stepIndex] = PlanStep(
      id: plan.steps[stepIndex].id,
      type: plan.steps[stepIndex].type,
      title: plan.steps[stepIndex].title,
      content: plan.steps[stepIndex].content,
      verseReference: plan.steps[stepIndex].verseReference,
      audioUrl: plan.steps[stepIndex].audioUrl,
      order: plan.steps[stepIndex].order,
      isCompleted: false,
      completedAt: null,
    );

    plan.isCompleted = false;
    plan.completedAt = null;
    _completedPlanDates.remove(planId);
    _calculateStreaks();

    notifyListeners();
  }

  DailyPlan? getPlanForDate(DateTime date) {
    return _plans[_dateKey(date)];
  }

  List<DailyPlan> getRecentPlans({int limit = 30}) {
    final plans = _plans.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return plans.take(limit).toList();
  }
}