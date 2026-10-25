import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:bible_path/features/chat/ai_client.dart';

void main() {
  test('same-origin endpoint needs no AI_API_URL on full-stack hosting', () {
    expect(
      AiClient.resolveEndpoint('', Uri.parse('https://bible.example/#/chat')),
      'https://bible.example',
    );
    expect(
      AiClient.resolveEndpoint(
        'https://api.example',
        Uri.parse('https://bible.example'),
      ),
      'https://api.example',
    );
    expect(AiClient.resolveEndpoint('', Uri.parse('file:///app')), isEmpty);
  });

  test('sends the bounded public contract to the Worker', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://worker.example/v1/chat');
      expect(request.headers.containsKey('Authorization'), isFalse);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body.keys.toSet(), {
        'sessionId',
        'locale',
        'translationId',
        'message',
        'history',
        'context',
      });
      expect(body['context'], [
        {
          'reference': 'John 3:16',
          'translationId': 'engwebp',
          'text': 'For God so loved the world…',
        },
      ]);
      return http.Response(
        jsonEncode({'text': 'A careful response.', 'truncated': false}),
        200,
      );
    });

    final response = await AiClient(
      client: client,
      endpoint: 'https://worker.example/',
    ).send(
      authToken: '',
      sessionId: 'session-one',
      locale: 'en',
      translationId: 'engwebp',
      message: 'Explain John 3:16',
      history: const [AiHistoryMessage(role: 'user', text: 'Earlier')],
      context: const [
        AiBibleContext(
          reference: 'John 3:16',
          translationId: 'engwebp',
          text: 'For God so loved the world…',
        ),
      ],
    );

    expect(response.text, 'A careful response.');
    expect(response.truncated, isFalse);
  });

  test(
    'maps typed Worker errors without exposing response internals',
    () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {
              'code': 'rate_limit_exceeded',
              'message': 'Too many requests',
            },
          }),
          429,
        ),
      );

      await expectLater(
        AiClient(client: client, endpoint: 'https://worker.example').send(
          authToken: 'personal-token',
          sessionId: 'session-one',
          locale: 'en',
          translationId: 'engwebp',
          message: 'Hello',
          history: const [],
        ),
        throwsA(
          isA<AiClientException>()
              .having((error) => error.code, 'code', 'rate_limit_exceeded')
              .having((error) => error.statusCode, 'status', 429),
        ),
      );
    },
  );
}
