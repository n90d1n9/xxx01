import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_reimbursement_models.dart';
import 'employee_reimbursement_styles.dart';

class EmployeeReimbursementSummaryStrip extends StatelessWidget {
  final EmployeeReimbursementProfile profile;

  const EmployeeReimbursementSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Submitted',
          value: '${profile.submittedCount}',
        ),
        HrisMetricStripItem(
          label: 'Approved',
          value: '${profile.approvedCount}',
        ),
        HrisMetricStripItem(
          label: 'Receipts',
          value: '${profile.missingReceiptCount}',
        ),
        HrisMetricStripItem(
          label: 'Low',
          value: '${profile.lowAllowanceCount}',
        ),
      ],
    );
  }
}

class EmployeeExpenseAllowanceCard extends StatelessWidget {
  final List<EmployeeExpenseAllowance> allowances;

  const EmployeeExpenseAllowanceCard({super.key, required this.allowances});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allowance budgets',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ..._allowanceRows(allowances),
        ],
      ),
    );
  }

  List<Widget> _allowanceRows(List<EmployeeExpenseAllowance> allowances) {
    final rows = <Widget>[];
    for (var index = 0; index < allowances.length; index++) {
      if (index > 0) rows.add(const SizedBox(height: 12));
      rows.add(_ExpenseAllowanceRow(allowance: allowances[index]));
    }
    return rows;
  }
}

class EmployeeExpenseClaimTile extends StatelessWidget {
  final EmployeeExpenseClaim claim;
  final VoidCallback onAttachReceipt;
  final VoidCallback onApprove;
  final VoidCallback onReimburse;
  final VoidCallback onReject;

  const EmployeeExpenseClaimTile({
    super.key,
    required this.claim,
    required this.onAttachReceipt,
    required this.onApprove,
    required this.onReimburse,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeExpenseClaimStatusColor(claim.status);
    final receiptColor = employeeExpenseReceiptStatusColor(claim.receiptStatus);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  employeeExpenseCategoryIcon(claim.category),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.merchant,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${claim.category.label} - ${formatExpenseMoney(claim.amount, claim.currencyCode)}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: claim.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            claim.description,
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
                icon: Icons.event_outlined,
                label: 'Incurred ${_formatDate(claim.incurredOn)}',
              ),
              _MetaChip(
                icon: Icons.inbox_outlined,
                label: 'Submitted ${_formatDate(claim.submittedAt)}',
              ),
              _MetaChip(
                icon: Icons.attachment_outlined,
                label: claim.receiptStatus.label,
                color: receiptColor,
              ),
            ],
          ),
          if (claim.canAttachReceipt ||
              claim.canApprove ||
              claim.canReimburse ||
              claim.canReject) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (claim.canReject)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Reject'),
                  ),
                if (claim.canAttachReceipt)
                  FilledButton.tonalIcon(
                    onPressed: onAttachReceipt,
                    icon: const Icon(Icons.attach_file_outlined),
                    label: const Text('Attach receipt'),
                  ),
                if (claim.canApprove)
                  FilledButton.tonalIcon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Approve'),
                  ),
                if (claim.canReimburse)
                  FilledButton.icon(
                    onPressed: onReimburse,
                    icon: const Icon(Icons.price_check_outlined),
                    label: const Text('Reimburse'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseAllowanceRow extends StatelessWidget {
  final EmployeeExpenseAllowance allowance;

  const _ExpenseAllowanceRow({required this.allowance});

  @override
  Widget build(BuildContext context) {
    final color =
        allowance.isLow ? const Color(0xFFB45309) : HrisColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              employeeExpenseCategoryIcon(allowance.category),
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                allowance.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(
              label: formatExpenseMoney(
                allowance.remainingAmount,
                allowance.currencyCode,
              ),
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 6),
        HrisProgressBar(
          value: allowance.utilizationRatio,
          color: color,
          label:
              '${formatExpenseMoney(allowance.usedAmount, allowance.currencyCode)} used, '
              '${formatExpenseMoney(allowance.pendingAmount, allowance.currencyCode)} pending',
        ),
      ],
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
    final chipColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String formatExpenseMoney(double amount, String currencyCode) {
  final formatter = NumberFormat.decimalPattern();
  return '$currencyCode ${formatter.format(amount.round())}';
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}
