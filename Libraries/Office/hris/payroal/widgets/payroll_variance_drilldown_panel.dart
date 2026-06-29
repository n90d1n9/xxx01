import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollVarianceDrilldownPanel extends StatelessWidget {
  final PayrollVarianceDrilldownSummary summary;

  const PayrollVarianceDrilldownPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.manage_search_outlined,
      title: 'Variance drilldown',
      subtitle: '${summary.periodLabel} vs ${summary.baselinePeriodLabel}',
      emptyMessage: 'No material payroll variance drilldowns remain',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Drilldowns',
              value: summary.lines.length.toString(),
            ),
            HrisMetricStripItem(
              label: 'Review',
              value: summary.reviewCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Watch',
              value: summary.watchCount.toString(),
            ),
            HrisMetricStripItem(
              label: 'Variance',
              value: payrollCurrencyFormat.format(
                summary.totalAbsoluteVariance,
              ),
            ),
          ],
        ),
        HrisListSurface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.difference_outlined,
                color: HrisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  summary.nextAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final line in summary.lines) _VarianceDrilldownTile(line: line),
      ],
    );
  }
}

class _VarianceDrilldownTile extends StatelessWidget {
  final PayrollVarianceDrilldownLine line;

  const _VarianceDrilldownTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _signalColor(line.signal);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_scopeIcon(line.scope), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              color: HrisColors.ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${line.scope.label} - ${line.owner}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: HrisColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: line.signal.label, color: color),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetricChip(
                      icon:
                          line.delta >= 0
                              ? Icons.arrow_upward_outlined
                              : Icons.arrow_downward_outlined,
                      label:
                          '${payrollCurrencyFormat.format(line.absoluteDelta)} ${_formatPercent(line.percentChange)}',
                    ),
                    _MetricChip(
                      icon: Icons.payments_outlined,
                      label:
                          'Current ${payrollCurrencyFormat.format(line.currentAmount)}',
                    ),
                    _MetricChip(
                      icon: Icons.history_outlined,
                      label:
                          'Baseline ${payrollCurrencyFormat.format(line.baselineAmount)}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  line.cause,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  line.action,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _formatPercent(double value) {
  final sign = value >= 0 ? '+' : '-';
  return '($sign${(value.abs() * 100).toStringAsFixed(1)}%)';
}

Color _signalColor(PayrollRunComparisonSignal signal) {
  return switch (signal) {
    PayrollRunComparisonSignal.stable => const Color(0xFF15803D),
    PayrollRunComparisonSignal.watch => const Color(0xFFB45309),
    PayrollRunComparisonSignal.review => const Color(0xFFB91C1C),
  };
}

IconData _scopeIcon(PayrollVarianceDrilldownScope scope) {
  return switch (scope) {
    PayrollVarianceDrilldownScope.run => Icons.analytics_outlined,
    PayrollVarianceDrilldownScope.costCenter => Icons.account_tree_outlined,
  };
}
