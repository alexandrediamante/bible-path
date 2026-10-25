import 'dart:async';
import 'speech_voice.dart';

class SpeechOutput {
  bool get supported => false;
  List<SpeechVoice> get voices => const [];
  bool get hasVoiceSelection => voices.isNotEmpty;
  Stream<void> get voicesChanged => const Stream.empty();
  String? get selectedVoiceId => null;
  void selectVoice(String? id) {}
  void speak(
    String text,
    String locale,
    double rate, {
    required void Function() onStart,
    required void Function() onDone,
    required void Function() onError,
  }) => onError();
  void pause() {}
  void resume() {}
  void stop() {}
  void dispose() {}
}
