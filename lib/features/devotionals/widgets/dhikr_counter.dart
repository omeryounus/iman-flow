import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/streak_service.dart';

/// Dhikr Counter Widget - Digital Tasbih
class DhikrCounter extends StatefulWidget {
  final VoidCallback? onComplete;

  const DhikrCounter({super.key, this.onComplete});

  @override
  State<DhikrCounter> createState() => _DhikrCounterState();
}

class _DhikrCounterState extends State<DhikrCounter> with SingleTickerProviderStateMixin {
  final StreakService _streakService = getIt<StreakService>();
  
  int _count = 0;
  int _targetCount = 33;
  String _selectedDhikr = 'SubhanAllah';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<DhikrItem> _dhikrList = [
    DhikrItem(name: 'SubhanAllah', arabic: 'سُبْحَانَ اللهِ', meaning: 'Glory be to Allah', defaultCount: 33),
    DhikrItem(name: 'Alhamdulillah', arabic: 'الْحَمْدُ لِلَّهِ', meaning: 'All praise is due to Allah', defaultCount: 33),
    DhikrItem(name: 'Allahu Akbar', arabic: 'اللهُ أَكْبَرُ', meaning: 'Allah is the Greatest', defaultCount: 34),
    DhikrItem(name: 'La ilaha illallah', arabic: 'لَا إِلَٰهَ إِلَّا اللهُ', meaning: 'There is no god but Allah', defaultCount: 100),
    DhikrItem(name: 'Astaghfirullah', arabic: 'أَسْتَغْفِرُ اللهَ', meaning: 'I seek forgiveness from Allah', defaultCount: 100),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
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
    _animationController.forward().then((_) => _animationController.reverse());

    setState(() => _count++);

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
          content: Text('$_selectedDhikr completed! 📿'),
          backgroundColor: ImanFlowTheme.gold,
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
    final currentDhikr = _dhikrList.firstWhere((d) => d.name == _selectedDhikr, orElse: () => _dhikrList[0]);
    final progress = _count / _targetCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Dhikr Selector
          Glass(
            radius: 12,
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: _showDhikrSelector,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentDhikr.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          Text(currentDhikr.meaning, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text(currentDhikr.arabic, style: ArabicTextStyles.quranVerse(fontSize: 32, color: ImanFlowTheme.gold), textAlign: TextAlign.center),

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
                      ImanFlowTheme.emeraldGlow.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                     BoxShadow(color: ImanFlowTheme.emeraldGlow.withOpacity(0.1), blurRadius: 40, spreadRadius: 5),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress > 1 ? 1 : progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(ImanFlowTheme.gold),
                      ),
                    ),
                    Glass(
                      radius: 200, isCircle: true,
                      padding: const EdgeInsets.all(0),
                      child: Container(
                         width: 200, height: 200,
                         alignment: Alignment.center,
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text('${_count}', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white)),
                             Text('of $_targetCount', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                           ],
                         ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Text('Tap to count', style: TextStyle(color: Colors.white.withOpacity(0.5))),

          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _reset,
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _showTargetSelector,
                style: OutlinedButton.styleFrom(foregroundColor: ImanFlowTheme.gold, side: const BorderSide(color: ImanFlowTheme.gold)),
                icon: const Icon(Icons.track_changes),
                label: Text('Target: $_targetCount'),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 8,
            children: [33, 34, 100].map((t) => ChoiceChip(
              label: Text("$t"), 
              selected: _targetCount == t,
              onSelected: (v) { if(v) setState(() => _targetCount = t); },
              selectedColor: ImanFlowTheme.gold,
              backgroundColor: Colors.white10,
              labelStyle: TextStyle(color: _targetCount == t ? Colors.black : Colors.white),
            )).toList(),
          ),
        ],
      ),
    );
  }

  void _showDhikrSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ImanFlowTheme.bgMid,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Dhikr', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ..._dhikrList.map((dhikr) => ListTile(
              onTap: () => _selectDhikr(dhikr),
              title: Text(dhikr.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(dhikr.meaning, style: const TextStyle(color: Colors.white70)),
              trailing: Text(dhikr.arabic, style: ArabicTextStyles.quranVerse(fontSize: 18, color: ImanFlowTheme.gold)),
            )),
          ],
        ),
      ),
    );
  }

  void _showTargetSelector() {
    // simplified for brevity
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ImanFlowTheme.bgMid,
        title: const Text('Set Target', style: TextStyle(color: Colors.white)),
        content: TextField(
           keyboardType: TextInputType.number,
           style: const TextStyle(color: Colors.white),
           onSubmitted: (v) {
             final t = int.tryParse(v) ?? 33;
             setState(() => _targetCount = t);
             Navigator.pop(context);
           },
        ),
      ),
    );
  }
}

class DhikrItem {
  final String name;
  final String arabic;
  final String meaning;
  final int defaultCount;

  DhikrItem({required this.name, required this.arabic, required this.meaning, required this.defaultCount});
}
