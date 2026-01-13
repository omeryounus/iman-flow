import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Empty state illustrations for lists/content
class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  /// Factory for empty bookmarks
  factory EmptyState.bookmarks({VoidCallback? onAction}) {
    return EmptyState(
      title: 'No bookmarks yet',
      message: 'Save your favorite verses here',
      icon: Icons.bookmark_outline,
      onAction: onAction,
      actionLabel: 'Browse Quran',
    );
  }

  /// Factory for empty history
  factory EmptyState.history() {
    return const EmptyState(
      title: 'No history yet',
      message: 'Your reading history will appear here',
      icon: Icons.history,
    );
  }

  /// Factory for empty search results
  factory EmptyState.noResults({String? query}) {
    return EmptyState(
      title: 'No results found',
      message: query != null ? 'Try searching for something else' : null,
      icon: Icons.search_off,
    );
  }

  /// Factory for empty prayers
  factory EmptyState.prayers() {
    return const EmptyState(
      title: 'Loading prayer times...',
      message: 'Enable location for accurate times',
      icon: Icons.access_time,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ImanFlowTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: ImanFlowTheme.primaryGreen.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ImanFlowTheme.primaryGreen,
                  side: BorderSide(color: ImanFlowTheme.primaryGreen),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
