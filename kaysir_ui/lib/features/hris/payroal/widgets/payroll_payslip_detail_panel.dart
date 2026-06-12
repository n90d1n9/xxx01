import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollPayslipDetailPanel extends StatelessWidget {
  final PayrollPayslipDetail detail;

  const PayrollPayslipDetailPanel({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final line = detail.line;
    final statusColor = _statusColor(detail.statusLabel);

    return HrisSectionPanel(
      icon: Icons.receipt_long_outlined,
      title: 'Payslip detail',
      subtitle:
          '${detail.packageId} - ${DateFormat('MMM d, yyyy').format(detail.payDate)}',
      children: [
        HrisListSurface(
          child:
              line == null
                  ? _EmptyPayslipDetail(nextAction: detail.nextAction)
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _statusIcon(detail.statusLabel),
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line.employeeName,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleSmall?.copyWith(
                                    color: HrisColors.ink,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${line.statementId} - ${line.position}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: HrisColors.muted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          HrisStatusPill(
                            label: detail.statusLabel,
                            color: statusColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _MetaChip(
                            icon: Icons.outbox_outlined,
                            label: line.channel.label,
                          ),
                          _MetaChip(
                            icon: Icons.alternate_email_outlined,
                            label: line.destinationLabel,
                          ),
                          _MetaChip(
                            icon: Icons.confirmation_number_outlined,
                            label: line.paymentReferenceCode,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      HrisMetricStrip(
                        items: [
                          HrisMetricStripItem(
                            label: 'Gross',
                            value: payrollCurrencyFormat.format(
                              detail.grossAmount,
                            ),
                          ),
                          HrisMetricStripItem(
                            label: 'Adjustments',
                            value: payrollCurrencyFormat.format(
                              detail.adjustmentAmount,
                            ),
                          ),
                          HrisMetricStripItem(
                            label: 'Deductions',
                            value: payrollCurrencyFormat.format(
                              detail.deductionAmount,
                            ),
                          ),
                          HrisMetricStripItem(
                            label: 'Net pay',
                            value: payrollCurrencyFormat.format(
                              detail.netAmount,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            line.hasBlockers
                                ? Icons.report_problem_outlined
                                : Icons.task_alt_outlined,
                            color:
                                line.hasBlockers
                                    ? const Color(0xFFB91C1C)
                                    : HrisColors.primary,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              detail.nextAction,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
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
      ],
    );
  }
}

class _EmptyPayslipDetail extends StatelessWidget {
  final String nextAction;

  const _EmptyPayslipDetail({required this.nextAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: HrisColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            nextAction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

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

Color _statusColor(String statusLabel) {
  return switch (statusLabel) {
    'Published' => const Color(0xFF15803D),
    'Blocked' => const Color(0xFFB91C1C),
    'Ready' => const Color(0xFF2563EB),
    _ => const Color(0xFFB45309),
  };
}

IconData _statusIcon(String statusLabel) {
  return switch (statusLabel) {
    'Published' => Icons.verified_outlined,
    'Blocked' => Icons.warning_amber_outlined,
    'Ready' => Icons.article_outlined,
    _ => Icons.info_outline,
  };
}
