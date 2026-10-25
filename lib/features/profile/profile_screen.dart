import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/chat/chat_repository.dart';
import 'package:bible_path/features/daily_plan/daily_plan_repository.dart';
import 'package:bible_path/features/prayer/prayer_repository.dart';
import 'package:bible_path/features/study/study_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer5<
      StorageService,
      DailyPlanRepository,
      ChatRepository,
      StudyRepository,
      PrayerRepository
    >(
      builder: (context, storage, daily, chat, study, prayers, _) {
        final l10n = AppLocalizations.of(context);
        final preferences = storage.userPreferences;
        final completedStudyPlans =
            study.myPlans.where((plan) => plan.isCompleted).length;
        final stats = [
          _Stat(
            l10n.profileCurrentStreak(daily.currentStreak),
            daily.currentStreak,
            Icons.local_fire_department,
          ),
          _Stat(
            l10n.profileLongestStreak(daily.longestStreak),
            daily.longestStreak,
            Icons.emoji_events,
          ),
          _Stat(
            l10n.profileDailyPlans(daily.completedPlanDates.length),
            daily.completedPlanDates.length,
            Icons.check_circle,
          ),
          _Stat(
            l10n.profileStudyPlans(completedStudyPlans),
            completedStudyPlans,
            Icons.school,
          ),
          _Stat(
            l10n.profileFavoriteVerses(preferences.favoriteVerses.length),
            preferences.favoriteVerses.length,
            Icons.favorite,
          ),
          _Stat(
            l10n.profilePrayerEntries(prayers.prayers.length),
            prayers.prayers.length,
            Icons.book_outlined,
          ),
          _Stat(
            l10n.profileAiMessages(chat.messageCount),
            chat.messageCount,
            Icons.chat_bubble,
          ),
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  child: Text(preferences.locale.toUpperCase()),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourJourney,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        l10n.dataStoredOnly,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.25,
                  children: [for (final stat in stats) _StatCard(stat: stat)],
                );
              },
            ),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.privacy,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.profilePrivacyDescription),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stat.icon),
            const SizedBox(height: 8),
            Text(
              NumberFormat.decimalPattern(locale).format(stat.value),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;
}
