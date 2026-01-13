import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/quran_service.dart';

/// Verse Share Widget - Share verses to social media
class VerseShare extends StatefulWidget {
  final bool womenMode;

  const VerseShare({super.key, this.womenMode = false});

  @override
  State<VerseShare> createState() => _VerseShareState();
}

class _VerseShareState extends State<VerseShare> {
  final QuranService _quranService = getIt<QuranService>();

  // Sample shared verses (would come from Firestore in production)
  final List<SharedVerse> _sharedVerses = [
    SharedVerse(
      id: '1',
      verseKey: '2:286',
      arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
      translation: 'Allah does not burden a soul beyond that it can bear.',
      sharedBy: 'Anonymous',
      shareCount: 234,
      reflection: 'A reminder during difficult times that we can handle what comes our way.',
    ),
    SharedVerse(
      id: '2',
      verseKey: '94:5-6',
      arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      translation: 'Indeed, with hardship comes ease. Indeed, with hardship comes ease.',
      sharedBy: 'Sister Aisha',
      shareCount: 456,
      reflection: 'Repeated for emphasis - ease will come!',
    ),
    SharedVerse(
      id: '3',
      verseKey: '13:28',
      arabicText: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      translation: 'Verily, in the remembrance of Allah do hearts find rest.',
      sharedBy: 'Brother Omar',
      shareCount: 678,
      reflection: 'The solution to anxiety is always with Allah.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final versesToShow = widget.womenMode
        ? _sharedVerses // In production, filter for women-focused verses
        : _sharedVerses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create New Share
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ImanFlowTheme.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote,
                  color: ImanFlowTheme.primaryGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Share a verse that inspired you...',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showShareDialog(),
                  child: const Text('Share'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (widget.womenMode) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.female, color: Colors.pink),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Viewing women-focused content and stories of female scholars',
                      style: TextStyle(
                        color: Colors.pink.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            widget.womenMode ? 'Sisters\' Reflections' : 'Community Reflections',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Shared Verses
          ...versesToShow.map((verse) => _buildVerseCard(verse)),
        ],
      ),
    );
  }

  Widget _buildVerseCard(SharedVerse verse) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse Reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ImanFlowTheme.primaryGreen.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ImanFlowTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    verse.verseKey,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Shared by ${verse.sharedBy}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Arabic Text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              verse.arabicText,
              style: ArabicTextStyles.quranVerse(
                fontSize: 22,
                height: 2,
                color: isDark ? Colors.white : ImanFlowTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Translation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              verse.translation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (verse.reflection != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ImanFlowTheme.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: ImanFlowTheme.accentGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        verse.reflection!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  Icons.favorite_border,
                  '${verse.shareCount}',
                  () {},
                ),
                _buildActionButton(
                  Icons.copy,
                  'Copy',
                  () => _copyVerse(verse),
                ),
                _buildActionButton(
                  Icons.share,
                  'Share',
                  () => _shareVerse(verse),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _copyVerse(SharedVerse verse) {
    final text = '${verse.arabicText}\n\n"${verse.translation}"\n\n- Quran ${verse.verseKey}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareVerse(SharedVerse verse) {
    // In production, use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening share dialog...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share a Verse',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter verse reference (e.g., 2:255)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add your reflection (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Share with Community'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SharedVerse {
  final String id;
  final String verseKey;
  final String arabicText;
  final String translation;
  final String sharedBy;
  final int shareCount;
  final String? reflection;

  SharedVerse({
    required this.id,
    required this.verseKey,
    required this.arabicText,
    required this.translation,
    required this.sharedBy,
    required this.shareCount,
    this.reflection,
  });
}
