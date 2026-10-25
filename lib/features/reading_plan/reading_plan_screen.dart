import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/features/reading_plan/models/reading_plan.dart';
import 'package:bible_path/features/reading_plan/reading_plan_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class ReadingPlanScreen extends StatelessWidget {
  const ReadingPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<ReadingPlanRepository>();

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
                        l10n.readingPlans,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(l10n.activePlans(repository.myPlans.length)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TabBar(tabs: [Tab(text: l10n.available), Tab(text: l10n.myPlans)]),
          Expanded(
            child: TabBarView(
              children: [
                _AvailablePlans(repository: repository),
                _MyPlans(plans: repository.myPlans),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailablePlans extends StatelessWidget {
  const _AvailablePlans({required this.repository});

  final ReadingPlanRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (repository.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (repository.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              Text(l10n.readingPlansUnavailable),
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    () => repository.loadLocale(repository.currentLocale),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in repository.categories) ...[
          _CategorySection(
            category: category,
            repository: repository,
            l10n: l10n,
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.repository,
    required this.l10n,
  });

  final ReadingPlanCategoryData category;
  final ReadingPlanRepository repository;
  final AppLocalizations l10n;

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'lightbulb':
        return Icons.lightbulb_rounded;
      case 'timeline':
        return Icons.timeline_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final availablePlans =
        category.plans.where((plan) => !plan.isStarted).toList();
    if (availablePlans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_getIcon(category.icon), size: 20),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          category.description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availablePlans.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final plan = availablePlans[index];
            return _PlanCard(
              plan: plan,
              repository: repository,
              onTap: () => context.go('/reading-plan/${plan.id}'),
            );
          },
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.repository,
    required this.onTap,
  });

  final ReadingPlan plan;
  final ReadingPlanRepository repository;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).hintColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.planDuration(plan.durationDays),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  if (plan.book != null) ...[
                    Icon(
                      Icons.menu_book_rounded,
                      size: 14,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.planBook(plan.book!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPlans extends StatelessWidget {
  const _MyPlans({required this.plans});

  final List<ReadingPlan> plans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.myPlansEmpty,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.startPlanToSeeProgress,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _ActivePlanCard(
          plan: plan,
          onTap: () => context.go('/reading-plan/${plan.id}'),
        );
      },
    );
  }
}

class _ActivePlanCard extends StatelessWidget {
  const _ActivePlanCard({required this.plan, required this.onTap});

  final ReadingPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.isCompleted ? l10n.completed : l10n.inProgress,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                plan.isCompleted
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (plan.isCompleted)
                    Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    )
                  else
                    const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: plan.progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.planProgress(plan.completedDays, plan.totalDays),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${(plan.progress * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReadingPlanDetailScreen extends StatelessWidget {
  const ReadingPlanDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<ReadingPlanRepository>();
    final plan = repository.getPlan(planId);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.readingPlans)),
        body: Center(child: Text(l10n.planNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
        actions: [
          if (!plan.isStarted)
            TextButton.icon(
              onPressed: () async {
                await repository.startPlan(planId);
                if (context.mounted) context.go('/reading-plan/$planId');
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.startPlan),
            )
          else if (!plan.isCompleted)
            TextButton.icon(
              onPressed:
                  () => _showCompleteDialog(context, plan, repository, l10n),
              icon: const Icon(Icons.check_rounded),
              label: Text(l10n.markComplete),
            ),
        ],
      ),
      body: _PlanDetailContent(plan: plan, repository: repository),
    );
  }

  void _showCompleteDialog(
    BuildContext context,
    ReadingPlan plan,
    ReadingPlanRepository repository,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.completePlan),
            content: Text(l10n.completePlanConfirmation(plan.title)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () async {
                  for (int day = 1; day <= plan.totalDays; day++) {
                    await repository.completeDay(plan.id, day);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(l10n.complete),
              ),
            ],
          ),
    );
  }
}

class _PlanDetailContent extends StatelessWidget {
  const _PlanDetailContent({required this.plan, required this.repository});

  final ReadingPlan plan;
  final ReadingPlanRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!plan.isStarted) {
      return _NotStartedView(plan: plan, repository: repository);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProgressHeader(plan: plan, l10n: l10n),
        const SizedBox(height: 16),
        _DaysList(plan: plan, repository: repository, l10n: l10n),
      ],
    );
  }
}

class _NotStartedView extends StatelessWidget {
  const _NotStartedView({required this.plan, required this.repository});

  final ReadingPlan plan;
  final ReadingPlanRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  plan.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.planDuration(plan.durationDays)),
                    const SizedBox(width: 24),
                    if (plan.readings != null)
                      Icon(
                        Icons.list_alt_rounded,
                        size: 18,
                        color: Theme.of(context).hintColor,
                      ),
                    const SizedBox(width: 8),
                    Text(l10n.planReadings(plan.readings!.length)),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    await repository.startPlan(plan.id);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.startPlan),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (plan.readings != null && plan.readings!.isNotEmpty) ...[
          Text(
            l10n.planSchedule,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plan.readings!.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final day = plan.readings![index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(day.title),
                  subtitle:
                      day.description != null ? Text(day.description!) : null,
                  trailing: Text(
                    day.passage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.plan, required this.l10n});

  final ReadingPlan plan;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.isCompleted ? l10n.completed : l10n.inProgress,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              plan.isCompleted
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (plan.isCompleted)
                  Icon(
                    Icons.check_circle_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  )
                else
                  const SizedBox(width: 32),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: plan.progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.planProgress(plan.completedDays, plan.totalDays),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(plan.progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DaysList extends StatelessWidget {
  const _DaysList({
    required this.plan,
    required this.repository,
    required this.l10n,
  });

  final ReadingPlan plan;
  final ReadingPlanRepository repository;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final days = plan.readings ?? [];

    if (days.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(child: Text(l10n.noReadingsAvailable)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.planSchedule, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final day = days[index];
            final isCompleted = plan.dayProgress[day.day] == true;

            return Card(
              margin: EdgeInsets.zero,
              child: CheckboxListTile(
                value: isCompleted,
                onChanged: (checked) async {
                  if (checked == true) {
                    await repository.completeDay(plan.id, day.day);
                  } else {
                    await repository.uncompleteDay(plan.id, day.day);
                  }
                },
                title: Text(day.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (day.description != null) ...[
                      const SizedBox(height: 4),
                      Text(day.description!),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      day.passage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                secondary: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      isCompleted
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                  child: Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color:
                          isCompleted
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            );
          },
        ),
      ],
    );
  }
}
