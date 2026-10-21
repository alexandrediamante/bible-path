import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/core/theme/app_theme.dart';
import 'package:bible_path/features/bible/bible_screen.dart';
import 'package:bible_path/features/chat/chat_screen.dart';
import 'package:bible_path/features/daily_plan/daily_plan_screen.dart';
import 'package:bible_path/features/home/home_screen.dart';
import 'package:bible_path/features/more/more_screen.dart';
import 'package:bible_path/features/prayer/prayer_screen.dart';
import 'package:bible_path/features/profile/profile_screen.dart';
import 'package:bible_path/features/settings/settings_screen.dart';
import 'package:bible_path/features/study/study_screen.dart';
import 'package:bible_path/l10n/app_localizations.dart';
import 'package:bible_path/shared/widgets/app_scaffold.dart';

class BiblePathApp extends StatelessWidget {
  const BiblePathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storage, _) {
        final preferences = storage.userPreferences;
        return MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(preferences.locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(preferences.textScale)),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
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
        GoRoute(path: '/study', builder: (_, _) => const StudyScreen()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ],
    ),
  ],
);
