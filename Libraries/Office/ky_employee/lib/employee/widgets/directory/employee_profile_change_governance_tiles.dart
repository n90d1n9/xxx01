import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_profile_change_governance_models.dart';

/// Summary metrics for an employee's governed profile change queue.
class EmployeeProfileChangeGovernanceSummaryStrip extends StatelessWidget {
  final EmployeeProfileChangeGovernanceProfile profile;

  const EmployeeProfileChangeGovernanceSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Open', value: '${profile.openCount}'),
        HrisMetricStripItem(label: 'Review', value: '${profile.inReviewCount}'),
        HrisMetricStripItem(
          label: 'Scheduled',
          value: '${profile.scheduledCount}',
        ),
        HrisMetricStripItem(
          label: 'Payroll',
          value: '${profile.payrollImpactCount}',
        ),
      ],
    );
  }
}

/// Governed employee profile change request card with lifecycle actions.
class EmployeeProfileChangeRequestTile extends StatelessWidget {
  final EmployeeProfileChangeRequest request;
  final DateTime asOfDate;
  final VoidCallback onStartReview;
  final VoidCallback onApprove;
  final VoidCallback onSchedule;
  final VoidCallback onApply;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  const EmployeeProfileChangeRequestTile({
    super.key,
    required this.request,
    required this.asOfDate,
    required this.onStartReview,
    required this.onApprove,
    required this.onSchedule,
    required this.onApply,
    required this.onReject,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeProfileChangeStatusColor(request.status);
    final dueLabel = DateFormat('MMM d, yyyy').format(request.effectiveDate);

    return Container(
      key: ValueKey('employee-profile-change-request-${request.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_fieldIcon(request.field), color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.field.label,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.impactLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: request.status.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ProfileChangeMetaChip(
                icon: Icons.event_available_outlined,
                label: 'Effective $dueLabel',
              ),
              _ProfileChangeMetaChip(
                icon: Icons.policy_outlined,
                label: request.riskLabel,
              ),
              _ProfileChangeMetaChip(
                icon: Icons.person_search_outlined,
                label: request.reviewer,
              ),
              _ProfileChangeMetaChip(
                icon: Icons.verified_user_outlined,
                label: request.approver,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.reason,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: ValueKey(
                  'employee-profile-change-start-review-${request.id}',
                ),
                onPressed: request.canStartReview ? onStartReview : null,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Review'),
              ),
              FilledButton.icon(
                key: ValueKey('employee-profile-change-approve-${request.id}'),
                onPressed: request.canApprove ? onApprove : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve'),
              ),
              OutlinedButton.icon(
                key: ValueKey('employee-profile-change-schedule-${request.id}'),
                onPressed: request.canSchedule ? onSchedule : null,
                icon: const Icon(Icons.event_outlined),
                label: const Text('Schedule'),
              ),
              FilledButton.tonalIcon(
                key: ValueKey('employee-profile-change-apply-${request.id}'),
                onPressed: request.canApply(asOfDate) ? onApply : null,
                icon: const Icon(Icons.done_all_outlined),
                label: const Text('Apply'),
              ),
              OutlinedButton.icon(
                key: ValueKey('employee-profile-change-reject-${request.id}'),
                onPressed: request.canReject ? onReject : null,
                icon: const Icon(Icons.block_outlined),
                label: const Text('Reject'),
              ),
              TextButton.icon(
                key: ValueKey('employee-profile-change-cancel-${request.id}'),
                onPressed: request.canCancel ? onCancel : null,
                icon: const Icon(Icons.close_outlined),
                label: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee profile change request tile')
Widget employeeProfileChangeRequestTilePreview() {
  final request = EmployeeProfileChangeRequest(
    id: 'EPC-1-001',
    employeeId: '1',
    employeeName: 'Sarah Johnson',
    field: EmployeeProfileChangeField.manager,
    currentValue: 'Emma Rodriguez',
    proposedValue: 'David Kim',
    effectiveDate: DateTime(2026, 6, 15),
    reason: 'Move reporting line for the new product squad.',
    requester: 'People Operations',
    reviewer: 'HR Business Partner',
    approver: 'People Director',
    createdAt: DateTime(2026, 6, 1),
    status: EmployeeProfileChangeStatus.inReview,
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeProfileChangeRequestTile(
          request: request,
          asOfDate: DateTime(2026, 6, 1),
          onStartReview: () {},
          onApprove: () {},
          onSchedule: () {},
          onApply: () {},
          onReject: () {},
          onCancel: () {},
        ),
      ),
    ),
  );
}

/// Compact metadata chip for employee profile change request details.
class _ProfileChangeMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileChangeMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Status color resolver for employee profile change request lifecycle states.
Color employeeProfileChangeStatusColor(EmployeeProfileChangeStatus status) {
  return switch (status) {
    EmployeeProfileChangeStatus.applied => const Color(0xFF15803D),
    EmployeeProfileChangeStatus.rejected ||
    EmployeeProfileChangeStatus.cancelled => const Color(0xFFB91C1C),
    EmployeeProfileChangeStatus.inReview ||
    EmployeeProfileChangeStatus.approved ||
    EmployeeProfileChangeStatus.scheduled => const Color(0xFFB45309),
    EmployeeProfileChangeStatus.submitted => HrisColors.primary,
  };
}

IconData _fieldIcon(EmployeeProfileChangeField field) {
  return switch (field) {
    EmployeeProfileChangeField.roleTitle => Icons.work_outline,
    EmployeeProfileChangeField.department => Icons.apartment_outlined,
    EmployeeProfileChangeField.manager => Icons.supervisor_account_outlined,
    EmployeeProfileChangeField.employmentStatus => Icons.verified_outlined,
    EmployeeProfileChangeField.payrollGroup =>
      Icons.account_balance_wallet_outlined,
    EmployeeProfileChangeField.jobLevel => Icons.grade_outlined,
    EmployeeProfileChangeField.costCenter => Icons.confirmation_number_outlined,
  };
}
