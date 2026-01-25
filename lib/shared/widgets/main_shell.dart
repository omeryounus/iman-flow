import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_widgets.dart';
import 'premium_background.dart';
import '../../app/theme.dart';

/// Main Shell with Bottom Navigation Bar
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location == '/' || location.startsWith('/home')) return 0;
    if (location.startsWith('/prayer')) return 1;
    if (location.startsWith('/quran')) return 2;
    if (location.startsWith('/devotionals')) return 3;
    if (location.startsWith('/community')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/prayer');
        break;
      case 2:
        context.go('/quran');
        break;
      case 3:
        context.go('/devotionals');
        break;
      case 4:
        context.go('/community');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Stack(
      children: [
        const PremiumBackgroundWithParticles(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: child),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Glass(
                radius: 22,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    NavItem(
                      active: selectedIndex == 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () => _onItemTapped(context, 0),
                    ),
                    NavItem(
                      active: selectedIndex == 1,
                      icon: Icons.access_time_rounded,
                      label: 'Prayer',
                      onTap: () => _onItemTapped(context, 1),
                    ),
                    NavItem(
                      active: selectedIndex == 2,
                      icon: Icons.auto_awesome_rounded,
                      label: 'Quran AI',
                      onTap: () => _onItemTapped(context, 2),
                    ),
                    NavItem(
                      active: selectedIndex == 3,
                      icon: Icons.favorite_rounded, // Devotionals
                      label: 'Devotionals',
                      onTap: () => _onItemTapped(context, 3),
                    ),
                    NavItem(
                      active: selectedIndex == 4,
                      icon: Icons.people_rounded, // Community
                      label: 'Community',
                      onTap: () => _onItemTapped(context, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Preserving the FAB for AI Chat if desired, but styling it to match
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/ai-chat'),
            tooltip: 'Ask AI',
            backgroundColor: ImanFlowTheme.gold,
            foregroundColor: Colors.black,
            child: const Icon(Icons.auto_awesome),
          ),
        ),
      ],
    );
  }
}
