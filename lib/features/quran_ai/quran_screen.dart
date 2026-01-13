import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
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
      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Quran'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            ImanFlowTheme.primaryGreenDark,
                            ImanFlowTheme.primaryGreen,
                          ]
                        : [
                            ImanFlowTheme.primaryGreen,
                            ImanFlowTheme.accentTurquoise,
                          ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Icon(
                        Icons.menu_book,
                        size: 40,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: 'Amiri',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.push('/ai-chat'),
                icon: const Icon(Icons.auto_awesome),
                tooltip: 'Ask AI about Quran',
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSurahs,
                decoration: InputDecoration(
                  hintText: 'Search Surah by name or number...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _filterSurahs('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      'Random Verse',
                      Icons.shuffle,
                      () async {
                        final verse = await _quranService.getRandomVerse();
                        if (mounted) {
                          _showVerseDialog(verse);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      'Continue Reading',
                      Icons.bookmark,
                      () {
                        // Load last read position
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      'Ask AI',
                      Icons.auto_awesome,
                      () => context.push('/ai-chat'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Surah List Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'All Surahs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text(
                    '${_filteredSurahs.length} of 114',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Surah List
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Failed to load Quran'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadSurahs,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final surah = _filteredSurahs[index];
                  return _buildSurahTile(surah);
                },
                childCount: _filteredSurahs.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ImanFlowTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: ImanFlowTheme.primaryGreen),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: ImanFlowTheme.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahTile(Surah surah) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ImanFlowTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${surah.id}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ImanFlowTheme.primaryGreen,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              surah.nameSimple,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              surah.nameArabic,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(surah.nameTranslated),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: surah.revelationPlace == 'makkah'
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                surah.revelationPlace == 'makkah' ? 'Makki' : 'Madani',
                style: TextStyle(
                  fontSize: 10,
                  color: surah.revelationPlace == 'makkah'
                      ? Colors.orange
                      : Colors.blue,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${surah.versesCount} verses',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: () {
          // Navigate to verse reader
          setState(() => _selectedSurahId = surah.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerseReader(surah: surah),
            ),
          );
        },
      ),
    );
  }

  void _showVerseDialog(Verse verse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verse of the Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              verse.textArabic,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                height: 2,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            Text(
              verse.translation ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              verse.verseKey,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/ai-chat');
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Ask AI'),
          ),
        ],
      ),
    );
  }
}
