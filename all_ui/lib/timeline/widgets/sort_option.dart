import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timeline_view.dart';
import '../states/timeline_provider.dart';

class SortOptions extends ConsumerWidget {
  const SortOptions({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timelineProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    SortMode.values.map((mode) {
                      final isSelected = state.sortMode == mode;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(
                            _getSortLabel(mode),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: const Color(0xFF1A1A2E),
                          selectedColor: const Color(0xFF6C63FF),
                          onSelected:
                              (_) => ref
                                  .read(timelineProvider.notifier)
                                  .setSortMode(mode),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(SortMode mode) {
    switch (mode) {
      case SortMode.popularity:
        return '⭐ Popular';
      case SortMode.chronological:
        return '📅 Oldest First';
      case SortMode.reverseChronological:
        return '🕐 Newest First';
      case SortMode.relevance:
        return '🎯 By Impact';
    }
  }
}
