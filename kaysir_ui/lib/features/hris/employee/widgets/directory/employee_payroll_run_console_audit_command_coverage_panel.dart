import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_audit_package_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';

/// Command-stage evidence coverage for a payroll console audit package.
class EmployeePayrollRunConsoleAuditCommandCoveragePanel
    extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditEvidencePackage package;

  const EmployeePayrollRunConsoleAuditCommandCoveragePanel({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        package.hasCompleteCommandCoverage
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Command stage coverage',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(
              label:
                  '${package.evidencedCommandCount}/'
                  '${package.totalCommandCount} evidenced',
              color: color,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            for (final coverage in package.commandCoverage)
              _CommandCoverageRow(
                key: ValueKey(
                  'employee-payroll-run-console-audit-command-${coverage.type.name}',
                ),
                coverage: coverage,
              ),
          ],
        ),
      ],
    );
  }
}

/// Row that explains audit coverage for one payroll command stage.
class _CommandCoverageRow extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditCommandCoverage coverage;

  const _CommandCoverageRow({super.key, required this.coverage});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(coverage.status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_commandIcon(coverage.type), size: 16, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        coverage.type.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: coverage.status.label, color: color),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  coverage.detailLabel,
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

@Preview(name: 'Employee payroll run console audit command coverage')
Widget employeePayrollRunConsoleAuditCommandCoveragePanelPreview() {
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
        child: EmployeePayrollRunConsoleAuditCommandCoveragePanel(
          package: EmployeePayrollRunConsoleAuditEvidencePackage(
            report: EmployeePayrollRunConsoleAuditEvidenceReport(
              summary: summary,
            ),
          ),
        ),
      ),
    ),
  );
}

IconData _commandIcon(EmployeePayrollRunConsoleCommandType type) {
  return switch (type) {
    EmployeePayrollRunConsoleCommandType.prepareExport =>
      Icons.upload_file_outlined,
    EmployeePayrollRunConsoleCommandType.settlePayment =>
      Icons.payments_outlined,
    EmployeePayrollRunConsoleCommandType.publishPayslip =>
      Icons.receipt_long_outlined,
    EmployeePayrollRunConsoleCommandType.closePeriod =>
      Icons.lock_clock_outlined,
  };
}

Color _statusColor(EmployeePayrollRunConsoleAuditCommandCoverageStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditCommandCoverageStatus.missing =>
      HrisColors.muted,
    EmployeePayrollRunConsoleAuditCommandCoverageStatus.ready => const Color(
      0xFF15803D,
    ),
    EmployeePayrollRunConsoleAuditCommandCoverageStatus.reviewNeeded =>
      const Color(0xFFB45309),
    EmployeePayrollRunConsoleAuditCommandCoverageStatus.noChange =>
      HrisColors.muted,
  };
}
