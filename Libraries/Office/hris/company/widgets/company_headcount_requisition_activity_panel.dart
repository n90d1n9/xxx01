import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_headcount_requisition_activity.dart';

/// Timeline panel for auditable headcount requisition workflow activity.
class CompanyHeadcountRequisitionActivityPanel extends StatelessWidget {
  final CompanyHeadcountRequisitionActivityTimeline timeline;

  const CompanyHeadcountRequisitionActivityPanel({
    super.key,
    required this.timeline,
  });

  @override
  Widget build(BuildContext context) {
    final records = timeline.recentRecords.take(6).toList();

    return HrisSectionPanel(
      icon: Icons.history_edu_outlined,
      title: 'Headcount Activity',
      subtitle:
          timeline.isEmpty
              ? 'No requisition activity'
              : '${timeline.approvalCount} approvals, ${timeline.recruitingCount} recruiting opens',
      emptyMessage: 'No headcount requisition activity',
      children:
          timeline.isEmpty
              ? const []
              : [
                _ActivitySummary(timeline: timeline),
                for (final record in records) _ActivityTile(record: record),
              ],
    );
  }
}

/// Summary metrics for the headcount activity timeline.
class _ActivitySummary extends StatelessWidget {
  final CompanyHeadcountRequisitionActivityTimeline timeline;

  const _ActivitySummary({required this.timeline});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Submitted',
          value: '${timeline.submittedCount}',
        ),
        HrisMetricStripItem(
          label: 'Approved',
          value: '${timeline.approvalCount}',
        ),
        HrisMetricStripItem(
          label: 'Recruiting',
          value: '${timeline.recruitingCount}',
        ),
        HrisMetricStripItem(label: 'Filled', value: '${timeline.filledCount}'),
      ],
    );
  }
}

/// One audit-style headcount requisition activity entry.
class _ActivityTile extends StatelessWidget {
  final CompanyHeadcountRequisitionActivityRecord record;

  const _ActivityTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = _activityColor(record.type);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_activityIcon(record.type), color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${record.type.label} - ${record.roleTitle}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: record.happenedAtLabel, color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  record.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${record.actorName} - ${record.requisitionId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _activityColor(CompanyHeadcountRequisitionActivityType type) {
  switch (type) {
    case CompanyHeadcountRequisitionActivityType.submitted:
      return Colors.blueGrey;
    case CompanyHeadcountRequisitionActivityType.approved:
      return Colors.indigo;
    case CompanyHeadcountRequisitionActivityType.recruitingOpened:
      return Colors.blue;
    case CompanyHeadcountRequisitionActivityType.filled:
      return Colors.green;
  }
}

IconData _activityIcon(CompanyHeadcountRequisitionActivityType type) {
  switch (type) {
    case CompanyHeadcountRequisitionActivityType.submitted:
      return Icons.send_outlined;
    case CompanyHeadcountRequisitionActivityType.approved:
      return Icons.verified_outlined;
    case CompanyHeadcountRequisitionActivityType.recruitingOpened:
      return Icons.campaign_outlined;
    case CompanyHeadcountRequisitionActivityType.filled:
      return Icons.task_alt_outlined;
  }
}

@Preview(name: 'Company headcount requisition activity')
Widget companyHeadcountRequisitionActivityPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyHeadcountRequisitionActivityPanel(
          timeline: CompanyHeadcountRequisitionActivityTimeline(
            records: [
              CompanyHeadcountRequisitionActivityRecord(
                id: 'hreq-activity-001',
                requisitionId: 'hreq-product-engineer',
                roleTitle: 'Product Engineer',
                type: CompanyHeadcountRequisitionActivityType.recruitingOpened,
                actorName: 'People Operations',
                happenedAt: DateTime(2026, 6, 12),
                note: 'Recruiting opened for two product engineer seats.',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
