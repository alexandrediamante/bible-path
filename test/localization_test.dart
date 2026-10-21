import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_path/l10n/app_localizations.dart';

void main() {
  test('loads every supported application locale', () {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
      orderedEquals(['de', 'en', 'es', 'fr', 'it', 'pt', 'ru']),
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(Locale(locale.languageCode));
      expect(l10n.navHome, isNotEmpty);
      expect(l10n.profilePrivacyDescription, isNotEmpty);
      expect(l10n.dayStreak(2), isNot(anyOf(contains('{'), contains('#'))));
      expect(
        l10n.planStepsComplete(1, 2),
        isNot(anyOf(contains('{'), contains('#'))),
      );
      expect(
        l10n.studyDurationAndTopics(7, 'Hope'),
        isNot(anyOf(contains('{'), contains('#'))),
      );
    }
  });
}
