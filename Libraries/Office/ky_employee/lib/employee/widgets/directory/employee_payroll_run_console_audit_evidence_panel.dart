import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_audit_package_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';
import 'employee_payroll_run_console_audit_package_panel.dart';

/// Compact payroll console audit evidence summary for close review.
class EmployeePayrollRunConsoleAuditEvidencePanel extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditEvidenceReport report;

  const EmployeePayrollRunConsoleAuditEvidencePanel({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(report.status);
    final evidencePackage = EmployeePayrollRunConsoleAuditEvidencePackage(
      report: report,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_statusIcon(report.status), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Audit evidence status',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: report.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report.headline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  report.nextAction,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _EvidenceMetaLabel(
                      icon: Icons.badge_outlined,
                      label: report.runReferenceLabel,
                    ),
                    _EvidenceMetaLabel(
                      icon: Icons.person_outline,
                      label: report.operatorLabel,
                    ),
                    _EvidenceMetaLabel(
                      icon: Icons.checklist_outlined,
                      label: report.coverageLabel,
                    ),
                    _EvidenceMetaLabel(
                      icon: Icons.history_outlined,
                      label: report.latestLabel,
                    ),
                  ],
                ),
                EmployeePayrollRunConsoleAuditPackagePanel(
                  package: evidencePackage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Metadata label used by the payroll console audit evidence summary.
class _EvidenceMetaLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EvidenceMetaLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HrisColors.muted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Employee payroll run console audit evidence')
Widget employeePayrollRunConsoleAuditEvidencePanelPreview() {
  final summary = EmployeePayrollRunConsoleAuditSummary(
    events: [
      EmployeePayrollRunConsoleAuditEvent(
        id: 'payroll-console-audit-1',
        runReference: 'RUN-202605-001',
        commandType: EmployeePayrollRunConsoleCommandType.prepareExport,
        scopeLabel: 'All 5 run employees',
        operatorName: 'Payroll Lead',
        occurredAt: DateTime(2026, 5, 30, 9, 30),
        targetEmployeeCount: 5,
        completedCount: 3,
        skippedCount: 2,
        errors: const [],
        message: '3 employees prepared and exported, 2 skipped.',
      ),
      EmployeePayrollRunConsoleAuditEvent(
        id: 'payroll-console-audit-2',
        runReference: 'RUN-202605-001',
        commandType: EmployeePayrollRunConsoleCommandType.settlePayment,
        scopeLabel: 'All 5 run employees',
        operatorName: 'Payroll Lead',
        occurredAt: DateTime(2026, 5, 30, 10, 15),
        targetEmployeeCount: 5,
        completedCount: 0,
        skippedCount: 5,
        errors: const ['Maya Santoso: Verify bank account first.'],
        message: 'Settle pay could not update employees.',
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditEvidencePanel(
          report: EmployeePayrollRunConsoleAuditEvidenceReport(
            summary: summary,
          ),
        ),
      ),
    ),
  );
}

IconData _statusIcon(EmployeePayrollRunConsoleAuditEvidenceStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditEvidenceStatus.empty => Icons.info_outline,
    EmployeePayrollRunConsoleAuditEvidenceStatus.ready =>
      Icons.verified_outlined,
    EmployeePayrollRunConsoleAuditEvidenceStatus.reviewNeeded =>
      Icons.rule_folder_outlined,
    EmployeePayrollRunConsoleAuditEvidenceStatus.noChange =>
      Icons.remove_done_outlined,
  };
}

Color _statusColor(EmployeePayrollRunConsoleAuditEvidenceStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditEvidenceStatus.empty => HrisColors.muted,
    EmployeePayrollRunConsoleAuditEvidenceStatus.ready => const Color(
      0xFF15803D,
    ),
    EmployeePayrollRunConsoleAuditEvidenceStatus.reviewNeeded => const Color(
      0xFFB45309,
    ),
    EmployeePayrollRunConsoleAuditEvidenceStatus.noChange => HrisColors.muted,
  };
}
