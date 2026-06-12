import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting_status.dart';
import 'attendee.dart';
import 'attendee_status.dart';
import 'action_item.dart';
import 'meeting_note.dart';
import 'meeting.dart';
import 'add_edit_meeting_page.dart';

class MeetingDetailsPage extends ConsumerWidget {
  final Meeting meeting;
  const MeetingDetailsPage({Key? key, required this.meeting}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) =>
                _handleMenuAction(context, ref, value.toString()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            meeting.title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoChip(meeting.type.name, Icons.category, Colors.blue),
          const SizedBox(height: 8),
          _buildInfoChip(meeting.status.name, Icons.info, _getStatusColor()),
          const SizedBox(height: 24),
          _buildInfoRow(
            Icons.calendar_today,
            DateFormat('EEEE, MMM dd, yyyy').format(meeting.dateTime),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.access_time,
            '${DateFormat('h:mm a').format(meeting.dateTime)} - ${DateFormat('h:mm a').format(meeting.endTime)} (${meeting.durationMinutes}m)',
          ),
          if (meeting.location != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, meeting.location!),
          ],
          if (meeting.meetingLink != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.link, meeting.meetingLink!),
          ],
          const SizedBox(height: 24),
          if (meeting.description.isNotEmpty) ...[
            _buildSectionTitle('Description'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(meeting.description),
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (meeting.attendees.isNotEmpty) ...[
            _buildSectionTitle('Attendees (${meeting.attendees.length})'),
            ...meeting.attendees.map((a) => _buildAttendeeCard(a)),
            const SizedBox(height: 24),
          ],
          if (meeting.notes.isNotEmpty) ...[
            _buildSectionTitle('Notes (${meeting.notes.length})'),
            ...meeting.notes.map((n) => _buildNoteCard(n)),
            const SizedBox(height: 24),
          ],
          if (meeting.actionItems.isNotEmpty) ...[
            _buildSectionTitle('Action Items (${meeting.actionItems.length})'),
            ...meeting.actionItems.map(
              (a) => _buildActionCard(context, ref, a),
            ),
            const SizedBox(height: 24),
          ],
          if (meeting.tags.isNotEmpty) ...[
            _buildSectionTitle('Tags'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: meeting.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
          ],
        ],
      ),
      floatingActionButton: meeting.status == MeetingStatus.scheduled
          ? FloatingActionButton.extended(
              onPressed: () {
                ref
                    .read(meetingsProvider.notifier)
                    .updateMeeting(
                      meeting.copyWith(status: MeetingStatus.inProgress),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meeting started')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Meeting'),
            )
          : meeting.status == MeetingStatus.inProgress
          ? FloatingActionButton.extended(
              onPressed: () {
                ref
                    .read(meetingsProvider.notifier)
                    .updateMeeting(
                      meeting.copyWith(status: MeetingStatus.completed),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Meeting completed')),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Complete'),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeeCard(Attendee attendee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(attendee.name[0].toUpperCase())),
        title: Row(
          children: [
            Text(attendee.name),
            if (attendee.isOrganizer) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Organizer',
                  style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
                ),
              ),
            ],
            if (attendee.isOptional) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Optional',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(attendee.email),
        trailing: _buildAttendeeStatusIcon(attendee.status),
      ),
    );
  }

  Widget _buildAttendeeStatusIcon(AttendeeStatus status) {
    IconData icon;
    Color color;
    switch (status) {
      case AttendeeStatus.accepted:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case AttendeeStatus.declined:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case AttendeeStatus.tentative:
        icon = Icons.help;
        color = Colors.orange;
        break;
      case AttendeeStatus.pending:
        icon = Icons.schedule;
        color = Colors.grey;
        break;
    }
    return Icon(icon, color: color, size: 20);
  }

  Widget _buildNoteCard(MeetingNote note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.note, size: 20),
        title: Text(note.content),
        subtitle: Text(
          DateFormat('MMM dd, h:mm a').format(note.timestamp),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    WidgetRef ref,
    ActionItem action,
  ) {
    final isOverdue =
        action.dueDate != null &&
        action.dueDate!.isBefore(DateTime.now()) &&
        !action.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: action.isCompleted,
          onChanged: (value) {
            final updatedActions = meeting.actionItems.map((a) {
              if (a.id == action.id) {
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
          action.title,
          style: TextStyle(
            decoration: action.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (action.assignedTo != null) ...[
              const SizedBox(height: 4),
              Text(
                'Assigned: ${action.assignedTo}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
            if (action.dueDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(action.dueDate!)}${isOverdue ? ' - OVERDUE' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? Colors.red : null,
                  fontWeight: isOverdue ? FontWeight.bold : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (meeting.status) {
      case MeetingStatus.scheduled:
        return Colors.blue;
      case MeetingStatus.inProgress:
        return Colors.orange;
      case MeetingStatus.completed:
        return Colors.green;
      case MeetingStatus.cancelled:
        return Colors.red;
    }
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditMeetingPage(meeting: meeting),
          ),
        );
        break;
      case 'duplicate':
        final duplicated = Meeting(
          id: const Uuid().v4(),
          title: '${meeting.title} (Copy)',
          description: meeting.description,
          dateTime: meeting.dateTime.add(const Duration(days: 7)),
          durationMinutes: meeting.durationMinutes,
          attendees: meeting.attendees,
          notes: [],
          actionItems: [],
          priority: meeting.priority,
          status: MeetingStatus.scheduled,
          type: meeting.type,
          location: meeting.location,
          meetingLink: meeting.meetingLink,
          tags: meeting.tags,
          createdAt: DateTime.now(),
        );
        ref.read(meetingsProvider.notifier).addMeeting(duplicated);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Meeting duplicated')));
        break;
      case 'share':
        _showShareDialog(context);
        break;
      case 'delete':
        _deleteMeeting(context, ref);
        break;
    }
  }

  void _showShareDialog(BuildContext context) {
    final summary = _generateMeetingSummary();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Meeting'),
        content: SingleChildScrollView(child: Text(summary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meeting summary copied')),
              );
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  String _generateMeetingSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Meeting: ${meeting.title}');
    buffer.writeln(
      'Date: ${DateFormat('MMM dd, yyyy - h:mm a').format(meeting.dateTime)}',
    );
    buffer.writeln('Duration: ${meeting.durationMinutes} minutes');
    if (meeting.location != null) {
      buffer.writeln('Location: ${meeting.location}');
    }
    if (meeting.meetingLink != null) {
      buffer.writeln('Link: ${meeting.meetingLink}');
    }
    buffer.writeln('\nDescription:');
    buffer.writeln(meeting.description);
    if (meeting.attendees.isNotEmpty) {
      buffer.writeln('\nAttendees:');
      for (final attendee in meeting.attendees) {
        buffer.writeln('- ${attendee.name} (${attendee.email})');
      }
    }
    if (meeting.notes.isNotEmpty) {
      buffer.writeln('\nNotes:');
      for (final note in meeting.notes) {
        buffer.writeln('- ${note.content}');
      }
    }
    if (meeting.actionItems.isNotEmpty) {
      buffer.writeln('\nAction Items:');
      for (final action in meeting.actionItems) {
        final status = action.isCompleted ? '✓' : '○';
        buffer.write('$status ${action.title}');
        if (action.assignedTo != null) {
          buffer.write(' (${action.assignedTo})');
        }
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  void _deleteMeeting(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: const Text(
          'Are you sure you want to delete this meeting? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(meetingsProvider.notifier).deleteMeeting(meeting.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Meeting deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
