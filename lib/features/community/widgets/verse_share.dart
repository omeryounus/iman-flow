import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
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
  final VerseShareService _shareService = VerseShareService();
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
          Glass(
            radius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.format_quote, color: ImanFlowTheme.gold),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Share a verse that inspired you...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showShareDialog(),
                  style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
                  child: const Text('Share'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (widget.womenMode) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.female, color: Colors.pinkAccent),
                  SizedBox(width: 8),
                  Expanded(child: Text('Viewing women-focused content', style: TextStyle(color: Colors.pinkAccent, fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text(widget.womenMode ? 'Sisters\' Reflections' : 'Community Reflections', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          const SizedBox(height: 12),

          StreamBuilder<List<SharedVerse>>(
            stream: _shareService.getSharedVerses(womenMode: widget.womenMode),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Error loading verses', style: TextStyle(color: Colors.red[300])));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: ImanFlowTheme.gold));
              
              final verses = snapshot.data ?? [];
              if (verses.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No verses shared yet.', style: TextStyle(color: Colors.white70))));

              return Column(children: verses.map((verse) => _buildVerseCard(verse)).toList());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(SharedVerse verse) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLiked = currentUser != null && verse.likedBy.contains(currentUser.uid);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Glass(
        radius: 16,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: ImanFlowTheme.glass, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: ImanFlowTheme.gold, borderRadius: BorderRadius.circular(8)),
                    child: Text(verse.verseKey, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Spacer(),
                  Text('Shared by ${verse.sharedBy}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(verse.arabicText, style: ArabicTextStyles.quranVerse(fontSize: 22, color: Colors.white, height: 2), textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(verse.translation, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
            ),
            if (verse.reflection != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: ImanFlowTheme.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 16, color: ImanFlowTheme.gold),
                      const SizedBox(width: 8),
                      Expanded(child: Text(verse.reflection!, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                    ],
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionBtn(isLiked ? Icons.favorite : Icons.favorite_border, '${verse.likeCount}', () => _shareService.toggleLike(verse.id), color: isLiked ? Colors.redAccent : null),
                  _actionBtn(Icons.copy, 'Copy', () => _copyVerse(verse)),
                  _actionBtn(Icons.share, '${verse.shareCount}', () => _shareVerse(verse)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? Colors.white70),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color ?? Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _copyVerse(SharedVerse verse) {
    Clipboard.setData(ClipboardData(text: '${verse.arabicText}\n\n"${verse.translation}"\n\n- Quran ${verse.verseKey}'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
  }

  void _shareVerse(SharedVerse verse) {
    _shareService.incrementShare(verse.id);
    Share.share('Iman Flow Verse:\n\n${verse.arabicText}\n\n"${verse.translation}"\n\n- Quran ${verse.verseKey}', subject: 'Verse from Iman Flow');
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ImanFlowTheme.bgMid,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share a Verse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: _verseRefController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Verse ref (e.g. 2:255)', filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reflectionController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Your reflection (optional)', filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSharing ? null : _submitShare,
                style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
                child: _isSharing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitShare() async {
    final ref = _verseRefController.text.trim();
    if (ref.isEmpty) return;
    setState(() => _isSharing = true);
    try {
      await _shareService.shareVerse(
        verseKey: ref,
        arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ', 
        translation: 'Say, "He is Allah, [who is] One."', 
        reflection: _reflectionController.text.trim().isNotEmpty ? _reflectionController.text.trim() : null,
        womenOnly: widget.womenMode,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shared successfully!')));
        _verseRefController.clear();
        _reflectionController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: ImanFlowTheme.error,
      ));
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
}
// Removed inline SharedVerse class definition as it's now imported
