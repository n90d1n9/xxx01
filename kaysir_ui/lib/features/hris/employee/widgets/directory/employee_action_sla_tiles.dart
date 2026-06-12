import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_action_sla_models.dart';
import 'employee_action_sla_styles.dart';
import 'employee_next_action_styles.dart';

class EmployeeActionSlaSummaryStrip extends StatelessWidget {
  final EmployeeActionSlaProfile profile;

  const EmployeeActionSlaSummaryStrip({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Escalated',
          value: '${profile.escalatedCount}',
        ),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
        HrisMetricStripItem(label: 'Today', value: '${profile.dueTodayCount}'),
        HrisMetricStripItem(
          label: 'Owner risk',
          value: '${profile.ownerRiskCount}',
        ),
      ],
    );
  }
}

class EmployeeActionOwnerLoadBoard extends StatelessWidget {
  final List<EmployeeActionOwnerLoad> loads;

  const EmployeeActionOwnerLoadBoard({super.key, required this.loads});

  @override
  Widget build(BuildContext context) {
    if (loads.isEmpty) {
      return const HrisEmptyState(message: 'No active owner SLA load');
    }

    return HrisListSurface(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children:
            loads.take(4).map((load) => _OwnerLoadTile(load: load)).toList(),
      ),
    );
  }
}

class EmployeeActionSlaSignalTile extends StatelessWidget {
  final EmployeeActionSlaSignal signal;

  const EmployeeActionSlaSignalTile({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final stateColor = employeeActionSlaStateColor(signal.state);
    final escalationColor = employeeActionEscalationColor(
      signal.escalationLevel,
    );
    final areaIcon = employeeNextActionAreaIcon(signal.area);

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
                  color: stateColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  employeeActionSlaStateIcon(signal.state),
                  color: stateColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signal.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      signal.recommendation,
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
              HrisStatusPill(label: signal.state.label, color: stateColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              HrisStatusPill(
                label: signal.escalationLevel.label,
                color: escalationColor,
              ),
              _MetaChip(icon: areaIcon, label: signal.area.label),
              _MetaChip(
                icon: Icons.person_outline,
                label: signal.owner,
                color: HrisColors.ink,
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: _dueLabel(signal),
                color: stateColor,
              ),
              _MetaChip(
                icon: Icons.hub_outlined,
                label: signal.sourceLabel,
                color: HrisColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _dueLabel(EmployeeActionSlaSignal signal) {
    final due = DateFormat('MMM d, yyyy').format(signal.dueDate);
    if (signal.daysUntilDue < 0) {
      return '${signal.daysUntilDue.abs()}d overdue';
    }
    if (signal.daysUntilDue == 0) {
      return 'Due today';
    }
    return 'Due in ${signal.daysUntilDue}d - $due';
  }
}

class _OwnerLoadTile extends StatelessWidget {
  final EmployeeActionOwnerLoad load;

  const _OwnerLoadTile({required this.load});

  @override
  Widget build(BuildContext context) {
    final color =
        load.needsBalancing ? const Color(0xFFD97706) : const Color(0xFF15803D);

    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle_outlined, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  load.owner,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(label: '${load.activeCount}', color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            load.recommendation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MiniMetric(label: 'Overdue', value: '${load.overdueCount}'),
              _MiniMetric(label: 'Due', value: '${load.dueSoonCount}'),
              _MiniMetric(label: 'Critical', value: '${load.criticalCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Text(
        '$label $value',
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: HrisColors.muted,
          fontWeight: FontWeight.w700,
        ),
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
