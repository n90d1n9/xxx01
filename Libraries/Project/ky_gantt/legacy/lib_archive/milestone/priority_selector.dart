
import 'package:flutter/material.dart';

import '../task/task.dart';

class PrioritySelector extends StatelessWidget {
  final TaskPriority priority;
  final ValueChanged<TaskPriority> onChanged;

  const PrioritySelector({
    super.key,
    required this.priority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TaskPriority>(
      value: priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
      ),
      items: TaskPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Icon(
                priority.icon,
                color: priority.color,
              ),
              const SizedBox(width: 8),
              Text(priority.label),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
