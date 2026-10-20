import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'core/services/storage_service.dart';
import 'features/daily_plan/daily_plan_repository.dart';

class DailyPlanScreen extends StatelessWidget {
  const DailyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Consumer2<DailyPlanRepository, StorageService>(
        builder: (context, dailyPlan, storage, _) {
          final isDark = storage.userPreferences?.isDarkMode ?? false;
          final todaysPlan = dailyPlan.todaysPlan;
          final streak = dailyPlan.currentStreak;
          final longestStreak = dailyPlan.longestStreak;

          return Column(
            children: [
              // Header with Streak
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Plan',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete your daily tasks to keep your streak strong in faith!',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _StreakDisplay(
                          current: streak,
                          longest: longestStreak,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                child: TabBar(
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'History'),
                  ],
                  labelColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                  unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
                  indicatorColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    // Today's Plan
                    _TodaysPlanView(plan: todaysPlan),

                    // History
                    _HistoryView(recentPlans: dailyPlan.getRecentPlans()),
                  ],
                ),
              ),
            ],
          ),
        },
      ),
    );
  }
}

class _StreakDisplay extends StatelessWidget {
  final int current;
  final int longest;

  const _StreakDisplay({required this.current, required this.longest});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.amber.shade700, Colors.amber.shade900]
              : [Colors.amber.shade500, Colors.amber.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                '$current',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                current == 1 ? 'Day Streak' : 'Day Streak',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Longest: $longest days',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaysPlanView extends StatelessWidget {
  final DailyPlan? plan;

  const _TodaysPlanView({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (plan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No plan for today',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back tomorrow for your Daily Plan.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    final progress = plan.progress;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Plan Steps
          ...plan.steps.map((step) => _PlanStepCard(
            step: step,
            planId: plan.id,
          )).toList(),

          const SizedBox(height: 24),

          // Complete Button
          if (!plan.isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Complete all remaining steps
                  for (final step in plan.steps) {
                    if (!step.isCompleted) {
                      context.read<DailyPlanRepository>().completeStep(plan.id, step.id);
                    }
                  }
                },
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text('Complete Today\'s Plan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.successColor : AppTheme.successColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: isDark ? AppTheme.successColor : AppTheme.successColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Plan Complete! 🎉',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.successColor : AppTheme.successColor,
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

class _PlanStepCard extends StatelessWidget {
  final PlanStep step;
  final String planId;

  const _PlanStepCard({required this.step, required this.planId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyPlan = context.read<DailyPlanRepository>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: step.isCompleted
              ? (isDark ? AppTheme.successColor.withOpacity(0.3) : AppTheme.successColor.withOpacity(0.3))
              : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (step.isCompleted) {
              dailyPlan.uncompleteStep(planId, step.id);
            } else {
              dailyPlan.completeStep(planId, step.id);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? (isDark ? AppTheme.successColor : AppTheme.successColor)
                        : Colors.transparent,
                    border: Border.all(
                      color: step.isCompleted
                          ? (isDark ? AppTheme.successColor : AppTheme.successColor)
                          : (isDark ? Colors.white54 : Colors.black38),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StepTypeIcon(type: step.type),
                          const SizedBox(width: 8),
                          Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: step.isCompleted
                                  ? (isDark ? Colors.white54 : Colors.black38)
                                  : (isDark ? Colors.white : Colors.black87),
                              decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      ),
                      if (step.verseReference != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          step.verseReference!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        step.content,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: step.isCompleted
                              ? (isDark ? Colors.white38 : Colors.black26)
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTypeIcon extends StatelessWidget {
  final PlanStepType type;

  const _StepTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    Color color;

    switch (type) {
      case PlanStepType.verse:
        icon = Icons.menu_book_rounded;
        color = Colors.blue;
        break;
      case PlanStepType.devotional:
        icon = Icons.auto_awesome_rounded;
        color = Colors.purple;
        break;
      case PlanStepType.prayer:
        icon = Icons.favorite_rounded;
        color = Colors.red;
        break;
      case PlanStepType.connection:
        icon = Icons.favorite_border_rounded;
        color = Colors.pink;
        break;
      case PlanStepType.reading:
        icon = Icons.book_rounded;
        color = Colors.green;
        break;
      case PlanStepType.listening:
        icon = Icons.headphones_rounded;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class _HistoryView extends StatelessWidget {
  final List<DailyPlan> recentPlans;

  const _HistoryView({required this.recentPlans});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (recentPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No completed plans yet',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your daily plan to see history here.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentPlans.length,
      itemBuilder: (context, index) {
        final plan = recentPlans[index];
        final dateStr = DateFormat('EEEE, MMMM d').format(plan.date);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: plan.isCompleted
                  ? (isDark ? AppTheme.successColor.withOpacity(0.3) : AppTheme.successColor.withOpacity(0.3))
                  : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: plan.isCompleted
                    ? (isDark ? AppTheme.successColor.withOpacity(0.2) : AppTheme.successColor.withOpacity(0.1))
                    : (isDark ? Colors.white10 : Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: plan.isCompleted
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: isDark ? AppTheme.successColor : AppTheme.successColor,
                      )
                    : Icon(
                        Icons.schedule_rounded,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
              ),
            ),
            title: Text(
              dateStr,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              plan.isCompleted
                  ? 'Completed • ${plan.completedSteps}/${plan.totalSteps} steps'
                  : '${plan.completedSteps}/${plan.totalSteps} steps',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            trailing: Text(
              plan.theme ?? '',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}