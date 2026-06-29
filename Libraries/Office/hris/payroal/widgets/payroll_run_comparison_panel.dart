import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollRunComparisonPanel extends StatelessWidget {
  final PayrollRunComparisonSummary summary;

  const PayrollRunComparisonPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color = _signalColor(summary.signal);

    return HrisSectionPanel(
      icon: Icons.compare_arrows_outlined,
      title: 'Run comparison',
      subtitle: '${summary.periodLabel} vs ${summary.baselinePeriodLabel}',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HrisStatusPill(label: summary.signal.label, color: color),
                  _MetricChip(
                    icon: Icons.manage_search_outlined,
                    label: '${summary.reviewCount} review',
                  ),
                  _MetricChip(
                    icon: Icons.visibility_outlined,
                    label: '${summary.watchCount} watch',
                  ),
                  _MetricChip(
                    icon: Icons.account_tree_outlined,
                    label: '${summary.costCenters.length} centers',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_signalIcon(summary.signal), color: color, size: 19),
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
            ],
          ),
        ),
        HrisSummaryGrid(metrics: summary.metrics.map(_metricCard).toList()),
        HrisListSurface(
          child: Column(
            children: [
              for (
                var index = 0;
                index < summary.costCenters.length;
                index++
              ) ...[
                _CostCenterComparisonRow(line: summary.costCenters[index]),
                if (index < summary.costCenters.length - 1)
                  const Divider(height: 20, color: HrisColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CostCenterComparisonRow extends StatelessWidget {
  final PayrollRunComparisonCostCenterLine line;

  const _CostCenterComparisonRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final color = _signalColor(line.signal);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_signalIcon(line.signal), color: color, size: 19),
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
                    child: Text(
                      line.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HrisStatusPill(label: line.signal.label, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _MetricChip(
                    icon: Icons.payments_outlined,
                    label:
                        '${_signedCurrency(line.grossDelta)} ${_formatPercent(line.grossPercentChange)}',
                  ),
                  _MetricChip(
                    icon: Icons.people_alt_outlined,
                    label:
                        '${_signedCount(line.employeeDelta)} headcount change',
                  ),
                  _MetricChip(
                    icon: Icons.history_outlined,
                    label:
                        'Prior ${payrollCurrencyFormat.format(line.baselineGrossPayroll)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

HrisSummaryMetric _metricCard(PayrollRunComparisonMetric metric) {
  return HrisSummaryMetric(
    title: metric.label,
    value: _formatValue(metric.currentValue, metric.type),
    detail:
        '${_formatDelta(metric.delta, metric.type)} ${_formatPercent(metric.percentChange)}',
    icon: _metricIcon(metric.id),
    color: _signalColor(metric.signal),
  );
}

String _formatValue(double value, PayrollRunComparisonMetricType type) {
  return switch (type) {
    PayrollRunComparisonMetricType.count => value.toInt().toString(),
    PayrollRunComparisonMetricType.currency => payrollCurrencyFormat.format(
      value,
    ),
  };
}

String _formatDelta(double value, PayrollRunComparisonMetricType type) {
  return switch (type) {
    PayrollRunComparisonMetricType.count => _signedCount(value.toInt()),
    PayrollRunComparisonMetricType.currency => _signedCurrency(value),
  };
}

String _signedCount(int value) {
  if (value == 0) return '0';
  return value > 0 ? '+$value' : '$value';
}

String _signedCurrency(double value) {
  if (value == 0) return payrollCurrencyFormat.format(0);
  final sign = value > 0 ? '+' : '-';
  return '$sign${payrollCurrencyFormat.format(value.abs())}';
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

IconData _signalIcon(PayrollRunComparisonSignal signal) {
  return switch (signal) {
    PayrollRunComparisonSignal.stable => Icons.check_circle_outline,
    PayrollRunComparisonSignal.watch => Icons.trending_up_outlined,
    PayrollRunComparisonSignal.review => Icons.manage_search_outlined,
  };
}

IconData _metricIcon(String id) {
  return switch (id) {
    'headcount' => Icons.people_alt_outlined,
    'gross-payroll' => Icons.account_balance_wallet_outlined,
    'net-payroll' => Icons.payments_outlined,
    'deductions' => Icons.receipt_long_outlined,
    'adjustments' => Icons.tune_outlined,
    _ => Icons.compare_arrows_outlined,
  };
}
