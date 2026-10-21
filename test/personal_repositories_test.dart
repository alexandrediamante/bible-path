import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/prayer/prayer_repository.dart';
import 'package:bible_path/features/study/study_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late StorageService storage;
  late ContentRepository content;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'bible_path_personal_',
    );
    Hive.init(tempDirectory.path);
    storage = StorageService();
    await storage.init();
    content = ContentRepository(storage);
    await content.init();
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('prayer journal persists archive state', () async {
    final repository = PrayerRepository(storage);
    await repository.init();
    await repository.addPrayer('Guide my next step', category: 'Guidance');
    final prayer = repository.prayers.single;

    await repository.updatePrayer(
      prayer.id,
      text: 'Guide my family',
      category: 'family',
    );
    await repository.setArchived(prayer.id, true);

    final restored = PrayerRepository(storage);
    await restored.init();
    expect(restored.prayers.single.text, 'Guide my family');
    expect(restored.prayers.single.category, 'family');
    expect(restored.prayers.single.isArchived, isTrue);
  });

  test('study plan has stable seven-day progress and no duplicates', () async {
    final repository = StudyRepository(storage, content);
    await repository.init();
    final plan = repository.availablePlans.single;

    expect(plan.id, 'seven-days-of-hope');
    expect(plan.lessons, hasLength(7));

    await repository.startPlan(plan.id);
    await repository.startPlan(plan.id);
    expect(repository.myPlans, hasLength(1));

    for (var day = 1; day <= 7; day++) {
      await repository.completeDay(plan.id, day);
    }
    expect(repository.myPlans.single.isCompleted, isTrue);

    final restored = StudyRepository(storage, content);
    await restored.init();
    expect(restored.myPlans.single.completedDays, 7);
    expect(restored.myPlans.single.isCompleted, isTrue);
  });

  test('failed locale load keeps the previous content', () async {
    final previous = content.devotional;

    expect(await content.loadLocale('missing'), isFalse);
    expect(content.devotional, same(previous));
    expect(content.error, isNotNull);
  });

  test('localized content switches without losing study progress', () async {
    final repository = StudyRepository(storage, content);
    await repository.init();
    await repository.startPlan('seven-days-of-hope');
    await repository.completeDay('seven-days-of-hope', 1);

    await storage.setLocale('pt');
    await content.loadLocale('pt');

    expect(repository.myPlans.single.title, 'Sete dias de esperança');
    expect(repository.myPlans.single.completedDays, 1);
  });
}
