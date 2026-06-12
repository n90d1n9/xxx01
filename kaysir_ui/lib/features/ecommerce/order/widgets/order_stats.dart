import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/utils/pos_formatters.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/order_insights.dart';

class OrdersStats extends StatelessWidget {
  final List<pos_order.Order> orders;

  const OrdersStats({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final insights = OrderInsights.fromOrders(orders);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 980
                ? 4
                : constraints.maxWidth >= 620
                ? 2
                : 1;
        final spacing = columns == 1 ? 0.0 : POSUiTokens.gapLarge;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: POSUiTokens.gapLarge,
          runSpacing: POSUiTokens.gapLarge,
          children: [
            _InsightCard(
              width: width,
              label: 'Orders',
              value: '${insights.orderCount}',
              detail:
                  '${insights.paidOrderCount} paid, ${insights.channelBreakdown.length} channels',
              icon: Icons.receipt_long_outlined,
              tone: _InsightTone.primary,
            ),
            _InsightCard(
              width: width,
              label: 'Revenue',
              value: formatPOSCurrency(insights.revenue),
              detail: 'Across selected ecommerce orders',
              icon: Icons.payments_outlined,
              tone: _InsightTone.success,
            ),
            _InsightCard(
              width: width,
              label: 'Avg order',
              value: formatPOSCurrency(insights.averageOrderValue),
              detail: 'Basket value per order',
              icon: Icons.bar_chart_outlined,
              tone: _InsightTone.warning,
            ),
            _InsightCard(
              width: width,
              label: 'Ops attention',
              value: '${insights.attentionOrderCount}',
              detail:
                  '${insights.criticalAttentionOrderCount} high priority, ${insights.externalSettlementCount} settlement',
              icon: Icons.assignment_late_outlined,
              tone:
                  insights.criticalAttentionOrderCount > 0
                      ? _InsightTone.danger
                      : _InsightTone.secondary,
            ),
          ],
        );
      },
    );
  }
}

enum _InsightTone { primary, secondary, success, warning, danger }

class _InsightCard extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final _InsightTone tone;

  const _InsightCard({
    required this.width,
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colors(theme.colorScheme);

    return SizedBox(
      width: width,
      child: POSSurface(
        padding: const EdgeInsets.all(14),
        color: colors.$1,
        border: Border.all(color: colors.$2.withValues(alpha: 0.24)),
        elevated: true,
        child: Row(
          children: [
            POSIconBadge(
              icon: icon,
              backgroundColor: colors.$2.withValues(alpha: 0.14),
              foregroundColor: colors.$2,
            ),
            const SizedBox(width: POSUiTokens.gapLarge),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
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

  (Color, Color) _colors(ColorScheme scheme) {
    return switch (tone) {
      _InsightTone.primary => (
        scheme.primaryContainer.withValues(alpha: 0.28),
        scheme.primary,
      ),
      _InsightTone.secondary => (
        scheme.secondaryContainer.withValues(alpha: 0.34),
        scheme.secondary,
      ),
      _InsightTone.success => (
        scheme.tertiaryContainer.withValues(alpha: 0.32),
        scheme.tertiary,
      ),
      _InsightTone.warning => (
        scheme.surfaceContainerHighest.withValues(alpha: 0.58),
        scheme.outline,
      ),
      _InsightTone.danger => (
        scheme.errorContainer.withValues(alpha: 0.34),
        scheme.error,
      ),
    };
  }
}
