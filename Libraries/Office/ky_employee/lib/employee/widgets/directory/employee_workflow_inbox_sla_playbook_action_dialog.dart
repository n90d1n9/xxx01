import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_action_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_models.dart';

/// Opens a reason form before recording a workflow inbox SLA playbook action.
Future<String?> showEmployeeWorkflowInboxSlaPlaybookActionDialog(
  BuildContext context, {
  required EmployeeWorkflowInboxSlaPlaybookStep step,
}) {
  return showDialog<String>(
    context: context,
    builder:
        (context) => EmployeeWorkflowInboxSlaPlaybookActionDialog(step: step),
  );
}

/// Dialog form used to capture why a workflow inbox SLA action is recorded.
class EmployeeWorkflowInboxSlaPlaybookActionDialog extends StatefulWidget {
  final EmployeeWorkflowInboxSlaPlaybookStep step;

  const EmployeeWorkflowInboxSlaPlaybookActionDialog({
    super.key,
    required this.step,
  });

  @override
  State<EmployeeWorkflowInboxSlaPlaybookActionDialog> createState() =>
      _EmployeeWorkflowInboxSlaPlaybookActionDialogState();
}

/// Holds form state for the workflow inbox SLA playbook action reason dialog.
class _EmployeeWorkflowInboxSlaPlaybookActionDialogState
    extends State<EmployeeWorkflowInboxSlaPlaybookActionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = employeeWorkflowInboxSlaPlaybookActionForStep(widget.step);

    return AlertDialog(
      key: const ValueKey('employee-workflow-inbox-sla-playbook-action-dialog'),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: HrisColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_actionIcon(action), color: HrisColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Record playbook action',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.step.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ActionContextChip(
                      icon: Icons.badge_outlined,
                      label: widget.step.owner,
                    ),
                    _ActionContextChip(
                      icon: Icons.format_list_numbered_outlined,
                      label: widget.step.countLabel,
                    ),
                    _ActionContextChip(
                      icon: Icons.hub_outlined,
                      label: widget.step.sourceLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey(
                    'employee-workflow-inbox-sla-playbook-action-reason-field',
                  ),
                  controller: _reasonController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 180,
                  decoration: const InputDecoration(
                    labelText: 'Action reason',
                    hintText: 'Add operational context',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Add a reason before recording this action';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _reasonSuggestions(action)
                          .map(
                            (reason) => ActionChip(
                              key: ValueKey(
                                'employee-workflow-inbox-sla-playbook-action-reason-suggestion-${_reasonKey(reason)}',
                              ),
                              avatar: const Icon(
                                Icons.auto_awesome_outlined,
                                size: 16,
                              ),
                              label: Text(reason),
                              onPressed: () => _reasonController.text = reason,
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey(
            'employee-workflow-inbox-sla-playbook-action-cancel-button',
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey(
            'employee-workflow-inbox-sla-playbook-action-record-button',
          ),
          onPressed: _submit,
          icon: const Icon(Icons.receipt_long_outlined, size: 18),
          label: const Text('Record action'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_reasonController.text.trim());
  }
}

@Preview(name: 'Employee workflow inbox SLA playbook action dialog')
Widget employeeWorkflowInboxSlaPlaybookActionDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: EmployeeWorkflowInboxSlaPlaybookActionDialog(step: _previewStep),
      ),
    ),
  );
}

/// Metadata chip shown inside the workflow inbox SLA playbook action dialog.
class _ActionContextChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionContextChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HrisColors.muted),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

EmployeeWorkflowInboxSlaPlaybookStep get _previewStep {
  return EmployeeWorkflowInboxSlaPlaybookStep(
    id: 'ready',
    type: EmployeeWorkflowInboxSlaPlaybookStepType.readyClearance,
    urgency: EmployeeWorkflowInboxSlaPlaybookUrgency.high,
    title: 'Clear ready inbox actions',
    detail: 'Run ready workflow actions before the SLA queue drifts.',
    owner: 'People Operations',
    signalIds: const ['profile-change-EPC-4-001'],
    sources: const [EmployeeWorkflowInboxSource.profileChange],
    dueDate: DateTime(2026, 6, 1),
  );
}

List<String> _reasonSuggestions(
  EmployeeWorkflowInboxSlaPlaybookActionType action,
) {
  return switch (action) {
    EmployeeWorkflowInboxSlaPlaybookActionType.markEscalated => const [
      'SLA risk requires leadership visibility',
      'Manager queue needs urgent unblock',
      'Employee impact requires escalation',
    ],
    EmployeeWorkflowInboxSlaPlaybookActionType.assignBackup => const [
      'Owner capacity is above recovery threshold',
      'Backup reviewer needed to protect SLA',
      'Redistribute queue before deadline',
    ],
    EmployeeWorkflowInboxSlaPlaybookActionType.startRecovery => const [
      'Ready work can be cleared today',
      'Recovery started to prevent SLA drift',
      'Queue has actionable items for closure',
    ],
    EmployeeWorkflowInboxSlaPlaybookActionType.confirmProgress => const [
      'Progress confirmed before due date',
      'Owner has acknowledged the watch item',
      'Monitoring continues until completion',
    ],
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

String _reasonKey(String reason) {
  final key = reason
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('-+'), '-')
      .replaceAll(RegExp('^-|-\$'), '');
  return key.isEmpty ? 'reason' : key;
}
