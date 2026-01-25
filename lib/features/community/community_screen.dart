import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import 'widgets/verse_share.dart';
import 'widgets/quran_puzzle.dart';
import 'models/challenge.dart';
import 'services/challenge_service.dart';
import '../../core/services/service_locator.dart';

/// Community Screen - Social features and fun niches
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ChallengeService _challengeService = getIt<ChallengeService>();
  int _selectedIndex = 0;
  bool _womenModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: TopBar(title: "Community", subtitle: "Connect with the Ummah")),
              Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: _toggleWomenMode,
                  icon: Icon(_womenModeEnabled ? Icons.female : Icons.female_outlined, color: _womenModeEnabled ? Colors.pinkAccent : Colors.white60),
                  tooltip: "Women Mode",
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tabs
          Glass(
            radius: 99,
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(child: _TabPill(label: "Share", icon: Icons.share_rounded, selected: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0))),
                Expanded(child: _TabPill(label: "Challenges", icon: Icons.emoji_events_rounded, selected: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1))),
                Expanded(child: _TabPill(label: "Puzzles", icon: Icons.extension_rounded, selected: _selectedIndex == 2, onTap: () => setState(() => _selectedIndex = 2))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: EnterAnim(
              key: ValueKey(_selectedIndex),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleWomenMode() {
    setState(() => _womenModeEnabled = !_womenModeEnabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_womenModeEnabled ? 'Women-focused content enabled' : 'Women-focused content disabled'), duration: const Duration(seconds: 1)),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return VerseShare(womenMode: _womenModeEnabled);
      case 1: return _buildChallengesTab();
      case 2: return QuranPuzzle(womenMode: _womenModeEnabled);
      default: return VerseShare(womenMode: _womenModeEnabled);
    }
  }

  Widget _buildChallengesTab() {
    return StreamBuilder<List<Challenge>>(
      stream: _challengeService.getActiveChallenges(womenOnly: _womenModeEnabled),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: ImanFlowTheme.gold));
        }

        final challenges = snapshot.data ?? [];
        if (challenges.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text('No active challenges found', style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ],
            ),
          );
        }

        final activeChallenge = challenges.first; // For simplicity, take the first one as active hero
        final upcoming = challenges.skip(1).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Challenge Hero
              _activeChallengeHero(activeChallenge),

              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Upcoming Challenges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                const SizedBox(height: 12),
                ...upcoming.map((c) => _challengeCard(c)),
              ],
            ],
          ),
        );
      }
    );
  }

  Widget _activeChallengeHero(Challenge challenge) {
    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: ImanFlowTheme.gold.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text('🔥 ACTIVE', style: TextStyle(color: ImanFlowTheme.gold, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text('${challenge.daysLeft} days left', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(challenge.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(challenge.description, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 16),
          
          const LinearProgressIndicator(value: 0.1, backgroundColor: Colors.white10, color: ImanFlowTheme.gold, minHeight: 6),
          const SizedBox(height: 8),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
                Text('Started recently', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                Text('${challenge.participantCount} joined', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
             ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _challengeService.joinChallenge(challenge.id),
              style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
              child: const Text('Join Challenge'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _challengeCard(Challenge challenge) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Glass(
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: ImanFlowTheme.emeraldGlow.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(challenge.icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
                  Text(challenge.description, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${challenge.participantCount} joined • Starts ${challenge.startDate.month}/${challenge.startDate.day}', 
                    style: const TextStyle(color: ImanFlowTheme.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: selected ? ImanFlowTheme.emeraldGlow : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.white60),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: selected ? Colors.white : Colors.white60)),
          ],
        ),
      ),
    );
  }
}
