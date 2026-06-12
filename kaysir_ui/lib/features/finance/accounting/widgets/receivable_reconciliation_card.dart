import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../states/receivable_reconciliation_provider.dart';
import 'receivable_reconciliation_detail_dialog.dart';

class ReceivableReconciliationCard extends ConsumerWidget {
  const ReceivableReconciliationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reconciliation = ref.watch(receivableReconciliationProvider);
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );
    final statusColor =
        reconciliation.isBalanced ? Colors.teal : Colors.deepOrange;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fact_check_outlined, color: statusColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AR Reconciliation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppStatusPill(
                  label: reconciliation.isBalanced ? 'Balanced' : 'Variance',
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'View reconciliation detail',
                  onPressed: () => _showDetail(context),
                  icon: const Icon(Icons.open_in_new_outlined),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 680;
                final metrics = [
                  _MetricData(
                    label: 'Subledger',
                    value: currency.format(reconciliation.subledgerBalance),
                  ),
                  _MetricData(
                    label: 'GL AR',
                    value: currency.format(reconciliation.ledgerBalance),
                  ),
                  _MetricData(
                    label: 'Variance',
                    value: currency.format(reconciliation.variance),
                    valueColor: statusColor,
                  ),
                  _MetricData(
                    label: 'Overdue',
                    value: currency.format(reconciliation.overdueBalance),
                  ),
                ];

                if (isCompact) {
                  return Column(
                    children: [
                      for (final metric in metrics) ...[
                        _ReconciliationMetric(metric: metric),
                        if (metric != metrics.last) const SizedBox(height: 10),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    for (final metric in metrics) ...[
                      Expanded(child: _ReconciliationMetric(metric: metric)),
                      if (metric != metrics.last) const SizedBox(width: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReceivableReconciliationDetailDialog(),
    );
  }
}

class _ReconciliationMetric extends StatelessWidget {
  final _MetricData metric;

  const _ReconciliationMetric({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(metric.label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                metric.value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: metric.valueColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricData({
    required this.label,
    required this.value,
    this.valueColor,
  });
}
