import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/models/dua_audio.dart';

class DhikrPlayer extends StatefulWidget {
  final DuaAudio dua;

  const DhikrPlayer({super.key, required this.dua});

  @override
  State<DhikrPlayer> createState() => _DhikrPlayerState();
}

class _DhikrPlayerState extends State<DhikrPlayer> {
  final AudioService _audioService = getIt<AudioService>();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Start playing automatically when opened
    _initAudio();
  }

  Future<void> _initAudio() async {
    // Basic connectivity check done in AudioService (try/catch)
    await _audioService.playAsset(widget.dua.audioUrl);
    if (mounted) setState(() => _isPlaying = _audioService.isPlaying);
  }

  void _togglePlay() {
    if (_isPlaying) {
      _audioService.pause();
    } else {
      _audioService.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ImanFlowTheme.gold.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: ImanFlowTheme.gold.withOpacity(0.15),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      ),
                      const Text(
                        'Dhikr Player',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {}, // Settings placeholder
                        icon: const Icon(Icons.tune_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Main Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        widget.dua.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle
                      Text(
                        'Calm Mode • ${_formatDuration(widget.dua.duration)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Play/Pause Button
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ImanFlowTheme.gold.withOpacity(0.3),
                                ImanFlowTheme.gold.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: ImanFlowTheme.gold.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ImanFlowTheme.gold.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Arabic Card
                      Glass(
                        radius: 24,
                        padding: const EdgeInsets.all(24),
                        color: Colors.white.withOpacity(0.05),
                        child: Column(
                          children: [
                            Text(
                              'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
                              textAlign: TextAlign.center,
                              style: ArabicTextStyles.quranVerse(
                                fontSize: 30,
                                height: 1.8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Surely in the remembrance of Allah do hearts find rest.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
