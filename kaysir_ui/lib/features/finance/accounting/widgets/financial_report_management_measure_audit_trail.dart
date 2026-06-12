import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_management_measure.dart';
import 'financial_report_audit_trail_components.dart';

class FinancialReportManagementMeasureAuditTrail extends StatelessWidget {
  const FinancialReportManagementMeasureAuditTrail({
    required this.events,
    required this.isDarkMode,
    this.emptyActionLabel,
    this.onCreateAuditEvidence,
    super.key,
  });

  final List<FinancialReportManagementMeasureAuditEvent> events;
  final bool isDarkMode;
  final String? emptyActionLabel;
  final VoidCallback? onCreateAuditEvidence;

  @override
  Widget build(BuildContext context) {
    return FinancialReportAuditTrailPanel<
      FinancialReportManagementMeasureAuditEvent
    >(
      title: 'UKTM Audit Trail',
      events: events,
      isDarkMode: isDarkMode,
      icon: Icons.manage_history_rounded,
      accentColor: isDarkMode ? const Color(0xFF7DD3FC) : Colors.indigo,
      emptyMessage: 'No UKTM audit events captured for this period yet.',
      emptyActionLabel: emptyActionLabel,
      emptyActionIcon: Icons.add_task_rounded,
      onEmptyAction: onCreateAuditEvidence,
      itemBuilder:
          (context, event) => FinancialReportManagementMeasureAuditTile(
            event: event,
            isDarkMode: isDarkMode,
          ),
    );
  }
}

class FinancialReportManagementMeasureAuditTile extends StatelessWidget {
  const FinancialReportManagementMeasureAuditTile({
    required this.event,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportManagementMeasureAuditEvent event;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final color = _actionColor(event.action);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final formatter = DateFormat('MMM d, yyyy HH:mm');
    final statusLabel = event.status == null ? '' : ' / ${event.status!.label}';

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
                '${event.action.label}: ${event.measureLabel}',
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
                '$statusLabel',
                style: TextStyle(color: mutedColor, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                event.periodLabel,
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

Color _actionColor(FinancialReportManagementMeasureAuditAction action) {
  switch (action) {
    case FinancialReportManagementMeasureAuditAction.approved:
      return Colors.teal.shade700;
    case FinancialReportManagementMeasureAuditAction.returned:
    case FinancialReportManagementMeasureAuditAction.removed:
      return Colors.red.shade700;
    case FinancialReportManagementMeasureAuditAction.submittedForReview:
      return Colors.indigo.shade600;
    case FinancialReportManagementMeasureAuditAction.reset:
      return Colors.blueGrey.shade700;
    case FinancialReportManagementMeasureAuditAction.saved:
      return Colors.blue.shade700;
  }
}

IconData _actionIcon(FinancialReportManagementMeasureAuditAction action) {
  switch (action) {
    case FinancialReportManagementMeasureAuditAction.approved:
      return Icons.verified_user_outlined;
    case FinancialReportManagementMeasureAuditAction.returned:
      return Icons.assignment_return_rounded;
    case FinancialReportManagementMeasureAuditAction.removed:
      return Icons.delete_outline_rounded;
    case FinancialReportManagementMeasureAuditAction.submittedForReview:
      return Icons.rate_review_outlined;
    case FinancialReportManagementMeasureAuditAction.reset:
      return Icons.restore_rounded;
    case FinancialReportManagementMeasureAuditAction.saved:
      return Icons.save_outlined;
  }
}
