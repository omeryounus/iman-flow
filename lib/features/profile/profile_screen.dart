import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            Future<void> handleLogin(Future<UserCredential?> Function() loginAction) async {
              setModalState(() => isLoggingIn = true);
              try {
                final credential = await loginAction();
                if (credential != null && context.mounted) {
                  Navigator.pop(context); // close modal
                  context.go('/home');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Welcome! You are now signed in'), backgroundColor: ImanFlowTheme.gold),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e'), backgroundColor: Colors.redAccent));
                }
              } finally {
                if (context.mounted) setModalState(() => isLoggingIn = false);
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
    final displayName = profile?.displayName ?? user.displayName ?? user.email?.split('@')[0] ?? 'User';
    final photoUrl = profile?.photoURL ?? user.photoURL;
    final email = profile?.email ?? user.email;
    final joinedAt = profile?.joinedAt;
    final versesCount = profile?.versesSharedCount ?? 0;
    final likesCount = profile?.likesReceivedCount ?? 0;
    final prayerStreak = profile?.prayerStreak ?? 0;
    final quranStreak = profile?.quranStreak ?? 0;
    final dhikrStreak = profile?.dhikrStreak ?? 0;
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
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? Text(displayName[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: ImanFlowTheme.gold))
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        if (email != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(email, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
          ),
        if (joinedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Member since ${DateFormat('MMMM yyyy').format(joinedAt)}',
              style: TextStyle(color: ImanFlowTheme.gold.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        if (bio != null && bio.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(bio, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
        
        const SizedBox(height: 32),

        // Stats Cards - Social
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.share_rounded, '$versesCount', 'Verses Shared')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.favorite_rounded, '$likesCount', 'Likes Received')),
          ],
        ),

        const SizedBox(height: 16),

        // Stats Cards - Streaks
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.local_fire_department_rounded, '$prayerStreak', 'Prayer Streak')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.menu_book_rounded, '$quranStreak', 'Quran Streak')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.auto_awesome_rounded, '$dhikrStreak', 'Dhikr Streak')),
          ],
        ),

        const SizedBox(height: 32),

        // Settings menu
        Glass(
          radius: 16,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
               _buildSettingsTile(Icons.edit, 'Edit Profile', () => _showEditProfileDialog(profile)),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: ImanFlowTheme.gold, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            label, 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
  
  void _showEditProfileDialog(UserProfile? profile) {
    final nameController = TextEditingController(text: profile?.displayName);
    final bioController = TextEditingController(text: profile?.bio);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ImanFlowTheme.bgMid,
          surfaceTintColor: Colors.transparent,
          title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white60),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ImanFlowTheme.gold)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: const TextStyle(color: Colors.white60),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ImanFlowTheme.gold)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            if (isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ImanFlowTheme.gold)),
              )
            else
              TextButton(
                onPressed: () async {
                  setDialogState(() => isSaving = true);
                  try {
                    await _userService.createOrUpdateProfile(
                      displayName: nameController.text.trim(),
                      bio: bioController.text.trim(),
                    );
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      setDialogState(() => isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
                    }
                  }
                },
                child: const Text('Save', style: TextStyle(color: ImanFlowTheme.gold)),
              ),
          ],
        ),
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
