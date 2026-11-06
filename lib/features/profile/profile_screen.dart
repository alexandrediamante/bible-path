import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:bible_path/core/services/auth_service.dart';
import 'package:bible_path/core/services/storage_service.dart';
import 'package:bible_path/core/services/sync_service.dart';
import 'package:bible_path/features/chat/chat_repository.dart';
import 'package:bible_path/features/daily_plan/daily_plan_repository.dart';
import 'package:bible_path/features/prayer/prayer_repository.dart';
import 'package:bible_path/features/study/study_repository.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer7<
      StorageService,
      DailyPlanRepository,
      ChatRepository,
      StudyRepository,
      PrayerRepository,
      AuthService,
      SyncService
    >(
      builder: (context, storage, daily, chat, study, prayers, auth, sync, _) {
        final l10n = AppLocalizations.of(context);
        final preferences = storage.userPreferences;
        final completedStudyPlans =
            study.myPlans.where((plan) => plan.isCompleted).length;
        final stats = [
          _Stat(
            l10n.profileCurrentStreak(daily.currentStreak),
            daily.currentStreak,
            Icons.local_fire_department,
          ),
          _Stat(
            l10n.profileLongestStreak(daily.longestStreak),
            daily.longestStreak,
            Icons.emoji_events,
          ),
          _Stat(
            l10n.profileDailyPlans(daily.completedPlanDates.length),
            daily.completedPlanDates.length,
            Icons.check_circle,
          ),
          _Stat(
            l10n.profileStudyPlans(completedStudyPlans),
            completedStudyPlans,
            Icons.school,
          ),
          _Stat(
            l10n.profileFavoriteVerses(preferences.favoriteVerses.length),
            preferences.favoriteVerses.length,
            Icons.favorite,
          ),
          _Stat(
            l10n.profilePrayerEntries(prayers.prayers.length),
            prayers.prayers.length,
            Icons.book_outlined,
          ),
          _Stat(
            l10n.profileAiMessages(chat.messageCount),
            chat.messageCount,
            Icons.chat_bubble,
          ),
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          children: [
            // Auth Section
            _AuthSection(
              auth: auth,
              sync: sync,
              preferences: preferences,
              l10n: l10n,
            ),
            const SizedBox(height: 24),
            // Stats
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.25,
                  children: [for (final stat in stats) _StatCard(stat: stat)],
                );
              },
            ),
            const SizedBox(height: 24),
            // Privacy Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.privacy,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.profilePrivacyDescription),
                    const SizedBox(height: 16),
                    if (auth.isSignedIn) ...[
                      Text(
                        'Cloud sync enabled',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      if (sync.lastSyncTime != null)
                        Text(
                          'Last sync: ${_formatDateTime(sync.lastSyncTime!)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatDateTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class _AuthSection extends StatelessWidget {
  const _AuthSection({
    required this.auth,
    required this.sync,
    required this.preferences,
    required this.l10n,
  });

  final AuthService auth;
  final SyncService sync;
  final UserPreferences preferences;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: auth.isSignedIn
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  backgroundImage:
                      auth.isSignedIn && auth.userPicture != null
                          ? NetworkImage(auth.userPicture!)
                          : null,
                  child: auth.isSignedIn && auth.userPicture == null
                      ? Text(
                          (auth.userName ?? preferences.locale)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.isSignedIn
                            ? (auth.userName ?? l10n.yourJourney)
                            : l10n.yourJourney,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.isSignedIn
                            ? (auth.userEmail ?? l10n.dataStoredOnly)
                            : l10n.dataStoredOnly,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (auth.isSignedIn) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (sync.isSyncing)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  else if (sync.lastSyncTime != null)
                    Icon(
                      Icons.cloud_done,
                      size: 16,
                      color: colorScheme.primary,
                    )
                  else
                    Icon(
                      Icons.cloud_off,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sync.isSyncing
                          ? l10n.syncInProgress
                          : sync.lastSyncTime != null
                              ? '${l10n.lastSync} ${_formatDateTime(sync.lastSyncTime!)}'
                              : l10n.neverSynced,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: sync.isSyncing
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (!sync.isSyncing)
                    TextButton.icon(
                      onPressed: () => _handleSync(context),
                      icon: const Icon(Icons.sync, size: 18),
                      label: Text(l10n.syncNow),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleSignOut(context),
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(l10n.signOut),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: auth.isLoading ? null : () => _handleSignIn(context),
                  icon: auth.isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.login, size: 18),
                  label: Text(auth.isLoading
                      ? l10n.signingIn
                      : l10n.signInWithGoogle),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.error!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      },
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    final success = await auth.signInWithGoogle();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in successfully!')),
      );
      // Trigger initial sync
      await sync.sync();
    } else if (context.mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await auth.signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed out')),
      );
    }
  }

  Future<void> _handleSync(BuildContext context) async {
    final success = await sync.sync();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Sync complete!' : 'Sync failed: ${sync.lastError}'),
          backgroundColor: success ? null : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(stat.icon),
            const SizedBox(height: 8),
            Text(
              NumberFormat.decimalPattern(locale).format(stat.value),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;
}
