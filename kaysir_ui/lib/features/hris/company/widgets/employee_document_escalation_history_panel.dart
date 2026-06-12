import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/employee_document_escalation_history.dart';

/// Shows recent employee document owner escalations and audit handoff.
class EmployeeDocumentEscalationHistoryPanel extends StatelessWidget {
  final EmployeeDocumentEscalationHistory history;
  final DateTime asOfDate;
  final ValueChanged<String>? onAuditEventSelected;

  const EmployeeDocumentEscalationHistoryPanel({
    super.key,
    required this.history,
    required this.asOfDate,
    this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.history_toggle_off_outlined,
      title: 'Escalation History',
      subtitle:
          '${history.totalEscalationCount} escalations, '
          '${history.ownerCount} owner lanes reached',
      emptyMessage: 'No employee document escalation history',
      children:
          history.isEmpty
              ? const []
              : [
                _EscalationHistorySummary(history: history, asOfDate: asOfDate),
                for (final item in history.items)
                  _EscalationHistoryItemTile(
                    item: item,
                    asOfDate: asOfDate,
                    onSelected:
                        onAuditEventSelected == null
                            ? null
                            : () => onAuditEventSelected!(item.auditEventId),
                  ),
              ],
    );
  }
}

/// Summary metrics for escalation audit history.
class _EscalationHistorySummary extends StatelessWidget {
  final EmployeeDocumentEscalationHistory history;
  final DateTime asOfDate;

  const _EscalationHistorySummary({
    required this.history,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Escalations',
          value: '${history.totalEscalationCount}',
        ),
        HrisMetricStripItem(label: 'Owners', value: '${history.ownerCount}'),
        HrisMetricStripItem(
          label: 'Latest',
          value: history.latestLabel(asOfDate),
        ),
        HrisMetricStripItem(label: 'Showing', value: '${history.items.length}'),
      ],
    );
  }
}

/// Compact audit event row for one employee document owner escalation.
class _EscalationHistoryItemTile extends StatelessWidget {
  final EmployeeDocumentEscalationHistoryItem item;
  final DateTime asOfDate;
  final VoidCallback? onSelected;

  const _EscalationHistoryItemTile({
    required this.item,
    required this.asOfDate,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final content = HrisListSurface(
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
                      item.ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.entityName} - ${item.actorName}',
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
              HrisStatusPill(
                label: item.escalatedLabel(asOfDate),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.note,
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

    if (onSelected == null) return content;
    return InkWell(
      key: Key('employee-escalation-history-${item.auditEventId}'),
      borderRadius: BorderRadius.circular(8),
      onTap: onSelected,
      child: content,
    );
  }
}

@Preview(name: 'Employee document escalation history panel')
Widget employeeDocumentEscalationHistoryPanelPreview() {
  final asOfDate = DateTime(2026, 6, 9);
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EmployeeDocumentEscalationHistoryPanel(
          asOfDate: asOfDate,
          history: EmployeeDocumentEscalationHistory(
            totalEscalationCount: 2,
            ownerCount: 2,
            items: [
              EmployeeDocumentEscalationHistoryItem(
                id: 'audit-escalation-2',
                ownerName: 'Fajar Prakoso',
                entityName: 'PT Kaysir Nusantara',
                actorName: 'People Operations',
                happenedAt: asOfDate,
                note:
                    'Escalated owner workload for 2 employee document gaps: '
                    'Critical priority, 9 missing evidence items.',
                auditEventId: 'audit-escalation-2',
              ),
              EmployeeDocumentEscalationHistoryItem(
                id: 'audit-escalation-1',
                ownerName: 'Dewi Lestari',
                entityName: 'Kaysir Retail Services',
                actorName: 'People Operations',
                happenedAt: asOfDate.subtract(const Duration(days: 1)),
                note:
                    'Escalated owner workload for 1 employee document gap: '
                    'Critical priority, 4 missing evidence items.',
                auditEventId: 'audit-escalation-1',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
