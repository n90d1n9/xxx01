import 'package:flutter/material.dart';

import 'pos_ui.dart';

class POSSwitchPanelHeader extends StatelessWidget {
  final String title;
  final String currentLabel;

  const POSSwitchPanelHeader({
    super.key,
    required this.title,
    required this.currentLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: POSUiTokens.gap),
        Flexible(
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(POSUiTokens.radius),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              currentLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class POSSwitchPanelEmptyState extends StatelessWidget {
  final bool filterActive;
  final String filteredTitle;
  final String emptyTitle;
  final IconData icon;

  const POSSwitchPanelEmptyState({
    super.key,
    required this.filterActive,
    required this.filteredTitle,
    required this.emptyTitle,
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: POSUiTokens.gap),
            Text(
              filterActive ? filteredTitle : emptyTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
