import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import 'models/user_profile.dart';
import 'services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        children: [
          const TopBar(title: "My Profile", subtitle: "Your spiritual journey"),
          const SizedBox(height: 24),
          
          StreamBuilder<User?>(
            stream: _auth.authStateChanges(),
            builder: (context, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: ImanFlowTheme.gold);
              final user = authSnapshot.data;
              if (user == null) return _buildGuestView();

              return StreamBuilder<UserProfile?>(
                stream: _userService.currentUserProfileStream,
                builder: (context, profileSnapshot) {
                  final profile = profileSnapshot.data;
                  return _buildUserProfileView(user, profile);
                },
              );
            },
          ),
        ],
      ),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Auth flow not implemented in this demo'), backgroundColor: ImanFlowTheme.bgMid));
              },
              style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Sign In / Sign Up'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileView(User user, UserProfile? profile) {
    if (profile == null) {
      _userService.createOrUpdateProfile();
      return const CircularProgressIndicator(color: ImanFlowTheme.gold);
    }

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
                ? Text((profile.displayName ?? 'U')[0].toUpperCase(), style: const TextStyle(fontSize: 32, color: ImanFlowTheme.gold))
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(profile.displayName ?? 'User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        if (profile.bio != null && profile.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(profile.bio!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
        
        const SizedBox(height: 32),

        // Stats Cards
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.share, '${profile.versesSharedCount}', 'Verses Shared')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(Icons.favorite, '${profile.likesReceivedCount}', 'Likes Received')),
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
               _buildSettingsTile(Icons.settings, 'Account Settings', () {}),
               _buildSettingsTile(Icons.logout, 'Sign Out', () async => await FirebaseAuth.instance.signOut(), isDestructive: true, showDivider: false),
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
