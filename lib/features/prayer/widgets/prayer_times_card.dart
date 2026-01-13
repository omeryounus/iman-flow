import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../../../app/theme.dart';
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
      setState(() {
        _prayerTimes = times;
        _timeUntilNext = timeUntil;
        _isLoading = false;
      });
      _startCountdown();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCompletedPrayers() async {
    final prayers = await _streakService.getTodayPrayers();
    setState(() {
      _completedPrayers = prayers;
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeUntilNext.inSeconds > 0) {
        setState(() {
          _timeUntilNext = _timeUntilNext - const Duration(seconds: 1);
        });
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
          content: Text('$prayerName prayer marked as complete! 🤲'),
          backgroundColor: ImanFlowTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Location Required',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Please enable location services to calculate accurate prayer times.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPrayerTimes,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final prayers = [
      _buildPrayerItem('Fajr', _prayerTimes!.fajr, ImanFlowTheme.fajrColor),
      _buildPrayerItem('Sunrise', _prayerTimes!.sunrise, Colors.orange, isOptional: true),
      _buildPrayerItem('Dhuhr', _prayerTimes!.dhuhr, ImanFlowTheme.dhuhrColor),
      _buildPrayerItem('Asr', _prayerTimes!.asr, ImanFlowTheme.asrColor),
      _buildPrayerItem('Maghrib', _prayerTimes!.maghrib, ImanFlowTheme.maghribColor),
      _buildPrayerItem('Isha', _prayerTimes!.isha, ImanFlowTheme.ishaColor),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Next Prayer Countdown
          _buildNextPrayerCard(),
          const SizedBox(height: 16),
          // All Prayer Times
          ...prayers,
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
          Text(
            'Next Prayer',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(hours.toString().padLeft(2, '0'), 'HRS'),
              const SizedBox(width: 8),
              Text(':', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 24)),
              const SizedBox(width: 8),
              _buildTimeUnit(minutes, 'MIN'),
              const SizedBox(width: 8),
              Text(':', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 24)),
              const SizedBox(width: 8),
              _buildTimeUnit(seconds, 'SEC'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerItem(String name, DateTime time, Color color, {bool isOptional = false}) {
    final isPassed = time.isBefore(DateTime.now());
    final isCompleted = _completedPrayers.contains(name);
    final isNext = _prayerService.getPrayerName(_prayerTimes!.nextPrayer()) == name;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isNext
            ? Border.all(color: color, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getPrayerIcon(name),
            color: color,
          ),
        ),
        title: Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isPassed && !isCompleted
                    ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)
                    : null,
              ),
            ),
            if (isNext)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          _prayerService.formatPrayerTime(time),
          style: TextStyle(
            color: isPassed && !isCompleted ? Colors.grey : color,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isOptional
            ? null
            : IconButton(
                onPressed: isCompleted
                    ? null
                    : () => _markPrayerComplete(name),
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: isCompleted ? ImanFlowTheme.success : Colors.grey,
                ),
              ),
      ),
    );
  }

  IconData _getPrayerIcon(String name) {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.cloud;
      case 'Maghrib':
        return Icons.nights_stay_outlined;
      case 'Isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }
}
