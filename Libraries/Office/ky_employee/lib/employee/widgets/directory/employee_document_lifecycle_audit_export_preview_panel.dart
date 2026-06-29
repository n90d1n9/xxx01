import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_document_lifecycle_audit_export_models.dart';
import '../../models/employee_document_lifecycle_audit_filter_models.dart';
import '../../models/employee_document_lifecycle_audit_models.dart';

/// Export-ready preview for filtered employee document lifecycle audit events.
class EmployeeDocumentLifecycleAuditExportPreviewPanel extends StatelessWidget {
  final EmployeeDocumentLifecycleAuditProfile profile;
  final List<EmployeeDocumentLifecycleAuditEntry> entries;
  final EmployeeDocumentLifecycleAuditFilterQuery query;
  final DateTime generatedAt;
  final ValueChanged<EmployeeDocumentLifecycleAuditExportPreview>? onCopied;

  const EmployeeDocumentLifecycleAuditExportPreviewPanel({
    super.key,
    required this.profile,
    required this.entries,
    required this.query,
    required this.generatedAt,
    this.onCopied,
  });

  @override
  Widget build(BuildContext context) {
    final preview = EmployeeDocumentLifecycleAuditExportPreview(
      profile: profile,
      entries: entries,
      query: query,
      generatedAt: generatedAt,
    );
    final color = _statusColor(preview.status);

    return HrisListSurface(
      key: const ValueKey('employee-document-lifecycle-audit-export-preview'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Lifecycle audit export preview',
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
            preview.exportActionLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Rows', value: '${preview.rowCount}'),
              HrisMetricStripItem(label: 'Scope', value: query.group.label),
              HrisMetricStripItem(
                label: 'Filters',
                value: '${query.activeFilterCount}',
              ),
              HrisMetricStripItem(
                label: 'Total',
                value: '${profile.totalCount}',
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
                  'employee-document-lifecycle-audit-export-copy-csv-button',
                ),
                onPressed:
                    preview.isReady
                        ? () => _copyCsv(context, preview, onCopied)
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
      ),
    );
  }
}

/// Compact manifest value chip used by document lifecycle export previews.
class _ExportManifestChip extends StatelessWidget {
  final EmployeeDocumentLifecycleAuditExportManifestItem item;

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

/// Monospace CSV sample block for document lifecycle export rows.
class _CsvPreview extends StatelessWidget {
  final EmployeeDocumentLifecycleAuditExportPreview preview;

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

@Preview(name: 'Employee document lifecycle audit export preview')
Widget employeeDocumentLifecycleAuditExportPreviewPanelPreview() {
  final profile = EmployeeDocumentLifecycleAuditProfile(
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    asOfDate: DateTime(2026, 6, 1),
    entries: [
      _previewEntry(
        id: 'EDLA-3-001',
        type: EmployeeDocumentLifecycleAuditEventType.requestCreated,
      ),
      _previewEntry(
        id: 'EDLA-3-002',
        type: EmployeeDocumentLifecycleAuditEventType.requestIssued,
      ),
      _previewEntry(
        id: 'EDLA-3-003',
        type: EmployeeDocumentLifecycleAuditEventType.vaultFulfilled,
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeDocumentLifecycleAuditExportPreviewPanel(
          profile: profile,
          entries: profile.sortedEntries,
          query: const EmployeeDocumentLifecycleAuditFilterQuery(),
          generatedAt: DateTime(2026, 6, 1, 12),
        ),
      ),
    ),
  );
}

Future<void> _copyCsv(
  BuildContext context,
  EmployeeDocumentLifecycleAuditExportPreview preview,
  ValueChanged<EmployeeDocumentLifecycleAuditExportPreview>? onCopied,
) async {
  await Clipboard.setData(ClipboardData(text: preview.csvContent));
  onCopied?.call(preview);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Document lifecycle audit CSV copied')),
  );
}

Color _statusColor(EmployeeDocumentLifecycleAuditExportStatus status) {
  return switch (status) {
    EmployeeDocumentLifecycleAuditExportStatus.ready => const Color(0xFF15803D),
    EmployeeDocumentLifecycleAuditExportStatus.scoped => const Color(
      0xFF2563EB,
    ),
    EmployeeDocumentLifecycleAuditExportStatus.empty => HrisColors.muted,
  };
}

EmployeeDocumentLifecycleAuditEntry _previewEntry({
  required String id,
  required EmployeeDocumentLifecycleAuditEventType type,
}) {
  return EmployeeDocumentLifecycleAuditEntry(
    id: id,
    employeeId: '3',
    employeeName: 'Aisha Rahman',
    type: type,
    subjectId: 'EDR-3-001',
    title: 'Payroll and tax evidence',
    actor: 'People Operations',
    owner: 'Aisha Rahman',
    detail: '${type.label} for Payroll and tax evidence.',
    correlationId: 'EDR-3-001',
    occurredAt: DateTime(2026, 5, 30),
  );
}
