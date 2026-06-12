import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_release_archive.dart';
import 'financial_report_audit_trail_components.dart';

class FinancialReportReleaseArchiveAuditTrail extends StatelessWidget {
  const FinancialReportReleaseArchiveAuditTrail({
    required this.events,
    required this.isDarkMode,
    super.key,
  });

  final List<FinancialReportReleaseArchiveAuditEvent> events;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportAuditTrailPanel<
      FinancialReportReleaseArchiveAuditEvent
    >(
      title: 'Archive Audit Trail',
      events: events,
      isDarkMode: isDarkMode,
      icon: Icons.archive_rounded,
      backgroundColor:
          isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      itemBuilder:
          (context, event) => FinancialReportReleaseArchiveAuditTile(
            event: event,
            isDarkMode: isDarkMode,
          ),
    );
  }
}

class FinancialReportReleaseArchiveAuditTile extends StatelessWidget {
  const FinancialReportReleaseArchiveAuditTile({
    required this.event,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportReleaseArchiveAuditEvent event;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = _actionColor(event.action);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final formatter = DateFormat('MMM d, yyyy HH:mm');
    final archiveLabel =
        event.archiveId == null || event.archiveId!.trim().isEmpty
            ? event.periodLabel
            : event.archiveId!;
    final retainLabel =
        event.retainUntil == null
            ? ''
            : ' / retain until ${DateFormat('MMM d, yyyy').format(event.retainUntil!)}';
    final nextReviewLabel =
        event.nextReviewDate == null
            ? ''
            : ' / next review ${DateFormat('MMM d, yyyy').format(event.nextReviewDate!)}';
    final fingerprintLabel =
        event.shortFingerprint.isEmpty ? '' : ' / ${event.shortFingerprint}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_actionIcon(event.action), size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event.action.label}: $archiveLabel',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${event.actor} / ${formatter.format(event.occurredAt)}'
                '$fingerprintLabel$retainLabel$nextReviewLabel',
                style: TextStyle(color: mutedColor, fontSize: 11),
              ),
              if (_locationLabel(event).isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _locationLabel(event),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ],
              if (event.note.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  event.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _locationLabel(FinancialReportReleaseArchiveAuditEvent event) {
    final parts = [
      event.custodian,
      event.storageLocation,
      event.retentionPolicy,
    ].where((part) => part != null && part.trim().isNotEmpty);
    return parts.join(' / ');
  }
}

Color _actionColor(FinancialReportReleaseArchiveAuditAction action) {
  switch (action) {
    case FinancialReportReleaseArchiveAuditAction.archived:
      return Colors.teal.shade700;
    case FinancialReportReleaseArchiveAuditAction.retentionReviewed:
      return Colors.indigo.shade600;
    case FinancialReportReleaseArchiveAuditAction.disposalReviewRequested:
      return Colors.orange.shade800;
    case FinancialReportReleaseArchiveAuditAction.cleared:
      return Colors.blueGrey.shade600;
  }
}

IconData _actionIcon(FinancialReportReleaseArchiveAuditAction action) {
  switch (action) {
    case FinancialReportReleaseArchiveAuditAction.archived:
      return Icons.archive_rounded;
    case FinancialReportReleaseArchiveAuditAction.retentionReviewed:
      return Icons.fact_check_rounded;
    case FinancialReportReleaseArchiveAuditAction.disposalReviewRequested:
      return Icons.rule_folder_rounded;
    case FinancialReportReleaseArchiveAuditAction.cleared:
      return Icons.lock_open_rounded;
  }
}
