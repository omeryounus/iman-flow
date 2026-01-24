import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Audio Service for Duas, Quran recitations, and meditation
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  
  bool get isPlaying => _player.playing;
  Duration? get duration => _player.duration;
  Duration get position => _player.position;
  
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Play audio from URL
  Future<void> playUrl(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  /// Play audio from local asset
  Future<void> playAsset(String assetPath) async {
    try {
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (e) {
      print("AudioService: Error playing asset $assetPath: $e");
      // Optionally notify user via a stream or service if needed
    }
  }

  /// Play cached audio (downloads if not cached)
  Future<void> playCached(String url, String cacheKey) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final cacheFile = File('${cacheDir.path}/audio_cache/$cacheKey.mp3');
    
    if (await cacheFile.exists()) {
      await _player.setFilePath(cacheFile.path);
    } else {
      // Download and cache for offline use
      await _player.setUrl(url);
      // Note: Actual download/caching would need additional implementation
    }
    await _player.play();
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.play();
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Set playback speed (for studying)
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Set loop mode
  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  /// Dispose player
  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Dua audio collection
class DuaAudio {
  final String id;
  final String name;
  final String nameArabic;
  final String category; // morning, evening, sleep, general
  final String audioUrl;
  final Duration duration;
  final bool isPremium;

  DuaAudio({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.category,
    required this.audioUrl,
    required this.duration,
    this.isPremium = false,
  });

  /// Sample Duas for MVP
  static List<DuaAudio> get morningDuas => [
    DuaAudio(
      id: 'morning_1',
      name: 'Morning Adhkar',
      nameArabic: 'أذكار الصباح',
      category: 'morning',
      audioUrl: 'assets/audio/morning_adhkar.mp3',
      duration: const Duration(minutes: 5),
    ),
    DuaAudio(
      id: 'morning_2',
      name: 'Ayatul Kursi',
      nameArabic: 'آية الكرسي',
      category: 'morning',
      audioUrl: 'assets/audio/ayatul_kursi.mp3',
      duration: const Duration(minutes: 2),
    ),
  ];

  static List<DuaAudio> get eveningDuas => [
    DuaAudio(
      id: 'evening_1',
      name: 'Evening Adhkar',
      nameArabic: 'أذكار المساء',
      category: 'evening',
      audioUrl: 'assets/audio/evening_adhkar.mp3',
      duration: const Duration(minutes: 5),
    ),
  ];

  static List<DuaAudio> get sleepDuas => [
    DuaAudio(
      id: 'sleep_1',
      name: 'Surah Al-Mulk',
      nameArabic: 'سورة الملك',
      category: 'sleep',
      audioUrl: 'assets/audio/surah_mulk.mp3',
      duration: const Duration(minutes: 8),
      isPremium: true,
    ),
    DuaAudio(
      id: 'sleep_2',
      name: 'Sleep Dua',
      nameArabic: 'دعاء النوم',
      category: 'sleep',
      audioUrl: 'assets/audio/sleep_dua.mp3',
      duration: const Duration(minutes: 1),
    ),
  ];
}
