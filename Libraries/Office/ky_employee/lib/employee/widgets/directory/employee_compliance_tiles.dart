import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_compliance_models.dart';
import 'employee_compliance_styles.dart';

class EmployeeComplianceSummaryStrip extends StatelessWidget {
  final EmployeeComplianceDocumentSummary summary;

  const EmployeeComplianceSummaryStrip({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Pending', value: '${summary.pendingCount}'),
        HrisMetricStripItem(
          label: 'Verified',
          value: '${summary.verifiedCount}',
        ),
        HrisMetricStripItem(label: 'Overdue', value: '${summary.overdueCount}'),
        HrisMetricStripItem(
          label: 'Expiring',
          value: '${summary.expiringSoonCount}',
        ),
      ],
    );
  }
}

class EmployeeComplianceDocumentTile extends StatelessWidget {
  final EmployeeComplianceDocumentRecord record;
  final DateTime asOfDate;
  final VoidCallback onVerify;
  final VoidCallback onReject;
  final VoidCallback onWaive;
  final VoidCallback onRenew;

  const EmployeeComplianceDocumentTile({
    super.key,
    required this.record,
    required this.asOfDate,
    required this.onVerify,
    required this.onReject,
    required this.onWaive,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeComplianceDocumentStatusColor(record.status);
    final overdue = record.isOverdue(asOfDate);
    final expired = record.isExpired(asOfDate);
    final expiring = record.isExpiringSoon(asOfDate);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeComplianceDocumentTypeIcon(record.type),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.type.label} - ${record.owner}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: record.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DocumentMetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${DateFormat('MMM d').format(record.dueDate)}',
                color: overdue ? const Color(0xFFB91C1C) : null,
              ),
              if (record.expiresAt != null)
                _DocumentMetaChip(
                  icon: Icons.update_outlined,
                  label:
                      'Expires ${DateFormat('MMM d').format(record.expiresAt!)}',
                  color: expired || expiring ? const Color(0xFFB91C1C) : null,
                ),
              _DocumentMetaChip(
                icon: Icons.upload_file_outlined,
                label:
                    'Uploaded ${DateFormat('MMM d').format(record.uploadedAt)}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record.notes,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (record.status != EmployeeComplianceDocumentStatus.verified)
                FilledButton.tonalIcon(
                  onPressed: onVerify,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Verify'),
                ),
              if (record.status == EmployeeComplianceDocumentStatus.pending)
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.report_outlined),
                  label: const Text('Reject'),
                ),
              if (record.status != EmployeeComplianceDocumentStatus.waived)
                OutlinedButton.icon(
                  onPressed: onWaive,
                  icon: const Icon(Icons.do_not_disturb_on_outlined),
                  label: const Text('Waive'),
                ),
              if (record.expiresAt != null && (expired || expiring))
                FilledButton.icon(
                  onPressed: onRenew,
                  icon: const Icon(Icons.autorenew_outlined),
                  label: const Text('Renew'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocumentMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _DocumentMetaChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? HrisColors.muted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
