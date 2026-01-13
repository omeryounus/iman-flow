import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Daily Hadith Card Widget
class DailyHadithCard extends StatefulWidget {
  final VoidCallback? onRefresh;

  const DailyHadithCard({super.key, this.onRefresh});

  @override
  State<DailyHadithCard> createState() => _DailyHadithCardState();
}

class _DailyHadithCardState extends State<DailyHadithCard> {
  int _currentIndex = 0;

  // Sample Hadith collection (would come from API/database in production)
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
    HadithModel(
      text: 'The Prophet (ﷺ) said, "Make things easy and do not make them difficult. Give glad tidings and do not repel people."',
      arabic: 'يَسِّرُوا وَلَا تُعَسِّرُوا، وَبَشِّرُوا وَلَا تُنَفِّرُوا',
      source: 'Sahih al-Bukhari 69',
      narrator: 'Narrated by Anas ibn Malik',
      category: 'Kindness',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hadith = _hadiths[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Hadith Card
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hadith.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_currentIndex + 1}/${_hadiths.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    hadith.arabic,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // English Translation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    hadith.text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                // Source
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        hadith.source,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        hadith.narrator,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
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
              IconButton(
                onPressed: _currentIndex > 0
                    ? () => setState(() => _currentIndex--)
                    : null,
                icon: const Icon(Icons.arrow_back_ios),
              ),
              IconButton(
                onPressed: () {
                  // Bookmark hadith
                },
                icon: const Icon(Icons.bookmark_border),
              ),
              IconButton(
                onPressed: () {
                  // Share hadith
                },
                icon: const Icon(Icons.share),
              ),
              IconButton(
                onPressed: _currentIndex < _hadiths.length - 1
                    ? () => setState(() => _currentIndex++)
                    : null,
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Reflection Section
          Text(
            '📝 Today\'s Reflection',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ImanFlowTheme.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getReflection(hadith.category),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Action point',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getActionPoint(hadith.category),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getReflection(String category) {
    switch (category) {
      case 'Character':
        return 'Good character is the heaviest thing on the scales of a believer on the Day of Judgment. Reflect on how you can improve your interactions with others today.';
      case 'Faith':
        return 'True faith extends beyond ritual worship - it shapes how we treat others. Consider: do I genuinely wish for others what I wish for myself?';
      case 'Speech':
        return 'Our words have power. Before speaking, ask: Is it true? Is it beneficial? Is it necessary? Is this the right time?';
      case 'Self-Control':
        return 'Real strength lies in mastering our emotions. When anger rises, pause, seek refuge in Allah, and respond with wisdom.';
      case 'Kindness':
        return 'Islam teaches ease, not hardship. How can you make someone\'s day easier? How can you share good news and hope?';
      default:
        return 'Take a moment to ponder this hadith and how it applies to your life.';
    }
  }

  String _getActionPoint(String category) {
    switch (category) {
      case 'Character':
        return 'Smile at someone today. The Prophet ﷺ said smiling is charity.';
      case 'Faith':
        return 'Do something kind for a Muslim brother or sister today.';
      case 'Speech':
        return 'Before speaking, pause and think if your words will benefit.';
      case 'Self-Control':
        return 'When upset today, make wudu and pray 2 rakats.';
      case 'Kindness':
        return 'Help someone with a task they find difficult.';
      default:
        return 'Apply this teaching in at least one interaction today.';
    }
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
