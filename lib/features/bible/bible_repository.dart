import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bible_path/core/services/storage_service.dart';

class BibleTranslation {
  const BibleTranslation({
    required this.id,
    required this.locale,
    required this.name,
    required this.abbreviation,
    required this.asset,
    required this.license,
    required this.licenseUrl,
    required this.sourceUrl,
    required this.attribution,
  });

  final String id;
  final String locale;
  final String name;
  final String abbreviation;
  final String asset;
  final String license;
  final String licenseUrl;
  final String sourceUrl;
  final String attribution;

  factory BibleTranslation.fromJson(Map<String, dynamic> json) {
    return BibleTranslation(
      id: json['id'] as String,
      locale: json['locale'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      asset: json['asset'] as String,
      license: json['license'] as String,
      licenseUrl: json['licenseUrl'] as String,
      sourceUrl: json['sourceUrl'] as String,
      attribution: json['attribution'] as String,
    );
  }
}

class BibleVerse {
  const BibleVerse({
    required this.bookId,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  final String bookId;
  final String book;
  final int chapter;
  final int verse;
  final String text;

  String get reference => '$book $chapter:$verse';
}

class BibleRepository extends ChangeNotifier {
  BibleRepository(this._storage);

  final StorageService _storage;
  Map<String, Map<int, Map<int, String>>> _data = {};
  final Map<String, String> _bookIds = {};
  List<String> _books = [];
  List<BibleTranslation> _translations = [];
  BibleTranslation? _currentTranslation;
  bool _isLoading = false;
  String? _error;

  List<String> get books => List.unmodifiable(_books);
  List<BibleTranslation> get translations => List.unmodifiable(_translations);
  String get currentVersion => _currentTranslation?.abbreviation ?? 'WEB';
  String get currentTranslationId => _currentTranslation?.id ?? 'engwebp';
  BibleTranslation? get currentTranslation => _currentTranslation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _translations = await _loadTranslationManifest();
      final preferences = _storage.userPreferences;
      final translation =
          _findTranslation(preferences.preferredBibleVersion) ??
          translationForLocale(preferences.locale) ??
          _translations.first;
      await _loadTranslation(translation);
      if (preferences.preferredBibleVersion != translation.id) {
        await _storage.setPreferredBibleVersion(translation.id);
      }
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> getAvailableVersions() =>
      _translations.map((item) => item.abbreviation).toList();

  BibleTranslation? translationForLocale(String locale) {
    for (final translation in _translations) {
      if (translation.locale == locale) return translation;
    }
    return null;
  }

  Future<bool> setVersion(String value) async {
    final translation = _findTranslation(value);
    if (translation == null || translation.id == _currentTranslation?.id) {
      return translation != null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _loadTranslation(translation);
      await _storage.setPreferredBibleVersion(translation.id);
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getChapters(String book) {
    final chapters = _data[book];
    if (chapters == null) return const [];
    return chapters.entries
        .map(
          (entry) => {'chapter': entry.key, 'verses': _stringMap(entry.value)},
        )
        .toList()
      ..sort((a, b) => (a['chapter'] as int).compareTo(b['chapter'] as int));
  }

  Map<String, dynamic>? getChapter(String book, int chapter) {
    final verses = _data[book]?[chapter];
    return verses == null ? null : _stringMap(verses);
  }

  String? getVerse(String book, int chapter, int verse) =>
      _data[book]?[chapter]?[verse];

  BibleVerse? verseByCanonicalReference(String reference) {
    final match = RegExp(
      r'^([1-3]?[A-Z]{2,3})\.(\d+)\.(\d+)$',
    ).firstMatch(reference.trim().toUpperCase());
    if (match == null) return null;
    final bookId = match.group(1)!;
    final chapter = int.parse(match.group(2)!);
    final verse = int.parse(match.group(3)!);
    String? book;
    for (final entry in _bookIds.entries) {
      if (entry.value == bookId) {
        book = entry.key;
        break;
      }
    }
    if (book == null) return null;
    final text = getVerse(book, chapter, verse);
    if (text == null) return null;
    return BibleVerse(
      bookId: bookId,
      book: book,
      chapter: chapter,
      verse: verse,
      text: text,
    );
  }

  /// Returns a complete canonical range, or nothing if any verse is unavailable.
  List<BibleVerse> passageByCanonicalReference(String reference) {
    final match = RegExp(
      r'^([1-3]?[A-Z]{2,3})\.(\d+)\.(\d+)(?:-(\d+))?$',
    ).firstMatch(reference);
    if (match == null) return const [];
    final first = int.parse(match.group(3)!);
    final last = int.parse(match.group(4) ?? match.group(3)!);
    if (last < first || last - first > 200) return const [];
    final verses = <BibleVerse>[];
    for (var number = first; number <= last; number++) {
      final verse = verseByCanonicalReference(
        '${match.group(1)}.${match.group(2)}.$number',
      );
      if (verse == null) return const [];
      verses.add(verse);
    }
    return verses;
  }

  String verseKey(String book, int chapter, int verse) {
    final bookId = _bookIds[book] ?? book;
    return '$currentTranslationId:$bookId:$chapter:$verse';
  }

  BibleVerse? verseFromKey(String key) {
    final parts = key.split(':');
    if (parts.length != 4 || parts.first != currentTranslationId) return null;
    return verseByCanonicalReference('${parts[1]}.${parts[2]}.${parts[3]}');
  }

  List<Map<String, String>> searchVerses(String query, {int limit = 50}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    final explicit = _findExplicitReference(query);
    if (explicit != null) return [_resultMap(explicit)];
    final results = <Map<String, String>>[];

    for (final book in _books) {
      final bookMatches = book.toLowerCase().contains(normalized);
      for (final chapter in _data[book]!.entries) {
        for (final verse in chapter.value.entries) {
          if (bookMatches || verse.value.toLowerCase().contains(normalized)) {
            results.add({
              'book': book,
              'bookId': _bookIds[book] ?? book,
              'chapter': chapter.key.toString(),
              'verse': verse.key.toString(),
              'text': verse.value,
            });
            if (results.length >= limit) return results;
          }
        }
      }
    }
    return results;
  }

  BibleVerse? _findExplicitReference(String query) {
    final canonical = RegExp(
      r'([1-3]?[A-Za-z]{2,3}\.\d+\.\d+)',
    ).firstMatch(query);
    if (canonical != null) {
      final verse = verseByCanonicalReference(canonical.group(1)!);
      if (verse != null) return verse;
    }

    for (final book in _books) {
      final match = RegExp(
        '${RegExp.escape(book)}\\s+(\\d+):(\\d+)',
        caseSensitive: false,
      ).firstMatch(query);
      if (match == null) continue;
      final chapter = int.parse(match.group(1)!);
      final verseNumber = int.parse(match.group(2)!);
      final text = getVerse(book, chapter, verseNumber);
      if (text == null) return null;
      return BibleVerse(
        bookId: _bookIds[book] ?? book,
        book: book,
        chapter: chapter,
        verse: verseNumber,
        text: text,
      );
    }
    return null;
  }

  static Map<String, String> _resultMap(BibleVerse verse) => {
    'book': verse.book,
    'bookId': verse.bookId,
    'chapter': verse.chapter.toString(),
    'verse': verse.verse.toString(),
    'text': verse.text,
  };

  List<BibleVerse> contextForQuestion(String query, {int limit = 8}) {
    final exact = searchVerses(query, limit: limit);
    final results = <String, Map<String, String>>{
      for (final item in exact) _mapKey(item): item,
    };
    if (results.isEmpty) {
      final tokens =
          query
              .toLowerCase()
              .split(RegExp(r'[\s,.;:!?()\[\]{}"“”]+'))
              .where(
                (token) =>
                    token.length >= 4 && !_questionStopWords.contains(token),
              )
              .toSet()
              .toList()
            ..sort((left, right) => right.length.compareTo(left.length));
      for (final token in tokens.take(3)) {
        for (final item in searchVerses(token, limit: limit - results.length)) {
          results.putIfAbsent(_mapKey(item), () => item);
          if (results.length >= limit) break;
        }
        if (results.length >= limit) break;
      }
    }

    return results.values
        .map(
          (item) => BibleVerse(
            bookId: item['bookId']!,
            book: item['book']!,
            chapter: int.parse(item['chapter']!),
            verse: int.parse(item['verse']!),
            text: item['text']!,
          ),
        )
        .toList();
  }

  static String _mapKey(Map<String, String> item) =>
      '${item['bookId']}:${item['chapter']}:${item['verse']}';

  Future<List<BibleTranslation>> _loadTranslationManifest() async {
    final raw = await rootBundle.loadString('assets/bible/translations.json');
    final decoded = jsonDecode(raw);
    final translations =
        (decoded['translations'] as List)
            .whereType<Map>()
            .map(
              (item) =>
                  BibleTranslation.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
    if (translations.isEmpty) throw const FormatException('No translations');
    return translations;
  }

  BibleTranslation? _findTranslation(String value) {
    final normalized = value.toLowerCase();
    for (final translation in _translations) {
      if (translation.id.toLowerCase() == normalized ||
          translation.abbreviation.toLowerCase() == normalized) {
        return translation;
      }
    }
    return null;
  }

  Future<void> _loadTranslation(BibleTranslation translation) async {
    final raw = await rootBundle.loadString(translation.asset);
    final decoded = jsonDecode(raw);
    final parsed =
        decoded is Map && decoded['books'] is List
            ? _parseNormalized(Map<String, dynamic>.from(decoded))
            : _parseLegacy(Map<String, dynamic>.from(decoded as Map));
    if (parsed.data.isEmpty) throw const FormatException('Bible is empty');

    _data = parsed.data;
    _bookIds
      ..clear()
      ..addAll(parsed.bookIds);
    _books = parsed.data.keys.toList();
    _currentTranslation = translation;
  }

  _ParsedBible _parseNormalized(Map<String, dynamic> json) {
    final data = <String, Map<int, Map<int, String>>>{};
    final ids = <String, String>{};
    for (final rawBook in (json['books'] as List).whereType<Map>()) {
      final book = Map<String, dynamic>.from(rawBook);
      final id = book['id'] as String;
      final name = book['name'] as String;
      final chapters = <int, Map<int, String>>{};
      for (final rawChapter in (book['chapters'] as List).whereType<Map>()) {
        final chapter = Map<String, dynamic>.from(rawChapter);
        final number = (chapter['number'] as num).toInt();
        final verses = <int, String>{};
        for (final entry in (chapter['verses'] as Map).entries) {
          final verse = int.tryParse(entry.key.toString());
          final text = entry.value?.toString().trim() ?? '';
          if (verse != null && text.isNotEmpty) verses[verse] = text;
        }
        if (verses.isNotEmpty) chapters[number] = verses;
      }
      if (chapters.isNotEmpty) {
        data[name] = chapters;
        ids[name] = id;
      }
    }
    return _ParsedBible(data, ids);
  }

  _ParsedBible _parseLegacy(Map<String, dynamic> json) {
    final data = <String, Map<int, Map<int, String>>>{};
    final ids = <String, String>{};
    for (final bookEntry in json.entries) {
      if (bookEntry.value is! Map) continue;
      final chapters = <int, Map<int, String>>{};
      for (final chapterEntry in (bookEntry.value as Map).entries) {
        final chapter = int.tryParse(chapterEntry.key.toString());
        if (chapter == null || chapterEntry.value is! Map) continue;
        final verses = <int, String>{};
        for (final verseEntry in (chapterEntry.value as Map).entries) {
          final verse = int.tryParse(verseEntry.key.toString());
          final text = verseEntry.value?.toString().trim() ?? '';
          if (verse != null && text.isNotEmpty) verses[verse] = text;
        }
        if (verses.isNotEmpty) chapters[chapter] = verses;
      }
      if (chapters.isNotEmpty) {
        data[bookEntry.key] = chapters;
        ids[bookEntry.key] = _legacyBookIds[bookEntry.key] ?? bookEntry.key;
      }
    }
    return _ParsedBible(data, ids);
  }

  static Map<String, dynamic> _stringMap(Map<int, String> verses) => {
    for (final entry in verses.entries) entry.key.toString(): entry.value,
  };
}

class _ParsedBible {
  const _ParsedBible(this.data, this.bookIds);

  final Map<String, Map<int, Map<int, String>>> data;
  final Map<String, String> bookIds;
}

const _questionStopWords = <String>{
  'which',
  'passages',
  'speak',
  'about',
  'explain',
  'context',
  'what',
  'does',
  'mean',
  'give',
  'short',
  'today',
  'with',
  'more',
  'help',
  'qué',
  'cuales',
  'pasajes',
  'hablan',
  'sobre',
  'explica',
  'contexto',
  'quais',
  'passagens',
  'falam',
  'explique',
  'quels',
  'parlent',
  'contexte',
  'welche',
  'stellen',
  'sprechen',
  'erkläre',
  'kontext',
  'quali',
  'passi',
  'parlano',
  'spiega',
  'contesto',
  'какие',
  'стихи',
  'говорят',
  'объясни',
  'контекст',
};

const _legacyBookIds = <String, String>{
  'Genesis': 'GEN',
  'Exodus': 'EXO',
  'Leviticus': 'LEV',
  'Numbers': 'NUM',
  'Deuteronomy': 'DEU',
  'Joshua': 'JOS',
  'Judges': 'JDG',
  'Ruth': 'RUT',
  '1 Samuel': '1SA',
  '2 Samuel': '2SA',
  '1 Kings': '1KI',
  '2 Kings': '2KI',
  '1 Chronicles': '1CH',
  '2 Chronicles': '2CH',
  'Ezra': 'EZR',
  'Nehemiah': 'NEH',
  'Esther': 'EST',
  'Job': 'JOB',
  'Psalms': 'PSA',
  'Proverbs': 'PRO',
  'Ecclesiastes': 'ECC',
  'Song of Solomon': 'SNG',
  'Isaiah': 'ISA',
  'Jeremiah': 'JER',
  'Lamentations': 'LAM',
  'Ezekiel': 'EZK',
  'Daniel': 'DAN',
  'Hosea': 'HOS',
  'Joel': 'JOL',
  'Amos': 'AMO',
  'Obadiah': 'OBA',
  'Jonah': 'JON',
  'Micah': 'MIC',
  'Nahum': 'NAM',
  'Habakkuk': 'HAB',
  'Zephaniah': 'ZEP',
  'Haggai': 'HAG',
  'Zechariah': 'ZEC',
  'Malachi': 'MAL',
  'Matthew': 'MAT',
  'Mark': 'MRK',
  'Luke': 'LUK',
  'John': 'JHN',
  'Acts': 'ACT',
  'Romans': 'ROM',
  '1 Corinthians': '1CO',
  '2 Corinthians': '2CO',
  'Galatians': 'GAL',
  'Ephesians': 'EPH',
  'Philippians': 'PHP',
  'Colossians': 'COL',
  '1 Thessalonians': '1TH',
  '2 Thessalonians': '2TH',
  '1 Timothy': '1TI',
  '2 Timothy': '2TI',
  'Titus': 'TIT',
  'Philemon': 'PHM',
  'Hebrews': 'HEB',
  'James': 'JAS',
  '1 Peter': '1PE',
  '2 Peter': '2PE',
  '1 John': '1JN',
  '2 John': '2JN',
  '3 John': '3JN',
  'Jude': 'JUD',
  'Revelation': 'REV',
};
