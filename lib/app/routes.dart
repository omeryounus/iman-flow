import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/prayer/prayer_screen.dart';
import '../features/quran_ai/quran_screen.dart';
import '../features/quran_ai/ai_chat_screen.dart';
import '../features/devotionals/devotionals_screen.dart';
import '../features/community/community_screen.dart';
import '../features/premium/paywall_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../shared/widgets/main_shell.dart';

/// App Router using go_router
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/prayer',
            name: 'prayer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerScreen(),
            ),
          ),
          GoRoute(
            path: '/quran',
            name: 'quran',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuranScreen(),
            ),
          ),
          GoRoute(
            path: '/devotionals',
            name: 'devotionals',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DevotionalsScreen(),
            ),
          ),
          GoRoute(
            path: '/community',
            name: 'community',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommunityScreen(),
            ),
          ),
        ],
      ),
      // Standalone routes (outside shell)
      GoRoute(
        path: '/ai-chat',
        name: 'ai-chat',
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );
}
