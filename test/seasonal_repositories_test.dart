import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/advent/advent_repository.dart';
import 'package:bible_path/features/lent/lent_repository.dart';
import 'package:bible_path/features/reading_plan/reading_plan_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late StorageService storage;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('bible_seasonal_');
    Hive.init(directory.path);
    storage = StorageService();
    await storage.init();
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'reading plan restores progress, completion undo and locale switch',
    () async {
      final repo = ReadingPlanRepository(storage);
      await repo.init();
      expect(repo.allPlans, hasLength(11));
      await repo.startPlan('romans-16');
      for (var day = 1; day <= 16; day++) {
        await repo.completeDay('romans-16', day);
      }
      expect(repo.getPlan('romans-16')!.isCompleted, isTrue);
      await repo.uncompleteDay('romans-16', 16);
      expect(repo.getPlan('romans-16')!.isCompleted, isFalse);
      final restored = ReadingPlanRepository(storage);
      await restored.init();
      expect(restored.myPlans.single.completedDays, 15);
      expect(restored.myPlans.single.isCompleted, isFalse);
      expect(await restored.loadLocale('pt'), isTrue);
      expect(restored.myPlans.single.completedDays, 15);
      await restored.removePlan('romans-16');
      expect(restored.myPlans, isEmpty);
      restored.dispose();
      repo.dispose();
    },
  );

  test('seasonal assets parse in all seven locales', () async {
    final lent = LentRepository(storage);
    final advent = AdventRepository(storage);
    final reading = ReadingPlanRepository(storage);
    for (final locale in ['en', 'es', 'pt', 'fr', 'de', 'it', 'ru']) {
      expect(await lent.loadLocale(locale), isTrue, reason: lent.error);
      expect(lent.totalDays, 88);
      expect(lent.getDay(1)!.dailyPrayer, isNotEmpty);
      expect(await reading.loadLocale(locale), isTrue, reason: reading.error);
      await advent.init(locale: locale);
      expect(advent.error, isNull);
      expect(advent.getAllDays(), hasLength(25));
    }
    lent.dispose();
    advent.dispose();
    reading.dispose();
  });

  test(
    'Lent persists progress independently of language and supports undo',
    () async {
      final lent = LentRepository(storage);
      await lent.init();
      await lent.completeDay(1);
      await lent.loadLocale('pt');
      expect(lent.completedDays, 1);
      final restored = LentRepository(storage);
      await restored.init();
      expect(restored.completedDays, 1);
      await restored.uncompleteDay(1);
      expect(restored.completedDays, 0);
      expect(restored.isCompleted, isFalse);
      restored.dispose();
      lent.dispose();
    },
  );
}
