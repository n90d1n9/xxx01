import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_profile_change_governance_models.dart';

/// Form for submitting an effective-dated employee profile change request.
class EmployeeProfileChangeGovernanceForm extends StatelessWidget {
  final EmployeeProfileChangeDraft draft;
  final TextEditingController currentValueController;
  final TextEditingController proposedValueController;
  final TextEditingController reasonController;
  final TextEditingController requesterController;
  final TextEditingController reviewerController;
  final TextEditingController approverController;
  final ValueChanged<EmployeeProfileChangeField> onFieldChanged;
  final ValueChanged<String> onCurrentValueChanged;
  final ValueChanged<String> onProposedValueChanged;
  final ValueChanged<String> onReasonChanged;
  final ValueChanged<String> onRequesterChanged;
  final ValueChanged<String> onReviewerChanged;
  final ValueChanged<String> onApproverChanged;
  final VoidCallback onSelectEffectiveDate;
  final VoidCallback onSubmit;

  const EmployeeProfileChangeGovernanceForm({
    super.key,
    required this.draft,
    required this.currentValueController,
    required this.proposedValueController,
    required this.reasonController,
    required this.requesterController,
    required this.reviewerController,
    required this.approverController,
    required this.onFieldChanged,
    required this.onCurrentValueChanged,
    required this.onProposedValueChanged,
    required this.onReasonChanged,
    required this.onRequesterChanged,
    required this.onReviewerChanged,
    required this.onApproverChanged,
    required this.onSelectEffectiveDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeProfileChangeField>(
            key: const ValueKey('employee-profile-change-field-dropdown'),
            initialValue: draft.field,
            decoration: const InputDecoration(
              labelText: 'Change field',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tune_outlined),
            ),
            items:
                EmployeeProfileChangeField.values
                    .map(
                      (field) => DropdownMenuItem(
                        value: field,
                        child: Text(field.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onFieldChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _ProfileChangeTextField(
            key: const ValueKey('employee-profile-change-current-field'),
            controller: currentValueController,
            label: 'Current value',
            icon: Icons.history_outlined,
            onChanged: onCurrentValueChanged,
          ),
          const SizedBox(height: 12),
          _ProfileChangeTextField(
            key: const ValueKey('employee-profile-change-proposed-field'),
            controller: proposedValueController,
            label: 'Proposed value',
            icon: Icons.edit_outlined,
            onChanged: onProposedValueChanged,
          ),
          const SizedBox(height: 12),
          _EffectiveDateField(draft: draft, onTap: onSelectEffectiveDate),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ProfileChangeTextField(
                  key: const ValueKey(
                    'employee-profile-change-requester-field',
                  ),
                  controller: requesterController,
                  label: 'Requester',
                  icon: Icons.person_outline,
                  onChanged: onRequesterChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfileChangeTextField(
                  key: const ValueKey('employee-profile-change-reviewer-field'),
                  controller: reviewerController,
                  label: 'Reviewer',
                  icon: Icons.person_search_outlined,
                  onChanged: onReviewerChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileChangeTextField(
            key: const ValueKey('employee-profile-change-approver-field'),
            controller: approverController,
            label: 'Approver',
            icon: Icons.verified_user_outlined,
            onChanged: onApproverChanged,
          ),
          const SizedBox(height: 12),
          _ProfileChangeTextField(
            key: const ValueKey('employee-profile-change-reason-field'),
            controller: reasonController,
            label: 'Reason',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onReasonChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToSubmit
                    ? const Color(0xFF15803D)
                    : HrisColors.primary,
            label: '${(draft.completionRatio * 100).round()}% ready',
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB91C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const ValueKey('employee-profile-change-submit-button'),
              onPressed: draft.isReadyToSubmit ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Submit change'),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee profile change governance form')
Widget employeeProfileChangeGovernanceFormPreview() {
  final draft = EmployeeProfileChangeDraft(
    employeeId: '1',
    employeeName: 'Sarah Johnson',
    asOfDate: DateTime(2026, 6, 1),
    field: EmployeeProfileChangeField.manager,
    currentValue: 'Emma Rodriguez',
    proposedValue: 'David Kim',
    effectiveDate: DateTime(2026, 6, 15),
    reason: 'Move reporting line for the new product squad.',
    requester: 'People Operations',
    reviewer: 'HR Business Partner',
    approver: 'People Director',
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EmployeeProfileChangeGovernanceForm(
          draft: draft,
          currentValueController: TextEditingController(
            text: draft.currentValue,
          ),
          proposedValueController: TextEditingController(
            text: draft.proposedValue,
          ),
          reasonController: TextEditingController(text: draft.reason),
          requesterController: TextEditingController(text: draft.requester),
          reviewerController: TextEditingController(text: draft.reviewer),
          approverController: TextEditingController(text: draft.approver),
          onFieldChanged: (_) {},
          onCurrentValueChanged: (_) {},
          onProposedValueChanged: (_) {},
          onReasonChanged: (_) {},
          onRequesterChanged: (_) {},
          onReviewerChanged: (_) {},
          onApproverChanged: (_) {},
          onSelectEffectiveDate: () {},
          onSubmit: () {},
        ),
      ),
    ),
  );
}

/// Text input used by the employee profile change governance form.
class _ProfileChangeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _ProfileChangeTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
    );
  }
}

/// Effective date picker display for a governed profile change draft.
class _EffectiveDateField extends StatelessWidget {
  final EmployeeProfileChangeDraft draft;
  final VoidCallback onTap;

  const _EffectiveDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = draft.effectiveDate;
    final label =
        date == null
            ? 'Select effective date'
            : DateFormat('MMM d, yyyy').format(date);

    return InkWell(
      key: const ValueKey('employee-profile-change-effective-date-field'),
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Effective date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(label),
      ),
    );
  }
}
