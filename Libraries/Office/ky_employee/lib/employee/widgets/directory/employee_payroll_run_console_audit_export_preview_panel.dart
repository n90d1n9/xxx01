import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_access_models.dart';
import '../../models/employee_payroll_run_console_audit_export_models.dart';
import '../../models/employee_payroll_run_console_audit_models.dart';
import '../../models/employee_payroll_run_console_audit_package_models.dart';
import '../../models/employee_payroll_run_console_command_models.dart';

/// Export-ready preview for a payroll console audit evidence package.
class EmployeePayrollRunConsoleAuditExportPreviewPanel extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditEvidencePackage package;
  final DateTime generatedAt;
  final EmployeePayrollRunConsoleAuditRole? role;

  const EmployeePayrollRunConsoleAuditExportPreviewPanel({
    super.key,
    required this.package,
    required this.generatedAt,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final preview = EmployeePayrollRunConsoleAuditExportPreview(
      package: package,
      generatedAt: generatedAt,
    );
    final copyPermission =
        role == null
            ? null
            : EmployeePayrollRunConsoleAuditAccessReview(
              role: role!,
              exportPreview: preview,
            ).copyExportPermission;
    final copyEnabled = preview.isReady && (copyPermission?.allowed ?? true);
    final color = _statusColor(preview.status);

    return Column(
      key: const ValueKey('employee-payroll-audit-export-preview-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Audit export preview',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            HrisStatusPill(label: preview.statusLabel, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          copyPermission?.reason ?? preview.exportActionLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
        const SizedBox(height: 10),
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(label: 'Rows', value: '${preview.rowCount}'),
            HrisMetricStripItem(
              label: 'Readiness',
              value: package.readinessLabel,
            ),
            HrisMetricStripItem(
              label: 'Commands',
              value:
                  '${package.evidencedCommandCount}/'
                  '${package.totalCommandCount}',
            ),
            HrisMetricStripItem(
              label: 'Review',
              value: '${package.summary.attentionCount}',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in preview.manifestItems)
              _ExportManifestChip(item: item),
          ],
        ),
        const SizedBox(height: 12),
        _CsvPreview(preview: preview),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              key: const ValueKey(
                'employee-payroll-audit-export-copy-csv-button',
              ),
              onPressed:
                  copyEnabled
                      ? () => _copyCsv(context, preview.csvContent)
                      : null,
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy CSV'),
            ),
            Text(
              '${preview.fileName} - ${preview.rowCountLabel}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact manifest value chip used by the audit export preview.
class _ExportManifestChip extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditExportManifestItem item;

  const _ExportManifestChip({required this.item});

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

/// CSV sample block showing the first export rows.
class _CsvPreview extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditExportPreview preview;

  const _CsvPreview({required this.preview});

  @override
  Widget build(BuildContext context) {
    final lines = preview.csvContent.split('\n').take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CSV sample',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontFamily: 'monospace',
              ),
            ),
          if (preview.rowCount > 3) ...[
            const SizedBox(height: 4),
            Text(
              '${preview.rowCount - 3} more rows included',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Employee payroll audit export preview')
Widget employeePayrollRunConsoleAuditExportPreviewPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditExportPreviewPanel(
          generatedAt: DateTime(2026, 6, 1, 12),
          package: EmployeePayrollRunConsoleAuditEvidencePackage(
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
          ),
        ),
      ),
    ),
  );
}

Future<void> _copyCsv(BuildContext context, String csvContent) async {
  await Clipboard.setData(ClipboardData(text: csvContent));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Audit CSV copied')));
}

Color _statusColor(EmployeePayrollRunConsoleAuditExportStatus status) {
  return switch (status) {
    EmployeePayrollRunConsoleAuditExportStatus.ready => const Color(0xFF15803D),
    EmployeePayrollRunConsoleAuditExportStatus.needsReview => const Color(
      0xFFB45309,
    ),
    EmployeePayrollRunConsoleAuditExportStatus.incomplete => const Color(
      0xFFB45309,
    ),
    EmployeePayrollRunConsoleAuditExportStatus.empty => HrisColors.muted,
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
