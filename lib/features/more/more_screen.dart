import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_path/l10n/app_localizations.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      (Icons.headphones_rounded, l10n.navListen, '/listen'),
      (Icons.celebration_rounded, l10n.navAdvent, '/advent'),
      (Icons.menu_book_rounded, l10n.readingPlans, '/reading-plan'),
      (Icons.favorite_rounded, l10n.prayerJournal, '/prayer'),
      (Icons.school_rounded, l10n.studyPlans, '/study'),
      (Icons.auto_awesome_rounded, l10n.lentTitle, '/lent'),
      (Icons.calendar_month_rounded, l10n.holyCalendarTitle, '/holy-calendar'),
      (Icons.person_rounded, l10n.navProfile, '/profile'),
      (Icons.settings_rounded, l10n.navSettings, '/settings'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        Text(l10n.navMore, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        for (final item in items)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              minTileHeight: 56,
              leading: Icon(item.$1),
              title: Text(item.$2),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go(item.$3),
            ),
          ),
      ],
    );
  }
}
