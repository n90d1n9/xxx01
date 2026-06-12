import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/employee_document_digest_history.dart';

/// Shows recent employee document digest dispatches and audit handoff.
class EmployeeDocumentDigestHistoryPanel extends StatelessWidget {
  final EmployeeDocumentDigestHistory history;
  final DateTime asOfDate;
  final ValueChanged<String>? onAuditEventSelected;

  const EmployeeDocumentDigestHistoryPanel({
    super.key,
    required this.history,
    required this.asOfDate,
    this.onAuditEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.history_outlined,
      title: 'Digest Dispatch History',
      subtitle:
          '${history.totalDigestCount} sent digests, '
          '${history.ownerCount} owner lanes reached',
      emptyMessage: 'No employee document digest history',
      children:
          history.isEmpty
              ? const []
              : [
                _DigestHistorySummary(history: history, asOfDate: asOfDate),
                for (final item in history.items)
                  _DigestHistoryItemTile(
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

/// Summary metrics for digest dispatch history.
class _DigestHistorySummary extends StatelessWidget {
  final EmployeeDocumentDigestHistory history;
  final DateTime asOfDate;

  const _DigestHistorySummary({required this.history, required this.asOfDate});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Digests',
          value: '${history.totalDigestCount}',
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

/// Compact audit event row for one owner digest dispatch.
class _DigestHistoryItemTile extends StatelessWidget {
  final EmployeeDocumentDigestHistoryItem item;
  final DateTime asOfDate;
  final VoidCallback? onSelected;

  const _DigestHistoryItemTile({
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
                label: item.sentLabel(asOfDate),
                color: HrisColors.primary,
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
      key: Key('employee-digest-history-${item.auditEventId}'),
      borderRadius: BorderRadius.circular(8),
      onTap: onSelected,
      child: content,
    );
  }
}

@Preview(name: 'Employee document digest history panel')
Widget employeeDocumentDigestHistoryPanelPreview() {
  final asOfDate = DateTime(2026, 6, 9);
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EmployeeDocumentDigestHistoryPanel(
          asOfDate: asOfDate,
          history: EmployeeDocumentDigestHistory(
            totalDigestCount: 2,
            ownerCount: 2,
            items: [
              EmployeeDocumentDigestHistoryItem(
                id: 'audit-preview-2',
                ownerName: 'Fajar Prakoso',
                entityName: 'PT Kaysir Nusantara',
                actorName: 'People Operations',
                happenedAt: asOfDate,
                note:
                    'Sent owner digest for 2 employee document gaps: '
                    '9 missing evidence items, 2 open requests.',
                auditEventId: 'audit-preview-2',
              ),
              EmployeeDocumentDigestHistoryItem(
                id: 'audit-preview-1',
                ownerName: 'Dewi Lestari',
                entityName: 'Kaysir Retail Services',
                actorName: 'People Operations',
                happenedAt: asOfDate.subtract(const Duration(days: 1)),
                note:
                    'Sent owner digest for 1 employee document gap: '
                    '4 missing evidence items, 1 open request.',
                auditEventId: 'audit-preview-1',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
