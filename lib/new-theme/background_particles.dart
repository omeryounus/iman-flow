import 'dart:math';
import 'package:flutter/material.dart';
import 'main.dart';

class PremiumBackgroundWithParticles extends StatefulWidget {
  const PremiumBackgroundWithParticles({super.key});

  @override
  State<PremiumBackgroundWithParticles> createState() => _PremiumBackgroundWithParticlesState();
}

class _PremiumBackgroundWithParticlesState extends State<PremiumBackgroundWithParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_P> _p;
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _p = List.generate(60, (_) => _P.random(_rnd));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppTheme.bgTop, AppTheme.bgMid, AppTheme.bgBot],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -120,
            child: _Glow(color: AppTheme.gold.withOpacity(.18), size: 360),
          ),
          Positioned(
            bottom: -180,
            right: -160,
            child: _Glow(color: AppTheme.emeraldGlow.withOpacity(.10), size: 420),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final t = _c.value;
                return CustomPaint(painter: _ParticlesPainter(_p, t));
              },
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _GeoPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 24)],
      ),
    );
  }
}

class _P {
  double x, y, s, v;
  _P(this.x, this.y, this.s, this.v);

  factory _P.random(Random r) {
    return _P(
      r.nextDouble(),
      r.nextDouble(),
      0.7 + r.nextDouble() * 1.8,
      0.02 + r.nextDouble() * 0.08,
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<_P> p;
  final double t;
  _ParticlesPainter(this.p, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()..color = AppTheme.gold.withOpacity(.20);
    final white = Paint()..color = Colors.white.withOpacity(.10);

    for (final pt in p) {
      final dx = (pt.x + sin((t * 2 * pi) + pt.y * 6) * 0.006) * size.width;
      final dy = ((pt.y - t * pt.v) % 1.0) * size.height;
      final paint = (pt.x > 0.72) ? gold : white;
      canvas.drawCircle(Offset(dx, dy), pt.s, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}

class _GeoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const step = 84.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final rect = Rect.fromCenter(center: Offset(x, y), width: 42, height: 42);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
