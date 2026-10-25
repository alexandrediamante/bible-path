import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/features/daily_plan/daily_plan_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class DailyPlanScreen extends StatelessWidget {
  const DailyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<DailyPlanRepository>();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dailyPlan,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(l10n.dayStreak(repository.currentStreak)),
                    ],
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.emoji_events_rounded, size: 18),
                  label: Text(l10n.bestStreak(repository.longestStreak)),
                ),
              ],
            ),
          ),
          TabBar(tabs: [Tab(text: l10n.today), Tab(text: l10n.history)]),
          Expanded(
            child: TabBarView(
              children: [
                _Today(repository: repository),
                _History(plans: repository.getRecentPlans()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Today extends StatelessWidget {
  const _Today({required this.repository});

  final DailyPlanRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plan = repository.todaysPlan;
    if (plan == null) return Center(child: Text(l10n.noPlanAvailable));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          _localizedTheme(l10n, plan.theme),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: plan.progress),
        const SizedBox(height: 8),
        Text(l10n.planStepsComplete(plan.completedSteps, plan.totalSteps)),
        const SizedBox(height: 16),
        for (final step in plan.steps)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: CheckboxListTile(
              value: step.isCompleted,
              onChanged: (checked) {
                if (checked == true) {
                  repository.completeStep(plan.id, step.id);
                } else {
                  repository.uncompleteStep(plan.id, step.id);
                }
              },
              title: Text(_localizedStepTitle(l10n, step.type)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  step.verseReference == null
                      ? step.content
                      : '${step.content}\n${step.verseReference}',
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        if (!plan.isCompleted)
          FilledButton.icon(
            onPressed: () async {
              for (final step in plan.steps.where(
                (item) => !item.isCompleted,
              )) {
                await repository.completeStep(plan.id, step.id);
              }
            },
            icon: const Icon(Icons.check_circle_rounded),
            label: Text(l10n.completeTodaysPlan),
          ),
      ],
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.plans});

  final List<DailyPlan> plans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completed = plans.where((plan) => plan.isCompleted).toList();
    if (completed.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.dailyHistoryEmpty),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        final plan = completed[index];
        return ListTile(
          leading: const Icon(Icons.check_circle_rounded),
          title: Text(_localizedTheme(l10n, plan.theme)),
          subtitle: Text(DateFormat.yMMMMd(l10n.localeName).format(plan.date)),
        );
      },
    );
  }
}

String _localizedStepTitle(AppLocalizations l10n, PlanStepType type) {
  return switch (type) {
    PlanStepType.verse => l10n.todaysVerse,
    PlanStepType.devotional => l10n.dailyDevotional,
    PlanStepType.reading => l10n.reading,
    PlanStepType.listening => l10n.listening,
    PlanStepType.connection => l10n.reflection,
    PlanStepType.prayer => l10n.dailyPrayer,
  };
}

String _localizedTheme(AppLocalizations l10n, String? theme) {
  return switch (theme) {
    'Trust & Guidance' => l10n.themeTrustGuidance,
    'Peace & Rest' => l10n.themePeaceRest,
    'Strength & Courage' => l10n.themeStrengthCourage,
    'Hope & Future' => l10n.themeHopeFuture,
    'Love & Grace' => l10n.themeLoveGrace,
    'Faith & Trust' => l10n.themeFaithTrust,
    'Wisdom & Understanding' => l10n.themeWisdomUnderstanding,
    null || '' => l10n.dailyPlan,
    _ => theme,
  };
}
