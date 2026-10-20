import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? verseReference;

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.verseReference,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();
}

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

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
}

class ChatRepository extends ChangeNotifier {
  final List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  int _messageCount = 0;
  static const int _freeMessageLimit = 10; // In original app, but we remove this limit!

  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  int get messageCount => _messageCount;
  bool get canSendMessage => true; // Always true - no limits!

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Load from local storage (implement with Hive/SharedPreferences)
    // For now, create a welcome session
    _createWelcomeSession();

    _isLoading = false;
    notifyListeners();
  }

  void _createWelcomeSession() {
    final session = ChatSession(
      title: 'Bible AI',
      messages: [
        ChatMessage(
          text: 'Welcome! I\'m your personal AI assistant Bible AI. Tell me what you need.',
          isUser: false,
        ),
      ],
    );
    _sessions.add(session);
    _currentSession = session;
    notifyListeners();
  }

  void createNewSession({String? title}) {
    final session = ChatSession(
      title: title ?? 'New Chat ${_sessions.length + 1}',
    );
    _sessions.insert(0, session);
    _currentSession = session;
    notifyListeners();
  }

  void setCurrentSession(ChatSession session) {
    _currentSession = session;
    notifyListeners();
  }

  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_currentSession?.id == sessionId) {
      _currentSession = _sessions.isNotEmpty ? _sessions.first : null;
    }
    notifyListeners();
  }

  void addMessage(String text, {bool isUser = true, String? verseReference}) {
    if (_currentSession == null) {
      createNewSession();
    }

    final message = ChatMessage(
      text: text,
      isUser: isUser,
      verseReference: verseReference,
    );

    _currentSession!.messages.add(message);
    _currentSession = _currentSession!.copyWith(
      messages: _currentSession!.messages,
      updatedAt: DateTime.now(),
    );

    if (isUser) {
      _messageCount++;
    }

    notifyListeners();
  }

  // Simulate AI response (in real app, this would call an API)
  Future<void> simulateAIResponse(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 500));

    String response;
    String? verseRef;

    // Simple keyword-based responses
    final lower = userMessage.toLowerCase();
    if (lower.contains('prayer') || lower.contains('pray')) {
      response = 'Prayer is a powerful way to connect with God. Would you like me to help you create a personalized prayer?';
      verseRef = 'Philippians 4:6-7';
    } else if (lower.contains('verse') || lower.contains('scripture')) {
      response = 'Here\'s a beautiful verse for you: "Be still, and know that I am God." - Psalm 46:10';
      verseRef = 'Psalm 46:10';
    } else if (lower.contains('forgiv') || lower.contains('sin')) {
      response = 'God\'s forgiveness is always available to those who seek it with a sincere heart. "If we confess our sins, he is faithful and just to forgive us our sins."';
      verseRef = '1 John 1:9';
    } else if (lower.contains('anxious') || lower.contains('worry') || lower.contains('fear')) {
      response = 'Cast all your anxiety on Him because He cares for you. You are not alone in your struggles.';
      verseRef = '1 Peter 5:7';
    } else if (lower.contains('love')) {
      response = 'God\'s love for you is unconditional and everlasting. "For God so loved the world that he gave his one and only Son."';
      verseRef = 'John 3:16';
    } else {
      response = 'Growing closer to God begins with making space for Him in your daily life. Here are some simple practices:\n\n1. Spend Time in Prayer: Speak honestly with God, share your worries and gratitude, and take a quiet moment to listen.\n\n2. Reflect on Scripture: Reflect on a short Bible passage each day and consider how its message applies to your life.';
      verseRef = 'Matthew 11:28';
    }

    addMessage(response, isUser: false, verseReference: verseRef);
  }

  // No license checks - unlimited messages!
  bool checkMessageLimit() => true;
}

extension ChatSessionCopy on ChatSession {
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
}