import 'package:flutter/material.dart';

class BibleBookCard extends StatelessWidget {
  final String book;
  final bool isSelected;
  final VoidCallback onTap;

  const BibleBookCard({
    super.key,
    required this.book,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? (isDark ? AppTheme.primaryLight.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1))
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppTheme.primaryLight : AppTheme.primaryColor)
                      : (isDark ? Colors.white10 : Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    book[0],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  book,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}