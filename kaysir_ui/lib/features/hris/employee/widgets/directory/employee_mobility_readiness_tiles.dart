import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_mobility_readiness_models.dart';
import 'employee_mobility_readiness_styles.dart';

class EmployeeMobilityReadinessSummaryStrip extends StatelessWidget {
  final EmployeeMobilityReadinessProfile profile;

  const EmployeeMobilityReadinessSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Blocked', value: '${profile.blockedCount}'),
        HrisMetricStripItem(
          label: 'Action',
          value: '${profile.actionRequiredCount}',
        ),
        HrisMetricStripItem(label: 'Ready', value: '${profile.readyCount}'),
        HrisMetricStripItem(label: 'Due', value: '${profile.overdueCount}'),
      ],
    );
  }
}

class EmployeeMobilityTargetCard extends StatelessWidget {
  final EmployeeMobilityReadinessProfile profile;
  final TextEditingController roleController;
  final TextEditingController departmentController;
  final TextEditingController managerController;
  final ValueChanged<EmployeeMobilityMoveType> onMoveTypeChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onManagerChanged;
  final VoidCallback onSelectEffectiveDate;
  final VoidCallback onReset;

  const EmployeeMobilityTargetCard({
    super.key,
    required this.profile,
    required this.roleController,
    required this.departmentController,
    required this.managerController,
    required this.onMoveTypeChanged,
    required this.onRoleChanged,
    required this.onDepartmentChanged,
    required this.onManagerChanged,
    required this.onSelectEffectiveDate,
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
            child: SegmentedButton<EmployeeMobilityMoveType>(
              showSelectedIcon: false,
              segments:
                  EmployeeMobilityMoveType.values
                      .map(
                        (type) => ButtonSegment(
                          value: type,
                          icon: Icon(employeeMobilityMoveTypeIcon(type)),
                          label: Text(type.label),
                        ),
                      )
                      .toList(),
              selected: {profile.moveType},
              onSelectionChanged:
                  (selection) => onMoveTypeChanged(selection.single),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: roleController,
            decoration: const InputDecoration(
              labelText: 'Target role',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            onChanged: onRoleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: departmentController,
            decoration: const InputDecoration(
              labelText: 'Target department',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business_outlined),
            ),
            onChanged: onDepartmentChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: managerController,
            decoration: const InputDecoration(
              labelText: 'Target manager',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.supervisor_account_outlined),
            ),
            onChanged: onManagerChanged,
          ),
          const SizedBox(height: 12),
          _EffectiveDateField(profile: profile, onTap: onSelectEffectiveDate),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.readinessRatio,
            color: progressColor,
            label:
                '${(profile.readinessRatio * 100).round()}% mobility ready, ${profile.daysUntilEffective} day(s) to effective date',
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

class EmployeeMobilityGateTile extends StatelessWidget {
  final EmployeeMobilityGate gate;
  final DateTime asOfDate;
  final ValueChanged<EmployeeMobilityGateStatus> onStatusChanged;
  final VoidCallback onWaive;
  final VoidCallback onReopen;
  final VoidCallback onRemove;

  const EmployeeMobilityGateTile({
    super.key,
    required this.gate,
    required this.asOfDate,
    required this.onStatusChanged,
    required this.onWaive,
    required this.onReopen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = employeeMobilityGateStatusColor(gate.status);
    final riskColor = employeeMobilityGateRiskColor(gate.risk);
    final typeIcon = employeeMobilityGateTypeIcon(gate.type);
    final overdue = gate.isOverdue(asOfDate);

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
                  employeeMobilityGateStatusIcon(gate.status),
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
                      gate.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gate.detail,
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
              HrisStatusPill(label: gate.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: typeIcon, label: gate.type.label),
              _MetaChip(
                icon: Icons.person_outline,
                label: gate.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: 'Due ${DateFormat('MMM d').format(gate.dueDate)}',
                color: overdue ? const Color(0xFFB91C1C) : HrisColors.muted,
              ),
              _MetaChip(
                icon: Icons.flag_outlined,
                label: gate.risk.label,
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
              PopupMenuButton<EmployeeMobilityGateStatus>(
                tooltip: 'Update gate status',
                onSelected: onStatusChanged,
                itemBuilder:
                    (context) =>
                        EmployeeMobilityGateStatus.values
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
              if (gate.status == EmployeeMobilityGateStatus.waived)
                TextButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.undo_outlined),
                  label: const Text('Reopen'),
                )
              else if (!gate.isComplete)
                TextButton.icon(
                  onPressed: onWaive,
                  icon: const Icon(Icons.do_not_disturb_on_outlined),
                  label: const Text('Waive'),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove gate',
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

class _EffectiveDateField extends StatelessWidget {
  final EmployeeMobilityReadinessProfile profile;
  final VoidCallback onTap;

  const _EffectiveDateField({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Effective date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(DateFormat('MMM d, yyyy').format(profile.effectiveDate)),
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
