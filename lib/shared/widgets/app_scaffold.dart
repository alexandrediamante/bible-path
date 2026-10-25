import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bible_path/core/theme/app_theme.dart';
import 'package:bible_path/l10n/app_localizations.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = GoRouterState.of(context).uri.path;
    final destinations = [
      _Destination(Icons.home_rounded, l10n.navHome, '/home'),
      _Destination(Icons.menu_book_rounded, l10n.navBible, '/bible'),
      _Destination(Icons.auto_awesome_rounded, l10n.navAi, '/chat'),
      _Destination(Icons.calendar_today_rounded, l10n.navDaily, '/daily-plan'),

      _Destination(Icons.more_horiz_rounded, l10n.navMore, '/more'),
      _Destination(Icons.headphones_rounded, l10n.navListen, '/listen'),
      _Destination(Icons.favorite_rounded, l10n.navPrayer, '/prayer'),
      _Destination(Icons.school_rounded, l10n.navStudy, '/study'),
      _Destination(Icons.person_rounded, l10n.navProfile, '/profile'),
      _Destination(Icons.settings_rounded, l10n.navSettings, '/settings'),
    ];
    final mobileDestinations = [
      _Destination(Icons.home_rounded, l10n.navHome, '/home'),
      _Destination(Icons.menu_book_rounded, l10n.navBible, '/bible'),
      _Destination(Icons.auto_awesome_rounded, l10n.navAi, '/chat'),
      _Destination(Icons.calendar_today_rounded, l10n.navDaily, '/daily-plan'),

      _Destination(Icons.more_horiz_rounded, l10n.navMore, '/more'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          final exact = mobileDestinations.indexWhere(
            (item) => item.route == route,
          );
          return Scaffold(
            body: SafeArea(bottom: false, child: child),
            bottomNavigationBar: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: exact >= 0 ? exact : 4,
                onDestinationSelected:
                    (index) => context.go(mobileDestinations[index].route),
                destinations: [
                  for (final destination in mobileDestinations)
                    NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.label,
                    ),
                ],
              ),
            ),
          );
        }

        final selected = destinations.indexWhere((item) => item.route == route);
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: selected < 0 ? 4 : selected,
                  onDestinationSelected:
                      (index) => context.go(destinations[index].route),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.primaryColor,
                      size: 30,
                    ),
                  ),
                  destinations: [
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon),
                        label: Text(destination.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination(this.icon, this.label, this.route);

  final IconData icon;
  final String label;
  final String route;
}
