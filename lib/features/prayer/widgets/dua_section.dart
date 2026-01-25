import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/models/dua_audio.dart';

/// Dua Section Widget - Guided Duas for morning, evening, sleep
class DuaSection extends StatefulWidget {
  const DuaSection({super.key});

  @override
  State<DuaSection> createState() => _DuaSectionState();
}

class _DuaSectionState extends State<DuaSection> {
  final AudioService _audioService = getIt<AudioService>();
  String _selectedCategory = 'morning';
  String? _playingDuaId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Selector
          _buildCategorySelector(),
          
          const SizedBox(height: 24),
          
          // Featured Dua
          _buildFeaturedDua(),
          
          const SizedBox(height: 24),
          
          // Dua List
          Text(
            _getCategoryTitle(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          
          StreamBuilder<List<DuaAudio>>(
            stream: _audioService.getAudioStream(_selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: ImanFlowTheme.gold),
                ));
              }

              final duas = snapshot.data ?? [];
              if (duas.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text('No content available for this category yet.', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                  ),
                );
              }

              return Column(
                children: duas.map((dua) => _buildDuaCard(dua)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip('morning', 'Morning', Icons.wb_twilight_rounded),
          const SizedBox(width: 8),
          _buildCategoryChip('evening', 'Evening', Icons.nights_stay_rounded),
          const SizedBox(width: 8),
          _buildCategoryChip('sleep', 'Sleep', Icons.bedtime_rounded),
          const SizedBox(width: 8),
          _buildCategoryChip('general', 'General', Icons.auto_awesome_rounded),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ImanFlowTheme.gold : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ImanFlowTheme.gold : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedDua() {
    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ImanFlowTheme.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: ImanFlowTheme.gold,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ayatul Kursi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'آية الكرسي',
                    style: ArabicTextStyles.quranVerse(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'The greatest verse in the Quran. Recite it after every prayer for protection.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Play Ayatul Kursi
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ImanFlowTheme.gold,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Listen'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  // Bookmark
                },
                icon: const Icon(Icons.bookmark_border),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCategoryTitle() {
    switch (_selectedCategory) {
      case 'morning': return '🌅 Morning Adhkar';
      case 'evening': return '🌙 Evening Adhkar';
      case 'sleep': return '😴 Before Sleep';
      case 'general': return '✨ Daily Duas';
      default: return 'Duas';
    }
  }

  Widget _buildDuaCard(DuaAudio dua) {
    final isPlaying = _playingDuaId == dua.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: ImanFlowTheme.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: ImanFlowTheme.gold,
                size: 30,
              ),
              if (dua.isPremium)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    Icons.star,
                    size: 10,
                    color: ImanFlowTheme.gold,
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          dua.name,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dua.nameArabic.isNotEmpty)
              Text(
                dua.nameArabic,
                style: ArabicTextStyles.quranVerse(fontSize: 14),
              ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(dua.duration),
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () async {
            if (isPlaying) {
              await _audioService.pause();
              setState(() => _playingDuaId = null);
            } else {
              if (dua.isPremium) {
                _showPremiumDialog();
              } else {
                // If it's a URL, use playUrl. If it's an asset path, use playAsset.
                // Assuming newly created ones are URLs. 
                if (dua.audioUrl.startsWith('http')) {
                  await _audioService.playUrl(dua.audioUrl);
                } else {
                  await _audioService.playAsset(dua.audioUrl);
                }
                setState(() => _playingDuaId = dua.id);
              }
            }
          },
          icon: Icon(
            isPlaying ? Icons.stop_circle_outlined : Icons.headphones,
            color: ImanFlowTheme.gold,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ImanFlowTheme.bgMid,
        title: const Row(
          children: [
            Icon(Icons.star, color: ImanFlowTheme.gold),
            SizedBox(width: 8),
            Text('Premium Content', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This audio is available with Iman Flow Premium. Unlock ad-free experience, offline audio, and more!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
            child: const Text('Go Premium'),
          ),
        ],
      ),
    );
  }
}
