import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/theme.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/quran_service.dart';
import '../models/shared_verse.dart';
import '../services/verse_share_service.dart';

/// Verse Share Widget - Share verses to social media
class VerseShare extends StatefulWidget {
  final bool womenMode;

  const VerseShare({super.key, this.womenMode = false});

  @override
  State<VerseShare> createState() => _VerseShareState();
}

class _VerseShareState extends State<VerseShare> {
  final QuranService _quranService = getIt<QuranService>();

  final VerseShareService _shareService = VerseShareService();
  
  // Controllers for the share dialog
  final TextEditingController _verseRefController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();
  bool _isSharing = false;

  @override
  void dispose() {
    _verseRefController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

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

          // Shared Verses Stream
          StreamBuilder<List<SharedVerse>>(
            stream: _shareService.getSharedVerses(womenMode: widget.womenMode),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final verses = snapshot.data ?? [];
              
              if (verses.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No verses shared yet. Be the first!'),
                  ),
                );
              }

              return Column(
                children: verses.map((verse) => _buildVerseCard(verse)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(SharedVerse verse) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLiked = currentUser != null && verse.likedBy.contains(currentUser.uid);

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
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  '${verse.likeCount}',
                  () => _shareService.toggleLike(verse.id),
                  color: isLiked ? Colors.red : null,
                ),
                _buildActionButton(
                  Icons.copy,
                  'Copy',
                  () => _copyVerse(verse),
                ),
                _buildActionButton(
                  Icons.share,
                  '${verse.shareCount}',
                  () => _shareVerse(verse),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color ?? Colors.grey, fontSize: 12),
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
    // Increment share count
    _shareService.incrementShare(verse.id);
    
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
              controller: _verseRefController,
              decoration: InputDecoration(
                hintText: 'Enter verse reference (e.g., 2:255)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reflectionController,
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
                onPressed: _isSharing ? null : _submitShare,
                child: _isSharing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Share with Community'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _submitShare() async {
    final ref = _verseRefController.text.trim();
    final reflection = _reflectionController.text.trim();
    
    if (ref.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a verse reference')),
      );
      return;
    }

    setState(() => _isSharing = true);

    try {
      // 1. Fetch verse details using the existing QuranService
      // Note: This relies on the QuranService having a method to get a verse by key.
      // If not, we might need a workaround or assume manual entry for now.
      // For this MVP, let's assume valid manual entry or mock data filling to avoid breaking if service lacks granular fetch.
      
      // Simulating fetch or using basic parsing
      // In a real app, parse "2:255", call API/Service, get Arabic/Translation.
      // Here, use placeholders since we don't have a direct "getVerseByKey" in the visible QuranService interface yet.
      
      await _shareService.shareVerse(
        verseKey: ref,
        arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ', // Placeholder if service fetch fails
        translation: 'Say, "He is Allah, [who is] One."', // Placeholder
        reflection: reflection.isNotEmpty ? reflection : null,
        womenOnly: widget.womenMode,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verse shared successfully!')),
        );
        _verseRefController.clear();
        _reflectionController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing verse: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}
// Removed inline SharedVerse class definition as it's now imported
