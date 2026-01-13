import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/quran_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/streak_service.dart';

/// Verse Reader Widget - Read verses of a Surah
class VerseReader extends StatefulWidget {
  final Surah surah;

  const VerseReader({super.key, required this.surah});

  @override
  State<VerseReader> createState() => _VerseReaderState();
}

class _VerseReaderState extends State<VerseReader> {
  final QuranService _quranService = getIt<QuranService>();
  final AudioService _audioService = getIt<AudioService>();
  final StreakService _streakService = getIt<StreakService>();
  
  List<Verse> _verses = [];
  bool _isLoading = true;
  String? _error;
  int? _playingVerseIndex;
  bool _showTranslation = true;

  @override
  void initState() {
    super.initState();
    _loadVerses();
    _logQuranReading();
  }

  Future<void> _loadVerses() async {
    try {
      final verses = await _quranService.getVerses(widget.surah.id);
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logQuranReading() async {
    await _streakService.logQuranReading();
  }

  Future<void> _playVerse(int index) async {
    try {
      final verse = _verses[index];
      final audioUrl = await _quranService.getRecitationUrl(verse.verseKey);
      await _audioService.playUrl(audioUrl);
      setState(() => _playingVerseIndex = index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play audio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surah.nameSimple),
            Text(
              widget.surah.nameArabic,
              style: ArabicTextStyles.quranVerse(fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _showTranslation = !_showTranslation);
            },
            icon: Icon(
              _showTranslation ? Icons.translate : Icons.translate_outlined,
            ),
            tooltip: _showTranslation ? 'Hide Translation' : 'Show Translation',
          ),
          IconButton(
            onPressed: () {
              // Bookmark
            },
            icon: const Icon(Icons.bookmark_border),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Failed to load verses'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadVerses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Surah Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ImanFlowTheme.primaryGreen.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          if (widget.surah.id != 9) // Not At-Tawbah
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: ImanFlowTheme.accentGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                style: ArabicTextStyles.quranVerse(
                                  fontSize: 24,
                                  color: isDark
                                      ? ImanFlowTheme.accentGold
                                      : ImanFlowTheme.primaryGreenDark,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.surah.nameTranslated} · ${widget.surah.versesCount} Verses · ${widget.surah.revelationPlace == 'makkah' ? 'Makki' : 'Madani'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    
                    // Verses List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _verses.length,
                        itemBuilder: (context, index) {
                          final verse = _verses[index];
                          final isPlaying = _playingVerseIndex == index;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: isPlaying
                                  ? Border.all(
                                      color: ImanFlowTheme.primaryGreen,
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Verse Header
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ImanFlowTheme.primaryGreen.withOpacity(0.05),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: ImanFlowTheme.primaryGreen,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${verse.verseNumber}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () => _playVerse(index),
                                        icon: Icon(
                                          isPlaying
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_outline,
                                          color: ImanFlowTheme.primaryGreen,
                                        ),
                                        iconSize: 28,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Share verse
                                        },
                                        icon: const Icon(Icons.share_outlined),
                                        iconSize: 20,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          // Bookmark verse
                                        },
                                        icon: const Icon(Icons.bookmark_border),
                                        iconSize: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Arabic Text
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    verse.textArabic,
                                    style: ArabicTextStyles.quranVerse(
                                      fontSize: 26,
                                      height: 2.2,
                                      color: isDark
                                          ? Colors.white
                                          : ImanFlowTheme.textPrimaryLight,
                                    ),
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                
                                // Translation
                                if (_showTranslation && verse.translation != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.grey.withOpacity(0.05),
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      verse.translation!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
