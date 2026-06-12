import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_saved_workspace_panel_view.dart';

class OrderSavedWorkspacePanelHeader extends StatelessWidget {
  final OrderSavedWorkspacePanelView view;
  final bool isActiveWorkspaceModified;
  final bool canSaveCurrent;
  final VoidCallback? onManage;
  final VoidCallback? onSaveCurrent;

  const OrderSavedWorkspacePanelHeader({
    super.key,
    required this.view,
    required this.isActiveWorkspaceModified,
    required this.canSaveCurrent,
    required this.onManage,
    required this.onSaveCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 900.0;
        final badges = view.visibleBadgesForWidth(availableWidth);

        return Row(
          children: [
            Icon(
              Icons.bookmarks_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Saved workspaces',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            for (final badge in badges) ...[
              const SizedBox(width: 6),
              _SavedWorkspaceHeaderBadge(
                key: _badgeKey(badge.type),
                icon: _badgeIcon(badge.type),
                label: badge.label,
              ),
            ],
            if (view.hasWorkspaces) ...[
              const SizedBox(width: 6),
              IconButton(
                key: const ValueKey('order_saved_workspace_manage'),
                tooltip: 'Manage saved workspaces',
                onPressed: onManage,
                icon: const Icon(Icons.manage_search_outlined),
                iconSize: 18,
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
            if (canSaveCurrent && onSaveCurrent != null) ...[
              const SizedBox(width: POSUiTokens.gap),
              OutlinedButton.icon(
                key: const ValueKey('order_save_current_workspace'),
                onPressed: onSaveCurrent,
                icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                label: Text(isActiveWorkspaceModified ? 'Save as new' : 'Save'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SavedWorkspaceHeaderBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SavedWorkspaceHeaderBadge({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

Key _badgeKey(OrderSavedWorkspacePanelBadgeType type) {
  return switch (type) {
    OrderSavedWorkspacePanelBadgeType.saved => const ValueKey(
      'order_saved_workspace_count',
    ),
    OrderSavedWorkspacePanelBadgeType.pinned => const ValueKey(
      'order_saved_workspace_pinned_count',
    ),
    OrderSavedWorkspacePanelBadgeType.notes => const ValueKey(
      'order_saved_workspace_note_count',
    ),
  };
}

IconData _badgeIcon(OrderSavedWorkspacePanelBadgeType type) {
  return switch (type) {
    OrderSavedWorkspacePanelBadgeType.saved => Icons.bookmark_border_rounded,
    OrderSavedWorkspacePanelBadgeType.pinned => Icons.push_pin_rounded,
    OrderSavedWorkspacePanelBadgeType.notes => Icons.sticky_note_2_outlined,
  };
}
