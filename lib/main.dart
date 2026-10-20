import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/app.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/models/user_preferences.dart';
import 'features/bible/bible_repository.dart';
import 'features/chat/chat_repository.dart';
import 'features/daily_plan/daily_plan_repository.dart';
import 'features/prayer/prayer_repository.dart';
import 'features/study/study_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure window for macOS
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Bible Path',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(UserPreferencesAdapter());
  await Hive.openBox<UserPreferences>('user_preferences');

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  // Initialize repositories
  final bibleRepository = BibleRepository();
  await bibleRepository.init();

  final chatRepository = ChatRepository();
  await chatRepository.init();

  final dailyPlanRepository = DailyPlanRepository();
  await dailyPlanRepository.init();

  final prayerRepository = PrayerRepository();
  await prayerRepository.init();

  final studyRepository = StudyRepository();
  await studyRepository.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => storageService),
        ChangeNotifierProvider(create: (_) => notificationService),
        ChangeNotifierProvider(create: (_) => bibleRepository),
        ChangeNotifierProvider(create: (_) => chatRepository),
        ChangeNotifierProvider(create: (_) => dailyPlanRepository),
        ChangeNotifierProvider(create: (_) => prayerRepository),
        ChangeNotifierProvider(create: (_) => studyRepository),
      ],
      child: const BiblePathApp(),
    ),
  );
}