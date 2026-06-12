import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_job_assignment_models.dart';
import 'employee_job_assignment_styles.dart';

class EmployeeJobAssignmentSummaryStrip extends StatelessWidget {
  final EmployeeJobAssignmentProfile profile;

  const EmployeeJobAssignmentSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Active', value: '${profile.activeCount}'),
        HrisMetricStripItem(
          label: 'Pending',
          value: '${profile.pendingApprovalCount}',
        ),
        HrisMetricStripItem(
          label: 'Soon',
          value: '${profile.scheduledSoonCount}',
        ),
        HrisMetricStripItem(label: 'History', value: '${profile.historyCount}'),
      ],
    );
  }
}

class EmployeeJobAssignmentCurrentCard extends StatelessWidget {
  final EmployeeJobAssignmentRecord assignment;
  final DateTime asOfDate;

  const EmployeeJobAssignmentCurrentCard({
    super.key,
    required this.assignment,
    required this.asOfDate,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeJobAssignmentStatusColor(assignment.status);

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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeJobAssignmentTypeIcon(assignment.assignmentType),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.position,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${assignment.department} - ${assignment.grade}',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(label: 'Current', color: color),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.supervisor_account_outlined,
                label: assignment.manager,
              ),
              _MetaChip(icon: Icons.place_outlined, label: assignment.location),
              _MetaChip(
                icon: employeeWorkArrangementIcon(assignment.arrangement),
                label: assignment.arrangement.label,
              ),
              _MetaChip(
                icon: Icons.confirmation_number_outlined,
                label: assignment.costCenter,
              ),
              _MetaChip(
                icon: Icons.description_outlined,
                label: assignment.contractType.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmployeeJobAssignmentRecordTile extends StatelessWidget {
  final EmployeeJobAssignmentRecord assignment;
  final DateTime asOfDate;
  final VoidCallback onApprove;
  final VoidCallback onActivate;

  const EmployeeJobAssignmentRecordTile({
    super.key,
    required this.assignment,
    required this.asOfDate,
    required this.onApprove,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeJobAssignmentStatusColor(assignment.status);
    final dateText = _dateRangeText(assignment);

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
                  employeeJobAssignmentStatusIcon(assignment.status),
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
                      assignment.position,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateText,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: assignment.status.label,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.apartment_outlined,
                label: assignment.department,
              ),
              _MetaChip(
                icon: Icons.supervisor_account_outlined,
                label: assignment.manager,
              ),
              _MetaChip(icon: Icons.place_outlined, label: assignment.location),
              _MetaChip(icon: Icons.grade_outlined, label: assignment.grade),
              _MetaChip(
                icon: Icons.description_outlined,
                label: assignment.contractType.label,
              ),
              _MetaChip(
                icon: employeeJobAssignmentTypeIcon(assignment.assignmentType),
                label: assignment.assignmentType.label,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            assignment.notes,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          if (assignment.canApprove || assignment.canActivate(asOfDate)) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (assignment.canApprove)
                    FilledButton.tonalIcon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Approve'),
                    ),
                  if (assignment.canActivate(asOfDate))
                    FilledButton.icon(
                      onPressed: onActivate,
                      icon: const Icon(Icons.assignment_turned_in_outlined),
                      label: const Text('Activate'),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _dateRangeText(EmployeeJobAssignmentRecord assignment) {
    final formatter = DateFormat('MMM d, yyyy');
    final start = formatter.format(assignment.startDate);
    final endDate = assignment.endDate;
    if (endDate == null) return 'Starts $start';
    return '$start - ${formatter.format(endDate)}';
  }
}

class EmployeeJobAssignmentImpactPreview extends StatelessWidget {
  final List<EmployeeJobAssignmentImpact> impacts;

  const EmployeeJobAssignmentImpactPreview({super.key, required this.impacts});

  @override
  Widget build(BuildContext context) {
    final changed = impacts.where((impact) => impact.hasChange).toList();

    if (changed.isEmpty) {
      return Text(
        'Change assignment fields to preview the impact.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: changed.map((impact) => _ImpactRow(impact: impact)).toList(),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final EmployeeJobAssignmentImpact impact;

  const _ImpactRow({required this.impact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              impact.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: HrisColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${impact.fromValue} -> ${impact.toValue}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
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

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: HrisColors.muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: HrisColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
