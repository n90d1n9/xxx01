import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../states/gantt_provider.dart';

class TaskListItem extends ConsumerStatefulWidget {
  final Task task;
  final double height;
  final bool isSelected;
  final bool isSubtask;
  final void Function() onTap;

  const TaskListItem({
    super.key,
    required this.task,
    required this.isSelected,
    required this.onTap,
    this.isSubtask = false,
    this.height = 40,
  });

  @override
  ConsumerState<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends ConsumerState<TaskListItem> {
  @override
  void initState() {
    super.initState();
    /*  WidgetsBinding.instance.addPostFrameCallback((_) {
      // This runs after the widget is built
      //_updateTaskSize();
    }); */
  }

  void _updateTaskSize() {
    final context = this.context;
    if (context.mounted) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        ref
            .read(tasksProvider.notifier)
            .updateTask(widget.task.copyWith(size: box.size));
      }
    }
  }

  @override
  void didUpdateWidget(covariant TaskListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) {
      _updateTaskSize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: widget.height,
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSubtask ? 24 : 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color:
              widget.isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 40,
              decoration: BoxDecoration(
                color: widget.task.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: widget.task.progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.task.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${(widget.task.progress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }
}
