import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_next_action_models.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_sla_models.dart';
import 'employee_next_action_styles.dart';

/// Summary metrics for cross-source HR workflow inbox SLA health.
class EmployeeWorkflowInboxSlaSummaryStrip extends StatelessWidget {
  final EmployeeWorkflowInboxSlaProfile profile;

  const EmployeeWorkflowInboxSlaSummaryStrip({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Escalated',
          value: '${profile.escalatedCount}',
        ),
        HrisMetricStripItem(label: 'Ready', value: '${profile.readyCount}'),
        HrisMetricStripItem(label: 'Overdue', value: '${profile.overdueCount}'),
        HrisMetricStripItem(
          label: 'Owner risk',
          value: '${profile.ownerRiskCount}',
        ),
      ],
    );
  }
}

/// Compact owner workload board for HR workflow inbox SLA triage.
class EmployeeWorkflowInboxSlaOwnerLoadBoard extends StatelessWidget {
  final List<EmployeeWorkflowInboxSlaOwnerLoad> loads;

  const EmployeeWorkflowInboxSlaOwnerLoadBoard({
    super.key,
    required this.loads,
  });

  @override
  Widget build(BuildContext context) {
    if (loads.isEmpty) {
      return const HrisEmptyState(message: 'No active workflow inbox SLA load');
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

/// Compact card for one HR workflow inbox SLA signal.
class EmployeeWorkflowInboxSlaSignalTile extends StatelessWidget {
  final EmployeeWorkflowInboxSlaSignal signal;

  const EmployeeWorkflowInboxSlaSignalTile({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final stateColor = _stateColor(signal.state);
    final escalationColor = _escalationColor(signal.escalationLevel);
    final areaIcon = employeeNextActionAreaIcon(signal.area);

    return HrisListSurface(
      key: ValueKey('employee-workflow-inbox-sla-signal-${signal.itemId}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _stateIcon(signal.state),
                  color: stateColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
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
                    const SizedBox(height: 3),
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
          const SizedBox(height: 10),
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
              _MetaChip(icon: Icons.hub_outlined, label: signal.source.label),
              if (signal.action != EmployeeWorkflowInboxAction.none)
                _MetaChip(
                  icon: Icons.playlist_add_check_outlined,
                  label: signal.action.label,
                  color: const Color(0xFF15803D),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee workflow inbox SLA summary')
Widget employeeWorkflowInboxSlaSummaryStripPreview() {
  final profile = _previewProfile;

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaSummaryStrip(profile: profile),
      ),
    ),
  );
}

@Preview(name: 'Employee workflow inbox SLA owners')
Widget employeeWorkflowInboxSlaOwnerLoadBoardPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaOwnerLoadBoard(
          loads: _previewProfile.ownerLoads,
        ),
      ),
    ),
  );
}

@Preview(name: 'Employee workflow inbox SLA signal')
Widget employeeWorkflowInboxSlaSignalTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaSignalTile(signal: _previewSignal),
      ),
    ),
  );
}

/// Compact owner load tile used by the workflow inbox SLA board.
class _OwnerLoadTile extends StatelessWidget {
  final EmployeeWorkflowInboxSlaOwnerLoad load;

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
              _MiniMetric(label: 'Ready', value: '${load.readyCount}'),
              _MiniMetric(label: 'Overdue', value: '${load.overdueCount}'),
              _MiniMetric(label: 'Due', value: '${load.dueSoonCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact metadata chip used by workflow inbox SLA signal cards.
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    this.color = HrisColors.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small metric badge used inside workflow inbox SLA owner tiles.
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

EmployeeWorkflowInboxSlaProfile get _previewProfile {
  return EmployeeWorkflowInboxSlaProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    signals: [_previewSignal],
    ownerLoads: const [
      EmployeeWorkflowInboxSlaOwnerLoad(
        owner: 'People Operations',
        activeCount: 3,
        readyCount: 2,
        overdueCount: 1,
        dueSoonCount: 1,
        leadershipCount: 1,
      ),
    ],
  );
}

EmployeeWorkflowInboxSlaSignal get _previewSignal {
  return EmployeeWorkflowInboxSlaSignal(
    itemId: 'profile-change-EPC-4-001',
    sourceRecordId: 'EPC-4-001',
    title: 'Manager change',
    owner: 'People Operations',
    source: EmployeeWorkflowInboxSource.profileChange,
    action: EmployeeWorkflowInboxAction.apply,
    area: EmployeeNextActionArea.work,
    priority: EmployeeNextActionPriority.high,
    dueDate: DateTime(2026, 6, 1),
    daysUntilDue: 0,
    isReady: true,
    state: EmployeeWorkflowInboxSlaState.dueToday,
    escalationLevel: EmployeeWorkflowInboxEscalationLevel.watch,
    recommendation: 'Run the ready inbox action before SLA drift.',
  );
}

Color _stateColor(EmployeeWorkflowInboxSlaState state) {
  return switch (state) {
    EmployeeWorkflowInboxSlaState.overdue => const Color(0xFFB91C1C),
    EmployeeWorkflowInboxSlaState.dueToday => const Color(0xFFD97706),
    EmployeeWorkflowInboxSlaState.dueSoon => HrisColors.primary,
    EmployeeWorkflowInboxSlaState.onTrack => const Color(0xFF15803D),
  };
}

Color _escalationColor(EmployeeWorkflowInboxEscalationLevel escalation) {
  return switch (escalation) {
    EmployeeWorkflowInboxEscalationLevel.leadership => const Color(0xFFB91C1C),
    EmployeeWorkflowInboxEscalationLevel.manager => const Color(0xFFD97706),
    EmployeeWorkflowInboxEscalationLevel.watch => HrisColors.primary,
    EmployeeWorkflowInboxEscalationLevel.none => HrisColors.muted,
  };
}

IconData _stateIcon(EmployeeWorkflowInboxSlaState state) {
  return switch (state) {
    EmployeeWorkflowInboxSlaState.overdue => Icons.warning_amber_outlined,
    EmployeeWorkflowInboxSlaState.dueToday => Icons.today_outlined,
    EmployeeWorkflowInboxSlaState.dueSoon => Icons.upcoming_outlined,
    EmployeeWorkflowInboxSlaState.onTrack => Icons.check_circle_outline,
  };
}

String _dueLabel(EmployeeWorkflowInboxSlaSignal signal) {
  final due = DateFormat('MMM d, yyyy').format(signal.dueDate);
  if (signal.daysUntilDue < 0) {
    return '${signal.daysUntilDue.abs()}d overdue';
  }
  if (signal.daysUntilDue == 0) return 'Due today';
  return 'Due in ${signal.daysUntilDue}d - $due';
}
