import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_models.dart';
import 'employee_payroll_styles.dart';

class EmployeePayrollSummaryStrip extends StatelessWidget {
  final EmployeePayrollProfile profile;

  const EmployeePayrollSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Bank',
          value: profile.bankAccount.verificationStatus.label,
        ),
        HrisMetricStripItem(
          label: 'Tax',
          value: profile.taxProfile.status.label,
        ),
        HrisMetricStripItem(
          label: 'Submitted',
          value: '${profile.submittedChangeCount}',
        ),
        HrisMetricStripItem(
          label: 'Approved',
          value: '${profile.approvedChangeCount}',
        ),
      ],
    );
  }
}

class EmployeePayrollBankAccountCard extends StatelessWidget {
  final EmployeePayrollBankAccount bankAccount;
  final VoidCallback onVerify;

  const EmployeePayrollBankAccountCard({
    super.key,
    required this.bankAccount,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeBankVerificationStatusColor(
      bankAccount.verificationStatus,
    );

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: Icons.account_balance_outlined,
            title: bankAccount.bankName,
            subtitle: '${bankAccount.maskedAccount} - ${bankAccount.country}',
            color: color,
            status: HrisStatusPill(
              label: bankAccount.verificationStatus.label,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.route_outlined,
                label: bankAccount.routingCode,
              ),
              _MetaChip(
                icon: Icons.verified_outlined,
                label:
                    bankAccount.lastVerifiedAt == null
                        ? 'Never verified'
                        : 'Verified ${_formatDate(bankAccount.lastVerifiedAt!)}',
              ),
            ],
          ),
          if (bankAccount.needsAttention) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onVerify,
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Mark verified'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmployeePayrollTaxProfileCard extends StatelessWidget {
  final EmployeePayrollTaxProfile taxProfile;
  final VoidCallback onMarkCurrent;

  const EmployeePayrollTaxProfileCard({
    super.key,
    required this.taxProfile,
    required this.onMarkCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeTaxFormStatusColor(taxProfile.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: Icons.receipt_long_outlined,
            title: taxProfile.formType,
            subtitle: '${taxProfile.taxIdMasked} - ${taxProfile.filingStatus}',
            color: color,
            status: HrisStatusPill(
              label: taxProfile.status.label,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.group_outlined,
                label: '${taxProfile.allowanceCount} allowance',
              ),
              _MetaChip(
                icon: Icons.update_outlined,
                label: 'Updated ${_formatDate(taxProfile.lastUpdatedAt)}',
              ),
            ],
          ),
          if (taxProfile.needsAttention) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onMarkCurrent,
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Mark current'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmployeePayrollScheduleCard extends StatelessWidget {
  final EmployeePayrollSchedule schedule;
  final DateTime asOfDate;

  const EmployeePayrollScheduleCard({
    super.key,
    required this.schedule,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    final cutoffSoon = schedule.isCutoffSoon(asOfDate);
    final color = cutoffSoon ? const Color(0xFFB45309) : HrisColors.primary;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeePaymentMethodIcon(schedule.paymentMethod),
            title: schedule.payGroup,
            subtitle: '${schedule.payCycle} - ${schedule.currencyCode}',
            color: color,
            status: HrisStatusPill(
              label: schedule.paymentMethod.label,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.payments_outlined,
                label: 'Next pay ${_formatDate(schedule.nextPayDate)}',
                color: color,
              ),
              _MetaChip(
                icon: Icons.event_busy_outlined,
                label: 'Cutoff ${_formatDate(schedule.cutoffDate)}',
                color: cutoffSoon ? color : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeePayrollChangeRequestTile extends StatelessWidget {
  final EmployeePayrollChangeRequest request;
  final VoidCallback onApprove;
  final VoidCallback onApply;
  final VoidCallback onReject;

  const EmployeePayrollChangeRequestTile({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onApply,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeePayrollChangeStatusColor(request.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeePayrollChangeTypeIcon(request.type),
            title: request.title,
            subtitle: '${request.type.label} - ${request.requestedBy}',
            color: color,
            status: HrisStatusPill(label: request.status.label, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            request.detail,
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
                icon: Icons.event_available_outlined,
                label: 'Effective ${_formatDate(request.effectiveDate)}',
              ),
              _MetaChip(
                icon: Icons.inbox_outlined,
                label: 'Submitted ${_formatDate(request.submittedAt)}',
              ),
            ],
          ),
          if (request.canApprove || request.canApply || request.canReject) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.canReject) ...[
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                ],
                if (request.canApprove)
                  FilledButton.tonalIcon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Approve'),
                  ),
                if (request.canApply)
                  FilledButton.icon(
                    onPressed: onApply,
                    icon: const Icon(Icons.done_all_outlined),
                    label: const Text('Apply'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget status;

  const _TileHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        status,
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

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}
