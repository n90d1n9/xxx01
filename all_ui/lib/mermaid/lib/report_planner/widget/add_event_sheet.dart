// Add/Edit Event Sheet with Reminder & Recurrence Support
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/agenda_item.dart';
import '../model/reminder_settings.dart';
import '../state/agenda_items_provider.dart';
import '../state/analytics_provider.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  final AgendaItem? editItem;

  const AddEventSheet({super.key, this.editItem});

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startTime;
  late DateTime _endTime;
  late Color _selectedColor;
  late String _selectedCategory;
  late List<ReminderSetting> _reminders;
  late RecurrenceType _recurrenceType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.editItem?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.editItem?.description ?? '',
    );
    _startTime = widget.editItem?.startTime ?? DateTime.now();
    _endTime =
        widget.editItem?.endTime ??
        DateTime.now().add(const Duration(hours: 1));
    _selectedColor = widget.editItem?.color ?? Colors.blue;
    _selectedCategory = widget.editItem?.category ?? 'Work';
    _reminders = List.from(widget.editItem?.reminders ?? []);
    _recurrenceType = widget.editItem?.recurrence?.type ?? RecurrenceType.none;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.editItem != null ? 'Edit Event' : 'New Event',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceType>(
                value: _recurrenceType,
                decoration: const InputDecoration(
                  labelText: 'Repeat',
                  border: OutlineInputBorder(),
                ),
                items: RecurrenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getRecurrenceLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _recurrenceType = value);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Reminders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ..._reminders.asMap().entries.map((entry) {
                return ListTile(
                  title: Text('${entry.value.minutesBefore} minutes before'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _reminders.removeAt(entry.key));
                    },
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addReminder,
                icon: const Icon(Icons.add),
                label: const Text('Add Reminder'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: Text(widget.editItem != null ? 'Update' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRecurrenceLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 'Does not repeat';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
      default:
        return 'Custom';
    }
  }

  void _addReminder() {
    showDialog(
      context: context,
      builder: (context) {
        int minutes = 15;
        return AlertDialog(
          title: const Text('Add Reminder'),
          content: DropdownButton<int>(
            value: minutes,
            items: [0, 5, 15, 30, 60, 120].map((m) {
              return DropdownMenuItem(
                value: m,
                child: Text(m == 0 ? 'At time of event' : '$m minutes before'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) minutes = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _reminders.add(ReminderSetting(minutesBefore: minutes));
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveEvent() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    final recurrence = _recurrenceType != RecurrenceType.none
        ? RecurrencePattern(type: _recurrenceType)
        : null;

    final item = AgendaItem(
      id:
          widget.editItem?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: _startTime,
      endTime: _endTime,
      color: _selectedColor,
      category: _selectedCategory,
      reminders: _reminders,
      recurrence: recurrence,
      isCompleted: widget.editItem?.isCompleted ?? false,
    );

    if (widget.editItem != null) {
      ref.read(agendaItemsProvider.notifier).updateItem(item);
    } else {
      ref.read(agendaItemsProvider.notifier).addItem(item);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
