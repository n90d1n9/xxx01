import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import 'leave_status_styles.dart';

class LeaveRequestForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String selectedLeaveType;
  final DateTime? startDate;
  final DateTime? endDate;
  final TextEditingController reasonController;
  final ValueChanged<String?> onLeaveTypeChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const LeaveRequestForm({
    super.key,
    required this.formKey,
    required this.selectedLeaveType,
    required this.startDate,
    required this.endDate,
    required this.reasonController,
    required this.onLeaveTypeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: hrisPanelDecoration(),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Request Leave',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: HrisColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: onCancel,
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedLeaveType,
              decoration: const InputDecoration(
                labelText: 'Leave Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items:
                  leaveTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: onLeaveTypeChanged,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please select leave type'
                          : null,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 640;
                final fields = [
                  _DatePickerField(
                    label: 'Start Date',
                    value: startDate,
                    firstDate: DateTime.now(),
                    onChanged: onStartDateChanged,
                  ),
                  _DatePickerField(
                    label: 'End Date',
                    value: endDate,
                    firstDate: startDate ?? DateTime.now(),
                    onChanged: onEndDateChanged,
                  ),
                ];

                if (isNarrow) {
                  return Column(
                    children: [
                      fields.first,
                      const SizedBox(height: 16),
                      fields.last,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: fields.first),
                    const SizedBox(width: 16),
                    Expanded(child: fields.last),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 3,
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please enter a reason'
                          : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onCancel, child: const Text('Cancel')),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text('Submit Request'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.firstDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      key: ValueKey('$label-${value?.millisecondsSinceEpoch ?? 'empty'}'),
      initialValue: value,
      validator: (date) => date == null ? 'Required' : null,
      builder: (state) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? firstDate,
              firstDate: firstDate,
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked == null) return;
            state.didChange(picked);
            onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              errorText: state.errorText,
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
      },
    );
  }
}
