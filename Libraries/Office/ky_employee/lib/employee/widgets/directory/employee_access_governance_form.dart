import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_access_governance_models.dart';

class EmployeeAccessGovernanceForm extends StatelessWidget {
  final EmployeeAccessGovernanceDraft draft;
  final TextEditingController systemController;
  final TextEditingController roleController;
  final TextEditingController ownerController;
  final TextEditingController reviewerController;
  final TextEditingController justificationController;
  final ValueChanged<String> onSystemChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<String> onReviewerChanged;
  final ValueChanged<String> onJustificationChanged;
  final ValueChanged<EmployeeAccessGovernanceScope> onScopeChanged;
  final ValueChanged<EmployeeAccessGovernanceRisk> onRiskChanged;
  final VoidCallback onSelectDueDate;
  final VoidCallback onSubmit;

  const EmployeeAccessGovernanceForm({
    super.key,
    required this.draft,
    required this.systemController,
    required this.roleController,
    required this.ownerController,
    required this.reviewerController,
    required this.justificationController,
    required this.onSystemChanged,
    required this.onRoleChanged,
    required this.onOwnerChanged,
    required this.onReviewerChanged,
    required this.onJustificationChanged,
    required this.onScopeChanged,
    required this.onRiskChanged,
    required this.onSelectDueDate,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<EmployeeAccessGovernanceScope>(
                  initialValue: draft.scope,
                  decoration: const InputDecoration(
                    labelText: 'Scope',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.security_outlined),
                  ),
                  items:
                      EmployeeAccessGovernanceScope.values
                          .map(
                            (scope) => DropdownMenuItem(
                              value: scope,
                              child: Text(
                                scope.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) onScopeChanged(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AccessDueDateField(
                  dueDate: draft.dueDate,
                  onTap: onSelectDueDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeAccessGovernanceRisk>(
            initialValue: draft.risk,
            decoration: const InputDecoration(
              labelText: 'Risk',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.warning_amber_outlined),
            ),
            items:
                EmployeeAccessGovernanceRisk.values
                    .map(
                      (risk) => DropdownMenuItem(
                        value: risk,
                        child: Text(
                          risk.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onRiskChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _AccessTextField(
            controller: systemController,
            label: 'System',
            icon: Icons.desktop_windows_outlined,
            onChanged: onSystemChanged,
          ),
          const SizedBox(height: 12),
          _AccessTextField(
            controller: roleController,
            label: 'Role',
            icon: Icons.key_outlined,
            onChanged: onRoleChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AccessTextField(
                  controller: ownerController,
                  label: 'Owner',
                  icon: Icons.assignment_ind_outlined,
                  onChanged: onOwnerChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AccessTextField(
                  controller: reviewerController,
                  label: 'Reviewer',
                  icon: Icons.person_search_outlined,
                  onChanged: onReviewerChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AccessTextField(
            controller: justificationController,
            label: 'Business justification',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onJustificationChanged,
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
              onPressed: draft.isReadyToSubmit ? onSubmit : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add access review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessDueDateField extends StatelessWidget {
  final DateTime dueDate;
  final VoidCallback onTap;

  const _AccessDueDateField({required this.dueDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(dueDate),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _AccessTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _AccessTextField({
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
