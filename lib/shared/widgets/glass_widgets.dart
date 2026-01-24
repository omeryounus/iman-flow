import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';

/// Fade & Slide Entry Animation
class EnterAnim extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const EnterAnim({super.key, required this.child, this.delayMs = 0});
  @override
  State<EnterAnim> createState() => _EnterAnimState();
}

class _EnterAnimState extends State<EnterAnim> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<double>(begin: 12, end: 0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Glass Container with Blur and Border
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final Color? color;
  final BoxBorder? border; // Updated type from Border? to BoxBorder? to be safe
  final bool isCircle;

  const Glass({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.border,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: isCircle ? BorderRadius.circular(9999) : BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? ImanFlowTheme.glass2,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(radius),
            border: border ?? Border.all(color: ImanFlowTheme.stroke),
          ),
          child: child,
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  const TopBar({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Glass(
          radius: 18,
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.nights_stay_rounded, color: ImanFlowTheme.gold, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12)),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/settings'),
            borderRadius: BorderRadius.circular(18),
            child: Glass(
              radius: 18,
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.settings_rounded, color: Colors.white.withOpacity(.85), size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final bool gold;
  const Pill({super.key, required this.text, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: gold ? ImanFlowTheme.gold.withOpacity(.14) : Colors.black.withOpacity(.18),
        border: Border.all(
          color: gold ? ImanFlowTheme.gold.withOpacity(.22) : Colors.white.withOpacity(.12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: gold ? ImanFlowTheme.gold : Colors.white.withOpacity(.85),
        ),
      ),
    );
  }
}

class AyahCard extends StatelessWidget {
  final String arabic;
  final String translation;
  const AyahCard({super.key, required this.arabic, required this.translation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withOpacity(.14),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        children: [
          Text(
            arabic,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 24,
              height: 1.8,
              color: Colors.white.withOpacity(.94),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(.78), height: 1.4, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const NavItem({
    super.key,
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: active ? ImanFlowTheme.gold.withOpacity(.12) : Colors.transparent,
            border: Border.all(
              color: active ? ImanFlowTheme.gold.withOpacity(.22) : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 22,
                  color: active ? ImanFlowTheme.gold : Colors.white.withOpacity(.75)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: active ? ImanFlowTheme.gold : Colors.white.withOpacity(.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
