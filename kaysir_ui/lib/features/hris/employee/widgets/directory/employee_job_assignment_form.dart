import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_job_assignment_models.dart';
import 'employee_job_assignment_tiles.dart';

class EmployeeJobAssignmentForm extends StatelessWidget {
  final EmployeeJobAssignmentDraft draft;
  final TextEditingController positionController;
  final TextEditingController departmentController;
  final TextEditingController managerController;
  final TextEditingController locationController;
  final TextEditingController costCenterController;
  final TextEditingController gradeController;
  final TextEditingController notesController;
  final ValueChanged<String> onPositionChanged;
  final ValueChanged<String> onDepartmentChanged;
  final ValueChanged<String> onManagerChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onCostCenterChanged;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<EmployeeEmploymentContractType> onContractTypeChanged;
  final ValueChanged<EmployeeWorkArrangement> onArrangementChanged;
  final ValueChanged<EmployeeJobAssignmentType> onAssignmentTypeChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSelectStartDate;
  final VoidCallback onAdd;

  const EmployeeJobAssignmentForm({
    super.key,
    required this.draft,
    required this.positionController,
    required this.departmentController,
    required this.managerController,
    required this.locationController,
    required this.costCenterController,
    required this.gradeController,
    required this.notesController,
    required this.onPositionChanged,
    required this.onDepartmentChanged,
    required this.onManagerChanged,
    required this.onLocationChanged,
    required this.onCostCenterChanged,
    required this.onGradeChanged,
    required this.onContractTypeChanged,
    required this.onArrangementChanged,
    required this.onAssignmentTypeChanged,
    required this.onNotesChanged,
    required this.onSelectStartDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AssignmentTextField(
            controller: positionController,
            label: 'Position',
            icon: Icons.work_outline,
            onChanged: onPositionChanged,
          ),
          const SizedBox(height: 12),
          _AssignmentTextField(
            controller: departmentController,
            label: 'Department',
            icon: Icons.apartment_outlined,
            onChanged: onDepartmentChanged,
          ),
          const SizedBox(height: 12),
          _AssignmentTextField(
            controller: managerController,
            label: 'Manager',
            icon: Icons.supervisor_account_outlined,
            onChanged: onManagerChanged,
          ),
          const SizedBox(height: 12),
          _AssignmentTextField(
            controller: locationController,
            label: 'Location',
            icon: Icons.place_outlined,
            onChanged: onLocationChanged,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AssignmentTextField(
                  controller: costCenterController,
                  label: 'Cost center',
                  icon: Icons.confirmation_number_outlined,
                  onChanged: onCostCenterChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AssignmentTextField(
                  controller: gradeController,
                  label: 'Grade',
                  icon: Icons.grade_outlined,
                  onChanged: onGradeChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AssignmentDateField(draft: draft, onTap: onSelectStartDate),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeEmploymentContractType>(
            initialValue: draft.contractType,
            decoration: const InputDecoration(
              labelText: 'Contract type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_outlined),
            ),
            items:
                EmployeeEmploymentContractType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onContractTypeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeWorkArrangement>(
            initialValue: draft.arrangement,
            decoration: const InputDecoration(
              labelText: 'Work arrangement',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.hub_outlined),
            ),
            items:
                EmployeeWorkArrangement.values
                    .map(
                      (arrangement) => DropdownMenuItem(
                        value: arrangement,
                        child: Text(arrangement.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onArrangementChanged(value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EmployeeJobAssignmentType>(
            initialValue: draft.assignmentType,
            decoration: const InputDecoration(
              labelText: 'Assignment type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items:
                EmployeeJobAssignmentType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onAssignmentTypeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _AssignmentTextField(
            controller: notesController,
            label: 'Notes',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onNotesChanged,
          ),
          const SizedBox(height: 12),
          Text(
            'Assignment impact',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          EmployeeJobAssignmentImpactPreview(impacts: draft.impacts),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToSchedule
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
              onPressed: draft.isReadyToSchedule ? onAdd : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add assignment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _AssignmentTextField({
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

class _AssignmentDateField extends StatelessWidget {
  final EmployeeJobAssignmentDraft draft;
  final VoidCallback onTap;

  const _AssignmentDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = draft.startDate;
    final label =
        date == null
            ? 'Select start date'
            : DateFormat('MMM d, yyyy').format(date);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Start date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(label),
      ),
    );
  }
}
