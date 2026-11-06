import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:bible_path/core/services/auth_service.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/chat/chat_repository.dart';
import 'package:bible_path/features/daily_plan/daily_plan_repository.dart';
import 'package:bible_path/features/prayer/prayer_repository.dart';
import 'package:bible_path/features/study/study_repository.dart';
import 'package:bible_path/features/advent/advent_repository.dart';
import 'package:bible_path/features/lent/lent_repository.dart';

/// Service for handling bidirectional sync between local (Hive) and cloud (Cloudflare D1)
class SyncService extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storage;
  final ChatRepository _chatRepository;
  final DailyPlanRepository _dailyPlanRepository;
  final PrayerRepository _prayerRepository;
  final StudyRepository _studyRepository;
  final AdventRepository _adventRepository;
  final LentRepository _lentRepository;
  final String _apiBaseUrl;

  bool _isSyncing = false;
  String? _lastError;
  DateTime? _lastSyncTime;
  SyncStatus _status = SyncStatus.idle;

  SyncService({
    required AuthService authService,
    required StorageService storage,
    required ChatRepository chatRepository,
    required DailyPlanRepository dailyPlanRepository,
    required PrayerRepository prayerRepository,
    required StudyRepository studyRepository,
    required AdventRepository adventRepository,
    required LentRepository lentRepository,
    required String apiBaseUrl,
  })  : _authService = authService,
        _storage = storage,
        _chatRepository = chatRepository,
        _dailyPlanRepository = dailyPlanRepository,
        _prayerRepository = prayerRepository,
        _studyRepository = studyRepository,
        _adventRepository = adventRepository,
        _lentRepository = lentRepository,
        _apiBaseUrl = apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');

  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;
  SyncStatus get status => _status;

  void _setStatus(SyncStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String? error) {
    _lastError = error;
    notifyListeners();
  }

  /// Full bidirectional sync
  Future<bool> sync() async {
    if (!_authService.isSignedIn) {
      _setError('Not signed in');
      return false;
    }

    if (_isSyncing) return false;

    _setStatus(SyncStatus.syncing);
    _isSyncing = true;
    _setError(null);

    try {
      // 1. Push local changes to cloud
      await _pushToCloud();

      // 2. Pull cloud changes to local
      await _pullFromCloud();

      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      _isSyncing = false;
      return true;
    } catch (e) {
      _setError('Sync failed: $e');
      _setStatus(SyncStatus.error);
      _isSyncing = false;
      return false;
    }
  }

  /// Push local data to cloud
  Future<void> _pushToCloud() async {
    final payload = _buildLocalPayload();

    final response = await http
        .post(
          Uri.parse('$_apiBaseUrl/v1/sync'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_authService.appAuthToken}',
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error']?['message'] ?? 'Push failed: ${response.statusCode}');
    }

    final result = jsonDecode(response.body);
    if (result['conflicts'] != null && (result['conflicts'] as List).isNotEmpty) {
      // Handle conflicts if needed
      debugPrint('Sync conflicts: ${result['conflicts']}');
    }
  }

  /// Pull cloud data to local
  Future<void> _pullFromCloud() async {
    final response = await http
        .get(
          Uri.parse('$_apiBaseUrl/v1/sync'),
          headers: {'Authorization': 'Bearer ${_authService.appAuthToken}'},
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error']?['message'] ?? 'Pull failed: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    await _applyCloudData(data);
  }

  /// Build payload from local repositories
  Map<String, dynamic> _buildLocalPayload() {
    final prefs = _storage.userPreferences;

    return {
      'preferences': {
        'isDarkMode': prefs.isDarkMode,
        'locale': prefs.locale,
        'textScale': prefs.textScale,
        'dailyReminderTime': prefs.dailyReminderTime,
        'dailyReminderEnabled': prefs.dailyReminderEnabled,
        'preferredBibleVersion': prefs.preferredBibleVersion,
        'translationStyle': prefs.translationStyle,
        'denomination': prefs.denomination,
        'aiAuthToken': prefs.aiAuthToken,
        'hasCompletedOnboarding': prefs.hasCompletedOnboarding,
      },
      'favoriteVerses': prefs.favoriteVerses,
      'chatSessions': _chatRepository.sessions.map((s) => {
        'id': s.id,
        'title': s.title,
        'createdAt': s.createdAt.millisecondsSinceEpoch,
        'updatedAt': s.updatedAt.millisecondsSinceEpoch,
        'isDeleted': false,
      }).toList(),
      'chatMessages': _chatRepository.sessions
          .expand((s) => s.messages.map((m) => {
                'id': m.id,
                'sessionId': s.id,
                'text': m.text,
                'isUser': m.isUser,
                'verseReference': m.verseReference,
                'isError': m.isError,
                'timestamp': m.timestamp.millisecondsSinceEpoch,
              }))
          .toList(),
      'dailyPlanProgress': _dailyPlanRepository.completedPlanDates.map((date) => {
        'planDate': date.toIso8601String().split('T').first,
        'planId': 'default', // TODO: get actual plan ID
        'completedAt': date.millisecondsSinceEpoch,
        'streakDay': null, // TODO: calculate streak day
      }).toList(),
      'prayers': _prayerRepository.prayers.map((p) => {
        'id': p.id,
        'title': p.title,
        'content': p.content,
        'category': p.category,
        'isAnswered': p.isAnswered,
        'answeredAt': p.answeredAt?.millisecondsSinceEpoch,
        'createdAt': p.createdAt.millisecondsSinceEpoch,
        'updatedAt': p.updatedAt.millisecondsSinceEpoch,
        'isDeleted': p.isDeleted,
      }).toList(),
      'studyPlans': _studyRepository.myPlans.map((plan) => {
        'id': plan.id,
        'title': plan.title,
        'description': plan.description,
        'translationId': plan.translationId,
        'totalDays': plan.totalDays,
        'completedDays': plan.completedDays,
        'currentDay': plan.currentDay,
        'isCompleted': plan.isCompleted,
        'startedAt': plan.startedAt.millisecondsSinceEpoch,
        'completedAt': plan.completedAt?.millisecondsSinceEpoch,
        'updatedAt': plan.updatedAt.millisecondsSinceEpoch,
      }).toList(),
      'studyPlanDays': _studyRepository.myPlans
          .expand((plan) => plan.days.map((day) => {
                'planId': plan.id,
                'dayNumber': day.dayNumber,
                'title': day.title,
                'reference': day.reference,
                'isCompleted': day.isCompleted,
                'completedAt': day.completedAt?.millisecondsSinceEpoch,
                'notes': day.notes,
              }))
          .toList(),
      'seasonalProgress': [
        ..._adventRepository.adventDays.map((day) => {
              'seasonType': 'advent',
              'year': day.date.year,
              'dayNumber': day.dayNumber,
              'isCompleted': day.isCompleted,
              'completedAt': day.completedAt?.millisecondsSinceEpoch,
              'notes': day.notes,
            }),
        ..._lentRepository.lentDays.map((day) => {
              'seasonType': 'lent',
              'year': day.date.year,
              'dayNumber': day.dayNumber,
              'isCompleted': day.isCompleted,
              'completedAt': day.completedAt?.millisecondsSinceEpoch,
              'notes': day.notes,
            }),
      ],
    };
  }

  /// Apply cloud data to local repositories
  Future<void> _applyCloudData(Map<String, dynamic> data) async {
    // Preferences
    if (data['preferences'] != null) {
      final p = data['preferences'] as Map<String, dynamic>;
      await _storage.updatePreferences(_storage.userPreferences.copyWith(
        isDarkMode: p['isDarkMode'] ?? false,
        locale: p['locale'] ?? 'en',
        textScale: (p['textScale'] as num?)?.toDouble() ?? 1.0,
        dailyReminderTime: p['dailyReminderTime'] ?? '07:00',
        dailyReminderEnabled: p['dailyReminderEnabled'] ?? false,
        preferredBibleVersion: p['preferredBibleVersion'] ?? 'engwebp',
        translationStyle: p['translationStyle'],
        denomination: p['denomination'],
        aiAuthToken: p['aiAuthToken'],
        hasCompletedOnboarding: p['hasCompletedOnboarding'] ?? false,
      ));
    }

    // Favorite verses
    if (data['favoriteVerses'] != null) {
      final verses = (data['favoriteVerses'] as List).cast<String>();
      await _storage.updatePreferences(
        _storage.userPreferences.copyWith(favoriteVerses: verses),
      );
    }

    // Chat sessions & messages
    if (data['chatSessions'] != null || data['chatMessages'] != null) {
      await _chatRepository.loadFromCloud(
        sessionsJson: data['chatSessions'] as List<dynamic>?,
        messagesJson: data['chatMessages'] as List<dynamic>?,
      );
    }

    // Daily plan progress
    if (data['dailyPlanProgress'] != null) {
      await _dailyPlanRepository.loadFromCloud(
        data['dailyPlanProgress'] as List<dynamic>,
      );
    }

    // Prayers
    if (data['prayers'] != null) {
      await _prayerRepository.loadFromCloud(data['prayers'] as List<dynamic>);
    }

    // Study plans
    if (data['studyPlans'] != null || data['studyPlanDays'] != null) {
      await _studyRepository.loadFromCloud(
        plansJson: data['studyPlans'] as List<dynamic>?,
        daysJson: data['studyPlanDays'] as List<dynamic>?,
      );
    }

    // Seasonal progress
    if (data['seasonalProgress'] != null) {
      final progress = data['seasonalProgress'] as List<dynamic>;
      final adventData = progress.where((p) => p['seasonType'] == 'advent').toList();
      final lentData = progress.where((p) => p['seasonType'] == 'lent').toList();

      if (adventData.isNotEmpty) {
        await _adventRepository.loadFromCloud(adventData);
      }
      if (lentData.isNotEmpty) {
        await _lentRepository.loadFromCloud(lentData);
      }
    }
  }

  /// Quick sync - only push pending changes
  Future<bool> quickSync() async {
    // TODO: Track dirty flags for incremental sync
    return await sync();
  }
}

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}