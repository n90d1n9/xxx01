import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';

import '../utils/product_stock_count_view.dart';

class ProductStockReviewSummaryPanel extends StatelessWidget {
  const ProductStockReviewSummaryPanel({
    super.key,
    required this.summary,
    required this.isLoading,
    required this.onOpenCountQueue,
    this.onRefresh,
  });

  final ProductStockCountSummary summary;
  final bool isLoading;
  final VoidCallback onOpenCountQueue;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Variance Review',
      subtitle:
          isLoading
              ? 'Refreshing count exceptions.'
              : _reviewSummaryLabel(summary),
      leadingIcon: Icons.rule_rounded,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppActionButton(
            label: 'Count queue',
            icon: Icons.fact_check_rounded,
            variant: AppActionButtonVariant.secondary,
            onPressed: onOpenCountQueue,
          ),
          if (onRefresh != null)
            IconButton.outlined(
              tooltip: 'Refresh products',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRefresh,
            ),
        ],
      ),
      child: _ReviewMetrics(summary: summary),
    );
  }
}

class _ReviewMetrics extends StatelessWidget {
  const _ReviewMetrics({required this.summary});

  final ProductStockCountSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metrics = [
      _ReviewMetric(
        label: 'Review',
        value: '${summary.reviewCount}',
        color: colorScheme.primary,
      ),
      _ReviewMetric(
        label: 'Pending',
        value: '${summary.pendingCount}',
        color: Colors.orange,
      ),
      _ReviewMetric(
        label: 'Variance',
        value: '${summary.discrepancyCount}',
        color: colorScheme.error,
      ),
      _ReviewMetric(
        label: 'Units',
        value: '${summary.totalVarianceUnits}',
        color: Colors.blue,
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
                child: _ReviewMetricTile(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _ReviewMetricTile extends StatelessWidget {
  const _ReviewMetricTile({required this.metric});

  final _ReviewMetric metric;

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

class _ReviewMetric {
  const _ReviewMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

String _reviewSummaryLabel(ProductStockCountSummary summary) {
  if (summary.reviewCount == 0) {
    return 'No count exceptions need review.';
  }

  return '${summary.reviewCount} review items, '
      '${summary.discrepancyCount} variance, '
      '${summary.pendingCount} pending count';
}
