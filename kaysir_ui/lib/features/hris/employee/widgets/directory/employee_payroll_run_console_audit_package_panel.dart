import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_access_models.dart';
import '../../models/employee_payroll_run_console_audit_archive_models.dart';
import '../../models/employee_payroll_run_console_audit_export_models.dart';
import '../../models/employee_payroll_run_console_audit_handoff_models.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_audit_package_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';
import 'employee_payroll_run_console_audit_access_panel.dart';
import 'employee_payroll_run_console_audit_archive_panel.dart';
import 'employee_payroll_run_console_audit_command_coverage_panel.dart';
import 'employee_payroll_run_console_audit_export_preview_panel.dart';
import 'employee_payroll_run_console_audit_handoff_panel.dart';

/// Checklist view for a payroll console audit evidence package.
class EmployeePayrollRunConsoleAuditPackagePanel extends StatefulWidget {
  final EmployeePayrollRunConsoleAuditEvidencePackage package;

  const EmployeePayrollRunConsoleAuditPackagePanel({
    super.key,
    required this.package,
  });

  @override
  State<EmployeePayrollRunConsoleAuditPackagePanel> createState() =>
      _EmployeePayrollRunConsoleAuditPackagePanelState();
}

/// Maintains the selected payroll audit role for package close controls.
class _EmployeePayrollRunConsoleAuditPackagePanelState
    extends State<EmployeePayrollRunConsoleAuditPackagePanel> {
  EmployeePayrollRunConsoleAuditRole _role =
      EmployeePayrollRunConsoleAuditRole.payrollReviewer;
  EmployeePayrollRunConsoleAuditHandoffReview? _handoffReview;

  @override
  Widget build(BuildContext context) {
    final package = widget.package;
    final generatedAt = package.closedAt ?? DateTime.now();
    final handoffReview = _handoffReviewFor(package);
    final exportPreview = EmployeePayrollRunConsoleAuditExportPreview(
      package: package,
      generatedAt: generatedAt,
    );
    final accessReview = EmployeePayrollRunConsoleAuditAccessReview(
      role: _role,
      exportPreview: exportPreview,
      handoffReview: handoffReview,
    );
    final readyColor =
        package.readyItemCount == package.totalItemCount
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
                'Close evidence package',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(label: package.readinessLabel, color: readyColor),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          package.handoffLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PackageMetaLabel(
              icon: Icons.inventory_2_outlined,
              label: package.packageReference,
            ),
            _PackageMetaLabel(
              icon: Icons.event_available_outlined,
              label: _formatWindow(package.openedAt, package.closedAt),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            for (final item in package.items)
              _PackageChecklistRow(
                key: ValueKey(
                  'employee-payroll-run-console-audit-package-${item.title}',
                ),
                item: item,
              ),
          ],
        ),
        EmployeePayrollRunConsoleAuditCommandCoveragePanel(package: package),
        EmployeePayrollRunConsoleAuditAccessPanel(
          review: accessReview,
          onRoleChanged: (role) => setState(() => _role = role),
        ),
        EmployeePayrollRunConsoleAuditExportPreviewPanel(
          package: package,
          generatedAt: generatedAt,
          role: _role,
        ),
        EmployeePayrollRunConsoleAuditHandoffPanel(
          package: package,
          role: _role,
          onReviewChanged: _handleHandoffReviewChanged,
        ),
        EmployeePayrollRunConsoleAuditArchivePanel(
          pack: EmployeePayrollRunConsoleAuditArchivePack(
            package: package,
            exportPreview: exportPreview,
            handoffReview: handoffReview,
          ),
        ),
      ],
    );
  }

  EmployeePayrollRunConsoleAuditHandoffReview _handoffReviewFor(
    EmployeePayrollRunConsoleAuditEvidencePackage package,
  ) {
    final review = _handoffReview;
    if (review?.package.packageReference == package.packageReference) {
      return review!;
    }
    return _accessHandoffReview(package);
  }

  void _handleHandoffReviewChanged(
    EmployeePayrollRunConsoleAuditHandoffReview review,
  ) {
    if (!mounted) return;
    setState(() => _handoffReview = review);
  }
}

/// Row that shows one evidence package readiness item.
class _PackageChecklistRow extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditPackageItem item;

  const _PackageChecklistRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final color =
        item.isReady ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.isReady ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.detail,
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

/// Compact metadata label used by the audit evidence package panel.
class _PackageMetaLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PackageMetaLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HrisColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ],
    );
  }
}

@Preview(name: 'Employee payroll run console audit package')
Widget employeePayrollRunConsoleAuditPackagePanelPreview() {
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
        child: EmployeePayrollRunConsoleAuditPackagePanel(
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

String _formatWindow(DateTime? openedAt, DateTime? closedAt) {
  if (openedAt == null || closedAt == null) return 'No evidence window';
  final formatter = DateFormat('MMM d, HH:mm');
  if (openedAt == closedAt) return formatter.format(openedAt);
  return '${formatter.format(openedAt)} - ${formatter.format(closedAt)}';
}

EmployeePayrollRunConsoleAuditHandoffReview _accessHandoffReview(
  EmployeePayrollRunConsoleAuditEvidencePackage package,
) {
  return EmployeePayrollRunConsoleAuditHandoffReview.fromState(
    package: package,
    draft: EmployeePayrollRunConsoleAuditHandoffDraft(
      dueDate: package.closedAt?.add(const Duration(days: 1)),
    ),
    handoffs: const [],
  );
}
