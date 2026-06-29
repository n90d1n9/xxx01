import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_succession_plan_models.dart';

class EmployeeSuccessionCandidateForm extends StatelessWidget {
  final EmployeeSuccessionCandidateDraft draft;
  final TextEditingController nameController;
  final TextEditingController currentRoleController;
  final TextEditingController targetRoleController;
  final TextEditingController ownerController;
  final TextEditingController notesController;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onCurrentRoleChanged;
  final ValueChanged<String> onTargetRoleChanged;
  final ValueChanged<EmployeeSuccessionReadiness> onReadinessChanged;
  final ValueChanged<EmployeeSuccessionRisk> onRiskChanged;
  final ValueChanged<EmployeeSuccessionActionType> onActionTypeChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<int> onBenchScoreChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSelectReviewDate;
  final VoidCallback onAdd;

  const EmployeeSuccessionCandidateForm({
    super.key,
    required this.draft,
    required this.nameController,
    required this.currentRoleController,
    required this.targetRoleController,
    required this.ownerController,
    required this.notesController,
    required this.onNameChanged,
    required this.onCurrentRoleChanged,
    required this.onTargetRoleChanged,
    required this.onReadinessChanged,
    required this.onRiskChanged,
    required this.onActionTypeChanged,
    required this.onOwnerChanged,
    required this.onBenchScoreChanged,
    required this.onNotesChanged,
    required this.onSelectReviewDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Candidate name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_add_alt_1_outlined),
            ),
            onChanged: onNameChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: currentRoleController,
            decoration: const InputDecoration(
              labelText: 'Candidate current role',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            onChanged: onCurrentRoleChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: targetRoleController,
            decoration: const InputDecoration(
              labelText: 'Succession target role',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_tree_outlined),
            ),
            onChanged: onTargetRoleChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeSuccessionReadiness>(
            initialValue: draft.readiness,
            decoration: const InputDecoration(
              labelText: 'Readiness',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timeline_outlined),
            ),
            items:
                EmployeeSuccessionReadiness.values
                    .map(
                      (readiness) => DropdownMenuItem(
                        value: readiness,
                        child: Text(readiness.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onReadinessChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeSuccessionRisk>(
            initialValue: draft.risk,
            decoration: const InputDecoration(
              labelText: 'Risk',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items:
                EmployeeSuccessionRisk.values
                    .map(
                      (risk) => DropdownMenuItem(
                        value: risk,
                        child: Text(risk.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onRiskChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeSuccessionActionType>(
            initialValue: draft.actionType,
            decoration: const InputDecoration(
              labelText: 'Coverage action',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.task_alt_outlined),
            ),
            items:
                EmployeeSuccessionActionType.values
                    .map(
                      (action) => DropdownMenuItem(
                        value: action,
                        child: Text(action.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onActionTypeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Coverage owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.supervisor_account_outlined),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _ReviewDateField(draft: draft, onTap: onSelectReviewDate),
          const SizedBox(height: 12),
          Text(
            'Bench score',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${draft.benchScore}',
                  value: draft.benchScore.toDouble(),
                  onChanged: (value) => onBenchScoreChanged(value.round()),
                ),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  '${draft.benchScore}%',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Succession notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNotesChanged,
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...errors.map(
              (error) => Text(
                error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HrisProgressBar(
                  value: draft.completionRatio,
                  color:
                      draft.isReadyToAdd
                          ? const Color(0xFF15803D)
                          : HrisColors.primary,
                  label: '${(draft.completionRatio * 100).round()}% ready',
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Add successor'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewDateField extends StatelessWidget {
  final EmployeeSuccessionCandidateDraft draft;
  final VoidCallback onTap;

  const _ReviewDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Candidate review date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_note_outlined),
        ),
        child: Text(
          draft.reviewDate == null
              ? 'Select date'
              : DateFormat('MMM d, yyyy').format(draft.reviewDate!),
        ),
      ),
    );
  }
}
