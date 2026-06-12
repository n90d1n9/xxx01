import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_document_lifecycle_audit_export_models.dart';
import '../../models/employee_document_lifecycle_audit_export_receipt_models.dart';
import '../../models/employee_document_lifecycle_audit_filter_models.dart';

/// Receipt history for copied employee document lifecycle audit exports.
class EmployeeDocumentLifecycleAuditExportReceiptHistory
    extends StatelessWidget {
  final EmployeeDocumentLifecycleAuditExportReceiptProfile profile;
  final int maxItems;

  const EmployeeDocumentLifecycleAuditExportReceiptHistory({
    super.key,
    required this.profile,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context) {
    final latest = profile.latestReceipts.take(maxItems).toList();

    return HrisListSurface(
      key: const ValueKey(
        'employee-document-lifecycle-audit-export-receipt-history',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lifecycle export receipt history',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: '${profile.totalCount} logged',
                color: _historyColor(profile.totalCount),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            profile.nextAction,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Receipts',
                value: '${profile.totalCount}',
              ),
              HrisMetricStripItem(label: 'Full', value: '${profile.fullCount}'),
              HrisMetricStripItem(
                label: 'Scoped',
                value: '${profile.scopedCount}',
              ),
              HrisMetricStripItem(label: 'Rows', value: '${profile.totalRows}'),
            ],
          ),
          const SizedBox(height: 10),
          if (latest.isEmpty)
            const HrisEmptyState(
              message: 'No lifecycle audit export receipts yet',
            )
          else
            ...latest.map(
              (receipt) => _LifecycleAuditExportReceiptTile(receipt: receipt),
            ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee document lifecycle export receipt history')
Widget employeeDocumentLifecycleAuditExportReceiptHistoryPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDocumentLifecycleAuditExportReceiptHistory(
          profile: _previewReceiptProfile,
        ),
      ),
    ),
  );
}

/// Compact tile for one document lifecycle audit export receipt.
class _LifecycleAuditExportReceiptTile extends StatelessWidget {
  final EmployeeDocumentLifecycleAuditExportReceipt receipt;

  const _LifecycleAuditExportReceiptTile({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final color = _receiptColor(receipt);

    return Container(
      key: ValueKey(
        'employee-document-lifecycle-audit-export-receipt-${receipt.id}',
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_receiptIcon(receipt), color: color, size: 20),
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
                        receipt.summaryLabel,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: receipt.statusLabel, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  receipt.packageLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _LifecycleAuditExportReceiptMetaChip(
                      icon: Icons.manage_search_outlined,
                      label: receipt.filterLabel,
                    ),
                    _LifecycleAuditExportReceiptMetaChip(
                      icon: Icons.rule_folder_outlined,
                      label: receipt.exportStatusLabel,
                    ),
                    _LifecycleAuditExportReceiptMetaChip(
                      icon: Icons.schedule_outlined,
                      label: receipt.copiedAtLabel,
                    ),
                    _LifecycleAuditExportReceiptMetaChip(
                      icon: Icons.event_available_outlined,
                      label: receipt.generatedAtLabel,
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

/// Small metadata chip used inside a document lifecycle export receipt tile.
class _LifecycleAuditExportReceiptMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LifecycleAuditExportReceiptMetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

EmployeeDocumentLifecycleAuditExportReceiptProfile get _previewReceiptProfile {
  return EmployeeDocumentLifecycleAuditExportReceiptProfile(
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    asOfDate: DateTime(2026, 6, 1),
    receipts: [
      EmployeeDocumentLifecycleAuditExportReceipt(
        id: 'EDLER-3-002',
        employeeId: '3',
        employeeName: 'Aisha Rahman',
        status: EmployeeDocumentLifecycleAuditExportReceiptStatus.copied,
        exportStatus: EmployeeDocumentLifecycleAuditExportStatus.scoped,
        group: EmployeeDocumentLifecycleAuditFilterGroup.fulfillment,
        searchText: 'payroll',
        copiedBy: 'People Operations',
        fileName:
            'aisha-rahman-document-lifecycle-audit-fulfilled-20260601.csv',
        rowCount: 1,
        totalCount: 3,
        generatedAt: DateTime(2026, 6, 1, 12),
        copiedAt: DateTime(2026, 6, 1, 12, 15),
      ),
      EmployeeDocumentLifecycleAuditExportReceipt(
        id: 'EDLER-3-001',
        employeeId: '3',
        employeeName: 'Aisha Rahman',
        status: EmployeeDocumentLifecycleAuditExportReceiptStatus.copied,
        exportStatus: EmployeeDocumentLifecycleAuditExportStatus.ready,
        group: EmployeeDocumentLifecycleAuditFilterGroup.all,
        searchText: '',
        copiedBy: 'People Operations',
        fileName: 'aisha-rahman-document-lifecycle-audit-all-20260601.csv',
        rowCount: 3,
        totalCount: 3,
        generatedAt: DateTime(2026, 6, 1, 12),
        copiedAt: DateTime(2026, 6, 1, 12, 5),
      ),
    ],
  );
}

Color _historyColor(int totalCount) {
  return totalCount == 0 ? HrisColors.muted : const Color(0xFF15803D);
}

Color _receiptColor(EmployeeDocumentLifecycleAuditExportReceipt receipt) {
  return receipt.isScoped ? const Color(0xFF2563EB) : const Color(0xFF15803D);
}

IconData _receiptIcon(EmployeeDocumentLifecycleAuditExportReceipt receipt) {
  return receipt.isScoped
      ? Icons.filter_alt_outlined
      : Icons.table_chart_outlined;
}
