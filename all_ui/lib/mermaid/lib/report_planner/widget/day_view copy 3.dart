// Day View with Drag & Drop support
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reorderable_grid/reorderable_grid.dart';

import '../model/agenda_item.dart';
import '../model/category.dart';
import '../service/animation_service.dart';
import '../state/agenda_items_provider.dart';
import '../state/agenda_provider.dart';
import '../state/analytics_provider.dart';
import '../state/filter_items_provider.dart';
import 'event_detail_sheet.dart';

class DayView extends ConsumerWidget {
  const DayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final items = ref.watch(filteredItemsProvider);

    final dayItems = items.where((item) {
      return item.startTime.year == selectedDate.year &&
          item.startTime.month == selectedDate.month &&
          item.startTime.day == selectedDate.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: [
        _buildDateNavigator(context, ref, selectedDate),
        Expanded(
          child: dayItems.isEmpty
              ? _buildEmptyState(context)
              : ReorderableGridView.extent(
                  maxCrossAxisExtent: 250,
                  // Try different key strategies for WASM
                  key: ObjectKey(dayItems), // or ValueKey(dayItems.hashCode)
                  padding: const EdgeInsets.all(16),
                  //itemCount: dayItems.length,
                  onReorder: (oldIndex, newIndex) {
                    _reorderItems(context, ref, dayItems, oldIndex, newIndex);
                  },
                  children: dayItems.map((item) {
                    return _buildAgendaCard(
                      context,
                      ref,
                      item,
                      key: ValueKey(
                        '${item.id}_${item.startTime.millisecondsSinceEpoch}',
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  void _reorderItems(
    BuildContext context,
    WidgetRef ref,
    List<AgendaItem> items,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = items[oldIndex];
    final targetItem = items[newIndex];

    // Calculate new start time based on target position
    final newStartTime = targetItem.startTime;
    final duration = item.endTime.difference(item.startTime);
    final newEndTime = newStartTime.add(duration);

    // Update the item with new times
    final updatedItem = item.copyWith(
      startTime: newStartTime,
      endTime: newEndTime,
    );

    ref.read(agendaItemsProvider.notifier).updateItem(updatedItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.title} rescheduled to ${DateFormat('HH:mm').format(newStartTime)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDateNavigator(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = date.subtract(
                const Duration(days: 1),
              );
            },
          ),
          TextButton.icon(
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
            icon: const Icon(Icons.today),
            label: const Text('Today'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = date.add(
                const Duration(days: 1),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaCard(
    BuildContext context,
    WidgetRef ref,
    AgendaItem item, {
    Key? key,
  }) {
    final category = categories.firstWhere(
      (cat) => cat.name == item.category,
      orElse: () => categories.last,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AnimationService.normalDuration,
      curve: AnimationService.defaultCurve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Dismissible(
        key: key ?? Key(item.id),
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(Icons.check, color: Colors.white, size: 32),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 32),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            ref.read(agendaItemsProvider.notifier).toggleComplete(item.id);
            return false;
          } else {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Event'),
                content: const Text(
                  'Are you sure you want to delete this event?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            ref.read(agendaItemsProvider.notifier).deleteItem(item.id);
          }
        },
        child: GestureDetector(
          onTap: () => _showEventDetails(context, ref, item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: item.isCompleted
                  ? Border.all(color: Colors.green.withOpacity(0.5), width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(category.icon, size: 20, color: item.color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    decoration: item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              if (item.recurrence != null &&
                                  item.recurrence!.type != RecurrenceType.none)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.repeat,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              if (item.reminders.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.notifications_active,
                                        size: 12,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${item.reminders.length}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item.isAllDay
                                    ? 'All Day'
                                    : '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (item.location != null) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.location!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No events scheduled',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(BuildContext context, WidgetRef ref, AgendaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailsSheet(item: item),
    );
  }
}
