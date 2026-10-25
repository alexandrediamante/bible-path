import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/onboarding/onboarding_screen.dart';
import 'package:bible_path/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('skip completes onboarding, persists and uses GoRouter home', (
    tester,
  ) async {
    await _withOnboarding(tester, (storage, _) async {
      await tester.runAsync(() async {
        await tester.tap(find.text('Skip'));
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pumpAndSettle();
      expect(find.text('Home reached'), findsOneWidget);
      expect(storage.userPreferences.hasCompletedOnboarding, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets(
    'complete mobile flow reaches denomination and persists choices',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _withOnboarding(tester, (storage, bible) async {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Português'));
        await tester.tap(find.text('Contemporary (NIV-style)'));
        await tester.pump();

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Denomination'), findsOneWidget);
        expect(find.text('Welcome to Bible Path'), findsNothing);
        expect(find.text('Complete'), findsOneWidget);

        await tester.tap(find.text('Protestant'));
        await tester.pump();
        await tester.runAsync(() async {
          await tester.tap(find.text('Complete'));
          await Future<void>.delayed(const Duration(milliseconds: 150));
        });
        await tester.pumpAndSettle();

        final preferences = storage.userPreferences;
        expect(find.text('Home reached'), findsOneWidget);
        expect(preferences.hasCompletedOnboarding, isTrue);
        expect(preferences.locale, 'pt');
        expect(preferences.translationStyle, 'contemporary');
        expect(preferences.denomination, 'protestant');
        expect(
          preferences.preferredBibleVersion,
          bible.translationForLocale('pt')!.id,
        );
        expect(tester.takeException(), isNull);
      });
    },
  );
}

Future<void> _withOnboarding(
  WidgetTester tester,
  Future<void> Function(StorageService storage, BibleRepository bible) test,
) async {
  late Directory directory;
  late StorageService storage;
  late ContentRepository content;
  late BibleRepository bible;
  await tester.runAsync(() async {
    directory = await Directory.systemTemp.createTemp('bible_onboarding_');
    Hive.init(directory.path);
    storage = StorageService();
    await storage.init();
    content = ContentRepository(storage);
    await content.init();
    bible = BibleRepository(storage);
    await bible.init();
  });
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/home',
        builder: (_, _) => const Scaffold(body: Text('Home reached')),
      ),
    ],
  );
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storage),
        ChangeNotifierProvider.value(value: content),
        ChangeNotifierProvider.value(value: bible),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  try {
    await test(storage, bible);
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    bible.dispose();
    content.dispose();
    storage.dispose();
    await tester.runAsync(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });
  }
}
