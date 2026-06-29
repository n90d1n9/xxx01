import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../model/agenda_item.dart';
import '../model/priority.dart';
import '../state/agenda_items_provider.dart';
import '../state/agenda_provider.dart';

// Month View
class MonthView extends ConsumerWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    final items = ref.read(agendaItemsProvider).value ?? [];
    return Column(
      children: [
        _buildMonthNavigator(context, ref, selectedDate),
        Expanded(child: _buildMonthCalendar(context, ref, selectedDate, items)),
      ],
    );
  }

  Widget _buildMonthNavigator(
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
              ref.read(selectedDateProvider.notifier).state = DateTime(
                date.year,
                date.month - 1,
                1,
              );
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(date),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime(
                date.year,
                date.month + 1,
                1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    List<AgendaItem> items,
  ) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: daysInMonth + firstWeekday - 1,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return const SizedBox();
        }

        final day = index - firstWeekday + 2;
        final currentDate = DateTime(date.year, date.month, day);
        final dayItems = items.where((item) {
          return item.startTime.year == currentDate.year &&
              item.startTime.month == currentDate.month &&
              item.startTime.day == currentDate.day;
        }).toList();

        final isToday =
            DateFormat('yyyy-MM-dd').format(currentDate) ==
            DateFormat('yyyy-MM-dd').format(DateTime.now());

        return GestureDetector(
          onTap: () {
            ref.read(selectedDateProvider.notifier).state = currentDate;
            ref.read(viewModeProvider.notifier).state = ViewMode.day;
          },
          child: Container(
            decoration: BoxDecoration(
              color: isToday
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                if (dayItems.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: dayItems.take(3).map((item) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
