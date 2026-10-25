import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/app.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/advent/advent_repository.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/chat/ai_client.dart';
import 'package:bible_path/features/chat/chat_repository.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/daily_plan/daily_plan_repository.dart';
import 'package:bible_path/features/listen/listen_repository.dart';
import 'package:bible_path/features/listen/listen_screen.dart';
import 'package:bible_path/features/prayer/prayer_repository.dart';
import 'package:bible_path/features/study/study_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('listening detail scrolls on a compact Portuguese viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 550);
    addTearDown(tester.view.reset);

    late Directory directory;
    late StorageService storage;
    late ContentRepository content;
    late BibleRepository bible;
    late ListenRepository listen;
    await tester.runAsync(() async {
      directory = await Directory.systemTemp.createTemp('listen_ui_');
      Hive.init(directory.path);
      storage = StorageService();
      await storage.init();
      await storage.setLocale('pt');
      content = ContentRepository(storage);
      await content.init();
      bible = BibleRepository(storage);
      await bible.init();
      listen = ListenRepository(storage, content);
      await listen.init();
      await listen.startPlan('listen-scripture');
    });

    addTearDown(() async {
      listen.dispose();
      bible.dispose();
      content.dispose();
      storage.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storage),
          ChangeNotifierProvider.value(value: bible),
          ChangeNotifierProvider.value(value: listen),
        ],
        child: const MaterialApp(
          locale: Locale('pt'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(body: ListenScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meus Planos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dia 1'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final markComplete = find.text('Marcar Concluído');
    expect(markComplete, findsOneWidget);
    final before = tester.getCenter(markComplete).dy;
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -200),
    );
    await tester.pump();
    expect(tester.getCenter(markComplete).dy, lessThan(before));
  });

  testWidgets('mobile shell fits iPhone viewport and exposes primary routes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);

    late Directory directory;
    late StorageService storage;
    late ContentRepository content;
    late BibleRepository bible;
    late ChatRepository chat;
    late DailyPlanRepository daily;
    late PrayerRepository prayers;
    late StudyRepository study;
    late AdventRepository advent;

    await tester.runAsync(() async {
      directory = await Directory.systemTemp.createTemp('bible_path_ui_');
      Hive.init(directory.path);
      storage = StorageService();
      await storage.init();
      content = ContentRepository(storage);
      await content.init();
      bible = BibleRepository(storage);
      await bible.init();
      await storage.addFavoriteVerse(bible.verseKey('John', 3, 16));
      chat = ChatRepository(storage, AiClient(endpoint: ''), bible);
      await chat.init();
      daily = DailyPlanRepository(storage, content, bible);
      await daily.init();
      prayers = PrayerRepository(storage);
      await prayers.init();
      study = StudyRepository(storage, content);
      await study.init();
      advent = AdventRepository(storage);
      await advent.init();
      await storage.setDailyReminder('00:00', true);
      for (final step in daily.todaysPlan!.steps) {
        await daily.completeStep(daily.todaysPlan!.id, step.id);
      }
      await storage.setOnboardingCompleted(true);
    });

    addTearDown(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storage),
          ChangeNotifierProvider.value(value: content),
          ChangeNotifierProvider.value(value: bible),
          ChangeNotifierProvider.value(value: chat),
          ChangeNotifierProvider.value(value: daily),
          ChangeNotifierProvider.value(value: prayers),
          ChangeNotifierProvider.value(value: study),
          ChangeNotifierProvider.value(value: advent),
        ],
        child: const BiblePathApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bible'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Your daily plan is ready.'), findsNothing);

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump();
    await tester.ensureVisible(find.text('Favorites'));
    await tester.pump();
    await tester.tap(find.text('Favorites'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('John 3:16'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Search books or verses…'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);
    expect(find.text('Prayer journal'), findsOneWidget);
    expect(find.text('Study plans'), findsOneWidget);

    await tester.tap(find.text('Prayer journal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.byTooltip('New prayer'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, 'Guide my day');
    await tester.pump();
    expect(tester.takeException(), isNull);
    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNotNull);
    await tester.runAsync(
      () => prayers.addPrayer('Guide my day', category: 'Personal'),
    );
    expect(prayers.prayers.single.text, 'Guide my day');
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.runAsync(() => storage.setLocale('ru'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    advent.dispose();
    daily.dispose();
    study.dispose();
    chat.dispose();
    prayers.dispose();
    bible.dispose();
    content.dispose();
    storage.dispose();
  });
}
