import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_action_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_models.dart';

/// Filter controls for employee workflow inbox SLA playbook audit history.
class EmployeeWorkflowInboxSlaPlaybookActionFilterStrip
    extends StatelessWidget {
  final EmployeeWorkflowInboxSlaPlaybookActionProfile profile;
  final EmployeeWorkflowInboxSlaPlaybookActionAuditFilter filter;
  final ValueChanged<EmployeeWorkflowInboxSlaPlaybookActionAuditFilter>
  onChanged;

  const EmployeeWorkflowInboxSlaPlaybookActionFilterStrip({
    super.key,
    required this.profile,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filteredCount = profile.receiptsForFilter(filter).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FilterGroup(
          label: 'Action',
          children: [
            _FilterChoiceChip(
              key: const ValueKey(
                'employee-workflow-inbox-sla-playbook-action-filter-all',
              ),
              icon: Icons.all_inbox_outlined,
              label: 'All actions',
              selected: filter.actionType == null,
              onSelected: () => onChanged(filter.withActionType(null)),
            ),
            ...profile.actionTypes.map(
              (action) => _FilterChoiceChip(
                key: ValueKey(
                  'employee-workflow-inbox-sla-playbook-action-filter-${action.name}',
                ),
                icon: _actionIcon(action),
                label: action.label,
                selected: filter.actionType == action,
                onSelected: () => onChanged(filter.withActionType(action)),
              ),
            ),
          ],
        ),
        if (profile.ownerNames.isNotEmpty) ...[
          const SizedBox(height: 10),
          _FilterGroup(
            label: 'Owner',
            children: [
              _FilterChoiceChip(
                key: const ValueKey(
                  'employee-workflow-inbox-sla-playbook-owner-filter-all',
                ),
                icon: Icons.groups_outlined,
                label: 'All owners',
                selected: filter.owner == null,
                onSelected: () => onChanged(filter.withOwner(null)),
              ),
              ...profile.ownerNames.map(
                (owner) => _FilterChoiceChip(
                  key: ValueKey(
                    'employee-workflow-inbox-sla-playbook-owner-filter-${_ownerKey(owner)}',
                  ),
                  icon: Icons.badge_outlined,
                  label: owner,
                  selected: filter.owner == owner,
                  onSelected: () => onChanged(filter.withOwner(owner)),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Showing $filteredCount of ${profile.totalCount} audit events',
                key: const ValueKey(
                  'employee-workflow-inbox-sla-playbook-action-filter-summary',
                ),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: HrisColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (filter.isActive)
              TextButton.icon(
                key: const ValueKey(
                  'employee-workflow-inbox-sla-playbook-action-filter-clear',
                ),
                onPressed: () => onChanged(filter.clear()),
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear'),
              ),
          ],
        ),
      ],
    );
  }
}

@Preview(name: 'Employee workflow inbox SLA playbook action filters')
Widget employeeWorkflowInboxSlaPlaybookActionFilterStripPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeWorkflowInboxSlaPlaybookActionFilterStrip(
          profile: _previewActionProfile,
          filter: const EmployeeWorkflowInboxSlaPlaybookActionAuditFilter(
            actionType:
                EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
          ),
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Labeled chip group used by the playbook audit filter strip.
class _FilterGroup extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FilterGroup({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

/// Compact selectable chip for workflow inbox SLA playbook audit filters.
class _FilterChoiceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChoiceChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      avatar: Icon(icon, size: 16, color: selected ? HrisColors.primary : null),
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: selected ? HrisColors.primary : HrisColors.ink,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? HrisColors.primary : HrisColors.border,
        ),
      ),
      selectedColor: HrisColors.primary.withValues(alpha: 0.12),
      backgroundColor: HrisColors.surface,
      visualDensity: VisualDensity.compact,
    );
  }
}

EmployeeWorkflowInboxSlaPlaybookActionProfile get _previewActionProfile {
  return EmployeeWorkflowInboxSlaPlaybookActionProfile(
    employeeId: '4',
    employeeName: 'David Kim',
    asOfDate: DateTime(2026, 6, 1),
    receipts: [
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-002',
        employeeId: '4',
        employeeName: 'David Kim',
        stepId: 'ready',
        stepTitle: 'Clear ready inbox actions',
        stepType: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
        actionType: EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery,
        actor: 'People Operations',
        owner: 'People Operations',
        itemCount: 2,
        sources: const [EmployeeWorkflowInboxSource.profileChange],
        decidedAt: DateTime(2026, 6, 1),
      ),
      EmployeeWorkflowInboxSlaPlaybookActionReceipt(
        id: 'EWP-4-001',
        employeeId: '4',
        employeeName: 'David Kim',
        stepId: 'rebalance',
        stepTitle: 'Balance inbox owner load',
        stepType: EmployeeWorkflowInboxSlaPlaybookStepType.ownerRebalance,
        actionType: EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup,
        actor: 'HR Lead',
        owner: 'HR Business Partner',
        itemCount: 3,
        sources: const [
          EmployeeWorkflowInboxSource.actionWorkflow,
          EmployeeWorkflowInboxSource.jobAssignment,
        ],
        decidedAt: DateTime(2026, 5, 31),
      ),
    ],
  );
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

String _ownerKey(String owner) {
  final key = owner
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('-+'), '-')
      .replaceAll(RegExp('^-|-\$'), '');
  return key.isEmpty ? 'unknown' : key;
}
