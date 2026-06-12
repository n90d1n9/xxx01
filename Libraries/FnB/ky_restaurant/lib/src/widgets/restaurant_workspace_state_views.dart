import 'package:flutter/material.dart';

import '../controllers/restaurant_workspace_state.dart';
import '../models/restaurant_snapshot_freshness.dart';
import 'restaurant_inline_notice.dart';
import 'restaurant_status_styles.dart';
import 'workspace_state_panel.dart';

/// Maps workspace loading state into empty, loading, and error notices.
class RestaurantWorkspaceStateNotice extends StatelessWidget {
  const RestaurantWorkspaceStateNotice({
    super.key,
    required this.state,
    required this.onRetry,
  });

  final RestaurantWorkspaceState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      RestaurantWorkspaceLoadStatus.loading =>
        const RestaurantWorkspaceStatePanel(
          icon: Icons.sync_rounded,
          title: 'Loading restaurant workspace',
          message: 'Fetching the latest floor, menu, and kitchen snapshot.',
          child: LinearProgressIndicator(),
        ),
      RestaurantWorkspaceLoadStatus.empty => RestaurantWorkspaceStatePanel(
        icon: Icons.inbox_outlined,
        title: 'No restaurant snapshot yet',
        message:
            'Connect a repository or seed demo data to show restaurant operations here.',
        child: RestaurantWorkspaceRetryButton(
          onRetry: onRetry,
          label: 'Refresh',
        ),
      ),
      RestaurantWorkspaceLoadStatus.error => RestaurantWorkspaceStatePanel(
        icon: Icons.cloud_off_outlined,
        title: 'Restaurant data is unavailable',
        message: state.errorMessage ?? 'The snapshot source did not respond.',
        child: RestaurantWorkspaceRetryButton(
          onRetry: onRetry,
          label: 'Try again',
        ),
      ),
      _ => RestaurantWorkspaceStatePanel(
        icon: Icons.restaurant_outlined,
        title: 'Restaurant workspace',
        message: 'Preparing the restaurant operations workspace.',
        child: RestaurantWorkspaceRetryButton(onRetry: onRetry, label: 'Load'),
      ),
    };
  }
}

/// Displays a compact notice while the restaurant snapshot is refreshing.
class RestaurantWorkspaceRefreshNotice extends StatelessWidget {
  const RestaurantWorkspaceRefreshNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RestaurantInlineNotice(
      leading: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
      ),
      message: 'Refreshing restaurant snapshot',
      backgroundColor: colors.primaryContainer.withValues(alpha: .36),
      foregroundColor: colors.onPrimaryContainer,
      messageStyle: theme.textTheme.labelLarge?.copyWith(
        color: colors.onPrimaryContainer,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Displays snapshot freshness status using the current update timestamp.
class RestaurantWorkspaceFreshnessNotice extends StatelessWidget {
  const RestaurantWorkspaceFreshnessNotice({
    super.key,
    required this.updatedAt,
    required this.isRefreshing,
    this.now,
  });

  final DateTime? updatedAt;
  final bool isRefreshing;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final evaluated = RestaurantSnapshotFreshness.evaluate(
      updatedAt: updatedAt,
      now: now ?? DateTime.now(),
      isRefreshing: isRefreshing,
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = restaurantStatusStyle(colors, evaluated.serviceStatus);

    return RestaurantInlineNotice(
      icon: _freshnessIcon(evaluated.status),
      title: '${evaluated.status.label} snapshot',
      message: evaluated.detail,
      backgroundColor: style.background.withValues(alpha: .72),
      borderColor: style.foreground.withValues(alpha: .16),
      foregroundColor: style.foreground,
      titleStyle: theme.textTheme.labelLarge?.copyWith(
        color: style.foreground,
        fontWeight: FontWeight.w900,
      ),
      messageStyle: theme.textTheme.labelSmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Displays the toolbar button used to refresh the restaurant snapshot.
class RestaurantWorkspaceRefreshButton extends StatelessWidget {
  const RestaurantWorkspaceRefreshButton({
    super.key,
    required this.onRefresh,
    required this.isRefreshing,
  });

  final VoidCallback onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Refresh restaurant snapshot',
      child: IconButton.filledTonal(
        onPressed: isRefreshing ? null : onRefresh,
        icon: isRefreshing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh_rounded),
      ),
    );
  }
}

IconData _freshnessIcon(RestaurantSnapshotFreshnessStatus status) {
  return switch (status) {
    RestaurantSnapshotFreshnessStatus.unknown => Icons.help_outline_rounded,
    RestaurantSnapshotFreshnessStatus.fresh => Icons.verified_outlined,
    RestaurantSnapshotFreshnessStatus.aging => Icons.schedule_outlined,
    RestaurantSnapshotFreshnessStatus.stale => Icons.warning_amber_rounded,
    RestaurantSnapshotFreshnessStatus.refreshing => Icons.sync_rounded,
  };
}
