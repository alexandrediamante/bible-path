import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/platform/browser_actions.dart';
import 'package:bible_path/features/lent/lent_repository.dart';
import 'package:bible_path/features/reading_plan/reading_plan_repository.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:bible_path/features/content/content_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';
import 'package:bible_path/features/bible/bible_version_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final storage = context.watch<StorageService>();
    final bible = context.watch<BibleRepository>();
    final content = context.read<ContentRepository>();
    final preferences = storage.userPreferences;
    const supportedLocales = AppLocalizations.supportedLocales;
    final selectedLocale =
        supportedLocales.any(
              (locale) => locale.languageCode == preferences.locale,
            )
            ? preferences.locale
            : supportedLocales.first.languageCode;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        Text(l10n.settings, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        _Section(
          title: l10n.appearanceAndLanguage,
          children: [
            SwitchListTile(
              title: Text(l10n.darkMode),
              value: preferences.isDarkMode,
              onChanged: storage.setDarkMode,
            ),
            ListTile(
              title: Text(l10n.textSize),
              subtitle: Slider(
                value: preferences.textScale,
                min: 0.8,
                max: 1.5,
                divisions: 7,
                label: NumberFormat.percentPattern(
                  l10n.localeName,
                ).format(preferences.textScale),
                onChanged: storage.setTextScale,
              ),
            ),
            ListTile(
              title: Text(l10n.language),
              trailing: DropdownButton<String>(
                value: selectedLocale,
                items: [
                  for (final locale in supportedLocales)
                    DropdownMenuItem(
                      value: locale.languageCode,
                      child: Text(_languageName(l10n, locale.languageCode)),
                    ),
                ],
                onChanged: (value) async {
                  if (value == null || value == preferences.locale) return;
                  final previousLocale = preferences.locale;
                  if (!await content.loadLocale(value)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.bibleContentUnavailable)),
                      );
                    }
                    return;
                  }
                  final translation = bible.translationForLocale(value);
                  if (translation == null ||
                      !await bible.setVersion(translation.id)) {
                    await content.loadLocale(previousLocale);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.translationUnavailable)),
                      );
                    }
                    return;
                  }
                  await storage.setLocale(value);
                  if (!context.mounted) return;
                  final lent = context.read<LentRepository>();
                  final reading = context.read<ReadingPlanRepository>();
                  await Future.wait([
                    lent.loadLocale(value),
                    reading.loadLocale(value),
                    storage.adventRepository.changeLocale(value),
                  ]);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.navBible,
          children: const [BibleVersionSelector()],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.inAppReminder,
          children: [
            SwitchListTile(
              title: Text(l10n.dailyReminder),
              subtitle: Text(l10n.reminderVisibility),
              value: preferences.dailyReminderEnabled,
              onChanged:
                  (enabled) => storage.setDailyReminder(
                    preferences.dailyReminderTime,
                    enabled,
                  ),
            ),
            if (preferences.dailyReminderEnabled)
              ListTile(
                title: Text(l10n.reminderTime),
                subtitle: Text(
                  _formatReminderTime(context, preferences.dailyReminderTime),
                ),
                trailing: const Icon(Icons.schedule_rounded),
                onTap: () => _pickTime(storage, preferences.dailyReminderTime),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.bibleAi,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.aiPrivacyDescription),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.localData,
          children: [
            ListTile(
              leading: const Icon(Icons.storage_rounded),
              title: Text(l10n.requestDurableStorage),
              subtitle: Text(l10n.durableStorageWarning),
              onTap: _requestStorage,
            ),
            ListTile(
              leading: const Icon(Icons.download_rounded),
              title: Text(l10n.exportMyData),
              subtitle: Text(l10n.tokenExcluded),
              onTap: () => _export(storage),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded),
              title: Text(l10n.resetLocalData),
              textColor: Theme.of(context).colorScheme.error,
              iconColor: Theme.of(context).colorScheme.error,
              onTap: () => _reset(storage),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: l10n.about,
          children: [
            ListTile(
              title: Text(l10n.appTitle),
              subtitle: Text(l10n.aboutDescription('1.0.0')),
            ),
            ListTile(
              title: Text(l10n.notifications),
              subtitle: Text(l10n.webPushUnavailable),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickTime(StorageService storage, String current) async {
    final parts = current.split(':');
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts.first),
        minute: int.parse(parts.last),
      ),
    );
    if (result == null) return;
    await storage.setDailyReminder(
      '${result.hour.toString().padLeft(2, '0')}:'
      '${result.minute.toString().padLeft(2, '0')}',
      true,
    );
  }

  Future<void> _requestStorage() async {
    final persistent = await requestPersistentStorage();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          persistent
              ? l10n.durableStorageGranted
              : l10n.durableStorageNotGranted,
        ),
      ),
    );
  }

  Future<void> _export(StorageService storage) async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    try {
      await downloadJson(
        const JsonEncoder.withIndent('  ').convert({
          ...storage.exportData(),
          'exportedAt': now.toUtc().toIso8601String(),
        }),
        'bible-path-$date.json',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportUnavailable)));
    }
  }

  Future<void> _reset(StorageService storage) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.resetAllDataTitle),
            content: Text(l10n.resetAllDataDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.reset),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    await storage.reset();
    reloadApp();
  }

  String _formatReminderTime(BuildContext context, String value) {
    final parts = value.split(':');
    if (parts.length != 2) return value;
    final hour = int.tryParse(parts.first);
    final minute = int.tryParse(parts.last);
    if (hour == null || minute == null) return value;
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay(hour: hour, minute: minute));
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...children,
        ],
      ),
    );
  }
}
