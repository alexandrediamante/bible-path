import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _completing = false;

  // User selections
  String? _selectedLanguage;
  String? _selectedTranslationStyle;
  String? _selectedDenomination;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    if (_completing) return;
    setState(() => _completing = true);
    final storage = context.read<StorageService>();
    final content = context.read<ContentRepository>();
    final bible = context.read<BibleRepository>();
    final l10n = AppLocalizations.of(context);
    try {
      final locale = _selectedLanguage ?? storage.userPreferences.locale;
      if (!await content.loadLocale(locale)) {
        throw StateError('Content unavailable');
      }
      final translation = bible.translationForLocale(locale);
      if (translation == null || !await bible.setVersion(translation.id)) {
        throw StateError('Translation unavailable');
      }
      await storage.updatePreferences(
        storage.userPreferences.copyWith(
          locale: locale,
          translationStyle: _selectedTranslationStyle,
          denomination: _selectedDenomination,
          hasCompletedOnboarding: true,
        ),
      );
      if (mounted) context.go('/home');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.translationUnavailable)));
      }
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final pages = [
      _WelcomePage(
        title: l10n.onboardingWelcomeTitle,
        description: l10n.onboardingWelcomeDescription,
        onNext: _nextPage,
        onSkip: _skipOnboarding,
      ),
      _LanguageAndStylePage(
        l10n: l10n,
        selectedLanguage: _selectedLanguage,
        selectedTranslationStyle: _selectedTranslationStyle,
        onLanguageChanged: (value) => setState(() => _selectedLanguage = value),
        onStyleChanged:
            (value) => setState(() => _selectedTranslationStyle = value),
        onNext: _nextPage,
        onSkip: _skipOnboarding,
      ),
      _DenominationPage(
        l10n: l10n,
        selectedDenomination: _selectedDenomination,
        onDenominationChanged:
            (value) => setState(() => _selectedDenomination = value),
        onComplete: _completeOnboarding,
        onSkip: _skipOnboarding,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Offstage(
              offstage: _currentPage >= 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      const SizedBox(width: 48)
                    else
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(l10n.onboardingSkip),
                      ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: pages,
              ),
            ),
            Offstage(
              offstage: _currentPage >= 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: FilledButton(
                  onPressed: _nextPage,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.onboardingNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.title,
    required this.description,
    required this.onNext,
    required this.onSkip,
  });

  final String title;
  final String description;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LanguageAndStylePage extends StatelessWidget {
  const _LanguageAndStylePage({
    required this.l10n,
    required this.selectedLanguage,
    required this.selectedTranslationStyle,
    required this.onLanguageChanged,
    required this.onStyleChanged,
    required this.onNext,
    required this.onSkip,
  });

  final AppLocalizations l10n;
  final String? selectedLanguage;
  final String? selectedTranslationStyle;
  final ValueChanged<String?> onLanguageChanged;
  final ValueChanged<String?> onStyleChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const supportedLocales = AppLocalizations.supportedLocales;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingLanguage,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: selectedLanguage,
            onChanged: onLanguageChanged,
            child: Column(
              children:
                  supportedLocales.map((locale) {
                    final code = locale.languageCode;
                    final name = _languageName(l10n, code);
                    return RadioListTile<String>(
                      value: code,
                      title: Text(name),
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingTranslationStyle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildStyleOption(
            context,
            value: 'formal',
            title: l10n.onboardingStyleFormal,
            subtitle: 'Traditional, reverent language (e.g., KJV, Almeida)',
            selected: selectedTranslationStyle,
            onTap: () => onStyleChanged('formal'),
          ),
          const SizedBox(height: 8),
          _buildStyleOption(
            context,
            value: 'contemporary',
            title: l10n.onboardingStyleContemporary,
            subtitle: 'Modern, accessible language (e.g., NIV, NVI)',
            selected: selectedTranslationStyle,
            onTap: () => onStyleChanged('contemporary'),
          ),
          const SizedBox(height: 8),
          _buildStyleOption(
            context,
            value: 'simple',
            title: l10n.onboardingStyleSimple,
            subtitle: 'Easy-to-read, simple language (e.g., NLT, NTLH)',
            selected: selectedTranslationStyle,
            onTap: () => onStyleChanged('simple'),
          ),
          const SizedBox(height: 8),
          _buildStyleOption(
            context,
            value: 'literary',
            title: l10n.onboardingStyleLiterary,
            subtitle: 'Literary precision with readability (e.g., ESV, ARA)',
            selected: selectedTranslationStyle,
            onTap: () => onStyleChanged('literary'),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleOption(
    BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required String? selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = selected == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
    );
  }

  String _languageName(AppLocalizations l10n, String code) {
    return switch (code) {
      'en' => l10n.languageEnglish,
      'es' => l10n.languageSpanish,
      'pt' => l10n.languagePortuguese,
      'fr' => l10n.languageFrench,
      'de' => l10n.languageGerman,
      'it' => l10n.languageItalian,
      'ru' => l10n.languageRussian,
      _ => code,
    };
  }
}

class _DenominationPage extends StatelessWidget {
  const _DenominationPage({
    required this.l10n,
    required this.selectedDenomination,
    required this.onDenominationChanged,
    required this.onComplete,
    required this.onSkip,
  });

  final AppLocalizations l10n;
  final String? selectedDenomination;
  final ValueChanged<String?> onDenominationChanged;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingDenomination,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us suggest relevant reading plans and devotionals.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildDenominationOption(
            context,
            value: 'catholic',
            title: l10n.onboardingDenominationCatholic,
            subtitle: 'Includes deuterocanonical books, Catholic calendar',
            selected: selectedDenomination,
            onTap: () => onDenominationChanged('catholic'),
          ),
          const SizedBox(height: 8),
          _buildDenominationOption(
            context,
            value: 'orthodox',
            title: l10n.onboardingDenominationOrthodox,
            subtitle: 'Orthodox calendar, Septuagint-based readings',
            selected: selectedDenomination,
            onTap: () => onDenominationChanged('orthodox'),
          ),
          const SizedBox(height: 8),
          _buildDenominationOption(
            context,
            value: 'protestant',
            title: l10n.onboardingDenominationProtestant,
            subtitle: '66-book canon, Protestant lectionary',
            selected: selectedDenomination,
            onTap: () => onDenominationChanged('protestant'),
          ),
          const SizedBox(height: 8),
          _buildDenominationOption(
            context,
            value: 'non_denominational',
            title: l10n.onboardingDenominationNonDenominational,
            subtitle: 'General Christian focus, no specific tradition',
            selected: selectedDenomination,
            onTap: () => onDenominationChanged('non_denominational'),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.onboardingComplete),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDenominationOption(
    BuildContext context, {
    required String value,
    required String title,
    required String subtitle,
    required String? selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isSelected = selected == value;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
    );
  }
}
