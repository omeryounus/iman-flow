import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// User-friendly error display with retry button
class ErrorView extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// Factory for network errors
  factory ErrorView.network({VoidCallback? onRetry}) {
    return ErrorView(
      title: 'No connection',
      message: 'Please check your internet and try again',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }

  /// Factory for permission errors
  factory ErrorView.permission({VoidCallback? onRetry, String? feature}) {
    return ErrorView(
      title: 'Permission needed',
      message: feature != null 
          ? 'Please grant $feature permission in settings'
          : 'Please grant the required permission',
      icon: Icons.lock_outline,
      onRetry: onRetry,
    );
  }

  /// Factory for location errors
  factory ErrorView.location({VoidCallback? onRetry}) {
    return ErrorView(
      title: 'Location unavailable',
      message: 'Enable location services for prayer times',
      icon: Icons.location_off,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ImanFlowTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: ImanFlowTheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ImanFlowTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
