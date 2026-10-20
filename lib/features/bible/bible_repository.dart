import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class BibleRepository extends ChangeNotifier {
  Map<String, dynamic> _bibleData = {};
  List<String> _books = [];
  String _currentVersion = 'ASV';
  bool _isLoading = false;

  Map<String, dynamic> get bibleData => _bibleData;
  List<String> get books => _books;
  String get currentVersion => _currentVersion;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load embedded Bible data (ASV - public domain)
      final String response = await rootBundle.loadString('assets/bible/asv.json');
      _bibleData = json.decode(response);
      _books = _bibleData.keys.toList()..sort((a, b) => _getBookOrder(a).compareTo(_getBookOrder(b)));
    } catch (e) {
      // Fallback: create minimal structure
      _createFallbackBible();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _createFallbackBible() {
    _books = [
      'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
      'Joshua', 'Judges', 'Ruth', '1 Samuel', '2 Samuel',
      '1 Kings', '2 Kings', '1 Chronicles', '2 Chronicles', 'Ezra',
      'Nehemiah', 'Esther', 'Job', 'Psalms', 'Proverbs',
      'Ecclesiastes', 'Song of Solomon', 'Isaiah', 'Jeremiah', 'Lamentations',
      'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
      'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk',
      'Zephaniah', 'Haggai', 'Zechariah', 'Malachi',
      'Matthew', 'Mark', 'Luke', 'John', 'Acts',
      'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians',
      'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians', '1 Timothy',
      '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James',
      '1 Peter', '2 Peter', '1 John', '2 John', '3 John',
      'Jude', 'Revelation',
    ];

    for (final book in _books) {
      _bibleData[book] = {};
      for (int i = 1; i <= _getChapterCount(book); i++) {
        _bibleData[book][i.toString()] = {};
        for (int j = 1; j <= _getVerseCount(book, i); j++) {
          _bibleData[book][i.toString()][j.toString()] =
            '$book $i:$j - [Verse text would be loaded from asset]';
        }
      }
    }
  }

  int _getBookOrder(String book) {
    final order = _books.indexOf(book);
    return order >= 0 ? order : 999;
  }

  int _getChapterCount(String book) {
    const chapterCounts = {
      'Genesis': 50, 'Exodus': 40, 'Leviticus': 27, 'Numbers': 36, 'Deuteronomy': 34,
      'Joshua': 24, 'Judges': 21, 'Ruth': 4, '1 Samuel': 31, '2 Samuel': 24,
      '1 Kings': 22, '2 Kings': 25, '1 Chronicles': 29, '2 Chronicles': 36, 'Ezra': 10,
      'Nehemiah': 13, 'Esther': 10, 'Job': 42, 'Psalms': 150, 'Proverbs': 31,
      'Ecclesiastes': 12, 'Song of Solomon': 8, 'Isaiah': 66, 'Jeremiah': 52, 'Lamentations': 5,
      'Ezekiel': 48, 'Daniel': 12, 'Hosea': 14, 'Joel': 3, 'Amos': 9,
      'Obadiah': 1, 'Jonah': 4, 'Micah': 7, 'Nahum': 3, 'Habakkuk': 3,
      'Zephaniah': 3, 'Haggai': 2, 'Zechariah': 14, 'Malachi': 4,
      'Matthew': 28, 'Mark': 16, 'Luke': 24, 'John': 21, 'Acts': 28,
      'Romans': 16, '1 Corinthians': 16, '2 Corinthians': 13, 'Galatians': 6, 'Ephesians': 6,
      'Philippians': 4, 'Colossians': 4, '1 Thessalonians': 5, '2 Thessalonians': 3, '1 Timothy': 6,
      '2 Timothy': 4, 'Titus': 3, 'Philemon': 1, 'Hebrews': 13, 'James': 5,
      '1 Peter': 5, '2 Peter': 3, '1 John': 5, '2 John': 1, '3 John': 1,
      'Jude': 1, 'Revelation': 22,
    };
    return chapterCounts[book] ?? 1;
  }

  int _getVerseCount(String book, int chapter) {
    // Simplified - return reasonable defaults
    return 30;
  }

  List<Map<String, dynamic>> getChapters(String book) {
    final bookData = _bibleData[book];
    if (bookData == null) return [];

    return bookData.entries.map((entry) {
      return {
        'chapter': int.parse(entry.key),
        'verses': entry.value,
      };
    }).toList()..sort((a, b) => a['chapter'].compareTo(b['chapter']));
  }

  Map<String, dynamic>? getChapter(String book, int chapter) {
    final bookData = _bibleData[book];
    if (bookData == null) return null;
    return bookData[chapter.toString()] as Map<String, dynamic>?;
  }

  String? getVerse(String book, int chapter, int verse) {
    final chapterData = getChapter(book, chapter);
    if (chapterData == null) return null;
    return chapterData[verse.toString()] as String?;
  }

  List<String> getAvailableVersions() {
    return ['ASV', 'KJV', 'WEB']; // Public domain versions
  }

  Future<void> setVersion(String version) async {
    if (_currentVersion != version) {
      _currentVersion = version;
      _isLoading = true;
      notifyListeners();

      try {
        final String response = await rootBundle.loadString('assets/bible/${version.toLowerCase()}.json');
        _bibleData = json.decode(response);
        _books = _bibleData.keys.toList()..sort((a, b) => _getBookOrder(a).compareTo(_getBookOrder(b)));
      } catch (e) {
        debugPrint('Failed to load version $version: $e');
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, String>> searchVerses(String query) {
    final results = <Map<String, String>>[];
    final lowerQuery = query.toLowerCase();

    for (final book in _books) {
      final bookData = _bibleData[book];
      if (bookData == null) continue;

      for (final chapterEntry in bookData.entries) {
        final chapter = chapterEntry.key;
        final verses = chapterEntry.value as Map<String, dynamic>;

        for (final verseEntry in verses.entries) {
          final verse = verseEntry.key;
          final text = verseEntry.value.toString().toLowerCase();

          if (text.contains(lowerQuery)) {
            results.add({
              'book': book,
              'chapter': chapter,
              'verse': verse,
              'text': verseEntry.value.toString(),
            });

            if (results.length >= 50) break;
          }
        }
        if (results.length >= 50) break;
      }
      if (results.length >= 50) break;
    }

    return results;
  }
}