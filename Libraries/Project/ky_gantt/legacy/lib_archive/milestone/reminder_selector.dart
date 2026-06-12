
import 'package:flutter/material.dart';

import '../date/datetime_picker.dart';

class ReminderSelector extends StatelessWidget {
  final DateTime? reminderDate;
  final ValueChanged<DateTime?> onChanged;

  const ReminderSelector({
    super.key,
    required this.reminderDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Set Reminder'),
          value: reminderDate != null,
          onChanged: (checked) {
            if (checked == false) {
              onChanged(null);
            } else {
              onChanged(DateTime.now().add(const Duration(days: 1)));
            }
          },
        ),
        if (reminderDate != null)
          DateTimePicker(
            labelText: 'Reminder Date',
            selectedDate: reminderDate,
            onChanged: onChanged,
          ),
      ],
    );
  }
}