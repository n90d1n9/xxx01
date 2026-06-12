import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_models.dart';
import 'employee_payroll_run_styles.dart';

class EmployeePayrollRunSummaryStrip extends StatelessWidget {
  final EmployeePayrollRunProfile profile;

  const EmployeePayrollRunSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Gross',
          value: _formatMoney(profile.grossEarnings, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Deductions',
          value: _formatMoney(profile.deductions, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Net pay',
          value: _formatMoney(profile.netPay, profile.currencyCode),
        ),
        HrisMetricStripItem(label: 'Holds', value: '${profile.blockerCount}'),
      ],
    );
  }
}

class EmployeePayrollRunStatusCard extends StatelessWidget {
  final EmployeePayrollRunProfile profile;

  const EmployeePayrollRunStatusCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final color = employeePayrollRunStatusColor(profile.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Run readiness',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: profile.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: _progressValue(profile),
            color: color,
            label: profile.nextAction,
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
                icon: Icons.event_busy_outlined,
                label: 'Cutoff ${_formatDate(profile.cutoffDate)}',
              ),
              _MetaChip(
                icon: Icons.payments_outlined,
                label: 'Pay ${_formatDate(profile.payDate)}',
                color: color,
              ),
              if (profile.reviewer.isNotEmpty)
                _MetaChip(icon: Icons.person_outline, label: profile.reviewer),
              if (profile.exportBatchId.isNotEmpty)
                _MetaChip(
                  icon: Icons.ios_share_outlined,
                  label: profile.exportBatchId,
                  color: const Color(0xFF15803D),
                ),
              if (profile.payslipVisible)
                const _MetaChip(
                  icon: Icons.visibility_outlined,
                  label: 'Payslip visible',
                  color: Color(0xFF2563EB),
                ),
            ],
          ),
        ],
      ),
    );
  }

  double _progressValue(EmployeePayrollRunProfile profile) {
    return switch (profile.status) {
      EmployeePayrollRunStatus.blocked => 0.25,
      EmployeePayrollRunStatus.draft => 0.55,
      EmployeePayrollRunStatus.ready => 0.8,
      EmployeePayrollRunStatus.exported => 1,
    };
  }
}

class EmployeePayrollRunLineTile extends StatelessWidget {
  final EmployeePayrollRunLine line;

  const EmployeePayrollRunLineTile({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final color = employeePayrollRunLineStatusColor(line.status);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              employeePayrollRunLineTypeIcon(line.type),
              color: color,
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
                    HrisStatusPill(label: line.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  line.detail,
                  maxLines: 2,
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
                      icon: Icons.category_outlined,
                      label: line.type.label,
                    ),
                    _MetaChip(
                      icon: Icons.attach_money_outlined,
                      label: _formatSignedMoney(line.amount, line.currencyCode),
                      color: line.isDeduction ? const Color(0xFFB91C1C) : null,
                    ),
                    if (line.taxable)
                      const _MetaChip(
                        icon: Icons.receipt_outlined,
                        label: 'Taxable',
                        color: Color(0xFF2563EB),
                      ),
                    if (!line.countsInNetPay &&
                        line.type != EmployeePayrollRunLineType.hold)
                      const _MetaChip(
                        icon: Icons.info_outline,
                        label: 'Cost only',
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

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String _formatShortDate(DateTime date) {
  return DateFormat('MMM d').format(date);
}
