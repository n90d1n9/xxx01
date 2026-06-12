import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_release_signoff.dart';
import 'financial_report_audit_trail_components.dart';

class FinancialReportReleaseSignOffAuditTrail extends StatelessWidget {
  const FinancialReportReleaseSignOffAuditTrail({
    required this.events,
    required this.isDarkMode,
    super.key,
  });

  final List<FinancialReportReleaseSignOffAuditEvent> events;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportAuditTrailPanel<
      FinancialReportReleaseSignOffAuditEvent
    >(
      title: 'Release Audit Trail',
      events: events,
      isDarkMode: isDarkMode,
      icon: Icons.verified_user_rounded,
      backgroundColor:
          isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      itemBuilder:
          (context, event) => FinancialReportReleaseSignOffAuditTile(
            event: event,
            isDarkMode: isDarkMode,
          ),
    );
  }
}

class FinancialReportReleaseSignOffAuditTile extends StatelessWidget {
  const FinancialReportReleaseSignOffAuditTile({
    required this.event,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportReleaseSignOffAuditEvent event;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = _actionColor(event.action);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final formatter = DateFormat('MMM d, yyyy HH:mm');
    final statusLabel = event.status == null ? '' : ' / ${event.status!.label}';
    final evidenceLabel =
        event.evidenceReference == null ||
                event.evidenceReference!.trim().isEmpty
            ? ''
            : ' / ${event.evidenceReference}';

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
                '${event.action.label}: ${event.requirementTitle}',
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
                '$statusLabel$evidenceLabel',
                style: TextStyle(color: mutedColor, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                '${event.role.label} / ${event.periodLabel}',
                style: TextStyle(color: mutedColor, fontSize: 11),
              ),
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
}

Color _actionColor(FinancialReportReleaseSignOffAuditAction action) {
  switch (action) {
    case FinancialReportReleaseSignOffAuditAction.signed:
      return Colors.teal.shade700;
    case FinancialReportReleaseSignOffAuditAction.returned:
      return Colors.red.shade700;
    case FinancialReportReleaseSignOffAuditAction.cleared:
      return Colors.blueGrey.shade600;
  }
}

IconData _actionIcon(FinancialReportReleaseSignOffAuditAction action) {
  switch (action) {
    case FinancialReportReleaseSignOffAuditAction.signed:
      return Icons.draw_rounded;
    case FinancialReportReleaseSignOffAuditAction.returned:
      return Icons.assignment_return_rounded;
    case FinancialReportReleaseSignOffAuditAction.cleared:
      return Icons.close_rounded;
  }
}
