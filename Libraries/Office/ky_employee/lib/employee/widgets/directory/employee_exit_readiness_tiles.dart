import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_exit_readiness_models.dart';
import 'employee_exit_readiness_styles.dart';

class EmployeeExitReadinessSummaryStrip extends StatelessWidget {
  final EmployeeExitReadinessProfile profile;

  const EmployeeExitReadinessSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Blocked', value: '${profile.blockedCount}'),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
        HrisMetricStripItem(label: 'Open', value: '${profile.openCount}'),
        HrisMetricStripItem(label: 'Done', value: '${profile.completeCount}'),
      ],
    );
  }
}

class EmployeeExitPlanCard extends StatelessWidget {
  final EmployeeExitReadinessProfile profile;
  final ValueChanged<EmployeeExitType> onTypeChanged;
  final VoidCallback onSelectFinalWorkday;
  final VoidCallback onReset;

  const EmployeeExitPlanCard({
    super.key,
    required this.profile,
    required this.onTypeChanged,
    required this.onSelectFinalWorkday,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor =
        profile.blockedCount > 0
            ? const Color(0xFFB91C1C)
            : profile.attentionCount > 0
            ? const Color(0xFFB45309)
            : const Color(0xFF15803D);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<EmployeeExitType>(
              segments:
                  EmployeeExitType.values
                      .map(
                        (type) =>
                            ButtonSegment(value: type, label: Text(type.label)),
                      )
                      .toList(),
              selected: {profile.exitType},
              onSelectionChanged:
                  (selection) => onTypeChanged(selection.single),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetaLine(
                  icon: Icons.event_available_outlined,
                  label:
                      'Final workday ${DateFormat('MMM d, yyyy').format(profile.finalWorkday)}',
                  color:
                      profile.isExitImminent
                          ? const Color(0xFFB45309)
                          : HrisColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: onSelectFinalWorkday,
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Change date'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.clearanceRatio,
            color: progressColor,
            label:
                '${(profile.clearanceRatio * 100).round()}% clearance ready, ${profile.daysUntilExit} day(s) to final workday',
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Reset preset'),
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeExitClearanceTile extends StatelessWidget {
  final EmployeeExitClearanceItem item;
  final DateTime asOfDate;
  final ValueChanged<EmployeeExitClearanceStatus> onStatusChanged;
  final VoidCallback onWaive;
  final VoidCallback onReopen;
  final VoidCallback onRemove;

  const EmployeeExitClearanceTile({
    super.key,
    required this.item,
    required this.asOfDate,
    required this.onStatusChanged,
    required this.onWaive,
    required this.onReopen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeExitStatusColor(item.status);
    final riskColor = employeeExitRiskColor(item.risk);
    final categoryIcon = employeeExitCategoryIcon(item.category);
    final overdue = item.isOverdue(asOfDate);

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
                  employeeExitStatusIcon(item.status),
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
                      item.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (item.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: HrisColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: item.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: categoryIcon, label: item.category.label),
              _MetaChip(
                icon: Icons.person_outline,
                label: item.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${DateFormat('MMM d').format(item.dueDate)}',
                color: overdue ? const Color(0xFFB91C1C) : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: item.risk.label,
                color: riskColor,
              ),
              if (overdue)
                _MetaChip(
                  icon: Icons.warning_amber_outlined,
                  label: 'Overdue',
                  color: const Color(0xFFB91C1C),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PopupMenuButton<EmployeeExitClearanceStatus>(
                tooltip: 'Update clearance status',
                onSelected: onStatusChanged,
                itemBuilder:
                    (context) =>
                        EmployeeExitClearanceStatus.values
                            .map(
                              (status) => PopupMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.tune_outlined),
                  label: Text('Status'),
                ),
              ),
              const SizedBox(width: 8),
              if (item.status == EmployeeExitClearanceStatus.waived)
                TextButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.undo_outlined),
                  label: const Text('Reopen'),
                )
              else if (!item.isComplete)
                TextButton.icon(
                  onPressed: onWaive,
                  icon: const Icon(Icons.do_not_disturb_on_outlined),
                  label: const Text('Waive'),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove clearance',
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

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaLine({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
      constraints: const BoxConstraints(maxWidth: 230),
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
