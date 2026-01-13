import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

/// Prayer time calculation service using adhan_dart
class PrayerService {
  Position? _currentPosition;
  
  /// Available calculation methods
  static const Map<String, CalculationMethod> calculationMethods = {
    'Muslim World League': CalculationMethod.muslim_world_league,
    'Egyptian': CalculationMethod.egyptian,
    'Karachi': CalculationMethod.karachi,
    'Umm al-Qura': CalculationMethod.umm_al_qura,
    'Dubai': CalculationMethod.dubai,
    'Qatar': CalculationMethod.qatar,
    'Kuwait': CalculationMethod.kuwait,
    'Singapore': CalculationMethod.singapore,
    'North America (ISNA)': CalculationMethod.north_america,
  };

  /// Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return _currentPosition!;
  }

  /// Calculate prayer times for a specific date
  Future<PrayerTimes> getPrayerTimes({
    DateTime? date,
    String methodName = 'Muslim World League',
  }) async {
    final position = _currentPosition ?? await getCurrentLocation();
    final coordinates = Coordinates(position.latitude, position.longitude);
    
    final method = calculationMethods[methodName] ?? CalculationMethod.muslim_world_league;
    final params = method.getParameters();
    
    final targetDate = date ?? DateTime.now();
    final dateComponents = DateComponents(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    
    return PrayerTimes(coordinates, dateComponents, params);
  }

  /// Get the next prayer (handles case when all today's prayers passed)
  Future<Prayer> getNextPrayer() async {
    final prayerTimes = await getPrayerTimes();
    final next = prayerTimes.nextPrayer();
    // If none, next prayer is tomorrow's Fajr
    return next == Prayer.none ? Prayer.fajr : next;
  }

  /// Get time until next prayer in minutes
  Future<Duration> getTimeUntilNextPrayer() async {
    final prayerTimes = await getPrayerTimes();
    final nextPrayer = prayerTimes.nextPrayer();
    
    // If all prayers passed, get tomorrow's Fajr
    if (nextPrayer == Prayer.none) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowPrayers = await getPrayerTimes(date: tomorrow);
      return tomorrowPrayers.fajr.difference(DateTime.now());
    }
    
    final nextPrayerTime = prayerTimes.timeForPrayer(nextPrayer);
    if (nextPrayerTime == null) return Duration.zero;
    return nextPrayerTime.difference(DateTime.now());
  }

  /// Calculate Qibla direction from current location
  Future<double> getQiblaDirection() async {
    final position = _currentPosition ?? await getCurrentLocation();
    final coordinates = Coordinates(position.latitude, position.longitude);
    final qibla = Qibla(coordinates);
    return qibla.direction;
  }

  /// Get prayer name as string
  String getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      case Prayer.none:
        return 'Fajr'; // After Isha, next is Fajr
    }
  }

  /// Format prayer time
  String formatPrayerTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }
}

/// Prayer time model for UI
class PrayerTimeModel {
  final String name;
  final DateTime time;
  final bool isPassed;
  final bool isNext;

  PrayerTimeModel({
    required this.name,
    required this.time,
    required this.isPassed,
    required this.isNext,
  });
}
