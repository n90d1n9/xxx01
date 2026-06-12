import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_workflow_inbox_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_action_models.dart';
import '../../models/employee_workflow_inbox_sla_playbook_models.dart';

/// Opens a form for correcting a workflow inbox SLA playbook action reason.
Future<String?> showEmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog(
  BuildContext context, {
  required EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt,
}) {
  return showDialog<String>(
    context: context,
    builder:
        (context) => EmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog(
          receipt: receipt,
        ),
  );
}

/// Dialog that records a corrected reason without mutating the source receipt.
class EmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog
    extends StatefulWidget {
  final EmployeeWorkflowInboxSlaPlaybookActionReceipt receipt;

  const EmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog({
    super.key,
    required this.receipt,
  });

  @override
  State<EmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog> createState() =>
      _EmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialogState();
}

/// Holds form state for the workflow inbox SLA playbook reason correction form.
class _EmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialogState
    extends State<EmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(
      text: widget.receipt.hasReason ? widget.receipt.reasonLabel : '',
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const ValueKey(
        'employee-workflow-inbox-sla-playbook-reason-correction-dialog',
      ),
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_note_outlined,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Correct reason',
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
                  widget.receipt.actionType.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.receipt.stepTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.receipt.hasReason)
                  _PreviousReasonPanel(reason: widget.receipt.reasonLabel),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey(
                    'employee-workflow-inbox-sla-playbook-reason-correction-field',
                  ),
                  controller: _reasonController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 180,
                  decoration: const InputDecoration(
                    labelText: 'Corrected reason',
                    hintText: 'Update the audit reason',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateReason,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey(
            'employee-workflow-inbox-sla-playbook-reason-correction-cancel-button',
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          key: const ValueKey(
            'employee-workflow-inbox-sla-playbook-reason-correction-save-button',
          ),
          onPressed: _submit,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save correction'),
        ),
      ],
    );
  }

  String? _validateReason(String? value) {
    final normalized = _normalizeReason(value ?? '');
    if (normalized.isEmpty) {
      return 'Add a corrected reason';
    }
    if (normalized == widget.receipt.reasonLabel) {
      return 'Change the reason before saving';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_normalizeReason(_reasonController.text));
  }

  String _normalizeReason(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

@Preview(name: 'Employee workflow inbox SLA playbook reason correction dialog')
Widget employeeWorkflowInboxSlaPlaybookReasonCorrectionDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: EmployeeWorkflowInboxSlaPlaybookReasonCorrectionDialog(
          receipt: _previewReceipt,
        ),
      ),
    ),
  );
}

/// Read-only panel showing the previous playbook audit reason.
class _PreviousReasonPanel extends StatelessWidget {
  final String reason;

  const _PreviousReasonPanel({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HrisColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.history_outlined, size: 16, color: HrisColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reason,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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

EmployeeWorkflowInboxSlaPlaybookActionReceipt get _previewReceipt {
  return EmployeeWorkflowInboxSlaPlaybookActionReceipt(
    id: 'EWP-4-001',
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
    reason: 'Recovery started to prevent SLA drift',
    decidedAt: DateTime(2026, 6, 1),
  );
}
