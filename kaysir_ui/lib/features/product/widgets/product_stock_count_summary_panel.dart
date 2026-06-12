import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';

import '../utils/product_stock_count_view.dart';
import 'product_stock_count_visuals.dart';

class ProductStockCountSummaryPanel extends StatelessWidget {
  const ProductStockCountSummaryPanel({
    super.key,
    required this.summary,
    required this.isLoading,
    required this.onScan,
    required this.onReport,
    this.onRefresh,
  });

  final ProductStockCountSummary summary;
  final bool isLoading;
  final VoidCallback onScan;
  final VoidCallback onReport;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Stock Count Board',
      subtitle:
          isLoading
              ? 'Refreshing the product count queue.'
              : productStockCountSummaryLabel(summary),
      leadingIcon: Icons.fact_check_rounded,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppActionButton(
            label: 'Scan',
            icon: Icons.document_scanner_rounded,
            onPressed: onScan,
          ),
          AppActionButton(
            label: 'Report',
            icon: Icons.assessment_rounded,
            variant: AppActionButtonVariant.secondary,
            onPressed: onReport,
          ),
          if (onRefresh != null)
            IconButton.outlined(
              tooltip: 'Refresh products',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRefresh,
            ),
        ],
      ),
      child: _StockCountMetrics(summary: summary),
    );
  }
}

class _StockCountMetrics extends StatelessWidget {
  const _StockCountMetrics({required this.summary});

  final ProductStockCountSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metrics = [
      _StockCountMetric(
        label: 'Products',
        value: '${summary.totalProducts}',
        color: colorScheme.primary,
      ),
      _StockCountMetric(
        label: 'Pending',
        value: '${summary.pendingCount}',
        color: Colors.orange,
      ),
      _StockCountMetric(
        label: 'Counted',
        value: '${summary.countedCount}',
        color: Colors.green,
      ),
      _StockCountMetric(
        label: 'Variance',
        value: '${summary.discrepancyCount}',
        color: colorScheme.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 620 ? 2 : 4;
        final spacing = 8.0;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width.clamp(120, constraints.maxWidth).toDouble(),
                child: _StockCountMetricTile(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _StockCountMetricTile extends StatelessWidget {
  const _StockCountMetricTile({required this.metric});

  final _StockCountMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: metric.color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockCountMetric {
  const _StockCountMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}
