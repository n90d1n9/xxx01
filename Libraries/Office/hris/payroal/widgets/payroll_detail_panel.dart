import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/employee/models/employee.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_detail.dart';
import 'payroll_formatters.dart';

class PayrollDetailPanel extends StatelessWidget {
  final Employee? employee;
  final PayrollDetails? details;
  final bool isPaid;
  final VoidCallback? onProcessPayment;

  const PayrollDetailPanel({
    super.key,
    required this.employee,
    required this.details,
    required this.isPaid,
    required this.onProcessPayment,
  });

  @override
  Widget build(BuildContext context) {
    final employee = this.employee;
    final details = this.details;

    if (employee == null || details == null) {
      return const HrisEmptyState(
        message: 'Select an employee to review payroll details',
      );
    }

    return Container(
      decoration: hrisPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: HrisColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    _initials(employee.name),
                    style: const TextStyle(
                      color: HrisColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        employee.position ?? 'Employee',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HrisColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Gross Salary',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payrollCurrencyFormat.format(details.grossSalary),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _PayrollAmountRow(
                  label: 'Federal Tax',
                  amount: details.federalTax,
                  color: const Color(0xFFDC2626),
                ),
                _PayrollAmountRow(
                  label: 'State Tax',
                  amount: details.stateTax,
                  color: const Color(0xFFEF4444),
                ),
                _PayrollAmountRow(
                  label: 'Social Security',
                  amount: details.socialSecurity,
                  color: const Color(0xFFD97706),
                ),
                _PayrollAmountRow(
                  label: 'Medicare',
                  amount: details.medicare,
                  color: const Color(0xFFF59E0B),
                ),
                _PayrollAmountRow(
                  label: '401(k) Retirement',
                  amount: details.retirement401k,
                  color: const Color(0xFF2563EB),
                ),
                _PayrollAmountRow(
                  label: 'Health Insurance',
                  amount: details.healthInsurance,
                  color: const Color(0xFF0F766E),
                ),
                const Divider(height: 28),
                _PayrollAmountRow(
                  label: 'Net Salary',
                  amount: details.netSalary,
                  color: const Color(0xFF059669),
                  isEmphasized: true,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isPaid ? null : onProcessPayment,
                icon: Icon(
                  isPaid ? Icons.check_circle_outline : Icons.payments_outlined,
                ),
                label: Text(
                  isPaid ? 'Payment Processed' : 'Process Direct Deposit',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayrollAmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isEmphasized;

  const _PayrollAmountRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final style =
        isEmphasized
            ? Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            )
            : Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w600,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: HrisColors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Text(payrollCurrencyFormat.format(amount), style: style),
        ],
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
