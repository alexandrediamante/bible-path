import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:go_router/go_router.dart';

import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

class CustomTitleBar extends StatefulWidget {
  final VoidCallback onMenuToggle;
  final bool isSidebarCollapsed;

  const CustomTitleBar({
    super.key,
    required this.onMenuToggle,
    required this.isSidebarCollapsed,
  });

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> {
  bool _isMaximized = false;

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final isDark = storage.userPreferences?.isDarkMode ?? false;
    final currentRoute = GoRouterState.of(context).uri.path;
    final title = _getTitleForRoute(currentRoute);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Window Controls (macOS style - left side)
          Row(
            children: [
              _WindowButton(
                color: const Color(0xFFFF5F57),
                onPressed: () => windowManager.close(),
                hoverColor: const Color(0xFFFF5F57).withOpacity(0.8),
              ),
              _WindowButton(
                color: const Color(0xFFFEBC2E),
                onPressed: () => windowManager.minimize(),
                hoverColor: const Color(0xFFFEBC2E).withOpacity(0.8),
              ),
              _WindowButton(
                color: const Color(0xFF28C840),
                onPressed: _toggleMaximize,
                hoverColor: const Color(0xFF28C840).withOpacity(0.8),
              ),
            ],
          ),

          // Title
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
            ),
          ),

          // Right side actions
          Row(
            children: [
              // Menu Toggle
              IconButton(
                icon: Icon(
                  widget.isSidebarCollapsed
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  size: 20,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
                onPressed: widget.onMenuToggle,
                tooltip: widget.isSidebarCollapsed ? 'Show Sidebar' : 'Hide Sidebar',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),

              // Theme Toggle
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 20,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                ),
                onPressed: () => storage.setDarkMode(!isDark),
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitleForRoute(String route) {
    switch (route) {
      case '/home': return 'Home';
      case '/bible': return 'Bible';
      case '/chat': return 'Bible AI Chat';
      case '/daily-plan': return 'Daily Plan';
      case '/prayer': return 'Prayer Wall';
      case '/study': return 'Study Plans';
      case '/profile': return 'Profile';
      case '/settings': return 'Settings';
      default: return 'Bible Path';
    }
  }

  Future<void> _toggleMaximize() async {
    _isMaximized = !_isMaximized;
    if (_isMaximized) {
      await windowManager.maximize();
    } else {
      await windowManager.unmaximize();
    }
    setState(() {});
  }
}

class _WindowButton extends StatefulWidget {
  final Color color;
  final VoidCallback onPressed;
  final Color hoverColor;

  const _WindowButton({
    required this.color,
    required this.onPressed,
    required this.hoverColor,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(left: 10, right: 6),
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}