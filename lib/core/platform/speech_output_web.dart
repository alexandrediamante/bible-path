// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:typed_data';
import 'speech_voice.dart';

@JS('navigator.audioSession')
external _AudioSession? get _audioSession;

extension type _AudioSession._(JSObject _) implements JSObject {
  external set type(String value);
}

class SpeechOutput {
  SpeechOutput() {
    try {
      _voiceId = html.window.localStorage['bible-path-speech-voice'];
    } catch (_) {}
    _setAudioSessionType('ambient');
    _createAudioRouteKeeper();
  }
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  html.SpeechSynthesisUtterance? _utterance;
  html.AudioElement? _audioRouteKeeper;
  String? _audioRouteKeeperUrl;
  Timer? _speakTimer;
  Timer? _routeReleaseTimer;
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
    _primeAudioRoute();
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
        _scheduleAudioRouteRelease();
        onDone();
      }),
    );
    _subscriptions.add(
      utterance.onError.listen((_) {
        _utterance = null;
        _scheduleAudioRouteRelease();
        onError();
      }),
    );
    // WebKit can retain a stale playback category after its media process is
    // recreated. A real category transition on the next task repairs it.
    _speakTimer = Timer(Duration.zero, () {
      if (_utterance != utterance) return;
      _setAudioSessionType('playback');
      synthesis.speak(utterance);
    });
  }

  void pause() => html.window.speechSynthesis?.pause();
  void resume() => html.window.speechSynthesis?.resume();
  void stop() {
    _speakTimer?.cancel();
    _routeReleaseTimer?.cancel();
    _clearSubscriptions();
    final synthesis = html.window.speechSynthesis;
    if (_utterance != null ||
        synthesis?.speaking == true ||
        synthesis?.pending == true ||
        synthesis?.paused == true) {
      synthesis?.cancel();
    }
    _utterance = null;
    _releaseAudioRoute();
  }

  void _primeAudioRoute() {
    _routeReleaseTimer?.cancel();
    _speakTimer?.cancel();
    _setAudioSessionType('ambient');
    final keeper = _audioRouteKeeper;
    if (keeper != null && keeper.paused) {
      unawaited(keeper.play().catchError((_) {}));
    }
  }

  void _scheduleAudioRouteRelease() {
    _routeReleaseTimer?.cancel();
    _routeReleaseTimer = Timer(
      const Duration(milliseconds: 750),
      _releaseAudioRoute,
    );
  }

  void _releaseAudioRoute() {
    _routeReleaseTimer?.cancel();
    final keeper = _audioRouteKeeper;
    keeper?.pause();
    if (keeper != null) keeper.currentTime = 0;
    _setAudioSessionType('ambient');
  }

  void _createAudioRouteKeeper() {
    try {
      const sampleRate = 8000;
      final bytes = Uint8List(44 + sampleRate);
      final data = ByteData.view(bytes.buffer);
      void ascii(int offset, String value) {
        bytes.setRange(offset, offset + value.length, value.codeUnits);
      }

      ascii(0, 'RIFF');
      data.setUint32(4, bytes.length - 8, Endian.little);
      ascii(8, 'WAVE');
      ascii(12, 'fmt ');
      data.setUint32(16, 16, Endian.little);
      data.setUint16(20, 1, Endian.little);
      data.setUint16(22, 1, Endian.little);
      data.setUint32(24, sampleRate, Endian.little);
      data.setUint32(28, sampleRate, Endian.little);
      data.setUint16(32, 1, Endian.little);
      data.setUint16(34, 8, Endian.little);
      ascii(36, 'data');
      data.setUint32(40, sampleRate, Endian.little);
      for (var index = 0; index < sampleRate; index++) {
        // Non-zero 20 Hz signal: inaudible on an iPhone speaker, but it keeps
        // the HTML media playback route active while speech is synthesized.
        bytes[44 + index] = (index ~/ 200).isEven ? 127 : 129;
      }

      final blob = html.Blob(<Object>[bytes], 'audio/wav');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final element =
          html.AudioElement(url)
            ..loop = true
            ..preload = 'auto'
            ..volume = 1;
      element.setAttribute('playsinline', '');
      element.style
        ..position = 'fixed'
        ..width = '1px'
        ..height = '1px'
        ..opacity = '0'
        ..pointerEvents = 'none';
      html.document.body?.append(element);
      _audioRouteKeeper = element;
      _audioRouteKeeperUrl = url;
    } catch (_) {
      // Speech still works normally in browsers that reject the route keeper.
    }
  }

  void _setAudioSessionType(String type) {
    try {
      _audioSession?.type = type;
    } catch (_) {
      // The Audio Session API is Safari-specific and best-effort.
    }
  }

  void _clearSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void dispose() {
    stop();
    _audioRouteKeeper?.remove();
    final url = _audioRouteKeeperUrl;
    if (url != null) html.Url.revokeObjectUrl(url);
    _audioRouteKeeper = null;
    _audioRouteKeeperUrl = null;
  }
}
