import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/listen/listen_repository.dart';
import 'package:bible_path/features/bible/bible_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late StorageService storage;
  late ContentRepository content;
  late ListenRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('bible_listen_');
    Hive.init(directory.path);
    storage = StorageService();
    await storage.init();
    content = ContentRepository(storage);
    await content.init();
    repository = ListenRepository(storage, content);
    await repository.init();
  });
  tearDown(() async {
    repository.dispose();
    content.dispose();
    storage.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('loads actual seven-day catalog before init completes', () {
    expect(repository.availablePlans.single.totalDays, 7);
    expect(repository.getDay('listen-scripture', 1)?.title, isNotEmpty);
  });

  test('completion, undo and removal survive repository recreation', () async {
    const id = 'listen-scripture';
    await repository.startPlan(id);
    await repository.startPlan(id);
    await repository.completeDay(id, 99);
    expect(repository.myPlans, hasLength(1));
    expect(repository.myPlans.single.completedDays, 0);
    for (var day = 1; day <= 7; day++) {
      await repository.completeDay(id, day);
    }
    expect(repository.myPlans.single.isCompleted, isTrue);
    await repository.uncompleteDay(id, 7);
    expect(repository.myPlans.single.isCompleted, isFalse);
    final restored = ListenRepository(storage, content);
    await restored.init();
    expect(restored.myPlans.single.completedDays, 6);
    expect(restored.myPlans.single.isCompleted, isFalse);
    await restored.removePlan(id);
    expect(restored.myPlans, isEmpty);
    restored.dispose();
  });

  test('catalog loads in every locale without resetting progress', () async {
    await repository.startPlan('listen-scripture');
    await repository.completeDay('listen-scripture', 1);
    for (final locale in ['en', 'es', 'pt', 'fr', 'de', 'it', 'ru']) {
      await content.loadLocale(locale);
      await repository.init();
      expect(repository.myPlans.single.locale, locale);
      expect(repository.myPlans.single.completedDays, 1);
    }
  });

  test('canonical ranges are complete and use selected translation', () async {
    final bible = BibleRepository(storage);
    await bible.init();
    expect(bible.passageByCanonicalReference('PSA.23.1-6'), hasLength(6));
    expect(bible.passageByCanonicalReference('PSA.23.6-1'), isEmpty);
    expect(bible.passageByCanonicalReference('PSA.23.1-999'), isEmpty);
    expect(bible.passageByCanonicalReference('invalid'), isEmpty);
    expect(bible.passageByCanonicalReference('GEN.1.1-31'), hasLength(31));
    await bible.setVersion('porbr2018');
    expect(bible.passageByCanonicalReference('JHN.10.1-18'), hasLength(18));
    bible.dispose();
  });
}
