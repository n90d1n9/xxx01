import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_action_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_models.dart';

/// Summary metrics for an employee workflow inbox SLA recovery playbook.
class EmployeeWorkflowInboxSlaPlaybookSummaryStrip extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybook playbook;

  const EmployeeWorkflowInboxSlaPlaybookSummaryStrip({
    super.key,
    required this.playbook,
  });

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(label: 'Steps', value: '${playbook.totalCount}'),
        HrisMetricStripItem(
          label: 'Critical',
          value: '${playbook.criticalCount}',
        ),
        HrisMetricStripItem(
          label: 'Items',
          value: '${playbook.recoveryItemCount}',
        ),
      ],
    );
  }
}

/// Compact card for one workflow inbox SLA recovery playbook step.
class EmployeeWorkflowInboxSlaPlaybookStepTile extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookStep step;
  final EmployeeWorkflowInboxSlaPlaybookActionReceipt? latestReceipt;
  final VoidCallback? onPrimaryAction;

  const EmployeeWorkflowInboxSlaPlaybookStepTile({
    super.key,
    required this.step,
    this.latestReceipt,
    this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = _urgencyColor(step.urgency);
    final actionType = employeeWorkflowInboxSlaPlaybookActionForStep(step);

    return HrisListSurface(
      key: ValueKey('employee-workflow-inbox-sla-playbook-step-${step.id}'),
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon(step.type), color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      step.detail,
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
              HrisStatusPill(label: step.urgency.label, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PlaybookMetaChip(
                icon: Icons.playlist_add_check_outlined,
                label: step.type.label,
                color: color,
              ),
              _PlaybookMetaChip(
                icon: Icons.person_outline,
                label: step.owner,
                color: HrisColors.ink,
              ),
              _PlaybookMetaChip(
                icon: Icons.hub_outlined,
                label: step.sourceLabel,
              ),
              _PlaybookMetaChip(
                icon: Icons.format_list_numbered_outlined,
                label: step.countLabel,
              ),
              _PlaybookMetaChip(
                icon: Icons.event_outlined,
                label: _formatDate(step.dueDate),
              ),
              if (latestReceipt != null)
                _PlaybookMetaChip(
                  icon: Icons.receipt_long_outlined,
                  label: latestReceipt!.actionLabel,
                  color: const Color(0xFF15803D),
                ),
            ],
          ),
          if (latestReceipt != null) ...[
            const SizedBox(height: 10),
            Text(
              latestReceipt!.summaryLabel,
              key: ValueKey(
                'employee-workflow-inbox-sla-playbook-receipt-${latestReceipt!.id}',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF15803D),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: ValueKey(
                'employee-workflow-inbox-sla-playbook-action-${step.id}',
              ),
              onPressed: onPrimaryAction,
              icon: Icon(_actionIcon(actionType), size: 18),
              label: Text(actionType.label),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee workflow inbox SLA playbook summary')
Widget employeeWorkflowInboxSlaPlaybookSummaryStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaPlaybookSummaryStrip(
          playbook: _previewPlaybook,
        ),
      ),
    ),
  );
}

@Preview(name: 'Employee workflow inbox SLA playbook step')
Widget employeeWorkflowInboxSlaPlaybookStepTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaPlaybookStepTile(
          step: _previewPlaybook.topSteps.first,
          onPrimaryAction: () {},
        ),
      ),
    ),
  );
}

/// Compact metadata chip used inside workflow inbox SLA playbook cards.
class _PlaybookMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PlaybookMetaChip({
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

EmployeeWorkflowInboxSlaPlaybook get _previewPlaybook {
  return EmployeeWorkflowInboxSlaPlaybook(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    steps: [
      EmployeeWorkflowInboxSlaPlaybookStep(
        id: 'ready',
        type: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
        urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.high,
        title: 'Clear ready inbox actions',
        detail: 'Run ready workflow actions before the SLA queue drifts.',
        owner: 'People Operations',
        signalIds: const ['profile-change-EPC-4-001'],
        sources: const [EmployeeWorkflowInboxSource.profileChange],
        dueDate: DateTime(2026, 6, 1),
      ),
    ],
  );
}

Color _urgencyColor(EmployeeWorkflowInboxSlaPlaybookUrgency urgency) {
  return switch (urgency) {
    EmployeeWorkflowInboxSlaPlaybookUrgency.critical => const Color(0xFFB91C1C),
    EmployeeWorkflowInboxSlaPlaybookUrgency.high => const Color(0xFFD97706),
    EmployeeWorkflowInboxSlaPlaybookUrgency.medium => HrisColors.primary,
    EmployeeWorkflowInboxSlaPlaybookUrgency.low => const Color(0xFF15803D),
  };
}

IconData _typeIcon(EmployeeWorkflowInboxSlaPlaybookStepType type) {
  return switch (type) {
    EmployeeWorkflowInboxSlaPlaybookStepType.leadershipEscalation =>
      Icons.priority_high_outlined,
    EmployeeWorkflowInboxSlaPlaybookStepType.managerEscalation =>
      Icons.supervisor_account_outlined,
    EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance =>
      Icons.bolt_outlined,
    EmployeeWorkflowInboxSlaPlaybookStepType.overdueRecovery =>
      Icons.warning_amber_outlined,
    EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance =>
      Icons.balance_outlined,
    EmployeeWorkflowInboxSlaPlaybookStepType.dueSoonWatch =>
      Icons.upcoming_outlined,
  };
}

IconData _actionIcon(EmployeeWorkflowInboxSlaPlaybookActionType action) {
  return switch (action) {
    EmployeeWorkflowInboxSlaPlaybookActionType.markEscalated =>
      Icons.priority_high_outlined,
    EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup =>
      Icons.group_add_outlined,
    EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery =>
      Icons.play_arrow_outlined,
    EmployeeWorkflowInboxSlaPlaybookActionType.confirmProgress =>
      Icons.check_circle_outline,
  };
}

String _formatDate(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}
