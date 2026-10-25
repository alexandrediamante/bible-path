import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bible_path/core/platform/speech_output.dart';
import 'package:bible_path/l10n/app_localizations.dart';

/// Speaks actual text in sequence; never simulates media duration/progress.
class ReadAloudPlayer extends StatefulWidget {
  const ReadAloudPlayer({
    super.key,
    required this.text,
    this.output,
    this.segments,
    this.onSegmentChanged,
    this.onCompleted,
    this.autoPlay = false,
    this.locale,
    this.compact = false,
  });
  final String text;
  final SpeechOutput? output;
  final List<String>? segments;
  final ValueChanged<int?>? onSegmentChanged;
  final VoidCallback? onCompleted;
  final bool autoPlay;
  final String? locale;
  final bool compact;
  @override
  State<ReadAloudPlayer> createState() => _ReadAloudPlayerState();
}

class _ReadAloudPlayerState extends State<ReadAloudPlayer> {
  late final SpeechOutput _output = widget.output ?? SpeechOutput();
  StreamSubscription<void>? _voiceSubscription;
  Timer? _startTimeout;
  bool _starting = false, _playing = false, _paused = false, _error = false;
  double _rate = 1;
  int _generation = 0, _index = 0;
  List<String> get _parts => widget.segments ?? splitSpeechText(widget.text);

  @override
  void initState() {
    super.initState();
    _voiceSubscription = _output.voicesChanged.listen((_) {
      if (mounted) setState(() {});
    });
  }

