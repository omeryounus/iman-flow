import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/streak_service.dart';
import '../../core/services/quran_service.dart';
import '../../core/services/premium_service.dart';
import 'package:adhan/adhan.dart';

/// Home Screen - Personalized Dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerService _prayerService = getIt<PrayerService>();
  final StreakService _streakService = getIt<StreakService>();
  final QuranService _quranService = getIt<QuranService>();
  final PremiumService _premiumService = getIt<PremiumService>();

  PrayerTimes? _prayerTimes;
  StreakData? _streakData;
  Verse? _dailyVerse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _prayerService.getPrayerTimes().catchError((_) => null),
        _streakService.getAllStreaks(),
        _quranService.getRandomVerse().catchError((_) => null),
      ]);

      setState(() {
        _prayerTimes = results[0] as PrayerTimes?;
        _streakData = results[1] as StreakData;
        _dailyVerse = results[2] as Verse?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greeting = _getGreeting();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              title: Text(
                '$greeting\nIman Flow',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            ImanFlowTheme.primaryGreenDark,
                            ImanFlowTheme.primaryGreen.withOpacity(0.8),
                          ]
                        : [
                            ImanFlowTheme.primaryGreen,
                            ImanFlowTheme.accentTurquoise,
                          ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Next Prayer Card
                if (_prayerTimes != null) _buildNextPrayerCard(),
                const SizedBox(height: 16),

                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 20),

                // Streaks
                if (_streakData != null) _buildStreaksSection(),
                const SizedBox(height: 20),

                // Daily Verse
                if (_dailyVerse != null) _buildDailyVerseCard(),
                const SizedBox(height: 20),

                // Quick Links Grid
                _buildQuickLinksGrid(),
                const SizedBox(height: 20),

                // Premium Upgrade Banner (for free users)
                _buildPremiumBanner(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    if (hour < 21) return 'Good Evening 🌅';
    return 'Good Night 🌙';
  }

  Widget _buildNextPrayerCard() {
    final nextPrayer = _prayerTimes!.nextPrayer();
    final nextPrayerName = _prayerService.getPrayerName(nextPrayer);
    
    // Handle the case when all prayers have passed - show tomorrow's Fajr time
    DateTime? nextPrayerTime;
    bool isTomorrow = false;
    
    if (nextPrayer == Prayer.none) {
      // After Isha, show tomorrow's Fajr (we'll calculate it)
      // For now, show today's Fajr time as reference with (Tomorrow) label
      nextPrayerTime = _prayerTimes!.fajr.add(const Duration(days: 1));
      isTomorrow = true;
    } else {
      nextPrayerTime = _prayerTimes!.timeForPrayer(nextPrayer);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ImanFlowTheme.primaryGreen,
            ImanFlowTheme.accentTurquoise,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ImanFlowTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Prayer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextPrayerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  nextPrayerTime != null
                      ? _prayerService.formatPrayerTime(nextPrayerTime)
                      : '--:--',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPrayerTimeChip('Fajr', _prayerTimes!.fajr),
              _buildPrayerTimeChip('Dhuhr', _prayerTimes!.dhuhr),
              _buildPrayerTimeChip('Asr', _prayerTimes!.asr),
              _buildPrayerTimeChip('Maghrib', _prayerTimes!.maghrib),
              _buildPrayerTimeChip('Isha', _prayerTimes!.isha),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeChip(String name, DateTime time) {
    final isPassed = time.isBefore(DateTime.now());
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: Colors.white.withOpacity(isPassed ? 0.5 : 0.8),
            fontSize: 10,
          ),
        ),
        Text(
          _prayerService.formatPrayerTime(time).replaceAll(' AM', '').replaceAll(' PM', ''),
          style: TextStyle(
            color: Colors.white.withOpacity(isPassed ? 0.5 : 1.0),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'AI Chat',
            Icons.auto_awesome,
            ImanFlowTheme.accentGold,
            () => context.push('/ai-chat'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Qibla',
            Icons.explore,
            ImanFlowTheme.primaryGreen,
            () => context.go('/prayer'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Dhikr',
            Icons.loop,
            ImanFlowTheme.accentTurquoise,
            () => context.go('/devotionals'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🔥 Your Streaks',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStreakCard(
                'Prayer',
                _streakData!.prayerStreak,
                Icons.access_time,
                ImanFlowTheme.fajrColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStreakCard(
                'Quran',
                _streakData!.quranStreak,
                Icons.menu_book,
                ImanFlowTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStreakCard(
                'Dhikr',
                _streakData!.dhikrStreak,
                Icons.favorite,
                ImanFlowTheme.accentGold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakCard(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyVerseCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ImanFlowTheme.primaryGreen.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_stories, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Verse of the Day',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _dailyVerse!.verseKey,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _dailyVerse!.textArabic,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    height: 2,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : ImanFlowTheme.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_dailyVerse!.translation != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _dailyVerse!.translation!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✨ Quick Access',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildQuickLink('Quran', Icons.menu_book, () => context.go('/quran')),
            _buildQuickLink('Duas', Icons.headphones, () => context.go('/prayer')),
            _buildQuickLink('Hadith', Icons.format_quote, () => context.go('/devotionals')),
            _buildQuickLink('Puzzles', Icons.extension, () => context.go('/community')),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickLink(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: ImanFlowTheme.primaryGreen),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return StreamBuilder<bool>(
      stream: _premiumService.isPremiumStream,
      initialData: _premiumService.isPremium,
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;

        // Don't show banner for premium users
        if (isPremium) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => context.push('/premium'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ImanFlowTheme.accentGold,
                  ImanFlowTheme.accentGold.withRed(200),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ImanFlowTheme.accentGold.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unlock Iman Flow Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Unlimited AI insights, ad-free & more',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
