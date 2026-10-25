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
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const OnboardingScreen(),
        ),
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
    await tester.runAsync(() async {
      await tester.tap(find.text('Skip'));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pumpAndSettle();
    expect(find.text('Home reached'), findsOneWidget);
    expect(storage.userPreferences.hasCompletedOnboarding, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    bible.dispose();
    content.dispose();
    storage.dispose();
    await tester.runAsync(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });
  });
}
