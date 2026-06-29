import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_position_control_models.dart';

class EmployeePositionRequisitionForm extends StatelessWidget {
  final EmployeePositionRequisitionDraft draft;
  final TextEditingController titleController;
  final TextEditingController ownerController;
  final TextEditingController businessCaseController;
  final ValueChanged<EmployeePositionRequisitionType> onTypeChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<double> onRequestedFteChanged;
  final ValueChanged<String> onBusinessCaseChanged;
  final VoidCallback onSelectTargetStartDate;
  final VoidCallback onAdd;

  const EmployeePositionRequisitionForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.ownerController,
    required this.businessCaseController,
    required this.onTypeChanged,
    required this.onTitleChanged,
    required this.onOwnerChanged,
    required this.onRequestedFteChanged,
    required this.onBusinessCaseChanged,
    required this.onSelectTargetStartDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeePositionRequisitionType>(
            initialValue: draft.type,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Requisition type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.route_outlined),
            ),
            items:
                EmployeePositionRequisitionType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) onTypeChanged(value);
            },
          ),
          const SizedBox(height: 12),
          _PositionTextField(
            controller: titleController,
            label: 'Requisition title',
            icon: Icons.short_text_outlined,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 12),
          _PositionTextField(
            controller: ownerController,
            label: 'Owner',
            icon: Icons.person_outline,
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _FteSlider(
            value: draft.requestedFte,
            onChanged: onRequestedFteChanged,
          ),
          const SizedBox(height: 12),
          _PositionDateField(
            value: draft.targetStartDate,
            onTap: onSelectTargetStartDate,
          ),
          const SizedBox(height: 12),
          _PositionTextField(
            controller: businessCaseController,
            label: 'Business case',
            icon: Icons.notes_outlined,
            minLines: 3,
            onChanged: onBusinessCaseChanged,
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: draft.completionRatio,
            color:
                draft.isReadyToAdd
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
              onPressed: draft.isReadyToAdd ? onAdd : null,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Add requisition'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FteSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _FteSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requested FTE: ${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        Slider(
          value: value,
          min: 0.25,
          max: 2,
          divisions: 7,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PositionDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _PositionDateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Target start date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(
          value == null
              ? 'Select date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}

class _PositionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _PositionTextField({
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
