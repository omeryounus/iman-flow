import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/audio_service.dart';

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
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          
          ..._getDuasForCategory().map((dua) => _buildDuaCard(dua)),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip('morning', 'Morning', Icons.wb_twilight),
          const SizedBox(width: 8),
          _buildCategoryChip('evening', 'Evening', Icons.nights_stay_outlined),
          const SizedBox(width: 8),
          _buildCategoryChip('sleep', 'Sleep', Icons.bedtime_outlined),
          const SizedBox(width: 8),
          _buildCategoryChip('general', 'General', Icons.auto_awesome),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : ImanFlowTheme.primaryGreen,
      ),
      label: Text(label),
      backgroundColor: Colors.transparent,
      selectedColor: ImanFlowTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
      ),
      side: BorderSide(
        color: isSelected ? ImanFlowTheme.primaryGreen : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildFeaturedDua() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ayatul Kursi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'آية الكرسي',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Amiri',
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
                    backgroundColor: Colors.white,
                    foregroundColor: ImanFlowTheme.primaryGreen,
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
      case 'morning':
        return '🌅 Morning Adhkar';
      case 'evening':
        return '🌙 Evening Adhkar';
      case 'sleep':
        return '😴 Before Sleep';
      case 'general':
        return '✨ Daily Duas';
      default:
        return 'Duas';
    }
  }

  List<DuaAudio> _getDuasForCategory() {
    switch (_selectedCategory) {
      case 'morning':
        return DuaAudio.morningDuas;
      case 'evening':
        return DuaAudio.eveningDuas;
      case 'sleep':
        return DuaAudio.sleepDuas;
      default:
        return [...DuaAudio.morningDuas, ...DuaAudio.eveningDuas];
    }
  }

  Widget _buildDuaCard(DuaAudio dua) {
    final isPlaying = _playingDuaId == dua.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: ImanFlowTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: ImanFlowTheme.primaryGreen,
                size: 32,
              ),
              if (dua.isPremium)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: ImanFlowTheme.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          dua.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dua.nameArabic,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(dua.duration),
              style: Theme.of(context).textTheme.bodySmall,
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
                // Show premium dialog
                _showPremiumDialog();
              } else {
                await _audioService.playAsset(dua.audioUrl);
                setState(() => _playingDuaId = dua.id);
              }
            }
          },
          icon: Icon(
            isPlaying ? Icons.stop_circle_outlined : Icons.headphones,
            color: ImanFlowTheme.primaryGreen,
          ),
        ),
        onTap: () {
          // Open dua details
        },
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
        title: Row(
          children: [
            Icon(Icons.star, color: ImanFlowTheme.accentGold),
            const SizedBox(width: 8),
            const Text('Premium Content'),
          ],
        ),
        content: const Text(
          'This audio is available with Iman Flow Premium. Unlock ad-free experience, offline audio, and more!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to premium screen
            },
            child: const Text('Go Premium'),
          ),
        ],
      ),
    );
  }
}