  void _notify(int? index) {
    final generation = _generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && generation == _generation) {
        widget.onSegmentChanged?.call(index);
      }
    });
  }

  void _start({bool fromBeginning = false}) {
    if (_parts.isEmpty) return;
    final generation = ++_generation;
    if (fromBeginning || _index >= _parts.length) _index = 0;
    setState(() {
      _error = false;
      _starting = true;
      _playing = false;
      _paused = false;
    });
    _notify(_index);
    _startTimeout?.cancel();
    _startTimeout = Timer(const Duration(seconds: 25), () {
      if (!mounted || generation != _generation || !_starting) return;
      _output.stop();
      setState(() {
        _starting = false;
        _error = true;
      });
      _notify(null);
    });
    try {
      _output.speak(
        _parts[_index],
        widget.locale ?? Localizations.localeOf(context).toLanguageTag(),
        _rate,
        onStart: () {
          if (mounted && generation == _generation) {
            _startTimeout?.cancel();
            setState(() {
              _starting = false;
              _playing = true;
            });
          }
        },
        onDone: () {
          if (!mounted || generation != _generation) return;
          _startTimeout?.cancel();
          if (_index + 1 < _parts.length) {
            _index++;
            // Avoid reentrant synthesis/event disposal from an end event.
            scheduleMicrotask(() {
              if (mounted && generation == _generation) _start();
            });
          } else {
            setState(() {
              _starting = false;
              _playing = false;
              _paused = false;
              _index = 0;
            });
            _notify(null);
            widget.onCompleted?.call();
          }
        },
        onError: () {
          if (!mounted || generation != _generation) return;
          _startTimeout?.cancel();
          setState(() {
            _starting = false;
            _playing = false;
            _paused = false;
            _error = true;
          });
          _notify(null);
        },
      );
    } catch (_) {
      if (mounted && generation == _generation) {
        _startTimeout?.cancel();
        setState(() {
          _starting = false;
          _playing = false;
          _paused = false;
          _error = true;
        });
        _notify(null);
      }
    }
  }

  void _stop() {
    _generation++;
    _startTimeout?.cancel();
    _output.stop();
    setState(() {
      _starting = false;
      _playing = false;
      _paused = false;
      _index = 0;
    });
    _notify(null);
  }

  @override
  void didUpdateWidget(covariant ReadAloudPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        widget.locale != oldWidget.locale ||
        !listEquals(widget.segments, oldWidget.segments)) {
      _stop();
      if (widget.autoPlay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.autoPlay) _start(fromBeginning: true);
        });
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    _startTimeout?.cancel();
    _voiceSubscription?.cancel();
    _output.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled =
        _output.supported &&
        _parts.isNotEmpty &&
        _parts.every((text) => text.trim().isNotEmpty);
    final voices =
        {for (final voice in _output.voices) voice.id: voice}.values.toList();
    final language =
        (widget.locale ?? Localizations.localeOf(context).languageCode)
            .split('-')
            .first
            .toLowerCase();
    voices.sort((a, b) {
      final aMatch = a.language.toLowerCase().startsWith(language);
      final bMatch = b.language.toLowerCase().startsWith(language);
      return aMatch == bMatch ? a.name.compareTo(b.name) : (aMatch ? -1 : 1);
    });
    final selected =
        voices.any((v) => v.id == _output.selectedVoiceId)
            ? _output.selectedVoiceId!
            : '';
    return Card(
      child: Padding(
        padding: EdgeInsets.all(widget.compact ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.compact) ...[
              Text(
                l10n.readAloud,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(enabled ? l10n.speechNotice : l10n.speechUnavailable),
            ],
            if (!enabled && widget.compact) Text(l10n.speechUnavailable),
            if (_error) Text(l10n.speechError),
            if (_output.hasVoiceSelection)
              DropdownButtonFormField<String>(
                key: ValueKey(selected),
                initialValue: selected,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.speechVoice),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(l10n.speechDefaultVoice),
                  ),
                  for (final voice in voices)
                    DropdownMenuItem(
                      value: voice.id,
                      child: Text(
                        '${voice.name} (${voice.language})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged:
                    !enabled
                        ? null
                        : (id) {
                          _output.selectVoice(id == '' ? null : id);
                          setState(() {});
                          if (_playing) _start();
                        },
              ),
            if (!_output.hasVoiceSelection)
              InputDecorator(
                decoration: InputDecoration(labelText: l10n.speechVoice),
                child: Text(
                  voices.isEmpty
                      ? l10n.speechDefaultVoice
                      : '${voices.first.name} (${voices.first.language})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (_output.hasVoiceSelection &&
                enabled &&
                voices.isEmpty &&
                !widget.compact)
              Text(l10n.speechNoVoices),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton.filled(
                  tooltip:
                      _playing && !_paused ? l10n.speechPause : l10n.speechPlay,
                  onPressed:
                      !enabled || _starting
                          ? null
                          : () {
                            if (!_playing) {
                              _start(fromBeginning: true);
                              return;
                            }
                            if (_paused) {
                              _output.resume();
                            } else {
                              _output.pause();
                            }
                            setState(() => _paused = !_paused);
                          },
                  icon:
                      _starting
                          ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(
                            _playing && !_paused
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                ),
                IconButton(
                  tooltip: l10n.speechStop,
                  onPressed: _playing || _starting ? _stop : null,
                  icon: const Icon(Icons.stop_rounded),
                ),
                PopupMenuButton<double>(
                  tooltip: l10n.speechRate,
                  initialValue: _rate,
                  enabled: enabled,
                  onSelected: (rate) {
                    setState(() => _rate = rate);
                    if (_playing || _starting) _start();
                  },
                  itemBuilder:
                      (_) => [
                        for (final rate in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
                          PopupMenuItem(value: rate, child: Text('${rate}x')),
                      ],
                  child: Chip(
                    avatar: const Icon(Icons.speed_rounded),
                    label: Text('${_rate}x'),
                  ),
                ),
                if (widget.segments != null && _playing)
                  Text('${_index + 1}/${_parts.length}'),
              ],
            ),
            if (kIsWeb)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Audio build 2026.10.25.3',
                  key: ValueKey('audio-build-marker'),
                  style: TextStyle(fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
List<String> splitSpeechText(String text, {int maxCharacters = 240}) {
  final words = text
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  final chunks = <String>[];
  var current = '';
  for (final word in words) {
    if (current.isNotEmpty &&
        current.length + word.length + 1 > maxCharacters) {
      chunks.add(current);
      current = word;
    } else {
      current = current.isEmpty ? word : '$current $word';
    }
  }
  if (current.isNotEmpty) chunks.add(current);
  return chunks;
}
