import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_payroll_run_console_audit_decision_models.dart';

/// Approver decision form for payroll audit handoff approval or return notes.
class EmployeePayrollRunConsoleAuditDecisionForm extends StatelessWidget {
  final TextEditingController noteController;
  final EmployeePayrollRunConsoleAuditDecisionDraft draft;
  final ValueChanged<EmployeePayrollRunConsoleAuditDecisionDraft>
  onDraftChanged;
  final VoidCallback? onApprove;
  final VoidCallback? onReturn;

  const EmployeePayrollRunConsoleAuditDecisionForm({
    super.key,
    required this.noteController,
    required this.draft,
    required this.onDraftChanged,
    this.onApprove,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final note = draft.note;
    final approveEnabled = onApprove != null && draft.canApprove;
    final returnEnabled = onReturn != null && draft.canReturn;
    final visibleHint =
        note.trim().isNotEmpty && note.trim().length < 8
            ? 'Return note must be at least 8 characters.'
            : draft.approvalHint;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HrisColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: HrisColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Attested',
                value: draft.attestationLabel,
              ),
              HrisMetricStripItem(
                label: 'Approval',
                value: draft.canApprove ? 'Ready' : 'Blocked',
              ),
              HrisMetricStripItem(
                label: 'Return',
                value: draft.canReturn ? 'Ready' : 'Needs note',
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final attestation
              in EmployeePayrollRunConsoleAuditDecisionAttestation.values)
            _DecisionAttestationCheckbox(
              attestation: attestation,
              selected: draft.isAttested(attestation),
              onChanged:
                  (selected) => onDraftChanged(
                    draft.toggleAttestation(attestation, selected),
                  ),
            ),
          const SizedBox(height: 10),
          TextField(
            key: const ValueKey('employee-payroll-audit-decision-note-field'),
            controller: noteController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Decision note',
              prefixIcon: Icon(Icons.rate_review_outlined),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => onDraftChanged(draft.copyWith(note: value)),
          ),
          const SizedBox(height: 8),
          Text(
            visibleHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  note.trim().isNotEmpty && note.trim().length < 8
                      ? const Color(0xFFB91C1C)
                      : HrisColors.muted,
              fontWeight:
                  note.trim().isNotEmpty && note.trim().length < 8
                      ? FontWeight.w700
                      : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const ValueKey(
                  'employee-payroll-audit-decision-approve-button',
                ),
                onPressed: approveEnabled ? onApprove : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve'),
              ),
              OutlinedButton.icon(
                key: const ValueKey(
                  'employee-payroll-audit-decision-return-button',
                ),
                onPressed: returnEnabled ? onReturn : null,
                icon: const Icon(Icons.undo_outlined),
                label: const Text('Return'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Checkbox row for one payroll audit approval attestation.
class _DecisionAttestationCheckbox extends StatelessWidget {
  final EmployeePayrollRunConsoleAuditDecisionAttestation attestation;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _DecisionAttestationCheckbox({
    required this.attestation,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CheckboxListTile(
        key: ValueKey(
          'employee-payroll-audit-decision-attestation-${attestation.name}',
        ),
        value: selected,
        onChanged: (value) => onChanged(value ?? false),
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        title: Text(
          attestation.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          attestation.detail,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
        ),
      ),
    );
  }
}

@Preview(name: 'Employee payroll audit decision form')
Widget employeePayrollRunConsoleAuditDecisionFormPreview() {
  final controller = TextEditingController(
    text: 'Approve close archive after validating bank proof.',
  );
  final draft = EmployeePayrollRunConsoleAuditDecisionDraft(
    note: controller.text,
    attestations:
        EmployeePayrollRunConsoleAuditDecisionAttestation.values.toSet(),
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeePayrollRunConsoleAuditDecisionForm(
          noteController: controller,
          draft: draft,
          onDraftChanged: (_) {},
          onApprove: () {},
          onReturn: () {},
        ),
      ),
    ),
  );
}
