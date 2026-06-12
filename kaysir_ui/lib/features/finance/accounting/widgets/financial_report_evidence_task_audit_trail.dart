import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_evidence_close_task.dart';
import 'financial_report_audit_trail_components.dart';

class FinancialReportEvidenceTaskAuditTrail extends StatelessWidget {
  const FinancialReportEvidenceTaskAuditTrail({
    required this.events,
    required this.isDarkMode,
    super.key,
  });

  final List<FinancialReportEvidenceTaskAuditEvent> events;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return FinancialReportAuditTrailPanel<
      FinancialReportEvidenceTaskAuditEvent
    >(
      title: 'Evidence Audit Trail',
      events: events,
      isDarkMode: isDarkMode,
      backgroundColor: isDarkMode ? Colors.white10 : Colors.white,
      itemBuilder:
          (context, event) => FinancialReportEvidenceTaskAuditTile(
            event: event,
            isDarkMode: isDarkMode,
          ),
    );
  }
}

class FinancialReportEvidenceTaskAuditTile extends StatelessWidget {
  const FinancialReportEvidenceTaskAuditTile({
    required this.event,
    required this.isDarkMode,
    super.key,
  });

  final FinancialReportEvidenceTaskAuditEvent event;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700;
    final formatter = DateFormat('MMM d, yyyy HH:mm');
    final reference = event.evidenceReference;
    final referenceLabel =
        reference == null || reference.trim().isEmpty ? '' : ' / $reference';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.task_alt_rounded,
          size: 16,
          color:
              event.status ==
                      FinancialReportEvidenceCloseTaskResolutionStatus.deferred
                  ? Colors.blueGrey
                  : Colors.teal,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event.action.label}: ${event.status.label}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${event.actor} / ${formatter.format(event.occurredAt)}$referenceLabel',
                style: TextStyle(color: mutedColor, fontSize: 11),
              ),
              if (event.note.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  event.note,
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
