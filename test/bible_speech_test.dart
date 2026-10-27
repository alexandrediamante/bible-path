import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/bible/bible_screen.dart';
import 'package:bible_path/l10n/app_localizations.dart';
import 'read_aloud_player_test.dart' show FakeSpeech;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'chapter speech highlights verses, auto advances and stops on manual navigation',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late Directory directory;
      late StorageService storage;
      late BibleRepository bible;
      await tester.runAsync(() async {
        directory = await Directory.systemTemp.createTemp('bible_speech_');
        Hive.init(directory.path);
        storage = StorageService();
        await storage.init();
        bible = BibleRepository(storage);
        await bible.init();
      });
      final speech = FakeSpeech();
      final router = GoRouter(
        initialLocation: '/bible',
        routes: [
          GoRoute(
            path: '/bible',
            builder:
                (_, _) => Scaffold(body: BibleScreen(speechOutput: speech)),
          ),
        ],
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: storage),
            ChangeNotifierProvider.value(value: bible),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Genesis'));
      await tester.pumpAndSettle();
      expect(find.text('Genesis 1'), findsOneWidget);
      expect(find.text('Voice'), findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.byTooltip('Play'));
      await tester.pump();
      speech.begin!();
      await tester.pumpAndSettle();
      expect(speech.text, bible.getVerse('Genesis', 1, 1));
      for (var verse = 1; verse <= 31; verse++) {
        speech.done!();
        await tester.pump();
        speech.begin!();
        await tester.pumpAndSettle();
      }
      expect(find.text('Genesis 2'), findsOneWidget);
      expect(speech.text, bible.getVerse('Genesis', 2, 1));
      await tester.tap(find.byTooltip('Next chapter'));
      await tester.pumpAndSettle();
      expect(find.text('Genesis 3'), findsOneWidget);
      expect(find.byTooltip('Play'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      bible.dispose();
      storage.dispose();
      await tester.runAsync(() async {
        await Hive.close();
        await directory.delete(recursive: true);
      });
    },
  );
}
