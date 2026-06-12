import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_leave_models.dart';

class EmployeeLeaveRequestForm extends StatelessWidget {
  final EmployeeLeaveRequestDraft draft;
  final TextEditingController reasonController;
  final TextEditingController coverageOwnerController;
  final ValueChanged<EmployeeLeaveType> onTypeChanged;
  final ValueChanged<String> onReasonChanged;
  final ValueChanged<String> onCoverageOwnerChanged;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;
  final VoidCallback onAdd;

  const EmployeeLeaveRequestForm({
    super.key,
    required this.draft,
    required this.reasonController,
    required this.coverageOwnerController,
    required this.onTypeChanged,
    required this.onReasonChanged,
    required this.onCoverageOwnerChanged,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeLeaveType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Leave type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.beach_access_outlined),
            ),
            items:
                EmployeeLeaveType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Start date',
                  date: draft.startDate,
                  onTap: onSelectStartDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'End date',
                  date: draft.endDate,
                  onTap: onSelectEndDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LeaveTextField(
            controller: coverageOwnerController,
            label: 'Coverage owner',
            icon: Icons.person_outline,
            onChanged: onCoverageOwnerChanged,
          ),
          const SizedBox(height: 12),
          _LeaveTextField(
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
              onPressed: draft.isReadyToSubmit ? onAdd : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add request'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(DateFormat('MMM d, yyyy').format(date)),
      ),
    );
  }
}

class _LeaveTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _LeaveTextField({
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
