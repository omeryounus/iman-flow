import 'package:get_it/get_it.dart';
import 'prayer_service.dart';
import 'ai_service.dart';
import 'quran_service.dart';
import 'audio_service.dart';
import 'notification_service.dart';
import 'streak_service.dart';
import 'premium_service.dart';
import 'settings_service.dart';

final getIt = GetIt.instance;

/// Setup all services for dependency injection
Future<void> setupServiceLocator() async {
  // Core services
  getIt.registerLazySingleton<PrayerService>(() => PrayerService());
  getIt.registerLazySingleton<QuranService>(() => QuranService());
  getIt.registerLazySingleton<AIService>(() => AIService());
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<StreakService>(() => StreakService());
  getIt.registerLazySingleton<PremiumService>(() => PremiumService());
  getIt.registerLazySingleton<SettingsService>(() => SettingsService());
  
  // Initialize services that need async setup
  await getIt<SettingsService>().initialize();
  await getIt<NotificationService>().initialize();
  await getIt<PremiumService>().initialize();
}
