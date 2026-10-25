import 'dart:convert';

import 'package:http/http.dart' as http;

class AiClient {
  AiClient({http.Client? client, String? endpoint, Uri? applicationUri})
    : _client = client ?? http.Client(),
      _endpoint = resolveEndpoint(
        endpoint ?? const String.fromEnvironment('AI_API_URL'),
        applicationUri ?? Uri.base,
      );

  /// A full-stack host serves /v1/chat beside the app; no build-time URL needed.
  static String resolveEndpoint(String configured, Uri applicationUri) {
    if (configured.trim().isNotEmpty) return configured.trim();
    if (applicationUri.scheme == 'http' || applicationUri.scheme == 'https') {
      return applicationUri.origin;
    }
    return '';
  }

  final http.Client _client;
  final String _endpoint;

  bool get isConfigured => Uri.tryParse(_endpoint)?.hasScheme == true;

  Future<AiResponse> send({
    required String authToken,
    required String sessionId,
    required String locale,
    required String translationId,
    required String message,
    required List<AiHistoryMessage> history,
    List<AiBibleContext> context = const [],
  }) async {
    if (!isConfigured) {
      throw const AiClientException(code: 'not_configured');
    }
    final base = _endpoint.replaceFirst(RegExp(r'/+$'), '');
    final response = await _client
        .post(
          Uri.parse('$base/v1/chat'),
          headers: {
            if (authToken.trim().isNotEmpty)
              'Authorization': 'Bearer ${authToken.trim()}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'sessionId': sessionId,
            'locale': locale,
            'translationId': translationId,
            'message': message,
            'history': history.map((item) => item.toJson()).toList(),
            'context': context.map((item) => item.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 70));

    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      decoded = null;
    }

    if (response.statusCode != 200) {
      final body = decoded is Map ? decoded : const <String, dynamic>{};
      final error = body['error'];
      final message =
          error is Map
              ? error['message'] as String?
              : body['message'] as String?;
      final code = error is Map ? error['code'] as String? : null;
      throw AiClientException(
        code: code ?? 'http_${response.statusCode}',
        statusCode: response.statusCode,
        remoteMessage: message,
      );
    }

    if (decoded is! Map || decoded['text'] is! String) {
      throw const AiClientException(code: 'invalid_response');
    }

    return AiResponse(
      text: decoded['text'] as String,
      truncated: decoded['truncated'] == true,
    );
  }
}

class AiResponse {
  const AiResponse({required this.text, required this.truncated});

  final String text;
  final bool truncated;
}

class AiHistoryMessage {
  const AiHistoryMessage({required this.role, required this.text});

  final String role;
  final String text;

  Map<String, dynamic> toJson() => {'role': role, 'text': text};
}

class AiBibleContext {
  const AiBibleContext({
    required this.reference,
    required this.translationId,
    required this.text,
  });

  final String reference;
  final String translationId;
  final String text;

  Map<String, dynamic> toJson() => {
    'reference': reference,
    'translationId': translationId,
    'text': text,
  };
}

class AiClientException implements Exception {
  const AiClientException({
    required this.code,
    this.statusCode,
    this.remoteMessage,
  });

  final String code;
  final int? statusCode;
  final String? remoteMessage;

  @override
  String toString() => remoteMessage ?? code;
}
