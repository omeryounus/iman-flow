import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../services/community_dua_service.dart';
import '../../../core/services/service_locator.dart';

/// Dua Wall Widget - Anonymous community duas
class DuaWall extends StatefulWidget {
  const DuaWall({super.key});

  @override
  State<DuaWall> createState() => _DuaWallState();
}

class _DuaWallState extends State<DuaWall> {
  final CommunityDuaService _duaService = getIt<CommunityDuaService>();
  final TextEditingController _duaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedCategory = 'General';

  final List<String> _categories = ['General', 'Health', 'Guidance', 'Ummah', 'Studies', 'Rizq'];

  @override
  void dispose() {
    _duaController.dispose();
    super.dispose();
  }

  void _submitDua() async {
    if (_duaController.text.trim().isEmpty) return;
    try {
      await _duaService.addDua(_duaController.text.trim(), _selectedCategory);
      _duaController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dua request shared 🤲')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _prayForDua(String duaId) async {
    await _duaService.prayForDua(duaId);
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
         content: Text('JazakAllah Khair! 🤲', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
         duration: Duration(seconds: 1), 
         backgroundColor: ImanFlowTheme.success
       ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: Text('Support others with dua', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13))),
              ElevatedButton.icon(
                onPressed: _showAddDuaSheet,
                style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 16)),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Request'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CommunityDua>>(
            stream: _duaService.getDuasStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: ImanFlowTheme.gold));
              }

              final duas = snapshot.data ?? [];
              if (duas.isEmpty) {
                return Center(child: Text('No dua requests yet. Be the first!', style: TextStyle(color: Colors.white.withOpacity(0.5))));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: duas.length,
                itemBuilder: (context, index) {
                  final dua = duas[index];
                  final hasPrayed = userId != null && dua.prayedBy.contains(userId);
                  return _buildDuaCard(dua, hasPrayed);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDuaCard(CommunityDua dua, bool hasPrayed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Glass(
        radius: 16,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getCategoryColor(dua.category).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(dua.category, style: TextStyle(color: _getCategoryColor(dua.category), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  Text(_formatTime(dua.timestamp), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(dua.text, style: const TextStyle(color: Colors.white, height: 1.5)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
              child: Row(
                children: [
                  Text('🤲 ${dua.prayerCount} prayed', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6))),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: hasPrayed ? null : () => _prayForDua(dua.id),
                    icon: Icon(hasPrayed ? Icons.check_circle : Icons.volunteer_activism, size: 16),
                    label: Text(hasPrayed ? 'Prayed' : 'Make Dua', style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: hasPrayed ? ImanFlowTheme.success : ImanFlowTheme.gold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDuaSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ImanFlowTheme.bgMid,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Dua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                children: _categories.map((cat) => ChoiceChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  selected: _selectedCategory == cat,
                  onSelected: (v) { if(v) setModalState(() => _selectedCategory = cat); },
                  selectedColor: ImanFlowTheme.gold,
                  labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.black : Colors.white),
                )).toList(),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _duaController,
                maxLines: 4,
                maxLength: 280,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What do you need dua for?',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitDua,
                  style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
                  child: const Text('Share Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    if (category == 'Health') return Colors.redAccent;
    if (category == 'Guidance') return Colors.blueAccent;
    if (category == 'Rizq') return ImanFlowTheme.gold;
    if (category == 'Ummah') return Colors.greenAccent;
    return ImanFlowTheme.emeraldGlow;
  }

  String _formatTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
