import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_release_distribution.dart';
import 'financial_report_audit_trail_components.dart';

class FinancialReportReleaseDistributionAuditTrail extends StatelessWidget {
  const FinancialReportReleaseDistributionAuditTrail({
    required this.events,
    required this.isDarkMode,
    super.key,
  });

  final List<FinancialReportReleaseDistributionAuditEvent> events;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportAuditTrailPanel<
      FinancialReportReleaseDistributionAuditEvent
    >(
      title: 'Distribution Audit Trail',
      events: events,
      isDarkMode: isDarkMode,
      icon: Icons.manage_history_rounded,
      backgroundColor:
          isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      itemBuilder:
          (context, event) => FinancialReportReleaseDistributionAuditTile(
            event: event,
            isDarkMode: isDarkMode,
          ),
    );
  }
}

class FinancialReportReleaseDistributionAuditTile extends StatelessWidget {
  const FinancialReportReleaseDistributionAuditTile({
    required this.event,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportReleaseDistributionAuditEvent event;
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
                '${event.action.label}: ${event.recipientName}',
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
                '${event.channel.label} / ${event.periodLabel}',
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

Color _actionColor(FinancialReportReleaseDistributionAuditAction action) {
  switch (action) {
    case FinancialReportReleaseDistributionAuditAction.acknowledged:
      return Colors.teal.shade700;
    case FinancialReportReleaseDistributionAuditAction.sent:
      return Colors.blue.shade700;
    case FinancialReportReleaseDistributionAuditAction.exception:
      return Colors.red.shade700;
    case FinancialReportReleaseDistributionAuditAction.cleared:
      return Colors.blueGrey.shade600;
  }
}

IconData _actionIcon(FinancialReportReleaseDistributionAuditAction action) {
  switch (action) {
    case FinancialReportReleaseDistributionAuditAction.acknowledged:
      return Icons.how_to_reg_rounded;
    case FinancialReportReleaseDistributionAuditAction.sent:
      return Icons.send_rounded;
    case FinancialReportReleaseDistributionAuditAction.exception:
      return Icons.report_problem_rounded;
    case FinancialReportReleaseDistributionAuditAction.cleared:
      return Icons.close_rounded;
  }
}
