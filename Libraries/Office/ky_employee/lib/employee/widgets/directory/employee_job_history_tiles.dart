import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_job_history_models.dart';
import 'employee_job_history_styles.dart';

class EmployeeJobHistorySummaryStrip extends StatelessWidget {
  final EmployeeJobHistoryProfile profile;

  const EmployeeJobHistorySummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Effective',
          value: '${profile.effectiveCount}',
        ),
        HrisMetricStripItem(
          label: 'Scheduled',
          value: '${profile.scheduledCount}',
        ),
        HrisMetricStripItem(
          label: 'Evidence',
          value: '${profile.pendingEvidenceCount}',
        ),
        HrisMetricStripItem(label: 'Due', value: '${profile.overdueCount}'),
      ],
    );
  }
}

class EmployeeJobHistoryCurrentCard extends StatelessWidget {
  final EmployeeJobHistoryProfile profile;

  const EmployeeJobHistoryCurrentCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final latest = profile.latestEffectiveEvent;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: HrisColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_history_outlined,
                  color: HrisColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.currentPosition,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${profile.currentDepartment} - ${profile.currentManager}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: latest == null ? 'No history' : 'Current',
                color:
                    latest == null
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF15803D),
              ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 12),
            Text(
              'Latest effective change: ${latest.title}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EmployeeJobHistoryEventTile extends StatelessWidget {
  final EmployeeJobHistoryEvent event;
  final DateTime asOfDate;
  final ValueChanged<EmployeeJobHistoryStatus> onStatusChanged;
  final VoidCallback onAttachEvidence;
  final VoidCallback onMarkEffective;
  final VoidCallback onRequestEvidence;
  final VoidCallback onReverse;
  final VoidCallback onRemove;

  const EmployeeJobHistoryEventTile({
    super.key,
    required this.event,
    required this.asOfDate,
    required this.onStatusChanged,
    required this.onAttachEvidence,
    required this.onMarkEffective,
    required this.onRequestEvidence,
    required this.onReverse,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeJobHistoryStatusColor(event.status);
    final formatter = DateFormat('MMM d, yyyy');
    final overdue = event.isOverdue(asOfDate);
    final needsEvidence = event.needsEvidence;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeJobHistoryStatusIcon(event.status),
                  color: statusColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.fromValue} -> ${event.toValue}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: HrisColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: event.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: employeeJobHistoryTypeIcon(event.type),
                label: event.type.label,
              ),
              _MetaChip(
                icon: employeeJobHistorySourceIcon(event.source),
                label: event.source.label,
              ),
              _MetaChip(icon: Icons.person_outline, label: event.owner),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Effective ${formatter.format(event.effectiveDate)}',
                color: overdue ? const Color(0xFFB91C1C) : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.receipt_long_outlined,
                label: event.hasEvidence ? 'Evidence attached' : 'No evidence',
                color:
                    needsEvidence ? const Color(0xFFB45309) : HrisColors.muted,
              ),
              if (overdue)
                _MetaChip(
                  icon: Icons.warning_amber_outlined,
                  label: 'Overdue',
                  color: const Color(0xFFB91C1C),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            event.note,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PopupMenuButton<EmployeeJobHistoryStatus>(
                tooltip: 'Update history status',
                onSelected: onStatusChanged,
                itemBuilder:
                    (context) =>
                        EmployeeJobHistoryStatus.values
                            .map(
                              (status) => PopupMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Status'),
                ),
              ),
              const SizedBox(width: 8),
              if (needsEvidence)
                FilledButton.tonalIcon(
                  onPressed: onAttachEvidence,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Evidence'),
                )
              else if (!event.isEffective && !event.isReversed)
                TextButton.icon(
                  onPressed: onRequestEvidence,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Request evidence'),
                ),
              if (!event.isEffective && !event.isReversed) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onMarkEffective,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark effective'),
                ),
              ],
              const Spacer(),
              if (!event.isReversed)
                IconButton(
                  tooltip: 'Reverse history event',
                  onPressed: onReverse,
                  icon: const Icon(Icons.undo_outlined),
                ),
              IconButton(
                tooltip: 'Remove history event',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
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
    final chipColor = color ?? HrisColors.muted;

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: chipColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
