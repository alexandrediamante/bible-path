// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_interop';
import 'package:bible_path/core/platform/speech_output_web.dart';

@JS('voiceHarness.emit')
external void emitEvent(String kind, int index);
@JS('voiceHarness.calls')
external int get calls;
@JS('voiceHarness.lastVoice')
external String get lastVoice;
@JS('voiceHarness.lastText')
external String get lastText;
@JS('voiceHarness.requests')
external int get requests;
@JS('voiceHarness.maxRequestLength')
external int get maxRequestLength;
@JS('voiceHarness.rejectResume')
external set rejectResume(bool value);
@JS('voiceHarness.holdFetch')
external set holdFetch(bool value);
@JS('voiceHarness.releaseFetch')
external void releaseFetch();
@JS('voiceHarness.playCalls')
external int get playCalls;
@JS('voiceHarness.playbackSession')
external bool get playbackSession;

Future<void> main() async {
  final results = html.document.getElementById('results')!;
  var passes = 0;
  void check(bool value, String label) {
    if (!value) throw StateError(label);
    passes++;
    results.appendText('PASS: $label\n');
  }

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 10));
  final output = SpeechOutput();
  var starts = 0, ends = 0, errors = 0;
  void speak(String text, {String locale = 'pt-BR'}) {
    output.speak(
      text,
      locale,
      1,
      onStart: () => starts++,
      onDone: () => ends++,
      onError: () => errors++,
    );
  }

  try {
    output.selectVoice(null);
    check(
      output.hasVoiceSelection,
      'voice selector available with online endpoint',
    );
    check(output.voices.length == 6, 'device and online inventories coexist');
    speak('No princípio Deus criou os céus e a terra.');
    check(
      lastVoice == 'device-br-one',
      'automatic selects exact Portuguese voice',
    );
    check(starts == 0 && ends == 0, 'no simulated start');
    emitEvent('start', calls - 1);
    await tick();
    check(starts == 1, 'actual start callback');
    emitEvent('end', calls - 1);
    await tick();
    check(ends == 1, 'actual end callback');

    output.selectVoice('device-br-two');
    speak('Segunda voz.');
    check(lastVoice == 'device-br-two', 'explicit second voice');
    final old = calls - 1;
    output.selectVoice('device-br-one');
    speak('Nova leitura.');
    emitEvent('start', old);
    emitEvent('end', old);
    await tick();
    check(starts == 1 && ends == 1, 'replaced utterance events ignored');
    emitEvent('start', calls - 1);
    await tick();
    output.stop();
    emitEvent('end', calls - 1);
    await tick();
    check(ends == 1, 'stop ignores late end');

    speak('Erro de início.');
    emitEvent('end', calls - 1);
    await tick();
    check(
      errors == 1 && ends == 1,
      'end without start is error, not completion',
    );

    final whole = List.generate(140, (i) => 'palavra$i').join(' ');
    final chunks = <String>[];
    speak(whole);
    while (true) {
      final count = calls;
      chunks.add(lastText);
      check(lastText.length <= 240, 'native request bounded');
      emitEvent('start', count - 1);
      emitEvent('end', count - 1);
      await tick();
      if (calls == count) break;
    }
    check(chunks.join(' ') == whole, 'whole long verse retained in order');
    check(ends == 2, 'long verse completes once');

    final restored = SpeechOutput();
    check(
      restored.selectedVoiceId == 'device-br-one',
      'voice persists across instances',
    );
    restored.dispose();
    output.selectVoice('removed-voice');
    speak('Voz removida.');
    check(
      lastVoice == 'device-br-one',
      'removed voice falls back to Portuguese',
    );
    output.stop();

    output.selectVoice('online-en');
    final requestCount = requests;
    speak('The Lord is my shepherd.', locale: 'en');
    await tick();
    await tick();
    await tick();
    check(requests == requestCount + 1, 'online voice calls service');
    check(playbackSession, 'served media uses playback audio session');
    check(starts >= 3, 'served playing event reaches callback');
    final beforeError = errors;
    output.pause();
    rejectResume = true;
    output.resume();
    await tick();
    check(errors == beforeError + 1, 'resume rejection reported');
    rejectResume = false;

    // Pause during an outstanding media request must survive its completion.
    holdFetch = true;
    speak('Deferred media.', locale: 'en');
    await tick();
    output.pause();
    final beforePausedResponse = playCalls;
    releaseFetch();
    await tick();
    await tick();
    check(playCalls == beforePausedResponse, 'fetched media stays paused');
    output.resume();
    await tick();
    check(
      playCalls == beforePausedResponse + 1,
      'resume starts deferred media',
    );
    holdFetch = false;
    output.stop();

    final beforeEmpty = errors;
    speak('');
    check(errors == beforeEmpty + 1, 'empty text rejected');
    output.selectVoice(null);
    final beforeLanguage = errors;
    speak('Sprache', locale: 'de');
    check(
      errors == beforeLanguage + 1,
      'unsupported language never becomes Spanish',
    );
    check(maxRequestLength <= 500, 'online payload within backend bound');
    output.dispose();
    results.appendText(
      '\n$passes adapter checks passed. Synthetic browser events; no physical audio claim.',
    );
    html.document.title = 'PASS — BiblePath speech adapter';
  } catch (error, stack) {
    output.dispose();
    results.appendText('\nFAIL: $error\n$stack');
    html.document.title = 'FAIL — BiblePath speech adapter';
  }
}
