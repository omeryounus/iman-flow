import 'package:get_it/get_it.dart';
import 'prayer_service.dart';
import 'ai_service.dart';
import 'quran_service.dart';
import 'audio_service.dart';
import 'notification_service.dart';
import 'streak_service.dart';
import 'premium_service.dart';
import 'settings_service.dart';
import 'daily_content_service.dart';
import '../../features/profile/services/user_service.dart';

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
  getIt.registerLazySingleton<DailyContentService>(() => DailyContentService());
  getIt.registerLazySingleton<UserService>(() => UserService());
  
  // Initialize services that need async setup
  await getIt<SettingsService>().initialize();
  await getIt<NotificationService>().initialize();
  await getIt<PremiumService>().initialize();
  
  // Configure AI Service
  // Pass keys via --dart-define=AWS_ACCESS_KEY=... or --dart-define=BEDROCK_API_KEY=...
  getIt<AIService>().configure(
    accessKeyId: const String.fromEnvironment('AWS_ACCESS_KEY', defaultValue: ''),
    secretAccessKey: const String.fromEnvironment('AWS_SECRET_KEY', defaultValue: ''),
    apiKey: const String.fromEnvironment('BEDROCK_API_KEY', defaultValue: ''),
    region: const String.fromEnvironment('AWS_REGION', defaultValue: 'us-east-1'),
  );
}
