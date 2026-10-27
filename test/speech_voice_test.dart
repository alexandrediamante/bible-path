import 'package:flutter_test/flutter_test.dart';
import 'package:bible_path/core/platform/speech_voice.dart';

void main() {
  const voices = [
    SpeechVoice(id: 'en', name: 'English', language: 'en-US'),
    SpeechVoice(id: 'pt', name: 'Portugal', language: 'pt-PT'),
    SpeechVoice(id: 'br', name: 'Brasil', language: 'pt-BR'),
  ];
  test('automatic selection prefers exact locale then base language', () {
    expect(chooseSpeechVoice(voices, 'pt-BR')?.id, 'br');
    expect(chooseSpeechVoice(voices, 'pt-AO')?.id, 'pt');
    expect(chooseSpeechVoice(voices, 'de-DE'), isNull);
    expect(chooseSpeechVoice(voices, 'PT_br')?.id, 'br');
  });
  test('explicit choice wins and a removed voice falls back by language', () {
    expect(chooseSpeechVoice(voices, 'pt-BR', selectedId: 'en')?.id, 'en');
    expect(chooseSpeechVoice(voices, 'pt-BR', selectedId: 'removed')?.id, 'br');
  });
  test('long verse chunks retain every word and enforce service limit', () {
    final text = List.generate(200, (i) => 'palavra$i').join(' ');
    final chunks = splitSpeechChunks(text);
    expect(chunks.length, greaterThan(1));
    expect(chunks.every((chunk) => chunk.length <= 240), isTrue);
    expect(chunks.join(' '), text);
    expect(splitSpeechChunks('   '), isEmpty);
    final long = 'a' * 800;
    final wordChunks = splitSpeechChunks(long);
    expect(wordChunks.every((chunk) => chunk.length <= 240), isTrue);
    expect(wordChunks.join(), long);
  });
}
