import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_performance_support_models.dart';
import 'employee_performance_support_styles.dart';

class EmployeePerformanceSupportSummaryStrip extends StatelessWidget {
  final EmployeePerformanceSupportPlan plan;

  const EmployeePerformanceSupportSummaryStrip({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Blocked', value: '${plan.blockedCount}'),
        HrisMetricStripItem(label: 'Overdue', value: '${plan.overdueCount}'),
        HrisMetricStripItem(label: 'Open', value: '${plan.openCount}'),
        HrisMetricStripItem(
          label: 'Progress',
          value: '${(plan.progressRatio * 100).round()}%',
        ),
      ],
    );
  }
}

class EmployeePerformanceSupportPlanCard extends StatelessWidget {
  final EmployeePerformanceSupportPlan plan;
  final TextEditingController titleController;
  final TextEditingController hrPartnerController;
  final ValueChanged<EmployeePerformanceSupportStatus> onStatusChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onHrPartnerChanged;
  final VoidCallback onSelectEndDate;
  final VoidCallback onReset;

  const EmployeePerformanceSupportPlanCard({
    super.key,
    required this.plan,
    required this.titleController,
    required this.hrPartnerController,
    required this.onStatusChanged,
    required this.onTitleChanged,
    required this.onHrPartnerChanged,
    required this.onSelectEndDate,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeePerformanceSupportStatusColor(plan.status);

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
                  employeePerformanceSupportStatusIcon(plan.status),
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
                      plan.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manager ${plan.manager} - HR ${plan.hrPartner}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: plan.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.event_available_outlined,
                label: 'Start ${DateFormat('MMM d').format(plan.startDate)}',
              ),
              _MetaChip(
                icon: Icons.event_note_outlined,
                label: 'End ${DateFormat('MMM d').format(plan.endDate)}',
                color:
                    plan.isReviewDue
                        ? const Color(0xFFB91C1C)
                        : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.timer_outlined,
                label: '${plan.daysRemaining} day(s) left',
                color:
                    plan.daysRemaining < 0
                        ? const Color(0xFFB91C1C)
                        : HrisColors.muted,
              ),
              if (plan.isEscalated)
                _MetaChip(
                  icon: Icons.priority_high_outlined,
                  label: 'Escalated',
                  color: const Color(0xFFB91C1C),
                ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: plan.progressRatio,
            color: statusColor,
            label: '${(plan.progressRatio * 100).round()}% milestones complete',
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<EmployeePerformanceSupportStatus>(
              showSelectedIcon: false,
              segments:
                  EmployeePerformanceSupportStatus.values
                      .map(
                        (status) => ButtonSegment(
                          value: status,
                          label: Text(status.label),
                        ),
                      )
                      .toList(),
              selected: {plan.status},
              onSelectionChanged:
                  (selection) => onStatusChanged(selection.single),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Plan title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.assignment_outlined),
            ),
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: hrPartnerController,
            decoration: const InputDecoration(
              labelText: 'HR partner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.support_agent_outlined),
            ),
            onChanged: onHrPartnerChanged,
          ),
          const SizedBox(height: 12),
          _DateField(
            label: 'Plan review date',
            date: plan.endDate,
            onTap: onSelectEndDate,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeePerformanceSupportMilestoneTile extends StatelessWidget {
  final EmployeePerformanceSupportMilestone milestone;
  final DateTime asOfDate;
  final ValueChanged<EmployeePerformanceMilestoneStatus> onStatusChanged;
  final ValueChanged<EmployeePerformanceSupportRisk> onRiskChanged;
  final VoidCallback onSchedule;
  final VoidCallback onComplete;
  final VoidCallback onWaive;
  final VoidCallback onRemove;

  const EmployeePerformanceSupportMilestoneTile({
    super.key,
    required this.milestone,
    required this.asOfDate,
    required this.onStatusChanged,
    required this.onRiskChanged,
    required this.onSchedule,
    required this.onComplete,
    required this.onWaive,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeePerformanceMilestoneStatusColor(
      milestone.status,
    );
    final riskColor = employeePerformanceSupportRiskColor(milestone.risk);
    final overdue = milestone.isOverdue(asOfDate);

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
                  employeePerformanceMilestoneStatusIcon(milestone.status),
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
                      milestone.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      milestone.successMetric,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HrisStatusPill(label: milestone.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            milestone.notes,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: employeePerformanceMilestoneTypeIcon(milestone.type),
                label: milestone.type.label,
              ),
              _MetaChip(
                icon: Icons.person_outline,
                label: milestone.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${DateFormat('MMM d').format(milestone.dueDate)}',
                color: overdue ? const Color(0xFFB91C1C) : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: milestone.risk.label,
                color: riskColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<EmployeePerformanceMilestoneStatus>(
                tooltip: 'Update milestone status',
                onSelected: onStatusChanged,
                itemBuilder:
                    (context) =>
                        EmployeePerformanceMilestoneStatus.values
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
              PopupMenuButton<EmployeePerformanceSupportRisk>(
                tooltip: 'Update milestone risk',
                onSelected: onRiskChanged,
                itemBuilder:
                    (context) =>
                        EmployeePerformanceSupportRisk.values
                            .map(
                              (risk) => PopupMenuItem(
                                value: risk,
                                child: Text(risk.label),
                              ),
                            )
                            .toList(),
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Risk'),
                ),
              ),
              IconButton(
                tooltip: 'Schedule milestone',
                onPressed: onSchedule,
                icon: const Icon(Icons.event_repeat_outlined),
              ),
              if (!milestone.isComplete)
                TextButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Complete'),
                ),
              if (!milestone.isComplete)
                TextButton.icon(
                  onPressed: onWaive,
                  icon: const Icon(Icons.do_not_disturb_on_outlined),
                  label: const Text('Waive'),
                ),
              IconButton(
                tooltip: 'Remove milestone',
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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_note_outlined),
        ),
        child: Text(DateFormat('MMM d, yyyy').format(date)),
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
