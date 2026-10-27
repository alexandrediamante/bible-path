class SpeechVoice {
  const SpeechVoice({
    required this.id,
    required this.name,
    required this.language,
  });
  final String id;
  final String name;
  final String language;
}

String _speechLocale(String value) => value.toLowerCase().replaceAll('_', '-');

/// An explicit available choice wins; automatic never guesses another language.
SpeechVoice? chooseSpeechVoice(
  List<SpeechVoice> voices,
  String locale, {
  String? selectedId,
}) {
  for (final voice in voices) {
    if (voice.id == selectedId) return voice;
  }
  final wanted = _speechLocale(locale);
  for (final voice in voices) {
    if (_speechLocale(voice.language) == wanted) return voice;
  }
  final language = wanted.split('-').first;
  for (final voice in voices) {
    if (_speechLocale(voice.language).split('-').first == language) {
      return voice;
    }
  }
  return null;
}

/// Bound engine requests while preserving order, including unusually long words.
List<String> splitSpeechChunks(String text, {int maxCharacters = 240}) {
  if (maxCharacters < 2) throw ArgumentError.value(maxCharacters);
  var remaining = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  final chunks = <String>[];
  while (remaining.length > maxCharacters) {
    var end = remaining.lastIndexOf(' ', maxCharacters);
    if (end <= 0) {
      end = maxCharacters;
      final last = remaining.codeUnitAt(end - 1);
      if (last >= 0xD800 && last <= 0xDBFF) end--;
    }
    chunks.add(remaining.substring(0, end));
    remaining = remaining.substring(end).trimLeft();
  }
  if (remaining.isNotEmpty) chunks.add(remaining);
  return chunks;
}
