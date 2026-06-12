import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../model/agenda_item.dart';
import '../model/priority.dart';
import '../model/reminder_settings.dart';
import '../service/notification_service.dart';
import '../utils/recurring_event_helper.dart';
import 'analytics_provider.dart';
import 'storage_service_provider.dart';

final agendaItemsProvider =
    StateNotifierProvider<AgendaItemsNotifier, AsyncValue<List<AgendaItem>>>(
      (ref) => AgendaItemsNotifier(ref.read(storageServiceProvider)),
    );

class AgendaItemsNotifier extends StateNotifier<AsyncValue<List<AgendaItem>>> {
  final StorageService _storage;

  AgendaItemsNotifier(this._storage) : super(const AsyncValue.loading()) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await _storage.loadItems();
      if (items.isEmpty) {
        state = AsyncValue.data(_getInitialItems());
        await _saveItems();
      } else {
        state = AsyncValue.data(items);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<AgendaItem> _getInitialItems() {
    final now = DateTime.now();
    return [
      AgendaItem(
        id: '1',
        title: 'Daily Standup',
        description: 'Team sync meeting',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 9, 30),
        color: Colors.blue,
        category: 'Meeting',
        location: 'Conference Room A',
        tags: ['recurring', 'team'],
        priority: Priority.high,
        reminders: [
          ReminderSetting(minutesBefore: 15),
          ReminderSetting(minutesBefore: 0),
        ],
        recurrence: RecurrencePattern(type: RecurrenceType.daily, interval: 1),
      ),
      AgendaItem(
        id: '2',
        title: 'Gym Session',
        description: 'Workout routine',
        startTime: DateTime(now.year, now.month, now.day, 18, 0),
        endTime: DateTime(now.year, now.month, now.day, 19, 30),
        color: Colors.red,
        category: 'Health',
        location: 'Fitness Center',
        tags: ['exercise', 'routine'],
        priority: Priority.medium,
        reminders: [ReminderSetting(minutesBefore: 30)],
        recurrence: RecurrencePattern(
          type: RecurrenceType.weekly,
          interval: 1,
          daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
        ),
      ),
    ];
  }

  Future<void> _saveItems() async {
    final items = state.value ?? []; // Changed here
    await _storage.saveItems(items);
  }

  Future<void> addItem(AgendaItem item) async {
    state = AsyncValue.data([...?state.value, item]); // Changed here
    await _saveItems();
    await NotificationService.scheduleEventReminders(item);
  }

  Future<void> updateItem(AgendaItem item) async {
    state = AsyncValue.data([...?state.value, item]);

    await _saveItems();
    await NotificationService.scheduleEventReminders(item);
  }

  Future<void> deleteItem(String id) async {
    final items = state.value ?? []; // Changed valueOrNull to value
    await NotificationService.cancelEventReminders(id);
    state = AsyncValue.data(items.where((item) => item.id != id).toList());
    await _saveItems();
  }

  Future<void> toggleComplete(String id) async {
    final items = state.value ?? []; // Changed valueOrNull to value
    AgendaItem? updatedItem;
    state = AsyncValue.data([
      for (final item in items)
        if (item.id == id) ...[
          updatedItem = item.copyWith(isCompleted: !item.isCompleted),
          updatedItem!,
        ] else
          item,
    ]);
    await _saveItems();

    if (updatedItem != null) {
      if (updatedItem!.isCompleted) {
        await NotificationService.cancelEventReminders(id);
      } else {
        await NotificationService.scheduleEventReminders(updatedItem!);
      }
    }
  }

  // Get expanded recurring events for a date range
  List<AgendaItem> getExpandedItems(DateTime start, DateTime end) {
    final items = state.value ?? []; // Changed valueOrNull to value
    final expanded = <AgendaItem>[];

    for (final item in items) {
      if (item.recurrence != null &&
          item.recurrence!.type != RecurrenceType.none) {
        expanded.addAll(
          RecurringEventHelper.generateRecurringInstances(item, start, end),
        );
      } else {
        if (item.startTime.isAfter(start) && item.startTime.isBefore(end)) {
          expanded.add(item);
        }
      }
    }

    return expanded;
  }
}
