import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/services/storage_service.dart';
import 'features/study/study_repository.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StudyType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyRepo = context.watch<StudyRepository>();
    final storage = context.watch<StorageService>();
    final isDark = storage.userPreferences?.isDarkMode ?? false;

    return Column(
      children: [
        // Header
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Study Plans',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  PopupMenuButton<StudyType?>(
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onSelected: (type) => setState(() => _filterType = type),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: null, child: Text('All Types')),
                      ...StudyType.values.map((t) => PopupMenuItem(
                        value: t,
                        child: Text(_getTypeLabel(t)),
                      )),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Available'),
                  Tab(text: 'My Plans'),
                ],
                labelColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
                indicatorColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
              ),
            ],
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Available Plans
              _AvailablePlansView(
                plans: studyRepo.availablePlans,
                filterType: _filterType,
                onStart: (plan) => studyRepo.startPlan(plan.id),
              ),
              // My Plans
              _MyPlansView(plans: studyRepo.myPlans),
            ],
          ),
        ),
      ],
    );
  }

  String _getTypeLabel(StudyType type) {
    switch (type) {
      case StudyType.readingPlan:
        return 'Reading Plans';
      case StudyType.listeningPlan:
        return 'Listening Plans';
      case StudyType.studyPlan:
        return 'Study Plans';
      case StudyType.challenge:
        return 'Challenges';
    }
  }
}

class _AvailablePlansView extends StatelessWidget {
  final List<StudyPlan> plans;
  final StudyType? filterType;
  final Function(StudyPlan) onStart;

  const _AvailablePlansView({
    required this.plans,
    required this.filterType,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredPlans = filterType == null
        ? plans
        : plans.where((p) => p.type == filterType).toList();

    if (filteredPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No plans found',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredPlans.length,
      itemBuilder: (context, index) {
        final plan = filteredPlans[index];
        return _StudyPlanCard(plan: plan, onStart: () => onStart(plan));
      },
    );
  }
}

class _MyPlansView extends StatelessWidget {
  final List<StudyPlan> plans;

  const _MyPlansView({required this.plans});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(height: 16),
            Text(
              'No active plans',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a plan from the Available tab to see it here.',
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
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _MyPlanCard(plan: plan);
      },
    );
  }
}

class _StudyPlanCard extends StatelessWidget {
  final StudyPlan plan;
  final VoidCallback onStart;

  const _StudyPlanCard({required this.plan, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onStart,
      child: Container(
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
            // Image/Type Header
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: _getTypeColor(plan.type).withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getTypeIcon(plan.type),
                      size: 48,
                      color: _getTypeColor(plan.type),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(plan.type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTypeLabel(plan.type),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (plan.audioUrl != null)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                ],
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
                  const SizedBox(height: 8),
                  Text(
                    plan.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.durationDays} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.signal_cellular_alt_rounded,
                        size: 14,
                        color: _getDifficultyColor(plan.difficulty),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getDifficultyLabel(plan.difficulty),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getDifficultyColor(plan.difficulty),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                      ),
                      child: Text(
                        plan.isStarted ? 'Continue' : 'Start Plan',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(StudyType type) {
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

  Color _getTypeColor(StudyType type) {
    switch (type) {
      case StudyType.readingPlan:
        return Colors.blue;
      case StudyType.listeningPlan:
        return Colors.orange;
      case StudyType.studyPlan:
        return Colors.purple;
      case StudyType.challenge:
        return Colors.red;
    }
  }

  Color _getDifficultyColor(StudyDifficulty difficulty) {
    switch (difficulty) {
      case StudyDifficulty.beginner:
        return Colors.green;
      case StudyDifficulty.intermediate:
        return Colors.orange;
      case StudyDifficulty.advanced:
        return Colors.red;
    }
  }

  String _getDifficultyLabel(StudyDifficulty difficulty) {
    switch (difficulty) {
      case StudyDifficulty.beginner:
        return 'Beginner';
      case StudyDifficulty.intermediate:
        return 'Intermediate';
      case StudyDifficulty.advanced:
        return 'Advanced';
    }
  }

  String _getTypeLabel(StudyType type) {
    switch (type) {
      case StudyType.readingPlan:
        return 'Reading';
      case StudyType.listeningPlan:
        return 'Listening';
      case StudyType.studyPlan:
        return 'Study';
      case StudyType.challenge:
        return 'Challenge';
    }
  }
}

class _MyPlanCard extends StatelessWidget {
  final StudyPlan plan;

  const _MyPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studyRepo = context.read<StudyRepository>();

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTypeColor(plan.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(plan.type),
                    color: _getTypeColor(plan.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
                      ),
                      Text(
                        plan.isCompleted ? 'Completed!' : 'Day ${plan.completedDays} of ${plan.durationDays}',
                        style: TextStyle(
                          fontSize: 12,
                          color: plan.isCompleted
                              ? (isDark ? AppTheme.successColor : AppTheme.successColor)
                              : (isDark ? Colors.white60 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                if (plan.isCompleted)
                  Icon(
                    Icons.check_circle_rounded,
                    color: isDark ? AppTheme.successColor : AppTheme.successColor,
                    size: 28,
                  ),
              ],
            ),

            if (!plan.isCompleted) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: plan.progress,
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(
                  plan.durationDays.clamp(0, 14),
                  (index) {
                    final day = index + 1;
                    final isDone = plan.dayProgress[day] ?? false;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => studyRepo.completeDay(plan.id, day),
                        child: Container(
                          height: 36,
                          margin: EdgeInsets.only(right: index < 13 ? 4 : 0),
                          decoration: BoxDecoration(
                            color: isDone
                                ? (isDark ? AppTheme.successColor.withOpacity(0.3) : AppTheme.successColor.withOpacity(0.2))
                                : (isDark ? Colors.white10 : Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDone
                                  ? (isDark ? AppTheme.successColor : AppTheme.successColor)
                                  : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDone
                                    ? (isDark ? AppTheme.successColor : AppTheme.successColor)
                                    : (isDark ? Colors.white54 : Colors.black45),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(StudyType type) {
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

  Color _getTypeColor(StudyType type) {
    switch (type) {
      case StudyType.readingPlan:
        return Colors.blue;
      case StudyType.listeningPlan:
        return Colors.orange;
      case StudyType.studyPlan:
        return Colors.purple;
      case StudyType.challenge:
        return Colors.red;
    }
  }
}