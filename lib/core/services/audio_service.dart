import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/dua_audio.dart';

/// Audio Service for Duas, Quran recitations, and meditation
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _audioCollection => _firestore.collection('audio_content');

  /// Stream of audio content from Firestore by category
  Stream<List<DuaAudio>> getAudioStream(String category) {
    return _audioCollection
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => DuaAudio.fromFirestore(doc)).toList();
        });
  }
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
    await _player.play();
  }

  /// Play audio from bytes (e.g. from Amazon Polly)
  Future<void> playBytes(Uint8List bytes) async {
    try {
      await _player.setAudioSource(MyCustomSource(bytes));
      await _player.play();
    } catch (e) {
      print("AudioService: Error playing bytes: $e");
    }
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

class MyCustomSource extends StreamAudioSource {
  final Uint8List bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
