import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Dua Wall Widget - Anonymous community duas
class DuaWall extends StatefulWidget {
  const DuaWall({super.key});

  @override
  State<DuaWall> createState() => _DuaWallState();
}

class _DuaWallState extends State<DuaWall> {
  final TextEditingController _duaController = TextEditingController();

  // Sample duas (would come from Firestore in production)
  final List<DuaRequest> _duas = [
    DuaRequest(
      id: '1',
      text: 'Please make dua for my mother who is unwell. May Allah grant her complete shifa. 🤲',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      prayerCount: 47,
      category: 'Health',
    ),
    DuaRequest(
      id: '2',
      text: 'Seeking duas for guidance in making a difficult life decision. JazakAllah khair.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      prayerCount: 32,
      category: 'Guidance',
    ),
    DuaRequest(
      id: '3',
      text: 'Please pray for peace and safety for our brothers and sisters around the world.',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      prayerCount: 156,
      category: 'Ummah',
    ),
    DuaRequest(
      id: '4',
      text: 'Make dua for my exams next week. May Allah make it easy and grant success.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      prayerCount: 23,
      category: 'Studies',
    ),
    DuaRequest(
      id: '5',
      text: 'Prayers requested for my family\'s financial situation. May Allah provide.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      prayerCount: 89,
      category: 'Rizq',
    ),
  ];

  @override
  void dispose() {
    _duaController.dispose();
    super.dispose();
  }

  void _submitDua() {
    if (_duaController.text.trim().isEmpty) return;

    setState(() {
      _duas.insert(
        0,
        DuaRequest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _duaController.text.trim(),
          timestamp: DateTime.now(),
          prayerCount: 0,
          category: 'General',
        ),
      );
    });

    _duaController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your dua request has been shared. May Allah answer it! 🤲'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _prayForDua(DuaRequest dua) {
    setState(() {
      dua.prayerCount++;
      dua.hasPrayed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JazakAllah Khair for making dua! 🤲'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Support your brothers and sisters with dua',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddDuaSheet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Request Dua'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          ),
        ),

        // Dua List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _duas.length,
            itemBuilder: (context, index) {
              final dua = _duas[index];
              return _buildDuaCard(dua);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDuaCard(DuaRequest dua) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Time
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(dua.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dua.category,
                    style: TextStyle(
                      color: _getCategoryColor(dua.category),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(dua.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Dua Text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              dua.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Prayer Count
                Row(
                  children: [
                    Text(
                      '🤲',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dua.prayerCount} prayed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Pray Button
                TextButton.icon(
                  onPressed: dua.hasPrayed ? null : () => _prayForDua(dua),
                  icon: Icon(
                    dua.hasPrayed ? Icons.check_circle : Icons.volunteer_activism,
                    size: 18,
                  ),
                  label: Text(dua.hasPrayed ? 'Prayed' : 'Make Dua'),
                  style: TextButton.styleFrom(
                    foregroundColor: dua.hasPrayed
                        ? ImanFlowTheme.success
                        : ImanFlowTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDuaSheet() {
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
            Row(
              children: [
                Text(
                  'Request Dua',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Share your dua request anonymously. The Ummah will pray for you.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _duaController,
              maxLines: 4,
              maxLength: 280,
              decoration: InputDecoration(
                hintText: 'What do you need dua for?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitDua,
                child: const Text('Share Dua Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Health':
        return Colors.red;
      case 'Guidance':
        return Colors.blue;
      case 'Ummah':
        return ImanFlowTheme.primaryGreen;
      case 'Studies':
        return Colors.orange;
      case 'Rizq':
        return ImanFlowTheme.accentGold;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class DuaRequest {
  final String id;
  final String text;
  final DateTime timestamp;
  int prayerCount;
  final String category;
  bool hasPrayed;

  DuaRequest({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.prayerCount,
    required this.category,
    this.hasPrayed = false,
  });
}
