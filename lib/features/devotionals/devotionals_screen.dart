import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
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

class _DevotionalsScreenState extends State<DevotionalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StreakService _streakService = getIt<StreakService>();
  StreakData? _streakData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStreaks();
  }

  Future<void> _loadStreaks() async {
    final streaks = await _streakService.getAllStreaks();
    setState(() => _streakData = streaks);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 60),
                title: const Text(
                  'Devotionals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark
                          ? [
                              ImanFlowTheme.accentTurquoise.withOpacity(0.8),
                              ImanFlowTheme.primaryGreenDark,
                            ]
                          : [
                              ImanFlowTheme.primaryGreenLight,
                              ImanFlowTheme.primaryGreen,
                            ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Streak Badges
                          if (_streakData != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStreakBadge(
                                  '🔥',
                                  '${_streakData!.prayerStreak}',
                                  'Prayer',
                                ),
                                const SizedBox(width: 16),
                                _buildStreakBadge(
                                  '📖',
                                  '${_streakData!.quranStreak}',
                                  'Quran',
                                ),
                                const SizedBox(width: 16),
                                _buildStreakBadge(
                                  '📿',
                                  '${_streakData!.dhikrStreak}',
                                  'Dhikr',
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.format_quote), text: 'Hadith'),
                  Tab(icon: Icon(Icons.loop), text: 'Dhikr'),
                  Tab(icon: Icon(Icons.volunteer_activism), text: 'Dua Wall'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            DailyHadithCard(onRefresh: _loadStreaks),
            DhikrCounter(onComplete: _loadStreaks),
            const DuaWall(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBadge(String emoji, String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
