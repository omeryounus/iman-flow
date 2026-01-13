import 'package:flutter/material.dart';
import '../../../app/theme.dart';

/// Premium Badge - Shows "PRO" indicator on premium features
class PremiumBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const PremiumBadge({
    super.key,
    this.onTap,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size * 0.5,
          vertical: size * 0.2,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ImanFlowTheme.accentGold,
              ImanFlowTheme.accentGold.withRed(220),
            ],
          ),
          borderRadius: BorderRadius.circular(size * 0.4),
          boxShadow: [
            BoxShadow(
              color: ImanFlowTheme.accentGold.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: size * 0.8,
              color: Colors.white,
            ),
            SizedBox(width: size * 0.2),
            Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.7,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
