import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_manager_change_readiness_models.dart';
import 'employee_manager_change_readiness_styles.dart';

class EmployeeManagerChangeSummaryStrip extends StatelessWidget {
  final EmployeeManagerChangeReadinessProfile profile;

  const EmployeeManagerChangeSummaryStrip({super.key, required this.profile});

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

class EmployeeManagerChangeTargetCard extends StatelessWidget {
  final EmployeeManagerChangeReadinessProfile profile;
  final TextEditingController targetManagerController;
  final TextEditingController reasonController;
  final ValueChanged<EmployeeManagerChangeType> onChangeTypeChanged;
  final ValueChanged<String> onTargetManagerChanged;
  final ValueChanged<String> onReasonChanged;
  final VoidCallback onSelectEffectiveDate;
  final VoidCallback onReset;

  const EmployeeManagerChangeTargetCard({
    super.key,
    required this.profile,
    required this.targetManagerController,
    required this.reasonController,
    required this.onChangeTypeChanged,
    required this.onTargetManagerChanged,
    required this.onReasonChanged,
    required this.onSelectEffectiveDate,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor =
        profile.blockedCount > 0 || !profile.targetDiffers
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
            child: SegmentedButton<EmployeeManagerChangeType>(
              showSelectedIcon: false,
              segments:
                  EmployeeManagerChangeType.values
                      .map(
                        (type) => ButtonSegment(
                          value: type,
                          icon: Icon(employeeManagerChangeTypeIcon(type)),
                          label: Text(type.label),
                        ),
                      )
                      .toList(),
              selected: {profile.changeType},
              onSelectionChanged:
                  (selection) => onChangeTypeChanged(selection.single),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Current manager ${profile.currentManager}',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: HrisColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: targetManagerController,
            decoration: const InputDecoration(
              labelText: 'Target manager',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.supervisor_account_outlined),
            ),
            onChanged: onTargetManagerChanged,
          ),
          const SizedBox(height: 12),
          _EffectiveDateField(profile: profile, onTap: onSelectEffectiveDate),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Change reason',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onReasonChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: profile.readinessRatio,
            color: progressColor,
            label:
                '${(profile.readinessRatio * 100).round()}% ready, ${profile.daysUntilEffective} day(s) to effective date',
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

class EmployeeManagerChangeChecklistTile extends StatelessWidget {
  final EmployeeManagerChangeChecklistItem item;
  final DateTime asOfDate;
  final ValueChanged<EmployeeManagerChangeChecklistStatus> onStatusChanged;
  final VoidCallback onWaive;
  final VoidCallback onReopen;
  final VoidCallback onRemove;

  const EmployeeManagerChangeChecklistTile({
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
    final statusColor = employeeManagerChangeStatusColor(item.status);
    final riskColor = employeeManagerChangeRiskColor(item.risk);
    final typeIcon = employeeManagerChangeChecklistIcon(item.type);
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
                  employeeManagerChangeStatusIcon(item.status),
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
                    const SizedBox(height: 4),
                    Text(
                      item.detail,
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
              HrisStatusPill(label: item.status.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: typeIcon, label: item.type.label),
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
              PopupMenuButton<EmployeeManagerChangeChecklistStatus>(
                tooltip: 'Update checklist status',
                onSelected: onStatusChanged,
                itemBuilder:
                    (context) =>
                        EmployeeManagerChangeChecklistStatus.values
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
              if (item.status == EmployeeManagerChangeChecklistStatus.waived)
                TextButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.undo_outlined),
                  label: const Text('Reopen'),
                )
              else if (!item.isReady)
                TextButton.icon(
                  onPressed: onWaive,
                  icon: const Icon(Icons.do_not_disturb_on_outlined),
                  label: const Text('Waive'),
                ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove checklist item',
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
  final EmployeeManagerChangeReadinessProfile profile;
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
