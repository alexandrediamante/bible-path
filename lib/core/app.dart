import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/core/theme/app_theme.dart';
import 'package:bible_path/features/advent/advent_repository.dart';
import 'package:bible_path/features/advent/advent_screen.dart';
import 'package:bible_path/features/bible/bible_screen.dart';
import 'package:bible_path/features/chat/chat_screen.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/daily_plan/daily_plan_screen.dart';
import 'package:bible_path/features/home/home_screen.dart';
import 'package:bible_path/features/holy_calendar/holy_calendar_repository.dart';
import 'package:bible_path/features/holy_calendar/holy_calendar_screen.dart';
import 'package:bible_path/features/lent/lent_repository.dart';
import 'package:bible_path/features/lent/lent_screen.dart';
import 'package:bible_path/features/listen/listen_repository.dart';
import 'package:bible_path/features/listen/listen_screen.dart';
import 'package:bible_path/features/more/more_screen.dart';
import 'package:bible_path/features/onboarding/onboarding_screen.dart';
import 'package:bible_path/features/prayer/prayer_screen.dart';
import 'package:bible_path/features/profile/profile_screen.dart';
import 'package:bible_path/features/reading_plan/reading_plan_repository.dart';
import 'package:bible_path/features/reading_plan/reading_plan_screen.dart';
import 'package:bible_path/features/settings/settings_screen.dart';
import 'package:bible_path/features/study/study_screen.dart';
import 'package:bible_path/l10n/app_localizations.dart';
import 'package:bible_path/shared/widgets/app_scaffold.dart';

class BiblePathApp extends StatelessWidget {
  const BiblePathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<ContentRepository, ListenRepository>(
          create:
              (context) => ListenRepository(
                context.read<StorageService>(),
                context.read<ContentRepository>(),
              )..init(),
          update:
              (context, content, previous) =>
                  previous ??
                  ListenRepository(context.read<StorageService>(), content),
        ),
        ChangeNotifierProvider<LentRepository>(
          create:
              (context) => LentRepository(context.read<StorageService>())
                ..loadLocale(
                  context.read<StorageService>().userPreferences.locale,
                ),
        ),
        ChangeNotifierProvider<ReadingPlanRepository>(
          create:
              (context) => ReadingPlanRepository(context.read<StorageService>())
                ..loadLocale(
                  context.read<StorageService>().userPreferences.locale,
                ),
        ),
        ChangeNotifierProvider<AdventRepository>(
          create: (context) => AdventRepository(context.read<StorageService>()),
        ),
        ChangeNotifierProvider<HolyCalendarRepository>(
          create:
              (context) =>
                  HolyCalendarRepository(context.read<StorageService>())
                    ..init(),
        ),
      ],
      child: Consumer<StorageService>(
        builder: (context, storage, _) {
          final preferences = storage.userPreferences;
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(preferences.locale),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: router,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(preferences.textScale),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Safely read storage - if not available, allow navigation to proceed
    // and let the app handle onboarding check after build
    StorageService? storage;
    try {
      storage = context.read<StorageService>();
    } catch (_) {
      return null; // Storage not available yet, don't redirect
    }

    final hasCompletedOnboarding =
        storage.userPreferences.hasCompletedOnboarding;
    final isOnboardingRoute = state.matchedLocation == '/onboarding';

    // If onboarding not completed and not on onboarding page, redirect to onboarding
    if (!hasCompletedOnboarding && !isOnboardingRoute) {
      return '/onboarding';
    }
    // If onboarding completed and on onboarding page, redirect to home
    if (hasCompletedOnboarding && isOnboardingRoute) {
      return '/home';
    }
    // If at root and onboarding completed, redirect to home
    if (hasCompletedOnboarding && state.matchedLocation == '/') {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/bible', builder: (_, _) => const BibleScreen()),
        GoRoute(path: '/chat', builder: (_, _) => const ChatScreen()),
        GoRoute(
          path: '/daily-plan',
          builder: (_, _) => const DailyPlanScreen(),
        ),
        GoRoute(path: '/more', builder: (_, _) => const MoreScreen()),
        GoRoute(path: '/prayer', builder: (_, _) => const PrayerScreen()),
        GoRoute(path: '/listen', builder: (_, _) => const ListenScreen()),
        GoRoute(path: '/lent', builder: (_, _) => const LentScreen()),
        GoRoute(path: '/advent', builder: (_, _) => const AdventScreen()),
        GoRoute(
          path: '/holy-calendar',
          builder: (_, _) => const HolyCalendarScreen(),
        ),
        GoRoute(
          path: '/reading-plan',
          builder: (_, _) => const ReadingPlanScreen(),
        ),
        GoRoute(
          path: '/reading-plan/:planId',
          builder:
              (context, state) => ReadingPlanDetailScreen(
                planId: state.pathParameters['planId']!,
              ),
        ),
        GoRoute(path: '/study', builder: (_, _) => const StudyScreen()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ],
    ),
  ],
);
