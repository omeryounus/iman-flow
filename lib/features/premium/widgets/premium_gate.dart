import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/services/premium_service.dart';
import '../../../core/services/service_locator.dart';
import 'premium_badge.dart';

/// Premium Gate - Wraps content that requires premium access
class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String? customMessage;
  final bool showLockOverlay;

  const PremiumGate({
    super.key,
    required this.child,
    required this.featureName,
    this.customMessage,
    this.showLockOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final premiumService = getIt<PremiumService>();

    return StreamBuilder<bool>(
      stream: premiumService.isPremiumStream,
      initialData: premiumService.isPremium,
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;

        if (isPremium) {
          return child;
        }

        return showLockOverlay
            ? _buildLockedOverlay(context)
            : _buildLockedPlaceholder(context);
      },
    );
  }

  Widget _buildLockedOverlay(BuildContext context) {
    return Stack(
      children: [
        // Blurred/dimmed child content
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.grey.withOpacity(0.5),
              BlendMode.saturation,
            ),
            child: child,
          ),
        ),

        // Lock overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: GestureDetector(
                onTap: () => _showPaywall(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 32,
                        color: ImanFlowTheme.accentGold,
                      ),
                      const SizedBox(height: 8),
                      const PremiumBadge(size: 18),
                      const SizedBox(height: 8),
                      Text(
                        customMessage ?? 'Unlock this feature',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showPaywall(context),
                        child: const Text('Upgrade'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedPlaceholder(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPaywall(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ImanFlowTheme.accentGold.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ImanFlowTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lock,
                color: ImanFlowTheme.accentGold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        featureName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const PremiumBadge(size: 14),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customMessage ?? 'Upgrade to unlock this feature',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: ImanFlowTheme.accentGold,
            ),
          ],
        ),
      ),
    );
  }

  void _showPaywall(BuildContext context) {
    context.push('/premium');
  }
}
