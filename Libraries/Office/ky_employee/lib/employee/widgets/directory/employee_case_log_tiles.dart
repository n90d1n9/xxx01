import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_case_log_models.dart';
import 'employee_case_log_styles.dart';

class EmployeeHrCaseLogSummaryStrip extends StatelessWidget {
  final EmployeeHrCaseLog log;

  const EmployeeHrCaseLogSummaryStrip({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Open', value: '${log.openCaseCount}'),
        HrisMetricStripItem(
          label: 'Overdue',
          value: '${log.overdueFollowUpCount}',
        ),
        HrisMetricStripItem(label: 'High', value: '${log.highPriorityCount}'),
        HrisMetricStripItem(
          label: 'Private',
          value: '${log.confidentialNoteCount}',
        ),
      ],
    );
  }
}

class EmployeeHrCaseRecordTile extends StatelessWidget {
  final EmployeeHrCaseRecord record;
  final DateTime asOfDate;
  final VoidCallback onStart;
  final VoidCallback onResolve;
  final VoidCallback onScheduleFollowUp;

  const EmployeeHrCaseRecordTile({
    super.key,
    required this.record,
    required this.asOfDate,
    required this.onStart,
    required this.onResolve,
    required this.onScheduleFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = record.isOverdue(asOfDate);
    final statusColor =
        overdue
            ? const Color(0xFFB91C1C)
            : employeeHrCaseStatusColor(record.status);
    final priorityColor = employeeHrCasePriorityColor(record.priority);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeHrCaseTypeIcon(record.type),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${record.owner} - ${record.type.label}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: overdue ? 'Overdue' : record.status.label,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.summary,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.priority_high_outlined,
                label: record.priority.label,
                color: priorityColor,
              ),
              _MetaChip(
                icon: employeeHrCaseConfidentialityIcon(record.confidentiality),
                label: record.confidentiality.label,
                color:
                    record.confidentiality ==
                            EmployeeHrCaseConfidentiality.restricted
                        ? const Color(0xFFB91C1C)
                        : null,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label:
                    'Follow ${DateFormat('MMM d').format(record.followUpDate)}',
                color: overdue ? const Color(0xFFB91C1C) : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      record.status == EmployeeHrCaseStatus.open
                          ? onStart
                          : null,
                  icon: const Icon(Icons.play_arrow_outlined),
                  label: const Text('Start'),
                ),
                OutlinedButton.icon(
                  onPressed: record.isOpen ? onScheduleFollowUp : null,
                  icon: const Icon(Icons.event_repeat_outlined),
                  label: const Text('Follow-up'),
                ),
                FilledButton.tonalIcon(
                  onPressed: record.isOpen ? onResolve : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Resolve'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeHrCaseNoteTile extends StatelessWidget {
  final EmployeeHrCaseNote note;
  final EmployeeHrCaseRecord? caseRecord;

  const EmployeeHrCaseNoteTile({
    super.key,
    required this.note,
    required this.caseRecord,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        note.confidential ? const Color(0xFF7C3AED) : HrisColors.primary;

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              note.confidential ? Icons.lock_outline : Icons.notes_outlined,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        caseRecord?.title ?? 'HR case note',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (note.confidential)
                      HrisStatusPill(label: 'Confidential', color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  note.body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.ink),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(icon: Icons.person_outline, label: note.author),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label: DateFormat('MMM d').format(note.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? HrisColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: resolvedColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
