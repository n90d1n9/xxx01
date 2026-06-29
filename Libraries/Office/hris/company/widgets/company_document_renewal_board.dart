import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_document_renewal.dart';
import 'company_status_styles.dart';

class CompanyDocumentRenewalBoard extends StatelessWidget {
  final List<CompanyDocumentRenewalTask> tasks;
  final DateTime asOfDate;
  final ValueChanged<String> onStart;
  final ValueChanged<String> onComplete;

  const CompanyDocumentRenewalBoard({
    super.key,
    required this.tasks,
    required this.asOfDate,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.event_repeat_outlined,
      title: 'Document Renewal Board',
      subtitle: '${tasks.length} renewal tasks',
      emptyMessage: 'No matching renewal tasks',
      children:
          tasks
              .map(
                (task) => _RenewalTaskTile(
                  task: task,
                  asOfDate: asOfDate,
                  onStart: () => onStart(task.id),
                  onComplete: () => onComplete(task.id),
                ),
              )
              .toList(),
    );
  }
}

class _RenewalTaskTile extends StatelessWidget {
  final CompanyDocumentRenewalTask task;
  final DateTime asOfDate;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const _RenewalTaskTile({
    required this.task,
    required this.asOfDate,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = companyDocumentRenewalStatusColor(task.status);
    final issues = task.issues(asOfDate);
    final isCompleted = task.status == CompanyDocumentRenewalStatus.completed;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.documentTitle,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: task.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${task.entityName} - ${task.lastActivity}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Owner', value: task.ownerName),
              HrisMetricStripItem(label: 'Due', value: _dueLabel(task)),
              HrisMetricStripItem(
                label: 'Reminder',
                value: '${task.reminderLeadDays}d',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            task.actionLabel,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  issues
                      .map(
                        (issue) => HrisStatusPill(
                          label: issue.label,
                          color: Colors.orange,
                        ),
                      )
                      .toList(),
            ),
          ],
          if (!isCompleted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _dueLabel(CompanyDocumentRenewalTask task) {
    final days = task.daysUntilDue(asOfDate);
    if (days < 0) return 'Overdue ${days.abs()}d';
    if (days == 0) return 'Today';
    return '${_formatDate(task.dueDate)} (${days}d)';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
