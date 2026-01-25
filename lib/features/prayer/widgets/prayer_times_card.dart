import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'dart:ui';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/streak_service.dart';
import 'dart:async';

/// Prayer Times Card Widget
class PrayerTimesCard extends StatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  final PrayerService _prayerService = getIt<PrayerService>();
  final StreakService _streakService = getIt<StreakService>();
  
  PrayerTimes? _prayerTimes;
  String? _error;
  bool _isLoading = true;
  Duration _timeUntilNext = Duration.zero;
  Timer? _countdownTimer;
  List<String> _completedPrayers = [];

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    _loadCompletedPrayers();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final times = await _prayerService.getPrayerTimes();
      final timeUntil = await _prayerService.getTimeUntilNextPrayer();
      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _timeUntilNext = timeUntil;
          _isLoading = false;
        });
        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCompletedPrayers() async {
    final prayers = await _streakService.getTodayPrayers();
    if (mounted) {
      setState(() {
        _completedPrayers = prayers;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeUntilNext.inSeconds > 0) {
        if (mounted) {
          setState(() {
            _timeUntilNext = _timeUntilNext - const Duration(seconds: 1);
          });
        }
      } else {
        _loadPrayerTimes(); // Refresh when prayer time arrives
      }
    });
  }

  Future<void> _markPrayerComplete(String prayerName) async {
    await _streakService.logPrayer(prayerName);
    await _loadCompletedPrayers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$prayerName prayer marked as complete!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ImanFlowTheme.gold));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text('Location Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text(
                'Please enable location services to calculate accurate prayer times.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPrayerTimes,
                style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Pass the prayer names to helper
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Column(
        children: [
          _buildNextPrayerCard(),
          const SizedBox(height: 16),
          _buildPrayerItem('Fajr', _prayerTimes!.fajr),
          _buildPrayerItem('Sunrise', _prayerTimes!.sunrise, isOptional: true),
          _buildPrayerItem('Dhuhr', _prayerTimes!.dhuhr),
          _buildPrayerItem('Asr', _prayerTimes!.asr),
          _buildPrayerItem('Maghrib', _prayerTimes!.maghrib),
          _buildPrayerItem('Isha', _prayerTimes!.isha),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    final nextPrayer = _prayerTimes!.nextPrayer();
    final nextPrayerName = _prayerService.getPrayerName(nextPrayer);
    
    final hours = _timeUntilNext.inHours;
    final minutes = (_timeUntilNext.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_timeUntilNext.inSeconds % 60).toString().padLeft(2, '0');

    return Glass(
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Next Prayer',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nextPrayerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(hours.toString().padLeft(2, '0'), 'HRS'),
              const SizedBox(width: 12),
              _buildColon(),
              const SizedBox(width: 12),
              _buildTimeUnit(minutes, 'MIN'),
              const SizedBox(width: 12),
              _buildColon(),
              const SizedBox(width: 12),
              _buildTimeUnit(seconds, 'SEC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColon() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(':', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: ImanFlowTheme.gold,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerItem(String name, DateTime time, {bool isOptional = false}) {
    final isPassed = time.isBefore(DateTime.now());
    final isCompleted = _completedPrayers.contains(name);
    final isNext = _prayerService.getPrayerName(_prayerTimes!.nextPrayer()) == name;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isNext ? ImanFlowTheme.gold.withOpacity(0.15) : Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNext ? ImanFlowTheme.gold.withOpacity(0.4) : Colors.white.withOpacity(0.08),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(
          _getPrayerIcon(name),
          color: isNext ? ImanFlowTheme.gold : Colors.white.withOpacity(0.7),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPassed && !isCompleted && !isOptional
                ? Colors.white.withOpacity(0.5)
                : Colors.white,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              _prayerService.formatPrayerTime(time),
              style: TextStyle(
                color: isNext ? ImanFlowTheme.gold : Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isOptional) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: isCompleted ? null : () => _markPrayerComplete(name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? ImanFlowTheme.gold : Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: isCompleted ? ImanFlowTheme.gold : Colors.white.withOpacity(0.3),
                    )
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: isCompleted ? Colors.black : Colors.transparent,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'Fajr': return Icons.wb_twilight_rounded;
      case 'Sunrise': return Icons.wb_sunny_outlined;
      case 'Dhuhr': return Icons.wb_sunny_rounded;
      case 'Asr': return Icons.cloud_outlined;
      case 'Maghrib': return Icons.nights_stay_outlined;
      case 'Isha': return Icons.nights_stay_rounded;
      default: return Icons.access_time_rounded;
    }
  }
}
