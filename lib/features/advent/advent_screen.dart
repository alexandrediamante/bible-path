import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/features/advent/advent_repository.dart';
import 'package:bible_path/features/advent/advent_models.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class AdventScreen extends StatelessWidget {
  const AdventScreen({super.key});

  static const routeName = '/advent';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdventRepository>.value(
      value: context.read<StorageService>().adventRepository,
      child: const _AdventPage(),
    );
  }
}

class _AdventPage extends StatefulWidget {
  const _AdventPage();

  @override
  State<_AdventPage> createState() => _AdventPageState();
}

class _AdventPageState extends State<_AdventPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onRefresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final repository = context.read<AdventRepository>();
    await repository.init(
      locale: context.read<StorageService>().userPreferences.locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repository = context.watch<AdventRepository>();

    if (repository.isLoading && repository.calendar == null) {
      return _buildLoadingState(theme);
    }

    if (repository.error != null && repository.calendar == null) {
      return _buildErrorState(context, l10n, repository.error!);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context, l10n, theme, repository),
          if (!repository.isAdventSeason)
            _buildCountdownCard(context, l10n, theme, repository),
          _buildCalendarGrid(context, l10n, theme, repository),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Loading Advent calendar...', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String error,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.adventErrorTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<AdventRepository>().init(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.adventRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    AdventRepository repository,
  ) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(l10n.adventTitle),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer,
                theme.colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 16),
              child: _buildSeasonIndicator(context, l10n, theme, repository),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _onRefresh,
          tooltip: l10n.adventRefresh,
        ),
      ],
    );
  }

  Widget _buildSeasonIndicator(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    AdventRepository repository,
  ) {
    if (!repository.isAdventSeason) {
      return Text(
        l10n.adventNotInSeason,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    final currentDay = repository.getCurrentDay();
    if (currentDay != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${l10n.adventDay} ${currentDay.day}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            currentDay.title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.8,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      l10n.adventSeasonActive,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildCountdownCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    AdventRepository repository,
  ) {
    final daysUntil = repository.daysUntilAdvent;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Card(
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 48,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.adventCountdownTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.adventCountdownSubtitle(daysUntil),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    AdventRepository repository,
  ) {
    final allDays = repository.getAllDays();
    if (allDays.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(l10n.adventNoData, style: theme.textTheme.bodyLarge),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final day = allDays[index];
          return _buildDayCard(context, l10n, theme, repository, day);
        }, childCount: allDays.length),
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    AdventRepository repository,
    AdventDay day,
  ) {
    final isUnlocked = repository.isDayUnlocked(day.day);
    final isToday = repository.isToday(day.day);
    final weekTheme = day.weekTheme;

    return GestureDetector(
      onTap:
          isUnlocked ? () => _showDayDetail(context, l10n, theme, day) : null,
      onLongPress:
          isUnlocked ? () => _showDayDetail(context, l10n, theme, day) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color:
              isUnlocked
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isToday
                    ? theme.colorScheme.primary
                    : isUnlocked
                    ? theme.colorScheme.outlineVariant
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isToday ? 2 : 1,
          ),
          boxShadow:
              isToday
                  ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child: Stack(
          children: [
            // Week theme color indicator at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: weekTheme.getColor(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Day number
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isUnlocked
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                        ),
                      ),
                      if (!isUnlocked)
                        Icon(
                          Icons.lock_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      if (isToday && isUnlocked)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Day title
                  Text(
                    day.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isUnlocked
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Week theme badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: weekTheme
                          .getColor(context)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getWeekThemeLabel(l10n, weekTheme),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: weekTheme.getColor(context),
                        fontWeight: FontWeight.w600,
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

  String _getWeekThemeLabel(AppLocalizations l10n, AdventWeekTheme theme) {
    switch (theme) {
      case AdventWeekTheme.hope:
        return l10n.adventWeekHope;
      case AdventWeekTheme.peace:
        return l10n.adventWeekPeace;
      case AdventWeekTheme.joy:
        return l10n.adventWeekJoy;
      case AdventWeekTheme.love:
        return l10n.adventWeekLove;
    }
  }

  void _showDayDetail(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    AdventDay day,
  ) {
    final isUnlocked = context.read<AdventRepository>().isDayUnlocked(day.day);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              _DayDetailSheet(day: day, isUnlocked: isUnlocked, l10n: l10n),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({
    required this.day,
    required this.isUnlocked,
    required this.l10n,
  });

  final AdventDay day;
  final bool isUnlocked;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekTheme = day.weekTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with week color
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                decoration: BoxDecoration(
                  color: weekTheme.getColor(context).withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${l10n.adventDay} ${day.day}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: weekTheme.getColor(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: weekTheme.getColor(context),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getWeekThemeLabel(l10n, weekTheme),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child:
                    isUnlocked
                        ? SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Scripture
                              _buildSection(
                                context,
                                l10n.adventScripture,
                                day.scriptureReference,
                                Icons.menu_book_rounded,
                                theme,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  day.scriptureText,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Reflection
                              _buildSection(
                                context,
                                l10n.adventReflection,
                                day.reflection,
                                Icons.lightbulb_rounded,
                                theme,
                              ),
                              const SizedBox(height: 24),
                              // Prayer
                              _buildSection(
                                context,
                                l10n.adventPrayer,
                                day.prayer,
                                Icons.favorite_rounded,
                                theme,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_rounded,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.adventDayLocked,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.adventDayLockedSubtitle(day.day),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
      ],
    );
  }

  String _getWeekThemeLabel(AppLocalizations l10n, AdventWeekTheme theme) {
    switch (theme) {
      case AdventWeekTheme.hope:
        return l10n.adventWeekHope;
      case AdventWeekTheme.peace:
        return l10n.adventWeekPeace;
      case AdventWeekTheme.joy:
        return l10n.adventWeekJoy;
      case AdventWeekTheme.love:
        return l10n.adventWeekLove;
    }
  }
}
