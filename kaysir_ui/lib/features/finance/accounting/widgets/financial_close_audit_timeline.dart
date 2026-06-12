import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_period_close_audit.dart';
import 'financial_report_audit_trail_components.dart';

class FinancialCloseAuditTimeline extends StatelessWidget {
  final List<FinancialPeriodCloseAuditEvent> events;
  final bool isDarkMode;

  const FinancialCloseAuditTimeline({
    required this.events,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return FinancialReportAuditTrailPanel<FinancialPeriodCloseAuditEvent>(
      title: 'Close Audit Trail',
      events: events,
      isDarkMode: isDarkMode,
      padding: const EdgeInsets.all(14),
      itemSpacing: 10,
      backgroundColor:
          isDarkMode
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.grey.shade50,
      itemBuilder:
          (context, event) =>
              _CloseAuditEventTile(event: event, isDarkMode: isDarkMode),
    );
  }
}

class _CloseAuditEventTile extends StatelessWidget {
  final FinancialPeriodCloseAuditEvent event;
  final bool isDarkMode;

  const _CloseAuditEventTile({required this.event, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final mutedColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    final color =
        event.action == FinancialPeriodCloseAuditAction.closed
            ? (isDarkMode ? const Color(0xFF4ECCA3) : Colors.teal.shade700)
            : Colors.orange.shade700;
    final formatter = DateFormat('MMM d, yyyy HH:mm');
    final readiness = (event.checklistReadinessRatio * 100).round();
    final closingEntry = event.closingEntryEvidenceLabel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Icon(
            event.action == FinancialPeriodCloseAuditAction.closed
                ? Icons.lock_rounded
                : Icons.lock_open_rounded,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${event.action.label} by ${event.actor}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                '${formatter.format(event.occurredAt)} | Readiness $readiness% | Blockers ${event.blockerCount}',
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
              if (event.reportPackageShortHash != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Package fingerprint ${event.reportPackageShortHash}',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
              if (closingEntry != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Closing entry $closingEntry',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
              if (event.reason != null && event.reason!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  event.reason!,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
