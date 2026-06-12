import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_workspace_entry_context.dart';
import '../models/order_workspace_launch_context.dart';
import '../models/order_workspace_launch_resolution.dart';
import '../models/order_workspace_route_resolution.dart';

class OrderWorkspaceLaunchContextBanner extends StatelessWidget {
  final OrderWorkspaceLaunchContext launchContext;
  final OrderWorkspaceEntryContext? entryContext;
  final OrderWorkspaceLaunchResolution? launchResolution;
  final OrderWorkspaceRouteResolution? routeResolution;
  final ValueChanged<String>? onOpenCanonicalRoute;

  const OrderWorkspaceLaunchContextBanner({
    super.key,
    required this.launchContext,
    this.entryContext,
    this.launchResolution,
    this.routeResolution,
    this.onOpenCanonicalRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = entryContext;
    final resolution = launchResolution;
    final routeNote = entry?.routeNote ?? _routeNote(routeResolution);
    final canonicalRouteLocation = entry?.canonicalLaunchLocation ?? '';
    final showCanonicalRouteAction =
        (entry?.shouldOfferCanonicalRoute ?? false) &&
        canonicalRouteLocation.trim().isNotEmpty &&
        onOpenCanonicalRoute != null;
    final detailLabel =
        entry?.detailLabel ??
        resolution?.detailLabel ??
        [
          launchContext.reason.label,
          launchContext.orderProfileDisplayLabel,
          if (launchContext.hasWorkspaceView)
            launchContext.workspaceViewDisplayLabel,
        ].join(' - ');
    final launchFallbackMessage =
        entry?.launchFallbackMessage ?? resolution?.fallbackMessage ?? '';
    final isFallback =
        entry?.usedLaunchFallback ?? resolution?.usedFallback ?? false;

    return POSSurface(
      key: const ValueKey('order_workspace_launch_context_banner'),
      padding: const EdgeInsets.all(12),
      color: (isFallback
              ? theme.colorScheme.tertiaryContainer
              : theme.colorScheme.primaryContainer)
          .withValues(alpha: 0.24),
      border: Border.all(
        color: (isFallback
                ? theme.colorScheme.tertiary
                : theme.colorScheme.primary)
            .withValues(alpha: 0.18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          POSIconBadge(
            icon: isFallback ? Icons.info_outline : Icons.open_in_new_outlined,
            backgroundColor:
                isFallback
                    ? theme.colorScheme.tertiaryContainer
                    : theme.colorScheme.primaryContainer,
            foregroundColor:
                isFallback
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.primary,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Opened from ${launchContext.sourceProfileDisplayLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detailLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isFallback) ...[
                  const SizedBox(height: 5),
                  Text(
                    launchFallbackMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (routeNote.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    routeNote,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (showCanonicalRouteAction) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const ValueKey(
                        'order_workspace_open_canonical_route',
                      ),
                      onPressed:
                          () => onOpenCanonicalRoute!(canonicalRouteLocation),
                      icon: const Icon(Icons.alt_route_outlined, size: 18),
                      label: const Text('Open canonical route'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _routeNote(OrderWorkspaceRouteResolution? resolution) {
    if (resolution == null) return '';
    if (resolution.status == OrderWorkspaceRouteResolutionStatus.pathMatched) {
      return '';
    }

    return resolution.message;
  }
}
