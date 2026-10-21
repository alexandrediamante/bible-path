import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String? _selectedBook;
  int _selectedChapter = 1;
  String _query = '';
  bool _showFavorites = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<BibleRepository>();
    final requestedFavorites =
        GoRouterState.of(context).uri.queryParameters['favorites'] == '1';
    final showFavorites = _showFavorites || requestedFavorites;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.navBible,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: showFavorites ? l10n.books : l10n.favorites,
                    onPressed: () {
                      if (requestedFavorites) context.go('/bible');
                      setState(() {
                        _showFavorites = !showFavorites;
                        _selectedBook = null;
                      });
                    },
                    icon: Icon(
                      showFavorites
                          ? Icons.menu_book_rounded
                          : Icons.favorite_rounded,
                    ),
                  ),
                  if (repository.translations.isNotEmpty)
                    DropdownButton<String>(
                      value: repository.currentVersion,
                      items: [
                        for (final translation in repository.translations)
                          DropdownMenuItem(
                            value: translation.abbreviation,
                            child: Text(translation.abbreviation),
                          ),
                      ],
                      onChanged: repository.isLoading
                          ? null
                          : (value) async {
                              if (value == null) return;
                              final loaded = await repository.setVersion(value);
                              if (!loaded && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.translationUnavailable),
                                  ),
                                );
                              }
                              if (loaded && mounted) {
                                setState(() {
                                  _selectedBook = null;
                                  _selectedChapter = 1;
                                });
                              }
                            },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchBooksOrVerses,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchDebounce?.cancel();
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
                onChanged: (value) {
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 250),
                    () {
                      if (mounted) setState(() => _query = value.trim());
                    },
                  );
                },
              ),
            ],
          ),
        ),
        if (repository.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(child: _content(repository, showFavorites: showFavorites)),
      ],
    );
  }

  Widget _content(BibleRepository repository, {required bool showFavorites}) {
    final l10n = AppLocalizations.of(context);
    if (repository.error != null && repository.books.isEmpty) {
      return _LoadError(
        message: l10n.bibleContentUnavailable,
        onRetry: repository.init,
      );
    }
    if (_query.isNotEmpty) {
      return _SearchResults(
        results: repository.searchVerses(_query),
        onSelected: (book, chapter) {
          setState(() {
            _selectedBook = book;
            _selectedChapter = chapter;
            _query = '';
            _searchController.clear();
          });
        },
      );
    }
    if (showFavorites) {
      final keys = context
          .watch<StorageService>()
          .userPreferences
          .favoriteVerses;
      final verses = keys
          .map(repository.verseFromKey)
          .whereType<BibleVerse>()
          .toList();
      return _FavoriteResults(verses: verses);
    }
    if (_selectedBook == null) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
        itemCount: repository.books.length,
        itemBuilder: (context, index) {
          final book = repository.books[index];
          return ListTile(
            minTileHeight: 52,
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(book),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => setState(() {
              _selectedBook = book;
              _selectedChapter = 1;
            }),
          );
        },
      );
    }

    return _ChapterView(
      book: _selectedBook!,
      chapter: _selectedChapter,
      onBack: () => setState(() => _selectedBook = null),
      onChapterChanged: (chapter) => setState(() => _selectedChapter = chapter),
    );
  }
}

class _ChapterView extends StatelessWidget {
  const _ChapterView({
    required this.book,
    required this.chapter,
    required this.onBack,
    required this.onChapterChanged,
  });

  final String book;
  final int chapter;
  final VoidCallback onBack;
  final ValueChanged<int> onChapterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<BibleRepository>();
    final verses = repository.getChapter(book, chapter);
    final chapterCount = repository.getChapters(book).length;
    final entries = verses?.entries.toList()
      ?..sort(
        (left, right) => int.parse(left.key).compareTo(int.parse(right.key)),
      );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.books,
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Text(
                  l10n.chapterTitle(book, chapter),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.previousChapter,
                onPressed: chapter > 1
                    ? () => onChapterChanged(chapter - 1)
                    : null,
                icon: const Icon(Icons.navigate_before_rounded),
              ),
              Text(l10n.chapterProgress(chapter, chapterCount)),
              IconButton(
                tooltip: l10n.nextChapter,
                onPressed: chapter < chapterCount
                    ? () => onChapterChanged(chapter + 1)
                    : null,
                icon: const Icon(Icons.navigate_next_rounded),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: entries == null || entries.isEmpty
              ? Center(child: Text(l10n.chapterNotAvailable))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _VerseTile(
                      book: book,
                      chapter: chapter,
                      verse: int.parse(entry.key),
                      text: entry.value as String,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _VerseTile extends StatelessWidget {
  const _VerseTile({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  final String book;
  final int chapter;
  final int verse;
  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.read<BibleRepository>();
    final storage = context.watch<StorageService>();
    final key = repository.verseKey(book, chapter, verse);
    final favorite = storage.userPreferences.favoriteVerses.contains(key);
    final shareText = l10n.verseShareText(
      book,
      chapter,
      verse,
      text,
      repository.currentVersion,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '$verse',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.verseActions,
            onSelected: (action) async {
              switch (action) {
                case 'favorite':
                  if (favorite) {
                    await storage.removeFavoriteVerse(key);
                  } else {
                    await storage.addFavoriteVerse(key);
                  }
                case 'copy':
                  await Clipboard.setData(ClipboardData(text: shareText));
                  if (context.mounted) _showCopied(context);
                case 'share':
                  try {
                    await SharePlus.instance.share(
                      ShareParams(text: shareText),
                    );
                  } catch (_) {
                    await Clipboard.setData(ClipboardData(text: shareText));
                    if (context.mounted) _showCopied(context);
                  }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'favorite',
                child: Text(favorite ? l10n.removeFavorite : l10n.addFavorite),
              ),
              PopupMenuItem(value: 'copy', child: Text(l10n.copy)),
              PopupMenuItem(value: 'share', child: Text(l10n.share)),
            ],
          ),
        ],
      ),
    );
  }

  void _showCopied(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.verseCopied)));
  }
}

class _FavoriteResults extends StatelessWidget {
  const _FavoriteResults({required this.verses});

  final List<BibleVerse> verses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (verses.isEmpty) return Center(child: Text(l10n.noResults));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
      itemCount: verses.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final verse = verses[index];
        return ListTile(
          leading: const Icon(Icons.favorite_rounded),
          title: Text(verse.reference),
          subtitle: SelectableText(verse.text),
        );
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.onSelected});

  final List<Map<String, String>> results;
  final void Function(String book, int chapter) onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (results.isEmpty) return Center(child: Text(l10n.noResults));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = results[index];
        final chapter = int.parse(result['chapter']!);
        return ListTile(
          title: Text(
            l10n.verseReference(result['book']!, chapter, result['verse']!),
          ),
          subtitle: Text(
            result['text']!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => onSelected(result['book']!, chapter),
        );
      },
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
