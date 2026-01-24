import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/streak_service.dart';
import 'widgets/daily_hadith_card.dart';
import 'widgets/dhikr_counter.dart';
import 'widgets/dua_wall.dart';

/// Devotionals Screen - Hadith, Dhikr, and Community Duas
class DevotionalsScreen extends StatefulWidget {
  const DevotionalsScreen({super.key});

  @override
  State<DevotionalsScreen> createState() => _DevotionalsScreenState();
}

class _DevotionalsScreenState extends State<DevotionalsScreen> {
  int _selectedIndex = 0;
  final StreakService _streakService = getIt<StreakService>();
  StreakData? _streakData;

  @override
  void initState() {
    super.initState();
    _loadStreaks();
  }

  Future<void> _loadStreaks() async {
    final streaks = await _streakService.getAllStreaks();
    if (mounted) setState(() => _streakData = streaks);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        children: [
          const TopBar(title: "Dhikr & Inspiration", subtitle: "Connect with Allah"),
          const SizedBox(height: 14),

          // Streaks
          if (_streakData != null)
            Row(
              children: [
                Expanded(child: _streakBadge('Prayer', '${_streakData!.prayerStreak}', '🔥')),
                const SizedBox(width: 8),
                Expanded(child: _streakBadge('Quran', '${_streakData!.quranStreak}', '📖')),
                const SizedBox(width: 8),
                Expanded(child: _streakBadge('Dhikr', '${_streakData!.dhikrStreak}', '📿')),
              ],
            ),
          const SizedBox(height: 14),

          // Custom Tabs
          Glass(
            radius: 99,
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(child: _TabPill(label: "Hadith", icon: Icons.format_quote_rounded, selected: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0))),
                Expanded(child: _TabPill(label: "Dhikr", icon: Icons.loop_rounded, selected: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1))),
                Expanded(child: _TabPill(label: "Duas", icon: Icons.volunteer_activism_rounded, selected: _selectedIndex == 2, onTap: () => setState(() => _selectedIndex = 2))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          EnterAnim(
            key: ValueKey(_selectedIndex),
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return DailyHadithCard(onRefresh: _loadStreaks);
      case 1: return DhikrCounter(onComplete: _loadStreaks);
      case 2: return const DuaWall();
      default: return DailyHadithCard(onRefresh: _loadStreaks);
    }
  }

  Widget _streakBadge(String label, String count, String emoji) {
    return Glass(
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
        ],
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
          color: selected ? ImanFlowTheme.gold : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.black : Colors.white60),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: selected ? Colors.black : Colors.white60)),
          ],
        ),
      ),
    );
  }
}
