import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';

class TaskDetailPanel extends StatelessWidget {
  final Task task;
  final void Function(String? id) onDelete;
  final void Function(Task? newTask) onAdd;
  final void Function(Task? newTask) onEdit;
  final void Function(Task? newTask) onUpdate;
  final void Function(double? value) onChange;
  final void Function(String? id) onAddSubtask;
  final void Function() onClose;
  const TaskDetailPanel({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onAdd,
    required this.onEdit,
    required this.onUpdate,
    required this.onChange,
    required this.onAddSubtask,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Crucial for proper sizing
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: task.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => onClose(),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEdit(task),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(task.id),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date Info Row
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                '${DateFormat('MMM d, yyyy').format(task.startDate)} - '
                '${DateFormat('MMM d, yyyy').format(task.endDate)}',
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 8),
              Text(
                '${task.endDate.difference(task.startDate).inDays + 1} days',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Section
          const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbColor: task.color,
                    activeTrackColor: task.color,
                    inactiveTrackColor: task.color.withValues(alpha: 0.2),
                  ),
                  child: Slider(value: task.progress, onChanged: onChange),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(task.progress * 100).toInt()}%'),
            ],
          ),

          // Dependencies (if any)
          if (task.dependsOn != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link, size: 16),
                const SizedBox(width: 8),
                const Text('Depends on: '),
                Text(
                  task.dependsOn!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],

          // Buttons Row - at the bottom
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subtask'),
                  onPressed: () => onAdd(task),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Set Complete'),
                  onPressed:
                      task.progress >= 1.0 ? null : () => onAddSubtask(task.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
