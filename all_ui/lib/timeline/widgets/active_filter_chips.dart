import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/timeline_provider.dart';

class ActiveFiltersChips extends ConsumerWidget {
  const ActiveFiltersChips({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timelineProvider);
    final hasFilters =
        state.selectedCategories.isNotEmpty ||
        state.searchQuery.isNotEmpty ||
        state.startDate != null ||
        state.showFavorites;
    if (!hasFilters) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (state.selectedCategories.isNotEmpty)
            ActionChip(
              avatar: const Icon(Icons.clear_all, size: 18),
              label: Text(
                'Clear Categories (${state.selectedCategories.length})',
              ),
              onPressed:
                  () => ref.read(timelineProvider.notifier).clearCategories(),
              backgroundColor: const Color(0xFF1A1A2E),
            ),
          if (state.startDate != null || state.endDate != null)
            ActionChip(
              avatar: const Icon(Icons.date_range, size: 18),
              label: const Text('Clear Date Range'),
              onPressed:
                  () => ref.read(timelineProvider.notifier).clearDateRange(),
              backgroundColor: const Color(0xFF1A1A2E),
            ),
        ],
      ),
    );
  }
}
