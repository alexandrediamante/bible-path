import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class BibleVersionSelector extends StatelessWidget {
  const BibleVersionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bible = context.watch<BibleRepository>();
    final storage = context.read<StorageService>();

    if (bible.translations.isEmpty) {
      return ListTile(
        title: Text(l10n.translation),
        subtitle: Text(l10n.loadingTranslations),
        trailing: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Group translations by locale
    final Map<String, List<BibleTranslation>> grouped = {};
    for (final t in bible.translations) {
      grouped.putIfAbsent(t.locale, () => []).add(t);
    }

    // Sort locales to have current locale first
    final currentLocale = storage.userPreferences.locale;
    final sortedLocales =
        grouped.keys.toList()..sort((a, b) {
          if (a == currentLocale) return -1;
          if (b == currentLocale) return 1;
          return a.compareTo(b);
        });

    return ListTile(
      title: Text(l10n.translation),
      subtitle: Text(
        _getCurrentTranslationSummary(bible),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      onTap:
          () => _showVersionSelectorDialog(
            context,
            bible,
            storage,
            grouped,
            sortedLocales,
            l10n,
          ),
    );
  }

  String _getCurrentTranslationSummary(BibleRepository bible) {
    final t = bible.currentTranslation;
    if (t == null) return bible.currentVersion;
    return '${t.name} (${t.abbreviation}) — ${t.license}';
  }

  void _showVersionSelectorDialog(
    BuildContext context,
    BibleRepository bible,
    StorageService storage,
    Map<String, List<BibleTranslation>> grouped,
    List<String> sortedLocales,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.menu_book_rounded),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.selectTranslation)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: ListView(
                children: [
                  for (final locale in sortedLocales) ...[
                    _LocaleSection(
                      locale: locale,
                      translations: grouped[locale]!,
                      currentVersion: bible.currentVersion,
                      onSelect: (translation) async {
                        final loaded = await bible.setVersion(translation.id);
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                          if (!loaded && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.translationUnavailable),
                              ),
                            );
                          }
                        }
                      },
                      l10n: l10n,
                    ),
                    if (locale != sortedLocales.last) const Divider(height: 24),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.close),
              ),
            ],
          ),
    );
  }
}

class _LocaleSection extends StatelessWidget {
  const _LocaleSection({
    required this.locale,
    required this.translations,
    required this.currentVersion,
    required this.onSelect,
    required this.l10n,
  });

  final String locale;
  final List<BibleTranslation> translations;
  final String currentVersion;
  final void Function(BibleTranslation) onSelect;
  final AppLocalizations l10n;

  String _localeDisplayName(String code) {
    return switch (code) {
      'en' => 'English',
      'es' => 'Español',
      'pt' => 'Português',
      'fr' => 'Français',
      'de' => 'Deutsch',
      'it' => 'Italiano',
      'ru' => 'Русский',
      _ => code.toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _localeDisplayName(locale),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (final translation in translations)
          _TranslationTile(
            translation: translation,
            isSelected: translation.abbreviation == currentVersion,
            onSelect: () => onSelect(translation),
          ),
      ],
    );
  }
}

class _TranslationTile extends StatelessWidget {
  const _TranslationTile({
    required this.translation,
    required this.isSelected,
    required this.onSelect,
  });

  final BibleTranslation translation;
  final bool isSelected;
  final VoidCallback onSelect;

  IconData _getTranslationIcon(String locale) {
    // Simple locale-based icons
    return switch (locale) {
      'en' => Icons.translate_rounded,
      'es' => Icons.translate_rounded,
      'pt' => Icons.translate_rounded,
      'fr' => Icons.translate_rounded,
      'de' => Icons.translate_rounded,
      'it' => Icons.translate_rounded,
      'ru' => Icons.translate_rounded,
      _ => Icons.menu_book_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTranslationIcon(translation.locale),
                  color:
                      isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            translation.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translation.abbreviation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${translation.license} • ${translation.locale.toUpperCase()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
