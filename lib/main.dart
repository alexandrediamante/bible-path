import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/app.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/chat/ai_client.dart';
import 'package:bible_path/features/chat/chat_repository.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/daily_plan/daily_plan_repository.dart';
import 'package:bible_path/features/prayer/prayer_repository.dart';
import 'package:bible_path/features/study/study_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    final storage = StorageService();
    await storage.init();

    final content = ContentRepository(storage);
    await content.init();

    final bible = BibleRepository(storage);
    await bible.init();

    final chat = ChatRepository(storage, AiClient(), bible);
    await chat.init();

    final dailyPlan = DailyPlanRepository(storage, content, bible);
    await dailyPlan.init();

    final prayer = PrayerRepository(storage);
    await prayer.init();

    final study = StudyRepository(storage, content);
    await study.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: storage),
          ChangeNotifierProvider.value(value: content),
          ChangeNotifierProvider.value(value: bible),
          ChangeNotifierProvider.value(value: chat),
          ChangeNotifierProvider.value(value: dailyPlan),
          ChangeNotifierProvider.value(value: prayer),
          ChangeNotifierProvider.value(value: study),
        ],
        child: const BiblePathApp(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('Bible Path startup failed: $error\n$stackTrace');
    runApp(_StartupErrorApp(error: error));
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        l10n.startupFailureTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.startupFailureDetails(error.toString()),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
