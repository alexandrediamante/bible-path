import 'package:flutter/material.dart';
import 'package:bible_path/shared/widgets/read_aloud_player.dart';
import 'package:bible_path/features/bible/bible_repository.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/features/listen/listen_repository.dart';
import 'package:bible_path/features/listen/models/listen_day.dart';
import 'package:bible_path/features/listen/models/listen_plan.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class ListenScreen extends StatelessWidget {
  const ListenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<ListenRepository>();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.listenPlans,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          TabBar(tabs: [Tab(text: l10n.available), Tab(text: l10n.myPlans)]),
          Expanded(
            child: TabBarView(
              children: [
                _AvailablePlans(repository: repository),
                _MyPlans(repository: repository),
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

  final ListenRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisExtent: 280,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: repository.availablePlans.length,
      itemBuilder: (context, index) {
        final plan = repository.availablePlans[index];
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.headphones_rounded, size: 36),
                const SizedBox(height: 12),
                Text(plan.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Expanded(child: Text(plan.description)),
                Text(
                  l10n.listenDurationAndDays(
                    plan.totalRoundedMinutes,
                    plan.totalDays,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        plan.isStarted
                            ? null
                            : () => repository.startPlan(plan.id),
                    child: Text(plan.isStarted ? l10n.started : l10n.startPlan),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MyPlans extends StatelessWidget {
  const _MyPlans({required this.repository});

  final ListenRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plans = repository.myPlans;
    if (plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.listenMyPlansEmpty),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      l10n.listenProgress(plan.completedDays, plan.totalDays),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: plan.progress),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final day in plan.days)
                      FilterChip(
                        label: Text(l10n.listenDay(day.day)),
                        selected: plan.dayProgress[day.day] == true,
                        onSelected:
                            (_) =>
                                _showDayPlayer(context, repository, plan, day),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => repository.removePlan(plan.id),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.removePlan),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDayPlayer(
    BuildContext context,
    ListenRepository repository,
    ListenPlan plan,
    ListenDay day,
  ) async {
    final l10n = AppLocalizations.of(context);
    final isCompleted = plan.dayProgress[day.day] == true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  24 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.listenDayTitle(day.day, day.title),
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                day.passage,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            day.durationDisplay,
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (day.description != null) ...[
                      Text(day.description!),
                      const SizedBox(height: 16),
                    ],
                    ReadAloudPlayer(
                      text: context
                          .read<BibleRepository>()
                          .passageByCanonicalReference(
                            _listenReference(day.day),
                          )
                          .map((verse) => verse.text)
                          .join(' '),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            isCompleted
                                ? null
                                : () async {
                                  await repository.completeDay(
                                    plan.id,
                                    day.day,
                                  );
                                  if (context.mounted) Navigator.pop(context);
                                },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          isCompleted ? l10n.completed : l10n.markComplete,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

String _listenReference(int day) => switch (day) {
  1 => 'GEN.1.1-31',
  2 => 'PSA.23.1-6',
  3 => 'MAT.5.1-12',
  4 => 'MAT.6.9-13',
  5 => 'JHN.10.1-18',
  6 => '1CO.13.1-13',
  7 => 'MAT.28.16-20',
  _ => '',
};
