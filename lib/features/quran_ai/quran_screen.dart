import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/quran_service.dart';
import 'widgets/surah_list.dart';
import 'widgets/verse_reader.dart';

/// Quran Screen - Full Quran reader with search and AI integration
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranService _quranService = getIt<QuranService>();
  final TextEditingController _searchController = TextEditingController();
  
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedSurahId;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    try {
      final surahs = await _quranService.getSurahs();
      if (mounted) {
        setState(() {
          _surahs = surahs;
          _filteredSurahs = surahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = _surahs;
      } else {
        _filteredSurahs = _surahs.where((surah) {
          return surah.nameSimple.toLowerCase().contains(query.toLowerCase()) ||
              surah.nameArabic.contains(query) ||
              surah.nameTranslated.toLowerCase().contains(query.toLowerCase()) ||
              surah.id.toString() == query;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopBar(title: "Quran Reader", subtitle: "Read & Understand"),
          const SizedBox(height: 14),

          // Search
          Glass(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSurahs,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Surah...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                icon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                filled: false,
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(onPressed: () { _searchController.clear(); _filterSurahs(''); }, icon: const Icon(Icons.clear, color: Colors.white70))
                  : null,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quick Actions Row
          Row(
            children: [
              Expanded(child: _quickBtn("Random Verse", Icons.shuffle, () async {
                 final verse = await _quranService.getRandomVerse();
                 if (mounted) _showVerseDialog(verse);
              })),
              const SizedBox(width: 8),
              Expanded(child: _quickBtn("Ask AI", Icons.auto_awesome, () => context.push('/ai-chat'))),
            ],
          ),
          const SizedBox(height: 18),

          Text("All Surahs (${_filteredSurahs.length})", 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: ImanFlowTheme.gold))
          else if (_error != null)
            Center(child: Text("Error loading Surahs", style: TextStyle(color: Colors.red[300])))
          else
            _buildSurahList(),
        ],
      ),
    );
  }

  Widget _quickBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Glass(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(icon, size: 18, color: ImanFlowTheme.gold),
             const SizedBox(width: 8),
             Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = _filteredSurahs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
               setState(() => _selectedSurahId = surah.id);
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => VerseReader(surah: surah)),
               );
            },
            child: Glass(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                   Container(
                     width: 36, height: 36,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: ImanFlowTheme.gold.withOpacity(0.1),
                       border: Border.all(color: ImanFlowTheme.gold.withOpacity(0.3)),
                     ),
                     child: Center(child: Text("${surah.id}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: ImanFlowTheme.gold))),
                   ),
                   const SizedBox(width: 14),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                        Text(surah.nameSimple, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                        Text("${surah.versesCount} verses", style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                     ],
                   ),
                   const Spacer(),
                   Text(surah.nameArabic, style: ArabicTextStyles.quranVerse(fontSize: 20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showVerseDialog(Verse verse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ImanFlowTheme.bgMid,
        title: const Text('Verse of the Day', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              verse.textArabic,
              style: ArabicTextStyles.quranVerse(fontSize: 24, height: 2),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            Text(
              verse.translation ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              verse.verseKey,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/ai-chat');
            },
            style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Ask AI'),
          ),
        ],
      ),
    );
  }
}
