import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/services/storage_service.dart';
import 'features/daily_plan/daily_plan_repository.dart';
import 'features/chat/chat_repository.dart';
import 'features/study/study_repository.dart';
import 'features/prayer/prayer_repository.dart';
import 'features/bible/bible_repository.dart';
import 'shared/widgets/feature_card.dart';
import 'shared/widgets/verse_of_day_widget.dart';
import 'shared/widgets/streak_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<DailyPlanRepository, ChatRepository, StudyRepository, StorageService>(
      builder: (context, dailyPlan, chat, study, storage, _) {
        final isDark = storage.userPreferences?.isDarkMode ?? false;
        final todaysPlan = dailyPlan.todaysPlan;
        final streak = dailyPlan.currentStreak;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _WelcomeSection(streak: streak),

              const SizedBox(height: 24),

              // Verse of the Day
              VerseOfDayWidget(
                verse: todaysPlan?.steps.firstWhere(
                  (s) => s.type == PlanStepType.verse,
                  orElse: () => PlanStep(
                    type: PlanStepType.verse,
                    title: 'Verse',
                    content: 'The Lord is my shepherd; I shall not want.',
                    order: 1,
                  ),
                ).content,
                reference: todaysPlan?.steps.firstWhere(
                  (s) => s.type == PlanStepType.verse,
                  orElse: () => PlanStep(
                    type: PlanStepType.verse,
                    title: 'Verse',
                    content: '',
                    verseReference: 'Psalm 23:1',
                    order: 1,
                  ),
                ).verseReference ?? 'Psalm 23:1',
              ),

              const SizedBox(height: 24),

              // Today's Plan Progress
              if (todaysPlan != null) ...[
                _TodaysPlanSection(plan: todaysPlan),
                const SizedBox(height: 24),
              ],

              // Quick Actions Grid
              _QuickActionsGrid(),

              const SizedBox(height: 24),

              // Continue Studying
              if (study.myPlans.isNotEmpty) ...[
                _ContinueStudyingSection(plans: study.myPlans.take(3).toList()),
                const SizedBox(height: 24),
              ],

              // Prayer Wall Preview
              _PrayerWallPreview(),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final int streak;

  const _WelcomeSection({required this.streak});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) greeting = 'Good Morning';
    else if (hour < 17) greeting = 'Good Afternoon';
    else greeting = 'Good Evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting! 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Connect with God, anywhere you are.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        StreakWidget(streak: streak),
      ],
    );
  }
}

class _TodaysPlanSection extends StatelessWidget {
  final DailyPlan plan;

  const _TodaysPlanSection({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = plan.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Plan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...plan.steps.map((step) => _PlanStepTile(step: step, planId: plan.id)).toList(),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/daily-plan'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Continue Plan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanStepTile extends StatelessWidget {
  final PlanStep step;
  final String planId;

  const _PlanStepTile({required this.step, required this.planId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyPlan = context.read<DailyPlanRepository>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(
            value: step.isCompleted,
            onChanged: (_) {
              if (step.isCompleted) {
                dailyPlan.uncompleteStep(planId, step.id);
              } else {
                dailyPlan.completeStep(planId, step.id);
              }
            },
            activeColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: step.isCompleted
                        ? (isDark ? Colors.white54 : Colors.black38)
                        : (isDark ? Colors.white : Colors.black87),
                    decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (step.verseReference != null)
                  Text(
                    step.verseReference!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black38,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            FeatureCard(
              icon: Icons.menu_book_rounded,
              label: 'Read Bible',
              color: Colors.blue,
              onTap: () => context.go('/bible'),
            ),
            FeatureCard(
              icon: Icons.chat_bubble_rounded,
              label: 'Ask AI',
              color: Colors.purple,
              onTap: () => context.go('/chat'),
            ),
            FeatureCard(
              icon: Icons.headphones_rounded,
              label: 'Listen',
              color: Colors.orange,
              onTap: () => context.go('/study'),
            ),
            FeatureCard(
              icon: Icons.favorite_rounded,
              label: 'Prayer Wall',
              color: Colors.red,
              onTap: () => context.go('/prayer'),
            ),
            FeatureCard(
              icon: Icons.school_rounded,
              label: 'Study Plans',
              color: Colors.green,
              onTap: () => context.go('/study'),
            ),
            FeatureCard(
              icon: Icons.calendar_today_rounded,
              label: 'Daily Plan',
              color: Colors.teal,
              onTap: () => context.go('/daily-plan'),
            ),
            FeatureCard(
              icon: Icons.local_fire_department_rounded,
              label: 'Challenges',
              color: Colors.deepOrange,
              onTap: () => context.go('/study'),
            ),
            FeatureCard(
              icon: Icons.settings_rounded,
              label: 'Settings',
              color: Colors.grey,
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContinueStudyingSection extends StatelessWidget {
  final List<StudyPlan> plans;

  const _ContinueStudyingSection({required this.plans});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Continue Studying',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/study'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return _StudyPlanCard(plan: plan);
            },
          ),
        ),
      ],
    );
  }
}

class _StudyPlanCard extends StatelessWidget {
  final StudyPlan plan;

  const _StudyPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.go('/study'),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              child: Center(
                child: Icon(
                  _getIconForType(plan.type),
                  size: 40,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.durationDays} days • ${plan.topics.take(2).join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (plan.isStarted) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: plan.progress,
                        minHeight: 6,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Day ${plan.completedDays} of ${plan.durationDays}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(StudyType type) {
    switch (type) {
      case StudyType.readingPlan:
        return Icons.menu_book_rounded;
      case StudyType.listeningPlan:
        return Icons.headphones_rounded;
      case StudyType.studyPlan:
        return Icons.school_rounded;
      case StudyType.challenge:
        return Icons.local_fire_department_rounded;
    }
  }
}

class _PrayerWallPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerRepo = context.read<PrayerRepository>();
    final prayers = prayerRepo.prayerWall.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prayer Wall',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/prayer'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...prayers.map((prayer) => _PrayerPreviewTile(prayer: prayer)).toList(),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/prayer'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Share a Prayer'),
          ),
        ),
      ],
    );
  }
}

class _PrayerPreviewTile extends StatelessWidget {
  final Prayer prayer;

  const _PrayerPreviewTile({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${prayer.text}"',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isDark ? AppTheme.primaryLight.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  prayer.authorName[0],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                prayer.authorName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.favorite_rounded,
                size: 16,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                '${prayer.amenCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Need to import PlanStepType
import 'features/daily_plan/daily_plan_repository.dart' as dp;
typedef PlanStepType = dp.PlanStepType;