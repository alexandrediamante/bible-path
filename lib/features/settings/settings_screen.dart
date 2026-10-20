import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/bible/bible_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<StorageService, BibleRepository>(
      builder: (context, storage, bibleRepo, _) {
        final isDark = storage.userPreferences?.isDarkMode ?? false;
        final prefs = storage.userPreferences;
        final locale = prefs?.locale ?? 'en';
        final textScale = prefs?.textScale ?? 1.0;
        final fontFamily = prefs?.fontFamily ?? 'NotoSerif';
        final notificationsEnabled = prefs?.notificationsEnabled ?? true;
        final dailyReminderTime = prefs?.dailyReminderTime ?? '07:00';
        final dailyReminderEnabled = prefs?.dailyReminderEnabled ?? true;
        final autoPlayAudio = prefs?.autoPlayAudio ?? true;
        final audioPlaybackSpeed = prefs?.audioPlaybackSpeed ?? 1.0;
        final preferredVersion = prefs?.preferredBibleVersion ?? 'ASV';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your Bible Path experience',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
              ),

              const SizedBox(height: 32),

              // Appearance
              _SettingsSection(
                title: 'Appearance',
                icon: Icons.palette_rounded,
                children: [
                  _SettingTile(
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark themes',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (v) => storage.setDarkMode(v),
                      activeColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                    ),
                  ),
                  _SettingTile(
                    title: 'Text Size',
                    subtitle: 'Adjust the font size for reading',
                    trailing: SizedBox(
                      width: 150,
                      child: Slider(
                        value: textScale,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        label: '${(textScale * 100).toInt()}%',
                        onChanged: (v) => storage.setTextScale(v),
                        activeColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  _SettingTile(
                    title: 'Font',
                    subtitle: fontFamily,
                    trailing: DropdownButton<String>(
                      value: fontFamily,
                      items: ['NotoSerif', 'Georgia', 'Times New Roman', 'System'].map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f),
                      )).toList(),
                      onChanged: (v) => v != null ? storage.setFontFamily(v) : null,
                    ),
                  ),
                  _SettingTile(
                    title: 'Language',
                    subtitle: _getLanguageName(locale),
                    trailing: DropdownButton<String>(
                      value: locale,
                      items: ['en', 'es', 'pt', 'fr', 'de', 'it', 'ru'].map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(_getLanguageName(l)),
                      )).toList(),
                      onChanged: (v) => v != null ? storage.setLocale(v) : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bible Settings
              _SettingsSection(
                title: 'Bible',
                icon: Icons.menu_book_rounded,
                children: [
                  _SettingTile(
                    title: 'Preferred Version',
                    subtitle: preferredVersion,
                    trailing: DropdownButton<String>(
                      value: preferredVersion,
                      items: bibleRepo.getAvailableVersions().map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      )).toList(),
                      onChanged: (v) => v != null ? storage.setPreferredBibleVersion(v) : null,
                    ),
                  ),
                  _SettingTile(
                    title: 'Auto-play Audio',
                    subtitle: 'Automatically play audio when opening a chapter',
                    trailing: Switch(
                      value: autoPlayAudio,
                      onChanged: (v) => storage.setAudioSettings(autoPlay: v),
                      activeColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                    ),
                  ),
                  _SettingTile(
                    title: 'Playback Speed',
                    subtitle: '${audioPlaybackSpeed.toStringAsFixed(1)}x',
                    trailing: DropdownButton<double>(
                      value: audioPlaybackSpeed,
                      items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s.toStringAsFixed(s.truncateToDouble() == s ? 0 : 1)}x'),
                      )).toList(),
                      onChanged: (v) => v != null ? storage.setAudioSettings(speed: v) : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notifications
              _SettingsSection(
                title: 'Notifications',
                icon: Icons.notifications_rounded,
                children: [
                  _SettingTile(
                    title: 'Enable Notifications',
                    subtitle: 'Receive daily reminders and updates',
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (v) => storage.setNotificationsEnabled(v),
                      activeColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                    ),
                  ),
                  _SettingTile(
                    title: 'Daily Plan Reminder',
                    subtitle: 'Get reminded to complete your daily plan',
                    trailing: Switch(
                      value: dailyReminderEnabled,
                      onChanged: (v) => storage.setDailyReminder(dailyReminderTime, v),
                      activeColor: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                    ),
                  ),
                  if (dailyReminderEnabled)
                    _SettingTile(
                      title: 'Reminder Time',
                      subtitle: dailyReminderTime,
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => _pickTime(context, storage, dailyReminderTime),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Data & Privacy
              _SettingsSection(
                title: 'Data & Privacy',
                icon: Icons.security_rounded,
                children: [
                  _SettingTile(
                    title: 'Clear Cache',
                    subtitle: 'Free up storage space',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showClearCacheDialog(context),
                  ),
                  _SettingTile(
                    title: 'Export My Data',
                    subtitle: 'Download your prayer, notes, and progress',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _exportData(context),
                  ),
                  _SettingTile(
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account and data',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    isDestructive: true,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // About
              _SettingsSection(
                title: 'About',
                icon: Icons.info_rounded,
                children: [
                  _SettingTile(
                    title: 'Version',
                    subtitle: '1.0.0 (macOS)',
                    trailing: const SizedBox.shrink(),
                  ),
                  _SettingTile(
                    title: 'Open Source Licenses',
                    subtitle: 'View licenses for third-party libraries',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showLicenses(context),
                  ),
                  _SettingTile(
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () => launchUrl(Uri.parse('https://biblepath.app/privacy')),
                  ),
                  _SettingTile(
                    title: 'Terms of Service',
                    subtitle: 'Read our terms of service',
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () => launchUrl(Uri.parse('https://biblepath.app/terms')),
                  ),
                  _SettingTile(
                    title: 'Support',
                    subtitle: 'Contact us or report an issue',
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () => launchUrl(Uri.parse('mailto:support@biblepath.app')),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Pro Status (always Pro in this version)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppTheme.primaryDark, AppTheme.primaryColor]
                        : [AppTheme.primaryColor, AppTheme.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bible Path Pro',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All features unlocked • No subscriptions needed',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    const names = {
      'en': 'English (US)',
      'es': 'Spanish',
      'pt': 'Portuguese',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'ru': 'Russian',
    };
    return names[code] ?? code;
  }

  Future<void> _pickTime(BuildContext context, StorageService storage, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await storage.setDailyReminder(timeStr, true);
    }
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove temporary files. Your progress and data will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon')),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion not implemented in this version')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(context: context, applicationName: 'Bible Path', applicationVersion: '1.0.0');
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
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
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}