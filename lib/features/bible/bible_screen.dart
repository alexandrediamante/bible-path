import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/storage_service.dart';
import 'features/bible/bible_repository.dart';
import 'shared/widgets/bible_book_card.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  String _searchQuery = '';
  String _selectedBook = '';
  int _selectedChapter = 1;
  bool _showChapters = false;

  @override
  Widget build(BuildContext context) {
    final bibleRepo = context.watch<BibleRepository>();
    final storage = context.watch<StorageService>();
    final isDark = storage.userPreferences?.isDarkMode ?? false;
    final books = bibleRepo.books;

    if (bibleRepo.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredBooks = _searchQuery.isEmpty
        ? books
        : books.where((b) => b.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.black12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: storage.userPreferences?.preferredBibleVersion ?? 'ASV',
                items: bibleRepo.getAvailableVersions().map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(v),
                )).toList(),
                onChanged: (v) {
                  if (v != null) {
                    storage.setPreferredBibleVersion(v);
                    bibleRepo.setVersion(v);
                  }
                },
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: Row(
            children: [
              // Book List
              if (!_showChapters || _selectedBook.isEmpty)
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      final isSelected = book == _selectedBook;
                      return BibleBookCard(
                        book: book,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedBook = book;
                            _selectedChapter = 1;
                            _showChapters = true;
                          });
                        },
                      );
                    },
                  ),
                ),

              // Chapter List
              if (_showChapters && _selectedBook.isEmpty)
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a book to start reading',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Chapter Content
              if (_showChapters && _selectedBook.isNotEmpty)
                Expanded(
                  flex: 3,
                  child: _BibleChapterView(
                    book: _selectedBook,
                    chapter: _selectedChapter,
                    onChapterChanged: (chapter) => setState(() => _selectedChapter = chapter),
                    onBack: () => setState(() => _showChapters = false),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BibleChapterView extends StatelessWidget {
  final String book;
  final int chapter;
  final ValueChanged<int> onChapterChanged;
  final VoidCallback onBack;

  const _BibleChapterView({
    required this.book,
    required this.chapter,
    required this.onChapterChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bibleRepo = context.watch<BibleRepository>();
    final storage = context.watch<StorageService>();
    final isDark = storage.userPreferences?.isDarkMode ?? false;
    final chapterData = bibleRepo.getChapter(book, chapter);
    final totalChapters = bibleRepo.getChapters(book).length;

    return Column(
      children: [
        // Chapter Navigation Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$book $chapter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.navigate_before_rounded),
                    onPressed: chapter > 1 ? () => onChapterChanged(chapter - 1) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$chapter / $totalChapters',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next_rounded),
                    onPressed: chapter < totalChapters ? () => onChapterChanged(chapter + 1) : null,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chapter Content
        Expanded(
          child: chapterData == null
              ? Center(
                  child: Text(
                    'Chapter not available',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: chapterData.length,
                  itemBuilder: (context, index) {
                    final verseNum = index + 1;
                    final verseText = chapterData[verseNum.toString()] ?? '';
                    return _VerseTile(
                      verse: verseNum,
                      text: verseText,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _VerseTile extends StatelessWidget {
  final int verse;
  final String text;

  const _VerseTile({required this.verse, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storage = context.watch<StorageService>();
    final isFavorite = storage.userPreferences?.favoriteVerses.contains('${verse}') ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse Number
          Container(
            width: 40,
            alignment: Alignment.topRight,
            child: Text(
              '$verse',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Verse Text
          Expanded(
            child: SelectableText(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            onSelected: (value) {
              switch (value) {
                case 'favorite':
                  // Toggle favorite
                  break;
                case 'share':
                  // Share verse
                  break;
                case 'copy':
                  // Copy verse
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Share Verse'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Copy Text'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}