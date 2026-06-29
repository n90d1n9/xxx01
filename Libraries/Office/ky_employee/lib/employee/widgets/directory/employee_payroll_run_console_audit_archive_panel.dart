import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_archive_models.dart';
import '../../models/employee_payroll_run_console_audit_decision_models.dart';
import '../../models/employee_payroll_run_console_audit_export_models.dart';
import '../../models/employee_payroll_run_console_audit_handoff_models.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_audit_package_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';

/// Archive readiness panel for an approved payroll close evidence package.
class EmployeePayrollRunConsoleAuditArchivePanel extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditArchivePack pack;

  const EmployeePayrollRunConsoleAuditArchivePanel({
    super.key,
    required this.pack,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(pack.status);

    return Column(
      key: const ValueKey('employee-payroll-audit-archive-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Payroll close archive pack',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(label: pack.statusLabel, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          pack.actionLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 10),
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Package', value: pack.packageLabel),
            HrisMetricStripItem(label: 'Export', value: pack.exportLabel),
            HrisMetricStripItem(label: 'Handoff', value: pack.handoffLabel),
            HrisMetricStripItem(label: 'Receipt', value: pack.receiptLabel),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in pack.manifestItems)
              _ArchiveManifestChip(item: item),
          ],
        ),
        if (pack.blockers.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final blocker in pack.blockers)
            _ArchiveBlockerRow(blocker: blocker),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const ValueKey('employee-payroll-audit-archive-button'),
          onPressed: pack.isReady ? () {} : null,
          icon: const Icon(Icons.archive_outlined),
          label: Text(pack.isReady ? 'Prepare archive' : 'Archive blocked'),
        ),
        const SizedBox(height: 6),
        Text(
          pack.fileName,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}

@Preview(name: 'Employee payroll audit archive pack')
Widget employeePayrollRunConsoleAuditArchivePanelPreview() {
  final package = EmployeePayrollRunConsoleAuditEvidencePackage(
    report: EmployeePayrollRunConsoleAuditEvidenceReport(
      summary: EmployeePayrollRunConsoleAuditSummary(
        events: [
          _previewEvent(
            id: 'payroll-console-audit-1',
            type: EmployeePayrollRunConsoleCommandType.prepareExport,
          ),
          _previewEvent(
            id: 'payroll-console-audit-2',
            type: EmployeePayrollRunConsoleCommandType.settlePayment,
          ),
          _previewEvent(
            id: 'payroll-console-audit-3',
            type: EmployeePayrollRunConsoleCommandType.publishPayslip,
          ),
          _previewEvent(
            id: 'payroll-console-audit-4',
            type: EmployeePayrollRunConsoleCommandType.closePeriod,
          ),
        ],
      ),
    ),
  );
  final submittedAt = DateTime(2026, 6, 9, 10, 30);
  final handoff = EmployeePayrollRunConsoleAuditHandoffRecord(
    id: 'PAH-1',
    packageReference: package.packageReference,
    reviewer: 'Alya Rahman',
    approver: 'Rafi Pratama',
    submittedAt: submittedAt,
    dueDate: DateTime(2026, 6, 10),
    note: 'Evidence package reviewed for payroll close handoff.',
    status: EmployeePayrollRunConsoleAuditHandoffStatus.approved,
    readyItemCount: package.readyItemCount,
    totalItemCount: package.totalItemCount,
    evidencedCommandCount: package.evidencedCommandCount,
    totalCommandCount: package.totalCommandCount,
    reviewEventCount: 0,
    decidedAt: submittedAt.add(const Duration(hours: 1)),
    decisionAttestations:
        EmployeePayrollRunConsoleAuditDecisionAttestation.values.toSet(),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditArchivePanel(
          pack: EmployeePayrollRunConsoleAuditArchivePack(
            package: package,
            exportPreview: EmployeePayrollRunConsoleAuditExportPreview(
              package: package,
              generatedAt: submittedAt,
            ),
            handoffReview:
                EmployeePayrollRunConsoleAuditHandoffReview.fromState(
                  package: package,
                  draft: const EmployeePayrollRunConsoleAuditHandoffDraft(),
                  handoffs: [handoff],
                ),
          ),
        ),
      ),
    ),
  );
}

/// Compact manifest chip used by payroll close archive pack previews.
class _ArchiveManifestChip extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditArchiveManifestItem item;

  const _ArchiveManifestChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${item.label}: ',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            item.value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single archive readiness blocker row.
class _ArchiveBlockerRow extends StatelessWidget {
  final String blocker;

  const _ArchiveBlockerRow({required this.blocker});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: Color(0xFFB45309)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              blocker,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(EmployeePayrollRunConsoleAuditArchiveStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditArchiveStatus.ready => const Color(
      0xFF15803D,
    ),
    EmployeePayrollRunConsoleAuditArchiveStatus.returned ||
    EmployeePayrollRunConsoleAuditArchiveStatus
        .receiptIncomplete => const Color(0xFFB91C1C),
    EmployeePayrollRunConsoleAuditArchiveStatus.packageBlocked ||
    EmployeePayrollRunConsoleAuditArchiveStatus.handoffRequired ||
    EmployeePayrollRunConsoleAuditArchiveStatus
        .decisionRequired => const Color(0xFFB45309),
    EmployeePayrollRunConsoleAuditArchiveStatus.noEvidence => HrisColors.muted,
  };
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
