import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'action_item.dart';
import 'meeting.dart';

class ActionItemCard extends ConsumerWidget {
  final ActionItem actionItem;
  final Meeting meeting;
  const ActionItemCard({
    Key? key,
    required this.actionItem,
    required this.meeting,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue =
        actionItem.dueDate != null &&
        actionItem.dueDate!.isBefore(DateTime.now()) &&
        !actionItem.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: actionItem.isCompleted,
          onChanged: (value) {
            final updatedActions =
                meeting.actionItems.map((a) {
                  if (a.id == actionItem.id) {
                    return a.copyWith(isCompleted: value ?? false);
                  }
                  return a;
                }).toList();
            ref
                .read(meetingsProvider.notifier)
                .updateMeeting(meeting.copyWith(actionItems: updatedActions));
          },
        ),
        title: Text(
          actionItem.title,
          style: TextStyle(
            decoration:
                actionItem.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From: ${meeting.title}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (actionItem.assignedTo != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    actionItem.assignedTo!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
            if (actionItem.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: isOverdue ? Colors.red : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(actionItem.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? Colors.red : Colors.grey.shade600,
                      fontWeight: isOverdue ? FontWeight.bold : null,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 4),
                    Text(
                      'OVERDUE',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
