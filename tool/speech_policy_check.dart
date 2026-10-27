// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
import 'package:bible_path/core/platform/speech_voice.dart';

void check(bool condition, String description) {
  if (!condition) throw StateError(description);
  print('PASS: $description');
}

void main() {
  const voices = [
    SpeechVoice(id: 'en', name: 'English', language: 'en-US'),
    SpeechVoice(id: 'pt', name: 'Portugal', language: 'pt-PT'),
    SpeechVoice(id: 'br', name: 'Brasil', language: 'pt-BR'),
  ];
  check(chooseSpeechVoice(voices, 'pt-BR')?.id == 'br', 'exact locale');
  check(chooseSpeechVoice(voices, 'PT_br')?.id == 'br', 'locale normalization');
  check(chooseSpeechVoice(voices, 'pt-AO')?.id == 'pt', 'base language');
  check(
    chooseSpeechVoice(voices, 'de') == null,
    'no unrelated language fallback',
  );
  check(
    chooseSpeechVoice(voices, 'pt', selectedId: 'en')?.id == 'en',
    'explicit voice',
  );
  check(
    chooseSpeechVoice(voices, 'pt-BR', selectedId: 'removed')?.id == 'br',
    'removed voice fallback',
  );
  check(chooseSpeechVoice([], 'pt') == null, 'empty catalog');
  check(splitSpeechChunks(' ').isEmpty, 'empty text');
  for (final limit in [2, 5, 80, 240]) {
    final text = List.generate(160, (i) => 'p$i').join(' ');
    final parts = splitSpeechChunks(text, maxCharacters: limit);
    check(
      parts.every((p) => p.isNotEmpty && p.length <= limit),
      'bounded chunks $limit',
    );
    check(
      parts.join().replaceAll(' ', '') == text.replaceAll(' ', ''),
      'no lost characters $limit',
    );
  }
  final longWord = 'x' * 800;
  check(
    splitSpeechChunks(longWord).join() == longWord,
    'unbroken long word preserved',
  );
  final ordinary = List.generate(160, (i) => 'palavra$i').join(' ');
  check(
    splitSpeechChunks(ordinary).join(' ') == ordinary,
    'ordinary word boundaries preserved',
  );
  final unicode = 'a' * 239 + '😀' + 'b' * 300;
  check(
    splitSpeechChunks(unicode).join() == unicode,
    'surrogate pair preserved',
  );
  print('19 speech policy checks passed');
}
