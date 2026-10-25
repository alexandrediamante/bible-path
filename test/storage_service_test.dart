import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:bible_path/core/services/storage_service.dart';

void main() {
  late Directory tempDirectory;
  late StorageService storage;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'bible_path_storage_',
    );
    Hive.init(tempDirectory.path);
    storage = StorageService();
    await storage.init();
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('persists preferences but excludes the AI token from exports', () async {
    await storage.setLocale('pt');
    await storage.addFavoriteVerse('engwebp:JHN:3:16');
    await storage.setAiAuthToken('personal-secret');
    await storage.write('prayers', [
      {'id': 'one', 'text': 'A prayer'},
    ]);

    final export = storage.exportData();
    final preferences = export['preferences'] as Map<String, dynamic>;

    expect(preferences['locale'], 'pt');
    expect(preferences['favoriteVerses'], contains('engwebp:JHN:3:16'));
    expect(preferences.containsKey('aiAuthToken'), isFalse);
    expect(export['prayers'], isNotNull);

    final restored = StorageService();
    await restored.init();
    expect(restored.userPreferences.locale, 'pt');
    expect(restored.userPreferences.aiAuthToken, 'personal-secret');
  });

  test('reset clears personal data and secrets', () async {
    await storage.setAiAuthToken('personal-secret');
    await storage.write('prayers', [
      {'id': 'one'},
    ]);

    await storage.reset();

    expect(storage.userPreferences.aiAuthToken, isNull);
    expect(storage.read<Object>('prayers'), isNull);
    expect(storage.exportData()['schemaVersion'], 1);
  });

  group('retryStorageInitialization', () {
    test('recovers when IndexedDB closes during startup', () async {
      var attempts = 0;
      var recoveries = 0;
      final waits = <Duration>[];

      await retryStorageInitialization(
        () async {
          attempts++;
          if (attempts < 3) {
            throw StateError(
              'InvalidStateError: database connection is closing',
            );
          }
        },
        recover: () async => recoveries++,
        wait: (delay) async => waits.add(delay),
      );

      expect(attempts, 3);
      expect(recoveries, 2);
      expect(waits, const [
        Duration(milliseconds: 150),
        Duration(milliseconds: 300),
      ]);
    });

    test('does not retry unrelated storage errors', () async {
      var recoveries = 0;

      await expectLater(
        retryStorageInitialization(
          () async => throw StateError('corrupt preferences'),
          recover: () async => recoveries++,
          wait: (_) async {},
        ),
        throwsA(isA<StateError>()),
      );

      expect(recoveries, 0);
    });
  });
}
