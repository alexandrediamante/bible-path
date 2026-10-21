import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/chat/ai_client.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class ChatMessage {
  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.verseReference,
    this.isError = false,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? verseReference;
  final bool isError;

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] == true,
      timestamp: DateTime.parse(json['timestamp'] as String),
      verseReference: json['verseReference'] as String?,
      isError: json['isError'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'verseReference': verseReference,
    'isError': isError,
  };
}

class ChatSession {
  ChatSession({
    String? id,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       messages = messages ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatSession copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ChatSession.fromJson(Map<dynamic, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List? ?? const [])
          .whereType<Map>()
          .map(ChatMessage.fromJson)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((message) => message.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

class ChatRepository extends ChangeNotifier {
  ChatRepository(this._storage, this._aiClient, this._bible);

  static const _sessionsKey = 'chatSessions';
  static const _currentSessionKey = 'currentChatSessionId';

  final StorageService _storage;
  final AiClient _aiClient;
  final BibleRepository _bible;
  final List<ChatSession> _sessions = [];
  final Set<String> _loadingSessions = {};
  String? _currentSessionId;

  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  ChatSession? get currentSession => _session(_currentSessionId);
  bool get isLoading =>
      _currentSessionId != null && _loadingSessions.contains(_currentSessionId);
  int get messageCount => _sessions.fold(
    0,
    (count, session) =>
        count + session.messages.where((message) => message.isUser).length,
  );
  bool get canSendMessage => currentSession != null && !isLoading;
  bool get aiConfigured => _aiClient.isConfigured;
  AppLocalizations get _l10n =>
      lookupAppLocalizations(Locale(_storage.userPreferences.locale));

  Future<void> init() async {
    final stored = _storage.read<List<dynamic>>(_sessionsKey) ?? const [];
    _sessions
      ..clear()
      ..addAll(stored.whereType<Map>().map(ChatSession.fromJson));
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _currentSessionId = _storage.read<String>(_currentSessionKey);
    if (_sessions.isEmpty) {
      await createNewSession();
    } else if (_session(_currentSessionId) == null) {
      _currentSessionId = _sessions.first.id;
    }
    await _save();
    notifyListeners();
  }

  Future<ChatSession> createNewSession({String? title}) async {
    final session = ChatSession(
      title: title ?? _l10n.newChatNumber(_sessions.length + 1),
    );
    _sessions.insert(0, session);
    _currentSessionId = session.id;
    await _save();
    notifyListeners();
    return session;
  }

  Future<void> setCurrentSession(ChatSession session) async {
    if (_session(session.id) == null) return;
    _currentSessionId = session.id;
    await _save();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
    _loadingSessions.remove(sessionId);
    if (_currentSessionId == sessionId) {
      _currentSessionId = _sessions.firstOrNull?.id;
    }
    if (_sessions.isEmpty) {
      final session = ChatSession(title: _l10n.newChatNumber(1));
      _sessions.add(session);
      _currentSessionId = session.id;
    }
    await _save();
    notifyListeners();
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return;
    final session = currentSession ?? await createNewSession();
    if (_loadingSessions.contains(session.id)) return;

    final recentMessages = session.messages
        .where((message) => !message.isError)
        .toList()
        .reversed
        .take(12)
        .toList()
        .reversed
        .toList();
    if (recentMessages.firstOrNull?.isUser == false) {
      recentMessages.removeAt(0);
    }
    final history = recentMessages
        .map(
          (message) => AiHistoryMessage(
            role: message.isUser ? 'user' : 'assistant',
            text: message.text,
          ),
        )
        .toList();

    _append(session.id, ChatMessage(text: text, isUser: true));
    _loadingSessions.add(session.id);
    await _save();
    notifyListeners();

    try {
      final preferences = _storage.userPreferences;
      final context = _bible
          .contextForQuestion(text)
          .map(
            (verse) => AiBibleContext(
              reference: verse.reference,
              translationId: _bible.currentTranslationId,
              text: verse.text,
            ),
          )
          .toList();
      final response = await _aiClient.send(
        authToken: preferences.aiAuthToken ?? '',
        sessionId: session.id,
        locale: preferences.locale,
        translationId: preferences.preferredBibleVersion,
        message: text,
        history: history,
        context: context,
      );
      if (_session(session.id) == null) return;
      _append(
        session.id,
        ChatMessage(
          text: response.truncated
              ? _l10n.responseTruncated(response.text)
              : response.text,
          isUser: false,
        ),
      );
    } on AiClientException catch (error) {
      if (_session(session.id) == null) return;
      _append(
        session.id,
        ChatMessage(text: _localizedError(error), isUser: false, isError: true),
      );
    } catch (_) {
      if (_session(session.id) == null) return;
      _append(
        session.id,
        ChatMessage(
          text: _l10n.aiUnavailableConnection,
          isUser: false,
          isError: true,
        ),
      );
    } finally {
      _loadingSessions.remove(session.id);
      await _save();
      notifyListeners();
    }
  }

  String _localizedError(AiClientException error) {
    return switch (error.code) {
      'not_configured' => _l10n.aiNotConfigured,
      'missing_token' => _l10n.aiMissingToken,
      'invalid_response' => _l10n.aiInvalidResponse,
      _ =>
        error.remoteMessage?.trim().isNotEmpty == true
            ? error.remoteMessage!
            : _l10n.aiUnavailableLater,
    };
  }

  void _append(String sessionId, ChatMessage message) {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    if (index < 0) return;
    final session = _sessions[index];
    final title =
        session.messages.where((item) => item.isUser).isEmpty && message.isUser
        ? _titleFrom(message.text)
        : session.title;
    _sessions[index] = session.copyWith(
      title: title,
      messages: [...session.messages, message],
      updatedAt: DateTime.now(),
    );
  }

  ChatSession? _session(String? id) {
    if (id == null) return null;
    for (final session in _sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  Future<void> _save() async {
    await _storage.write(
      _sessionsKey,
      _sessions.map((session) => session.toJson()).toList(),
    );
    if (_currentSessionId == null) {
      await _storage.delete(_currentSessionKey);
    } else {
      await _storage.write(_currentSessionKey, _currentSessionId);
    }
  }

  static String _titleFrom(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized.length <= 36
        ? normalized
        : '${normalized.substring(0, 33)}…';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
