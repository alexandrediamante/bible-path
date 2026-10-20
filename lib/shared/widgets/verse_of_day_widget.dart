import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

class VerseOfDayWidget extends StatelessWidget {
  final String verse;
  final String reference;

  const VerseOfDayWidget({
    super.key,
    required this.verse,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final isDark = storage.userPreferences?.isDarkMode ?? false;

    return GestureDetector(
      onTap: () => context.go('/bible'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.primaryDark.withOpacity(0.8),
                    AppTheme.primaryColor.withOpacity(0.6),
                  ]
                : [
                    AppTheme.primaryColor.withOpacity(0.9),
                    AppTheme.primaryLight.withOpacity(0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppTheme.primaryDark : AppTheme.primaryColor).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Verse of the Day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"$verse"',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reference,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ActionButton(
                  icon: Icons.favorite_border_rounded,
                  label: 'Favorite',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}