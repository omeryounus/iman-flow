import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:adhan/adhan.dart'; // Correct import placement
import 'package:iman_flow/app/app.dart';
import 'package:iman_flow/core/services/settings_service.dart';
import 'package:iman_flow/core/services/prayer_service.dart';
import 'package:iman_flow/core/services/premium_service.dart';
import 'package:iman_flow/core/services/streak_service.dart';
import 'package:iman_flow/core/services/daily_content_service.dart';
import 'package:iman_flow/core/services/notification_service.dart';
import 'package:iman_flow/core/services/ai_service.dart';
import 'package:iman_flow/core/services/audio_service.dart';
import 'package:iman_flow/core/services/quran_service.dart';
import 'package:iman_flow/features/profile/services/user_service.dart';
import 'package:iman_flow/features/profile/models/user_profile.dart'; 

// --- Mocks ---

class FakeSettingsService extends Fake implements SettingsService {
  @override
  Stream<UserSettings> get settingsStream => Stream.value(const UserSettings());
  
  @override
  UserSettings get settings => const UserSettings();
  
  @override
  Future<void> initialize() async {}
}

class FakePremiumService extends Fake implements PremiumService {
  @override
  Stream<bool> get isPremiumStream => Stream.value(false);
  
  @override
  bool get isPremium => false;
  
  @override
  Future<void> initialize() async {}
}

class FakePrayerService extends Fake implements PrayerService {
  @override
  Future<PrayerTimes> getPrayerTimes({DateTime? date, String methodName = 'Muslim World League'}) async {
    final coords = Coordinates(21.4225, 39.8262); // Mecca
    final params = CalculationMethod.muslim_world_league.getParameters();
    final d = date ?? DateTime.now();
    final dateComponents = DateComponents(d.year, d.month, d.day);
    return PrayerTimes(coords, dateComponents, params);
  }
  
  @override
  String formatPrayerTime(DateTime time) => "12:00 PM";
  
  @override
  String getPrayerName(dynamic p) => "Fajr";
}

class FakeStreakService extends Fake implements StreakService {
  @override
  Future<StreakData> getAllStreaks() async => StreakData(prayerStreak: 0, quranStreak: 0, dhikrStreak: 0);
  
  @override
  Future<void> syncWithRemote(int p, int q, int d) async {}
}

class FakeDailyContentService extends Fake implements DailyContentService {
  @override
  Future<Verse> getDailyVerse() async {
    return Verse(
      verseKey: '1:1',
      textArabic: 'بسم الله الرحمن الرحيم',
      translation: 'In the name of Allah',
      verseNumber: 1,
      surahNumber: 1,
    );
  }
}

class FakeUserService extends Fake implements UserService {
  @override
  Stream<UserProfile?> get currentUserProfileStream => Stream.value(null);
}

class FakeNotificationService extends Fake implements NotificationService {
  @override
  Future<void> initialize() async {}
}

// Minimal fakes for others to prevent GetIt crashes if they are accessed
class FakeAIService extends Fake implements AIService {
  @override
  void configure({String? accessKeyId, String? secretAccessKey, String? apiKey, required String region}) {}
}
class FakeAudioService extends Fake implements AudioService {}
class FakeQuranService extends Fake implements QuranService {}


void main() {
  setUp(() {
    GetIt.I.reset();
    
    // Register all mocks used by App/Home
    GetIt.I.registerSingleton<SettingsService>(FakeSettingsService());
    GetIt.I.registerSingleton<PremiumService>(FakePremiumService());
    GetIt.I.registerSingleton<PrayerService>(FakePrayerService());
    GetIt.I.registerSingleton<StreakService>(FakeStreakService());
    GetIt.I.registerSingleton<DailyContentService>(FakeDailyContentService());
    GetIt.I.registerSingleton<UserService>(FakeUserService());
    GetIt.I.registerSingleton<NotificationService>(FakeNotificationService());
    GetIt.I.registerSingleton<AIService>(FakeAIService());
    GetIt.I.registerSingleton<AudioService>(FakeAudioService());
    GetIt.I.registerSingleton<QuranService>(FakeQuranService());
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Set surface size to ensure responsive layout builds
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(const ImanFlowApp());
    // Use pump instead of pumpAndSettle because PremiumBackground has infinite animation loop
    await tester.pump(const Duration(seconds: 2)); 
    
    expect(find.byType(ImanFlowApp), findsOneWidget);
    // Should find HomeScreen if navigation works
    expect(find.text('Prayer Times'), findsOneWidget); 
  });
}
