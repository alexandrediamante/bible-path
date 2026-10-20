import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/storage_service.dart';
import 'features/daily_plan/daily_plan_repository.dart';
import 'features/chat/chat_repository.dart';
import 'features/study/study_repository.dart';
import 'features/prayer/prayer_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer5<StorageService, DailyPlanRepository, ChatRepository, StudyRepository, PrayerRepository>(
      builder: (context, storage, dailyPlan, chat, study, prayer, _) {
        final isDark = storage.userPreferences?.isDarkMode ?? false;
        final prefs = storage.userPreferences;
        final streak = dailyPlan.currentStreak;
        final longestStreak = dailyPlan.longestStreak;
        final completedPlans = dailyPlan.completedPlanDates.length;
        final totalMessages = chat.messageCount;
        const favoriteVerses = 0; // Would come from storage
        const prayersShared = 0; // Would come from prayer repo

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: isDark ? AppTheme.primaryLight.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      prefs?.locale?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Believer',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bible Path Pro',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$streak day streak',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/settings'),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Stats Grid
              Text(
                'Your Journey',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '$streak',
                    label: 'Current Streak',
                    color: Colors.amber,
                  ),
                  _StatCard(
                    icon: Icons.emoji_events_rounded,
                    value: '$longestStreak',
                    label: 'Longest Streak',
                    color: Colors.orange,
                  ),
                  _StatCard(
                    icon: Icons.check_circle_rounded,
                    value: '$completedPlans',
                    label: 'Plans Completed',
                    color: Colors.green,
                  ),
                  _StatCard(
                    icon: Icons.chat_bubble_rounded,
                    value: '$totalMessages',
                    label: 'AI Messages',
                    color: Colors.purple,
                  ),
                  _StatCard(
                    icon: Icons.favorite_rounded,
                    value: '$favoriteVerses',
                    label: 'Favorite Verses',
                    color: Colors.red,
                  ),
                  _StatCard(
                    icon: Icons.favorite_border_rounded,
                    value: '$prayersShared',
                    label: 'Prayers Shared',
                    color: Colors.pink,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Achievements
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _AchievementsList(streak: streak, completedPlans: completedPlans),

              const SizedBox(height: 32),

              // Account Section
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _AccountOptions(),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AchievementsList extends StatelessWidget {
  final int streak;
  final int completedPlans;

  const _AchievementsList({required this.streak, required this.completedPlans});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final achievements = [
      ('First Spark', 'Complete your first daily plan', completedPlans >= 1, Icons.star_rounded),
      ('Pathfinder', 'Complete 7 daily plans', completedPlans >= 7, Icons.explore_rounded),
      ('Midway Beacon', 'Complete 30 daily plans', completedPlans >= 30, Icons.flag_rounded),
      ('Illumination', 'Complete 100 daily plans', completedPlans >= 100, Icons.lightbulb_rounded),
      ('Awakened Soul', '7-day streak', streak >= 7, Icons.wb_sunny_rounded),
      ('The Harvest', '30-day streak', streak >= 30, Icons.agriculture_rounded),
      ('Born of Faith', '100-day streak', streak >= 100, Icons.favorite_rounded),
    ];

    return Column(
      children: achievements.map((a) {
        final (title, desc, unlocked, icon) = a;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unlocked
                ? (isDark ? Colors.amber.withOpacity(0.1) : Colors.amber.withOpacity(0.05))
                : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: unlocked
                  ? Colors.amber.withOpacity(0.3)
                  : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: unlocked
                      ? Colors.amber.withOpacity(0.2)
                      : (isDark ? Colors.white10 : Colors.black12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: unlocked ? Colors.amber : (isDark ? Colors.white38 : Colors.black38),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: unlocked
                            ? (isDark ? Colors.white : Colors.black87)
                            : (isDark ? Colors.white54 : Colors.black45),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (unlocked)
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.amber,
                  size: 24,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AccountOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _AccountOption(
          icon: Icons.person_rounded,
          title: 'Edit Profile',
          subtitle: 'Change name, photo, preferences',
          onTap: () => context.go('/settings'),
        ),
        _AccountOption(
          icon: Icons.notifications_rounded,
          title: 'Notifications',
          subtitle: 'Manage reminders and alerts',
          onTap: () => context.go('/settings'),
        ),
        _AccountOption(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: 'English (US)',
          onTap: () => context.go('/settings'),
        ),
        _AccountOption(
          icon: Icons.help_rounded,
          title: 'Help & Support',
          subtitle: 'FAQ, contact us, feedback',
          onTap: () {},
        ),
        _AccountOption(
          icon: Icons.privacy_tip_rounded,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () {},
        ),
        _AccountOption(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          onTap: () {},
          isDestructive: true,
        ),
      ],
    );
  }
}

class _AccountOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _AccountOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withOpacity(0.1)
                      : (isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive ? Colors.red : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}