import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meeting_priority.dart';
import 'meeting_status.dart';
import 'meeting_type.dart';
import 'attendee.dart';
import 'action_item.dart';
import 'meeting_note.dart';
import 'meeting.dart';
import 'add_edit_meeting_page.dart';

class _AddEditMeetingPageState extends ConsumerState<AddEditMeetingPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _meetingLinkController;
  late DateTime _selectedDateTime;
  late int _durationMinutes;
  late MeetingPriority _selectedPriority;
  late MeetingStatus _selectedStatus;
  late MeetingType _selectedType;
  final List<Attendee> _attendees = [];
  final List<MeetingNote> _notes = [];
  final List<ActionItem> _actionItems = [];
  final List<String> _tags = [];
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    final meeting = widget.meeting;
    _titleController = TextEditingController(text: meeting?.title ?? '');
    _descriptionController = TextEditingController(
      text: meeting?.description ?? '',
    );
    _locationController = TextEditingController(text: meeting?.location ?? '');
    _meetingLinkController = TextEditingController(
      text: meeting?.meetingLink ?? '',
    );
    _selectedDateTime = meeting?.dateTime ?? DateTime.now();
    _durationMinutes = meeting?.durationMinutes ?? 60;
    _selectedPriority = meeting?.priority ?? MeetingPriority.medium;
    _selectedStatus = meeting?.status ?? MeetingStatus.scheduled;
    _selectedType = meeting?.type ?? MeetingType.other;
    if (meeting != null) {
      _attendees.addAll(meeting.attendees);
      _notes.addAll(meeting.notes);
      _actionItems.addAll(meeting.actionItems);
      _tags.addAll(meeting.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _meetingLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting == null ? 'New Meeting' : 'Edit Meeting'),
        actions: [
          TextButton(
            onPressed: _saveMeeting,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MeetingType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Meeting Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: MeetingType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(
                DateFormat('MMM dd, yyyy - h:mm a').format(_selectedDateTime),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectDateTime,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _durationMinutes,
              decoration: const InputDecoration(
                labelText: 'Duration',
                prefixIcon: Icon(Icons.timer),
              ),
              items: [15, 30, 45, 60, 90, 120, 180].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes minutes'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _durationMinutes = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MeetingPriority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag),
              ),
              items: MeetingPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedPriority = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MeetingStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.info),
              ),
              items: MeetingStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedStatus = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _meetingLinkController,
              decoration: const InputDecoration(
                labelText: 'Meeting Link (Zoom, Teams, etc.)',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 24),
            _buildListSection(
              'Tags',
              _tags,
              Icons.tag,
              'Add tag',
              simple: true,
            ),
            const SizedBox(height: 24),
            _buildAttendeesSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildActionItemsSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attendees',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._attendees.map((attendee) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(attendee.name[0].toUpperCase()),
              ),
              title: Text(attendee.name),
              subtitle: Text(attendee.email),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => setState(() => _attendees.remove(attendee)),
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addAttendee,
          icon: const Icon(Icons.add),
          label: const Text('Add attendee'),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._notes.map((note) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.note, size: 20),
              title: Text(note.content),
              subtitle: Text(
                DateFormat('MMM dd, h:mm a').format(note.timestamp),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => setState(() => _notes.remove(note)),
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addNote,
          icon: const Icon(Icons.add),
          label: const Text('Add note'),
        ),
      ],
    );
  }

  Widget _buildActionItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Action Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._actionItems.map((action) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Checkbox(
                value: action.isCompleted,
                onChanged: (value) {
                  final index = _actionItems.indexOf(action);
                  setState(() {
                    _actionItems[index] = action.copyWith(
                      isCompleted: value ?? false,
                    );
                  });
                },
              ),
              title: Text(action.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (action.assignedTo != null)
                    Text(
                      'Assigned: ${action.assignedTo}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (action.dueDate != null)
                    Text(
                      'Due: ${DateFormat('MMM dd').format(action.dueDate!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: () => setState(() => _actionItems.remove(action)),
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: _addActionItem,
          icon: const Icon(Icons.add),
          label: const Text('Add action item'),
        ),
      ],
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    IconData icon,
    String hint, {
    bool simple = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Chip(
                label: Text(item),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => items.remove(item)),
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _addSimpleItem(items, hint),
          icon: const Icon(Icons.add),
          label: Text(hint),
        ),
      ],
    );
  }

  void _addSimpleItem(List<String> list, String hint) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hint),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => list.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addAttendee() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    bool isOrganizer = false;
    bool isOptional = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Attendee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Organizer'),
                value: isOrganizer,
                onChanged: (value) =>
                    setState(() => isOrganizer = value ?? false),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Optional'),
                value: isOptional,
                onChanged: (value) =>
                    setState(() => isOptional = value ?? false),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  final attendee = Attendee(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    email: emailController.text,
                    isOrganizer: isOrganizer,
                    isOptional: isOptional,
                  );
                  this.setState(() => _attendees.add(attendee));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addNote() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter note'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final note = MeetingNote(
                  id: const Uuid().v4(),
                  content: controller.text,
                  timestamp: DateTime.now(),
                );
                setState(() => _notes.add(note));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addActionItem() {
    final titleController = TextEditingController();
    final assignedToController = TextEditingController();
    DateTime? dueDate;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Action Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: assignedToController,
                decoration: const InputDecoration(labelText: 'Assigned To'),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  dueDate == null
                      ? 'No due date'
                      : DateFormat('MMM dd, yyyy').format(dueDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => dueDate = date);
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final action = ActionItem(
                    id: const Uuid().v4(),
                    title: titleController.text,
                    assignedTo: assignedToController.text.isEmpty
                        ? null
                        : assignedToController.text,
                    dueDate: dueDate,
                    createdAt: DateTime.now(),
                  );
                  this.setState(() => _actionItems.add(action));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveMeeting() {
    if (!_formKey.currentState!.validate()) return;
    final meeting = Meeting(
      id: widget.meeting?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      dateTime: _selectedDateTime,
      durationMinutes: _durationMinutes,
      attendees: _attendees,
      notes: _notes,
      actionItems: _actionItems,
      priority: _selectedPriority,
      status: _selectedStatus,
      type: _selectedType,
      location: _locationController.text.isEmpty
          ? null
          : _locationController.text,
      meetingLink: _meetingLinkController.text.isEmpty
          ? null
          : _meetingLinkController.text,
      tags: _tags,
      createdAt: widget.meeting?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    if (widget.meeting == null) {
      ref.read(meetingsProvider.notifier).addMeeting(meeting);
    } else {
      ref.read(meetingsProvider.notifier).updateMeeting(meeting);
    }
    Navigator.pop(context);
  }
}
