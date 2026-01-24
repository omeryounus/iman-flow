import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'background_particles.dart';
import 'screens.dart';

void main() => runApp(const QuranAiApp());

/// ===============================
/// THEME (Royal Emerald & Gold)
/// ===============================
class AppTheme {
  // Royal Emerald base
  static const Color bgTop = Color(0xFF021B1A); // deep emerald-black
  static const Color bgMid = Color(0xFF052C2A); // emerald core
  static const Color bgBot = Color(0xFF063F3B); // richer teal-emerald

  // Premium gold accents
  static const Color gold = Color(0xFFF4D37B); // soft gold
  static const Color goldDeep = Color(0xFFC89B3C); // royal gold

  // Glass cards
  static const Color glass = Color(0x14FFFFFF);
  static const Color glass2 = Color(0x1AFFFFFF);
  static const Color stroke = Color(0x26FFFFFF); // slightly stronger

  // Extra emerald tint for overlays
  static const Color emeraldGlow = Color(0xFF2BE6C6);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: goldDeep,
      ),
    );
  }
}

/// ===============================
/// ROUTER (Real navigation)
/// ===============================
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/quran', builder: (_, __) => const QuranAiScreen()),
        GoRoute(path: '/prayer', builder: (_, __) => const PrayerTimesScreen()),
        GoRoute(path: '/dhikr', builder: (_, __) => const DhikrScreen()),
        GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
      ],
    ),
    GoRoute(
      path: '/dhikr/player',
      builder: (_, __) => const DhikrPlayerScreen(),
    ),
  ],
);

class QuranAiApp extends StatelessWidget {
  const QuranAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Quran AI',
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}

/// ===============================
/// APP SHELL (Bottom Nav + Particles background)
/// ===============================
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/quran')) return 1;
    if (loc.startsWith('/prayer')) return 2;
    if (loc.startsWith('/dhikr')) return 3;
    if (loc.startsWith('/more')) return 4;
    return 0;
  }

  void _go(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/quran');
        break;
      case 2:
        context.go('/prayer');
        break;
      case 3:
        context.go('/dhikr');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(loc);

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
                      active: index == 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () => _go(context, 0),
                    ),
                    NavItem(
                      active: index == 1,
                      icon: Icons.auto_awesome_rounded,
                      label: 'Quran AI',
                      onTap: () => _go(context, 1),
                    ),
                    NavItem(
                      active: index == 2,
                      icon: Icons.access_time_rounded,
                      label: 'Prayer',
                      onTap: () => _go(context, 2),
                    ),
                    NavItem(
                      active: index == 3,
                      icon: Icons.graphic_eq_rounded,
                      label: 'Dhikr',
                      onTap: () => _go(context, 3),
                    ),
                    NavItem(
                      active: index == 4,
                      icon: Icons.grid_view_rounded,
                      label: 'More',
                      onTap: () => _go(context, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================
/// GLASS + NAV ITEM
/// ===============================
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  const Glass({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.glass2,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppTheme.stroke),
          ),
          child: child,
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const NavItem({
    super.key,
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: active ? AppTheme.gold.withOpacity(.12) : Colors.transparent,
            border: Border.all(
              color: active ? AppTheme.gold.withOpacity(.22) : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 22,
                  color: active ? AppTheme.gold : Colors.white.withOpacity(.75)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: active ? AppTheme.gold : Colors.white.withOpacity(.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
