// Filtered Items Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/agenda_item.dart';
import 'agenda_items_provider.dart';
import 'agenda_provider.dart';

final filteredItemsProvider = Provider<List<AgendaItem>>((ref) {
  final itemsAsync = ref.watch(agendaItemsProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategories = ref.watch(selectedCategoriesProvider);
  final showCompleted = ref.watch(showCompletedProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return itemsAsync.when(
    data: (items) {
      // Expand recurring events for current month
      final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
      final monthEnd = DateTime(selectedDate.year, selectedDate.month + 1, 0);

      final notifier = ref.read(agendaItemsProvider.notifier);
      var filtered = notifier.getExpandedItems(
        monthStart.subtract(const Duration(days: 7)),
        monthEnd.add(const Duration(days: 7)),
      );

      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((item) {
          return item.title.toLowerCase().contains(searchQuery) ||
              item.description.toLowerCase().contains(searchQuery) ||
              item.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
        }).toList();
      }

      if (selectedCategories.isNotEmpty) {
        filtered = filtered
            .where((item) => selectedCategories.contains(item.category))
            .toList();
      }

      if (!showCompleted) {
        filtered = filtered.where((item) => !item.isCompleted).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
