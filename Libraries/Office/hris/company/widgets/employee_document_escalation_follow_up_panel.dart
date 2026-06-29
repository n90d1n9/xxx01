import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/employee_document_escalation_follow_up.dart';
import '../models/employee_document_escalation_plan.dart';

/// Shows next-touch SLA items for escalated employee document owner lanes.
class EmployeeDocumentEscalationFollowUpPanel extends StatelessWidget {
  final List<EmployeeDocumentEscalationFollowUp> followUps;
  final DateTime asOfDate;
  final ValueChanged<String>? onAuditEventSelected;
  final ValueChanged<String>? onRecordFollowUp;

  const EmployeeDocumentEscalationFollowUpPanel({
    super.key,
    required this.followUps,
    required this.asOfDate,
    this.onAuditEventSelected,
    this.onRecordFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final overdueCount =
        followUps
            .where(
              (item) =>
                  item.state == EmployeeDocumentEscalationFollowUpState.overdue,
            )
            .length;
    final dueTodayCount =
        followUps
            .where(
              (item) =>
                  item.state ==
                  EmployeeDocumentEscalationFollowUpState.dueToday,
            )
            .length;

    return HrisSectionPanel(
      icon: Icons.event_repeat_outlined,
      title: 'Escalation Follow-up Queue',
      subtitle:
          followUps.isEmpty
              ? 'No owner escalation follow-ups scheduled'
              : '$overdueCount overdue, $dueTodayCount due today',
      emptyMessage: 'No employee document escalation follow-ups',
      children:
          followUps.isEmpty
              ? const []
              : [
                _FollowUpSummaryStrip(followUps: followUps),
                for (final item in followUps)
                  _FollowUpTile(
                    item: item,
                    asOfDate: asOfDate,
                    onSelected:
                        onAuditEventSelected == null
                            ? null
                            : () => onAuditEventSelected!(
                              item.lastEscalationAuditEventId,
                            ),
                    onRecordFollowUp:
                        onRecordFollowUp == null
                            ? null
                            : () => onRecordFollowUp!(item.ownerName),
                  ),
              ],
    );
  }
}

/// Summary metrics for escalation follow-up SLA items.
class _FollowUpSummaryStrip extends StatelessWidget {
  final List<EmployeeDocumentEscalationFollowUp> followUps;

  const _FollowUpSummaryStrip({required this.followUps});

  @override
  Widget build(BuildContext context) {
    final overdueCount =
        followUps
            .where(
              (item) =>
                  item.state == EmployeeDocumentEscalationFollowUpState.overdue,
            )
            .length;
    final dueTodayCount =
        followUps
            .where(
              (item) =>
                  item.state ==
                  EmployeeDocumentEscalationFollowUpState.dueToday,
            )
            .length;
    final scheduledCount =
        followUps
            .where(
              (item) =>
                  item.state ==
                  EmployeeDocumentEscalationFollowUpState.scheduled,
            )
            .length;

    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Follow-ups', value: '${followUps.length}'),
        HrisMetricStripItem(label: 'Overdue', value: '$overdueCount'),
        HrisMetricStripItem(label: 'Due today', value: '$dueTodayCount'),
        HrisMetricStripItem(label: 'Scheduled', value: '$scheduledCount'),
      ],
    );
  }
}

/// Displays one owner escalation follow-up SLA item.
class _FollowUpTile extends StatelessWidget {
  final EmployeeDocumentEscalationFollowUp item;
  final DateTime asOfDate;
  final VoidCallback? onSelected;
  final VoidCallback? onRecordFollowUp;

  const _FollowUpTile({
    required this.item,
    required this.asOfDate,
    required this.onSelected,
    required this.onRecordFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final stateColor = _stateColor(item.state);
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
                    const SizedBox(height: 4),
                    Text(
                      '${item.entitySummary} - ${item.primaryEmployeeLabel}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HrisStatusPill(label: item.state.label, color: stateColor),
                  const SizedBox(height: 6),
                  HrisStatusPill(
                    label: item.priority.label,
                    color:
                        item.priority ==
                                EmployeeDocumentEscalationPriority.critical
                            ? Colors.red
                            : Colors.orange,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Next touch',
                value: item.nextTouchLabel(asOfDate),
              ),
              HrisMetricStripItem(
                label: 'Last',
                value: item.lastEscalatedLabel(asOfDate),
              ),
              HrisMetricStripItem(
                label: 'Missing',
                value: '${item.missingDocumentCount}',
              ),
              HrisMetricStripItem(
                label: 'Requests',
                value: '${item.openRequestCount}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final rationale = _FollowUpRationale(
                item: item,
                stateColor: stateColor,
              );
              final action = OutlinedButton.icon(
                onPressed: onSelected,
                icon: const Icon(Icons.manage_search_outlined),
                label: const Text('Open audit'),
              );
              final recordAction = FilledButton.icon(
                key: Key(
                  'employee-escalation-follow-up-record-${item.ownerName}',
                ),
                onPressed: onRecordFollowUp,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Record follow-up'),
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [action, recordAction],
              );

              if (constraints.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [rationale, const SizedBox(height: 12), actions],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: rationale),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
        ],
      ),
    );

    if (onSelected == null) return content;
    return InkWell(
      key: Key(
        'employee-escalation-follow-up-${item.lastEscalationAuditEventId}',
      ),
      borderRadius: BorderRadius.circular(8),
      onTap: onSelected,
      child: content,
    );
  }
}

/// Context block explaining the next follow-up touch.
class _FollowUpRationale extends StatelessWidget {
  final EmployeeDocumentEscalationFollowUp item;
  final Color stateColor;

  const _FollowUpRationale({required this.item, required this.stateColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stateColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: stateColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_send_outlined, color: stateColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.rationale,
                  maxLines: 3,
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

Color _stateColor(EmployeeDocumentEscalationFollowUpState state) {
  switch (state) {
    case EmployeeDocumentEscalationFollowUpState.overdue:
      return Colors.red;
    case EmployeeDocumentEscalationFollowUpState.dueToday:
      return Colors.orange;
    case EmployeeDocumentEscalationFollowUpState.scheduled:
      return Colors.green;
  }
}

@Preview(name: 'Employee document escalation follow-up panel')
Widget employeeDocumentEscalationFollowUpPanelPreview() {
  final asOfDate = DateTime(2026, 6, 10);
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: EmployeeDocumentEscalationFollowUpPanel(
          asOfDate: asOfDate,
          followUps: [
            EmployeeDocumentEscalationFollowUp(
              ownerName: 'Fajar Prakoso',
              entitySummary: 'PT Kaysir Nusantara',
              priority: EmployeeDocumentEscalationPriority.critical,
              actionLabel: 'Review rejected evidence',
              primaryEmployeeName: 'David Kim',
              workloadScore: 186,
              missingDocumentCount: 9,
              openRequestCount: 2,
              lastEscalationAuditEventId: 'audit-follow-up-1',
              lastEscalatedAt: asOfDate.subtract(const Duration(days: 2)),
              nextTouchDate: asOfDate.subtract(const Duration(days: 1)),
              state: EmployeeDocumentEscalationFollowUpState.overdue,
              rationale:
                  'Critical owner lane with 9 missing evidence items and 2 open requests. Follow-up is overdue.',
            ),
          ],
          onAuditEventSelected: _previewAuditSelected,
          onRecordFollowUp: _previewRecordFollowUp,
        ),
      ),
    ),
  );
}

void _previewAuditSelected(String auditEventId) {}

void _previewRecordFollowUp(String ownerName) {}
