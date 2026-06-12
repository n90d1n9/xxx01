import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_timekeeping_models.dart';

class EmployeeTimekeepingExceptionForm extends StatelessWidget {
  final EmployeeTimekeepingExceptionDraft draft;
  final TextEditingController ownerController;
  final TextEditingController noteController;
  final ValueChanged<EmployeeTimekeepingExceptionType> onTypeChanged;
  final ValueChanged<EmployeeTimekeepingExceptionSeverity> onSeverityChanged;
  final ValueChanged<String> onOwnerChanged;
  final ValueChanged<int> onMinutesImpactChanged;
  final ValueChanged<bool> onPayrollImpactChanged;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onSelectWorkDate;
  final VoidCallback onAdd;

  const EmployeeTimekeepingExceptionForm({
    super.key,
    required this.draft,
    required this.ownerController,
    required this.noteController,
    required this.onTypeChanged,
    required this.onSeverityChanged,
    required this.onOwnerChanged,
    required this.onMinutesImpactChanged,
    required this.onPayrollImpactChanged,
    required this.onNoteChanged,
    required this.onSelectWorkDate,
    required this.onAdd,
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
                child: _EnumDropdown<EmployeeTimekeepingExceptionType>(
                  label: 'Exception type',
                  icon: Icons.warning_amber_outlined,
                  value: draft.type,
                  values: EmployeeTimekeepingExceptionType.values,
                  labelFor: (value) => value.label,
                  onChanged: onTypeChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _EnumDropdown<EmployeeTimekeepingExceptionSeverity>(
                  label: 'Severity',
                  icon: Icons.priority_high_outlined,
                  value: draft.severity,
                  values: EmployeeTimekeepingExceptionSeverity.values,
                  labelFor: (value) => value.label,
                  onChanged: onSeverityChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WorkDateField(value: draft.workDate, onTap: onSelectWorkDate),
          const SizedBox(height: 12),
          TextField(
            controller: ownerController,
            decoration: const InputDecoration(
              labelText: 'Owner',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: onOwnerChanged,
          ),
          const SizedBox(height: 12),
          _MinutesImpactSlider(
            value: draft.minutesImpact,
            onChanged: onMinutesImpactChanged,
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              value: draft.payrollImpact,
              contentPadding: EdgeInsets.zero,
              title: const Text('Payroll impact'),
              subtitle: const Text('Blocks payroll readiness until resolved'),
              onChanged: onPayrollImpactChanged,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: noteController,
            minLines: 3,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Exception note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: onNoteChanged,
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
              label: const Text('Add exception'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  const _EnumDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items:
          values
              .map(
                (entry) => DropdownMenuItem<T>(
                  value: entry,
                  child: Text(labelFor(entry), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}

class _WorkDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const _WorkDateField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Work date',
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

class _MinutesImpactSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _MinutesImpactSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minutes impact: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 240,
          divisions: 16,
          label: '$value',
          onChanged: (next) => onChanged(next.round()),
        ),
      ],
    );
  }
}
