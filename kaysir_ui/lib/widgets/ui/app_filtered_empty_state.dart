import 'package:flutter/material.dart';

class AppFilteredEmptyState extends StatelessWidget {
  const AppFilteredEmptyState({
    super.key,
    required this.title,
    this.icon = Icons.search_off_outlined,
    this.actionLabel = 'Clear filters',
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: Text(actionLabel),
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
