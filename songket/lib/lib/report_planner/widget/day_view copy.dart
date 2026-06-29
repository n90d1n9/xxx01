// Day View with Drag & Drop support
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/agenda_provider.dart';
import '../state/filter_items_provider.dart';
import 'day_item_list.dart';

class DayView extends ConsumerStatefulWidget {
  const DayView({super.key});

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  final GlobalKey _reorderableKey = GlobalKey(); // Key created once in state

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final items = ref.watch(filteredItemsProvider);

    final dayItems = items.where((item) {
      return item.startTime.year == selectedDate.year &&
          item.startTime.month == selectedDate.month &&
          item.startTime.day == selectedDate.day;
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Debug print
    print('DayView rebuild: ${dayItems.length} items, key: $_reorderableKey');

    try {
      return Column(
        children: [
          _buildDateNavigator(context, ref, selectedDate),
          Expanded(
            child: dayItems.isEmpty
                ? _buildEmptyState(context)
                : DayItemsList(
                    dayItems: dayItems,
                    reorderableKey: _reorderableKey,
                  ),
          ),
        ],
      );
    } catch (e, stack) {
      print('Error in DayView: $e');
      print('Stack: $stack');
      return Center(child: Text('Error: $e'));
    }
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
}
