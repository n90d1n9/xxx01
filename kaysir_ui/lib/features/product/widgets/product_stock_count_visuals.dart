import 'package:flutter/material.dart';

import '../utils/product_stock_count_view.dart';

String productStockCountSummaryLabel(ProductStockCountSummary summary) {
  if (summary.isComplete) {
    return '${summary.totalProducts} products counted, '
        '${summary.discrepancyCount} variance to review';
  }

  return '${summary.pendingCount} pending, '
      '${summary.countedCount} counted, '
      '${summary.discrepancyCount} variance to review';
}

String productStockCountFilterLabel(ProductStockCountFilter filter) {
  switch (filter) {
    case ProductStockCountFilter.all:
      return 'All';
    case ProductStockCountFilter.needsReview:
      return 'Needs review';
    case ProductStockCountFilter.pending:
      return 'Pending';
    case ProductStockCountFilter.counted:
      return 'Counted';
    case ProductStockCountFilter.discrepancy:
      return 'Variance';
  }
}

Color productStockCountStatusColor(
  BuildContext context,
  ProductStockCountStatus status,
) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case ProductStockCountStatus.pending:
      return Colors.orange;
    case ProductStockCountStatus.matched:
      return Colors.green;
    case ProductStockCountStatus.discrepancy:
      return colorScheme.error;
  }
}

IconData productStockCountStatusIcon(ProductStockCountStatus status) {
  switch (status) {
    case ProductStockCountStatus.pending:
      return Icons.hourglass_top_rounded;
    case ProductStockCountStatus.matched:
      return Icons.check_circle_rounded;
    case ProductStockCountStatus.discrepancy:
      return Icons.rule_rounded;
  }
}
