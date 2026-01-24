import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import 'widgets/prayer_times_card.dart';
import 'widgets/qibla_compass.dart';
import 'widgets/dua_section.dart';

/// Prayer Screen - Main prayer tab with times, Qibla, and Duas
class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopBar(title: "Prayer Times", subtitle: "Your Location • Hijri Date"),
          const SizedBox(height: 14),
          
          // Custom Tab Selector
          Glass(
            radius: 99,
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(child: _TabPill(label: "Times", icon: Icons.access_time_filled_rounded, selected: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0))),
                const SizedBox(width: 6),
                Expanded(child: _TabPill(label: "Qibla", icon: Icons.explore_rounded, selected: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1))),
                const SizedBox(width: 6),
                Expanded(child: _TabPill(label: "Duas", icon: Icons.headphones_rounded, selected: _selectedIndex == 2, onTap: () => setState(() => _selectedIndex = 2))),
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

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0: return const PrayerTimesCard();
      case 1: return const QiblaCompass();
      case 2: return const DuaSection();
      default: return const PrayerTimesCard();
    }
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
            Icon(icon, size: 18, color: selected ? Colors.black : Colors.white.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 13,
              color: selected ? Colors.black : Colors.white.withOpacity(0.6)
            )),
          ],
        ),
      ),
    );
  }
}
