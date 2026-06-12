import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/utils/pos_formatters.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../order/models/order_insights.dart';
import 'empty_state.dart';
import 'inset_surface.dart';

class OrderBreakdownList extends StatelessWidget {
  const OrderBreakdownList({
    required this.title,
    required this.emptyMessage,
    required this.rows,
    this.maxVisibleRows = 4,
    super.key,
  }) : assert(maxVisibleRows > 0);

  final String title;
  final String emptyMessage;
  final List<OrderBreakdown> rows;
  final int maxVisibleRows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleRows = rows.take(maxVisibleRows).toList(growable: false);
    final totalOrders = rows.fold<int>(
      0,
      (sum, value) => sum + value.orderCount,
    );

    return InsetSurface(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: POSUiTokens.gap),
          if (visibleRows.isEmpty)
            EmptyState(message: emptyMessage, fontWeight: FontWeight.w600)
          else
            ...visibleRows.map(
              (row) => OrderBreakdownRow(row: row, totalOrders: totalOrders),
            ),
        ],
      ),
    );
  }
}

class OrderBreakdownRow extends StatelessWidget {
  const OrderBreakdownRow({
    required this.row,
    required this.totalOrders,
    super.key,
  });

  final OrderBreakdown row;
  final int totalOrders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = totalOrders == 0 ? 0.0 : row.orderCount / totalOrders;

    return Padding(
      padding: const EdgeInsets.only(bottom: POSUiTokens.gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: POSUiTokens.gap),
              Text(
                '${row.orderCount} / ${formatPOSCurrency(row.revenue)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(POSUiTokens.radius),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              minHeight: 6,
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }
}
