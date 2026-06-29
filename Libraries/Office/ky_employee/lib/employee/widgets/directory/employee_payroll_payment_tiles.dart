import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_payment_models.dart';
import 'employee_payroll_payment_styles.dart';

class EmployeePayrollPaymentSummaryStrip extends StatelessWidget {
  final EmployeePayrollPaymentProfile profile;

  const EmployeePayrollPaymentSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Net pay',
          value: _formatMoney(profile.netPay, profile.currencyCode),
        ),
        HrisMetricStripItem(
          label: 'Method',
          value: profile.paymentMethod.label,
        ),
        HrisMetricStripItem(
          label: 'Instructions',
          value:
              '${profile.settledInstructionCount}/${profile.instructions.length}',
        ),
        HrisMetricStripItem(
          label: 'Blockers',
          value: '${profile.attentionCount}',
        ),
      ],
    );
  }
}

class EmployeePayrollPaymentStatusCard extends StatelessWidget {
  final EmployeePayrollPaymentProfile profile;

  const EmployeePayrollPaymentStatusCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final color = employeePayrollPaymentStatusColor(profile.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payment readiness',
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
                icon: Icons.payments_outlined,
                label: 'Pay ${_formatDate(profile.payDate)}',
                color: color,
              ),
              _MetaChip(
                icon: Icons.account_balance_outlined,
                label: profile.bankName,
              ),
              _MetaChip(
                icon: Icons.credit_card_outlined,
                label: profile.maskedAccount,
              ),
              _MetaChip(icon: Icons.route_outlined, label: profile.routingCode),
              if (profile.exportBatchId.isNotEmpty)
                _MetaChip(
                  icon: Icons.ios_share_outlined,
                  label: profile.exportBatchId,
                  color: const Color(0xFF15803D),
                ),
              if (profile.paymentReference.isNotEmpty)
                _MetaChip(
                  icon: Icons.tag_outlined,
                  label: profile.paymentReference,
                  color: const Color(0xFF15803D),
                ),
              if (profile.paidAt != null)
                _MetaChip(
                  icon: Icons.event_available_outlined,
                  label: 'Paid ${_formatDate(profile.paidAt!)}',
                  color: const Color(0xFF15803D),
                ),
            ],
          ),
        ],
      ),
    );
  }

  double _progressValue(EmployeePayrollPaymentProfile profile) {
    return switch (profile.status) {
      EmployeePayrollPaymentStatus.blocked => 0.2,
      EmployeePayrollPaymentStatus.ready => 0.55,
      EmployeePayrollPaymentStatus.held => 0.45,
      EmployeePayrollPaymentStatus.scheduled => 0.8,
      EmployeePayrollPaymentStatus.paid => 1,
    };
  }
}

class EmployeePayrollPaymentInstructionTile extends StatelessWidget {
  final EmployeePayrollPaymentInstruction instruction;

  const EmployeePayrollPaymentInstructionTile({
    super.key,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeePayrollPaymentInstructionStatusColor(
      instruction.status,
    );

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
            child: Icon(Icons.account_balance_wallet_outlined, color: color),
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
                        instruction.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HrisStatusPill(
                      label: instruction.status.label,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  instruction.detail,
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
                      icon: Icons.payments_outlined,
                      label: _formatMoney(
                        instruction.amount,
                        instruction.currencyCode,
                      ),
                      color: const Color(0xFF15803D),
                    ),
                    _MetaChip(
                      icon: Icons.swap_horiz_outlined,
                      label: instruction.method.label,
                    ),
                    _MetaChip(
                      icon: Icons.account_balance_outlined,
                      label: instruction.bankName,
                    ),
                    _MetaChip(
                      icon: Icons.credit_card_outlined,
                      label: instruction.maskedAccount,
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

String _formatDate(DateTime value) {
  return DateFormat('d MMM y').format(value);
}
