import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/models/user_preferences.dart';
import 'features/home/home_screen.dart';
import 'features/bible/bible_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/daily_plan/daily_plan_screen.dart';
import 'features/prayer/prayer_screen.dart';
import 'features/study/study_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'shared/widgets/app_scaffold.dart';
import 'shared/widgets/custom_title_bar.dart';

class BiblePathApp extends StatelessWidget {
  const BiblePathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storage, _) {
        final isDark = storage.userPreferences?.isDarkMode ?? false;
        final locale = storage.userPreferences?.locale ?? 'en';

        return MaterialApp.router(
          title: 'Bible Path',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(locale),
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('pt'),
            Locale('fr'),
            Locale('de'),
            Locale('it'),
            Locale('ru'),
          ],
          routerConfig: _router,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  storage.userPreferences?.textScale ?? 1.0,
                ),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/bible',
          name: 'bible',
          builder: (context, state) => const BibleScreen(),
        ),
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/daily-plan',
          name: 'daily-plan',
          builder: (context, state) => const DailyPlanScreen(),
        ),
        GoRoute(
          path: '/prayer',
          name: 'prayer',
          builder: (context, state) => const PrayerScreen(),
        ),
        GoRoute(
          path: '/study',
          name: 'study',
          builder: (context, state) => const StudyScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);