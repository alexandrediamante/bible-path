// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
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
  html.AudioElement? _audioElement;
  String? _audioObjectUrl;
  html.AudioElement? _audioRouteKeeper;
  String? _audioRouteKeeperUrl;
  Timer? _routeReleaseTimer;
  String? _voiceId;
  int _requestGeneration = 0;
  bool _paused = false;
  bool _usingOnline = false;
  static const _configuredEndpoint = String.fromEnvironment('AI_API_URL');
  String get _endpoint {
    final configured = _configuredEndpoint.trim();
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/+$'), '');
    }
    final uri = Uri.base;
    return uri.scheme == 'http' || uri.scheme == 'https' ? uri.origin : '';
  }

  bool get _servedAudioConfigured => Uri.tryParse(_endpoint)?.hasScheme == true;
  bool get supported =>
      _servedAudioConfigured || html.window.speechSynthesis != null;
  bool get hasVoiceSelection => true;
  static const _onlineVoices = [
    SpeechVoice(id: 'online-en', name: 'Online audio', language: 'en'),
    SpeechVoice(
      id: 'online-es',
      name: 'Audio en línea (online)',
      language: 'es',
    ),
    SpeechVoice(
      id: 'online-fr',
      name: 'Audio en ligne (online)',
      language: 'fr',
    ),
  ];
  List<SpeechVoice> get _deviceVoices => [
    for (final voice
        in html.window.speechSynthesis?.getVoices() ??
            <html.SpeechSynthesisVoice>[])
      if ((voice.voiceUri ?? voice.name ?? '').isNotEmpty)
        SpeechVoice(
          id: voice.voiceUri ?? voice.name!,
          name: voice.name ?? voice.voiceUri ?? '',
          language: voice.lang ?? '',
        ),
  ];
  List<SpeechVoice> get voices => [
    ..._deviceVoices,
    if (_servedAudioConfigured) ..._onlineVoices,
  ];
  Stream<void> get voicesChanged =>
      html.window.speechSynthesis?.on['voiceschanged'].map<void>((_) {}) ??
      const Stream.empty();
  String? get selectedVoiceId => _voiceId;
  void Function()? _activeError;

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
    stop();
    final generation = _requestGeneration;
    final chunks = splitSpeechChunks(text);
    final devices = _deviceVoices;
    final catalog = voices;
    final explicit = catalog.where((voice) => voice.id == _voiceId);
    final voice =
        explicit.isNotEmpty
            ? explicit.first
            : chooseSpeechVoice(devices, locale) ??
                chooseSpeechVoice(
                  _servedAudioConfigured ? _onlineVoices : const [],
                  locale,
                );
    // A missing compatible voice is recoverable after voiceschanged.
    // Never use an unrelated online language for Portuguese.
    final online =
        voice != null &&
        _onlineVoices.any((candidate) => candidate.id == voice.id) &&
        !devices.any((candidate) => candidate.id == voice.id);
    if (voice == null ||
        chunks.isEmpty ||
        !rate.isFinite ||
        rate <= 0 ||
        (!online && html.window.speechSynthesis == null)) {
      onError();
      return;
    }
    _usingOnline = online;
    var started = false;
    var finished = false;
    void fail() {
      if (generation != _requestGeneration || finished) return;
      finished = true;
      stop();
      onError();
    }

    _activeError = fail;
    void playChunk(int index) {
      if (generation != _requestGeneration || finished) return;
      if (index == chunks.length) {
        finished = true;
        _activeError = null;
        _scheduleAudioRouteRelease();
        onDone();
        return;
      }
      void begin() {
        if (generation != _requestGeneration || finished) return;
        if (!started) {
          started = true;
          onStart();
        }
      }

      void next() {
        scheduleMicrotask(() => playChunk(index + 1));
      }

      if (online) {
        _speakServedChunk(
          chunks[index],
          voice.language,
          rate,
          generation,
          onStart: begin,
          onDone: next,
          onError: fail,
        );
      } else {
        _speakDeviceChunk(
          chunks[index],
          locale,
          rate,
          generation,
          voice,
          onStart: begin,
          onDone: next,
          onError: fail,
        );
      }
    }

    _primeAudioRoute();
    playChunk(0);
  }

  void _speakDeviceChunk(
    String text,
    String locale,
    double rate,
    int generation,
    SpeechVoice? voice, {
    required void Function() onStart,
    required void Function() onDone,
    required void Function() onError,
  }) {
    _clearSubscriptions();
    final synthesis = html.window.speechSynthesis!;
    final utterance =
        html.SpeechSynthesisUtterance(text)
          ..lang = locale
          ..rate = rate;
    _utterance = utterance;
    for (final available in synthesis.getVoices()) {
      if (voice != null && (available.voiceUri ?? available.name) == voice.id) {
        utterance.voice = available;
        break;
      }
    }
    var started = false;
    var ended = false;
    bool current() => generation == _requestGeneration && !ended;
    _subscriptions.add(
      utterance.onStart.listen((_) {
        if (!current()) return;
        started = true;
        onStart();
      }),
    );
    _subscriptions.add(
      utterance.onEnd.listen((_) {
        if (!current()) return;
        ended = true;
        _utterance = null;
        if (started) {
          onDone();
        } else {
          onError();
        }
      }),
    );
    _subscriptions.add(
      utterance.onError.listen((_) {
        if (!current()) return;
        ended = true;
        onError();
      }),
    );
    try {
      _setAudioSessionType('playback');
      // Keep the first utterance within the user's gesture.
      synthesis.speak(utterance);
      if (_paused) synthesis.pause();
    } catch (_) {
      onError();
    }
  }

  void pause() {
    _paused = true;
    if (_audioElement != null) {
      _audioElement!.pause();
    } else if (!_usingOnline) {
      html.window.speechSynthesis?.pause();
    }
  }

  void resume() {
    _paused = false;
    final generation = _requestGeneration;
    _setAudioSessionType('playback');
    final audio = _audioElement;
    if (audio != null) {
      unawaited(
        audio.play().catchError((_) {
          if (generation == _requestGeneration) _activeError?.call();
        }),
      );
    } else if (!_usingOnline) {
      try {
        html.window.speechSynthesis?.resume();
      } catch (_) {
        _activeError?.call();
      }
    }
  }

  void stop() {
    _requestGeneration++;
    _paused = false;
    _usingOnline = false;
    _activeError = null;
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
    _releaseGeneratedAudio();
    _releaseAudioRoute();
  }

  void _speakServedChunk(
    String text,
    String locale,
    double rate,
    int generation, {
    required void Function() onStart,
    required void Function() onDone,
    required void Function() onError,
  }) {
    _clearSubscriptions();
    _releaseGeneratedAudio();
    unawaited(() async {
      try {
        final response = await http
            .post(
              Uri.parse('$_endpoint/v1/tts'),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({'text': text, 'locale': locale}),
            )
            .timeout(const Duration(seconds: 20));
        if (generation != _requestGeneration) return;
        final bytes = response.bodyBytes;
        final contentType = response.headers['content-type'] ?? '';
        if (response.statusCode != 200 ||
            !contentType.toLowerCase().startsWith('audio/wav') ||
            bytes.length < 44 ||
            ascii.decode(bytes.sublist(0, 4), allowInvalid: true) != 'RIFF' ||
            ascii.decode(bytes.sublist(8, 12), allowInvalid: true) != 'WAVE') {
          throw StateError('Invalid served audio');
        }
        final url = html.Url.createObjectUrlFromBlob(
          html.Blob(<Object>[bytes], 'audio/wav'),
        );
        // Preserve the user-gesture-unlocked media element on iOS.
        final audio = _audioRouteKeeper;
        if (audio == null) {
          html.Url.revokeObjectUrl(url);
          throw StateError('Audio route unavailable');
        }
        _audioElement = audio;
        _audioObjectUrl = url;
        var started = false;
        var ended = false;
        bool current() => generation == _requestGeneration && !ended;
        _subscriptions.add(
          audio.onPlaying.listen((_) {
            if (!current() || started) return;
            started = true;
            onStart();
          }),
        );
        _subscriptions.add(
          audio.onEnded.listen((_) {
            if (!current()) return;
            ended = true;
            _clearSubscriptions();
            _releaseGeneratedAudio();
            if (started) {
              onDone();
            } else {
              onError();
            }
          }),
        );
        _subscriptions.add(
          audio.onError.listen((_) {
            if (current()) {
              ended = true;
              onError();
            }
          }),
        );
        audio
          ..pause()
          ..loop = false
          ..src = url
          ..preload = 'auto'
          ..playbackRate = rate;
        audio.load();
        _setAudioSessionType('playback');
        if (!_paused) await audio.play();
      } catch (_) {
        if (generation == _requestGeneration) onError();
      }
    }());
  }

  void _releaseGeneratedAudio() {
    final audio = _audioElement;
    audio?.pause();
    final keeperUrl = _audioRouteKeeperUrl;
    if (audio != null &&
        identical(audio, _audioRouteKeeper) &&
        keeperUrl != null) {
      audio
        ..loop = true
        ..playbackRate = 1
        ..src = keeperUrl
        ..currentTime = 0;
      audio.load();
    } else {
      audio?.removeAttribute('src');
      audio?.load();
      audio?.remove();
    }
    final url = _audioObjectUrl;
    if (url != null) html.Url.revokeObjectUrl(url);
    _audioElement = null;
    _audioObjectUrl = null;
  }

  void _primeAudioRoute() {
    _routeReleaseTimer?.cancel();
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
