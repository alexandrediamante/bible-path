import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/features/study/study_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<StudyRepository>();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.studyPlans,
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

  final StudyRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420,
        mainAxisExtent: 260,
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
                const Icon(Icons.school_rounded, size: 36),
                const SizedBox(height: 12),
                Text(plan.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Expanded(child: Text(plan.description)),
                Text(
                  l10n.studyDurationAndTopics(
                    plan.durationDays,
                    plan.topics.join(' • '),
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

  final StudyRepository repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final plans = repository.myPlans;
    if (plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.studyMyPlansEmpty),
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
                      l10n.studyProgress(plan.completedDays, plan.durationDays),
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
                    for (final lesson in plan.lessons)
                      FilterChip(
                        label: Text(l10n.studyDay(lesson.day)),
                        selected: plan.dayProgress[lesson.day] == true,
                        onSelected:
                            (_) =>
                                _showLesson(context, repository, plan, lesson),
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

  Future<void> _showLesson(
    BuildContext context,
    StudyRepository repository,
    StudyPlan plan,
    StudyLesson lesson,
  ) async {
    final l10n = AppLocalizations.of(context);
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
                    Text(
                      l10n.studyLessonTitle(lesson.day, lesson.title),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lesson.reading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(lesson.reflection),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            plan.dayProgress[lesson.day] == true
                                ? null
                                : () async {
                                  await repository.completeDay(
                                    plan.id,
                                    lesson.day,
                                  );
                                  if (context.mounted) Navigator.pop(context);
                                },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(
                          plan.dayProgress[lesson.day] == true
                              ? l10n.completed
                              : l10n.markComplete,
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
