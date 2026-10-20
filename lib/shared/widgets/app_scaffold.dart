import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:go_router/go_router.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'custom_title_bar.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  static const List<NavigationItem> _navItems = [
    NavigationItem(icon: Icons.home_rounded, label: 'Home', route: '/home'),
    NavigationItem(icon: Icons.menu_book_rounded, label: 'Bible', route: '/bible'),
    NavigationItem(icon: Icons.chat_bubble_rounded, label: 'Chat', route: '/chat'),
    NavigationItem(icon: Icons.calendar_today_rounded, label: 'Daily Plan', route: '/daily-plan'),
    NavigationItem(icon: Icons.favorite_rounded, label: 'Prayer', route: '/prayer'),
    NavigationItem(icon: Icons.school_rounded, label: 'Study', route: '/study'),
    NavigationItem(icon: Icons.person_rounded, label: 'Profile', route: '/profile'),
    NavigationItem(icon: Icons.settings_rounded, label: 'Settings', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final isDark = storage.userPreferences?.isDarkMode ?? false;
    final currentRoute = GoRouterState.of(context).uri.path;

    _selectedIndex = _navItems.indexWhere((item) => item.route == currentRoute);
    if (_selectedIndex == -1) _selectedIndex = 0;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 72 : 260,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                right: BorderSide(
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // App Logo/Title
                SizedBox(
                  height: 72,
                  child: Center(
                    child: _isSidebarCollapsed
                        ? Icon(
                            Icons.auto_awesome_rounded,
                            size: 32,
                            color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 28,
                                color: isDark ? AppTheme.primaryLight : AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Bible Path',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                ),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = index == _selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: _isSidebarCollapsed
                            ? _CollapsedNavItem(
                                item: item,
                                isSelected: isSelected,
                                onTap: () => _onNavTap(index),
                              )
                            : _ExpandedNavItem(
                                item: item,
                                isSelected: isSelected,
                                onTap: () => _onNavTap(index),
                              ),
                      );
                    },
                  ),
                ),

                // Collapse/Expand Button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: _isSidebarCollapsed ? Alignment.center : Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        _isSidebarCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                      ),
                      onPressed: () {
                        setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
                      },
                      tooltip: _isSidebarCollapsed ? 'Expand' : 'Collapse',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Custom Title Bar (for macOS window controls)
                CustomTitleBar(
                  onMenuToggle: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                  isSidebarCollapsed: _isSidebarCollapsed,
                ),

                // Content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index].route);
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class _CollapsedNavItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CollapsedNavItem({
    required this.item,
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
        child: SizedBox(
          width: 56,
          height: 48,
          child: Center(
            child: Icon(
              item.icon,
              size: 24,
              color: isSelected
                  ? (isDark ? AppTheme.primaryLight : AppTheme.primaryColor)
                  : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedNavItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpandedNavItem({
    required this.item,
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
              Icon(
                item.icon,
                size: 22,
                color: isSelected
                    ? (isDark ? AppTheme.primaryLight : AppTheme.primaryColor)
                    : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight)
                        : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}