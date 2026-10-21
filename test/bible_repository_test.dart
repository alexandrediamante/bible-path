import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late StorageService storage;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('bible_path_bible_');
    Hive.init(tempDirectory.path);
    storage = StorageService();
    await storage.init();
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('loads all translations and resolves explicit references', () async {
    final repository = BibleRepository(storage);
    await repository.init();

    expect(repository.translations, hasLength(7));
    expect(repository.currentTranslationId, 'engwebp');
    expect(repository.books, hasLength(66));

    final verse = repository.verseByCanonicalReference('JHN.3.16');
    expect(verse, isNotNull);
    expect(verse!.text, contains('God'));

    final result = repository.searchVerses('John 3:16');
    expect(result, hasLength(1));
    expect(result.single['text'], verse.text);
    expect(
      repository.contextForQuestion('Which passages speak about anxiety?'),
      isNotEmpty,
    );
  });

  test('switches data and favorite identity transactionally', () async {
    final repository = BibleRepository(storage);
    await repository.init();
    final englishKey = repository.verseKey('John', 3, 16);
    expect(repository.verseFromKey(englishKey)?.text, isNotEmpty);

    expect(await repository.setVersion('BLIVRE'), isTrue);
    expect(repository.currentTranslationId, 'porbr2018');
    expect(repository.currentTranslation!.locale, 'pt');
    expect(storage.userPreferences.preferredBibleVersion, 'porbr2018');

    final portugueseVerse = repository.verseByCanonicalReference('JHN.3.16');
    expect(portugueseVerse, isNotNull);
    expect(portugueseVerse!.text, isNotEmpty);
    expect(repository.verseKey(portugueseVerse.book, 3, 16), isNot(englishKey));

    final before = repository.currentTranslationId;
    expect(await repository.setVersion('missing-version'), isFalse);
    expect(repository.currentTranslationId, before);
  });
}
