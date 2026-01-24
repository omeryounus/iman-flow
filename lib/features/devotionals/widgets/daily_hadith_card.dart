import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

/// Daily Hadith Card Widget
class DailyHadithCard extends StatefulWidget {
  final VoidCallback? onRefresh;

  const DailyHadithCard({super.key, this.onRefresh});

  @override
  State<DailyHadithCard> createState() => _DailyHadithCardState();
}

class _DailyHadithCardState extends State<DailyHadithCard> {
  int _currentIndex = 0;

  // Sample Hadith collection
  final List<HadithModel> _hadiths = [
    HadithModel(
      text: 'The Prophet (ﷺ) said, "The best among you are those who have the best manners and character."',
      arabic: 'خَيْرُكُمْ أَحْسَنُكُمْ خُلُقًا',
      source: 'Sahih al-Bukhari 6029',
      narrator: 'Narrated by Abdullah ibn Amr',
      category: 'Character',
    ),
    HadithModel(
      text: 'The Prophet (ﷺ) said, "None of you truly believes until he loves for his brother what he loves for himself."',
      arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      source: 'Sahih al-Bukhari 13, Sahih Muslim 45',
      narrator: 'Narrated by Anas ibn Malik',
      category: 'Faith',
    ),
    HadithModel(
      text: 'The Prophet (ﷺ) said, "Whoever believes in Allah and the Last Day should speak good or remain silent."',
      arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      source: 'Sahih al-Bukhari 6018, Sahih Muslim 47',
      narrator: 'Narrated by Abu Hurairah',
      category: 'Speech',
    ),
    HadithModel(
      text: 'The Prophet (ﷺ) said, "The strong person is not the one who can overpower others, but the one who controls himself when angry."',
      arabic: 'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الْغَضَبِ',
      source: 'Sahih al-Bukhari 6114',
      narrator: 'Narrated by Abu Hurairah',
      category: 'Self-Control',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _hadiths.length) _currentIndex = 0;
    final hadith = _hadiths[_currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Hadith Card
          Glass(
            radius: 20,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ImanFlowTheme.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, color: ImanFlowTheme.gold, size: 14),
                            const SizedBox(width: 6),
                            Text(hadith.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text('${_currentIndex + 1}/${_hadiths.length}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
                ),

                // Arabic Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    hadith.arabic,
                    style: ArabicTextStyles.quranVerse(fontSize: 22, color: Colors.white, height: 1.8),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // English Translation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    hadith.text,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // Source
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
                  child: Column(
                    children: [
                      Text(hadith.source, style: const TextStyle(color: ImanFlowTheme.gold, fontWeight: FontWeight.bold)),
                      Text(hadith.narrator, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Navigation & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null, icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded, color: Colors.white)),
              IconButton(onPressed: _currentIndex < _hadiths.length - 1 ? () => setState(() => _currentIndex++) : null, icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 24),

          // Reflection Section
          const Text('📝 Today\'s Reflection', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Glass(
            radius: 12,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getReflection(hadith.category), style: const TextStyle(color: Colors.white70, height: 1.6)),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: ImanFlowTheme.gold),
                    SizedBox(width: 4),
                    Text('Action point', style: TextStyle(color: ImanFlowTheme.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_getActionPoint(hadith.category), style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReflection(String category) {
    // simplified for brevity
    return 'Take a moment to ponder this hadith and how it applies to your life.';
  }

  String _getActionPoint(String category) {
    return 'Apply this teaching in at least one interaction today.';
  }
}

class HadithModel {
  final String text;
  final String arabic;
  final String source;
  final String narrator;
  final String category;

  HadithModel({
    required this.text,
    required this.arabic,
    required this.source,
    required this.narrator,
    required this.category,
  });
}
