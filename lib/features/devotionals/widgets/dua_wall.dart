import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

/// Dua Wall Widget - Anonymous community duas
class DuaWall extends StatefulWidget {
  const DuaWall({super.key});

  @override
  State<DuaWall> createState() => _DuaWallState();
}

class _DuaWallState extends State<DuaWall> {
  final TextEditingController _duaController = TextEditingController();

  // Sample duas
  final List<DuaRequest> _duas = [
    DuaRequest(id: '1', text: 'Please make dua for my mother who is unwell. May Allah grant her complete shifa. 🤲', timestamp: DateTime.now().subtract(const Duration(hours: 2)), prayerCount: 47, category: 'Health'),
    DuaRequest(id: '2', text: 'Seeking duas for guidance in making a difficult life decision. JazakAllah khair.', timestamp: DateTime.now().subtract(const Duration(hours: 5)), prayerCount: 32, category: 'Guidance'),
    DuaRequest(id: '3', text: 'Please pray for peace and safety for our brothers and sisters around the world.', timestamp: DateTime.now().subtract(const Duration(hours: 8)), prayerCount: 156, category: 'Ummah'),
    DuaRequest(id: '4', text: 'Make dua for my exams next week. May Allah make it easy and grant success.', timestamp: DateTime.now().subtract(const Duration(days: 1)), prayerCount: 23, category: 'Studies'),
  ];

  @override
  void dispose() {
    _duaController.dispose();
    super.dispose();
  }

  void _submitDua() {
    if (_duaController.text.trim().isEmpty) return;
    setState(() {
      _duas.insert(0, DuaRequest(id: DateTime.now().toString(), text: _duaController.text.trim(), timestamp: DateTime.now(), prayerCount: 0, category: 'General'));
    });
    _duaController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dua request shared 🤲'), backgroundColor: ImanFlowTheme.gold));
  }

  void _prayForDua(DuaRequest dua) {
    setState(() { dua.prayerCount++; dua.hasPrayed = true; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JazakAllah Khair! 🤲'), duration: Duration(seconds: 1), backgroundColor: ImanFlowTheme.success));
  }

  @override
  Widget build(BuildContext context) {
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _duas.length,
            itemBuilder: (context, index) => _buildDuaCard(_duas[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildDuaCard(DuaRequest dua) {
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
                    onPressed: dua.hasPrayed ? null : () => _prayForDua(dua),
                    icon: Icon(dua.hasPrayed ? Icons.check_circle : Icons.volunteer_activism, size: 16),
                    label: Text(dua.hasPrayed ? 'Prayed' : 'Make Dua', style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: dua.hasPrayed ? ImanFlowTheme.success : ImanFlowTheme.gold),
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Request Dua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
    );
  }

  Color _getCategoryColor(String category) {
    if (category == 'Health') return Colors.redAccent;
    if (category == 'Guidance') return Colors.blueAccent;
    if (category == 'Rizq') return ImanFlowTheme.gold;
    return ImanFlowTheme.emeraldGlow;
  }

  String _formatTime(DateTime timestamp) {
    // simplified
    final diff = DateTime.now().difference(timestamp);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class DuaRequest {
  final String id;
  final String text;
  final DateTime timestamp;
  int prayerCount;
  final String category;
  bool hasPrayed;

  DuaRequest({required this.id, required this.text, required this.timestamp, required this.prayerCount, required this.category, this.hasPrayed = false});
}
