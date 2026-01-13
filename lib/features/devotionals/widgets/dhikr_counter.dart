import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/streak_service.dart';

/// Dhikr Counter Widget - Digital Tasbih
class DhikrCounter extends StatefulWidget {
  final VoidCallback? onComplete;

  const DhikrCounter({super.key, this.onComplete});

  @override
  State<DhikrCounter> createState() => _DhikrCounterState();
}

class _DhikrCounterState extends State<DhikrCounter>
    with SingleTickerProviderStateMixin {
  final StreakService _streakService = getIt<StreakService>();
  
  int _count = 0;
  int _targetCount = 33;
  String _selectedDhikr = 'SubhanAllah';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<DhikrItem> _dhikrList = [
    DhikrItem(
      name: 'SubhanAllah',
      arabic: 'سُبْحَانَ اللهِ',
      meaning: 'Glory be to Allah',
      defaultCount: 33,
    ),
    DhikrItem(
      name: 'Alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      meaning: 'All praise is due to Allah',
      defaultCount: 33,
    ),
    DhikrItem(
      name: 'Allahu Akbar',
      arabic: 'اللهُ أَكْبَرُ',
      meaning: 'Allah is the Greatest',
      defaultCount: 34,
    ),
    DhikrItem(
      name: 'La ilaha illallah',
      arabic: 'لَا إِلَٰهَ إِلَّا اللهُ',
      meaning: 'There is no god but Allah',
      defaultCount: 100,
    ),
    DhikrItem(
      name: 'Astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللهَ',
      meaning: 'I seek forgiveness from Allah',
      defaultCount: 100,
    ),
    DhikrItem(
      name: 'SubhanAllahi wa bihamdihi',
      arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      meaning: 'Glory and Praise be to Allah',
      defaultCount: 100,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _count++;
    });

    if (_count >= _targetCount) {
      _onComplete();
    }
  }

  void _onComplete() async {
    HapticFeedback.heavyImpact();
    await _streakService.logDhikr();
    widget.onComplete?.call();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('$_selectedDhikr completed! 📿'),
            ],
          ),
          backgroundColor: ImanFlowTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() => _count = 0);
  }

  void _selectDhikr(DhikrItem dhikr) {
    setState(() {
      _selectedDhikr = dhikr.name;
      _targetCount = dhikr.defaultCount;
      _count = 0;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDhikr = _dhikrList.firstWhere((d) => d.name == _selectedDhikr);
    final progress = _count / _targetCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Dhikr Selector
          InkWell(
            onTap: () => _showDhikrSelector(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDhikr.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currentDhikr.meaning,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    currentDhikr.arabic,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Counter Circle
          GestureDetector(
            onTap: _increment,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ImanFlowTheme.primaryGreen.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress Ring
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(
                          progress >= 1.0
                              ? ImanFlowTheme.accentGold
                              : ImanFlowTheme.primaryGreen,
                        ),
                      ),
                    ),
                    // Inner Circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: ImanFlowTheme.primaryGreen.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_count',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: progress >= 1.0
                                  ? ImanFlowTheme.accentGold
                                  : ImanFlowTheme.primaryGreen,
                            ),
                          ),
                          Text(
                            'of $_targetCount',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Tap to count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset Button
              ElevatedButton.icon(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.grey.shade700,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              // Target Selector
              ElevatedButton.icon(
                onPressed: () => _showTargetSelector(),
                icon: const Icon(Icons.track_changes),
                label: Text('Target: $_targetCount'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Count Buttons
          Wrap(
            spacing: 8,
            children: [33, 34, 99, 100].map((target) {
              return FilterChip(
                selected: _targetCount == target,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _targetCount = target);
                  }
                },
                label: Text('$target'),
                selectedColor: ImanFlowTheme.primaryGreen.withOpacity(0.2),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDhikrSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Dhikr',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._dhikrList.map((dhikr) => ListTile(
              onTap: () => _selectDhikr(dhikr),
              title: Text(dhikr.name),
              subtitle: Text(dhikr.meaning),
              trailing: Text(
                dhikr.arabic,
                style: const TextStyle(fontFamily: 'Amiri', fontSize: 18),
              ),
              selected: _selectedDhikr == dhikr.name,
              selectedTileColor: ImanFlowTheme.primaryGreen.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showTargetSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Target Count'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target',
            hintText: 'Enter target count',
          ),
          onSubmitted: (value) {
            final target = int.tryParse(value) ?? 33;
            setState(() => _targetCount = target);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class DhikrItem {
  final String name;
  final String arabic;
  final String meaning;
  final int defaultCount;

  DhikrItem({
    required this.name,
    required this.arabic,
    required this.meaning,
    required this.defaultCount,
  });
}
