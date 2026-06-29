import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_employee_document_workload.dart';
import '../models/company_employee_document_workload_digest_status.dart';
import '../models/employee_document_digest_preview.dart';

/// Opens a confirmation preview for a due employee document digest dispatch.
Future<bool?> showEmployeeDocumentDigestPreviewDialog({
  required BuildContext context,
  required EmployeeDocumentDigestPreview preview,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => EmployeeDocumentDigestPreviewDialog(preview: preview),
  );
}

/// Modal preview for owner digests before bulk dispatch is confirmed.
class EmployeeDocumentDigestPreviewDialog extends StatelessWidget {
  final EmployeeDocumentDigestPreview preview;

  const EmployeeDocumentDigestPreviewDialog({super.key, required this.preview});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return AlertDialog(
      icon: const Icon(Icons.forward_to_inbox_outlined),
      title: const Text('Digest preview'),
      content: SizedBox(
        width: 680,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DigestPreviewSummary(preview: preview),
                const SizedBox(height: 14),
                for (final owner in preview.owners) ...[
                  _DigestPreviewOwnerTile(owner: owner),
                  if (owner != preview.owners.last) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed:
              preview.isEmpty ? null : () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.send_outlined),
          label: Text(
            preview.ownerCount == 1
                ? 'Send digest'
                : 'Send ${preview.ownerCount} digests',
          ),
        ),
      ],
    );
  }
}

/// Summary strip for the digest preview modal.
class _DigestPreviewSummary extends StatelessWidget {
  final EmployeeDocumentDigestPreview preview;

  const _DigestPreviewSummary({required this.preview});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _DigestPreviewStat(
          label: 'Owners',
          value: '${preview.ownerCount}',
          icon: Icons.supervisor_account_outlined,
          color: HrisColors.primary,
        ),
        _DigestPreviewStat(
          label: 'Gaps',
          value: '${preview.gapCount}',
          icon: Icons.rule_folder_outlined,
          color: Colors.deepOrange,
        ),
        _DigestPreviewStat(
          label: 'Missing',
          value: '${preview.missingDocumentCount}',
          icon: Icons.file_present_outlined,
          color: Colors.red,
        ),
        _DigestPreviewStat(
          label: 'Requests',
          value: '${preview.openRequestCount}',
          icon: Icons.mark_email_unread_outlined,
          color: Colors.indigo,
        ),
        _DigestPreviewStat(
          label: 'Escalations',
          value: '${preview.escalationCount}',
          icon: Icons.priority_high_outlined,
          color: Colors.purple,
        ),
      ],
    );
  }
}

/// Compact metric chip for the digest preview summary.
class _DigestPreviewStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DigestPreviewStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 108),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: HrisColors.muted),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Owner row for the digest preview modal.
class _DigestPreviewOwnerTile extends StatelessWidget {
  final EmployeeDocumentDigestPreviewOwner owner;

  const _DigestPreviewOwnerTile({required this.owner});

  @override
  Widget build(BuildContext context) {
    final workload = owner.workload;
    final statusColor = workload.requiresEscalation ? Colors.red : Colors.green;
    final statusLabel = workload.requiresEscalation ? 'Escalate' : 'Watchlist';

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workload.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${workload.entitySummary} - ${owner.lastSentLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HrisStatusPill(
                    label: owner.freshnessLabel,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 6),
                  HrisStatusPill(label: statusLabel, color: statusColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Gaps', value: '${workload.gapCount}'),
              HrisMetricStripItem(
                label: 'Missing',
                value: '${workload.missingDocumentCount}',
              ),
              HrisMetricStripItem(
                label: 'Requests',
                value: '${workload.openRequestCount}',
              ),
              HrisMetricStripItem(label: 'Cadence', value: owner.cadenceLabel),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            owner.primarySummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee document digest preview dialog')
Widget employeeDocumentDigestPreviewDialogPreview() {
  final asOfDate = DateTime(2026, 6, 9);
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: EmployeeDocumentDigestPreviewDialog(
          preview: buildEmployeeDocumentDigestPreview(
            ownerNames: const ['Fajar Prakoso', 'People Operations'],
            workloads: _previewWorkloads,
            digestStatuses: [
              CompanyEmployeeDocumentWorkloadDigestStatus(
                ownerName: 'Fajar Prakoso',
                digestCount: 1,
                lastSentAt: asOfDate.subtract(const Duration(days: 1)),
                lastAuditEventId: 'audit-preview-1',
              ),
              const CompanyEmployeeDocumentWorkloadDigestStatus(
                ownerName: 'People Operations',
                digestCount: 0,
                lastSentAt: null,
                lastAuditEventId: '',
              ),
            ],
            asOfDate: asOfDate,
          ),
        ),
      ),
    ),
  );
}

const _previewWorkloads = [
  CompanyEmployeeDocumentWorkload(
    ownerName: 'Fajar Prakoso',
    entityNames: ['PT Kaysir Nusantara'],
    gapIds: ['gap-1', 'gap-2'],
    score: 186,
    gapCount: 2,
    criticalCount: 1,
    highCount: 1,
    overdueCount: 1,
    dueSoonCount: 1,
    openRequestCount: 2,
    missingDocumentCount: 9,
    pendingDocumentCount: 1,
    rejectedDocumentCount: 1,
    primaryAction: 'Review rejected evidence',
    primaryGapId: 'gap-1',
    primaryEmployeeName: 'David Kim',
  ),
  CompanyEmployeeDocumentWorkload(
    ownerName: 'People Operations',
    entityNames: ['PT Kaysir Nusantara', 'Kaysir Retail Services'],
    gapIds: ['gap-3'],
    score: 72,
    gapCount: 1,
    criticalCount: 0,
    highCount: 1,
    overdueCount: 0,
    dueSoonCount: 1,
    openRequestCount: 1,
    missingDocumentCount: 4,
    pendingDocumentCount: 0,
    rejectedDocumentCount: 0,
    primaryAction: 'Generate request',
    primaryGapId: 'gap-3',
    primaryEmployeeName: 'Alya Rahman',
  ),
];
