import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_detail.dart';
import 'payroll_formatters.dart';

class PayrollSummaryPanel extends StatelessWidget {
  final PayrollSummary summary;

  const PayrollSummaryPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: hrisPanelDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: HrisColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      color: HrisColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'March 2025 Payroll',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Payment date: March 15, 2025',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: HrisColors.muted),
                        ),
                      ],
                    ),
                  ),
                  HrisStatusPill(
                    label:
                        '${(summary.completionRate * 100).toStringAsFixed(0)}% processed',
                    color:
                        summary.pendingCount == 0
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              HrisProgressBar(
                value: summary.completionRate,
                color: HrisColors.primary,
                label:
                    '${summary.paidCount}/${summary.employeeCount} employees paid',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HrisSummaryGrid(
          metrics: [
            HrisSummaryMetric(
              title: 'Gross payroll',
              value: payrollCurrencyFormat.format(summary.totalGross),
              detail: '${summary.employeeCount} employees',
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF2563EB),
            ),
            HrisSummaryMetric(
              title: 'Net payroll',
              value: payrollCurrencyFormat.format(summary.totalNet),
              detail: 'direct deposit',
              icon: Icons.payments_outlined,
              color: const Color(0xFF059669),
            ),
            HrisSummaryMetric(
              title: 'Deductions',
              value: payrollCurrencyFormat.format(summary.totalDeductions),
              detail: 'taxes and benefits',
              icon: Icons.receipt_long_outlined,
              color: const Color(0xFFD97706),
            ),
            HrisSummaryMetric(
              title: 'Pending',
              value: '${summary.pendingCount}',
              detail: 'payments left',
              icon: Icons.pending_actions_outlined,
              color: const Color(0xFF7C3AED),
            ),
          ],
        ),
      ],
    );
  }
}
