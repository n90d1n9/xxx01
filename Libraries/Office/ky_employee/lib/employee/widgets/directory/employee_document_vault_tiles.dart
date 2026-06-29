import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_document_vault_models.dart';
import 'employee_document_vault_styles.dart';

class EmployeeDocumentVaultSummaryStrip extends StatelessWidget {
  final EmployeeDocumentVaultProfile profile;

  const EmployeeDocumentVaultSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Verified',
          value: '${profile.verifiedCount}',
        ),
        HrisMetricStripItem(
          label: 'Review',
          value: '${profile.pendingReviewCount}',
        ),
        HrisMetricStripItem(
          label: 'Upload',
          value: '${profile.uploadNeededCount}',
        ),
        HrisMetricStripItem(
          label: 'Expiring',
          value: '${profile.expiringSoonCount}',
        ),
      ],
    );
  }
}

class EmployeeDocumentVaultRecordTile extends StatelessWidget {
  final EmployeeDocumentVaultRecord record;
  final DateTime asOfDate;
  final VoidCallback onVerify;
  final VoidCallback onRequestUpload;
  final VoidCallback onReject;
  final VoidCallback onArchive;

  const EmployeeDocumentVaultRecordTile({
    super.key,
    required this.record,
    required this.asOfDate,
    required this.onVerify,
    required this.onRequestUpload,
    required this.onReject,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final expired = record.isExpired(asOfDate);
    final expiringSoon = record.isExpiringSoon(asOfDate);
    final statusColor =
        expired
            ? const Color(0xFFB91C1C)
            : record.status != EmployeeDocumentVaultStatus.verified
            ? employeeDocumentVaultStatusColor(record.status)
            : expiringSoon
            ? const Color(0xFFB45309)
            : employeeDocumentVaultStatusColor(record.status);
    final accessColor = employeeDocumentVaultAccessColor(record.access);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileHeader(
            icon: employeeDocumentVaultCategoryIcon(record.category),
            title: record.title,
            subtitle: '${record.category.label} - ${record.owner}',
            color: statusColor,
            status: HrisStatusPill(
              label: _statusLabel(expired, expiringSoon),
              color: statusColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            record.summary,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: employeeDocumentVaultAccessIcon(record.access),
                label: record.access.label,
                color: accessColor,
              ),
              _MetaChip(
                icon: employeeDocumentVaultStatusIcon(record.status),
                label: record.source,
              ),
              _MetaChip(
                icon: Icons.upload_file_outlined,
                label: 'Uploaded ${_formatDate(record.uploadedAt)}',
              ),
              if (record.expiresAt != null)
                _MetaChip(
                  icon: Icons.event_busy_outlined,
                  label: 'Expires ${_formatDate(record.expiresAt!)}',
                  color:
                      expired || expiringSoon ? const Color(0xFFB45309) : null,
                ),
              if (record.verifiedAt != null)
                _MetaChip(
                  icon: Icons.verified_outlined,
                  label: 'Verified ${_formatDate(record.verifiedAt!)}',
                  color: const Color(0xFF15803D),
                ),
            ],
          ),
          if (_hasActions) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (record.canRequestUpload)
                  OutlinedButton.icon(
                    onPressed: onRequestUpload,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Request upload'),
                  ),
                if (record.canReject)
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close_outlined),
                    label: const Text('Reject'),
                  ),
                if (record.canVerify)
                  FilledButton.tonalIcon(
                    onPressed: onVerify,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Verify'),
                  ),
                if (record.canArchive)
                  OutlinedButton.icon(
                    onPressed: onArchive,
                    icon: const Icon(Icons.archive_outlined),
                    label: const Text('Archive'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasActions {
    return record.canRequestUpload ||
        record.canReject ||
        record.canVerify ||
        record.canArchive;
  }

  String _statusLabel(bool expired, bool expiringSoon) {
    if (expired) return EmployeeDocumentVaultStatus.expired.label;
    if (record.status != EmployeeDocumentVaultStatus.verified) {
      return record.status.label;
    }
    if (expiringSoon) return EmployeeDocumentVaultStatus.expiringSoon.label;
    return record.status.label;
  }
}

class _TileHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget status;

  const _TileHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        status,
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? HrisColors.muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}
