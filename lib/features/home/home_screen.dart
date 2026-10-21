import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/models/user_preferences.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/chat/chat_repository.dart';
import 'package:bible_path/features/daily_plan/daily_plan_repository.dart';
import 'package:bible_path/features/prayer/prayer_repository.dart';
import 'package:bible_path/features/study/study_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final daily = context.watch<DailyPlanRepository>();
    final storage = context.watch<StorageService>();
    final chat = context.watch<ChatRepository>();
    final study = context.watch<StudyRepository>();
    final prayers = context.watch<PrayerRepository>();
    final plan = daily.todaysPlan;
    final verse = plan?.steps
        .where((step) => step.type == PlanStepType.verse)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      children: [
        Text(l10n.appTitle, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(l10n.homeTagline, style: Theme.of(context).textTheme.bodyLarge),
        if (_shouldShowReminder(
          storage.userPreferences,
          plan?.isCompleted == true,
        )) ...[
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(l10n.reminderBanner),
              trailing: TextButton(
                onPressed: () => storage.dismissReminderForDate(_todayKey()),
                child: Text(l10n.dismiss),
              ),
              onTap: () => context.go('/daily-plan'),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verse?.verseReference ?? l10n.dailyVerse,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  verse?.content ?? l10n.openBiblePrompt,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.go('/bible'),
                    icon: const Icon(Icons.menu_book_rounded),
                    label: Text(l10n.openBible),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.todaysPlan,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(l10n.dayStreak(daily.currentStreak)),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: plan?.progress ?? 0),
                const SizedBox(height: 8),
                Text(
                  plan == null
                      ? l10n.noPlanAvailable
                      : l10n.planStepsComplete(
                          plan.completedSteps,
                          plan.totalSteps,
                        ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => context.go('/daily-plan'),
                    child: Text(l10n.continueAction),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.continueJourney,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.15,
          children: [
            _ActionCard(
              icon: Icons.auto_awesome_rounded,
              title: l10n.bibleAi,
              subtitle: l10n.questionCount(chat.messageCount),
              onTap: () => context.go('/chat'),
            ),
            _ActionCard(
              icon: Icons.school_rounded,
              title: l10n.studyTitle,
              subtitle: l10n.activePlanCount(study.myPlans.length),
              onTap: () => context.go('/study'),
            ),
            _ActionCard(
              icon: Icons.book_outlined,
              title: l10n.prayerJournal,
              subtitle: l10n.entryCount(prayers.prayers.length),
              onTap: () => context.go('/prayer'),
            ),
            _ActionCard(
              icon: Icons.favorite_rounded,
              title: l10n.favorites,
              subtitle: l10n.verseCount(
                storage.userPreferences.favoriteVerses.length,
              ),
              onTap: () => context.go('/bible?favorites=1'),
            ),
          ],
        ),
      ],
    );
  }

  bool _shouldShowReminder(UserPreferences preferences, bool planCompleted) {
    if (planCompleted ||
        !preferences.dailyReminderEnabled ||
        preferences.lastReminderDate == _todayKey()) {
      return false;
    }
    final parts = preferences.dailyReminderTime.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts.first);
    final minute = int.tryParse(parts.last);
    if (hour == null || minute == null) return false;
    final now = DateTime.now();
    final reminder = DateTime(now.year, now.month, now.day, hour, minute);
    return !now.isBefore(reminder);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
