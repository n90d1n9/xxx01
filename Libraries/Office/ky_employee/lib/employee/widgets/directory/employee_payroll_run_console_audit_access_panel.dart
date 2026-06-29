import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_access_models.dart';
import '../../models/employee_payroll_run_console_audit_export_models.dart';
import '../../models/employee_payroll_run_console_audit_handoff_models.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_audit_package_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';

/// Role selector and permission summary for payroll audit close actions.
class EmployeePayrollRunConsoleAuditAccessPanel extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditAccessReview review;
  final ValueChanged<EmployeePayrollRunConsoleAuditRole> onRoleChanged;

  const EmployeePayrollRunConsoleAuditAccessPanel({
    super.key,
    required this.review,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(review);

    return Column(
      key: const ValueKey('employee-payroll-audit-access-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Audit role controls',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(label: review.statusLabel, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          review.role.description,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 10),
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Role', value: review.role.shortLabel),
            HrisMetricStripItem(label: 'Allowed', value: review.allowedLabel),
            HrisMetricStripItem(
              label: 'Export',
              value: review.copyExportPermission.statusLabel,
            ),
            HrisMetricStripItem(
              label: 'Close',
              value: review.submitHandoffPermission.statusLabel,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _AuditGuidanceCallout(guidance: review.guidance),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<EmployeePayrollRunConsoleAuditRole>(
            key: const ValueKey('employee-payroll-audit-role-selector'),
            showSelectedIcon: false,
            segments: [
              for (final role in EmployeePayrollRunConsoleAuditRole.values)
                ButtonSegment(
                  value: role,
                  icon: Icon(_roleIcon(role), size: 18),
                  label: Text(role.shortLabel),
                ),
            ],
            selected: {review.role},
            onSelectionChanged: (selection) => onRoleChanged(selection.single),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            for (final permission in review.permissions)
              _AuditPermissionRow(permission: permission),
          ],
        ),
      ],
    );
  }
}

/// Highlighted next-step guidance for the active payroll audit role.
class _AuditGuidanceCallout extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditGuidance guidance;

  const _AuditGuidanceCallout({required this.guidance});

  @override
  Widget build(BuildContext context) {
    final color =
        guidance.isReady ? const Color(0xFF15803D) : HrisColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_guidanceIcon(guidance), size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        guidance.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: guidance.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  guidance.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact row explaining one payroll audit permission decision.
class _AuditPermissionRow extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditPermission permission;

  const _AuditPermissionRow({required this.permission});

  @override
  Widget build(BuildContext context) {
    final color =
        permission.allowed ? const Color(0xFF15803D) : HrisColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_actionIcon(permission.action), size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  permission.action.label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  permission.reason,
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
          HrisStatusPill(label: permission.statusLabel, color: color),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee payroll audit access panel')
Widget employeePayrollRunConsoleAuditAccessPanelPreview() {
  final package = _readyPackage();
  final handoffReview = EmployeePayrollRunConsoleAuditHandoffReview.fromState(
    package: package,
    draft: EmployeePayrollRunConsoleAuditHandoffDraft(
      reviewer: 'Alya Rahman',
      approver: 'Rafi Pratama',
      dueDate: DateTime(2026, 6, 1),
      note: 'Reviewed payroll evidence before handoff.',
    ),
    handoffs: const [],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditAccessPanel(
          review: EmployeePayrollRunConsoleAuditAccessReview(
            role: EmployeePayrollRunConsoleAuditRole.payrollReviewer,
            exportPreview: EmployeePayrollRunConsoleAuditExportPreview(
              package: package,
              generatedAt: DateTime(2026, 6, 1, 12),
            ),
            handoffReview: handoffReview,
          ),
          onRoleChanged: (_) {},
        ),
      ),
    ),
  );
}

Color _statusColor(EmployeePayrollRunConsoleAuditAccessReview review) {
  if (review.allowedCount == 0) return HrisColors.muted;
  if (review.allowedCount == review.totalCount) return const Color(0xFF15803D);
  return HrisColors.primary;
}

IconData _roleIcon(EmployeePayrollRunConsoleAuditRole role) {
  return switch (role) {
    EmployeePayrollRunConsoleAuditRole.payrollOfficer =>
      Icons.folder_copy_outlined,
    EmployeePayrollRunConsoleAuditRole.payrollReviewer =>
      Icons.fact_check_outlined,
    EmployeePayrollRunConsoleAuditRole.payrollApprover =>
      Icons.verified_user_outlined,
    EmployeePayrollRunConsoleAuditRole.auditor => Icons.visibility_outlined,
  };
}

IconData _actionIcon(EmployeePayrollRunConsoleAuditAction action) {
  return switch (action) {
    EmployeePayrollRunConsoleAuditAction.copyExport => Icons.copy_outlined,
    EmployeePayrollRunConsoleAuditAction.submitHandoff => Icons.outbox_outlined,
    EmployeePayrollRunConsoleAuditAction.approveHandoff =>
      Icons.check_circle_outline,
    EmployeePayrollRunConsoleAuditAction.returnHandoff => Icons.undo_outlined,
  };
}

IconData _guidanceIcon(EmployeePayrollRunConsoleAuditGuidance guidance) {
  final action = guidance.action;
  if (action == null) return Icons.visibility_outlined;
  return _actionIcon(action);
}

EmployeePayrollRunConsoleAuditEvidencePackage _readyPackage() {
  return EmployeePayrollRunConsoleAuditEvidencePackage(
    report: EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: EmployeePayrollRunConsoleAuditSummary(
        events: [
          _previewEvent(
            id: 'prepare',
            type: EmployeePayrollRunConsoleCommandType.prepareExport,
          ),
          _previewEvent(
            id: 'settle',
            type: EmployeePayrollRunConsoleCommandType.settlePayment,
          ),
          _previewEvent(
            id: 'publish',
            type: EmployeePayrollRunConsoleCommandType.publishPayslip,
          ),
          _previewEvent(
            id: 'close',
            type: EmployeePayrollRunConsoleCommandType.closePeriod,
          ),
        ],
      ),
    ),
  );
}

EmployeePayrollRunConsoleAuditEvent _previewEvent({
  required String id,
  required EmployeePayrollRunConsoleCommandType type,
}) {
  return EmployeePayrollRunConsoleAuditEvent(
    id: id,
    runReference: 'RUN-202605-001',
    commandType: type,
    scopeLabel: 'All 5 run employees',
    operatorName: 'Payroll Lead',
    occurredAt: DateTime(2026, 5, 30, 9, 30),
    targetEmployeeCount: 3,
    completedCount: 3,
    skippedCount: 0,
    errors: const [],
    message: '${type.label} audit evidence captured.',
  );
}
