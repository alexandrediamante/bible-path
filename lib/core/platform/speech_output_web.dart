// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'speech_voice.dart';

class SpeechOutput {
  SpeechOutput() {
    try {
      _voiceId = html.window.localStorage['bible-path-speech-voice'];
    } catch (_) {}
  }
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  html.SpeechSynthesisUtterance? _utterance;
  String? _voiceId;
  bool get supported => html.window.speechSynthesis != null;
  List<SpeechVoice> get voices => [
    for (final voice
        in html.window.speechSynthesis?.getVoices() ??
            <html.SpeechSynthesisVoice>[])
      SpeechVoice(
        id: voice.voiceUri ?? voice.name ?? '',
        name: voice.name ?? '',
        language: voice.lang ?? '',
      ),
  ];
  Stream<void> get voicesChanged =>
      html.window.speechSynthesis?.on['voiceschanged'].map<void>((_) {}) ??
      const Stream.empty();
  String? get selectedVoiceId => _voiceId;
  void selectVoice(String? id) {
    _voiceId = id;
    try {
      if (id == null) {
        html.window.localStorage.remove('bible-path-speech-voice');
      } else {
        html.window.localStorage['bible-path-speech-voice'] = id;
      }
    } catch (_) {}
  }

  void speak(
    String text,
    String locale,
    double rate, {
    required void Function() onStart,
    required void Function() onDone,
    required void Function() onError,
  }) {
    final synthesis = html.window.speechSynthesis;
    if (synthesis == null) {
      onError();
      return;
    }
    _clearSubscriptions();
    if (synthesis.speaking == true ||
        synthesis.pending == true ||
        synthesis.paused == true) {
      synthesis.cancel();
    }
    final utterance =
        html.SpeechSynthesisUtterance(text)
          ..lang = locale
          ..rate = rate;
    _utterance = utterance;
    final available = synthesis.getVoices();
    for (final voice in available) {
      if (_voiceId != null && (voice.voiceUri ?? voice.name) == _voiceId) {
        utterance.voice = voice;
        break;
      }
    }
    _subscriptions.add(utterance.onStart.listen((_) => onStart()));
    _subscriptions.add(
      utterance.onEnd.listen((_) {
        _utterance = null;
        onDone();
      }),
    );
    _subscriptions.add(
      utterance.onError.listen((_) {
        _utterance = null;
        onError();
      }),
    );
    synthesis.speak(utterance);
  }

  void pause() => html.window.speechSynthesis?.pause();
  void resume() => html.window.speechSynthesis?.resume();
  void stop() {
    _clearSubscriptions();
    final synthesis = html.window.speechSynthesis;
    if (_utterance != null ||
        synthesis?.speaking == true ||
        synthesis?.pending == true ||
        synthesis?.paused == true) {
      synthesis?.cancel();
    }
    _utterance = null;
  }

  void _clearSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void dispose() => stop();
}
