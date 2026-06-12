import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_variance_models.dart';
import 'employee_payroll_variance_styles.dart';

class EmployeePayrollVarianceSummaryStrip extends StatelessWidget {
  final EmployeePayrollVarianceProfile profile;

  const EmployeePayrollVarianceSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Baseline',
          value: _formatMoney(profile.baselineGrossPay, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Projected',
          value: _formatMoney(profile.projectedGrossPay, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Variance',
          value: _formatSignedMoney(
            profile.varianceAmount,
            profile.currencyCode,
          ),
        ),
        HrisMetricStripItem(
          label: 'Attention',
          value: '${profile.attentionCount}',
        ),
      ],
    );
  }
}

class EmployeePayrollVariancePeriodCard extends StatelessWidget {
  final EmployeePayrollVarianceProfile profile;

  const EmployeePayrollVariancePeriodCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final color =
        profile.varianceRiskCount > 0
            ? const Color(0xFFB91C1C)
            : profile.isWithinTolerance
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Variance tolerance',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: profile.isWithinTolerance ? 'Within 3%' : 'Review',
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: (1 - profile.variancePercent.abs()).clamp(0, 1).toDouble(),
            color: color,
            label:
                '${(profile.variancePercent * 100).toStringAsFixed(1)}% variance against baseline gross pay',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.date_range_outlined,
                label:
                    '${_formatShortDate(profile.periodStart)} - ${_formatShortDate(profile.periodEnd)}',
              ),
              _MetaChip(
                icon: Icons.payments_outlined,
                label: '${profile.monetaryLineCount} monetary item',
              ),
              _MetaChip(
                icon: Icons.rule_outlined,
                label: '${profile.approvalRequiredCount} approval',
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeePayrollVarianceLineTile extends StatelessWidget {
  final EmployeePayrollVarianceLine line;
  final VoidCallback onReview;
  final VoidCallback onApprove;
  final VoidCallback onExclude;
  final VoidCallback onReopen;

  const EmployeePayrollVarianceLineTile({
    super.key,
    required this.line,
    required this.onReview,
    required this.onApprove,
    required this.onExclude,
    required this.onReopen,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = employeePayrollVarianceSeverityColor(line.severity);
    final statusColor = employeePayrollVarianceStatusColor(line.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeePayrollVarianceSourceIcon(line.source),
              color: severityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: line.status.label,
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  line.detail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.source_outlined,
                      label: line.source.label,
                    ),
                    _MetaChip(
                      icon: Icons.attach_money_outlined,
                      label: _formatSignedMoney(line.amount, line.currencyCode),
                      color: line.amount < 0 ? const Color(0xFFB91C1C) : null,
                    ),
                    _MetaChip(
                      icon: Icons.priority_high_outlined,
                      label: line.severity.label,
                      color: severityColor,
                    ),
                    _MetaChip(icon: Icons.person_outline, label: line.owner),
                    if (line.taxableImpact)
                      const _MetaChip(
                        icon: Icons.receipt_outlined,
                        label: 'Taxable',
                        color: Color(0xFF2563EB),
                      ),
                    if (line.requiresApproval)
                      const _MetaChip(
                        icon: Icons.rule_outlined,
                        label: 'Approval',
                        color: Color(0xFFB45309),
                      ),
                    if (!line.isClosed)
                      OutlinedButton.icon(
                        onPressed:
                            line.status == EmployeePayrollVarianceStatus.open
                                ? onReview
                                : null,
                        icon: const Icon(Icons.manage_search_outlined),
                        label: const Text('Review'),
                      ),
                    if (!line.isClosed)
                      FilledButton.tonalIcon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Approve'),
                      ),
                    if (!line.isClosed)
                      TextButton.icon(
                        onPressed: onExclude,
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text('Exclude'),
                      ),
                    if (line.isClosed)
                      TextButton.icon(
                        onPressed: onReopen,
                        icon: const Icon(Icons.restart_alt_outlined),
                        label: const Text('Reopen'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resolvedColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: resolvedColor),
          const SizedBox(width: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: resolvedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatMoney(double value, String currencyCode) {
  return NumberFormat.compactCurrency(
    symbol: '$currencyCode ',
    decimalDigits: 1,
  ).format(value);
}

String _formatSignedMoney(double value, String currencyCode) {
  if (value == 0) return 'No cash impact';
  final formatted = _formatMoney(value.abs(), currencyCode);
  return value > 0 ? '+$formatted' : '-$formatted';
}

String _formatShortDate(DateTime date) {
  return DateFormat('MMM d').format(date);
}
