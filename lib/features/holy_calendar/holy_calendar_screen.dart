import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/features/holy_calendar/holy_calendar_models.dart';
import 'package:bible_path/features/holy_calendar/holy_calendar_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class HolyCalendarScreen extends StatefulWidget {
  const HolyCalendarScreen({super.key});

  @override
  State<HolyCalendarScreen> createState() => _HolyCalendarScreenState();
}

class _HolyCalendarScreenState extends State<HolyCalendarScreen> {
  int _month = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Consumer<HolyCalendarRepository>(
      builder: (context, repository, _) {
        final calendar = repository.calendar;
        final days = repository.getDaysForMonth(_month);
        return RefreshIndicator(
          onRefresh: () => repository.refresh(locale: locale),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(pinned: true, title: Text(l10n.holyCalendarTitle)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<LiturgicalTradition>(
                        segments: [
                          for (final tradition in LiturgicalTradition.values)
                            ButtonSegment(
                              value: tradition,
                              label: Text(tradition.getDisplayName(l10n)),
                            ),
                        ],
                        selected: {repository.selectedTradition},
                        showSelectedIcon: false,
                        onSelectionChanged:
                            repository.isLoading
                                ? null
                                : (selection) => repository.changeTradition(
                                  selection.first,
                                  locale: locale,
                                ),
                      ),
                      const SizedBox(height: 12),
                      _MonthSelector(
                        month: _month,
                        locale: locale,
                        onPrevious:
                            () => setState(
                              () => _month = _month == 1 ? 12 : _month - 1,
                            ),
                        onNext:
                            () => setState(
                              () => _month = _month == 12 ? 1 : _month + 1,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              if (repository.isLoading && calendar == null)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (repository.error != null && calendar == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessageState(
                    icon: Icons.calendar_month_outlined,
                    message: l10n.holyCalendarLoadError,
                    actionLabel: l10n.holyCalendarRetry,
                    onAction: () => repository.refresh(locale: locale),
                  ),
                )
              else if (days.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessageState(
                    icon: Icons.event_busy_outlined,
                    message: l10n.holyCalendarNoEvents,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: days.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder:
                        (context, index) => _DayCard(
                          day: days[index],
                          locale: locale,
                          isToday:
                              days[index].date ==
                              DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          onTap: () => _showDay(context, days[index], locale),
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDay(BuildContext context, HolyCalendarDay day, String locale) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.72,
            maxChildSize: 0.94,
            builder:
                (context, controller) => ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    Text(
                      day.dayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMMd(
                        locale,
                      ).format(DateTime.parse(day.date)),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(day.season)),
                        Chip(label: Text(day.rank.name)),
                        if (day.isHolyDayOfObligation)
                          Chip(label: Text(l10n.holyCalendarObligation)),
                      ],
                    ),
                    if (day.saints?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.holyCalendarSaints,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(day.saints!.join(', ')),
                    ],
                    if (day.fastingRules?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.holyCalendarFasting,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(day.fastingRules!),
                    ],
                    if (day.readings.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.holyCalendarReadings,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final reading in day.readings)
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reading.citation,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(reading.text),
                                if (reading.response?.isNotEmpty ?? false) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    reading.response!,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                    if (day.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      Text(day.notes!),
                    ],
                  ],
                ),
          ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
  });

  final int month;
  final String locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.MMMM(locale).format(DateTime(2024, month));
    return Row(
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            '${label[0].toUpperCase()}${label.substring(1)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.locale,
    required this.isToday,
    required this.onTap,
  });

  final HolyCalendarDay day;
  final String locale;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(day.date);
    final color = day.getColor(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat.MMM(locale).format(date).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.dayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('${day.season} · ${day.rank.name}'),
                    if (isToday) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context).today,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
