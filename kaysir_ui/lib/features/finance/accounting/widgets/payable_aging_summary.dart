import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/payable_aging.dart';
import '../states/invoice_filter_provider.dart';
import '../states/payable_aging_provider.dart';

class PayableAgingSummaryStrip extends ConsumerWidget {
  const PayableAgingSummaryStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(payableAgingSummaryProvider);
    final selectedBucketId = ref.watch(
      invoiceFilterProvider.select((filter) => filter.agingBucketId),
    );
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AgingHeader(summary: summary, currency: currency),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 720;
                final compactWidth =
                    (constraints.maxWidth - 12).clamp(220.0, 320.0).toDouble();
                final itemWidth =
                    isCompact ? compactWidth : (constraints.maxWidth - 48) / 5;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final bucket in summary.buckets)
                      _AgingBucketTile(
                        bucket: bucket,
                        currency: currency,
                        isSelected: bucket.id == selectedBucketId,
                        onTap: () => _toggleBucketFilter(ref, bucket.id),
                        width: itemWidth,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBucketFilter(WidgetRef ref, String bucketId) {
    final currentFilter = ref.read(invoiceFilterProvider);
    final nextBucketId =
        currentFilter.agingBucketId == bucketId ? null : bucketId;
    ref.read(invoiceFilterProvider.notifier).state = currentFilter
        .withAgingBucket(nextBucketId);
  }
}

class _AgingHeader extends StatelessWidget {
  final PayableAgingSummary summary;
  final NumberFormat currency;

  const _AgingHeader({required this.summary, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              'AP Aging',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
        final metrics = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderMetric(
              label: 'Open',
              value: summary.openBillCount.toString(),
            ),
            const SizedBox(width: 16),
            _HeaderMetric(
              label: 'Overdue',
              value: currency.format(summary.overdueAmount),
            ),
          ],
        );

        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 8), metrics],
          );
        }

        return Row(children: [Expanded(child: title), metrics]);
      },
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AgingBucketTile extends StatelessWidget {
  final PayableAgingBucket bucket;
  final NumberFormat currency;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _AgingBucketTile({
    required this.bucket,
    required this.currency,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isSelected
            ? theme.colorScheme.primary
            : _bucketColor(theme.colorScheme, bucket.id);

    return SizedBox(
      width: width,
      child: Tooltip(
        message:
            isSelected
                ? 'Clear ${bucket.label} aging filter'
                : 'Show ${bucket.label} bills',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: isSelected ? 0.12 : 0.08),
              border: Border.all(
                color: color.withValues(alpha: isSelected ? 0.64 : 0.22),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bucket.label,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 28,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currency.format(bucket.amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _billCountLabel(bucket.billCount),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _bucketColor(ColorScheme colorScheme, String bucketId) {
    switch (bucketId) {
      case PayableAgingBucketIds.current:
        return Colors.teal;
      case PayableAgingBucketIds.overdue1To30:
        return Colors.amber.shade700;
      case PayableAgingBucketIds.overdue31To60:
        return Colors.deepOrange;
      case PayableAgingBucketIds.overdue61To90:
        return Colors.red;
      case PayableAgingBucketIds.overdue90Plus:
        return Colors.purple;
      default:
        return colorScheme.primary;
    }
  }

  String _billCountLabel(int count) {
    return count == 1 ? '1 bill' : '$count bills';
  }
}
