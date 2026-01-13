import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:math' as math;
import '../../../app/theme.dart';

/// Qibla Compass Widget
class QiblaCompass extends StatefulWidget {
  const QiblaCompass({super.key});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> with SingleTickerProviderStateMixin {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _deviceSupport,
      builder: (context, AsyncSnapshot<bool?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError || snapshot.data == false) {
          return _buildUnsupportedView();
        }

        return _buildCompassView();
      },
    );
  }

  Widget _buildUnsupportedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sensors_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Compass Not Available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your device may not have compass sensors. Try using AR Qibla instead.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to AR Qibla
              },
              icon: const Icon(Icons.view_in_ar),
              label: const Text('Try AR Qibla'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassView() {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Calibrating compass...'),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return _buildUnsupportedView();
        }

        final qiblahDirection = snapshot.data!;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Compass Container
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ImanFlowTheme.primaryGreenLight.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ImanFlowTheme.primaryGreen.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Compass Rose / Background
                    Transform.rotate(
                      angle: -(qiblahDirection.direction * (math.pi / 180)),
                      child: CustomPaint(
                        size: const Size(260, 260),
                        painter: CompassPainter(
                          isDark: Theme.of(context).brightness == Brightness.dark,
                        ),
                      ),
                    ),
                    
                    // Qibla Direction Arrow
                    Transform.rotate(
                      angle: (qiblahDirection.qiblah * (math.pi / 180)),
                      child: Container(
                        width: 260,
                        height: 260,
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: ImanFlowTheme.accentGold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mosque,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    ImanFlowTheme.accentGold,
                                    ImanFlowTheme.accentGold.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Center Point
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: ImanFlowTheme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Direction Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDirectionInfo(
                      'Qibla',
                      '${qiblahDirection.qiblah.toStringAsFixed(1)}°',
                      Icons.mosque,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    _buildDirectionInfo(
                      'Compass',
                      '${qiblahDirection.direction.toStringAsFixed(1)}°',
                      Icons.explore,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ImanFlowTheme.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ImanFlowTheme.accentGold.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: ImanFlowTheme.accentGold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Point your phone in the direction of the golden arrow to face the Kaaba.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // AR Qibla Button
              OutlinedButton.icon(
                onPressed: () {
                  // Navigate to AR Qibla view
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.view_in_ar),
                label: const Text('Try AR Qibla'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDirectionInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: ImanFlowTheme.primaryGreen),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ImanFlowTheme.primaryGreen,
          ),
        ),
      ],
    );
  }
}

/// Custom Painter for Compass Rose
class CompassPainter extends CustomPainter {
  final bool isDark;

  CompassPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer circle
    final outerPaint = Paint()
      ..color = isDark ? Colors.grey[800]! : Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 10, outerPaint);

    // Draw direction markers
    final directions = ['N', 'E', 'S', 'W'];
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * (math.pi / 180);
      final x = center.dx + (radius - 30) * math.cos(angle);
      final y = center.dy + (radius - 30) * math.sin(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: directions[i] == 'N'
              ? ImanFlowTheme.error
              : (isDark ? Colors.white70 : Colors.grey[700]),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw tick marks
    for (var i = 0; i < 360; i += 10) {
      final angle = (i - 90) * (math.pi / 180);
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;
      
      final innerRadius = radius - (isCardinal ? 45 : (isMajor ? 20 : 15));
      final outerRadius = radius - 10;

      final x1 = center.dx + innerRadius * math.cos(angle);
      final y1 = center.dy + innerRadius * math.sin(angle);
      final x2 = center.dx + outerRadius * math.cos(angle);
      final y2 = center.dy + outerRadius * math.sin(angle);

      final tickPaint = Paint()
        ..color = isDark ? Colors.white54 : Colors.grey[500]!
        ..strokeWidth = isCardinal ? 2 : (isMajor ? 1.5 : 0.5);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
