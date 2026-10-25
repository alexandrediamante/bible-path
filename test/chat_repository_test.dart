import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/chat/ai_client.dart';
import 'package:bible_path/features/chat/chat_repository.dart';

class _DelayedAiClient extends AiClient {
  _DelayedAiClient() : super(endpoint: 'https://worker.test');

  final requests = <Completer<AiResponse>>[];
  final histories = <List<AiHistoryMessage>>[];

  @override
  bool get isConfigured => true;

  @override
  Future<AiResponse> send({
    required String authToken,
    required String sessionId,
    required String locale,
    required String translationId,
    required String message,
    required List<AiHistoryMessage> history,
    List<AiBibleContext> context = const [],
  }) {
    histories.add(history);
    final completer = Completer<AiResponse>();
    requests.add(completer);
    return completer.future;
  }
}

Future<void> _waitForRequest(_DelayedAiClient client, [int count = 1]) async {
  while (client.requests.length < count) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late StorageService storage;
  late BibleRepository bible;
  late _DelayedAiClient client;
  late ChatRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('bible_path_chat_');
    Hive.init(tempDirectory.path);
    storage = StorageService();
    await storage.init();
    bible = BibleRepository(storage);
    await bible.init();
    client = _DelayedAiClient();
    repository = ChatRepository(storage, client, bible);
    await repository.init();
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('AI response stays in the originating session', () async {
    final origin = repository.currentSession!;
    final pending = repository.sendMessage('Explain John 3:16');
    await _waitForRequest(client);
    expect(client.requests, hasLength(1));

    final other = await repository.createNewSession(title: 'Other chat');
    client.requests.single.complete(
      const AiResponse(text: 'A response with context.', truncated: false),
    );
    await pending;

    final restoredOrigin = repository.sessions.singleWhere(
      (session) => session.id == origin.id,
    );
    expect(restoredOrigin.messages, hasLength(2));
    expect(restoredOrigin.messages.last.text, 'A response with context.');
    expect(repository.currentSession!.id, other.id);
    expect(repository.currentSession!.messages, isEmpty);
  });

  test('long histories still begin with a user turn', () async {
    final session = ChatSession(
      title: 'Long chat',
      messages: [
        for (var index = 0; index < 13; index++)
          ChatMessage(text: 'Message $index', isUser: index.isEven),
      ],
    );
    await storage.write('chatSessions', [session.toJson()]);
    await storage.write('currentChatSessionId', session.id);
    final delayed = _DelayedAiClient();
    final longChat = ChatRepository(storage, delayed, bible);
    await longChat.init();

    final pending = longChat.sendMessage('Continue');
    await _waitForRequest(delayed);

    expect(delayed.histories.single, hasLength(11));
    expect(delayed.histories.single.first.role, 'user');
    delayed.requests.single.complete(
      const AiResponse(text: 'Continued', truncated: false),
    );
    await pending;
  });

  test('pending response does not recreate a deleted session', () async {
    final origin = repository.currentSession!;
    final pending = repository.sendMessage('A delayed question');
    await _waitForRequest(client);

    await repository.deleteSession(origin.id);
    client.requests.single.complete(
      const AiResponse(text: 'Late response', truncated: false),
    );
    await pending;

    expect(
      repository.sessions.any((session) => session.id == origin.id),
      isFalse,
    );
    expect(
      repository.sessions
          .expand((session) => session.messages)
          .any((message) => message.text == 'Late response'),
      isFalse,
    );
  });

  test(
    'retry replaces a failed turn without duplicating the question',
    () async {
      final first = repository.sendMessage('How should I pray?');
      await _waitForRequest(client);
      client.requests.first.completeError(
        const AiClientException(code: 'timeout'),
      );
      await first;

      expect(repository.currentSession!.messages, hasLength(2));
      expect(repository.currentSession!.messages.last.isError, isTrue);

      final retry = repository.retryLastFailedMessage();
      await _waitForRequest(client, 2);
      expect(repository.currentSession!.messages, hasLength(1));
      expect(
        repository.currentSession!.messages.single.text,
        'How should I pray?',
      );
      client.requests.last.complete(
        const AiResponse(text: 'Pray simply and honestly.', truncated: false),
      );
      await retry;

      expect(
        repository.currentSession!.messages.map((message) => message.text),
        ['How should I pray?', 'Pray simply and honestly.'],
      );
    },
  );
}
