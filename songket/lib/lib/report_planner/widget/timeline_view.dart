// New Timeline View
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../model/agenda_item.dart';
import '../state/agenda_provider.dart';
import '../state/filter_items_provider.dart';

class TimelineView extends ConsumerWidget {
  const TimelineView({Key? key}) : super(key: key);

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
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state = selectedDate
                      .subtract(const Duration(days: 1));
                },
              ),
              Text(
                DateFormat('EEEE, MMM d').format(selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state = selectedDate
                      .add(const Duration(days: 1));
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 24,
            itemBuilder: (context, hour) {
              final hourItems = dayItems.where((item) {
                return item.startTime.hour == hour;
              }).toList();

              return _buildTimelineHour(context, hour, hourItems);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineHour(
    BuildContext context,
    int hour,
    List<AgendaItem> items,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            DateFormat('HH:mm').format(DateTime(2024, 1, 1, hour)),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                height: 1,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              ),
              if (items.isNotEmpty)
                ...items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: item.color, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('HH:mm').format(item.startTime)} - ${DateFormat('HH:mm').format(item.endTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(height: 60),
            ],
          ),
        ),
      ],
    );
  }
}
