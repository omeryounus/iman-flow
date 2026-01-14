import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authSnapshot.data;

          if (user == null) {
            return _buildGuestView();
          }

          return StreamBuilder<UserProfile?>(
            stream: _userService.currentUserProfileStream,
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final profile = profileSnapshot.data;
              return _buildUserProfileView(user, profile);
            },
          );
        },
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Join the Community',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign up to track your spiritual journey, see your shared verses impact, and customize your profile.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to auth or trigger auth flow
                // For MVP, meaningful auth not implemented, showing placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auth flow not implemented in this demo')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Sign In / Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileView(User user, UserProfile? profile) {
    if (profile == null) {
      // Create default profile if missing
      _userService.createOrUpdateProfile();
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ImanFlowTheme.primaryGreen, width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: ImanFlowTheme.primaryGreen.withOpacity(0.1),
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Text(
                      (profile.displayName ?? 'U')[0].toUpperCase(),
                      style: TextStyle(fontSize: 32, color: ImanFlowTheme.primaryGreen),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName ?? 'User',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                profile.bio!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          
          const SizedBox(height: 32),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.share,
                  '${profile.versesSharedCount}',
                  'Verses Shared',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  Icons.favorite,
                  '${profile.likesReceivedCount}',
                  'Likes Received',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Settings Section
          _buildSettingsTile(Icons.edit, 'Edit Profile', () {
             // TODO: Edit Profile Dialog
          }),
          _buildSettingsTile(Icons.settings, 'Account Settings', () {}),
          _buildSettingsTile(Icons.logout, 'Sign Out', () async {
            await FirebaseAuth.instance.signOut();
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: ImanFlowTheme.accentGold, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        title, 
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
