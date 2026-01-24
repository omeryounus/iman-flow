import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import '../../shared/widgets/premium_background.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/auth_service.dart';
import 'models/user_profile.dart';
import 'services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = getIt<UserService>();
  final AuthService _authService = getIt<AuthService>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const PremiumBackgroundWithParticles(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      const BackButton(color: Colors.white),
                      const Expanded(child: TopBar(title: "My Profile", subtitle: "Your spiritual journey")),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  StreamBuilder<UserProfile?>(
                    stream: _userService.currentUserProfileStream,
                    builder: (context, snapshot) {
                      final user = _auth.currentUser;
                      if (user == null) return _buildGuestView();

                      // If profile data is still loading but user is authenticated
                      final profile = snapshot.data;
                      return _buildUserProfileView(user, profile);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestView() {
    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.account_circle_outlined, size: 80, color: Colors.white60),
          const SizedBox(height: 24),
          const Text('Join the Community', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Text(
            'Sign up to track your spiritual journey, see your shared verses impact, and customize your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(height: 1.5, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showLoginOptions(),
              style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Sign In / Sign Up'),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ImanFlowTheme.bgMid,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        bool isLoggingIn = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleLogin(Future<void> Function() loginAction) async {
              setModalState(() => isLoggingIn = true);
              try {
                await loginAction();
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  setModalState(() => isLoggingIn = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e'), backgroundColor: Colors.redAccent));
                }
              }
            }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Sign In to Iman Flow', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Your progress will be synced across all your devices.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
                const SizedBox(height: 24),
                if (isLoggingIn)
                  const Center(child: CircularProgressIndicator(color: ImanFlowTheme.gold))
                else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => handleLogin(() => _authService.signInWithGoogle()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.all(16)),
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => handleLogin(() => _authService.signInAnonymously()),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.all(16), side: const BorderSide(color: Colors.white24)),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Continue Anonymously'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    },
    );
  }

  Widget _buildUserProfileView(User user, UserProfile? profile) {
    if (profile == null) {
      // Trigger creation if profile doesn't exist yet, but show fallback UI
      _userService.createOrUpdateProfile();
    }

    final displayName = profile?.displayName ?? user.displayName ?? user.email?.split('@')[0] ?? 'User';
    final photoUrl = user.photoURL;
    final versesCount = profile?.versesSharedCount ?? 0;
    final likesCount = profile?.likesReceivedCount ?? 0;
    final bio = profile?.bio;

    return Column(
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ImanFlowTheme.gold, width: 2),
            boxShadow: [BoxShadow(color: ImanFlowTheme.gold.withOpacity(0.3), blurRadius: 20)],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: ImanFlowTheme.bgMid,
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Text(displayName[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: ImanFlowTheme.gold))
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        if (bio != null && bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(bio, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
        
        const SizedBox(height: 32),

        // Stats Cards
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.share, '$versesCount', 'Verses Shared')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(Icons.favorite, '$likesCount', 'Likes Received')),
          ],
        ),

        const SizedBox(height: 32),

        // Settings menu
        Glass(
          radius: 16,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
               _buildSettingsTile(Icons.edit, 'Edit Profile', () {}),
               _buildSettingsTile(Icons.settings, 'Account Settings', () => context.push('/settings')),
               _buildSettingsTile(Icons.logout, 'Sign Out', () => _authService.signOut(), isDestructive: true, showDivider: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Glass(
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: ImanFlowTheme.gold, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }
  
  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false, bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70),
          title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white)),
          trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.white30),
          onTap: onTap,
        ),
        if (showDivider) Divider(height: 1, color: Colors.white.withOpacity(0.1), indent: 16, endIndent: 16),
      ],
    );
  }
}
