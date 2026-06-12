import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_schedule_models.dart';

class EmployeeScheduleAdjustmentForm extends StatelessWidget {
  final EmployeeScheduleAdjustmentDraft draft;
  final TextEditingController startController;
  final TextEditingController endController;
  final TextEditingController locationController;
  final TextEditingController reasonController;
  final ValueChanged<EmployeeScheduleAdjustmentType> onTypeChanged;
  final ValueChanged<String> onStartChanged;
  final ValueChanged<String> onEndChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onReasonChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onAdd;

  const EmployeeScheduleAdjustmentForm({
    super.key,
    required this.draft,
    required this.startController,
    required this.endController,
    required this.locationController,
    required this.reasonController,
    required this.onTypeChanged,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onLocationChanged,
    required this.onReasonChanged,
    required this.onSelectDate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EmployeeScheduleAdjustmentType>(
            initialValue: draft.type,
            decoration: const InputDecoration(
              labelText: 'Adjustment type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tune_outlined),
            ),
            items:
                EmployeeScheduleAdjustmentType.values
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
          _TargetDateField(draft: draft, onTap: onSelectDate),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ScheduleTextField(
                  controller: startController,
                  label: 'Start',
                  icon: Icons.schedule_outlined,
                  onChanged: onStartChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScheduleTextField(
                  controller: endController,
                  label: 'End',
                  icon: Icons.update_outlined,
                  onChanged: onEndChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ScheduleTextField(
            controller: locationController,
            label: 'Location',
            icon: Icons.place_outlined,
            onChanged: onLocationChanged,
          ),
          const SizedBox(height: 12),
          _ScheduleTextField(
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
              label: const Text('Add adjustment'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final int minLines;

  const _ScheduleTextField({
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

class _TargetDateField extends StatelessWidget {
  final EmployeeScheduleAdjustmentDraft draft;
  final VoidCallback onTap;

  const _TargetDateField({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = draft.targetDate;
    final label =
        date == null
            ? 'Select target date'
            : DateFormat('MMM d, yyyy').format(date);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Target date',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.event_outlined),
        ),
        child: Text(label),
      ),
    );
  }
}
