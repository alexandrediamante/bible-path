import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/features/prayer/prayer_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final _controller = TextEditingController();
  bool _showComposer = false;
  bool _showArchived = false;
  String _category = 'personal';
  Prayer? _editingPrayer;

  static const _categories = [
    'personal',
    'gratitude',
    'guidance',
    'healing',
    'family',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = context.watch<PrayerRepository>();
    final entries =
        repository.prayers
            .where((prayer) => prayer.isArchived == _showArchived)
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.prayerJournal,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(l10n.prayerPrivateDescription),
                  ],
                ),
              ),
              IconButton.filled(
                tooltip: l10n.newPrayer,
                onPressed: _startNewPrayer,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(l10n.active)),
            ButtonSegment(value: true, label: Text(l10n.archived)),
          ],
          selected: {_showArchived},
          onSelectionChanged: (selection) {
            setState(() => _showArchived = selection.first);
          },
        ),
        if (_showComposer) _composer(repository),
        const SizedBox(height: 8),
        Expanded(
          child:
              entries.isEmpty
                  ? _EmptyJournal(archived: _showArchived)
                  : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final prayer = entries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (prayer.category != null)
                                    Chip(
                                      label: Text(
                                        _categoryLabel(l10n, prayer.category!),
                                      ),
                                    ),
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    onSelected: (action) async {
                                      if (action == 'edit') {
                                        _startEditing(prayer);
                                      } else if (action == 'archive') {
                                        await repository.setArchived(
                                          prayer.id,
                                          !prayer.isArchived,
                                        );
                                      } else if (action == 'delete') {
                                        await _confirmDelete(
                                          repository,
                                          prayer,
                                        );
                                      }
                                    },
                                    itemBuilder:
                                        (_) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text(l10n.edit),
                                          ),
                                          PopupMenuItem(
                                            value: 'archive',
                                            child: Text(
                                              prayer.isArchived
                                                  ? l10n.restore
                                                  : l10n.archive,
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(l10n.delete),
                                          ),
                                        ],
                                  ),
                                ],
                              ),
                              SelectableText(
                                prayer.text,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                MaterialLocalizations.of(
                                  context,
                                ).formatMediumDate(prayer.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _composer(PrayerRepository repository) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: l10n.prayerComposerHint),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: [
                  for (final category in _categories)
                    DropdownMenuItem(
                      value: category,
                      child: Text(_categoryLabel(l10n, category)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _cancelComposer,
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        _controller.text.trim().isEmpty
                            ? null
                            : () async {
                              final editing = _editingPrayer;
                              if (editing == null) {
                                await repository.addPrayer(
                                  _controller.text,
                                  category: _category,
                                );
                              } else {
                                await repository.updatePrayer(
                                  editing.id,
                                  text: _controller.text,
                                  category: _category,
                                );
                              }
                              _cancelComposer();
                            },
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewPrayer() {
    _controller.clear();
    setState(() {
      _editingPrayer = null;
      _category = 'personal';
      _showComposer = true;
    });
  }

  void _startEditing(Prayer prayer) {
    _controller.text = prayer.text;
    setState(() {
      _editingPrayer = prayer;
      _category = prayer.category ?? 'personal';
      _showComposer = true;
    });
  }

  void _cancelComposer() {
    _controller.clear();
    setState(() {
      _editingPrayer = null;
      _showComposer = false;
    });
  }

  Future<void> _confirmDelete(
    PrayerRepository repository,
    Prayer prayer,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.deleteEntryTitle),
            content: Text(l10n.cannotUndo),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
    );
    if (confirmed == true) await repository.removePrayer(prayer.id);
  }
}

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal({required this.archived});

  final bool archived;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          archived ? l10n.noArchivedPrayers : l10n.emptyPrayerJournal,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _categoryLabel(AppLocalizations l10n, String category) {
  return switch (category.toLowerCase()) {
    'personal' => l10n.categoryPersonal,
    'gratitude' => l10n.categoryGratitude,
    'guidance' => l10n.categoryGuidance,
    'healing' => l10n.categoryHealing,
    'family' => l10n.categoryFamily,
    _ => category,
  };
}
