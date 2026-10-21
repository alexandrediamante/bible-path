import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/daily_plan/daily_plan_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late StorageService storage;
  late ContentRepository content;
  late BibleRepository bible;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('bible_path_test_');
    Hive.init(tempDirectory.path);
    storage = StorageService();
    await storage.init();
    content = ContentRepository(storage);
    await content.init();
    bible = BibleRepository(storage);
    await bible.init();
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('regenerates localized content without losing completion', () async {
    final repository = DailyPlanRepository(storage, content, bible);
    await repository.init();
    final firstStep = repository.todaysPlan!.steps.first;
    await repository.completeStep(repository.todaysPlan!.id, firstStep.id);

    await storage.setLocale('pt');
    await content.loadLocale('pt');
    await bible.setVersion('porbr2018');

    final localized = repository.todaysPlan!;
    expect(
      content.devotional!.days.any((day) => day.title == localized.theme),
      isTrue,
    );
    expect(localized.steps.first.content, isNotEmpty);
    expect(localized.steps.first.isCompleted, isTrue);
  });

  test('uses the date key for completion and restores progress', () async {
    final repository = DailyPlanRepository(storage, content, bible);
    await repository.init();
    final plan = repository.todaysPlan!;

    expect(plan.id, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));

    for (final step in plan.steps) {
      await repository.completeStep(plan.id, step.id);
    }

    expect(plan.isCompleted, isTrue);
    expect(repository.completedPlanDates, contains(plan.id));
    expect(repository.currentStreak, 1);

    final restored = DailyPlanRepository(storage, content, bible);
    await restored.init();

    expect(restored.todaysPlan!.isCompleted, isTrue);
    expect(restored.todaysPlan!.completedSteps, plan.totalSteps);
    expect(restored.completedPlanDates, contains(plan.id));
  });
}
