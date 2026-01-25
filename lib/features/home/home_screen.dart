import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan/adhan.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart'; // Glass, TopBar, EnterAnim, etc.
import '../../core/services/service_locator.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/streak_service.dart';
import '../../core/services/quran_service.dart';
import '../../core/services/premium_service.dart';
import '../../core/services/daily_content_service.dart';
import '../../features/profile/services/user_service.dart';
import '../../features/profile/models/user_profile.dart';

/// Home Screen - Personalized Dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerService _prayerService = getIt<PrayerService>();
  final StreakService _streakService = getIt<StreakService>();
  final PremiumService _premiumService = getIt<PremiumService>();

  PrayerTimes? _prayerTimes;
  StreakData? _streakData;
  Verse? _dailyVerse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Listen for profile changes (auth state + firestore) to refresh home data
    getIt<UserService>().currentUserProfileStream.listen((profile) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _prayerService.getPrayerTimes().then((v) => v as PrayerTimes?).catchError((_) => null),
        _streakService.getAllStreaks(),
        getIt<DailyContentService>().getDailyVerse().then((v) => v as Verse?).catchError((_) => null),
        getIt<UserService>().currentUserProfileStream.first.catchError((_) => null),
      ]);

      // Sync streaks if user is logged in
      final profile = results[3] as UserProfile?;
      if (profile != null) {
        await _streakService.syncWithRemote(
          profile.prayerStreak, 
          profile.quranStreak, 
          profile.dhikrStreak
        );
        results[1] = await _streakService.getAllStreaks();
      }

      if (mounted) {
        setState(() {
          _prayerTimes = results[0] as PrayerTimes?;
          _streakData = results[1] as StreakData;
          _dailyVerse = results[2] as Verse?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If loading, show simple loader or empty
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ImanFlowTheme.gold));
    }

    final String greeting = _getGreeting();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBar(title: greeting, subtitle: "Prayer • Dhikr • Quran"),
          const SizedBox(height: 14),

          // Next Prayer Card
          if (_prayerTimes != null) ...[
            EnterAnim(delayMs: 0, child: _buildNextPrayerCard()),
            const SizedBox(height: 14),
          ],

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 14),

          // Streaks
          if (_streakData != null) ...[
             EnterAnim(delayMs: 100, child: _buildStreaksSection()),
             const SizedBox(height: 14),
          ],

          // Daily Verse
          if (_dailyVerse != null) ...[
            EnterAnim(delayMs: 200, child: _buildDailyVerseCard()),
            const SizedBox(height: 14),
          ],
          
          // Premium Banner
          _buildPremiumBanner(),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  Widget _buildNextPrayerCard() {
    final nextPrayer = _prayerTimes!.nextPrayer();
    final nextPrayerName = _nextPrayerName(nextPrayer);
    final nextPrayerTime = _nextPrayerTime(nextPrayer);

    return Glass(
      radius: 28,
      padding: const EdgeInsets.all(0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ImanFlowTheme.gold.withOpacity(.10), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill(text: "Next: $nextPrayerName", gold: true),
                const Spacer(),
                Text(
                  _prayerService.formatPrayerTime(nextPrayerTime),
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white.withOpacity(0.9)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text("Prayer Times", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            // Mini list of prayers
            _miniPrayerRow("Fajr", _prayerTimes!.fajr, nextPrayer == Prayer.fajr),
            _miniPrayerRow("Dhuhr", _prayerTimes!.dhuhr, nextPrayer == Prayer.dhuhr),
            _miniPrayerRow("Asr", _prayerTimes!.asr, nextPrayer == Prayer.asr),
            _miniPrayerRow("Maghrib", _prayerTimes!.maghrib, nextPrayer == Prayer.maghrib),
            _miniPrayerRow("Isha", _prayerTimes!.isha, nextPrayer == Prayer.isha),
          ],
        ),
      ),
    );
  }

  String _nextPrayerName(Prayer p) {
    if (p == Prayer.none) return "Fajr (Tom)";
    return _prayerService.getPrayerName(p);
  }

  DateTime _nextPrayerTime(Prayer p) {
    if (p == Prayer.none) return _prayerTimes!.fajr.add(const Duration(days: 1));
    return _prayerTimes!.timeForPrayer(p)!;
  }

  Widget _miniPrayerRow(String name, DateTime time, bool isNext) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(name, style: TextStyle(
            color: isNext ? ImanFlowTheme.gold : Colors.white.withOpacity(0.7),
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          )),
          const Spacer(),
          Text(
            _prayerService.formatPrayerTime(time), 
            style: TextStyle(
              color: isNext ? ImanFlowTheme.gold : Colors.white.withOpacity(0.7),
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
             Expanded(child: _quickActionTile(Icons.auto_awesome_rounded, "AI Chat", () => context.push('/ai-chat'))),
             const SizedBox(width: 10),
             Expanded(child: _quickActionTile(Icons.explore_rounded, "Qibla", () => context.go('/prayer'))),
             const SizedBox(width: 10),
             Expanded(child: _quickActionTile(Icons.graphic_eq_rounded, "Dhikr", () => context.go('/devotionals'))),
          ],
        );
      }
    );
  }

  Widget _quickActionTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 18,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: ImanFlowTheme.gold, size: 26),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksSection() {
    return Glass(
      radius: 22,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _streakItem("Prayer", _streakData!.prayerStreak, Icons.access_time_rounded),
          _streakItem("Quran", _streakData!.quranStreak, Icons.menu_book_rounded),
          _streakItem("Dhikr", _streakData!.dhikrStreak, Icons.graphic_eq_rounded),
        ],
      ),
    );
  }

  Widget _streakItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: ImanFlowTheme.emeraldGlow, size: 20),
        const SizedBox(height: 4),
        Text("$count", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildDailyVerseCard() {
    return Glass(
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           Row(children: [
             const Icon(Icons.auto_stories_rounded, color: ImanFlowTheme.gold, size: 18),
             const SizedBox(width: 8),
             Text("Verse of the Day", style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.bold)),
           ]),
           const SizedBox(height: 12),
           AyahCard(
             arabic: _dailyVerse!.textArabic,
             translation: _dailyVerse!.translation ?? "",
           ),
           const SizedBox(height: 8),
           Text(_dailyVerse!.verseKey, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return StreamBuilder<bool>(
      stream: _premiumService.isPremiumStream,
      initialData: _premiumService.isPremium,
      builder: (context, snapshot) {
        if (snapshot.data == true) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 14),
          child: GestureDetector(
            onTap: () => context.push('/premium'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [ImanFlowTheme.gold, ImanFlowTheme.goldDeep],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.black, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Unlock Premium", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                        Text("Unlimited AI & Ad-free", style: TextStyle(color: Colors.black87, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: Colors.black.withOpacity(0.6)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
