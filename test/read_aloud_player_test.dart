import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible_path/core/platform/speech_output.dart';
import 'package:bible_path/shared/widgets/read_aloud_player.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class FakeSpeech extends SpeechOutput {
  int starts = 0, pauses = 0, resumes = 0, stops = 0;
  double rate = 0;
  String text = '', locale = '';
  bool available = true;
  String? voiceId;
  @override
  List<SpeechVoice> get voices => const [
    SpeechVoice(id: 'test-pt', name: 'Test voice', language: 'pt-BR'),
  ];
  @override
  String? get selectedVoiceId => voiceId;
  @override
  void selectVoice(String? id) {
    voiceId = id;
  }

  void Function()? begin, done, fail;
  @override
  bool get supported => available;
  @override
  void speak(
    String text,
    String locale,
    double rate, {
    required void Function() onStart,
    required void Function() onDone,
    required void Function() onError,
  }) {
    starts++;
    this.text = text;
    this.locale = locale;
    this.rate = rate;
    begin = onStart;
    done = onDone;
    fail = onError;
  }

  @override
  void pause() {
    pauses++;
  }

  @override
  void resume() {
    resumes++;
  }

  @override
  void stop() {
    stops++;
  }

  @override
  void dispose() => stop();
}

void main() {
  Future<void> mount(
    WidgetTester tester,
    FakeSpeech speech, {
    String text = 'Real text',
  }) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('pt'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: ReadAloudPlayer(text: text, output: speech)),
    ),
  );

  test('splits long Safari utterances without losing words', () {
    final text = List.generate(120, (index) => 'word$index').join(' ');
    final chunks = splitSpeechText(text, maxCharacters: 80);
    expect(chunks.length, greaterThan(1));
    expect(chunks.every((chunk) => chunk.length <= 80), isTrue);
    expect(chunks.join(' '), text);
  });

  testWidgets('voice selector applies the selected device voice', (
    tester,
  ) async {
    final speech = FakeSpeech();
    await mount(tester, speech);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test voice (pt-BR)').last);
    await tester.pumpAndSettle();
    expect(speech.voiceId, 'test-pt');
    await tester.tap(find.byTooltip('Reproduzir'));
    await tester.pump();
    expect(speech.starts, 1);
  });

  testWidgets(
    'verses advance only after actual end events and stop rejects stale events',
    (tester) async {
      final speech = FakeSpeech();
      final indices = <int?>[];
      var completed = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: ReadAloudPlayer(
              text: 'one two',
              segments: const ['one', 'two'],
              output: speech,
              onSegmentChanged: indices.add,
              onCompleted: () => completed++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Reproduzir'));
      await tester.pump();
      expect(speech.text, 'one');
      expect(indices.last, 0);
      speech.done!();
      await tester.pump();
      expect(speech.text, 'two');
      await tester.pump();
      expect(indices.last, 1);
      final stale = speech.done!;
      await tester.tap(find.byTooltip('Parar'));
      await tester.pump();
      stale();
      await tester.pump();
      expect(completed, 0);
      expect(indices.last, isNull);
    },
  );

  testWidgets('play, pause, resume, stop and speed reach the speech engine', (
    tester,
  ) async {
    final speech = FakeSpeech();
    await mount(tester, speech);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reproduzir'));
    await tester.pump();
    expect(speech.text, 'Real text');
    expect(speech.locale, 'pt');
    expect(speech.starts, 1);
    expect(find.byTooltip('Reproduzir'), findsOneWidget);
    speech.begin!();
    await tester.pump();
    await tester.tap(find.byTooltip('Pausar'));
    await tester.pump();
    expect(speech.pauses, 1);
    await tester.tap(find.byTooltip('Reproduzir'));
    await tester.pump();
    expect(speech.resumes, 1);
    await tester.tap(find.byTooltip('Velocidade de leitura'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1.5x'));
    await tester.pumpAndSettle();
    expect(speech.rate, 1.5);
    expect(speech.starts, 2);
    speech.begin!();
    await tester.pump();
    await tester.tap(find.byTooltip('Parar'));
    await tester.pump();
    expect(speech.stops, greaterThan(0));
    expect(find.byTooltip('Reproduzir'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('does not claim playback before the browser starts speaking', (
    tester,
  ) async {
    final speech = FakeSpeech();
    await mount(tester, speech);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Reproduzir'));
    await tester.pump();

    expect(speech.starts, 1);
    expect(find.byTooltip('Pausar'), findsNothing);
    expect(find.byTooltip('Reproduzir'), findsOneWidget);

    speech.begin!();
    await tester.pump();
    expect(find.byTooltip('Pausar'), findsOneWidget);
  });

  testWidgets('unsupported and empty text do not offer fake playback', (
    tester,
  ) async {
    final speech = FakeSpeech()..available = false;
    await mount(tester, speech);
    await tester.pumpAndSettle();
    final play = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Reproduzir',
      ),
    );
    expect(play.onPressed, isNull);
    expect(find.byType(Slider), findsNothing);
    expect(speech.starts, 0);
  });

  testWidgets('errors and late callbacks are handled safely after dismissal', (
    tester,
  ) async {
    final speech = FakeSpeech();
    await mount(tester, speech);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reproduzir'));
    speech.fail!();
    await tester.pump();
    expect(find.textContaining('Falha ao gerar ou reproduzir'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    speech.done!();
    expect(tester.takeException(), isNull);
  });
}
