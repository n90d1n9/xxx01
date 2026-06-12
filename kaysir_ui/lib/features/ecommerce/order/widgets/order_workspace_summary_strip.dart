import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/order_workspace_summary.dart';
import '../models/order_workspace_view.dart';

class OrderWorkspaceSummaryStrip extends StatelessWidget {
  final OrderWorkspaceContext workspace;
  final List<pos_order.Order> orders;

  const OrderWorkspaceSummaryStrip({
    super.key,
    required this.workspace,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final summary = OrderWorkspaceSummary.fromOrders(
      workspace: workspace,
      orders: orders,
    );

    return POSSurface(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
      border: Border.all(color: theme.dividerColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              POSIconBadge(
                icon: Icons.insights_outlined,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: POSUiTokens.gapLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      summary.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  constraints.maxWidth >= 980
                      ? 4
                      : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              final spacing = columns == 1 ? 0.0 : POSUiTokens.gapLarge;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: POSUiTokens.gapLarge,
                runSpacing: POSUiTokens.gapLarge,
                children: summary.signals
                    .map(
                      (signal) => _WorkspaceSignalCard(
                        width: cardWidth,
                        signal: signal,
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkspaceSignalCard extends StatelessWidget {
  final double width;
  final OrderWorkspaceSignal signal;

  const _WorkspaceSignalCard({required this.width, required this.signal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _signalColors(theme.colorScheme, signal.tone);

    return SizedBox(
      key: ValueKey('order_workspace_signal_${signal.id}'),
      width: width,
      child: POSSurface(
        padding: const EdgeInsets.all(12),
        color: colors.background,
        border: Border.all(color: colors.foreground.withValues(alpha: 0.18)),
        child: Row(
          children: [
            POSIconBadge(
              icon: _signalIcon(signal.id),
              backgroundColor: colors.foreground.withValues(alpha: 0.12),
              foregroundColor: colors.foreground,
              size: 32,
              iconSize: 18,
            ),
            const SizedBox(width: POSUiTokens.gapLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    signal.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    signal.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    signal.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

({Color background, Color foreground}) _signalColors(
  ColorScheme scheme,
  OrderWorkspaceSignalTone tone,
) {
  return switch (tone) {
    OrderWorkspaceSignalTone.neutral => (
      background: scheme.surface,
      foreground: scheme.outline,
    ),
    OrderWorkspaceSignalTone.info => (
      background: scheme.primaryContainer.withValues(alpha: 0.22),
      foreground: scheme.primary,
    ),
    OrderWorkspaceSignalTone.success => (
      background: scheme.tertiaryContainer.withValues(alpha: 0.28),
      foreground: scheme.tertiary,
    ),
    OrderWorkspaceSignalTone.warning => (
      background: scheme.surfaceContainerHighest.withValues(alpha: 0.62),
      foreground: scheme.outline,
    ),
    OrderWorkspaceSignalTone.danger => (
      background: scheme.errorContainer.withValues(alpha: 0.32),
      foreground: scheme.error,
    ),
  };
}

IconData _signalIcon(String signalId) {
  return switch (signalId) {
    'top_channel' => Icons.hub_outlined,
    'fulfillment_mix' => Icons.local_shipping_outlined,
    'payment_health' => Icons.payments_outlined,
    'ops_attention' => Icons.assignment_late_outlined,
    _ => Icons.insights_outlined,
  };
}
