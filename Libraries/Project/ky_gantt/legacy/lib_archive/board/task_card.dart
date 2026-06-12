import 'package:flutter/material.dart';

import '../task/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({
    required this.task,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: onTap,
        title: Text(task.title),
        subtitle: Text(
          task.description!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: task.assignedTo.isNotEmpty
            ? CircleAvatar(
                child: Text(task.assignedTo[0].toUpperCase()),
              )
            : null,
      ),
    );
  }
}
